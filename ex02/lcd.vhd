-- lcd.vhd
--
-- Created on: 14 May 2017
--     Author: Fabian Meyer
--
-- Component to write characters on the LCD display of the Spartan 6
-- FPGA.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lcd is
    generic(RSTDEF: std_logic := '0');
    port(rst:   in  std_logic;                      -- reset, RSTDEF active
         clk:   in  std_logic;                      -- clock, rising edge
         din:   in  std_logic_vector(7 downto 0);   -- data in, 8 bit ASCII char
         posx:  in  std_logic_vector(3 downto 0);   -- x position within a line of LCD
         posy:  in  std_logic;                      -- y position (line number)
         flush: in  std_logic;                      -- flush input, high active
         rdy:   out std_logic;                      -- ready, high active
         en:    out std_logic;                      -- enable, high active
         rw:    out std_logic;
         rs:    out std_logic;
         bl:    out std_logic;
         data:  inout std_logic_vector(3 downto 0));
end entity;

architecture behavioral of lcd is
    -- state for internal state machine of LCD screen
    type TState is (SINIT, SREADY, SFLUSH);
    signal state: TState := SINIT;

    -- constants to define cycles per time unit
    constant CLKPERMS: natural := 24000;
    constant CLKPERUS: natural := 24;
    constant CLKPEREN: natural := 8;

    -- counter for applying enable signal for 300ns (8 cycles)
    constant ENCNTLEN: natural := 4;
    signal   en_cnt:   std_logic_vector(ENCNTLEN-1 downto 0) := (others => '0');

    -- counter for measuring time
    constant CNTLEN: natural := 20;
    signal   cnt:    std_logic_vector(CNTLEN-1 downto 0) := (others => '0');

    -- instruction signal that splits into "rs + rw + data"
    signal   ins:    std_logic_vector(5 downto 0);
begin

    -- carry bit of en_cnt defines enable signal
    en <= en_cnt(ENCNTLEN-1);

    -- map instruction signal to out ports
    rs   <= ins(5);
    rw   <= ins(4);
    data <= ins(3 downto 0);

    process(rst, clk)
    begin
        if rst = RSTDEF then
            state <= SINIT;
            cnt <= (others => '0');
            en_cnt <= (others => '0');
            ins <= (others => '0');

            rdy <= '0';
            bl <= '0';
        elsif rising_edge(clk) then
            cnt <= cnt + 1;
            -- always set enable to 0 again
            -- enable will always only last CLKPEREN cycles
            if en_cnt(ENCNTLEN-1) = '1' then
                en_cnt <= en_cnt + 1;
            end if;

            case state is
                -- init state computes initialization sequence
                when SINIT =>
                    case to_integer(unsigned(cnt)) is
                        when 0 =>
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000000";
                        when 20 * CLKPERMS =>
                            -- after 20ms
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000011";
                        when 30 * CLKPERMS =>
                            -- after 10ms
                            en_cnt(ENCNTLEN-1) <= '1';
                        when 30 * CLKPERMS + 100 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                        when 30 * CLKPERMS + 200 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000010";
                        when 30 * CLKPERMS + 300 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                        when 30 * CLKPERMS + 400 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "001100";
                        when 30 * CLKPERMS + 500 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000000";
                        when 30 * CLKPERMS + 600 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "001100";
                        when 30 * CLKPERMS + 700 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000000";
                        when 30 * CLKPERMS + 800 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000001";
                        when 40 * CLKPERMS + 800 * CLKPERUS =>
                            -- after 10ms
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "000000";
                        when 40 * CLKPERMS + 900 * CLKPERUS =>
                            -- after 100us
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "001100";
                        when 40 * CLKPERMS + 1000 * CLKPERUS - 1 =>
                            -- after 100us - 1 cycle, so we are in ready state
                            -- on next cycle to receive commands
                            -- when we have finished initialization
                            state <= SREADY;
                            rdy <= '1';
                        when others =>
                    end case;
                -- READY state waits for a write command
                when SREADY =>
                    if flush = '1' then
                        state <= SFLUSH;
                        rdy <= '0';
                        cnt <= (others => '0');
                        -- set already first instruction for writing data
                        en_cnt(ENCNTLEN-1) <= '1';
                        ins <= "001" & posy & "00";
                    end if;
                -- FLUSH state writes current char din at position (posx/posy)
                when SFLUSH =>
                    case to_integer(unsigned(cnt)) is
                        when 100 * CLKPERUS =>
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "00" & posx;
                        when 200 * CLKPERUS =>
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "10" & din(7 downto 4);
                        when 300 * CLKPERUS =>
                            en_cnt(ENCNTLEN-1) <= '1';
                            ins <= "10" & din(3 downto 0);
                        when 400 * CLKPERUS - 1 =>
                            state <= SREADY;
                            rdy <= '1';
                        when others =>
                    end case;
            end case;
        end if;
    end process;
end architecture;
