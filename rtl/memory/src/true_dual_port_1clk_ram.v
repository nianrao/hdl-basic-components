module true_dual_port_1clk_ram #(
           parameter WIDTH = 8,
           parameter DEPTH = 256,
           parameter MODE = "NO_CHANGE" // "READ_FIRST" or "WRITE_FIRST"
       ) (
           // common clock
           input clk,

           // port A
           input [WIDTH - 1: 0] dina,
           input [$clog2(DEPTH) - 1: 0] addra,
           input wea,
           input ena,
           output [WIDTH - 1: 0] douta,

           // port B
           input [WIDTH - 1: 0] dinb,
           input [$clog2(DEPTH) - 1: 0] addrb,
           input web,
           input enb,
           output [WIDTH - 1: 0] doutb
       );

reg [WIDTH - 1: 0] mem [0: DEPTH - 1];
reg [WIDTH - 1: 0] douta_temp ;
reg [WIDTH - 1: 0] doutb_temp ;

generate
    if (MODE == "NO_CHANGE") begin: NO_CHANGE_RAM
        // port A
        always @ (posedge clk) begin
            if (ena) begin
                if (wea)
                    mem[addra] <= dina;
                else
                    douta_temp <= mem[addra];
            end
        end

        // port B
        always @ (posedge clk) begin
            if (enb) begin
                if (web)
                    mem[addrb] <= dinb;
                else
                    doutb_temp <= mem[addrb];
            end
        end
    end
    else if (MODE == "READ_FIRST") begin: READ_FIRST_RAM
        // port A
        always @ (posedge clk) begin
            if (ena) begin
                if (wea)
                    mem[addra] <= dina;

                douta_temp <= mem[addra];
            end
        end

        // port B
        always @ (posedge clk) begin
            if (enb) begin
                if (web)
                    mem[addrb] <= dinb;
                doutb_temp <= mem[addrb];
            end
        end

    end
    else if (MODE == "WRITE_FIRST") begin: WRITE_FIRST_RAM
        // port A
        always @ (posedge clk) begin
            if (ena) begin
                if (wea) begin
                    mem[addra] <= dina;
                    douta_temp <= dina;
                end
                else begin
                    douta_temp <= mem[addra];
                end
            end
        end

        // port B
        always @ (posedge clk) begin
            if (enb) begin
                if (web) begin
                    mem[addrb] <= dinb;
                    doutb_temp <= dinb;
                end
                else begin
                    doutb_temp <= mem[addrb];
                end
            end
        end
    end
endgenerate

assign douta = douta_temp;
assign doutb = doutb_temp;

endmodule
