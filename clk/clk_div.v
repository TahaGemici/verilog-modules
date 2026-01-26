module clk_div (
    input clk_in,
    input arst_n,
    input[31:0] prescaler,
    output reg clk_out
);
    reg clk_out_nxt;
    reg[31:0] counter, counter_nxt;

    always @(posedge clk_in or negedge arst_n) begin
        if(~arst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            counter <= counter_nxt;
            clk_out <= clk_out_nxt;
        end
    end

    always @* begin
        counter_nxt = counter + 1;
        clk_out_nxt = clk_out;
        if(counter >= (prescaler[31:1] - 1)) begin
            counter_nxt = 0;
        end
        if(counter == 0) begin
            clk_out_nxt = ~clk_out;
        end
    end
endmodule