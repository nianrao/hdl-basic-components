module full_adder
       (
           input x,
           input y,
           input carry_in,
           output carry_out,
           output sum
       );

assign sum = (x ^ y) ^ carry_in;
assign carry_out = ((x ^ y) & carry_in) | (x & y);

endmodule
