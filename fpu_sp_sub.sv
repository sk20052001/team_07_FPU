////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/***************************************************************************************************************
module_name  : fp_sp_sub.sv
written_date : 4/20/2025
author       : sathish thirumalaisamy
description  : 32-bit Single-Precision Subtraction Unit
               Takes in a 2-32-bit IEE-754 format floating point inputs and performs a subrtraction
	       A-B functionality is carried at doing A+(-B)

               Input Signal:
	       Clk -> Posedge
	       rst_n -> negedge for resetting flops
	       din1 -> 32-bit wide IEE-754 format input
	       din2 -> 32-bit wide IEE-754 format input
	       dval -> high, indicating the data inputs are valid
	       result -> 32-bit wide output after performing A+(-B)
	       rdy -> high, indicating the output is ready	    
***************************************************************************************************************** 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

module fpu_sp_sub #(parameter nBITS=32) (
        input  logic          clk,
        input  logic          rst_n,
        input  logic [31:0]   din1,
        input  logic [31:0]   din2,
        input  logic          dval,
        output logic [31:0]   result,
        output logic          rdy
      );

logic [31:0] din2_inv;

//perform negate operation on bit31 to flip the sign extension bit
assign din2_inv = {~din2[31],din2[30:0]};

fpu_sp_add fpu_sp_add (
	.clk(clk),
	.rst_n(rst_n),
	.din1(din1),
	.din2(din2_inv),
	.dval(dval),
	.result(result),
	.rdy(rdy));

endmodule
