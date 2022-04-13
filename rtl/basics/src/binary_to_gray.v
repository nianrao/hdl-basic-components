module binary_to_gray #(
           parameter WIDTH = 8
       ) (
           input [WIDTH - 1: 0] binary,
           output [WIDTH - 1: 0] gray
       );

assign gray[0] = binary[0];

genvar i;
generate
    for (i = 1; i < WIDTH; i = i + 1) begin: gray_gen
        assign gray[i] = binary[i] ^ binary[i - 1];
    end
endgenerate


endmodule
