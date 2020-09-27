
function [4:0]pos2char( input [25:0]pos );
begin
	case(pos)
		26'h0000001: pos2char = 5'd0;
		26'h0000002: pos2char = 5'd1;
		26'h0000004: pos2char = 5'd2;
		26'h0000008: pos2char = 5'd3;
		26'h0000010: pos2char = 5'd4;
		26'h0000020: pos2char = 5'd5;
		26'h0000040: pos2char = 5'd6;
		26'h0000080: pos2char = 5'd7;
		26'h0000100: pos2char = 5'd8;
		26'h0000200: pos2char = 5'd9;
		26'h0000400: pos2char = 5'd10;
		26'h0000800: pos2char = 5'd11;
		26'h0001000: pos2char = 5'd12;
		26'h0002000: pos2char = 5'd13;
		26'h0004000: pos2char = 5'd14;
		26'h0008000: pos2char = 5'd15;
		26'h0010000: pos2char = 5'd16;
		26'h0020000: pos2char = 5'd17;
		26'h0040000: pos2char = 5'd18;
		26'h0080000: pos2char = 5'd19;
		26'h0100000: pos2char = 5'd20;
		26'h0200000: pos2char = 5'd21;
		26'h0400000: pos2char = 5'd22;
		26'h0800000: pos2char = 5'd23;
		26'h1000000: pos2char = 5'd24;
		26'h2000000: pos2char = 5'd25;
	default:
		pos2char = 5'b11111;
	endcase
end
endfunction

function [7:0]pos2letter( input [25:0]pos );
begin
	case(pos)
		26'h0000001: pos2letter = "A";
		26'h0000002: pos2letter = "B";
		26'h0000004: pos2letter = "C";
		26'h0000008: pos2letter = "D";
		26'h0000010: pos2letter = "E";
		26'h0000020: pos2letter = "F";
		26'h0000040: pos2letter = "G";
		26'h0000080: pos2letter = "H";
		26'h0000100: pos2letter = "I";
		26'h0000200: pos2letter = "J";
		26'h0000400: pos2letter = "K";
		26'h0000800: pos2letter = "L";
		26'h0001000: pos2letter = "M";
		26'h0002000: pos2letter = "N";
		26'h0004000: pos2letter = "O";
		26'h0008000: pos2letter = "P";
		26'h0010000: pos2letter = "Q";
		26'h0020000: pos2letter = "R";
		26'h0040000: pos2letter = "S";
		26'h0080000: pos2letter = "T";
		26'h0100000: pos2letter = "U";
		26'h0200000: pos2letter = "V";
		26'h0400000: pos2letter = "W";
		26'h0800000: pos2letter = "X";
		26'h1000000: pos2letter = "Y";
		26'h2000000: pos2letter = "Z";
	default:
		pos2letter = "?";
	endcase
end
endfunction

