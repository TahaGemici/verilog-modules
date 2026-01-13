// ToDo:
// - synchronize rst to both clk domains
// - pass only lower Ptr bits between clk domains
`define grayCode(x) {x[1], x[1]^x[0]}

module async_fifo(
	input rst, //async to both domains

	// rClk domain
	input rClk,
	input rEn,
	output[31:0] rData,
	output empty,

	// wClk domain
	input wClk,
	input wEn,
	input[31:0] wData,
	output full	
);

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

reg[31:0] mem[0:1023];

// rClk domain
reg empty, empty_nxt;
reg[10:0] rPtr, rPtr_nxt;
reg[10:0] wPtr_rClk, wPtr_rClk_nxt;
reg[1:0] wPtr_rClk_gray, wPtr_rClk_gray_nxt;

assign rData = mem[rPtr[9:0]];
always @(posedge rClk) begin
  empty <= #1 empty_nxt;
  rPtr <= #1 rPtr_nxt;

  // crossed over from wClk domain 
  wPtr_rClk_gray_nxt <= #1 `grayCode(wPtr);
  wPtr_rClk_gray <= #1 wPtr_rClk_gray_nxt;
  wPtr_rClk <= #1 wPtr_rClk_nxt;
end

always @* begin
  wPtr_rClk_nxt[10:2] = wPtr_rClk[10:2];
  wPtr_rClk_nxt[1:0] = `grayCode(wPtr_rClk_gray);
  if(wPtr_rClk[1:0] > wPtr_rClk_nxt[1:0]) begin
	  wPtr_rClk_nxt[10:2] = wPtr_rClk[10:2] + 1;
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
reg[10:0] wPtr, wPtr_nxt;
reg[10:0] rPtr_wClk, rPtr_wClk_nxt;
reg[1:0] rPtr_wClk_gray, rPtr_wClk_gray_nxt;

always @(posedge wClk) begin
  full <= #1 full_nxt;
  wPtr <= #1 wPtr_nxt;
  mem[wPtr[9:0]] <= #1 wEn ? wData : mem[wPtr[9:0]];
  
  // crossed over from rClk domain 
  rPtr_wClk_gray_nxt <= #1 `grayCode(rPtr);
  rPtr_wClk_gray <= #1 rPtr_wClk_gray_nxt;
  rPtr_wClk <= #1 rPtr_wClk_nxt;
end

always @* begin
  rPtr_wClk_nxt[10:2] = rPtr_wClk[10:2];
  rPtr_wClk_nxt[1:0] = `grayCode(rPtr_wClk_gray);
  if(rPtr_wClk[1:0] > rPtr_wClk_nxt[1:0]) begin
	  rPtr_wClk_nxt[10:2] = rPtr_wClk[10:2] + 1;
  end
  
  wPtr_nxt = wPtr + wEn;
  full_nxt = {~wPtr_nxt[10], wPtr_nxt[9:0]} == rPtr_wClk_nxt;
  if(rst_wClk)begin
    wPtr_nxt = 0;
    rPtr_wClk_nxt = 0;
    rPtr_wClk_gray_nxt = 0;
    full_nxt = 0;
    wPtr_nxt = 0;
  end
end

endmodule
