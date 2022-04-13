module gray_to_binary #(
           parameter WIDTH = 8
       ) (
           input [WIDTH - 1: 0] gray,
           output [WIDTH - 1: 0] binary
       );

assign binary[WIDTH - 1] = gray[WIDTH - 1];

genvar i;
generate
    for (i = WIDTH - 2; i >= 0; i = i - 1) begin: binary_gen
        assign binary[i] = binary[i + 1] ^ gray[i];
    end
endgenerate

endmodule
