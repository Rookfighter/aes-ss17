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
#include <sys/ioctl.h>
#include <linux/i2c.h>
#include "i2c.h"

// The bus to use.
#define TWSI_BUS "/dev/twsi0"

int twsiDevice = -1;

// Set the I2C speed to the given speed.
// Please have a look at i2c.h:19ff for valid speeds.
int setI2CSpeed(uint32_t speed) {
  galois_twsi_speed_t twsiSpeedConfig;
  twsiSpeedConfig.mst_id     = 0;
  twsiSpeedConfig.speed_type = TWSI_STANDARD_SPEED;
  twsiSpeedConfig.speed      = speed;
  if (ioctl(twsiDevice, TWSI_IOCTL_SETSPEED, &twsiSpeedConfig)) {
    printf("Error in speed negotiation: %s\n", strerror(errno));
    return -1;
  }
  return 0;
}

// Initialize I2C.
// This will open the bus and set a default speed of 100 KHz.
int initI2C (void) {
  twsiDevice = open(TWSI_BUS, I2C_RDWR);
  if (twsiDevice < 0) {
    printf("Can't access bus: %s\n", strerror(errno));
    return -1;
  }
  // Start slowly (compatibility mode)
  setI2CSpeed(TWSI_SPEED_100);
  return 0;
}

// Perform an action on the I2C bus.
// You can either write data (writeBufferLength > 0, readBufferLength == 0)
// or read data (writeBufferLength > 0, readBufferLength > 0).
// (Normally read-commands are issued by writing the address to read and then
// reading the data that's shifted out)
//
// Please note that the slave address is supposed to be a 7 bit address; the
// last bit (0/1) is attached depending on the operation itself (write/read).
int writeReadI2C (uint8_t slave, uint8_t * writeBuffer,
                  uint8_t writeBufferLength, uint8_t * readBuffer,
                  uint8_t readBufferLength) {
  if (twsiDevice < 0) {
    printf("Can't access bus: %s\n", strerror(errno));
    return -1;
  }
  galois_twsi_rw_t twsiTransfer;

  // Hard wired part
  twsiTransfer.mst_id = 0;
  twsiTransfer.addr_type = TWSI_7BIT_SLAVE_ADDR;
  // User defined part
  twsiTransfer.slv_addr = slave;
  twsiTransfer.wr_cnt = writeBufferLength;
  twsiTransfer.wr_buf = writeBuffer;
  twsiTransfer.rd_cnt = readBufferLength;
  twsiTransfer.rd_buf = readBuffer;
  if (ioctl(twsiDevice, TWSI_IOCTL_READWRITE, &twsiTransfer)) {
    // If this throws "Permission denied", you try to read more bytes than
    // the slave writes to the bus.
    printf("Error in communication: %s\n", strerror(errno));
    return -1;
  }
  return 0;
}

// Close the I2C connection (normally only necessary when the program ends)
int closeI2C () {
  if (twsiDevice < 0) {
    printf("Can't access bus: %s\n", strerror(errno));
    return -1;
  }
  close(twsiDevice);
  return 0;
}

// Main routine
int main(int argc, char * argv[]) {
  // Your write buffer (these data will be written)
  uint8_t writeBuffer [1] = {0x40};
  // Your read buffer (data read will end up here)
  uint8_t readBuffer  [1] = {0x00};
  // Amount of bytes that should be written from the write buffer
  uint32_t writeBufferLength = 1;
  // Amount of bytes that should be read into the read buffer
  uint32_t readBufferLength  = 0;

  // The slave's address
  uint8_t slaveAddress = 0x20;

  printf("Writing data to 0x%02x.\n", slaveAddress);
  // Initialize I2C
  if (initI2C() == -1) {
    printf("Couldn't initialize I2C\n");
    return 1;
  }
  // Write one byte (0x40) to the slave address 0x20. Read nothing.
  int success = writeReadI2C(
    slaveAddress,
    writeBuffer, writeBufferLength,  // puffer and # of bytes to write
    readBuffer,  readBufferLength    // puffer and # of bytes to read
  );
  if (success == -1) {
    printf("Couldn't write/read data to I2C.\n");
    return 1;
  }
  // Simply print all received data
  uint32_t counter = 0;
  if (readBufferLength) {
    printf("Data read: ");
    for (; counter < readBufferLength; counter++) {
      printf("%02x", readBuffer[counter]);
    }
    printf("\n");
  }
  // Clean up
  closeI2C();
  return 0;
}
