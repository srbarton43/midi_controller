# midi_controller

Sam Barton & Grant Foley

## Description

This repository contains vhdl code for our ENGS31--Digital Electronics Final Project, a simple midi-controller.
The inputs to our system are the serial MIDI signal (31.25 kHz baudrate), and an external clock (assumed to be 100 MHz).
The intended output is the Pmod DA2, a digital to analog SPI interface, thus the outputs are an SPI chip select signal, serial date signal, and the system clock (1 MHz).
