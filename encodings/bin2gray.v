module bin2gray #(parameter WIDTH = 4) (input[WIDTH-1:0] bin, output[WIDTH-1:0] gray);
    genvar i;
    generate
        assign gray[WIDTH-1] = bin[WIDTH-1];
        for(i = WIDTH-2; i >= 0; i = i - 1) begin
            assign gray[i] = bin[i+1] ^ bin[i];
        end
    endgenerate
endmodule