
module serial(
	input wire clk12,
	input wire [7:0]sbyte,
	input wire sbyte_rdy,
	output wire tx,
	output wire end_of_send,
	output wire ack
	);

reg [9:0]sreg;
assign tx = sreg[0];
reg [3:0]cnt = 0;
wire busy; assign busy = (cnt<11);
assign ack = sbyte_rdy & ~busy;

always @(posedge clk12)
begin
	if(sbyte_rdy & ~busy)
		sreg <= { 2'b11, sbyte, 1'b0 }; //load
	else
		sreg <= {2'b11, sreg[9:1] }; //shift

	if(sbyte_rdy & ~busy)
		cnt <= 0;
	else
	if(busy)
		cnt <= cnt + 1'b1;
end

reg prev_busy;
always @(posedge clk12)
	prev_busy <= busy;

assign end_of_send = busy==1'b0 && prev_busy==1'b1;

endmodule
