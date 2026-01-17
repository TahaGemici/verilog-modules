module mean #(parameter WIDTH=8, DEPTH=4) (
    input clk,
    input arst_n,
    
    input data_valid,
    input [WIDTH-1:0] data_in,
    
    output reg [WIDTH-1:0] mean_out
);
reg[$clog2(DEPTH):0] count, count_nxt;
reg[WIDTH-1:0] numbers[0:DEPTH-1], numbers_nxt[0:DEPTH-1], mean_out_nxt;

integer i;
always @(posedge clk or negedge arst_n) begin
    if(~arst_n) begin
        count <= 0;
        for(i = 0; i < DEPTH; i = i + 1) begin
            numbers[i] <= 0;
        end
        mean_out <= 0;
    end else begin
        count <= count_nxt;
        for(i = 0; i < DEPTH; i = i + 1) begin
            numbers[i] <= numbers_nxt[i];
        end
        mean_out <= mean_out_nxt;
    end
end

always @* begin
    count_nxt = count;
    for(i = 0; i < DEPTH; i = i + 1) begin
        numbers_nxt[i] = numbers[i];
    end
    mean_out_nxt = mean_out;
    
    if(data_valid) begin
        if(count != DEPTH) begin
            count_nxt = count + 1;
        end
        numbers_nxt[0] = data_in;
        for(i = 1; i < DEPTH; i = i + 1) begin
            numbers_nxt[i] = numbers[i-1];
        end
    end
    
    // Calculate mean
    integer sum;
    sum = 0;
    for(i = 0; i < DEPTH; i = i + 1) begin
        if(count > i) begin
            sum = sum + numbers[i];
        end
    end
    if(count > 0) begin
        mean_out_nxt = sum / count;
    end
end

endmodule