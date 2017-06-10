/*
 * I2C implementation for the Marvell Armada 1500
 *
 * This code was written by
 * Sebastian Sester <mail@sebastiansester.de>
 * but bases mostly on the I2C-code by RTRK.
 *
 * This code requires the i2c.h-headerfile from
 * the GoogleTV source code.
 *
 * Compile this code with
 * $CC -o i2c i2c.c
 */

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stddef.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <linux/i2c.h>
#include "i2c.h"

// The bus to use.
#define TWSI_BUS "/dev/twsi0"

#define LCDLEN 32
#define SLV_ADDR 0x20

int twsi_device = -1;

// Set the I2C speed to the given speed.
// Please have a look at i2c.h:19ff for valid speeds.
int i2c_set_speed(uint32_t speed) {
    galois_twsi_speed_t twsi_speed_cfg;
    twsi_speed_cfg.mst_id     = 0;
    twsi_speed_cfg.speed_type = TWSI_STANDARD_SPEED;
    twsi_speed_cfg.speed      = speed;
    if (ioctl(twsi_device, TWSI_IOCTL_SETSPEED, &twsi_speed_cfg))
        return -1;
    return 0;
}

// Initialize I2C.
// This will open the bus and set a default speed of 100 KHz.
int i2c_init (void) {
    twsi_device = open(TWSI_BUS, I2C_RDWR);
    if (twsi_device < 0)
        return -1;

    // Start slowly (compatibility mode)
    return i2c_set_speed(TWSI_SPEED_100);
}

// Perform an action on the I2C bus.
// You can either write data (writeBufferLength > 0, readBufferLength == 0)
// or read data (writeBufferLength > 0, readBufferLength > 0).
// (Normally read-commands are issued by writing the address to read and then
// reading the data that's shifted out)
//
// Please note that the slave address is supposed to be a 7 bit address; the
// last bit (0/1) is attached depending on the operation itself (write/read).
int i2c_read_write (uint8_t slv_addr, uint8_t * wr_buf,
                  uint8_t wr_cnt, uint8_t * rd_buf,
                  uint8_t rd_cnt) {
    if (twsi_device < 0) {
        printf("Can't access bus: %s\n", strerror(errno));
        return -1;
    }
    galois_twsi_rw_t twsiTransfer;

    // Hard wired part
    twsiTransfer.mst_id = 0;
    twsiTransfer.addr_type = TWSI_7BIT_SLAVE_ADDR;
    // User defined part
    twsiTransfer.slv_addr = slv_addr;
    twsiTransfer.wr_cnt = wr_cnt;
    twsiTransfer.wr_buf = wr_buf;
    twsiTransfer.rd_cnt = rd_cnt;
    twsiTransfer.rd_buf = rd_buf;
    if (ioctl(twsi_device, TWSI_IOCTL_READWRITE, &twsiTransfer))
        return -1;
    return 0;
}

// Close the I2C connection (normally only necessary when the program ends)
int i2c_close () {
    if (twsi_device < 0) {
        printf("Can't access bus: %s\n", strerror(errno));
        return -1;
    }
    close(twsi_device);
    return 0;
}

int main(int argc, char * argv[]) {
    uint8_t wr_buf[LCDLEN+1];
    uint8_t rd_buf[1];
    int ret;
    int i;

    ret = i2c_init();
    if(ret)
    {
        fprintf(stderr, "Failed to init I2C: %s\n", strerror(errno));
        return 1;
    }

    while(1) {
        // first read current value of DIP switches
        ret = i2c_read_write(SLV_ADDR,
            NULL, 0,
            rd_buf, 1);

        if(ret)
        {
            fprintf(stderr, "Failed to read I2C: %s\n", strerror(errno));
            sleep(3);
            continue;
        }

        // print output text into wr:buf
        snprintf((char*) wr_buf, LCDLEN+1, "Your input is 0x%02x.             ", *rd_buf);

        // send write command to 
        printf("Sending \"%s\" to slave ...\n", (char*) wr_buf);
        for(i = 0; i < LCDLEN; ++i)
        {
            ret = i2c_read_write(SLV_ADDR,
                &wr_buf[i], 1,
                NULL, 0);
                
            if(ret)
            {
                fprintf(stderr, "Failed to write byte %d: %s\n", i + 1 ,strerror(errno));
                break;
            }
        }
        /*ret = i2c_read_write(SLV_ADDR,
            wr_buf, LCDLEN,
            NULL, 0);
        if(ret)
        {
            fprintf(stderr, "Failed to write I2C: %s\n", strerror(errno));
        }*/

        sleep(3);
    }
    
    i2c_close();
    return 0;
}
