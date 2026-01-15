`timescale 1ns / 1ps
`define test_number 1000000
`define ASYNC
`define SEED 1
`define clk_random ($urandom%30+1)
`define random_25 (($urandom%4)==3)
`define random_50 ($urandom%2)

module fifo_tb();

integer periodA = 1, periodB = 0;

reg clka = 0, clkb = 0;
integer i, j;
wire empty, full;
wire[31:0] dout;
reg rd_en, wr_en, aresetn;
reg[31:0] din;

`ifdef ASYNC
async_fifo dut(
	.rst(~arst_n),
	.rClk(clkb),
	.rEn(rd_en),
	.rData(dout),
	.empty(empty),
	.wClk(clka),
	.wEn(wr_en),
	.wData(din),
	.full(full)
);
`else
sync_fifo dut(
	.clk(clka),
	.arst_n(arst_n),
	.rEn(rd_en),
	.wEn(wr_en),
	.rData(dout),
	.wData(din),
	.empty(empty),
	.full(full)
);
`endif

reg[10:0] length = 0;
reg[9:0] rPtr_tb = 0;
reg[31:0] mem[0:1023];

reg[31:0] dout2;
always @(posedge clkb or posedge clka) dout2 <= #1 mem[rPtr_tb];

reg flagA = 0;
initial begin
	din = $urandom(`SEED);
	fork
		begin
			periodA = `clk_random;
			forever clka = #periodA ~clka;
		end

		begin
			`ifdef ASYNC
				periodB = `clk_random;
				while(periodB == periodA) periodB = #1 `clk_random;
			`else
				periodB = periodA;
			`endif
				forever clkb = #periodB ~clkb;
		end

		begin
			wr_en = 0;
			rd_en = 0;
			rst = 1;
			#500;
			rst = 0;
			#400;
			@(negedge clkb);
			forever begin
				if(dout2!==dout) begin
					$display("error: data is wrong");
					$finish;
				end
				@(negedge clkb);
			end
		end

		begin
			#1000;
			@(negedge clka);
			#(periodA-1);
			for(i=0; i<`test_number; i=i+1) begin
				wr_en = full ? 0 : `random_25;
				din = $random;
				if(wr_en) mem[(rPtr_tb + length)%1024] = din;
				length = length + wr_en;
				#(periodA*2);
			end
			for(i=0; i<`test_number; i=i+1) begin
				wr_en = full ? 0 : `random_50;
				din = $random;
				if(wr_en) mem[(rPtr_tb + length)%1024] = din;
				length = length + wr_en;
				#(periodA*2);
			end
			for(i=0; i<`test_number; i=i+1) begin
				wr_en = full ? 0 : `random_50;
				din = $random;
				if(wr_en) mem[(rPtr_tb + length)%1024] = din;
				length = length + wr_en;
				#(periodA*2);
			end
			wr_en = 0;
			flagA = 1;
		end

		begin
			#1000;
			@(negedge clkb);
			#(periodB-1);
			for(j=0; j<`test_number; j=j+1) begin
				rd_en = empty ? 0 : `random_50;
				rPtr_tb = rPtr_tb + rd_en;
				length = length - rd_en;
				#(periodB*2);
			end
			for(j=0; j<`test_number; j=j+1) begin
				rd_en = empty ? 0 : `random_50;
				rPtr_tb = rPtr_tb + rd_en;
				length = length - rd_en;
				#(periodB*2);
			end
			for(j=0; j<`test_number; j=j+1) begin
				rd_en = empty ? 0 : `random_25;
				rPtr_tb = rPtr_tb + rd_en;
				length = length - rd_en;
				#(periodB*2);
			end

			wait(flagA);
			for(j=0; j<1035; j=j+1) begin
				rd_en = empty ? 0 : 1;
				rPtr_tb = rPtr_tb + rd_en;
				length = length - rd_en;
				#(periodB*2);
			end
			rd_en = 0;
			if(length !== 0) begin
				$display("error: fifo cannot have any data left");
				$finish;
			end
			$display("Successful!!!");
			$finish;
		end
	join
end

endmodule
