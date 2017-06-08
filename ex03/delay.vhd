-- Delay a signal by a given amount of clock cycles.
-- 2015 by Jan Kuehn

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay is
  generic (
    delayLength : integer
  );
  port (
    clk, reset, signalIn : in std_logic;
    signalOut : out std_logic
  );
end delay;

architecture Behavioral of delay is

  signal delayReg : std_logic_vector (delayLength - 1 downto 0);

begin
  process (clk, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        delayReg <= (others => '1');
      else
        delayReg <= delayReg(delayLength - 2 downto 0) & signalIn;
      end if;
    end if;
  end process;

  signalOut <= delayReg(delayLength - 1);

end Behavioral;

