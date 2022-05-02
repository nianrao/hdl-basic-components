`ifndef FIFO_2CLK_SV
`define FIFO_2CLK_SV

`default_nettype none

module fifo_2clk #(
    parameter WIDTH = 8,
    parameter DEPTH = 256
) (
    // common
    input wire rst_async,

    // write port
    input wire wr_clk,
    input wire [WIDTH-1:0] din,
    input wire wr_en,
    output wire full,

    // read port
    input wire rd_clk,
    input wire rd_en,
    output wire [WIDTH-1:0] dout,
    output wire empty
);

  localparam ADDR_WIDTH = $clog2(DEPTH);
  localparam SYNC_STAGE = 2;  // number of stages to sync the wr/rd pointer

  logic [WIDTH-1:0] buffer[DEPTH-1:0];

  // write interface
  logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_gray;
  logic [ADDR_WIDTH:0] rd_ptr_gray_sync_wr_clk[SYNC_STAGE-1:0];
  logic [ADDR_WIDTH:0] rd_ptr_binary_sync_wr_clk;

  // read interface
  logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_gray;
  logic [ADDR_WIDTH:0] wr_ptr_gray_sync_rd_clk[SYNC_STAGE-1:0];
  logic [ADDR_WIDTH:0] wr_ptr_binary_sync_rd_clk;
  logic [WIDTH-1:0] dout_temp;

  //////////////////////////////////////////////////////////////////////////////
  // write port
  //////////////////////////////////////////////////////////////////////////////
  always_ff @(posedge wr_clk or posedge rst_async) begin : fifo_write
    if (rst_async) begin
      wr_ptr <= 0;
      buffer <= '{default: '0};
    end else begin
      if (wr_en && !full) begin
        wr_ptr <= wr_ptr + 1;
        buffer[wr_ptr[0+:ADDR_WIDTH]] <= din;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // read port
  //////////////////////////////////////////////////////////////////////////////
  always_ff @(posedge rd_clk or posedge rst_async) begin : fifo_read
    if (rst_async) begin
      rd_ptr <= 0;
      dout_temp <= 0;
    end else begin
      if (rd_en && !empty) begin
        rd_ptr <= rd_ptr + 1;
        dout_temp <= buffer[rd_ptr[0+:ADDR_WIDTH]];
      end
    end
  end

  assign dout = dout_temp;

  //////////////////////////////////////////////////////////////////////////////
  // fifo full status
  //////////////////////////////////////////////////////////////////////////////
  // convert rd_ptr to gray code
  binary_to_gray #(
      .WIDTH(ADDR_WIDTH)
  ) rd_ptr_binary_to_gray_inst (
      .binary(rd_ptr),
      .gray  (rd_ptr_gray)
  );

  // synchronize rd_ptr_gray to wr_clk domain
  always_ff @(posedge wr_clk or posedge rst_async) begin : rd_ptr_sync
    if (rst_async) begin
      rd_ptr_gray_sync_wr_clk <= '{default: '0};
    end else begin
      rd_ptr_gray_sync_wr_clk <= {
        rd_ptr_gray_sync_wr_clk[0+:(SYNC_STAGE-1)], rd_ptr_gray
      };
    end
  end

  // convert rd_ptr_gray_sync_wr_clk to binary
  gray_to_binary #(
      .WIDTH(ADDR_WIDTH)
  ) rd_ptr_gray_to_binary_inst (
      .gray  (rd_ptr_gray_sync_wr_clk[SYNC_STAGE-1]),
      .binary(rd_ptr_binary_sync_wr_clk)
  );

  assign full = (wr_ptr[0 +: ADDR_WIDTH] == rd_ptr_binary_sync_wr_clk[0 +: ADDR_WIDTH]) &&
                (wr_ptr[ADDR_WIDTH] != rd_ptr_binary_sync_wr_clk[ADDR_WIDTH]);

  //////////////////////////////////////////////////////////////////////////////
  // fifo empty status
  //////////////////////////////////////////////////////////////////////////////
  // convert wr_ptr to gray code
  binary_to_gray #(
      .WIDTH(ADDR_WIDTH)
  ) wr_ptr_binary_to_gray_inst (
      .binary(wr_ptr),
      .gray  (wr_ptr_gray)
  );

  // synchronize wr_ptr_gray to rd_clk domain
  always_ff @(posedge rd_clk or posedge rst_async) begin : wr_ptr_sync
    if (rst_async) begin
      wr_ptr_gray_sync_rd_clk <= '{default: '0};
    end else begin
      wr_ptr_gray_sync_rd_clk <= {
        wr_ptr_gray_sync_rd_clk[0+:(SYNC_STAGE-1)], wr_ptr_gray
      };
    end
  end

  // convert wr_ptr_gray_sync_rd_clk to binary
  gray_to_binary #(
      .WIDTH(ADDR_WIDTH)
  ) wr_ptr_gray_to_binary_inst (
      .gray  (wr_ptr_gray_sync_rd_clk[SYNC_STAGE-1]),
      .binary(wr_ptr_binary_sync_rd_clk)
  );

  assign empty = (rd_ptr == wr_ptr_binary_sync_rd_clk);

endmodule

`default_nettype wire

`endif
