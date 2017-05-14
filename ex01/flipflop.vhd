-- flipflop.vhd
--
-- Created on: 14 May 2017
--     Author: Fabian Meyer
--
-- Fliflop component. Apply input to output in sync with clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity flipflop is
    generic(RSTDEF: std_logic := '1');
    port(rst: in  std_logic;   -- reset, RSTDEF active
         clk: in  std_logic;   -- clock, rising edge
         en:  in  std_logic;   -- enable, high active
         d:   in  std_logic;   -- data in
         q:   out std_logic);  -- data out, clock synced
end flipflop;

architecture behavioral of flipflop is
    -- tmp variable for output data
    signal dff: std_logic;
begin

    -- link dff to output
    q <= dff;

    process(rst, clk) is
    begin
        if rst = RSTDEF then
            dff <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                dff <= d;
            end if;
        end if;
    end process;

end behavioral;
