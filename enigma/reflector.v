
module reflector(
		input wire [25:0]in,
		output reg [25:0]out
	);
parameter TRANSLATION = "BDFHJLCPRTXVZNYEIWGAKMUSQO";

always @*
begin
	out[ ((TRANSLATION>>(25*8) )&8'hFF) - 8'h41 ]= in[0 ];
	out[ ((TRANSLATION>>(24*8) )&8'hFF) - 8'h41 ]= in[1 ];
	out[ ((TRANSLATION>>(23*8) )&8'hFF) - 8'h41 ]= in[2 ];
	out[ ((TRANSLATION>>(22*8) )&8'hFF) - 8'h41 ]= in[3 ];
	out[ ((TRANSLATION>>(21*8) )&8'hFF) - 8'h41 ]= in[4 ];
	out[ ((TRANSLATION>>(20*8) )&8'hFF) - 8'h41 ]= in[5 ];
	out[ ((TRANSLATION>>(19*8) )&8'hFF) - 8'h41 ]= in[6 ];
	out[ ((TRANSLATION>>(18*8) )&8'hFF) - 8'h41 ]= in[7 ];
	out[ ((TRANSLATION>>(17*8) )&8'hFF) - 8'h41 ]= in[8 ];
	out[ ((TRANSLATION>>(16*8) )&8'hFF) - 8'h41 ]= in[9 ];
	out[ ((TRANSLATION>>(15*8) )&8'hFF) - 8'h41 ]= in[10];
	out[ ((TRANSLATION>>(14*8) )&8'hFF) - 8'h41 ]= in[11];
	out[ ((TRANSLATION>>(13*8) )&8'hFF) - 8'h41 ]= in[12];
	out[ ((TRANSLATION>>(12*8) )&8'hFF) - 8'h41 ]= in[13];
	out[ ((TRANSLATION>>(11*8) )&8'hFF) - 8'h41 ]= in[14];
	out[ ((TRANSLATION>>(10*8) )&8'hFF) - 8'h41 ]= in[15];
	out[ ((TRANSLATION>>( 9*8) )&8'hFF) - 8'h41 ]= in[16];
	out[ ((TRANSLATION>>( 8*8) )&8'hFF) - 8'h41 ]= in[17];
	out[ ((TRANSLATION>>( 7*8) )&8'hFF) - 8'h41 ]= in[18];
	out[ ((TRANSLATION>>( 6*8) )&8'hFF) - 8'h41 ]= in[19];
	out[ ((TRANSLATION>>( 5*8) )&8'hFF) - 8'h41 ]= in[20];
	out[ ((TRANSLATION>>( 4*8) )&8'hFF) - 8'h41 ]= in[21];
	out[ ((TRANSLATION>>( 3*8) )&8'hFF) - 8'h41 ]= in[22];
	out[ ((TRANSLATION>>( 2*8) )&8'hFF) - 8'h41 ]= in[23];
	out[ ((TRANSLATION>>( 1*8) )&8'hFF) - 8'h41 ]= in[24];
	out[ ((TRANSLATION>>( 0*8) )&8'hFF) - 8'h41 ]= in[25];
end

endmodule
