-- freq_controller.vhd
--
-- Created on: 12 May 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;

entity freq_controller is
    port(freq : out std_logic_vector(2 downto 0)); -- frequency, 000 = stop, 111 = fast
end entity freq_controller;

architecture behavioral of freq_controller is

begin
    freq <= "010";
end architecture behavioral;
