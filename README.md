# UART Transmitter and Receiver in Verilog

## Overview
Implemented a UART transmitter and receiver using Verilog RTL, targeting a 25 MHz clock and approximately 115200 baud.

## Features
- Baud-rate timing generator
- UART transmitter: 8-bit data, LSB first
- UART receiver with a 2-flop synchronizer
- Framing-error detection
- Integrated TX-RX loopback

## Design Specifications
- Clock frequency: 25 MHz
- Clock cycles per bit: 217
- Baud rate: Approximately 115207 baud
- Frame format: 8-N-1

## Verification
- Baud generator test: PASS
- UART TX test: PASS
- UART RX test: PASS
- Integrated loopback test: PASS

## Tools
Verilog, GVim, Verilator, WSL/Linux
