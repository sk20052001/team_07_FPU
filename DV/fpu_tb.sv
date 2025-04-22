`timescale 1ns/1ns

module fpu_tb;
    logic clk;
    logic reset;
    logic valid;
    logic [31:0] din1, din2;
    logic [31:0] result;
    logic [1:0] op_sel;
    logic ready;

    typedef struct {
        logic [31:0] a;
        logic [31:0] b;
        logic [31:0] expected;
        string name;
    } test_t;

    test_t tests [4][4];

    fpu_top DUT (
        .clk(clk),
        .reset(reset),
        .din1(din1),
        .din2(din2),
        .valid(valid),
        .op_sel(op_sel),
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

        tests[0][0] = '{32'h3f800000, 32'h3f800000, 32'h40000000, "1.0 + 1.0 = 2.0"};
        tests[0][1] = '{32'h40000000, 32'h40400000, 32'h40a00000, "2.0 + 3.0 = 5.0"};
        tests[0][2] = '{32'h7f800000, 32'h3f800000, 32'h7f800000, "inf + 1.0 = inf"};
        tests[0][3] = '{32'hc0000000, 32'h40000000, 32'h00000000, "-2.0 + 2.0 = 0.0"};

        tests[1][0] = '{32'h3f800000, 32'h3f800000, 32'h00000000, "1.0 - 1.0 = 0.0"};
        tests[1][1] = '{32'h40000000, 32'h40400000, 32'hbf800000, "2.0 - 3.0 = -1.0"};
        tests[1][2] = '{32'h7f800000, 32'h3f800000, 32'h7f800000, "inf - 1.0 = inf"};
        tests[1][3] = '{32'hc0000000, 32'h40000000, 32'hc0800000, "-2.0 - 2.0 = -4.0"};

        tests[2][0] = '{32'h3f800000, 32'h40000000, 32'h40000000, "1.0 * 2.0 = 2.0"};
        tests[2][1] = '{32'h40600000, 32'h3fe00000, 32'h40c40000, "3.5 * 1.75 = 6.125"};
        tests[2][2] = '{32'h7f800000, 32'h40000000, 32'h7f800000, "inf * 2.0 = inf"};
        tests[2][3] = '{32'h40b00000, 32'hc0000000, 32'hc1300000, "5.5 * (-2.0) = -11.0"};

        tests[3][0] = '{32'h3f800000, 32'h40000000, 32'h3f000000, "1.0 /  2.0 = 0.5"};
        tests[3][1] = '{32'h40600000, 32'h3fe00000, 32'h40000000, "3.5 /  1.75 = 2.0"};
        tests[3][2] = '{32'h40e00000, 32'h40000000, 32'h40600000, "7.0 /  2.0 = 3.5"};
        tests[3][3] = '{32'h00000001, 32'h00000000, 32'h7f800000, "1.401298464e-45 / 0.0 = inf"};

        for (int i = 0; i < 4; i++) begin
            op_sel = i;
            for (int j = 0; j < 4; j++) begin
                $display("\n---- Test %0d: %s ----", (i * 4) + j + 1, tests[i][j].name);
                din1 = tests[i][j].a;
                din2 = tests[i][j].b;
                valid = 1;
                @(posedge clk);
                valid = 0;

                wait (ready);
                @(posedge clk);

                if (result === tests[i][j].expected) begin
                    $display("PASS: got 0x%08h expected 0x%08h", result, tests[i][j].expected);
                end else begin
                    $display("FAIL: got 0x%08h expected 0x%08h", result, tests[i][j].expected);
                end
            end
        end

        $display("\nAll tests completed.");
        $stop;
    end

endmodule