-- i2c_slave.vhd
--
-- Created on: 08 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity i2c_slave is
    generic(RSTDEF:  std_logic := '0';
            ADDRDEF: std_logic_vector(6 downto 0) := "0100000");
    port(rst:  in    std_logic;                       -- reset, RSTDEF active
         clk:  in    std_logic;                       -- clock, rising edge
         data: out   std_logic_vector(7 downto 0);    -- data out, received byte
         sda:  inout std_logic;
         scl:  inout std_logic);
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

    type TState is (SIDLE, SADDR1, SADDR2, SACK1, SACK2, SDATAR1, SDATAR2, SDATAW1, SDATAW2);
    signal state: TState := SIDLE;

    -- constant to define cycles per time unit
    constant CLKPERMS: natural := 24000;

    -- counter for measuring time to timeout after 1ms
    constant TIMEOUTLEN: natural := 15;
    signal cnt_timeout: std_logic_vector(TIMEOUTLEN-1 downto 0) := (others => '0');

    signal dout: std_logic_vector(7 downto 0) := (others => '0');
    signal rdata: std_logic := '0';

    -- sda signal delayed by 1us
    signal sda_del: std_logic := '0';

begin

    -- delay sda signal by 24 cylces (= 1us)
    delay1: delay
        generic map(RSTDEF => RSTDEF,
                    DELAYLEN => 24)
        port map(rst => rst,
                 clk => clk,
                 din => sda,
                 dout => sda_del);

    data <= dout;

    process(clk, rst)
    begin
        if rst = RSTDEF then
            state <= SIDLE;
            cnt_timeout <= (others => '0');
            dout <= (others => '0');
            rdata <= '0';
        elsif rising_edge(clk) then
            cnt_timeout <= cnt_timeout + 1;

            -- whenever we timeout go back to idle state
            if conv_integer(cnt_timeout) = CLKPERMS then
                state <= SIDLE;
            end if;

            case state is
                when SIDLE =>
                    -- check for i2c start condition
                    if scl = '1' and sda_del = '0' then
                        state <= SADDR1;
                        cnt_timeout <= (others => '0');
                        dout <= "00000001";
                    end if;
                when SADDR1 =>
                    if scl = '0' then
                        state <= SADDR2;
                        cnt_timeout <= (others => '0');
                    end if;
                when SADDR2 =>
                    if scl = '1' then
                        state <= SADDR1;
                        cnt_timeout <= (others => '0');

                        -- shift sda in from the right side
                        dout <= dout(6 downto 0) & sda_del;

                        -- if carry bit is 1 then we just received the 8th bit
                        -- (direction bit) for the address (see also SIDLE)
                        if dout(7) = '1' then
                            rdata <= sda_del;
                            if dout(6 downto 0) = ADDRDEF then
                                -- address matches ours, acknowledge
                                state <= SACK1;
                            else
                                -- address doesn't match ours, ignore
                                state <= SIDLE;
                            end if;
                        end if;
                    end if;
                when SACK1 =>
                    if scl = '0' then
                        state <= SACK2;
                        cnt_timeout <= (others => '0');
                        sda <= '0';
                    end if;
                when SACK2 =>
                    if scl = '1' then
                        cnt_timeout <= (others => '0');
                        -- check if master requested read or write
                        if rdata = '1' then
                            -- master wants to read
                            state <= SDATAR1;
                        else
                            -- master wants to write
                            state <= SDATAW1;
                            dout <= "00000001";
                        end if;
                    end if;
                when SDATAR1 =>
                    -- TODO not implemented
                when SDATAR2 =>
                    -- TODO not implemented
                when SDATAW1 =>
                    if scl = '0' then
                        state <= SDATAW2;
                        cnt_timeout <= (others => '0');
                        -- release sda
                        sda <= 'Z';
                    end if;
                when SDATAW2 =>
                    if scl = '1' then
                        state <= SDATAW1;
                        cnt_timeout <= (others => '0');

                        -- shift sda in from the right side
                        dout <= dout(6 downto 0) & sda_del;

                        if dout(7) = '1' then
                            state <= SACK1;
                        end if;
                    end if;
            end case;
        end if;
    end process;
end architecture;
