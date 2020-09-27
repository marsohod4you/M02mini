  
module serial(
	input wire reset,
	input wire clk100,	//100MHz
	input wire rx,
	output reg [7:0]rx_byte,
	output reg rbyte_ready
	);

parameter RCONST = 868+16; //115200bps

reg [1:0]shr;
always @(posedge clk100)
	shr <= {shr[0],rx};
wire rxf; assign rxf = shr[1];
wire rx_edge; assign rx_edge = shr[0]!=shr[1];

reg [15:0]cnt;
wire bit_strobe; assign bit_strobe = (cnt==RCONST || rx_edge);

reg [3:0]num_bits;
reg [7:0]shift_reg;

always @(posedge clk100 or posedge reset)
begin
	if(reset)
		cnt <= 0;
	else
	begin
		if( bit_strobe )
			cnt <= 0;
		else
		if(num_bits<9)
			cnt <= cnt + 1'b1;
	end
end

always @(posedge clk100 or posedge reset)
begin
	if(reset)
	begin
		num_bits <= 0;
		shift_reg <= 0;
	end
	else
	begin
		if(num_bits==9 && shr[0]==1'b0 )
			num_bits <= 0;
		else
		if( bit_strobe )
			num_bits <= num_bits + 1'b1;
				
		
		if( cnt == RCONST/2 )
			shift_reg <= {rxf,shift_reg[7:1]};
	end
end

reg [2:0]flag;
always @(posedge clk100 or posedge reset)
	if(reset)
		flag <= 3'b000;
	else
		flag <= {flag[1:0],(num_bits==9)};

always @*
	rbyte_ready = (flag==3'b011);

always @(posedge clk100 or posedge reset)
	if(reset)
		rx_byte <= 0;
	else
	if(flag==3'b001)
		rx_byte <= shift_reg[7:0];

	
endmodule

module tx_serial(
	input wire reset,
	input wire clk100,
	input wire [7:0]sbyte,
	input wire send,
	output reg tx,
	output reg busy 
);

parameter RCONST = 868;

reg [8:0]send_reg;
reg [3:0]send_num;
reg [31:0]send_cnt;

wire send_time; assign send_time = (send_cnt == RCONST);

always @(posedge clk100 or posedge reset)
begin
	if(reset)
	begin
		send_reg <= 0;
		send_num <= 0;
		send_cnt <= 0;
	end
	else
	begin
		if( send || send_time )
			send_cnt <= 0;
		else
			send_cnt <= send_cnt + 1'b1;
        
		if(send)
		begin
			send_reg <= {sbyte,1'b0};
			send_num <= 0;
		end
		else
		if(send_time && send_num!=10)
		begin
			send_reg <= {1'b1,send_reg[8:1]};
			send_num <= send_num + 1'b1;
		end
	end
end

always @*
begin
    busy = send_num!=10;
    tx = send_reg[0];
end
    
endmodule

