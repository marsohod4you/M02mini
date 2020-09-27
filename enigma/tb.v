
`timescale 1ns / 1ns

module tb;
`include "lib.v"

reg clk;
always #5 clk = ~ clk;

reg ena;
reg [7:0]chr;
reg chr_wr = 0;
wire [25:0]out1;

reg [3:0]cnt=0;
always @(posedge clk)
	cnt<=cnt+1;
	
always @(posedge clk)
if(ena)
begin
	if(chr<8 && cnt==15)
		chr<=chr+1;
	chr_wr <= (chr<8)&& cnt==15;
end

reg rset;
reg [23:0]offset;
reg [14:0]offs;
reg [23:0]rightstellung;
reg [14:0]rstl;

wire [7:0]chr_out;
wire chr_out_rdy;
enigma enigma_inst(
	.clk( clk ),
	.rset( rset ),
	.offset_init( offs ),
	.ringst_init( rstl ),
	.plug_tbl( { 110'd0, 5'd2, 5'd3, 5'd4, 5'd5 } ),
	.in_char( "A"+chr ),
	.in_char_write(chr_wr),
	.out_char(chr_out),
	.out_char_ready(chr_out_rdy)
);

always @(posedge clk)
begin
	if(chr_out_rdy)
		$display("%c",chr_out);
end

initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);
	clk = 0;
	ena = 0;
	chr=0;
	rset = 0;
	@(posedge clk); #0;
	rset = 1;
	offset="ADT";
	rightstellung="BCD";
	offs[ 4: 0] = offset[ 7: 0]-"A";
	offs[ 9: 5] = offset[15: 8]-"A";
	offs[14:10] = offset[23:16]-"A";
	rstl[ 4: 0] = rightstellung[ 7: 0]-"A";
	rstl[ 9: 5] = rightstellung[15: 8]-"A";
	rstl[14:10] = rightstellung[23:16]-"A";
	@(posedge clk);  #0;
	@(posedge clk);  #0;
	rset = 0;
	@(posedge clk);  #0;
	offs = { 5'h00, 5'h00, 5'h00 };
	rstl = { 5'h00, 5'h00, 5'h00 };
	#50;
	@(posedge clk);  #0;
	ena=1;
	#5000;
    $finish;
end

endmodule
