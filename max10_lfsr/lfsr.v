
module lfsr(
	input wire rst,
	input wire clk,
	input wire enable,
	output wire [31:0]out,
	output wire [7:0]out_lb
);

reg [31:0]shift_reg;
assign out = shift_reg;
assign out_lb = shift_reg[7:0];
wire next_bit;
assign next_bit = 
	shift_reg[31] ^
	shift_reg[30] ^
	shift_reg[29] ^
	shift_reg[27] ^
	shift_reg[25] ^
	shift_reg[ 0];

always @(posedge clk or posedge rst)
	if(rst)
		shift_reg <= 32'h00000001;
	else
	if(enable)
		shift_reg <= { next_bit, shift_reg[31:1] };

endmodule
