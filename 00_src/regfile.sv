module regfile(
  input  logic        i_clk,
  input  logic        i_reset_n,          // reset mức thấp (active-low)
  input  logic [4:0]  i_rs1_addr,
  input  logic [4:0]  i_rs2_addr,
  output logic [31:0] o_rs1_data,
  output logic [31:0] o_rs2_data,
  input  logic [4:0]  i_rd_addr,
  input  logic [31:0] i_rd_data,          // dữ liệu ghi vào
  input  logic        i_rd_wren           // enable ghi
);

  integer k;
  logic [31:0] registers [31:0];          // 32 thanh ghi, mỗi cái 32-bit

  // Ghi đồng bộ, reset bất đồng bộ mức thấp
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      for (k = 0; k < 32; k = k + 1)
        registers[k] <= 32'd0;
    end else begin
      if (i_rd_wren && (i_rd_addr != 5'd0))   // không cho ghi x0
        registers[i_rd_addr] <= i_rd_data;

      registers[5'd0] <= 32'd0;               // khóa x0 luôn 0
    end
  end

  // Đọc bất đồng bộ (combinational read)
  assign o_rs1_data = (i_rs1_addr == 5'd0) ? 32'd0 : registers[i_rs1_addr];
  assign o_rs2_data = (i_rs2_addr == 5'd0) ? 32'd0 : registers[i_rs2_addr];

endmodule
