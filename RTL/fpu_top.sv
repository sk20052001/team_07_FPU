module fpu_top (
    input  logic clk,
    input  logic reset,
    input  logic [31:0] din1,
    input  logic [31:0] din2,
    input  logic valid,
    input  logic [1:0] op_sel,
    output logic [31:0] result,
    output logic ready
);
    // Wires to submodules
    logic [31:0] add_result, sub_result, mul_result, div_result;
    logic add_ready, sub_ready, mul_ready, div_ready;

    // Valid signal distribution
    logic add_valid, sub_valid, mul_valid, div_valid;

    // Dispatch input based on op_sel
    always_comb begin
        add_valid = (op_sel == 2'b00) ? valid : 0;
        sub_valid = (op_sel == 2'b01) ? valid : 0;
        mul_valid = (op_sel == 2'b10) ? valid : 0;
        div_valid = (op_sel == 2'b11) ? valid : 0;
    end

    // Instantiate submodules
    fpu_add adder (
        .clk    (clk),
        .reset  (reset),
        .din1   (din1),
        .din2   (din2),
        .valid  (add_valid),
        .result (add_result),
        .ready  (add_ready)
    );

    fpu_sub subtractor (
        .clk    (clk),
        .reset  (reset),
        .din1   (din1),
        .din2   (din2),
        .valid  (sub_valid),
        .result (sub_result),
        .ready  (sub_ready)
    );

    fpu_mul multiplier (
        .clk    (clk),
        .reset  (reset),
        .din1   (din1),
        .din2   (din2),
        .valid  (mul_valid),
        .result (mul_result),
        .ready  (mul_ready)
    );

    fpu_div divider (
        .clk    (clk),
        .reset  (reset),
        .din1   (din1),
        .din2   (din2),
        .valid  (div_valid),
        .result (div_result),
        .ready  (div_ready)
    );

    // Multiplex result and ready signal
    always_comb begin
        case (op_sel)
            2'b00: begin
                result = add_result;
                ready  = add_ready;
            end
            2'b01: begin
                result = sub_result;
                ready  = sub_ready;
            end
            2'b10: begin
                result = mul_result;
                ready  = mul_ready;
            end
            2'b11: begin
                result = div_result;
                ready  = div_ready;
            end
            default: begin
                result = 32'd0;
                ready  = 0;
            end
        endcase
    end

endmodule