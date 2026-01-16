module clk_div #(
    parameter DIV_FACTOR = 2 // Must be even
)(
    input clk_in,
    input arst_n,
    output reg clk_out
);
    reg clk_out_nxt;
    reg[$clog2(DIV_FACTOR)-1:0] counter, counter_nxt;

    always @(posedge clk_in or negedge arst_n) begin
        counter <= counter_nxt;
        clk_out <= clk_out_nxt;
        if(~arst_n) begin
            counter <= 0;
            clk_out <= 0;
        end
    end

    always @* begin
        counter_nxt = counter + 1;
        clk_out_nxt = clk_out;
        if(counter == DIV_FACTOR/2 - 1) begin
            counter_nxt = 0;
        end
        if(counter == 0) begin
            clk_out_nxt = ~clk_out;
        end
    end
endmodule