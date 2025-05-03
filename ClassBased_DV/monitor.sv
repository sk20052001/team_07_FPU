import classes_pkg::*;

class monitor;
    transaction tx;
    virtual intf vif;
    mailbox #(transaction) mon2scb;

    event scbrun;

    function new (virtual intf vif, mailbox #(transaction) mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task main();
        forever begin
            wait (vif.ready);
            tx = new();
            tx.din1 = vif.din1;
            tx.din2 = vif.din2;
            tx.op_sel = vif.op_sel;
            tx.ready = vif.ready;
            tx.valid = vif.valid;
            tx.result = vif.result;
            mon2scb.put(tx);
            @(posedge vif.clk);
            -> scbrun;
        end
    endtask
endclass