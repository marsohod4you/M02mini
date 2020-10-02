

module top_M02_mini(
	input wire CLK100MHZ,
	input wire KEY0,
	input wire KEY1,
	input wire SERIAL_RX,
	output wire SERIAL_TX,
	output wire [3:0]LED,
	inout [13:0]IO
);

wire wc0;
wire wc1;
wire wlocked;
wire wpdone;
wire up_down; 
reg pstep;

wire scanclk; assign scanclk = wc0;
	
reg [7:0]cnt8;
always @( posedge scanclk )
	cnt8 <= cnt8 + 8'h01;

mypll mypll_ (
	.areset( ~KEY0 ),
	.inclk0(CLK100MHZ),
	.phasecounterselect( 3'b011 ),
	.phasestep( pstep ),
	.phaseupdown( up_down ),
	.scanclk(scanclk),
	.c0(wc0),
	.c1(wc1),
	.locked(wlocked),
	.phasedone( wpdone )
	);

wire [7:0]w_rx_byte;

wire w_byte_ready;
reg [1:0]byte_rdy;
always @( posedge wc0 )
	byte_rdy <= {byte_rdy[0],w_byte_ready};
	
serial receiver(
	.reset( ~wlocked ),
	.clk100( wc0 ),	//100MHz
	.rx( SERIAL_RX ),
	.sbyte( 8'h00 ),
	.send( 1'b0 ),
	.rx_byte( w_rx_byte ),
	.rbyte_ready( w_byte_ready ),
	.tx(),
	.busy(), 
	.rb()
	);

reg  [7:0]current_pll_phase = 0;
wire [7:0]signal; assign signal = w_rx_byte[7:0];
assign up_down = signal>current_pll_phase;

reg [3:0]state = 0;
always @( negedge scanclk )
begin
	case(state)
	0: begin 
			//wait recv byte
			if( byte_rdy ) state <= 1;
		end
	1: begin 
			//do we really need to change phase?
			if( current_pll_phase==signal ) state <= 0;
			else state <= 2;
		end	
	2: begin 
			//wait phase done
			if( ~wpdone ) state <= 3;
		end
	3: begin 
			state <= 4;
		end
	4: begin 
			state <= 1;
		end
	endcase
	
	if( pstep && (~wpdone) )
		if( up_down )
			current_pll_phase <= current_pll_phase + 6'h1;
		else
			current_pll_phase <= current_pll_phase - 6'h1;
			
	if( ~wpdone )
		pstep <= 1'b0;
	else
	if( state==2 )
		pstep <= 1'b1;

end

assign IO[0] =  wc1;
assign IO[1] = 1'b0;
assign IO[2] = ~wc1;
assign IO[13:3] = 0;

endmodule
