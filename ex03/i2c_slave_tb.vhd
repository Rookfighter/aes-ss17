-- i2c_slave_tb.vhd
--
-- Created on: 08 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;

entity i2c_slave_tb is
end entity;

architecture behavior of i2c_slave_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component i2c_slave
    generic(RSTDEF:  std_logic := '0';
            ADDRDEF: std_logic_vector(6 downto 0) := "0100000");
    port(rst:  in    std_logic;                       -- reset, RSTDEF active
         clk:  in    std_logic;                       -- clock, rising edge
         data: out   std_logic_vector(7 downto 0);    -- data out, received byte
         sda:  inout std_logic;                       -- serial data of I2C
         scl:  inout std_logic);                      -- serial clock of I2C
    end component;

    --Inputs
    signal rst : std_logic := '0';
    signal clk : std_logic := '0';

    --BiDirs
    signal sda : std_logic := '1';
    signal scl : std_logic := '1';

    --Outputs
    signal data : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: i2c_slave
        generic map(RSTDEF => '0',
                    ADDRDEF => "0010111") -- address 0x17
        port map(rst => rst,
                 clk => clk,
                 data => data,
                 sda => sda,
                 scl => scl);

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

        procedure wait_ack is
        begin
            send_bit('Z');
            -- wait additional cycle for slave to release SDA again
            scl <= '0';
            wait for clk_period;
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
        send_bit('0');

        -- send address
        send_bit('0'); -- address bit 1
        send_bit('0'); -- address bit 2
        send_bit('1'); -- address bit 3
        send_bit('0'); -- address bit 4
        send_bit('1'); -- address bit 5
        send_bit('1'); -- address bit 6
        send_bit('1'); -- address bit 7
        send_bit('0'); -- direction bit

        -- we should receive acknowledge here
        wait_ack; -- release sda

        -- send data
        send_bit('1'); -- data bit 1
        send_bit('1'); -- data bit 2
        send_bit('0'); -- data bit 3
        send_bit('0'); -- data bit 4
        send_bit('1'); -- data bit 5
        send_bit('1'); -- data bit 6
        send_bit('0'); -- data bit 7
        send_bit('1'); -- data bit 8

        -- we should receive acknowledge here
        wait_ack; -- release sda

        -- terminate transmission
        send_term;

        -- just wait a bit
        wait for clk_period*10;

        -- init next transmission
        send_bit('0');

        -- send wrong address 0x13
        send_bit('0'); -- address bit 1
        send_bit('0'); -- address bit 2
        send_bit('1'); -- address bit 3
        send_bit('0'); -- address bit 4
        send_bit('0'); -- address bit 5
        send_bit('1'); -- address bit 6
        send_bit('1'); -- address bit 7
        send_bit('0'); -- direction bit

        -- no ack and go back to idle mode
        wait for clk_period*10;

        wait;
    end process;

end;
