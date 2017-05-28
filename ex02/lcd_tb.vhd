-- lcd_tb.vhd
--
-- Created on: 21 May 2017
--     Author: Fabian Meyer
--
-- Testbench for LCD component.

library ieee;
use ieee.std_logic_1164.all;

entity lcd_tb is
end lcd_tb;

architecture behavior of lcd_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component lcd
    generic(RSTDEF: std_logic := '0');
    port(rst:   in     std_logic;
         clk:   in     std_logic;
         din:   in     std_logic_vector(7 downto 0);
         posx:  in     std_logic_vector(3 downto 0);
         posy:  in     std_logic;
         flush: in     std_logic;
         rdy:   out    std_logic;
         en:    out    std_logic;
         rw:    out    std_logic;
         rs:    out    std_logic;
         bl:    out    std_logic;
         data:  inout  std_logic_vector(3 downto 0));
    end component;


    --Inputs
    signal rst:   std_logic := '0';
    signal clk:   std_logic := '0';
    signal din:   std_logic_vector(7 downto 0) := (others => '0');
    signal posx:  std_logic_vector(3 downto 0) := (others => '0');
    signal posy:  std_logic := '0';
    signal flush: std_logic := '0';

    --BiDirs
    signal data: std_logic_vector(3 downto 0);

    --Outputs
    signal rdy: std_logic;
    signal en:  std_logic;
    signal rw:  std_logic;
    signal rs:  std_logic;
    signal bl:  std_logic;

    -- Clock period definitions
    constant clk_period: time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: lcd
    port map (rst => rst,
              clk => clk,
              din => din,
              posx => posx,
              posy => posy,
              flush => flush,
              rdy => rdy,
              en => en,
              rw => rw,
              rs => rs,
              bl => bl,
              data => data);

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

        -- init sequence takes 41ms
        -- with 24MHz this makes 984000 cycles (24000/ms)
        wait for clk_period*984001;

        -- en should always stay on for 8 cycles
        -- rdy should turn 1 here!

        -- write char at pos 4 in line 1
        din <= "11000000";
        posx <= "0100";
        posy <= '1';
        flush <= '1';

        wait for clk_period;
        flush <= '0';
        --rdy should be 0 here!

        -- write sequence takes 400us
        -- with 24MHz this makes 9600 cycles (24/us)
        wait for clk_period*9600;

        -- rdy should be 1 here!

        --wait;
    end process;
end architecture;
