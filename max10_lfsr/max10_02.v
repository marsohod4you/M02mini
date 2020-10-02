
module max10_02(
	input wire CLK100MHZ,
	input wire KEY0,
	input wire KEY1,
	input wire SERIAL_RX,
	output wire SERIAL_TX,
	output wire [3:0]LED,
	inout [13:0]IO
	);

wire w_clk;
wire w_locked;

`ifdef ICARUS
assign w_clk = CLK100MHZ;
reg [3:0]lock_cnt = 0;
assign w_locked = (lock_cnt==4'b1111);
always @(posedge w_clk)
	if(!w_locked)
		lock_cnt<=lock_cnt+1;
`else
mypll my_pll_inst(
	.inclk0( CLK100MHZ ),
	.c0( ),
	.c1( w_clk ),
	.locked( w_locked )
	);
`endif

wire [7:0]w_out_byte;
wire enable;

lfsr lfsr_inst(
	.rst( ~KEY0 ),
	.clk( w_clk ),
	.enable( enable ),
	.out(),
	.out_lb( w_out_byte )
);

serial serial_inst(
	.clk12( w_clk ),
	.sbyte( w_out_byte ),
	.sbyte_rdy( enable ),
	.tx( SERIAL_TX ),
	.end_of_send( enable ),
	.ack()
	);

wire [7:0]w_leds;
display display_inst(
	.clk12( w_clk ),
	.sbyte( w_out_byte ),
	.leds( w_leds )
	);

assign LED = ~w_leds[3:0];

endmodule
	