-- i2c_slave_tb.vhd
--
-- Created on: 08 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;

entity i2c_slave_read_tb is
end entity;

architecture behavior of i2c_slave_read_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component i2c_slave
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
    end component;

    --Inputs
    signal rst:     std_logic := '0';
    signal clk:     std_logic := '0';
    signal tx_data: std_logic_vector(7 downto 0) := (others => '0');

    --BiDirs
    signal sda: std_logic := '1';
    signal scl: std_logic := '1';

    --Outputs
    signal tx_sent: std_logic;
    signal rx_data: std_logic_vector(7 downto 0);
    signal rx_recv: std_logic;
    signal rdy:     std_logic;

    -- Clock period definitions
    constant clk_period: time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: i2c_slave
        generic map(RSTDEF => '0',
                    ADDRDEF => "0010111") -- address 0x17
        port map(rst     => rst,
                 clk     => clk,
                 tx_data => tx_data,
                 tx_sent => tx_sent,
                 rx_data => rx_data,
                 rx_recv => rx_recv,
                 rdy     => rdy,
                 sda     => sda,
                 scl     => scl);

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
        procedure send_bit(tosend: std_logic) is
        begin
            scl <= '0';
            sda <= tosend;
            -- wait for delay element to take over new value
            wait for 24*clk_period;
            -- allow slave to read
            scl <= '1';
            wait for clk_period;
        end procedure;
        
        procedure recv_bit is
        begin
            scl <= '0';
            sda <= 'Z';
            wait for clk_period;
            scl <= '1';
            wait for clk_period;
        end procedure;
        
        procedure send_ack is
        begin
            send_bit('0');
        end procedure;

        procedure wait_ack is
        begin
            send_bit('Z');
            -- wait additional cycle for slave to release SDA again
            scl <= '0';
            wait for clk_period;
        end procedure;

        procedure send_init is
        begin
            send_bit('1');
            -- rise sda without changing clk
            sda <= '0';
            wait for 25*clk_period;
        end procedure;

        procedure send_term is
        begin
            send_bit('0');
            -- rise sda without changing clk
            sda <= '1';
            wait for 25*clk_period;
        end procedure;
    begin
        -- hold reset state for 100 ns.
        wait for clk_period*10;
        rst <= '1';

        -- init transmission
        send_init;

        -- send address
        send_bit('0'); -- address bit 1
        send_bit('0'); -- address bit 2
        send_bit('1'); -- address bit 3
        send_bit('0'); -- address bit 4
        send_bit('1'); -- address bit 5
        send_bit('1'); -- address bit 6
        send_bit('1'); -- address bit 7
        send_bit('1'); -- direction bit

        tx_data <= "Z00ZZ00Z";
        
        -- we should receive acknowledge here
        wait_ack; -- release sda

        -- recv data
        recv_bit; -- data bit 1
        recv_bit; -- data bit 2
        recv_bit; -- data bit 3
        recv_bit; -- data bit 4
        recv_bit; -- data bit 5
        recv_bit; -- data bit 6
        recv_bit; -- data bit 7
        recv_bit; -- data bit 8

        -- send acknowledge to slave
        send_ack;

        tx_data <= "Z0Z00ZZZ";
        
        -- recv data
        recv_bit; -- data bit 1
        recv_bit; -- data bit 2
        recv_bit; -- data bit 3
        recv_bit; -- data bit 4
        recv_bit; -- data bit 5
        recv_bit; -- data bit 6
        recv_bit; -- data bit 7
        recv_bit; -- data bit 8
        
        -- send acknowledge to slave
        send_ack;
        
        -- terminate transmission
        send_term;

        wait;
    end process;

end;
