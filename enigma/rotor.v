
module rotor(
		input wire clk,
		input wire set,  //pulse used for offset/rengstellung initial settings 
		input wire step0, //main pulse used for rotating
		input wire step, //pulse used for rotating
		input wire [4:0]offset, //initial settings
		input wire [4:0]ringstellung, //initial settings
		input wire [25:0]f_in,	//forward translation
		output wire[25:0]f_out,
		input wire [25:0]b_in,	//backward translation
		output wire[25:0]b_out,
		output wire advance
	);
parameter TRANSLATION = "BDFHJLCPRTXVZNYEIWGAKMUSQO";
parameter NOTCH = "A";
`include "lib.v"

reg [4:0]r_offset = 0;
reg [4:0]r_ringstellung = 0;

always @(posedge clk)
	if( set )
		r_ringstellung <= ringstellung;

reg [4:0]next_offset;
always @*
	if( r_offset==25)
		next_offset = 0;
	else
		next_offset = r_offset+1;		

always @(posedge clk)
	if( set )
		r_offset <= offset;
	else
	if( step | advance )
		r_offset <= next_offset;
		
reg [5:0]pos;
always @*
begin
	pos = r_offset-r_ringstellung;
	if( pos[5] )
		pos = pos+26;
end

assign advance = (r_offset==(NOTCH-8'h41))&step0;

`ifdef USE_SHIFT
reg  [25:0]f_rotated;
always @*
		f_rotated = (f_in<<pos)|(f_in>>(26-pos));
`else
wire  [25:0]f_rotated;
left left1(.shift(pos),.in(f_in),.out(f_rotated));
`endif

`ifdef USE_SHIFT
reg [25:0]b_rotated;
always @*
	b_rotated = (b_in<<pos)|(b_in>>(26-pos));
`else
wire [25:0]b_rotated;
left left3(.shift(pos),.in(b_in),.out(b_rotated));
`endif

wire [25:0]w_f_out;
wire [25:0]w_b_out;
ring  #( .TRANSLATION(TRANSLATION) ) ri(
		.f_in( f_rotated ),
		.f_out( w_f_out ),
		.b_in( b_rotated ),
		.b_out( w_b_out )
	);

`ifdef USE_SHIFT
reg [25:0]f_rotated_out;
always @*
	f_rotated_out = (w_f_out<<(26-pos))|(w_f_out>>pos);
`else
wire [25:0]f_rotated_out;
left left2(.shift(6'd26-pos),.in(w_f_out),.out(f_rotated_out));
`endif

`ifdef USE_SHIFT
reg [25:0]b_rotated_out;
always @*
	b_rotated_out = (w_b_out<<(26-pos))|(w_b_out>>pos);
`else
wire [25:0]b_rotated_out;
left left4(.shift(6'd26-pos),.in(w_b_out),.out(b_rotated_out));
`endif
	
wire [7:0]chr_f_in;  assign chr_f_in  = pos2letter(f_in);
wire [7:0]chr_f_out; assign chr_f_out = pos2letter(f_rotated_out);

wire [7:0]chr_b_in;  assign chr_b_in = pos2letter(b_in);
wire [7:0]chr_b_out; assign chr_b_out = pos2letter(b_rotated_out);

assign f_out = f_rotated_out;
assign b_out = b_rotated_out;

endmodule

