
`timescale 1ns / 1ns

module enigma(
	input wire clk,
	input wire rset,
	input wire [14:0]offset_init, //3 ring * 5 bits
	input wire [14:0]ringst_init,
	input wire [25*5+4:0] plug_tbl,
	input wire [7:0]in_char,
	input wire in_char_write,
	output wire [7:0]out_char,
	output reg out_char_ready
);

`include "lib.v"

wire [4:0]plg1_in; assign plg1_in = (in_char-"A");
wire [4:0]plg1_out;
plugboard plg1(
		.char(plg1_in  ),
		.tbl( plug_tbl ),
		.out( plg1_out )
		);

reg [25:0]f_in;
always @*
		f_in <= (1<<plg1_out);

wire [25:0]f_out3;
wire [25:0]b_out3;
wire [25:0]f_out2;
wire [25:0]b_out2;
wire [25:0]f_out1;
wire [25:0]b_out1;
wire [25:0]ukw_out;

wire adv1;
wire adv2;
wire adv3;
rotor #( .TRANSLATION("BDFHJLCPRTXVZNYEIWGAKMUSQO"),
		 .NOTCH("V") ) rot3(
		.clk( clk ),
		.set( rset ),
		.step0(in_char_write),
		.step(in_char_write),
		.offset( offset_init[4:0] ),
		.ringstellung( ringst_init[4:0] ),
		.f_in(f_in),
		.f_out(f_out3),
		.b_in(b_out2),
		.b_out(b_out3),
		.advance( adv3 )
		);

wire [4:0]plg2_in; assign plg2_in = pos2char( b_out3 );
wire [4:0]plg2_out;
plugboard plg2(
		.char( plg2_in ),
		.tbl( plug_tbl ),
		.out( plg2_out )
		);

assign out_char = plg2_out+"A";

//out char ready one clock later then input char
always @(posedge clk)
	out_char_ready <= in_char_write;// && allowed_in;
	
rotor #( .TRANSLATION("AJDKSIRUXBLHWTMCQGZNPYFVOE"),
		 .NOTCH("E") ) rot2(
		.clk( clk ),
		.set( rset ),
		.step0(in_char_write),
		.step( adv3 ),
		.offset( offset_init[9:5] ),
		.ringstellung( ringst_init[9:5] ),
		.f_in(f_out3),
		.f_out(f_out2),
		.b_in(b_out1),
		.b_out(b_out2),
		.advance( adv2 )
		);

rotor #( .TRANSLATION("EKMFLGDQVZNTOWYHXUSPAIBRCJ"),
		 .NOTCH("Q") ) rot1(
		.clk( clk ),
		.set( rset ),
		.step0(in_char_write),
		.step(adv2 ),
		.offset( offset_init[14:10] ),
		.ringstellung( ringst_init[14:10] ),
		.f_in(f_out2),
		.f_out(f_out1),
		.b_in(ukw_out),
		.b_out(b_out1),
		.advance( adv1 )
		);

reflector #( .TRANSLATION("YRUHQSLDPXNGOKMIEBFZCWVJAT") ) ukw_b(
		.in( f_out1 ),
		.out( ukw_out )
	);
wire [7:0]chr_ukw_out; assign chr_ukw_out = pos2letter(ukw_out);

endmodule
