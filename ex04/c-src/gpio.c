// Copyright 2014: Sebastian Sester, Jan Burchard
// LCD example for the ARMADA board
// displays the current UTC time

#include <stdio.h>
#include <math.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <time.h>

#include "gpio_common.h"


/*
List of GPIO pins on the ARMADA board
note: only pins 1, 3, 4, 8, 9 and 23 appear to be working

gpio 1:  fpga V14 , sm
gpio 3:  fpga U15 , sm
gpio 4:  fpga AD17, no sm
gpio 7:  fpga AC15, NOT WORKING!
gpio 8:  fpga AD15, sm
gpio 9:  fpga AC16, sm
gpio 10: fpga AF18, NOT WORKING!
gpio 11: fpga AC19, NOT WORKING!
gpio 23, fpga AD18, no sm
*/

#define LCD_INIT_CMD 0x01
#define LCD_CHAR_CMD 0x02
#define LCD_POS_CMD  0x03

int sFd;
FILE *spFile = NULL;

static int gpio_cmd_ports[5] = {1, 3, 4, 8, 9};
static int gpio_clk_port = 23;

static uint8_t posx = 0;
static uint8_t posy = 0;


// helper to pause execution for the given amount of ms
void msleep (int ms) {
    while (ms--) {
        usleep(1000);
    }
}

/*
 * GPIO functions - you do not need to change anything here
 */


int gpio_open(galois_gpio_data_t gpio_data) {
    if (spFile == NULL) {
        spFile = fopen(GPIO_DEVICE, "rw+");
        if (!spFile) {
            printf("Failed to open GPIO_DEVICE.\n");
            return -1;
        }
    }
    sFd = fileno(spFile);

    // non-sm mode only for ports 4 and 23
    if (gpio_data.port == 4 || gpio_data.port == 23) {
        if (ioctl(sFd, GPIO_IOCTL_SET, &gpio_data)) {
            printf("ioctl GPIO_IOCTL_SET error.\n");
            fclose(spFile);
            return -1;
        }
    }
    else {
        if (ioctl(sFd, SM_GPIO_IOCTL_SET, &gpio_data)) {
            printf("ioctl SM_GPIO_IOCTL_SET error.\n");
            fclose(spFile);
            return -1;
        }
    }
    return 0;
}

int gpio_close() {
    if (spFile != NULL) {
        fclose(spFile);
        spFile = NULL;
    }
    return 0;
}

int gpio_write(galois_gpio_data_t gpio_data) {
    // non-sm mode only for ports 4 and 23
    if (gpio_data.port == 4 || gpio_data.port == 23) {
        if (ioctl(sFd, GPIO_IOCTL_WRITE, &gpio_data)) {
            printf("ioctl GPIO_IOCTL_WRITE error. port: %d, value: %d\n", gpio_data.port, gpio_data.data);
            return -1;
        }
    }
    else {
        if (ioctl(sFd, SM_GPIO_IOCTL_WRITE, &gpio_data)) {
            printf("ioctl SM_GPIO_IOCTL_WRITE error. port: %d, value: %d\n", gpio_data.port, gpio_data.data);
            return -1;
        }
    }
    return 0;
}


// sets the gpio port to the given value (0, 1)
int set_gpio(int port_no,int val) {
    int error = 0;
    galois_gpio_data_t gpio_data;
    gpio_data.port = port_no ;
    gpio_data.mode = 2;
    gpio_data.data = val;
    error |= gpio_open(gpio_data);
    error |= gpio_write(gpio_data);
    error |= gpio_close();
    return error;
}

/* Sends a command to the FPGA over six GPIO pins.
 * Ports 1, 3, 4, 8, 9 are used for payload data.
 * Port 23 is the clk signal which signals the FPGA that
 * the data is ready to read (high). */
int lcd_send_cmd(uint8_t b)
{
    uint8_t dat = b;
    uint8_t val;
    int ret;
    unsigned int i;
    
    // iterate through data and apply it to GPIO ports
    for(i = 0; i < 5; ++i)
    {
        val = dat & 0x01;
        ret = set_gpio(gpio_cmd_ports[i], val);
        if(ret)
            return ret;
        dat = dat >> 1;
    }
    
    // set clk port to high for 100us
    set_gpio(gpio_clk_port, 1);
    if(ret)
        return ret;
    usleep(100);
    
    // set clk port to low again for 100us
    set_gpio(gpio_clk_port, 0);
    if(ret)
        return ret;
    usleep(100);
    
    return 0;
}

/* Sends the command to the FPGA that it should reinit the LCD component. */
int lcd_init() {
    return lcd_send_cmd(LCD_INIT_CMD);
}

/* Sends the given character to the FPGA.
 * Character is split into 4 bit packets. */
int lcd_putc(char c) {
    int ret;
    // send 4 most significant bits first
    uint8_t c1 = (c & 0xf0) >> 4;
    uint8_t c2 = c & 0x0f;
    
    
    // send command to write a character
    ret = lcd_send_cmd(LCD_CHAR_CMD);
    if(ret)
        return ret;
    
    // sends 4 most significant bits of char
    ret = lcd_send_cmd(c1);
    if(ret)
        return ret;
    
    // sends 4 least significant bits of char
    return lcd_send_cmd(c2);
}

/* Sets the position of the cursors on the LCD to given x and y. */
int lcd_set_pos(uint8_t x, uint8_t y) {
    int ret;
    // y is determined by 5th bit
    // x is determined by 4 least significant bits
    uint8_t cmd = ((y & 0x01) << 4) | (x & 0x0f);
    
    // send command to change position of cursor
    ret = lcd_send_cmd(LCD_POS_CMD);
    if(ret)
        return ret;
    
    // send position
    return lcd_send_cmd(cmd);
}

/* Increments the current position of the cursor */
int lcd_inc_pos()
{
    posx = (posx + 1) % 16;
    if(posx == 0)
        posy = (posy + 1) % 2;
    
    return lcd_set_pos(posx, posy);    
}

/* Sends the given unsigned int to the FPGA.
 * Sends at most 5 digits of the number. */
int lcd_put_uint(unsigned int val) {
    int ret;
    unsigned int i;
    char buf[6];
    
    snprintf(buf, 6, "%.5d", val);
    
    for(i = 0; buf[i] != '\0'; ++i) {        
        ret = lcd_putc(buf[i]);
        if(ret)
            return ret;
        
        ret = lcd_inc_pos();
        if(ret)
            return ret;
    }
    
    return 0;
}

/* Sends the given null terminated string to the FPGA. */
int lcd_put_str(const char *str)
{
    int ret;
    unsigned int i;
    size_t len = strlen(str);
    
    for(i = 0; i < len; ++i)
    {
        ret = lcd_putc(str[i]);
        if(ret)
            return ret;
        
        usleep(500);
        
        ret = lcd_inc_pos();
        if(ret)
            return ret;
    }
    
    return 0;
    
}

int lcd_reset_pos()
{
    posx = 0;
    posy = 0;
    return lcd_set_pos(posx, posy);
}

int lcd_clear()
{
    int ret;
    ret = lcd_reset_pos();
    if(ret)
        return ret;

    ret = lcd_put_str("                                ");
    if(ret)
        return ret;
    
    return lcd_reset_pos();
}

int main(int argc, char * argv[]) {
    int ret;
    char buf[33];

    while(1) {
        
        strncpy(buf, "Hello World! I feel brilliant!", 33);
        printf("Sending \"%s\" ...\n", buf);
        
        ret = lcd_clear();
        if(ret)
            return ret;
        
        ret = lcd_put_str(buf);
        if(ret) 
            return ret;
       
        msleep(2000);
        
        strncpy(buf, "This is just a test.", 33);
        printf("Sending \"%s\" ...\n", buf);
        
        ret = lcd_clear();
        if(ret)
            return ret;
        
        ret = lcd_put_str(buf);
        if(ret) 
            return ret;
        
        msleep(2000);
    }

    return 0;
}
