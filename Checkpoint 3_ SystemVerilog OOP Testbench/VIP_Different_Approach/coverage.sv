// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Coverage Collector
// File:    coverage.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 26-Jul-2023
//
// Description: 
// The SystemVerilog coverage collector class is responsible for gathering 
// coverage information from the transactions it receives.
//
// The coverage collector class has a transaction object and a mailbox 
// 'driv2cor', which is used to receive transactions from the driver. It also 
// uses a virtual interface 'vif' to communicate with the DUV.
//
// The coverage collector uses a covergroup 'cov_cg' to define the coverage 
// points and crosses that it is interested in. The coverage points are 
// trans_type, Htrans, Hsize, and Hburst, which are properties of the 
// transaction. The crosses are combinations of trans_type with the other 
// properties.
//
// The 'execute' task is the main routine of the coverage collector. It 
// retrieves a transaction from the driver using 'driv2cor.get(tx)', and 
// then it displays information about the transaction.
//
// Note: The 'sample_coverage' and 'print_coverage' functions are commented 
// out in the original code. The 'sample_coverage' function would be used to 
// sample the coverage points and crosses defined in 'cov_cg' using the current 
// transaction. The 'print_coverage' function would be used to print a coverage 
// report, showing the percentage of coverage points and crosses that have been 
// hit.
// -----------------------------------------------------------------------------

class coverage_collector;

    Transaction tx;     // Transaction object
    mailbox #(Transaction) driv2cor;   // Mailbox for Generator to Driver
    virtual ahb_apb_bfm_if vif;
    // Coverage groups
    covergroup cov_cg;
        trans_type_cp: coverpoint tx.trans_type {
            bins read  = {Transaction::AHB_READ};
            bins write = {Transaction::AHB_WRITE};
        }
        Htrans_cp: coverpoint tx.Htrans {
            bins non_seq = {2'b00};
            bins idle    = {2'b01};
            bins seq     = {2'b10};
            bins busy    = {2'b11};
        }
        Hsize_cp: coverpoint tx.Hsize {
            bins size_byte     = {3'b000};
            bins size_halfword = {3'b001};
            bins size_word     = {3'b010};
        }
        Hburst_cp: coverpoint tx.Hburst {
            bins single = {3'b000};
            bins incr   = {3'b001};
            bins wrap4  = {3'b010};
            bins incr4  = {3'b011};
        }
        // Cross coverage
        trans_x_htrans: cross trans_type_cp, Htrans_cp;
        trans_x_hsize: cross trans_type_cp, Hsize_cp;
        trans_x_hburst: cross trans_type_cp, Hburst_cp;
    endgroup

    // cov_cg ahb_cg;
    function new(mailbox #(Transaction) driv2cor, virtual ahb_apb_bfm_if vif);
        this.driv2cor = driv2cor;
       cov_cg = new;
        this.vif = vif;
    endfunction

    // Function to sample the coverage
    /* function void sample_coverage();
        cov_cg.sample();
    endfunction

    // Function to print the coverage report
    function void print_coverage();
        $display("Coverage: %0d%%", cov_cg.get_coverage() * 100);
    endfunction */

    // Task to get Transaction from mailbox and sample coverage
    task execute();
        forever begin
            driv2cor.get(tx);
           // sample_coverage();
           $display("tx got", tx);
        end
    endtask
endclass

