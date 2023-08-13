// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Monitor
// File:    monitor.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 29-Jul-2023
//
// Description: 
// The monitor class is a crucial part of the verification process in a 
// SystemVerilog testbench. It observes the interface, captures the 
// transactions occurring on the bus, and forwards them to the scoreboard for 
// checking against the expected results. It acts as a listener, making it 
// passive and non-intrusive to the design under test (DUT).
//
// In this particular scenario, the monitor watches the signals on the AHB APB 
// bridge interface, creates transaction objects representing the observed 
// transactions, and sends them to the scoreboard. It operates in an infinite 
// loop, continuously monitoring the interface for new transactions.
//
// The monitor utilizes a clocking block (mon_cb) to sample the interface 
// signals synchronously with the clock. The sampled values are used to create 
// the transaction object, which is then forwarded to the scoreboard via a 
// mailbox.
// -----------------------------------------------------------------------------

class ahb_apb_monitor;

    Transaction tx;      // Transaction handle            
    mailbox #(Transaction) mail2sb;  // Mailbox to the scoreboard

    // Virtual interface reference
    virtual ahb_apb_bfm_if.slave vif;            
    
    function new(mailbox #(Transaction) mail2sb, virtual ahb_apb_bfm_if.slave vif);
        this.mail2sb = mail2sb;
        this.vif = vif;
    endfunction

    // Watch and send transactions to the scoreboard
    task watch;
        tx = new();
        
        // Loop to monitor transactions
        forever begin
            @(vif.mon_cb) begin  // Use the clocking block to sample the interface signals
                wait(vif.mon_cb.Htrans !== 2'b00); // Wait for any transaction to start
                //tx.trans_type = vif.mon_cb.Hwrite ? Transaction.AHB_WRITE : Transaction.AHB_READ;
                tx.Haddr      = vif.mon_cb.Haddr;
                tx.Hwdata     = vif.mon_cb.Hwdata;
                tx.Hwrite     = vif.mon_cb.Hwrite;
                tx.Htrans     = vif.mon_cb.Htrans;
                tx.Paddr      = vif.mon_cb.Paddr;
                tx.Pwdata     = vif.mon_cb.Pwdata;
                tx.Pwrite     = vif.mon_cb.Pwrite;
                tx.Pselx      = vif.mon_cb.Pselx;
                tx.Prdata     = vif.mon_cb.Prdata;
                
                mail2sb.put(tx); // Send the transaction to the scoreboard
            end
        end
    endtask

endclass


