# M02mini
FPGA projects for M02mini MAX10 2K board.
Use Intel Quartus Prime for building projects and programme FPGA boards.

1) max10_02_first
	Simple project with
		- PLL,
		- binary counter,
		- 2 buttons for counter clk enable and asynchronous reset,
		- counter bits output to leds.

2) enigma
	Enigma M3 german kriegsmarine WW2 crypto-machine in FPGA.
	Control Enigma via serial port (use Putty): enter initial crypto key
	initial rotors offset 3 chars, then 3 chars ringstellung, then few pairs of chars presenting plugboard wires and press enter.
	Then type message for crypt or decrypt.

3) max10_lfsr
	Random number generator in FPGA.
	When started, sends via serial port random bytes.
	Additionaly Visual Studio app can receive and show received random numbers or
	Python app can draw Specter of captured samples.

4) forth_j1
	Forth processor J1 in FPGA.


