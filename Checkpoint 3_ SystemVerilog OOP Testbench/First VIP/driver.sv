// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Driver
// File:    driver.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 26-Jul-2023
//
// Description: 
// The SystemVerilog driver class is responsible for receiving transactions 
// from the generator and driving them into the Design Under Verification (DUV). 
// It communicates with the DUV through a virtual interface 'vif'.
//
// The driver class has transaction handles and several mailboxes: 'gen2driv', 
// 'driv2sb', and 'driv2cor'. The 'gen2driv' mailbox is used to receive 
// transactions from the generator, 'driv2sb' sends transactions to the 
// scoreboard for verification, and 'driv2cor' sends transactions directly 
// to the DUV.
//
// The 'drive' task is the main routine of the driver. It retrieves a 
// transaction from the generator using 'gen2driv.get(tx)', then sends it 
// to the scoreboard and the DUV using 'driv2sb.put(tx)' and 'driv2cor.put(tx)' 
// respectively.
//
// After that, the 'drive' task uses the virtual interface to drive the 
// transaction values to the DUV. It assigns each signal in the DUV with 
// the corresponding value from the transaction. Then it waits for a clock 
// edge before proceeding.
// -----------------------------------------------------------------------------


class driver;

    Transaction tx; // Handle for transactions       

    mailbox #(Transaction) gen2driv; // Generator to Driver mailbox
    mailbox #(Transaction) driv2sb;  // Driver to Scoreboard mailbox
    mailbox #(Transaction) driv2cor; // Driver to DUV (Device Under Verification) mailbox
    virtual ahb_apb_bfm_if.master vif;                 // Virtual interface to DUV

    // Constructor
    function new(mailbox #(Transaction)gen2driv, mailbox #(Transaction)driv2sb, mailbox #(Transaction)driv2cor, virtual ahb_apb_bfm_if.master vif);
        this.gen2driv = gen2driv; // assigning gen2driv 
        this.driv2sb = driv2sb;   // assigning driv2sb
        this.driv2cor = driv2cor; // assigning driv2cor
        this.vif = vif;           // assigning virtual interface
    endfunction

// Task to get packets from generator and drive them into interface
task drive; 
    gen2driv.get(tx);   
    driv2sb.put(tx);   
    driv2cor.put(tx);
    $display("driver tx", tx);
    // Driving the values to the DUV via the virtual interface
    vif.drv_cb.Hwrite <= tx.Hwrite;     
    vif.drv_cb.Htrans <= tx.Htrans;
    vif.drv_cb.Hwdata <= tx.Hwdata;     
    vif.drv_cb.Haddr <= tx.Haddr;
   #10;  // wait for 10 time units
    // vif.drv_cb.Hsize <= tx.Hsize;      
    // vif.drv_cb.Hburst <= tx.Hburst;    
endtask
endclass


