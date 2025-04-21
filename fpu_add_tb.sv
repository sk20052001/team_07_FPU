`timescale 1ns/1ps

module fpu_add_tb;

  logic clk, reset, valid;
  logic [31:0] din1, din2;
  logic [31:0] result;
  logic ready;

  fpu_add_RTL dut (
    .clk(clk),
    .reset(reset),
    .din1(din1),
    .din2(din2),
    .valid(valid),
    .result(result),
    .ready(ready)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Task for applying one test case
  task apply_test(input [31:0] a, input [31:0] b);
    begin
      din1 = a;
      din2 = b;
      valid = 1;
      @(posedge clk);
      valid = 0;
      // Wait for ready signal
      wait (ready == 1);
      $display("Time: %0t | din1 = %h, din2 = %h, result = %h", $time, a, b, result);
      @(posedge clk); // Wait one more cycle to go back to WAIT
    end
  endtask

  initial begin
    $display("\n========== Floating Point Adder Testbench ==========\n");

    // Initialize
    reset = 1;
    valid = 0;
    din1 = 0;
    din2 = 0;
    @(negedge clk);
    reset = 0;

    // Wait a little
    repeat (2) @(posedge clk);

    // Test 1: 1.0 + 1.0 = 2.0
    apply_test(32'h3f800000, 32'h3f800000); // 1.0 + 1.0

    // Test 2: 2.0 + 3.0 = 5.0
    apply_test(32'h40000000, 32'h40400000); // 2.0 + 3.0

    // Test 3: +inf + 1.0 = +inf
    apply_test(32'h7f800000, 32'h3f800000); // inf + 1.0

    // Test 4: NaN + 0.0 = NaN
    apply_test(32'h7fc00000, 32'h00000000); // nan + 0.0

    // Test 5: -2.0 + 2.0 = 0.0
    apply_test(32'hc0000000, 32'h40000000); // -2.0 + 2.0

    // Finish
    $display("\n========== Testbench Finished ==========\n");
    $finish;
  end

endmodule

