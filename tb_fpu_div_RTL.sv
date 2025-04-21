`timescale 1ns/1ps

module tb_fpu_div_RTL;

  // Clock, reset and DUT I/O
  logic        clk;
  logic        reset;
  logic [31:0] din1, din2;
  logic        valid;
  wire [31:0]  result;
  wire         ready;

  // Instantiate the DUT
  fpu_div_RTL uut (
    .clk    (clk),
    .reset  (reset),
    .din1   (din1),
    .din2   (din2),
    .valid  (valid),
    .result (result),
    .ready  (ready)
  );

  // 10 ns clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset pulse
  initial begin
    reset = 1;
    valid = 0;
    #20;
    reset = 0;
  end

  // Test‑vector type and table
  typedef struct {
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] exp;
  } tv_t;

  tv_t tv [0:3];

  initial begin
    // a       /     b        = expected
    tv[0] = '{32'h3f800000, 32'h40000000, 32'h3f000000}; //  1.0 /  2.0 = 0.5
    tv[1] = '{32'h40600000, 32'h3fe00000, 32'h40000000}; //  3.5 /  1.75 = 2.0
    tv[2] = '{32'h40e00000, 32'h40000000, 32'h40600000};
	//  7.0 /  2.0 = 3.5
	tv[3] = '{32'h00000001, 32'h00000000, 32'h7F800000};
  //  tv[3] = '{32'hc0b00000, 32'h40000000, 32'hc0300000}; // -5.5 /  2.0 = -2.75
  // tv[4] = '{32'h00000001, 32'h00000000, 32'h7F800000};
    // Give DUT time to come out of reset
    #70;

    // Apply each vector
    for (int i = 0; i < 4; i++) begin
      @(posedge clk);
        valid <= 1;
        din1  <= tv[i].a;
        din2  <= tv[i].b;
      @(posedge clk);
        valid <= 0;
      // Wait for the division to complete
      wait (ready);
      // Check result
      if (result !== tv[i].exp) begin
        $display("FAIL: %h / %h => got %h, expected %h",
                  tv[i].a, tv[i].b, result, tv[i].exp);
      end else begin
        $display("PASS: %h / %h = %h",
                  tv[i].a, tv[i].b, result);
      end
      #10;
    end

    $display("All tests completed.");
    $finish;
  end

endmodule
