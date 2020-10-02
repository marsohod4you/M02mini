`timescale 1ns/10ps

module testbench();

reg clk=1'b0;
always #5.0 clk = ~clk;

reg reset;
reg [7:0]sbyte;
reg wr=0;
wire serial_tx;
wire serial_rx;
wire busy;
tx_serial #( .RCONST(108) ) tb_tx_serial_inst(
	.reset( reset ),
	.clk100( clk ),
	.sbyte( sbyte ),
	.send( wr ),
	.tx( serial_tx ),
	.busy( busy ) 
	);

wire [7:0]L;
jtop _jtop(
	.CLK100MHZ( clk ),
	.LED( L ),
	.KEY0( 1'b1 ),
	.KEY1( 1'b1 ),
	.FTDI_RX( serial_tx ),
	.FTDI_TX( serial_rx )
  );

initial
begin
	$dumpfile("test.vcd");
	$dumpvars(0, testbench);
	reset = 1'b1;
	sbyte = 0;
	wr = 1'b0;
	#200;
	reset = 1'b0;
	#5000;
	@(posedge clk); #0;
	sbyte = 8'h41;
	wr = 1'b1;
	@(posedge clk); #0;
	sbyte = 8'h00;
	wr = 1'b0;
	
	#80000;
	$finish();
end

endmodule
