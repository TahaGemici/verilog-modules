module cdc_sync #(parameter WIDTH = 1) (
    input clk,
    input arst_n,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    reg [WIDTH-1:0] d1;
    always @(posedge clk or negedge arst_n) begin
        d1 <= d;
        q <= d1;
        if(~arst_n) begin
            d1 <= 0;
            q <= 0;
        end
    end

endmodule