module ripple_carry_adder #(parameter WIDTH = 10)
       (input [WIDTH - 1 : 0] a,
        input [WIDTH - 1 : 0] b,
        output [WIDTH : 0] o_sum);

wire [WIDTH: 0] w_carry;
wire [WIDTH - 1: 0] w_sum;

// generate a loop with a full adder for each input bit
assign w_carry[0] = 1'b0;
genvar i;
generate
    for (i = 0 ; i < WIDTH ; i = i + 1) begin
        full_adder adder
                   (.x(a[i]),
                    .y(b[i]),
                    .carry_in(w_carry[i]),
                    .carry_out(w_carry[i + 1]),
                    .sum(w_sum[i]));
    end
endgenerate
endmodule  //ripple_carry_adder
