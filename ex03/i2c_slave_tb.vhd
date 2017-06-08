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
    port(rst:  in    std_logic;
         clk:  in    std_logic;
         data: out   std_logic_vector(7 downto 0);
         sda:  inout std_logic;
         scl:  inout std_logic);
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
        port generic(RSTDEF => '0',
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
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;
      wait for clk_period*10;
      rst <= '1';

      -- init transmission
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 1
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 2
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 3
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 4
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 5
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 6
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- address bit 7
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- direction bit
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- we should receive acknowledge here
      scl <= '1';
      sda <= 'Z';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 1
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 2
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 3
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 4
      scl <= '1';
      sda <= '0';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 5
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 6
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 7
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;

      -- data bit 8
      scl <= '1';
      sda <= '1';
      wait for clk_period;
      scl <= '0';
      wait for clk_period;


      wait;
   end process;

end;
