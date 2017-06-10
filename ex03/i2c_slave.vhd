-- i2c_slave.vhd
--
-- Created on: 08 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_slave is
    generic(RSTDEF:  std_logic := '0';
            ADDRDEF: std_logic_vector(6 downto 0) := "0100000");
    port(rst:     in    std_logic;                    -- reset, RSTDEF active
         clk:     in    std_logic;                    -- clock, rising edge
         tx_data: in    std_logic_vector(7 downto 0); -- tx, data to send
         tx_sent: out   std_logic;                    -- tx was sent, high active
         rx_data: out   std_logic_vector(7 downto 0); -- rx, data received
         rx_recv: out   std_logic;                    -- rx received, high active
         rdy:     out   std_logic;                    -- ready, high active
         sda:     inout std_logic;                    -- serial data of I2C
         scl:     inout std_logic);                   -- serial clock of I2C
end entity;

architecture behavioral of i2c_slave is

    component delay
    generic(RSTDEF: std_logic := '0';
            DELAYLEN: natural := 8);
    port(rst:  in  std_logic;   -- reset, RSTDEF active
         clk:  in  std_logic;   -- clock, rising edge
         din:  in  std_logic;   -- data in
         dout: out std_logic);  -- data out
    end component;

    -- states for FSM
    type TState is (SIDLE, SADDR, SSEND_ACK1, SSEND_ACK2, SRECV_ACK, SREAD, SWRITE);
    signal state: TState := SIDLE;

    -- constant to define cycles per time unit
    constant CLKPERMS: natural := 24000;

    -- counter for measuring time to timeout after 1ms
    constant TIMEOUTLEN:  natural := 15;
    signal   cnt_timeout: unsigned(TIMEOUTLEN-1 downto 0) := (others => '0');

    -- data vector for handling traffic internally
    constant DATALEN: natural := 8;
    signal   data:    std_logic_vector(DATALEN-1 downto 0) := (others => '0');

    -- determines if master reqested read (high) or write (low)
    signal rwbit: std_logic := '0';

    -- sda signal delayed by 1us
    signal sda_del: std_logic := '0';
    -- i2c vectors to store previous and current signal
    signal scl_vec: std_logic_vector(1 downto 0) := (others => '0');
    signal sda_vec: std_logic_vector(1 downto 0) := (others => '0');
begin

    scl <= 'Z';
    scl_vec(0) <= scl;
    sda_vec(0) <= sda_del;
    rdy <= '1' when state = SIDLE else '0';

    -- delay sda signal by 24 cylces (= 1us)
    delay1: delay
        generic map(RSTDEF => RSTDEF,
                    DELAYLEN => 24)
        port map(rst => rst,
                 clk => clk,
                 din => sda,
                 dout => sda_del);

    process(clk, rst)
    begin
        if rst = RSTDEF then
            tx_sent <= '0';
            rx_data <= (others => '0');
            rx_recv <= '0';
            sda <= 'Z';
            state <= SIDLE;
            cnt_timeout <= (others => '0');
            data <= (others => '0');
            rwbit <= '0';
            scl_vec(1) <= '0';
            sda_vec(1) <= '0';
        elsif rising_edge(clk) then
            -- keep track of previous sda and scl
            sda_vec(1) <= sda_vec(0);
            scl_vec(1) <= scl_vec(0);

            -- leave sent and recv signals high only one cylce
            tx_sent <= '0';
            rx_recv <= '0';

            -- check for timeout
            cnt_timeout <= cnt_timeout + 1;
            if scl_vec = "01" then
                -- reset timeout on rising scl
                cnt_timeout <= (others => '0');
            elsif to_integer(cnt_timeout) = CLKPERMS then
                -- timeout is reached go into idle state
                cnt_timeout <= (others => '0');
                state <= SIDLE;
                sda <= 'Z';
            end if;

            -- check for i2c stop condition
            if scl_vec = "11" and sda_vec = "01" then
                state <= SIDLE;
                sda <= 'Z';
            end if;

            -- compute state machine for i2c slave
            case state is
                when SIDLE =>
                    -- check for i2c start condition
                    if scl_vec = "11" and sda_vec = "10" then
                        state <= SADDR;
                        data <= "00000001";
                    end if;
                when SADDR =>
                    if scl_vec = "01" then
                        -- shift sda in from the right side
                        data <= data(DATALEN-2 downto 0) & sda_vec(0);

                        -- if carry bit is 1 then we just received the 8th bit
                        -- (direction bit) for the address
                        if data(DATALEN-1) = '1' then
                            rwbit <= sda_vec(0);
                            if data(DATALEN-2 downto 0) = ADDRDEF then
                                -- address matches ours, acknowledge
                                state <= SSEND_ACK1;
                            else
                                -- address doesn't match ours, ignore
                                state <= SIDLE;
                            end if;
                        end if;
                    end if;
                when SSEND_ACK1 =>
                    if scl_vec = "10" then
                        state <= SSEND_ACK2;
                        sda <= '0';
                    end if;
                when SSEND_ACK2 =>
                    if scl_vec = "10" then
                        -- check if master requested read or write
                        if rwbit = '1' then
                            -- master wants to read
                            sda <= tx_data(7); -- write first bit on bus
                            data <= tx_data(6 downto 0) & '1';
                            state <= SREAD;
                        else
                            -- master wants to write
                            sda <= 'Z'; -- release sda
                            data <= "00000001";
                            state <= SWRITE;
                        end if;
                    end if;
                when SRECV_ACK =>
                    if scl_vec = "01" then
                        -- check for ack
                        if sda_vec(0) /= '0' then
                            -- no ack received
                            state <= SIDLE;
                        end if;
                    elsif scl_vec = "10" then
                        -- continue read
                        sda <= tx_data(7); -- write first bit on bus
                        data <= tx_data(6 downto 0) & '1';
                        state <= SREAD;
                    end if;
                when SREAD =>
                    if scl_vec = "10" then
                        sda <= data(7);
                        data <= data(6 downto 0) & '0';

                        -- if carry bit is 1 then we have sent everything
                        -- data is not allowed to contain any 1, only Z or 0
                        if data(7) = '1' then
                            sda <= 'Z';
                            state <= SRECV_ACK;
                            tx_sent <= '1';
                        end if;
                    end if;
                when SWRITE =>
                    if scl_vec = "01" then
                        -- shift sda in from the right side
                        data <= data(DATALEN-2 downto 0) & sda_vec(0);

                        -- if carry bit is 1 then we just received the 8th bit
                        if data(DATALEN-1) = '1' then
                            state <= SSEND_ACK1;
                            -- apply received byte to out port
                            rx_data <= data(DATALEN-2 downto 0) & sda_vec(0);
                            rx_recv <= '1';
                        end if;
                    end if;
            end case;
        end if;
    end process;
end architecture;
