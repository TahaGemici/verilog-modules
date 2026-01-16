module gray2bin #(parameter WIDTH = 4) (input[WIDTH-1:0] gray, output[WIDTH-1:0] bin);
    genvar i;
    generate
        assign bin[WIDTH-1] = gray[WIDTH-1];
        for(i = 0; i < (WIDTH-1); i = i + 1) begin
            assign bin[i] = bin[i+1] ^ gray[i];
        end
    endgenerate
endmodule