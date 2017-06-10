-- whole_design.vhd
--
-- Created on: 08 Jun 2017
--     Author: Fabian Meyer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity whole_design is
    generic(RSTDEF: std_logic := '0');
    port(rst:      in    std_logic;                     -- reset, RSTDEF active
         clk:      in    std_logic;                     -- clock, rising edge
         dip:      in    std_logic_vector(7 downto 0);
         lcd_en:   out   std_logic;                     -- enable, high active
         lcd_rw:   out   std_logic;
         lcd_rs:   out   std_logic;
         lcd_bl:   out   std_logic;
         led:      out   std_logic;                     -- led, high active
         lcd_data: inout std_logic_vector(3 downto 0);  -- data, dual direction
         sda:      inout std_logic;                     -- serial data of I2C
         scl:      inout std_logic);                    -- serial clock of I2C
 end entity;

 architecture behavioral of whole_design is

    -- import i2c slave
    component i2c_slave
    generic(RSTDEF:  std_logic := '0';
            ADDRDEF: std_logic_vector(6 downto 0) := "0100000");
    port(rst:     in    std_logic;                    -- reset, RSTDEF active
         clk:     in    std_logic;                    -- clock, rising edge
         tx_data: in    std_logic_vector(7 downto 0); -- tx, data to send
         tx_sent: out   std_logic;                    -- tx was sent, high active
         rx_data: out   std_logic_vector(7 downto 0); -- rx, data received
         rx_recv: out   std_logic;                    -- rx received, high active
         rdy:     out   std_logic;                    -- ready, high active
         sda:     inout std_logic;                    -- serial data of I2C
         scl:     inout std_logic);                   -- serial clock of I2C
    end component;

    -- import lcd component
    component lcd
    generic(RSTDEF: std_logic := '0');
    port(rst:   in    std_logic;                       -- reset, RSTDEF active
         clk:   in    std_logic;                       -- clock, rising edge
         din:   in    std_logic_vector(7 downto 0);    -- data in, 8 bit ASCII char
         posx:  in    std_logic_vector(3 downto 0);    -- x position within a line of LCD
         posy:  in    std_logic;                       -- y position (line number)
         flush: in    std_logic;                       -- flush input, high active
         rdy:   out   std_logic;                       -- ready, high active
         en:    out   std_logic;                       -- enable, high active
         rw:    out   std_logic;
         rs:    out   std_logic;
         bl:    out   std_logic;                       -- backlight, high active
         data:  inout std_logic_vector(3 downto 0));   -- data, dual direction
    end component;

    -- counter which splits into x and y pos
    signal pos_cnt:   unsigned(4 downto 0) := (others => '1');
    signal bit_cnt:   unsigned(7 downto 0);
    signal lcd_posx:  std_logic_vector(3 downto 0) := (others => '0');
    signal lcd_posy:  std_logic := '0';

    signal rx_data: std_logic_vector(7 downto 0) := (others => '0');
    signal rx_recv: std_logic := '0';

    constant BUFLEN:   natural := 256;
    signal   cbuf:     std_logic_vector(BUFLEN-1 downto 0) := (others => '0');

    signal i2c_rdy:   std_logic := '0';

    signal lcd_din:   std_logic_vector(7 downto 0);
    signal lcd_flush: std_logic := '0';
    signal lcd_rdy:   std_logic := '0';
    signal dip_z:     std_logic_vector(7 downto 0) := (others => '0');
 begin

    led <= not rst;
    -- lower bits of pos_cnt define x position of character to write
    lcd_posx <= std_logic_vector(pos_cnt(3 downto 0));
    -- carry bit of pos_cnt defines line
    lcd_posy <= std_logic(pos_cnt(4));

    gen_conv:
    for i in 0 to 7 generate
        dip_z(i) <= 'Z' when dip(i) = '1' else '0';
    end generate;
    
    -- append 3 zeros to multiply by 8
    bit_cnt <= pos_cnt & "000";
    lcd_din <= cbuf(BUFLEN-to_integer(bit_cnt)-1 downto BUFLEN-to_integer(bit_cnt)-8);

    slave1: i2c_slave
        generic map(RSTDEF  => RSTDEF,
                    ADDRDEF => "0100000")
        port map(rst     => rst,
                 clk     => clk,
                 tx_data => dip_z,
                 tx_sent => open,
                 rx_data => rx_data,
                 rx_recv => rx_recv,
                 rdy     => i2c_rdy,
                 sda     => sda,
                 scl     => scl);

    lcd1: lcd
        generic map(RSTDEF  => RSTDEF)
        port map (rst   => rst,
                  clk   => clk,
                  din   => lcd_din,
                  posx  => lcd_posx,
                  posy  => lcd_posy,
                  flush => lcd_flush,
                  rdy   => lcd_rdy,
                  en    => lcd_en,
                  rw    => lcd_rw,
                  rs    => lcd_rs,
                  bl    => lcd_bl,
                  data  => lcd_data);

    process(rst, clk)
    begin
        if rst = RSTDEF then
            lcd_flush <= '0';
            pos_cnt <= (others => '1');
            cbuf <= (others => '0');
        elsif rising_edge(clk) then
            -- always reset flush after one cycle
            lcd_flush <= '0';

            -- check if i2c is ready (i.e. not busy)
            if i2c_rdy = '1' then
                -- check if lcd is ready and we are not currently flushing
                if lcd_rdy   = '1' and
                   lcd_flush = '0' then
                    -- increment position
                    pos_cnt <= pos_cnt + 1;
                    -- flush current input
                    lcd_flush <= '1';
                end if;
            -- check if we received a new byte
            elsif rx_recv = '1' then
                -- shift incoming data into buffer from the right side
                cbuf <= cbuf(BUFLEN-9 downto 0) & rx_data;
                -- reset position counter for lcd
                pos_cnt <= (others => '1');
            end if;
        end if;
    end process;

end architecture;
