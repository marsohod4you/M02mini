module tb;
reg  clk;
reg  rst;
  
initial
begin
	clk <= 1'b0;
	while (1)
	begin
	  #5 clk <= ~clk;
	end
end

wire w_tx,w_ack;
wire [31:0]w_random;

lfsr u_lfsr(
	.rst( rst ),
	.clk( clk ),
	.enable( w_eos ),
	.out( w_random )
);

serial u_serial(
	.clk12( clk ),
	.sbyte( w_random[7:0] ),
	.sbyte_rdy( w_eos ),
	.tx( w_tx ),
	.end_of_send( w_eos ),
	.ack( w_ack )
	);
	
initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);
	rst <= 1'b1;
	#50 rst <= 1'b0;
	#100;
	#10000;
	$finish;
end

endmodule
