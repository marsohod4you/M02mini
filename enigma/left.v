
module left(
		input wire [5:0]shift,
		input wire [25:0]in,
		output reg [25:0]out
	);

reg [5:0] five;
always @*
	case(in)
		26'h0000001: five=6'd0;
		26'h0000002: five=6'd1;
		26'h0000004: five=6'd2;
		26'h0000008: five=6'd3;
		26'h0000010: five=6'd4;
		26'h0000020: five=6'd5;
		26'h0000040: five=6'd6;
		26'h0000080: five=6'd7;
		26'h0000100: five=6'd8;
		26'h0000200: five=6'd9;
		26'h0000400: five=6'd10;
		26'h0000800: five=6'd11;
		26'h0001000: five=6'd12;
		26'h0002000: five=6'd13;
		26'h0004000: five=6'd14;
		26'h0008000: five=6'd15;
		26'h0010000: five=6'd16;
		26'h0020000: five=6'd17;
		26'h0040000: five=6'd18;
		26'h0080000: five=6'd19;
		26'h0100000: five=6'd20;
		26'h0200000: five=6'd21;
		26'h0400000: five=6'd22;
		26'h0800000: five=6'd23;
		26'h1000000: five=6'd24;
		26'h2000000: five=6'd25;
	default:
		five=6'd0;
	endcase

wire [5:0] five2 = ((five+shift)>6'd25) ? five-6'd26+shift : five+shift ;
always @* 
	case(five2)
		6'd0:	out=		26'h0000001;
		6'd1:	out=		26'h0000002;
		6'd2:out=		26'h0000004;
		6'd3:out=		26'h0000008;
		6'd4:out=		26'h0000010;
		6'd5:out=		26'h0000020;
		6'd6:out=		26'h0000040;
		6'd7:out=		26'h0000080;
		6'd8:out=		26'h0000100;
		6'd9:out=		26'h0000200;
		6'd10:out=		26'h0000400;
		6'd11:out=		26'h0000800;
		6'd12:out=		26'h0001000;
		6'd13:out=		26'h0002000;
		6'd14:out=		26'h0004000;
		6'd15:out=		26'h0008000;
		6'd16:out=		26'h0010000;
		6'd17:out=		26'h0020000;
		6'd18:out=		26'h0040000;
		6'd19:out=		26'h0080000;
		6'd20:out=		26'h0100000;
		6'd21:out=		26'h0200000;
		6'd22:out=		26'h0400000;
		6'd23:out=		26'h0800000;
		6'd24:out=		26'h1000000;
		6'd25:out=		26'h2000000;
	default:
		out=26'd1;
	endcase
endmodule



