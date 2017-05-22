# Advanced Embedded Systems Lab SS17

Repo for the exercises of the *Advanced Embedded Systems Lab* in SS 17 of the
Albert-Ludwigs Universität Freiburg.

Compilation and synthezing of VHDL code is done with *Xilinx ISE 14.7*.

## Install

Each ```exNN``` is a self contained ISE project. To add a directory as project
perform the following steps in your ISE IDE:

* click on *File > New Project*
* select location as ```<path-to-repo>```
* enter the name of the project, e.g. ```ex01```
* select the following parameters

| Key                | Value    |
|--------------------|----------|
| Family             | Spartan6 |
| Device             | XC6SLX45 |
| Package            | FGG676   |
| Speed              | -3       |
| Synthesis Tool     | XST      |
| Simulator          | ISim     |
| Preferred Language | VHDL     |

* click *finish*
