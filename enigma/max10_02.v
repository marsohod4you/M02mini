
module max10_02(
	input wire CLK100MHZ,
	input wire KEY0,
	input wire KEY1,
	input wire SERIAL_RX,
	output wire SERIAL_TX,
	output wire [3:0]LED,
	inout [13:0]IO
	);

wire w_clk;
wire w_locked;

`ifdef ICARUS
assign w_clk = CLK100MHZ;
reg [3:0]lock_cnt = 0;
assign w_locked = (lock_cnt==4'b1111);
always @(posedge w_clk)
	if(!w_locked)
		lock_cnt<=lock_cnt+1;
`else
my_pll my_pll_inst(
	.inclk0( CLK100MHZ ),
	.c0( w_clk ),
	.locked( w_locked )
	);
`endif

wire [7:0]rx_byte;
wire w_rbyte_ready;
serial #( .RCONST(108+8) ) my_serial_inst(
	.reset( ~w_locked ),
	.clk100( w_clk ),
	.rx( SERIAL_RX ),
	.rx_byte( rx_byte ),
	.rbyte_ready( w_rbyte_ready )
	);

//fix received serial byte into register
reg [7:0]r_rx_byte;
wire rx_byte_ok; assign rx_byte_ok = (rx_byte>="A") && (rx_byte<="Z");
wire rx_byte_init_done; assign rx_byte_init_done = (rx_byte==8'h0D); //press Enter
always @( posedge w_clk )
	if( w_rbyte_ready && rx_byte_ok )
		r_rx_byte <= rx_byte;

//registered delay of w_rbyte_ready impulse 
reg r_rbyte_ready = 0;
always @( posedge w_clk )
	if( rx_byte_ok )
		r_rbyte_ready <= w_rbyte_ready ;

reg r_rbyte_ready2 = 0;
always @(posedge w_clk)
	r_rbyte_ready2 <= r_rbyte_ready;
 
wire rset = r_rbyte_ready2 & (state==6);

//catch board button press
reg [1:0]key = 0;
always @( posedge w_clk )
	key <= { key[0], KEY0 };
wire w_init; assign w_init = key==2'b01;

integer i;
reg [7:0]state = 0;
reg [4:0]password[31:0];
always @(posedge w_clk)
	if( w_init)
	begin
		for(i=0; i<32; i=i+1)
			password[i] <= 0;
	end
	else
	if( r_rbyte_ready && (state<32) )
		password[state] <= (r_rx_byte-"A");

//pairs of chars for plug board
wire [26*5-1:0]plug_table = {
		password[6],password[7],
		password[8],password[9],
		password[10],password[11],
		password[12],password[13],
		password[14],password[15],
		password[16],password[17],
		password[18],password[19],
		password[20],password[21],
		password[22],password[23],
		password[24],password[25],
		password[26],password[27],
		password[28],password[29],
		password[30],password[31]
	};

always @(posedge w_clk)
	if( w_init)
		state <= 0 ;
	else
	if(rx_byte_init_done)
		state<=32;
	else
	if(r_rbyte_ready && (state<32) )
		state <= state+1;

wire encode = (state==32);
wire [7:0]w_encoded_byte;
wire w_encoded_byte_ready;
enigma enigma_inst(
	.clk( w_clk ),
	.rset( rset ),
	.offset_init( { password[0],password[1],password[2] } ),
	.ringst_init( { password[3],password[4],password[5] } ),
	.plug_tbl( plug_table ),
	.in_char( r_rx_byte ),
	.in_char_write( r_rbyte_ready & encode ),
	.out_char( w_encoded_byte ),
	.out_char_ready( w_encoded_byte_ready )
);

reg [7:0]delay;
always @(posedge w_clk)
	delay <= { delay[6:0],w_encoded_byte_ready};
	
//serial send
wire send_imp = w_init | (w_rbyte_ready && (state<32)) | delay[7];
wire [7:0]send_byte;
assign send_byte =   w_init ? ">" : 
							(w_rbyte_ready && (state<32)) ? (rx_byte_init_done ? ":" : rx_byte) : w_encoded_byte;
tx_serial #( .RCONST(108) ) my_tx_serial_inst(
	.reset( ~w_locked ),
	.clk100( w_clk ),
	.sbyte( send_byte ),
	.send( send_imp ),
	.tx( SERIAL_TX ),
	.busy() 
	);

assign LED = ~r_rx_byte[3:0];

endmodule
	