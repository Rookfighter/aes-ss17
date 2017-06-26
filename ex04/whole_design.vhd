-- whole_design.vhd
--
-- Created on: 26 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;

entity whole_design is
    generic(RSTDEF: std_logic := '0');
    port(rst:      in    std_logic;
         clk:      in    std_logic;
         gpio:     in    std_logic_vector(5 downto 0);
         lcd_en:   out   std_logic;                     -- LCD enable
         lcd_rw:   out   std_logic;                     -- LCD rw
         lcd_rs:   out   std_logic;                     -- LCD rs
         lcd_bl:   out   std_logic;                     -- LCD backlight
         lcd_data: inout std_logic_vector(3 downto 0)); -- LCD data
end entity;

architecture behavioral of whole_design is
    -- import lcd component
    component lcd
    generic(RSTDEF: std_logic := '0');
    port(rst:   in  std_logic;                       -- reset, RSTDEF active
         clk:   in  std_logic;                       -- clock, rising edge
         din:   in  std_logic_vector(7 downto 0);    -- data in, 8 bit ASCII char
         posx:  in  std_logic_vector(3 downto 0);    -- x position within a line of LCD
         posy:  in  std_logic;                       -- y position (line number)
         flush: in  std_logic;                       -- flush input, high active
         rdy:   out std_logic;                       -- ready, high active
         en:    out std_logic;                       -- enable, high active
         rw:    out std_logic;
         rs:    out std_logic;
         bl:    out std_logic;                       -- backlight, high active
         data:  inout std_logic_vector(3 downto 0)); -- data, dual direction
    end component;

    -- states for communication over GPIO
    type TState is (SIDLE, SCHAR1, SCHAR2, SPOS);
    signal state: TState := SIDLE;

    -- character that will be written on the LCD
    signal char: std_logic_vector(7 downto 0) := (others => '0');
    -- position where char will be written
    signal pos: std_logic_vector(4 downto 0) := (others => '0');
    
    signal reinit: std_logic := '0';
    
    signal lcd_char:  std_logic_vector(7 downto 0) := (others => '0');
    signal lcd_pos:   std_logic_vector(4 downto 0) := (others => '0');
    signal lcd_flush: std_logic := '0';
    signal lcd_rdy:   std_logic := '0';
    signal lcd_rst:   std_logic := '1';
    
    -- gpio clock that keeps track of curr and prev signal
    -- used to detect rising edges
    signal gpio_clk: std_logic_vector(1 downto 0) := (others => '0');
    -- payload of gpios whenever we receive rising edge
    signal gpio_cmd: std_logic_vector(4 downto 0) := (others => '0');
    
begin

    -- curr gpio clk is msb of gpio
    gpio_clk(0) <= gpio(5);
    -- remaining bits hold payload
    gpio_cmd <= gpio(4 downto 0);
    
    lcd_rst <= RSTDEF when reinit = '1' else rst;

    mylcd: lcd
    generic map(RSTDEF => RSTDEF)
    port map (rst =>   lcd_rst,
              clk =>   clk,
              din =>   lcd_char,
              posx =>  lcd_pos(3 downto 0),
              posy =>  lcd_pos(4),
              flush => lcd_flush,
              rdy =>   lcd_rdy,
              en =>    lcd_en,
              rw =>    lcd_rw,
              rs =>    lcd_rs,
              bl =>    lcd_bl,
              data =>  lcd_data);

    process(rst, clk)
    begin
        if rst = RSTDEF then
            state <= SIDLE;
            char <= (others => '0');
            pos <= (others => '0');
            reinit <= '0';
            
            lcd_char <= (others => '0');
            lcd_pos <= (others => '0');
            lcd_flush <= '0';
            
            gpio_clk(1) <= '0';
        elsif rising_edge(clk) then
            -- always keep track of prev gpio_clk
            -- so we can detect rising and falling edges
            gpio_clk(1) <= gpio_clk(0);
            
            -- keep reinit active for only one cycle
            reinit <= '0';
 
            -- flush whenever possible
            lcd_flush <= '0';
            if lcd_rdy = '1' and lcd_flush = '0' and state = SIDLE then
                -- data has to be stored temporarily, so it cannot
                -- be changed while LCD is writing
                lcd_pos <= pos;
                lcd_char <= char;
                lcd_flush <= '1';
            end if;
            
            -- only process communication state machine if
            -- gpio_clk shows rising edge
            if gpio_clk = "01" then
                case state is
                    when SIDLE =>
                        -- possible commands:
                        --   "00001": reset LCD (reinit)
                        --   "00010": write new char to LCD
                        --   "00011": change position of character
                        if gpio_cmd = "00001" then
                            reinit <= '1';
                        elsif gpio_cmd = "00010" then
                            state <= SCHAR1;
                        elsif gpio_cmd = "00011" then
                            state <= SPOS;
                        end if;
                    when SCHAR1 =>
                        -- receive first half of character
                        -- msb of gpio_cmd is unused here
                        char(7 downto 4) <= gpio_cmd(3 downto 0);
                        state <= SCHAR2;
                    when SCHAR2 =>
                        -- receive second half of character
                        -- msb of gpio_cmd is unused here
                        char(3 downto 0) <= gpio_cmd(3 downto 0);
                        state <= SIDLE;
                    when SPOS =>
                        -- gpio_cmd contains position update
                        -- msb is posy, remaining are posx
                        pos <= gpio_cmd;
                        state <= SIDLE;
                end case;
            end if;
            
        end if;
    end process;       
end architecture;
