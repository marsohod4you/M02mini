`include "common.h"

module jtop(
  input wire CLK100MHZ,
  output wire [3:0]LED,
  input  wire KEY0,
  input  wire KEY1,
  input  wire FTDI_RX,
  output wire FTDI_TX
  );
localparam MHZ = 50;

wire sys_clk;
wire sys_reset;
wire locked;

`ifdef ICARUS
//in case of simulation
reg rclk = 1'b0;
always @(posedge CLK100MHZ)
	rclk <= ~rclk;
assign sys_clk = rclk;
reg [3:0]locked_cnt = 0;
assign locked = locked_cnt==4'hF;
always @(posedge sys_clk)
	if(~locked)
		locked_cnt <= locked_cnt + 4'd1;
`else
mypll _mypll(
	.inclk0( CLK100MHZ ),
	.c0( sys_clk ),
	.locked( locked )
	);

`endif
	
// ------------------------------------------------------------------------

wire uart0_valid, uart0_busy;
wire [7:0] uart0_data;
wire uart0_rd, uart0_wr,led_wr;
reg [31:0] baud = 32'd921600;
wire UART0_RX;
wire [31:0] dout;

reg io_wr_;
reg [15:0] mem_addr_;
reg [31:0] dout_;
reg [7:0]serial_send_byte;

always @(posedge sys_clk)
	if(uart0_wr)
		serial_send_byte <= dout_[7:0];

buart #(.CLKFREQ(MHZ * 1000000)) _uart0 (
	.clk(sys_clk),
	.resetq(sys_reset),
	.baud(baud),
	.rx(FTDI_RX),
	.tx(FTDI_TX),
	.rd(uart0_rd),
	.wr(uart0_wr),
	.valid(uart0_valid),
	.busy(uart0_busy),
	.tx_data(dout_[7:0]),
	.rx_data(uart0_data)
	);

wire [15:0] mem_addr;
wire [31:0] mem_din;
wire mem_wr;

wire [12:0] code_addr;
wire [15:0] insn;

wire io_wr;
  
j1 _j1 (
	.clk(sys_clk),
	.resetq(sys_reset),

	.io_wr(io_wr),
	.mem_addr(mem_addr),
	.mem_wr(mem_wr),
	.mem_din(mem_din),
	.dout(dout),
	.io_din({16'd0, uart0_data, 4'd0, uart0_valid, uart0_busy, KEY1, KEY0}),

	.code_addr(code_addr),
	.insn(insn)
	);

`ifdef ICARUS
//use Verilog memory array
ram16k ram(
	.clk(sys_clk),
	.a_addr(mem_addr),
	.a_q(mem_din),
	.a_wr(mem_wr),
	.a_d(dout),
	.b_addr(code_addr),
	.b_q(insn)
	);
assign sys_reset = locked;

`else

//use Altera megafunction

wire [15:0]ufm_data;
wire ufm_data_ready;
wire [12:0]ram_code_addr;

`ifdef MAX10_02
wire ufmr_resetn;
assign ufmr_resetn = locked /* KEY0 */;
wire ufm_done;
wire [12:0]ufm_addr;
assign ram_code_addr = ufm_done ? code_addr : ufm_addr;

ufmr ufmr_inst( 
	.clk( sys_clk ),	//50Mhz
	.resetn( ufmr_resetn ),
	.data( ufm_data ),
	.adr( ufm_addr ),
	.wr( ufm_data_ready ),
	.done( ufm_done )
	);

assign sys_reset = ufm_done;
`else
assign sys_reset = locked;
assign ram_code_addr = code_addr;
assign ufm_data = 16'h00;
assign ufm_data_ready = 1'b0;
`endif

jram _jram(
	.clock( sys_clk ),
	.address_a( mem_addr[13:2] ),
	.address_b( ram_code_addr ),
	.data_a( dout ),
	.data_b( ufm_data ),
	.wren_a( mem_wr ),
	.wren_b( ufm_data_ready ),
	.q_a( mem_din ),
	.q_b( insn )
	);
							
`endif

always @(posedge sys_clk)
	{io_wr_, mem_addr_, dout_} <= {io_wr, mem_addr, dout};

assign uart0_wr = io_wr_ & (mem_addr_ == 16'h0000);
assign uart0_rd = io_wr_ & (mem_addr_ == 16'h0002);
assign   led_wr = io_wr_ & (mem_addr_ == 16'h0004);
  
reg [31:0]L;
always @(posedge sys_clk)
	if( led_wr )
			L <= ~dout_;

assign LED = L[3:0];

endmodule
