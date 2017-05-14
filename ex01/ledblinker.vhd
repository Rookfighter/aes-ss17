-- ledblinker.vhd
--
-- Created on: 12 May 2017
--     Author: Fabian Meyer
--
-- LED blinker with configurable frequency.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- LED blinking module
entity ledblinker is
    generic(RSTDEF: std_logic := '1');
    port (rst:  in  std_logic;                    -- reset, RSTDEF active
          clk:  in  std_logic;                    -- clock, rising edge
          freq: in  std_logic_vector(2 downto 0); -- blinking frequency, 000 = stop, 111 = fast
          led:  out std_logic);                   -- LED status, active high
end entity ledblinker;

architecture behavioral of ledblinker is
    -- define length of counter
    constant CNTLEN : natural := 26;
    -- counter that is incremented on each clk
    signal cnt : std_logic_vector(CNTLEN-1 downto 0) := (others => '0');
    -- counter plus zero bit (freq = 0)
    signal cnt_tmp : std_logic_vector(CNTLEN downto 0) := (others => '0');
begin

    process(rst, clk)
    begin
        if rst = RSTDEF then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            -- increment cnt, carry bit defines LED status
            cnt <= cnt + 1;
        end if;
    end process;

    -- always keep a leading 0 for freq = 0
    cnt_tmp <= '0' & cnt;
    -- led status is defined by carry bit
    -- position of carry bit is defined by freq
    led <= cnt_tmp(CNTLEN - CONV_INTEGER(freq));

end architecture behavioral;
