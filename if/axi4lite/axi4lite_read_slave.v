module axi4lite_read_slave (
    input aclk,
    input aresetn,

    input arvalid,
    output reg arready,
    input[31:0] araddr,
    input[2:0] arprot,

    output reg rvalid,
    input rready,
    output reg[31:0] rdata,
    output reg[1:0] rresp,
    
    input stall,
    input[31:0] data
);

localparam OKAY = 2'b00, SLVERR = 2'b10;

reg arready_nxt, rvalid_nxt;
reg[1:0] rresp_nxt;
reg[31:0] rdata_nxt;
always @(posedge aclk or negedge aresetn) begin
    if(~aresetn) begin
        arready <= 1'b1;
        rvalid <= 1'b0;
        rdata <= 32'b0;
        rresp <= OKAY;
    end else begin
        arready <= arready_nxt;
        rvalid <= rvalid_nxt;
        rdata <= rdata_nxt;
        rresp <= rresp_nxt;
    end
end

always @* begin
    arready_nxt = arready;
    rdata_nxt = rdata;
    rresp_nxt = rresp;
    if(arvalid & arready) begin
        arready_nxt = 1'b0;
        rdata_nxt = data;
        rresp_nxt = araddr[1:0] ? SLVERR : OKAY;
    end

    rvalid_nxt = rvalid;
    if((~arready) & (~stall)) begin
        rvalid_nxt = 1'b1;
    end

    if(rready & rvalid) begin
        rvalid_nxt = 1'b0;
        arready_nxt = 1'b1;
    end
end

endmodule