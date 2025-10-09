module adder32(
	input  logic [31:0] a,
	input  logic [31:0] b,
	input  logic 		  c_in,
	output logic [31:0] sum,
	output logic 		  c_out 
);

	logic [31:0] c_out_tmp;
		//Create LSB and c_out_tmp
		full_adder fa_0 (
				.a (a[0]),
				.b (b[0]^c_in),
				.c_in (c_in),
				.c_out (c_out_tmp[0]),
				.s (sum[0])
		);

		//Instantiate 32 full_adder
		genvar i;
		generate 
			for (i=1; i<32; i++) begin : adder32
				full_adder fa_i (
					.a (a[i]),
					.b (b[i]^c_in),
					.c_in (c_out_tmp[i-1]),
					.c_out (c_out_tmp[i]),
					.s (sum[i])
				);
			end
		endgenerate
	
	assign c_out = c_out_tmp[31];
endmodule
