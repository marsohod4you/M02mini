/////////////////////////////////////////////////////////////////////////

module  ufmr(
	input				clk,				// 50mhz
						resetn,
	output [15:0]  data,
	output [10:0]  adr,
	output			wr,
						done,
						test);

reg [18:0] cnt;
always @(posedge clk or negedge resetn )
	if( ~resetn )
		cnt <= 0;
	else
		cnt <= cnt[18] ? cnt : cnt + 1;

wire drclk = cnt[1];				// drclk = 12.5mhz
wire drdout;
wire drshft = ~(cnt[6]&cnt[5]&cnt[4]&cnt[3]&cnt[2]);
wire arshft = ~(cnt[16]|cnt[17]);
	altera_onchip_flash_block # (	
		.DEVICE_FAMILY ("MAX 10"),
		.PART_NAME ("10M02DCV36C8G"),
		.IS_DUAL_BOOT ("False"),
		.IS_ERAM_SKIP ("True"),
		.IS_COMPRESSED_IMAGE ("False"),
		.INIT_FILENAME ("firmware/demo1.mif"),
		.MIN_VALID_ADDR (0),
		.MAX_VALID_ADDR (3071),
		.MIN_UFM_VALID_ADDR (0),
		.MAX_UFM_VALID_ADDR (3071),
		.ADDR_RANGE1_END_ADDR (3071),
		.ADDR_RANGE1_OFFSET (512),
		.ADDR_RANGE2_OFFSET (0),
		// simulation only start
		.DEVICE_ID ("02"),
		.INIT_FILENAME_SIM ("")
		// simulation only end	
	) altera_onchip_flash_block_ (
		.xe_ye(1'b1),						
		.se(1'b1),							
		.arclk(cnt[6]),				// arclk = 12.5/32 mhz
		.arshft(arshft),
		.ardin({{22{1'b1}},1'b0}),
		.drclk(drclk),					
		.drshft(drshft),
		.drdin(1'b0),
		.nprogram(1'b1),				
		.nerase(1'b1),					
		.nosc_ena(1'b0),
		.par_en(1'b1),					
		.drdout(drdout),
		.busy(),								
		.se_pass(),					
		.sp_pass(),					
		.osc()								
	);	
	
reg [14:0] shift; always @(posedge drclk)  shift <= {shift[13:0],drdout};
assign data		= {shift[14:0],drdout};
assign adr		= {cnt[16:7],~cnt[6]};
assign wr		= cnt[5]&cnt[4]&cnt[3]&cnt[2]&(!cnt[1])&(!cnt[0])&cnt[17];
assign done		= cnt[18];
assign test		= cnt[17];
endmodule 