# Two-Bit Adder with Seven-Segment Display

## Overview

This project implements a 2-bit binary adder with an input carry using Verilog HDL. The 3-bit addition result is displayed as a decimal digit on a single seven-segment display.

The result ranges from 0 to 7.

## Hardware and Tools

- **HDL:** Verilog
- **FPGA Board:** EGO1
- **Design Tool:** Vivado
- **Input:** DIP switches
- **Output:** Seven-segment display

## Module Description

| Module | Description |
|---|---|
| `top` | Top-level module. Connects DIP switches, the adder, the decoder, and display outputs. |
| `TwoBitAdder` | Adds two 2-bit binary numbers and an input carry. |
| `segMsg` | Decodes a 4-bit input into seven-segment display signals. |

## Input Mapping

- `sw_pin[1:0]`: Operand A
- `sw_pin[3:2]`: Operand B
- `sw_pin[4]`: Input carry `Cin`

## Output

The adder produces a 3-bit result:

- `Sum[1:0]`: Two least significant result bits
- `Cout`: Carry-out

The result `{Cout, Sum}` is decoded and displayed as a decimal digit from 0 to 7.

## Verification

The design was verified through functional simulation and FPGA hardware testing.

## Source Code

- `two_digit_adder.v` — Contains the top-level module, adder module, and seven-segment decoder.