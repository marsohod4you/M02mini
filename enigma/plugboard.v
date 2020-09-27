module plugboard(
		input wire[4:0] char,
		input wire[25*5+4:0] tbl,
		output reg [4:0] out);
		
reg [4:0] outp [11:0];
always @*
begin
 outp[0]= (char==tbl[ 0*5+4: 0*5]) ? tbl[ 1*5+4: 1*5] : (char==tbl[ 1*5+4: 1*5]) ? tbl[ 0*5+4: 0*5] : char;
 outp[1]= (char==tbl[ 2*5+4: 2*5]) ? tbl[ 3*5+4: 3*5] : (char==tbl[ 3*5+4: 3*5]) ? tbl[ 2*5+4: 2*5] : outp[0];
 outp[2]= (char==tbl[ 4*5+4: 4*5]) ? tbl[ 5*5+4: 5*5] : (char==tbl[ 5*5+4: 5*5]) ? tbl[ 4*5+4: 4*5] : outp[1];
 outp[3]= (char==tbl[ 6*5+4: 6*5]) ? tbl[ 7*5+4: 7*5] : (char==tbl[ 7*5+4: 7*5]) ? tbl[ 6*5+4: 6*5] : outp[2];
 outp[4]= (char==tbl[ 8*5+4: 8*5]) ? tbl[ 9*5+4: 9*5] : (char==tbl[ 9*5+4: 9*5]) ? tbl[ 8*5+4: 8*5] : outp[3];
 outp[5]= (char==tbl[10*5+4:10*5]) ? tbl[11*5+4:11*5] : (char==tbl[11*5+4:11*5]) ? tbl[10*5+4:10*5] : outp[4];
 outp[6]= (char==tbl[12*5+4:12*5]) ? tbl[13*5+4:13*5] : (char==tbl[13*5+4:13*5]) ? tbl[12*5+4:12*5] : outp[5];
 outp[7]= (char==tbl[14*5+4:14*5]) ? tbl[15*5+4:15*5] : (char==tbl[15*5+4:15*5]) ? tbl[14*5+4:14*5] : outp[6];
 outp[8]= (char==tbl[16*5+4:16*5]) ? tbl[17*5+4:17*5] : (char==tbl[17*5+4:17*5]) ? tbl[16*5+4:16*5] : outp[7];
 outp[9]= (char==tbl[18*5+4:18*5]) ? tbl[19*5+4:19*5] : (char==tbl[19*5+4:19*5]) ? tbl[18*5+4:18*5] : outp[8];
 outp[10]=(char==tbl[20*5+4:20*5]) ? tbl[21*5+4:21*5] : (char==tbl[21*5+4:21*5]) ? tbl[20*5+4:20*5] : outp[9];
 outp[11]=(char==tbl[22*5+4:22*5]) ? tbl[23*5+4:23*5] : (char==tbl[23*5+4:23*5]) ? tbl[22*5+4:22*5] : outp[10];
 out= 	  (char==tbl[24*5+4:24*5]) ? tbl[25*5+4:25*5] : (char==tbl[25*5+4:25*5]) ? tbl[24*5+4:24*5] : outp[11];
end

endmodule


