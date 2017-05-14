-- ledblinker.vhd
--
-- Created on: 12 May 2017
--     Author: Fabian Meyer
--
-- LED blinker with configurable frequency.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- LED blinking module
entity ledblinker is
    port (clk:  in  std_logic;                    -- clock, rising edge
          led:  out std_logic);                   -- LED status, active high
end entity ledblinker;

architecture behavioral of ledblinker is
    -- define length of counter
    constant CNTLEN: natural := 24;
    signal cnt: std_logic_vector(CNTLEN-1 downto 0) := (others => '0');
    signal led_int: std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if unsigned(cnt) = 12000000 then
                cnt <= (others => '0');
                led_int <= not led_int;
            else
                cnt <= std_logic_vector(unsigned(cnt) + 1);
            end if;
        end if;
    end process;

    led <= led_int;
end architecture behavioral;
