-- whole_design.vhd
--
-- Created on: 14 May 2017
--     Author: Fabian Meyer
--
-- Integrates ledblinker and freq_controller.

library ieee;
use ieee.std_logic_1164.all;

entity whole_design is
    generic(RSTDEF: std_logic := '0');
    port(rst:  in  std_logic;
         clk:  in  std_logic;
         btn0: in  std_logic;
         btn1: in  std_logic;
         led:  out std_logic;
         freq: out std_logic_vector(2 downto 0));

end whole_design;

architecture behavioral of whole_design is

    component ledblinker is
    generic(RSTDEF: std_logic := '1');
    port (rst:  in  std_logic;                    -- reset, RSTDEF active
          clk:  in  std_logic;                    -- clock, rising edge
          freq: in  std_logic_vector(2 downto 0); -- blinking frequency, 000 = stop, 111 = fast
          led:  out std_logic);                   -- LED status, active high
    end component;
    
    component freq_controller is
    generic(RSTDEF: std_logic := '1');
    port(rst:  in  std_logic;                     -- reset, RSTDEF active
         clk:  in  std_logic;                     -- clock, rising edge
         btn0: in  std_logic;                     -- increment button, low active
         btn1: in  std_logic;                     -- decrement button, low active
         freq: out std_logic_vector(2 downto 0)); -- frequency, 000 = stop, 111 = fast
    end component;
    
    -- signal to connect freq, ledblinker and freq_controller
    signal freq_tmp: std_logic_vector(2 downto 0) := (others => '0');
begin
    
    -- connect freq_tmp to out port freq
    freq <= freq_tmp;
    
    -- connect freq of ledblinker to freq_tmp (read)
    lblink: ledblinker
    generic map(RSTDEF => RSTDEF)
    port map(rst  => rst,
             clk  => clk,
             freq => freq_tmp,
             led  => led);

    -- connect freq of freq_controlelr to freq_tmp (write)
    fcontr : freq_controller
    generic map(RSTDEF => RSTDEF)
    port map(rst  => rst,
             clk  => clk,
             btn0 => btn0,
             btn1 => btn1,
             freq => freq_tmp);

end behavioral;

