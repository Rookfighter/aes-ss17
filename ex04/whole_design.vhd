-- whole_design.vhd
--
-- Created on: 26 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;

entity whole_design is
    generic(RSTDEF: std_logic := '0');
    port(ledi: in  std_logic;
         ledo: out std_logic);
end entity;

architecture behavioral of whole_design is
begin

    ledo <= ledi;

end;
