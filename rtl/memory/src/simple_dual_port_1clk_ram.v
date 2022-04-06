module simple_dual_port_1clk_ram #(
           parameter WIDTH = 8,
           parameter DEPTH = 256
       ) (
           // common clock
           input clk,

           // port A for write
           input [WIDTH - 1: 0] dina,
           input [$clog2(DEPTH) - 1: 0] addra,
           input wea,

           // port B for read
           input enb,
           input [$clog2(DEPTH) - 1: 0] addrb,
           output [WIDTH - 1: 0] doutb
       );

reg [WIDTH - 1: 0] mem [DEPTH - 1: 0];
reg [WIDTH - 1: 0] dout_temp = {WIDTH{1'b0}};

always @(posedge clk) begin
    if (wea)
        mem[addra] <= dina;
    if (enb)
        dout_temp <= mem[addrb];
end

assign doutb = dout_temp;

endmodule
