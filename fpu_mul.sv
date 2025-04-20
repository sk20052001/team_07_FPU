module fpu_mul #(
    parameter EXP_WIDTH  = 8,                // Exponent width: 8 for single, 11 for double
    parameter MANT_WIDTH = 23                // Mantissa width: 23 for single, 52 for double
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [EXP_WIDTH + MANT_WIDTH : 0] din1,  // {sign, exponent, mantissa}
    input  logic [EXP_WIDTH + MANT_WIDTH : 0] din2,
    input  logic dval,
    output logic [EXP_WIDTH + MANT_WIDTH : 0] result,
    output logic rdy
);

    // Derived constants
    localparam BIAS           = (1 << (EXP_WIDTH - 1)) - 1;
    localparam FULL_MANT      = MANT_WIDTH + 1;          // +1 for hidden bit
    localparam PRODUCT_WIDTH  = FULL_MANT * 2;

    typedef enum logic [3:0] {
        WAIT_REQ,
        UNPACK,
        SPECIAL_CASES,
        NORMALISE_A,
        NORMALISE_B,
        MULTIPLY_0,
        MULTIPLY_1,
        NORMALISE_1,
        NORMALISE_2,
        ROUND,
        PACK,
        OUT_RDY
    } state_t;

    state_t state;

    logic [EXP_WIDTH + MANT_WIDTH : 0] a, b, z;
    logic [FULL_MANT-1:0] a_m, b_m, z_m;
    logic signed [EXP_WIDTH:0] a_e, b_e, z_e;
    logic a_s, b_s, z_s;
    logic guard, round_bit, sticky;
    logic [PRODUCT_WIDTH-1:0] product;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        state <= WAIT_REQ;
        rdy   <= 0;
        end else begin
        case(state)

            WAIT_REQ: begin
            rdy <= 0;
            if (dval) begin
                a <= din1;
                b <= din2;
                state <= UNPACK;
            end
            end

            UNPACK: begin
            a_m <= a[MANT_WIDTH-1:0];
            b_m <= b[MANT_WIDTH-1:0];
            a_e <= $signed(a[MANT_WIDTH + EXP_WIDTH - 1 : MANT_WIDTH]) - BIAS;
            b_e <= $signed(b[MANT_WIDTH + EXP_WIDTH - 1 : MANT_WIDTH]) - BIAS;
            a_s <= a[EXP_WIDTH + MANT_WIDTH];
            b_s <= b[EXP_WIDTH + MANT_WIDTH];
            state <= SPECIAL_CASES;
            end

            SPECIAL_CASES: begin
            if ((a_e == (1 << EXP_WIDTH) - BIAS) && a_m != 0 || (b_e == (1 << EXP_WIDTH) - BIAS) && b_m != 0) begin
                z <= {1'b1, {(EXP_WIDTH){1'b1}}, {MANT_WIDTH{1'b0}}};
                z[MANT_WIDTH] <= 1; // Quiet NaN
                state <= OUT_RDY;
            end else if (a_e == (1 << EXP_WIDTH) - BIAS) begin
                z <= {a_s ^ b_s, {(EXP_WIDTH){1'b1}}, {MANT_WIDTH{1'b0}}};
                if (b_e == -BIAS && b_m == 0) begin
                z <= {1'b1, {(EXP_WIDTH){1'b1}}, {MANT_WIDTH{1'b0}}};
                z[MANT_WIDTH] <= 1;
                end
                state <= OUT_RDY;
            end else if (b_e == (1 << EXP_WIDTH) - BIAS) begin
                z <= {a_s ^ b_s, {(EXP_WIDTH){1'b1}}, {MANT_WIDTH{1'b0}}};
                if (a_e == -BIAS && a_m == 0) begin
                z <= {1'b1, {(EXP_WIDTH){1'b1}}, {MANT_WIDTH{1'b0}}};
                z[MANT_WIDTH] <= 1;
                end
                state <= OUT_RDY;
            end else if ((a_e == -BIAS && a_m == 0) || (b_e == -BIAS && b_m == 0)) begin
                z <= {a_s ^ b_s, {(EXP_WIDTH){1'b0}}, {MANT_WIDTH{1'b0}}};
                state <= OUT_RDY;
            end else begin
                if (a_e == -BIAS) a_e <= -BIAS + 1; else a_m[FULL_MANT-1] <= 1;
                if (b_e == -BIAS) b_e <= -BIAS + 1; else b_m[FULL_MANT-1] <= 1;
                state <= NORMALISE_A;
            end
            end

            NORMALISE_A: begin
            if (a_m[FULL_MANT-1]) state <= NORMALISE_B;
            else begin
                a_m <= a_m << 1;
                a_e <= a_e - 1;
            end
            end

            NORMALISE_B: begin
            if (b_m[FULL_MANT-1]) state <= MULTIPLY_0;
            else begin
                b_m <= b_m << 1;
                b_e <= b_e - 1;
            end
            end

            MULTIPLY_0: begin
            z_s <= a_s ^ b_s;
            z_e <= a_e + b_e + 1;
            product <= a_m * b_m;
            state <= MULTIPLY_1;
            end

            MULTIPLY_1: begin
            z_m       <= product[PRODUCT_WIDTH-1 : FULL_MANT];
            guard     <= product[FULL_MANT-1];
            round_bit <= product[FULL_MANT-2];
            sticky    <= |product[FULL_MANT-3:0];
            state     <= NORMALISE_1;
            end

            NORMALISE_1: begin
            if (!z_m[FULL_MANT-1]) begin
                z_e <= z_e - 1;
                z_m <= (z_m << 1) | guard;
                guard <= round_bit;
                round_bit <= 0;
            end else state <= NORMALISE_2;
            end

            NORMALISE_2: begin
            if (z_e < -BIAS + 1) begin
                z_e <= z_e + 1;
                sticky <= sticky | round_bit | guard;
                round_bit <= z_m[0];
                guard <= z_m[1];
                z_m <= z_m >> 1;
            end else state <= ROUND;
            end

            ROUND: begin
            if (guard && (round_bit | sticky | z_m[0])) begin
                z_m <= z_m + 1;
                if (z_m == {FULL_MANT{1'b1}}) z_e <= z_e + 1;
            end
            state <= PACK;
            end

            PACK: begin
            z <= {z_s, (z_e + BIAS)[EXP_WIDTH-1:0], z_m[FULL_MANT-2:0]};
            if (z_e > ((1 << EXP_WIDTH) - 1 - BIAS)) begin
                z <= {z_s, {(EXP_WIDTH){1'b1}}, {MANT_WIDTH{1'b0}}};  // Overflow to Inf
            end else if (z_e == -BIAS && !z_m[FULL_MANT-1]) begin
                z[EXP_WIDTH + MANT_WIDTH - 1 : MANT_WIDTH] <= {EXP_WIDTH{1'b0}};
            end
            state <= OUT_RDY;
            end

            OUT_RDY: begin
            rdy <= 1;
            result <= z;
            state <= WAIT_REQ;
            end

        endcase
        end
    end

endmodule