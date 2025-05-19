module fpu_add(
    input  logic          clk,
    input  logic          reset,
    input  logic [31:0]   din1,
    input  logic [31:0]   din2,
    input  logic          valid,
    output logic [31:0]   result,
    output logic          ready
);

    logic       [31:0] s_output_z;

    typedef enum logic [3:0]{
        WAIT      = 4'd0,
        UNPACK        = 4'd1,
        CORNER_CASES = 4'd2,
        DENORM         = 4'd3,
        ADD         = 4'd4,
        SET_GRS         = 4'd5,
        NORMALISE_1   = 4'd6,
        NORMALISE_2   = 4'd7,
        ROUND         = 4'd8,
        PACK          = 4'd9,
        READY       = 4'd10
    }states;
			
	states state;
			

    logic       [31:0] a, b, z;
    logic       [26:0] a_m, b_m;
    logic       [23:0] z_m;
    logic       [9:0] a_e, b_e, z_e;
    logic       a_s, b_s, z_s;
    logic       guard, round_bit, sticky;
    logic       [27:0] pre_sum;

    always @(negedge reset or posedge clk)
    begin
        if (reset == 1) begin
        state         <= WAIT;
        ready           <= '0;
        end else begin
            case(state)
            WAIT:
            begin
                ready   <= '0;
                if (valid) begin
                a <= din1;
                b <= din2;
                state <= UNPACK;
                end
            end

            UNPACK:
            begin
                a_m    <= {a[22 : 0], 3'd0};
                b_m    <= {b[22 : 0], 3'd0};
                a_e    <= a[30 : 23] - 127;
                b_e    <= b[30 : 23] - 127;
                a_s    <= a[31];
                b_s    <= b[31];
                state <= CORNER_CASES;
            end

            CORNER_CASES:
            begin
                
                if ((a_e == 128 && a_m != 0) && (b_e == 128 && b_m != 0)) begin
                    // Both inputs are NaN or -NaN (sign can be either)
                    // Return first input as output
                    z[31] <= a_s;         // sign of a
                    z[30:23] <= 255;      // exponent all ones for NaN
                    z[22] <= 1;           // quiet NaN bit
                    z[21:0] <= a_m[25:3]; // mantissa from first input (or keep as is)
                    state <= READY;

                end else if ((a_e == 128 && a_m != 0)) begin
                    // Only a is NaN or -NaN, return a
                    z[31] <= a_s;
                    z[30:23] <= 255;
                    z[22] <= 1;
                    z[21:0] <= a_m[25:3];
                    state <= READY;

                end else if ((b_e == 128 && b_m != 0)) begin
                    // Only b is NaN or -NaN, return b
                    z[31] <= b_s;
                    z[30:23] <= 255;
                    z[22] <= 1;
                    z[21:0] <= b_m[25:3];
                    state <= READY;
                
                end else if (a_e == 128) begin									//if a is infinity return infinity
                z[31] <= a_s;
                z[30:23] <= 255;
                z[22:0] <= 0;
                
                if ((b_e == 128) && (a_s != b_s)) begin						//if a is infinity and signs don't match return NaN
                    z[31] <= 1;
                    z[30:23] <= 255;
                    z[22] <= 1;
                    z[21:0] <= 0;
                end
                state <= READY;
                
                end else if (b_e == 128) begin									//if b is infinity return infinity
                z[31] <= b_s;
                z[30:23] <= 255;
                z[22:0] <= 0;
                state <= READY;
                
                end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) begin	//if a is zero return b
                z[31] <= a_s & b_s;
                z[30:23] <= b_e[7:0] + 127;
                z[22:0] <= b_m[26:3];
                state <= READY;
                
                end else if (($signed(b_e) == -127) && (b_m == 0)) begin												//if b is zero return a
                z[31] <= a_s;
                z[30:23] <= a_e[7:0] + 127;
                z[22:0] <= a_m[26:3];
                state <= READY;
                end else begin
                //Denormalised Number
                if ($signed(a_e) == -127) begin
                    a_e <= -126;
                end else begin
                    a_m[26] <= 1;
                end
                //Denormalised Number
                if ($signed(b_e) == -127) begin
                    b_e <= -126;
                end else begin
                    b_m[26] <= 1;
                end
                state <= DENORM;
                end
            end

            DENORM:
            begin
                if ($signed(a_e) > $signed(b_e)) begin
                b_e <= b_e + 1;
                b_m <= b_m >> 1;
                b_m[0] <= b_m[0] | b_m[1];
                end else if ($signed(a_e) < $signed(b_e)) begin
                a_e <= a_e + 1;
                a_m <= a_m >> 1;
                a_m[0] <= a_m[0] | a_m[1];
                end else begin
                state <= ADD;
                end
            end

            ADD:
            begin
                z_e <= a_e;
                if (a_s == b_s) begin
                pre_sum <= a_m + b_m;
                z_s <= a_s;
                end else begin
                if (a_m >= b_m) begin
                    pre_sum <= a_m - b_m;
                    z_s <= a_s;
                end else begin
                    pre_sum <= b_m - a_m;
                    z_s <= b_s;
                end
                end
                state <= SET_GRS;
            end

            SET_GRS:
            begin
                if (pre_sum[27]) begin
                z_m <= pre_sum[27:4];
                guard <= pre_sum[3];
                round_bit <= pre_sum[2];
                sticky <= pre_sum[1] | pre_sum[0];
                z_e <= z_e + 1;
                end else begin
                z_m <= pre_sum[26:3];
                guard <= pre_sum[2];
                round_bit <= pre_sum[1];
                sticky <= pre_sum[0];
                end
                state <= NORMALISE_1;
            end

            NORMALISE_1:
            begin
                if (z_m[23] == 0 && $signed(z_e) > -126) begin
                z_e <= z_e - 1;
                z_m <= z_m << 1;
                z_m[0] <= guard;
                guard <= round_bit;
                round_bit <= 0;
                end else begin
                state <= NORMALISE_2;
                end
            end

            NORMALISE_2:
            begin
                if ($signed(z_e) < -126) begin
                z_e <= z_e + 1;
                z_m <= z_m >> 1;
                guard <= z_m[0];
                round_bit <= guard;
                sticky <= sticky | round_bit;
                end else begin
                state <= ROUND;
                end
            end

            ROUND:
            begin
                if (guard && (round_bit | sticky | z_m[0])) begin
                z_m <= z_m + 1;
                if (z_m == 24'hffffff) begin
                    z_e <=z_e + 1;
                end
                end
                state <= PACK;
            end

            PACK:
            begin
                z[22 : 0] <= z_m[22:0];
                z[30 : 23] <= z_e[7:0] + 127;
                z[31] <= z_s;
                if ($signed(z_e) == -126 && z_m[23] == 0) begin
                z[30 : 23] <= 0;
                end
                if ($signed(z_e) == -126 && z_m[23:0] == 24'h0) begin
                z[31] <= 1'b0; 
                end
                //if overflow occurs, return inf
                if ($signed(z_e) > 127) begin
                z[22 : 0] <= 0;
                z[30 : 23] <= 255;
                z[31] <= z_s;
                end
                state <= READY;
            end

            READY:
            begin
                ready        <= 1;
                result     <= z;
                state      <= WAIT;
            end

            endcase
        end
    end

endmodule