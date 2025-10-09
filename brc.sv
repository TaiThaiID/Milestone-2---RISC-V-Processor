module brc (
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic        i_br_un,
    output logic        o_br_less,
    output logic        o_br_equal
);

    // --- Internal Signals ---
    logic [31:0] sum;          // Kết quả của phép trừ rs1 - rs2
    logic        c_out;        // Cờ nhớ ra từ phép trừ
    logic        overflow;     // Cờ tràn số cho phép toán có dấu
    logic        signed_less;  // Kết quả so sánh nhỏ hơn có dấu
    logic        unsigned_less;// Kết quả so sánh nhỏ hơn không dấu

    // Sign bits for readability
    assign        s1_sign = i_rs1_data[31];
    assign        s2_sign = i_rs2_data[31];
    assign        sum_sign = sum[31];

    // --- Subtraction using the provided 32-bit adder ---
    // Để thực hiện rs1 - rs2, ta tính rs1 + (~rs2) + 1 (Cin = 1).
    adder32 u_subtractor (
        .a      (i_rs1_data),
        .b      (i_rs2_data),
        .c_in   (1'b1),
        .sum    (sum),
        .c_out  (c_out)
    );

    // --- Equality Check ---
    // rs1 == rs2 khi và chỉ khi sum = (rs1 - rs2) == 0.
    assign o_br_equal = ~|sum;

    // --- Less Than Check ---

    // 1. Unsigned comparison (i_br_un = 0)
    // rs1 < rs2 (unsigned) khi có borrow, tương đương với c_out = 0.
    assign unsigned_less = ~c_out;

    // 2. Signed comparison (i_br_un = 1)
    // Tràn số xảy ra khi dấu của 2 toán hạng khác nhau VÀ dấu kết quả khác dấu toán hạng đầu.
    assign overflow = (s1_sign ^ s2_sign) & (s1_sign ^ sum_sign);
    // Kết quả nhỏ hơn là XOR của bit dấu kết quả và cờ tràn.
    assign signed_less = sum_sign ^ overflow;

    // 3. Final Selection
    // Dùng MUX để chọn kết quả cuối cùng dựa trên i_br_un.
    assign o_br_less = i_br_un ? signed_less : unsigned_less;

endmodule