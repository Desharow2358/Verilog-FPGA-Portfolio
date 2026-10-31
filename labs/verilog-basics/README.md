# Two-Digit Adder with Seven-Segment Display

## Overview

This project implements a two-bit full adder using Verilog HDL.

Two 2-bit unsigned numbers, A and B, are added together with an input carry Cin. The 3-bit result is displayed as a decimal digit on a seven-segment display.

## Features

- Two-bit full adder
- Carry-in and carry-out support
- Seven-segment display decoder
- EGO1 FPGA board implementation

## Input and Output

| Signal | Description |
|---|---|
| A[1:0] | First 2-bit unsigned number |
| B[1:0] | Second 2-bit unsigned number |
| Cin | Input carry |
| Sum[1:0] | Two-bit sum |
| Cout | Output carry |

The final result is:

`Result = {Cout, Sum}`

## Simulation

The waveform screenshot is available in:

`simulation/two_digit_adder_waveform.png`

The simulation verifies the relationship between the input operands, carry-in, sum, and carry-out.

## Tools

- Verilog HDL
- Xilinx Vivado 2023.2
- EGO1 FPGA Board