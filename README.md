# midi_controller

Sam Barton & Grant Foley

## Description

This repository contains vhdl code for our ENGS31--Digital Electronics Final Project, a simple midi-controller.

### Input Ports

* serial MIDI signal (31.25 kHz baudrate)
* external clock (assumed to be 100 MHz).

### Output Ports

The intended output device is the [Pmod DA2](https://digilent.com/shop/pmod-da2-two-12-bit-d-a-outputs), a digital to analog SPI interface which then connects to a speaker through an amp. 

* SPI chip select signal
* serial data signal
* system clock signal (1 MHz).
