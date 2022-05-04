module gray_to_binary #(
           parameter WIDTH = 8
       ) (
           input [WIDTH - 1: 0] gray,
           output [WIDTH - 1: 0] binary
       );

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin: binary_gen
        assign binary[i] = ^ (gray >> i);
    end
endgenerate

endmodule
