module sync_fifo(clk, arst_n, rEn, wEn, rData, wData, empty, full);
	parameter DATA_WIDTH = 32;
	parameter DEPTH = 1024; // MUST BE POWER OF 2 !!!
	input clk;
	input arst_n;
	input rEn;
	input wEn;
	output[DATA_WIDTH-1:0] rData;
	input[DATA_WIDTH-1:0] wData;
	output reg empty;
	output reg full;
	
	reg full_nxt, empty_nxt;
	reg[$clog2(DEPTH)-1:0] rPtr, rPtr_nxt, wPtr, wPtr_nxt;
	reg[DATA_WIDTH-1:0] mem[0:DEPTH-1];

	assign rData = mem[rPtr];
	always @(posedge clk or negedge arst_n) begin
		if(!arst_n) begin
			full <= 0;
			empty <= 1;
			rPtr <= 0;
			wPtr <= 0;
		end
		else begin
			full <= full_nxt;
			empty <= empty_nxt;
			rPtr <= rPtr_nxt;
			wPtr <= wPtr_nxt;
			mem[wPtr] <= wEn ? wData : mem[wPtr];
		end
	end
	
	wire equ = (wPtr_nxt == rPtr_nxt);
	always @* begin
		rPtr_nxt = rPtr + rEn;
		wPtr_nxt = wPtr + wEn;
		case({wEn, rEn})
			2'b00: begin
				empty_nxt = empty;
				full_nxt = full;
			end
			2'b01: begin
				empty_nxt = equ;
				full_nxt = 0;
			end
			2'b10: begin
				empty_nxt = 0;
				full_nxt = equ;
			end
			2'b11: begin
				empty_nxt = 0;
				full_nxt = 0;
			end
		endcase
	end
endmodule
