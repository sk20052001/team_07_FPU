module fpu_sub #(parameter nBITS=32) (
        input  logic          clk,
        input  logic          reset,
        input  logic [31:0]   din1,
        input  logic [31:0]   din2,
        input  logic          valid,
        output logic [31:0]   result,
        output logic          ready
      );

logic [31:0] din2_inv;

//perform negate operation on bit31 to flip the sign extension bit
assign din2_inv = {~din2[31],din2[30:0]};

fpu_add fpu_add (
	.clk(clk),
	.reset(reset),
	.din1(din1),
	.din2(din2_inv),
	.valid(valid),
	.result(result),
	.ready(ready));

endmodule
