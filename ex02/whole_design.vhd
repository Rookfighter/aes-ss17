-- whole_design.vhd
--
-- Created on: 21 May 2017
--     Author: Fabian Meyer
--
-- Integrates LCD display to show a custom text.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity whole_design is
    generic(RSTDEF: std_logic := '0');
    port(rst:  in    std_logic;
         clk:  in    std_logic;
         en:   out   std_logic;
         rw:   out   std_logic;
         rs:   out   std_logic;
         bl:   out   std_logic;
         data: inout std_logic_vector(3 downto 0));
end whole_design;

architecture behavioral of whole_design is
    -- import lcd component
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

    -- counter defines which character is printed and at which position
    signal cnt: std_logic_vector(4 downto 0) := (others => '0');

    signal din:   std_logic_vector(7 downto 0) := (others => '0');
    signal posx:  std_logic_vector(3 downto 0) := (others => '0');
    signal posy:  std_logic := '0';
    signal flush: std_logic := '0';
    signal rdy:   std_logic := '0';

begin

    mylcd: lcd
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

    -- lower bits of cnt define x position of character to write
    posx <= cnt(3 downto 0);
    -- carry bit of cnt defines line
    posy <= cnt(4);

    -- map current cnt to a ASCII character
    with conv_integer(cnt) select din <=
        X"48" when  0, -- 'H'
        X"65" when  1, -- 'e'
        X"6c" when  2, -- 'l'
        X"6c" when  3, -- 'l'
        X"6f" when  4, -- 'o'
        X"20" when  5, -- ' '
        X"57" when  6, -- 'W'
        X"6f" when  7, -- 'o'
        X"72" when  8, -- 'r'
        X"6c" when  9, -- 'l'
        X"64" when 10, -- 'd'
        X"21" when 11, -- '!'
        X"46" when 16, -- 'F'
        X"6f" when 17, -- 'o'
        X"6f" when 18, -- 'o'
        X"62" when 19, -- 'b'
        X"61" when 20, -- 'a'
        X"72" when 21, -- 'r'
        X"20" when others;

    process(rst, clk)
    begin
        if rst = RSTDEF then
            cnt <= (others => '0');
            flush <= '0';
        elsif rising_edge(clk) then
            -- disable flush every cycle
            -- flush will always only stable enabled for one cycle
            flush <= '0';

            if rdy = '1' then
                -- increment counter whenever LCD is ready again
                cnt <= cnt + 1;
                -- flush straight away
                flush <= '1';
            end if;
        end if;
    end process;
end behavioral;
