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
	
5) pm_radio
	Mono sound music 8bit 22050Hz sampling rate is sent via serial port to FPGA board M02mini.
	FPGA receives bytes and reloads PLL phase according to value of received byte.
	So basic output frequency 100MHz little bit floats modulated by music signal.
	Two 0.75 meter wires connected to digital pins of FPGA board play role of antenna.
	So FPGA board transmits music.
	Use mobile phone with Radio app to listen music remotely up to 10-15 meters.


