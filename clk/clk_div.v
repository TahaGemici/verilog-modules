module clk_div #(
    parameter DIV_FACTOR = 2 // Must be even
)(
    input clk_in,
    input arst_n,
    output reg clk_out
);
    generate
        if(DIV_FACTOR <= 2) reg counter, counter_nxt;
        else reg[$clog2(DIV_FACTOR)-1:0] counter, counter_nxt;
    endgenerate

    always @(posedge clk_in or negedge arst_n) begin
        counter <= counter_nxt;
        if(counter_nxt == 0) begin
            clk_out <= ~clk_out;
        end
        
        if(~arst_n) begin
            counter <= 0;
            clk_out <= 0;
        end
    end

    always @* begin
        counter_nxt = counter + 1;
        if(counter == DIV_FACTOR/2 - 1) begin
            counter_nxt = 0;
        end
    end
endmodule