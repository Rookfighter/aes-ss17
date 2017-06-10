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
         dip:      in    std_logic_vector(7 downto 0);  -- DIP buttons, high active
         led:      out   std_logic_vector(7 downto 0);  -- led array, high active
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
    
    signal tx_data: std_logic_vector(7 downto 0) := (others => '0');
    signal rx_data: std_logic_vector(7 downto 0) := (others => '0');
    signal rx_recv: std_logic := '0';

    signal i2c_rdy:   std_logic := '0';

    signal dip_z:     std_logic_vector(7 downto 0) := (others => '0');
 begin
 
    dip_conv:
    for i in 0 to 7 generate
        dip_z(i) <= 'Z' when dip(i) = '1' else '0';
    end generate;

    slave1: i2c_slave
        generic map(RSTDEF  => RSTDEF,
                    ADDRDEF => "0100000")
        port map(rst     => rst,
                 clk     => clk,
                 tx_data => tx_data,
                 tx_sent => open,
                 rx_data => rx_data,
                 rx_recv => rx_recv,
                 rdy     => i2c_rdy,
                 sda     => sda,
                 scl     => scl);

    process(rst, clk)
    begin
        if rst = RSTDEF then
            led <= (others => '0');
        elsif rising_edge(clk) then

            -- check if i2c is ready (i.e. not busy)
            if i2c_rdy = '1' then
                tx_data <= dip_z;
            end if;

            -- check if we received a new byte
            if rx_recv = '1' then
                led <= rx_data;
            end if;
        end if;
    end process;

end architecture;
