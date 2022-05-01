`ifndef FIFO_1CLK_SV
`define FIFO_1CLK_SV

`default_nettype none

module fifo_1clk #(
    parameter WIDTH = 8,
    parameter DEPTH = 256
) (
    // common interface
    input wire clk,
    input wire rst,

    // write interface
    input wire [WIDTH-1:0] din,
    input wire wr_en,
    output wire full,

    // read interface
    input wire rd_en,
    output wire [WIDTH-1:0] dout,
    output wire empty
);

  localparam ADDR_WIDTH = $clog2(DEPTH);

  logic [ADDR_WIDTH:0] wr_ptr, rd_ptr;
  logic [WIDTH-1:0] buffer[DEPTH-1:0];

  logic [WIDTH-1:0] dout_temp;

  // fifo read and write
  always_ff @(posedge clk) begin
    if (rst) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      dout_temp <= 0;
      buffer <= '{default: '0};
    end else begin
      if (wr_en && !full) begin
        buffer[wr_ptr[0+:ADDR_WIDTH]] <= din;
        wr_ptr <= wr_ptr + 1;
      end

      if (rd_en && !empty) begin
        dout_temp <= buffer[rd_ptr[0+:ADDR_WIDTH]];
        rd_ptr <= rd_ptr + 1;
      end
    end
  end
  assign dout = dout_temp;

  // Status logic
  assign full = (wr_ptr[0 +: ADDR_WIDTH] == rd_ptr[0 +: ADDR_WIDTH]) &&
                (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);

  assign empty = (wr_ptr == rd_ptr);

endmodule

`default_nettype wire

`endif  // FIFO_1CLK_SV
