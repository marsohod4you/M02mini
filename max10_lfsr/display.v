
module display(
	input wire clk12,
	input wire [7:0]sbyte,
	output reg [7:0]leds
	);

reg [31:0]cnt=0;
always @(posedge clk12)
begin
	if(cnt==2000000)
		cnt<=0;
	else
		cnt<=cnt+1;

	if(cnt==2000000)
		leds<=sbyte;
end

endmodule
