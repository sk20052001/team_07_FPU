`timescale 1 ns/10 ps
module tb_top;
parameter CLK_PERIOD = 10;
parameter nBITS = 32;

logic          clk;
logic          rst_n;
logic [31:0]   din1;
logic [31:0]   din2;
logic          dval;
wire [31:0]    result;
wire           rdy;
logic          test_fail;

//Device Under Test
fpu_sp_sub fpu_sp_sub (clk, rst_n, din1, din2, dval, result, rdy);

//Clock Generation
always #(CLK_PERIOD/2) clk  <= (clk === 1'b0);

initial 
begin
   rst_n = 0;
   test_fail=0;
   #100 rst_n = 1;
   repeat (2) @(posedge clk);
   dval = 1;
   //Few test cases
   din1 = fp_encode(4.0); 
   din2 = fp_encode(3.0);
   #200;
   $display("%0t\t%f - %f = %f", $time, $bitstoshortreal(din1), $bitstoshortreal(din2), $bitstoshortreal(result));
   din1 = fp_encode(5.5); 
   din2 = fp_encode(3.0);
   #300;
   $display("%0t\t%f - %f = %f", $time, $bitstoshortreal(din1), $bitstoshortreal(din2), $bitstoshortreal(result));
   #200;
   $finish();
end

 function [31:0] fp_encode(input shortreal val);
    return $shortrealtobits(val);
  endfunction

endmodule 
