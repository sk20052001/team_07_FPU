'include "transaction.sv"

class generator;
    rand transaction tx;
    mailbox gen_to_driv;
    int tx_count;

    extern function new (mailbox gen_to_driv);
        this.gen_to_driv = gen_to_driv;
    endfunction

    task main();
        $display("Generator started");
        repeat(tx_count) begin
            tx = new();
            assert (tx.roandomize());
            gen_to_driv.put(tx);
        end
        $display("Generator completed")
    endtask

endclass