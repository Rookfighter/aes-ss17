-- whole_design.vhd
--
-- Created on: 08 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;

entity whole_design is
    generic(RSTDEF: std_logic := '0');
    port(rst: in    std_logic;   -- reset, RSTDEF active
         clk: in    std_logic;   -- clock, rising edge
         led: out   std_logic;   -- led, high active
         sda: inout std_logic;   -- serial data of I2C
         scl: inout std_logic);  -- serial clock of I2C
 end entity;

 architecture behavioral of whole_design is

    component i2c_slave
    generic(RSTDEF:  std_logic := '0';
            ADDRDEF: std_logic_vector(6 downto 0) := "0100000");
    port(rst:  in    std_logic;                       -- reset, RSTDEF active
         clk:  in    std_logic;                       -- clock, rising edge
         data: out   std_logic_vector(7 downto 0);    -- data out, received byte
         sda:  inout std_logic;                       -- serial data of I2C
         scl:  inout std_logic);                      -- serial clock of I2C
    end component;

    signal data: std_logic_vector(7 downto 0) := (others => '0');

 begin

    slave1: i2c_slave
        generic map(RSTDEF  => RSTDEF,
                    ADDRDEF => "0100000")
        port map(rst => rst,
                 clk => clk,
                 data => data,
                 sda => sda,
                 scl => scl);

    led <= '1' when data = "01000000" else '0';
end architecture;
