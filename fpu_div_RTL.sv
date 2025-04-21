module fpu_div_RTL(
        input  logic          clk,
        input  logic          reset,
        input  logic [31:0]   din1,
        input  logic [31:0]   din2,
        input  logic          valid,
        output logic [31:0]   result,
        output logic          ready
);


   typedef enum logic [3:0]{WAIT      = 4'd0,
            UNPACK        = 4'd1,
            CORNER_CASES = 4'd2,
            NORMALISE_DIN1   = 4'd3,
            NORMALISE_DIN2   = 4'd4,
            SET_SIGN_EXP      = 4'd5,
            DIVISION_0      = 4'd6,
            DIVISION_1      = 4'd7,
            GET_GRS      = 4'd8,
            NORMALISE_1   = 4'd9,
            NORMALISE_2   = 4'd10,
            ROUND         = 4'd11,
            PACK          = 4'd12,
            READY       = 4'd13} states;
			
	states state;

  reg       [31:0] a, b, z;
  reg       [23:0] a_m, b_m, z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [50:0] quotient, divisor, dividend, remainder;
  reg       [5:0] count;

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
        a_m <= a[22 : 0];
        b_m <= b[22 : 0];
        a_e <= a[30 : 23] - 127;
        b_e <= b[30 : 23] - 127;
        a_s <= a[31];
        b_s <= b[31];
        state <= CORNER_CASES;
      end

      CORNER_CASES:
      begin
        //if a is NaN or b is NaN return NaN 
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 1;
          z[21:0] <= 0;
          state <= READY;
          //if a is inf and b is inf return NaN 
        end else if ((a_e == 128) && (b_e == 128)) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 1;
          z[21:0] <= 0;
          state <= READY;
        //if a is inf return inf
        end else if (a_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          state <= READY;
           //if b is zero return NaN
          if ($signed(b_e == -127) && (b_m == 0)) begin
            z[31] <= 1;
            z[30:23] <= 255;
            z[22] <= 1;
            z[21:0] <= 0;
            state <= READY;
          end
        //if b is inf return zero
        end else if (b_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= READY;
        //if a is zero return zero
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= READY;
           //if b is zero return NaN
          if (($signed(b_e) == -127) && (b_m == 0)) begin
            z[31] <= 1;
            z[30:23] <= 255;
            z[22] <= 1;
            z[21:0] <= 0;
            state <= READY;
          end
        //if b is zero return inf
        end else if (($signed(b_e) == -127) && (b_m == 0)) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          state <= READY;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -127) begin
            a_e <= -126;
          end else begin
            a_m[23] <= 1;
          end
          //Denormalised Number
          if ($signed(b_e) == -127) begin
            b_e <= -126;
          end else begin
            b_m[23] <= 1;
          end
          state <= NORMALISE_DIN1;
        end
      end

      NORMALISE_DIN1:
      begin
        if (a_m[23]) begin
          state <= NORMALISE_DIN2;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end
      end

      NORMALISE_DIN2:
      begin
        if (b_m[23]) begin
          state <= SET_SIGN_EXP;
        end else begin
          b_m <= b_m << 1;
          b_e <= b_e - 1;
        end
      end

      SET_SIGN_EXP:
      begin
        z_s <= a_s ^ b_s;
        z_e <= a_e - b_e;
        quotient <= 0;
        remainder <= 0;
        count <= 0;
        dividend <= a_m << 27;
        divisor <= b_m;
        state <= DIVISION_0;
      end

      DIVISION_0:
      begin
        quotient <= quotient << 1;
        remainder <= remainder << 1;
        remainder[0] <= dividend[50];
        dividend <= dividend << 1;
        state <= DIVISION_1;
      end

      DIVISION_1:
      begin
        if (remainder >= divisor) begin
          quotient[0] <= 1;
          remainder <= remainder - divisor;
        end
        if (count == 49) begin
          state <= GET_GRS;
        end else begin
          count <= count + 1;
          state <= DIVISION_0;
        end
      end

      GET_GRS:
      begin
        z_m <= quotient[26:3];
        guard <= quotient[2];
        round_bit <= quotient[1];
        sticky <= quotient[0] | (remainder != 0);
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

