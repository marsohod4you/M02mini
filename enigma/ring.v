
module ring(
		input wire [25:0]f_in,
		output reg [25:0]f_out,
		input wire [25:0]b_in,
		output reg [25:0]b_out
	);
parameter TRANSLATION = "BDFHJLCPRTXVZNYEIWGAKMUSQO";

always @*
begin
	f_out[ ((TRANSLATION>>(25*8) )&8'hFF) - 8'h41 ]= f_in[0 ];
	f_out[ ((TRANSLATION>>(24*8) )&8'hFF) - 8'h41 ]= f_in[1 ];
	f_out[ ((TRANSLATION>>(23*8) )&8'hFF) - 8'h41 ]= f_in[2 ];
	f_out[ ((TRANSLATION>>(22*8) )&8'hFF) - 8'h41 ]= f_in[3 ];
	f_out[ ((TRANSLATION>>(21*8) )&8'hFF) - 8'h41 ]= f_in[4 ];
	f_out[ ((TRANSLATION>>(20*8) )&8'hFF) - 8'h41 ]= f_in[5 ];
	f_out[ ((TRANSLATION>>(19*8) )&8'hFF) - 8'h41 ]= f_in[6 ];
	f_out[ ((TRANSLATION>>(18*8) )&8'hFF) - 8'h41 ]= f_in[7 ];
	f_out[ ((TRANSLATION>>(17*8) )&8'hFF) - 8'h41 ]= f_in[8 ];
	f_out[ ((TRANSLATION>>(16*8) )&8'hFF) - 8'h41 ]= f_in[9 ];
	f_out[ ((TRANSLATION>>(15*8) )&8'hFF) - 8'h41 ]= f_in[10];
	f_out[ ((TRANSLATION>>(14*8) )&8'hFF) - 8'h41 ]= f_in[11];
	f_out[ ((TRANSLATION>>(13*8) )&8'hFF) - 8'h41 ]= f_in[12];
	f_out[ ((TRANSLATION>>(12*8) )&8'hFF) - 8'h41 ]= f_in[13];
	f_out[ ((TRANSLATION>>(11*8) )&8'hFF) - 8'h41 ]= f_in[14];
	f_out[ ((TRANSLATION>>(10*8) )&8'hFF) - 8'h41 ]= f_in[15];
	f_out[ ((TRANSLATION>>( 9*8) )&8'hFF) - 8'h41 ]= f_in[16];
	f_out[ ((TRANSLATION>>( 8*8) )&8'hFF) - 8'h41 ]= f_in[17];
	f_out[ ((TRANSLATION>>( 7*8) )&8'hFF) - 8'h41 ]= f_in[18];
	f_out[ ((TRANSLATION>>( 6*8) )&8'hFF) - 8'h41 ]= f_in[19];
	f_out[ ((TRANSLATION>>( 5*8) )&8'hFF) - 8'h41 ]= f_in[20];
	f_out[ ((TRANSLATION>>( 4*8) )&8'hFF) - 8'h41 ]= f_in[21];
	f_out[ ((TRANSLATION>>( 3*8) )&8'hFF) - 8'h41 ]= f_in[22];
	f_out[ ((TRANSLATION>>( 2*8) )&8'hFF) - 8'h41 ]= f_in[23];
	f_out[ ((TRANSLATION>>( 1*8) )&8'hFF) - 8'h41 ]= f_in[24];
	f_out[ ((TRANSLATION>>( 0*8) )&8'hFF) - 8'h41 ]= f_in[25];
end

always @*
begin
	b_out[ 0  ]= b_in[ ((TRANSLATION>>(25*8) )&8'hFF) - 8'h41 ];
	b_out[ 1  ]= b_in[ ((TRANSLATION>>(24*8) )&8'hFF) - 8'h41 ];
	b_out[ 2  ]= b_in[ ((TRANSLATION>>(23*8) )&8'hFF) - 8'h41 ];
	b_out[ 3  ]= b_in[ ((TRANSLATION>>(22*8) )&8'hFF) - 8'h41 ];
	b_out[ 4  ]= b_in[ ((TRANSLATION>>(21*8) )&8'hFF) - 8'h41 ];
	b_out[ 5  ]= b_in[ ((TRANSLATION>>(20*8) )&8'hFF) - 8'h41 ];
	b_out[ 6  ]= b_in[ ((TRANSLATION>>(19*8) )&8'hFF) - 8'h41 ];
	b_out[ 7  ]= b_in[ ((TRANSLATION>>(18*8) )&8'hFF) - 8'h41 ];
	b_out[ 8  ]= b_in[ ((TRANSLATION>>(17*8) )&8'hFF) - 8'h41 ];
	b_out[ 9  ]= b_in[ ((TRANSLATION>>(16*8) )&8'hFF) - 8'h41 ];
	b_out[ 10 ]= b_in[ ((TRANSLATION>>(15*8) )&8'hFF) - 8'h41 ];
	b_out[ 11 ]= b_in[ ((TRANSLATION>>(14*8) )&8'hFF) - 8'h41 ];
	b_out[ 12 ]= b_in[ ((TRANSLATION>>(13*8) )&8'hFF) - 8'h41 ];
	b_out[ 13 ]= b_in[ ((TRANSLATION>>(12*8) )&8'hFF) - 8'h41 ];
	b_out[ 14 ]= b_in[ ((TRANSLATION>>(11*8) )&8'hFF) - 8'h41 ];
	b_out[ 15 ]= b_in[ ((TRANSLATION>>(10*8) )&8'hFF) - 8'h41 ];
	b_out[ 16 ]= b_in[ ((TRANSLATION>>( 9*8) )&8'hFF) - 8'h41 ];
	b_out[ 17 ]= b_in[ ((TRANSLATION>>( 8*8) )&8'hFF) - 8'h41 ];
	b_out[ 18 ]= b_in[ ((TRANSLATION>>( 7*8) )&8'hFF) - 8'h41 ];
	b_out[ 19 ]= b_in[ ((TRANSLATION>>( 6*8) )&8'hFF) - 8'h41 ];
	b_out[ 20 ]= b_in[ ((TRANSLATION>>( 5*8) )&8'hFF) - 8'h41 ];
	b_out[ 21 ]= b_in[ ((TRANSLATION>>( 4*8) )&8'hFF) - 8'h41 ];
	b_out[ 22 ]= b_in[ ((TRANSLATION>>( 3*8) )&8'hFF) - 8'h41 ];
	b_out[ 23 ]= b_in[ ((TRANSLATION>>( 2*8) )&8'hFF) - 8'h41 ];
	b_out[ 24 ]= b_in[ ((TRANSLATION>>( 1*8) )&8'hFF) - 8'h41 ];
	b_out[ 25 ]= b_in[ ((TRANSLATION>>( 0*8) )&8'hFF) - 8'h41 ];
end

endmodule


