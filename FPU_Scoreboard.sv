//=========================================================
// Scoreboard for FPU Project
// Author: Pavani Patibandla
// Description: Compares DUT output with expected result
//=========================================================

`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

class transaction;
  rand bit [31:0] x, y;       // IEEE-754 format input operands
  rand bit [1:0] opcode;      // 00 = add, 01 = sub, 10 = mul, 11 = div
  bit [31:0] result;          // DUT output in IEEE-754 format

  // Optional display function for debug
  function void display(string tag);
    $display("[%s] x --> %f  y --> %f  opcode --> %b  result --> %f",
             tag, $bitstoreal(x), $bitstoreal(y), opcode, $bitstoreal(result));
  endfunction
endclass

class scoreboard;
  mailbox #(transaction) gen2scb;  // Mailbox from generator
  mailbox #(transaction) mon2scb;  // Mailbox from monitor

  function new(mailbox #(transaction) gen2scb, mailbox #(transaction) mon2scb);
    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    transaction gen_trans, mon_trans;
    real expected, actual, in_x, in_y;

    forever begin
      gen2scb.get(gen_trans);  // Get input transaction
      mon2scb.get(mon_trans);  // Get DUT output transaction

      in_x = $bitstoreal(gen_trans.x);
      in_y = $bitstoreal(gen_trans.y);

      // Compute expected output
      case (gen_trans.opcode)
        2'b00: expected = in_x + in_y;
        2'b01: expected = in_x - in_y;
        2'b10: expected = in_x * in_y;
        2'b11: expected = (in_y != 0) ? in_x / in_y : 32'h7fc00000; // NaN for divide by 0
        default: expected = 0.0;
      endcase

      actual = $bitstoreal(mon_trans.result);

      // Compare expected and actual
      if (fabs(expected - actual) > 0.001) begin
        $display("MISMATCH : opcode --> %b x --> %f y -->%f ----> Expected --> %f DUT --> %f",
                 gen_trans.opcode, in_x, in_y, expected, actual);
      end else begin
        $display("MATCH : opcode --> %b x --> %f y --> %f  Result --> %f",
                 gen_trans.opcode, in_x, in_y, actual);
      end
    end
  endtask
endclass

`endif
