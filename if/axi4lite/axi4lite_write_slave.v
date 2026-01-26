module axi4lite_write_slave (
    input aclk,
    input aresetn,

    input awvalid,
    output reg awready,
    input[31:0] awaddr,
    input[2:0] awprot,

    input wvalid,
    output reg wready,
    input[31:0] wdata,
    input[3:0] wstrb,

    output reg bvalid,
    input bready,
    output reg[1:0] bresp,

    input stall,
    output reg[3:0] en,
    output reg[31:0] addr,
    output reg[31:0] data
);

localparam OKAY = 2'b00, SLVERR = 2'b10;

reg wakeup, awready_nxt, wready_nxt, bvalid_nxt;
reg[1:0] bresp_nxt;
reg[3:0] strb, strb_nxt, en_nxt;
reg[31:0] addr_nxt, data_nxt;
always @(posedge aclk or negedge aresetn) begin
    if(~aresetn) begin
        wakeup <= 1'b1;
        awready <= 1'b0;
        wready <= 1'b0;
        bvalid <= 1'b0;
        bresp <= OKAY;
        strb <= 4'b0;
        addr <= 32'b0;
        data <= 32'b0;
        en <= 4'b0;
    end else begin
        wakeup <= 1'b0;
        awready <= awready_nxt;
        wready <= wready_nxt;
        bvalid <= bvalid_nxt;
        bresp <= bresp_nxt;
        strb <= strb_nxt;
        addr <= addr_nxt;
        data <= data_nxt;
        en <= en_nxt;
    end
end

always @* begin
    awready_nxt = awready;
    addr_nxt = addr;
    bresp_nxt = bresp;
    if(awvalid & awready) begin
        awready_nxt = 1'b0;
        addr_nxt = awaddr;
        bresp_nxt = awaddr[1:0] ? SLVERR : OKAY;
    end

    wready_nxt = wready;
    data_nxt = data;
    strb_nxt = strb;
    if(wvalid & wready) begin
        wready_nxt = 1'b0;
        data_nxt = wdata;
        strb_nxt = wstrb;
    end

    en_nxt = 4'b0;
    bvalid_nxt = bvalid;
    if((~awready) & (~wready) & (~stall)) begin
        if(bresp == OKAY) en_nxt = strb;
        bvalid_nxt = ~wakeup;
        awready_nxt = 1'b1;
        wready_nxt = 1'b1;
    end

    if(bvalid & bready) begin
        bvalid_nxt = 1'b0;
    end
end
endmodule