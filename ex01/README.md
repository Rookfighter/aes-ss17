# Exercise 01

**Author:** Fabian Meyer

**Due Date:** 15.05.2017

**Note:** There are 2 *whole_design* implementations. One is the schematic way
which was described in the exercise sheet. The other one is a manual
```.vhd``` file.

I experienced troubles with importing the schema on different machines and I
prefer writing code instead of using GUI applications.

Both implementations were tested and should work, however the **recommended**
top level module is ```whole_design.vhd```.

## Overview

*ledblinker*

Module which let's a LED blink with aconfigurable frequenc.

---

*flipflop*

Module which implements a D-Flipflop which is used for hyteresis.

---

*sync_buffer*

Module which implements a hysteresis approach for debouncing a input signal.

---

*freq_controller*

Module which outputs a frequency value for *ledblinker* and can be controlled
by two buttons to increase or decrease frequency. Makes use of *sync_buffer*
to debounce button signals.
