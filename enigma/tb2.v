
`timescale 1ns / 1ns

module tb;
`include "lib.v"

reg clk=0;
always #5 clk = ~ clk;

reg reset;
reg [7:0]sbyte;
reg wr=0;
wire serial_line;
wire busy;
tx_serial #( .RCONST(108) ) tb_tx_serial_inst(
	.reset( reset ),
	.clk100( clk ),
	.sbyte( sbyte ),
	.send( wr ),
	.tx( serial_line ),
	.busy( busy ) 
	);
	
reg K0,K1;
max10_02 prj(
	.CLK100MHZ( clk ),
	.KEY0( K0 ),
	.KEY1( K1 ),
	.SERIAL_RX( serial_line ),
	.SERIAL_TX(),
	.LED(),
	.IO()
	);

task send_serial_char;
input [7:0]char;
begin
	@(posedge clk); #0;
	sbyte = char;
	wr = 1'b1;
	@(posedge clk); #0;
	sbyte = 0;
	wr = 1'b0;
	#10;
	while( busy ) #10;
	#10;
	@(posedge clk); #0;
end
endtask

initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);
	K0 = 1;
	K1 = 1;
	reset = 1;
	#200;
	K0 = 0;
	reset = 0;
	#2000;
	K0 = 1;
	while( busy ) #10;
	//enigma offset
	send_serial_char("A");
    send_serial_char("D");
    send_serial_char("T");
	//enigma ringst
	send_serial_char("B");
    send_serial_char("C");
    send_serial_char("D");
	//plug board
    send_serial_char("C");
    send_serial_char("D");
    send_serial_char("E");
    send_serial_char("F");
    send_serial_char(8'h0d);
	//send text to encode
	send_serial_char("B");
	send_serial_char("C");
	send_serial_char("D");
	send_serial_char("E");
	send_serial_char("F");
	send_serial_char("G");
	send_serial_char("H");
	send_serial_char("I");
	#2000;
    $finish;
end

endmodule
