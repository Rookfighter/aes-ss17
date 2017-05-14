-- freq_controller.vhd
--
-- Created on: 12 May 2017
--     Author: Fabian Meyer
--
-- Component that allows to set blinking frequency from user input (buttons).
-- Uses sync_buffer component to debounce buttons signals. Button signals
-- are sampled with ~732Hz (24MHz / 2**15).

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity freq_controller is
    generic(RSTDEF: std_logic := '1');
    port(rst:  in  std_logic;                     -- reset, RSTDEF active
         clk:  in  std_logic;                     -- clock, rising edge
         btn0: in  std_logic;                     -- increment button, low active
         btn1: in  std_logic;                     -- decrement button, low active
         freq: out std_logic_vector(2 downto 0)); -- frequency, 000 = stop, 111 = fast
end entity freq_controller;

architecture behavioral of freq_controller is

    -- debounce buffer component for buttons
    component sync_buffer is
    generic(RSTDEF:  std_logic);
    port(rst:    in  std_logic;  -- reset, RSTDEF active
         clk:    in  std_logic;  -- clock, rising edge
         en:     in  std_logic;  -- enable, high active
         din:    in  std_logic;  -- data bit, input
         dout:   out std_logic;  -- data bit, output
         redge:  out std_logic;  -- rising  edge on din detected
         fedge:  out std_logic); -- falling edge on din detected
     end component;

    -- frequency divider by 2**CNTLEN
    constant CNTLEN: natural := 15;
    signal cnt: std_logic_vector(CNTLEN-1 downto 0) := (others => '0');
    signal cnt_tmp: std_logic_vector(CNTLEN downto 0) := (others => '0');
    signal cnt_en: std_logic := '0';

    -- increment frequency
    signal inc: std_logic := '0';
    -- decrement frequency
    signal dec: std_logic := '0';
    -- tmp frequency
    signal freq_tmp: std_logic_vector(2 downto 0) := (others => '0');

begin
    -- carry bit defines enable for sync_buffers
    cnt_en <= cnt_tmp(CNTLEN);
    cnt <= cnt_tmp(CNTLEN-1 downto 0);
    -- connect freq out port with internal freq_tmp
    freq <= freq_tmp;

    process(rst, clk)
    begin
        if rst = RSTDEF then
            cnt_tmp <= (others => '0');
        elsif rising_edge(clk) then
            -- increment frequency divider
            cnt_tmp <= '0' & cnt + 1;

            -- only if enable is set check inc or dec
            if cnt_en = '1' then
                if inc = '1' then
                    -- increment frequency, overflow not handled
                    -- just start at 0 again
                    freq_tmp <= freq_tmp + 1;
                elsif dec = '1' then
                    -- decrement frequency, overflow not handled
                    -- just start at full freq again
                    freq_tmp <= freq_tmp - 1;
                end if;
            end if;
        end if;
    end process;

    -- map rising edge (release button) of btn0 to inc
    -- connect frequency divider carry to enable
    sbuf0: sync_buffer
    generic map(RSTDEF => RSTDEF)
    port map(rst   => rst,
             clk   => clk,
             en    => cnt_en,
             din   => btn0,
             dout  => open,
             redge => inc,
             fedge => open);

     -- map rising edge (release button) of btn1 to dec
     -- connect frequency divider carry to enable
     sbuf1: sync_buffer
     generic map(RSTDEF => RSTDEF)
     port map(rst   => rst,
              clk   => clk,
              en    => cnt_en,
              din   => btn1,
              dout  => open,
              redge => dec,
              fedge => open);

end architecture behavioral;
