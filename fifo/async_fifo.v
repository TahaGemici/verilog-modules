`define grayCode(x) {x[1], x[1]^x[0]}

module async_fifo(rst, rClk, rEn, rData, empty, wClk, wEn, wData, full);
	parameter DATA_WIDTH = 32;
	parameter DEPTH = 1024; // MUST BE POWER OF 2 !!!
	localparam ADDR_WIDTH = $clog2(DEPTH); // actual width = ADDR_WIDTH + 1
	
  //async to both domains
  input rst;

	// rClk domain
	input rClk;
	input rEn;
	output[DATA_WIDTH-1:0] rData;
	output empty;

	// wClk domain
	input wClk;
	input wEn;
	input[DATA_WIDTH-1:0] wData;
	output full;

reg rst_rClk, rst_wClk;
reg rst_rClk1, rst_wClk1;

always @(posedge wClk) begin
	rst_wClk1 <= rst;
	rst_wClk <= rst_wClk1;
end

always @(posedge rClk) begin
	rst_rClk1 <= rst;
	rst_rClk <= rst_rClk1;
end

reg[DATA_WIDTH-1:0] mem[0:DEPTH-1];

// rClk domain
reg empty, empty_nxt;
reg[1:0] wPtr_rClk_gray, wPtr_rClk_gray_nxt;
reg[ADDR_WIDTH:0] rPtr, rPtr_nxt, wPtr_rClk, wPtr_rClk_nxt;

assign rData = mem[rPtr[ADDR_WIDTH-1:0]];
always @(posedge rClk) begin
  empty <= empty_nxt;
  rPtr <= rPtr_nxt;

  // crossed over from wClk domain 
  wPtr_rClk_gray_nxt <= `grayCode(wPtr);
  wPtr_rClk_gray <= wPtr_rClk_gray_nxt;
  wPtr_rClk <= wPtr_rClk_nxt;
end

always @* begin
  wPtr_rClk_nxt[ADDR_WIDTH:2] = wPtr_rClk[ADDR_WIDTH:2];
  wPtr_rClk_nxt[1:0] = `grayCode(wPtr_rClk_gray);
  if(wPtr_rClk[1:0] > wPtr_rClk_nxt[1:0]) begin
	  wPtr_rClk_nxt[ADDR_WIDTH:2] = wPtr_rClk[ADDR_WIDTH:2] + 1;
  end
  
  rPtr_nxt = rPtr + rEn;
  empty_nxt = rPtr_nxt == wPtr_rClk_nxt;
  if(rst_rClk)begin
    rPtr_nxt = 0;
    wPtr_rClk_nxt = 0;
    wPtr_rClk_gray_nxt = 0;
    empty_nxt = 1;
    rPtr_nxt = 0;
  end
end

// wClk domain
reg full, full_nxt;
reg[1:0] rPtr_wClk_gray, rPtr_wClk_gray_nxt;
reg[ADDR_WIDTH:0] wPtr, wPtr_nxt, rPtr_wClk, rPtr_wClk_nxt;

always @(posedge wClk) begin
  full <= full_nxt;
  wPtr <= wPtr_nxt;
  mem[wPtr[ADDR_WIDTH-1:0]] <= wEn ? wData : mem[wPtr[ADDR_WIDTH-1:0]];
  
  // crossed over from rClk domain 
  rPtr_wClk_gray_nxt <= `grayCode(rPtr);
  rPtr_wClk_gray <= rPtr_wClk_gray_nxt;
  rPtr_wClk <= rPtr_wClk_nxt;
end

always @* begin
  rPtr_wClk_nxt[ADDR_WIDTH:2] = rPtr_wClk[ADDR_WIDTH:2];
  rPtr_wClk_nxt[1:0] = `grayCode(rPtr_wClk_gray);
  if(rPtr_wClk[1:0] > rPtr_wClk_nxt[1:0]) begin
	  rPtr_wClk_nxt[ADDR_WIDTH:2] = rPtr_wClk[ADDR_WIDTH:2] + 1;
  end
  
  wPtr_nxt = wPtr + wEn;
  full_nxt = {~wPtr_nxt[ADDR_WIDTH], wPtr_nxt[ADDR_WIDTH-1:0]} == rPtr_wClk_nxt;
  if(rst_wClk)begin
    wPtr_nxt = 0;
    rPtr_wClk_nxt = 0;
    rPtr_wClk_gray_nxt = 0;
    full_nxt = 0;
    wPtr_nxt = 0;
  end
end

endmodule