# Exercise 02

**Author:** Fabian Meyer

**Due Date:** 29.05.2017

**Note:** Testbenches are marked with the suffix ```_tb```.

## Overview

*lcd*

Module that implements an interface to the LCD screen. It executes the init
sequence for the LCD screen in 2 line mode and allows writing ASCII encoded
characters to it.

---

*lcd_tb*

Testbench for the *lcd* module. Waits for the init sequence to finish and
applies a ASCII character to the module.

---

*whole_design*

Integration module for the LCD component. Writes

```
Hello World!
Foobar
```

on the LCD screen. Also turns on an LED to indicate if reset was triggered
or not.

