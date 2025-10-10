`timescale 1ns/1ps

module brc_tb;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic        br_un;
    logic        br_less;
    logic        br_equal;

    // Instantiate the Device Under Test (DUT)
    brc dut (
        .i_rs1_data(rs1_data),
        .i_rs2_data(rs2_data),
        .i_br_un   (br_un),
        .o_br_less (br_less),
        .o_br_equal(br_equal)
    );

    // Test Logic
    integer test_count = 0;
    integer error_count = 0;

    // Task để kiểm tra một trường hợp cụ thể, giúp code gọn hơn
    task run_test(
        input [31:0] rs1_val,
        input [31:0] rs2_val,
        input        is_signed,
        input        expected_less,
        input        expected_equal,
        input string comment
    );
        begin
            test_count++;
            rs1_data = rs1_val;
            rs2_data = rs2_val;
            br_un    = is_signed;
            #10; // Chờ 10ns để logic tổ hợp ổn định
				
				//hệ thống sẽ so sánh ngõ ra thực tế (br_less) của code và ngõ ra mong muốn (expected_less) do mình đặt vào
				//hong đúng thì dô cái này
            if (br_less !== expected_less || br_equal !== expected_equal) begin
                error_count++;
                $display("--------------------------------------------------");
                $display(">>> [FAIL] Test %0d: %s", test_count, comment);
                $display("    Inputs: rs1=%d (%h), rs2=%d (%h), signed=%b", rs1_val, rs1_val, rs2_val, rs2_val, is_signed);
                $display("    Expected: less=%b, equal=%b", expected_less, expected_equal);
                $display("    Got:      less=%b, equal=%b", br_less, br_equal);
                $display("--------------------------------------------------");
            end else begin
				//Đúng hết thì dô cái này
                $display("[PASS] Test %0d: rs1 = %d (%h), rs2 = %d (%h), br_less = %b, br_equal = %b, %s", test_count, rs1_val, rs1_val, rs2_val, rs2_val, expected_less, expected_equal, comment);
            end
        end
    endtask


    // Khối initial chứa tất cả các test case
    initial begin
        $display("==================================================");
        $display("=== Starting BRC Verification ===");
        $display("==================================================");
        $display("================= EQUALITY TESTS =================");

        run_test(100, 100, 1, 0, 1, "Equality (Positive)"); //Đúng hết thì hiện câu trong ""
        run_test(-50, -50, 1, 0, 1, "Equality (Negative)");
        run_test(100, 101, 1, 1, 0, "Non-Equality");
		  
		  $display("========== UNSIGNED TESTS (br_un = 1) ==========");
        run_test(5, 10, 0, 1, 0, "5 < 10");
        run_test(10, 5, 0, 0, 0, "10 > 5");
        run_test(32'hFFFFFFFF, 0, 0, 0, 0, "Max > 0");
        // Trường hợp khó: số âm lớn nhất (có dấu) so với số dương (không dấu)
        // 32'h80000000 là 2^31, 32'h7FFFFFFF là 2^31 - 1
        run_test(32'h80000000, 32'h7FFFFFFF, 0, 0, 0, "2^31 > 2^31-1");

        $display("=========== SIGNED TESTS (br_un = 0) ===========");
		  run_test(5, 10, 1, 1, 0, "5 < 10");
        run_test(10, 5, 1, 0, 0, "10 > 5");
        run_test(-10, -5, 1, 1, 0, "-10 < -5");
        run_test(-5, -10, 1, 0, 0, "-5 > -10");
        run_test(-5, 5, 1, 1, 0, "Negative < Positive");
        run_test(5, -5, 1, 0, 0, "Positive > Negative");

		  $display("============ SIGNED OVERFLOW TESTS ============");
        // MAX_INT - (-1) gây tràn số. 2147483647 < -1 là sai
        run_test(32'h7FFFFFFF, 32'hFFFFFFFF, 1, 0, 0, "Signed Overflow: MAX_INT vs -1");
        // MIN_INT - 1 gây tràn số. -2147483648 < 1 là đúng
        run_test(32'h80000000, 1, 1, 1, 0, "Signed Overflow: MIN_INT vs 1");

        // --- Final Report ---
        if (error_count == 0) begin
            $display("\n>>> ALL TESTS PASSED! Congratulations! <<<");
        end else begin
            $display("\n>>> VERIFICATION FAILED with %0d error(s).", error_count);
        end
        $display("==================================================");

        $finish; // Kết thúc mô phỏng
    end

endmodule
