module async_fifo(arst_n, rClk, rEn, rData, empty, wClk, wEn, wData, full);
	parameter DATA_WIDTH = 32;
	parameter DEPTH = 1024; // MUST BE POWER OF 2 !!!
	localparam ADDR_WIDTH = $clog2(DEPTH); // actual width = ADDR_WIDTH + 1
	
  //async to both domains
  input arst_n;

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

reg[DATA_WIDTH-1:0] mem[0:DEPTH-1];

// rClk domain
reg empty, empty_nxt;
reg[ADDR_WIDTH:0] rPtr, rPtr_nxt;
reg[ADDR_WIDTH:0] wPtr;

assign rData = mem[rPtr[ADDR_WIDTH-1:0]];
wire[ADDR_WIDTH:0] wPtr_gray, wPtr_bin;
bin2gray #(ADDR_WIDTH+1) wPtr_gray_inst (.bin(wPtr), .gray(wPtr_gray));

wire[ADDR_WIDTH:0] wPtr_rClk_gray;
cdc_sync #(ADDR_WIDTH+1) wPtr_rClk_gray_sync (.clk(rClk), .arst_n(arst_n), .d(wPtr_gray), .q(wPtr_rClk_gray));

gray2bin #(ADDR_WIDTH+1) wPtr_bin_inst (.gray(wPtr_rClk_gray), .bin(wPtr_bin));
always @(posedge rClk or negedge arst_n) begin
  if(~arst_n) begin
    rPtr <= 0;
    empty <= 1;
  end else begin
    empty <= empty_nxt;
    rPtr <= rPtr_nxt;
  end
end

always @* begin
  rPtr_nxt = rPtr + rEn;
  empty_nxt = rPtr_nxt == wPtr_bin;
end

// wClk domain
reg full, full_nxt;
reg[ADDR_WIDTH:0] wPtr_nxt;

wire[ADDR_WIDTH:0] rPtr_gray, rPtr_bin;
bin2gray #(ADDR_WIDTH+1) rPtr_gray_inst (.bin(rPtr), .gray(rPtr_gray));

wire[ADDR_WIDTH:0] rPtr_wClk_gray;
cdc_sync #(ADDR_WIDTH+1) rPtr_wClk_gray_sync (.clk(wClk), .arst_n(arst_n), .d(rPtr_gray), .q(rPtr_wClk_gray));

gray2bin #(ADDR_WIDTH+1) rPtr_bin_inst (.gray(rPtr_wClk_gray), .bin(rPtr_bin));
always @(posedge wClk) begin
  mem[wPtr[ADDR_WIDTH-1:0]] <= wEn ? wData : mem[wPtr[ADDR_WIDTH-1:0]];
end

always @(posedge wClk or negedge arst_n) begin
  if(~arst_n) begin
    wPtr <= 0;
    full <= 0;
  end else begin
    full <= full_nxt;
    wPtr <= wPtr_nxt;
  end
end

always @* begin
  wPtr_nxt = wPtr + wEn;
  full_nxt = {~wPtr_nxt[ADDR_WIDTH], wPtr_nxt[ADDR_WIDTH-1:0]} == rPtr_bin;
end

endmodule