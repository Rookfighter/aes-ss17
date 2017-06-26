#ifndef _GPIO_DMD_H_
#define _GPIO_DMD_H_

typedef struct galois_gpio_data {
  int port;       /* port number: for SoC, 0~31; for SM, 0~11 */
  int mode;       /* port mode: data(in/out) or irq(level/edge) */
  unsigned int data;      /* port data: 1 or 0, only valid when mode is data(in/out) */
} galois_gpio_data_t;

#define GPIO0_DIR                         0x020B
#define GPIO0_DATA_IN                     0x020C
#define GPIO0_DATA_OUT                    0x020D
#define GPIO0_STATUS                      0x020E
#define GPIO0_IT_MASK                     0x020F
#define GPIO0_DFT                         0x0210
#define GPIO0_MASK_DATA                   0x0211
#define GPIO1_DIR                         0x0212
#define GPIO1_DATA_IN                     0x0213
#define GPIO1_DATA_OUT                    0x0214
#define GPIO1_STATUS                      0x0215
#define GPIO1_IT_MASK                     0x0216
#define GPIO_DEVICE "/dev/gpio"

#define GPIO_IOCTL_READ                 0x1111
#define GPIO_IOCTL_WRITE                0x1112
#define GPIO_IOCTL_SET                  0x1113
#define GPIO_IOCTL_GET                  0x1114
#define GPIO_IOCTL_INIT_IRQ             0x2222
#define GPIO_IOCTL_EXIT_IRQ             0x2223
#define GPIO_IOCTL_ENABLE_IRQ   0x2224
#define GPIO_IOCTL_DISABLE_IRQ  0x2225
#define GPIO_IOCTL_CLEAR_IRQ    0x2226
#define GPIO_IOCTL_READ_IRQ             0x2227

#define SM_GPIO_IOCTL_READ                      0x3333
#define SM_GPIO_IOCTL_WRITE                     0x3334
#define SM_GPIO_IOCTL_SET                       0x3335
#define SM_GPIO_IOCTL_GET                       0x3336
#define SM_GPIO_IOCTL_INIT_IRQ          0x4444
#define SM_GPIO_IOCTL_EXIT_IRQ          0x4445
#define SM_GPIO_IOCTL_ENABLE_IRQ        0x4446
#define SM_GPIO_IOCTL_DISABLE_IRQ       0x4447
#define SM_GPIO_IOCTL_CLEAR_IRQ         0x4448
#define SM_GPIO_IOCTL_READ_IRQ          0x4449

#define GPIO_MODE_DATA_IN               1
#define GPIO_MODE_DATA_OUT              2
#define GPIO_MODE_IRQ_LOWLEVEL  3
#define GPIO_MODE_IRQ_HIGHLEVEL 4
#define GPIO_MODE_IRQ_RISEEDGE  5
#define GPIO_MODE_IRQ_FALLEDGE  6

int gpio_open(galois_gpio_data_t gpio_data);
int gpio_close();
int gpio_write(galois_gpio_data_t gpio_data);
int set_gpio(int port_no,int val);
int gpio_read(int port_no);

int set_pinmux(int owner, int group, int value);

#endif
