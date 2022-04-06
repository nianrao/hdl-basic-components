module single_port_ram #(
           parameter WIDTH = 8,
           parameter DEPTH = 256,
           parameter MODE = "NO_CHANGE" // "READ_FIRST" or "WRITE_FIRST"
       ) (
           input [WIDTH - 1: 0] din,
           input [$clog2(DEPTH) - 1: 0] addr,
           input clk,
           input wea,
           input ena,
           output [WIDTH - 1: 0] dout
       );

reg [WIDTH - 1: 0] mem [DEPTH - 1: 0];
reg [WIDTH - 1: 0] dout_temp = {WIDTH{1'b0}};

generate
    if (MODE == "NO_CHANGE") begin: NO_CHANGE_RAM
        always @(posedge clk) begin
            if (ena) begin
                if (wea) begin
                    mem[addr] = din;
                end
                else begin
                    dout_temp = mem[addr];
                end
            end
        end
    end
    else if (MODE == "WRITE_FIRST") begin: WRITE_FIRST_RAM
        always @(posedge clk) begin
            if (ena) begin
                if (wea) begin
                    mem[addr] <= din;
                    dout_temp <= din;
                end
                else begin
                    dout_temp <= mem[addr];
                end
            end
        end
    end
    else if (MODE == "READ_FIRST") begin: READ_FIRST_RAM
        always @(posedge clk) begin
            if (ena) begin
                dout_temp <= mem[addr];
                if (wea)
                    mem[addr] <= din;
            end
        end
    end
endgenerate

assign dout = dout_temp;

endmodule
