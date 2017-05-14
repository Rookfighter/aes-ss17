-- sync_buffer.vhd
--
-- Created on: 14 May 2017
--     Author: Fabian Meyer
--
-- Buffer component to debounce signals using hysteresis approach. Waits a
-- certain amount of clock cycles until input signal is applied to output.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sync_buffer is
   generic(RSTDEF: std_logic := '1');

   port(rst:    in  std_logic;  -- reset, RSTDEF active
        clk:    in  std_logic;  -- clock, rising edge
        en:     in  std_logic;  -- enable, high active
        din:    in  std_logic;  -- data bit, input
        dout:   out std_logic;  -- data bit, output
        redge:  out std_logic;  -- rising  edge on din detected
        fedge:  out std_logic); -- falling edge on din detected
end sync_buffer;

-- sync_buffer waits 2**CNTLEN clock cycles until it puts din on dout
architecture behavioral of sync_buffer is

    component flipflop is
        generic(RSTDEF: std_logic);
        port(rst:   in  std_logic;
             clk:   in  std_logic;
             en:    in  std_logic;
             d:     in  std_logic;
             q:     out std_logic);
    end component;

    -- length of counter
    constant CNTLEN : natural := 5; -- after 32 clock cycles value is applied
    constant CNTFULL : std_logic_vector(CNTLEN-1 downto 0) := (others => '1');

    -- counter until input is applied to output
    signal cnt : std_logic_vector(CNTLEN-1 downto 0) := (others => '0');

    -- debounced input signal
    signal din_deb: std_logic := '0';

    -- output signal of flipflop1
    signal q1 : std_logic := '0';
    -- output signal of flipflop2
    signal q2 : std_logic := '0';

begin

    -- signal is chained through 2 flipflops to delay working signal from
    -- original signal
    flipflop1 : flipflop
    generic map(RSTDEF => RSTDEF)
    port map(rst => rst,
            clk => clk,
            en => en,
            d => din,
            q => q1);

    flipflop2 : flipflop
    generic map(RSTDEF => RSTDEF)
    port map(rst => rst,
            clk => clk,
            en => en,
            d => q1,
            q => q2);


    dout <= din_deb;

    -- debouncing like Maxim-Dallas MAX6816
    process (rst, clk)
    begin
        if rst = RSTDEF then
            din_deb <= '0';
            cnt <= CNTEMPTY;
            redge <= '0';
            fedge <= '0';
        elsif rising_edge(clk) then
            redge <= '0';
            fedge <= '0';
            if en = '1' then
                -- only start counting if q2 != din_deb
                -- signal has to stay stable for 2**CNTLEN cycles before it is
                -- applied. Otherwise counter will be reset again.
                if din_deb = q2 then
                    cnt <= (others => '0');
                else
                    cnt <= cnt + 1;
                end if;

                if cnt = CNTFULL then
                    -- counter is full, apply signal and set if it is a rising
                    -- or falling edge
                    redge <= q2;
                    fedge <= not q2;
                    din_deb <= q2;
                end if;
            end if;
        end if;
    end process;

end behavioral;
