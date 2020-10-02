
// A 16Kbyte RAM (4096x32) with one write port and one read port
module ram16k(
  input wire        clk,

  input  wire[15:0] a_addr,
  output wire[31:0] a_q,
  input  wire[31:0] a_d,
  input  wire       a_wr,

  input  wire[12:0] b_addr,
  output wire[15:0] b_q);

  //synthesis attribute ram_style of mem is block
  reg    [31:0]  mem[0:4095]; //pragma attribute mem ram_block TRUE
  initial begin
    $readmemh("./firmware/demo1.hex", mem);
  end

  always @ (posedge clk)
    if (a_wr)
      mem[a_addr[13:2]] <= a_d;  

  reg    [15:0]  a_addr_;
  always @ (posedge clk)
    a_addr_  <= a_addr;
  assign a_q = mem[a_addr_[13:2]];

  reg    [12:0]  raddr_reg;
  always @ (posedge clk)
    raddr_reg  <= b_addr;
  wire [31:0] insn32 = mem[raddr_reg[12:1]];
  assign b_q = raddr_reg[0] ? insn32[31:16] : insn32[15:0];
endmodule
