`timescale 1ns/1ns

module fpu_mul_tb;

  logic clk;
  logic reset;
  logic valid;
  logic [31:0] din1, din2;
  logic [31:0] result;
  logic ready;

  typedef struct {
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] expected;
    string name;
  } test_t;

  test_t tests [0:3];

  fpu_mul_RTL DUT(
    .clk(clk),
    .reset(reset),
    .din1(din1),
    .din2(din2),
    .valid(valid),
    .result(result),
    .ready(ready)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    reset = 1;
    valid  = 0;
    din1  = 32'd0;
    din2  = 32'd0;
    #20;

    reset = 0;
    #20;

    tests[0] = '{32'h3F800000, 32'h40000000, 32'h40000000, "1.0 * 2.0 = 2.0"};
    tests[1] = '{32'h40600000, 32'h3FE00000, 32'h40C40000, "3.5 * 1.75 = 6.125"};
    tests[2] = '{32'h40E00000, 32'h40000000, 32'h41600000, "7.0 * 2.0 = 14.0"};
    tests[3] = '{32'h40B00000, 32'hC0000000, 32'hC1300000, "5.5 * (-2.0) = -11.0"};

    foreach (tests[i]) begin
      $display("\n---- Test %0d: %s ----", i, tests[i].name);
      din1 = tests[i].a;
      din2 = tests[i].b;
      valid = 1;
      @(posedge clk);
      valid = 0;

      wait (ready);
      @(posedge clk);

      if (result === tests[i].expected) begin
        $display("PASS: got 0x%08h expected 0x%08h", result, tests[i].expected);
      end else begin
        $display("FAIL: got 0x%08h expected 0x%08h", result, tests[i].expected);
      end
    end

    $display("\nAll tests completed.");
    $stop;
  end

endmodule