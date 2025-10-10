module adder32(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        c_in,      // 0: ADD, 1: SUB
    output logic [31:0] sum,
    output logic        c_out 
);
	
	
	logic [32:0] carry;
   	logic [31:0] b_xor;
	
	// Selection ADD or SUB 
    	assign b_xor = b ^ {32{c_in}};

	// Carry in
    	assign carry[0] = c_in;

	// Array of 32 full adders
   	 full_adder fa[31:0] (
        .a(a),
        .b(b_xor),
        .c_in(carry[31:0]),
        .s(sum),
        .c_out(carry[32:1])
    	);

	// Carry đầu ra
   	assign c_out = carry[32];
    
endmodule
