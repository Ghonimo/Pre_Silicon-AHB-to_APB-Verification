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


// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Environment
// File:    environment.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 29-Jul-2023
//
// Description: 
// The environment class is a central part of the verification process in a 
// SystemVerilog testbench. It houses all the main verification components such 
// as the generator, driver, monitor, and scoreboard, and manages the interactions 
// between them. 
// In this particular scenario, it establishes mailboxes for communication, 
// initiates all components, and manages specific test cases. These test cases 
// represent various transactions that the AHB APB bridge should be capable of 
// handling, thus facilitating comprehensive testing and verification of the 
// design under test (DUT).
//
// -----------------------------------------------------------------------------


class environment;
  mailbox #(Transaction) gen2driv;  
  mailbox #(Transaction) driv2sb;  
  mailbox #(Transaction) mail2sb; 
  mailbox #(Transaction) driv2cor;

  generator gen;        
  driver driv;          
  ahb_apb_monitor moni;         
  ahb_apb_scoreboard sb;        
  // coverage_collector cov;
  virtual ahb_apb_bfm_if vif;

  function new(virtual ahb_apb_bfm_if vif);
    this.vif = vif;
  endfunction

  function create();
    gen2driv = new(1);
    driv2sb = new(1);
    mail2sb = new(1);
    driv2cor = new(1);
    gen = new(gen2driv);
    driv = new(gen2driv, driv2sb, driv2cor, vif);
    moni = new(mail2sb, vif);
    sb = new(driv2sb, mail2sb);
    // cov = new(driv2cor, vif);
  endfunction

/*
  task env_read_single_byte_nonseq_single_Htransfer_okay();
    fork
      gen.write_single_halfword_nonseq_single_Htransfer_okay();
      driv.drive();
      moni.watch();
      sb.data_write();

    join_none
  endtask

*/

	// Test Case 2
task env_write_single_halfword_nonseq_single_Htransfer_okay();
  fork
    gen.write_single_halfword_nonseq_single_Htransfer_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 3
task env_read_single_halfword_nonseq_single_Htransfer_okay();
  fork
    gen.read_single_halfword_nonseq_single_Htransfer_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 4
task env_write_single_byte_nonseq_single_Htransfer_error();
  fork
    gen.write_single_byte_nonseq_single_Htransfer_error();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 5
task env_read_incr_halfword_nonseq_incr_Hburst_okay();
  fork
    gen.read_incr_halfword_nonseq_incr_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 6
task env_write_incr_word_nonseq_incr_Hburst_okay();
  fork
    gen.write_incr_word_nonseq_incr_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 7
task env_read_wrap4_byte_nonseq_wrap4_Hburst_okay();
  fork
    gen.read_wrap4_byte_nonseq_wrap4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 8
task env_write_wrap4_halfword_nonseq_wrap4_Hburst_okay();
  fork
    gen.write_wrap4_halfword_nonseq_wrap4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 9
task env_read_wrap4_word_nonseq_wrap4_Hburst_okay();
  fork
    gen.read_wrap4_word_nonseq_wrap4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 10
task env_write_incr4_byte_nonseq_incr4_Hburst_okay();
  fork
    gen.write_incr4_byte_nonseq_incr4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 11
task env_read_incr4_halfword_nonseq_incr4_Hburst_okay();
  fork
    gen.read_incr4_halfword_nonseq_incr4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 12
task env_write_incr4_word_nonseq_incr4_Hburst_okay();
  fork
    gen.write_incr4_word_nonseq_incr4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 13
task env_read_wrap8_byte_nonseq_wrap8_Hburst_okay();
  fork
    gen.read_wrap8_byte_nonseq_wrap8_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 14
task env_write_wrap8_halfword_nonseq_wrap8_Hburst_okay();
  fork
    gen.write_wrap8_halfword_nonseq_wrap8_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 15
task env_read_wrap8_word_nonseq_wrap8_Hburst_okay();
  fork
    gen.read_wrap8_word_nonseq_wrap8_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 16
task env_write_incr8_byte_nonseq_incr8_Hburst_okay();
$display("in env");
  fork
    gen.write_incr8_byte_nonseq_incr8_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 17
task env_read_incr8_halfword_nonseq_incr8_Hburst_okay();
  fork
    gen.read_incr8_halfword_nonseq_incr8_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 18
task env_write_incr8_word_nonseq_incr8_Hburst_okay();
  fork
    gen.write_incr8_word_nonseq_incr8_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 19
task env_read_single_byte_seq_single_Htransfer_okay();
  fork
    gen.read_single_byte_seq_single_Htransfer_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 20
task env_write_single_halfword_seq_single_Htransfer_okay();
  fork
    gen.write_single_halfword_seq_single_Htransfer_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 21
task env_read_single_word_seq_single_Htransfer_okay();
  fork
    gen.read_single_word_seq_single_Htransfer_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 22
task env_write_single_byte_seq_single_Htransfer_error();
  fork
    gen.write_single_byte_seq_single_Htransfer_error();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 23
task env_read_incr_halfword_seq_incr_Hburst_okay();
  fork
    gen.read_incr_halfword_seq_incr_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 24
task env_write_incr_word_seq_incr_Hburst_okay();
  fork
    gen.write_incr_word_seq_incr_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 25
task env_read_wrap4_byte_seq_wrap4_Hburst_okay();
  fork
    gen.read_wrap4_byte_seq_wrap4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 26
task env_write_wrap4_halfword_seq_wrap4_Hburst_okay();
  fork
    gen.write_wrap4_halfword_seq_wrap4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 27
task env_read_wrap4_word_seq_wrap4_Hburst_okay();
  fork
    gen.read_wrap4_word_seq_wrap4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 28
task env_write_incr4_byte_seq_incr4_Hburst_okay();
  fork
    gen.write_incr4_byte_seq_incr4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 29
task env_read_incr4_halfword_seq_incr4_Hburst_okay();
  fork
    gen.read_incr4_halfword_seq_incr4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 30
task env_write_incr4_word_seq_incr4_Hburst_okay();
  fork
    gen.write_incr4_word_seq_incr4_Hburst_okay();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 31
task env_read_single_byte_nonseq_single_Htransfer_reset();
  fork
    gen.read_single_byte_nonseq_single_Htransfer_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 32
task env_write_single_halfword_nonseq_single_Htransfer_reset();
  fork
    gen.write_single_halfword_nonseq_single_Htransfer_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 33
task env_read_single_word_nonseq_single_Htransfer_reset();
  fork
    gen.read_single_word_nonseq_single_Htransfer_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

//here
// Test Case 34
task env_write_incr_byte_nonseq_incr_Hburst_reset();
  fork
    gen.write_incr_byte_nonseq_incr_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 35
task env_read_incr_halfword_nonseq_incr_Hburst_reset();
  fork
    gen.read_incr_halfword_nonseq_incr_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 36
task env_write_incr_word_nonseq_incr_Hburst_reset();
  fork
    gen.write_incr_word_nonseq_incr_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 37
task env_read_wrap4_byte_nonseq_wrap4_Hburst_reset();
  fork
    gen.read_wrap4_byte_nonseq_wrap4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 38
task env_write_wrap4_halfword_nonseq_wrap4_Hburst_reset();
  fork
    gen.write_wrap4_halfword_nonseq_wrap4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 39
task env_read_wrap4_word_nonseq_wrap4_Hburst_reset();
  fork
    gen.read_wrap4_word_nonseq_wrap4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 40
task env_write_incr4_byte_nonseq_incr4_Hburst_reset();
  fork
    gen.write_incr4_byte_nonseq_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 41
task env_read_incr4_halfword_nonseq_incr4_Hburst_reset();
  fork
    gen.read_incr4_halfword_nonseq_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 42
task env_write_incr4_word_nonseq_incr4_Hburst_reset();
  fork
    gen.write_incr4_word_nonseq_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 43
task env_read_wrap8_byte_nonseq_wrap8_Hburst_reset();
  fork
    gen.read_wrap8_byte_nonseq_wrap8_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 44
task env_write_wrap8_halfword_nonseq_wrap8_Hburst_reset();
  fork
    gen.write_wrap8_halfword_nonseq_wrap8_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();

  join_none
endtask

// Test Case 45
task env_read_wrap8_word_nonseq_wrap8_Hburst_reset();
  fork
    gen.read_wrap8_word_nonseq_wrap8_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();

  join_none
endtask

// Test Case 46
task env_write_incr8_byte_nonseq_incr8_Hburst_reset();
  fork
    gen.write_incr8_byte_nonseq_incr8_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 47
task env_read_incr8_halfword_nonseq_incr8_Hburst_reset();
  fork
    gen.read_incr8_halfword_nonseq_incr8_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 48
task env_write_incr8_word_nonseq_incr8_Hburst_reset();
  fork
    gen.write_incr8_word_nonseq_incr8_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 49
task env_read_single_byte_seq_single_Htransfer_reset();
  fork
    gen.read_single_byte_seq_single_Htransfer_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 50
task env_write_single_halfword_seq_single_Htransfer_reset();
  fork
    gen.write_single_halfword_seq_single_Htransfer_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 51
task env_read_single_word_seq_single_Htransfer_reset();
  fork
    gen.read_single_word_seq_single_Htransfer_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 52
task env_write_single_byte_seq_single_Htransfer_error_reset();
  fork
    gen.write_single_byte_seq_single_Htransfer_error_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 53
task env_read_incr_halfword_seq_incr_Hburst_reset();
  fork
    gen.read_incr_halfword_seq_incr_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 54
task env_write_incr_word_seq_incr_Hburst_reset();
  fork
    gen.write_incr_word_seq_incr_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 55
task env_read_wrap4_byte_seq_wrap4_Hburst_reset();
  fork
    gen.read_wrap4_byte_seq_wrap4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 56
task env_write_wrap4_halfword_seq_wrap4_Hburst_reset();
  fork
    gen.write_wrap4_halfword_seq_wrap4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 57
task env_read_wrap4_word_seq_wrap4_Hburst_reset();
  fork
    gen.read_wrap4_word_seq_wrap4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 58
task env_write_incr4_byte_seq_incr4_Hburst_reset();
  fork
    gen.write_incr4_byte_seq_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 59
task env_read_incr4_halfword_seq_incr4_Hburst_reset();
  fork
    gen.read_incr4_halfword_seq_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_read();
  join_none
endtask

// Test Case 60
task env_write_incr4_word_seq_incr4_Hburst_reset();
  fork
    gen.write_incr4_word_seq_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 61
task env_write_incr4_word_idle_incr4_Hburst_reset();
  fork
    gen.write_incr4_word_idle_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 62
task env_write_incr4_word_busy_incr4_Hburst_reset();
  fork
    gen.write_incr4_word_busy_incr4_Hburst_reset();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

// Test Case 63
task env_write_single_byte_idle_single_Htransfer_error();
  fork
    gen.write_single_byte_idle_single_Htransfer_error();
    driv.drive();
    moni.watch();
    sb.data_write();
  join_none
endtask

endclass

// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Generator
// File:    generator.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 29-Jul-2023
//
// Description: 
// The SystemVerilog generator class generates transactions of different 
// types and sends them to the driver for execution. In this module, there 
// are several test cases defined as tasks, each representing a unique 
// transaction.
//
// The class generator has a transaction handle 'tx' and a mailbox 'gen2driv'
// that is used to send transactions to the driver. It also has a virtual
// interface 'vif' to communicate with the DUT.
//
// The 'read_single_byte_nonseq_single_Htransfer_okay' task, for instance, 
// creates a read transaction, with each field of the transaction being 
// assigned a value according to the requirements of the test case. Once the 
// transaction is ready, it is sent to the driver using the 'gen2driv.put(tx);' 
// command.
//
// Similar operations are performed in other test case tasks. Each task 
// defines a different type of transaction, with various values assigned to 
// the fields of the transaction.
//
// The generator class also samples each transaction for coverage using the 
// 'tx.cov_cg.sample();' command. This helps to ensure that all types of 
// transactions are generated and executed, thus ensuring complete functional 
// coverage.
// -----------------------------------------------------------------------------

class generator;

    Transaction tx;   // Handle for Htransactions          
    mailbox #(Transaction) gen2driv;  // Generator to Driver mailbox

    logic [31:0] temp_Haddr; // temporary variable  
    logic [11:0] Haddr_array [6] =  {8'h11, 8'h22, 12'h384, 12'hFD2, 12'h64, 12'hDAC}; // Haddress array
    logic [11:0] Haddr_Hburst[2] = {12'hab , 12'hde}; // Hburst
    int i =0;

    function new(mailbox #(Transaction)gen2driv);
        this.gen2driv   = gen2driv;
    endfunction
    
    // Test Case 2
    task write_single_halfword_nonseq_single_Htransfer_okay();
        $display($time, "   write_single_halfword_nonseq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1; // Write operation
    tx.update_trans_type();
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
    tx.Penable = 1;
        tx.Hwdata = $urandom(); // Generate random data for write
    tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask


    // Test Case 3
    task read_single_halfword_nonseq_single_Htransfer_okay();
        $display($time, "   read_single_word_nonseq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
    tx.Penable = 1;
    tx.Pwrite = 0;
    tx.cov_cg.sample(); // After transaction is fully defined
      tx.update_trans_type();
        gen2driv.put(tx);
    endtask

    // Test Case 4
    task write_single_byte_nonseq_single_Htransfer_error();
        $display($time, "   write_single_byte_nonseq_single_Htransfer_error task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hresp = 1;
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
  	tx.update_trans_type();
        gen2driv.put(tx);
    endtask

    // Test Case 5
    task read_incr_halfword_nonseq_incr_Hburst_okay();
        $display($time, "   read_incr_halfword_nonseq_incr_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b10;
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 6
    task write_incr_word_nonseq_incr_Hburst_okay();
        $display($time, "   write_incr_word_nonseq_incr_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b10;
	tx.Penable = 1;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 7
    task read_wrap4_byte_nonseq_wrap4_Hburst_okay();
        $display($time, "   read_wrap4_byte_nonseq_wrap4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b10;
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 8
    task write_wrap4_halfword_nonseq_wrap4_Hburst_okay();
        $display($time, "   write_wrap4_halfword_nonseq_wrap4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 9
    task read_wrap4_word_nonseq_wrap4_Hburst_okay();
        $display($time, "   read_wrap4_word_nonseq_wrap4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b10;
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 10
    task write_incr4_byte_nonseq_incr4_Hburst_okay();
        $display($time, "   write_incr4_byte_nonseq_incr4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 11
    task read_incr4_halfword_nonseq_incr4_Hburst_okay();
        $display($time, "   read_incr4_halfword_nonseq_incr4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b10;
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 12
    task write_incr4_word_nonseq_incr4_Hburst_okay();
        $display($time, "   write_incr4_word_nonseq_incr4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 13
    task read_wrap8_byte_nonseq_wrap8_Hburst_okay();
        $display($time, "   read_wrap8_byte_nonseq_wrap8_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b100;
        tx.Htrans = 2'b10;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 14
    task write_wrap8_halfword_nonseq_wrap8_Hburst_okay();
        $display($time, "   write_wrap8_halfword_nonseq_wrap8_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b100;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 15
    task read_wrap8_word_nonseq_wrap8_Hburst_okay();
        $display($time, "   read_wrap8_word_nonseq_wrap8_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b100;
        tx.Htrans = 2'b10;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 16
    task write_incr8_byte_nonseq_incr8_Hburst_okay();
        $display($time, "   write_incr8_byte_nonseq_incr8_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b101;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 17
    task read_incr8_halfword_nonseq_incr8_Hburst_okay();
        $display($time, "   read_incr8_halfword_nonseq_incr8_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b101;
        tx.Htrans = 2'b10;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 18
    task write_incr8_word_nonseq_incr8_Hburst_okay();
        $display($time, "   write_incr8_word_nonseq_incr8_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b101;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 19
    task read_single_byte_seq_single_Htransfer_okay();
        $display($time, "   read_single_byte_seq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 20
    task write_single_halfword_seq_single_Htransfer_okay();
        $display($time, "   write_single_halfword_seq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 21
    task read_single_word_seq_single_Htransfer_okay();
        $display($time, "   read_single_word_seq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 22
    task write_single_byte_seq_single_Htransfer_error();
        $display($time, "   write_single_byte_seq_single_Htransfer_error task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hresp = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 23
    task read_incr_halfword_seq_incr_Hburst_okay();
        $display($time, "   read_incr_halfword_seq_incr_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 24
    task write_incr_word_seq_incr_Hburst_okay();
        $display($time, "   write_incr_word_seq_incr_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 25
    task read_wrap4_byte_seq_wrap4_Hburst_okay();

        $display($time, "   read_wrap4_byte_seq_wrap4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 26
    task write_wrap4_halfword_seq_wrap4_Hburst_okay();
        $display($time, "   write_wrap4_halfword_seq_wrap4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 27
    task read_wrap4_word_seq_wrap4_Hburst_okay();
        $display($time, "   read_wrap4_word_seq_wrap4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 28
    task write_incr4_byte_seq_incr4_Hburst_okay();
        $display($time, "   write_incr4_byte_seq_incr4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 29
    task read_incr4_halfword_seq_incr4_Hburst_okay();
        $display($time, "   read_incr4_halfword_seq_incr4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 30
    task write_incr4_word_seq_incr4_Hburst_okay();
        $display($time, "   write_incr4_word_seq_incr4_Hburst_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 31
    task read_single_byte_nonseq_single_Htransfer_reset();
        $display($time, "   read_single_byte_nonseq_single_Htransfer_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 32
    task write_single_halfword_nonseq_single_Htransfer_reset();
        $display($time, "   write_single_halfword_nonseq_single_Htransfer_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 33
    task read_single_word_nonseq_single_Htransfer_reset();
        $display($time, "   read_single_word_nonseq_single_Htransfer_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 34
    task write_incr_byte_nonseq_incr_Hburst_reset();
        $display($time, "   write_incr_byte_nonseq_incr_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 35
    task read_incr_halfword_nonseq_incr_Hburst_reset();
        $display($time, "   read_incr_halfword_nonseq_incr_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 36
    task write_incr_word_nonseq_incr_Hburst_reset();
        $display($time, "   write_incr_word_nonseq_incr_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 37
    task read_wrap4_byte_nonseq_wrap4_Hburst_reset();
        $display($time, "   read_wrap4_byte_nonseq_wrap4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 38
    task write_wrap4_halfword_nonseq_wrap4_Hburst_reset();
        $display($time, "   write_wrap4_halfword_nonseq_wrap4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 39
    task read_wrap4_word_nonseq_wrap4_Hburst_reset();
        $display($time, "   read_wrap4_word_nonseq_wrap4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 40
    task write_incr4_byte_nonseq_incr4_Hburst_reset();
        $display($time, "   write_incr4_byte_nonseq_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 41
    task read_incr4_halfword_nonseq_incr4_Hburst_reset();
        $display($time, "   read_incr4_halfword_nonseq_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 42
    task write_incr4_word_nonseq_incr4_Hburst_reset();
        $display($time, "   write_incr4_word_nonseq_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 43
    task read_wrap8_byte_nonseq_wrap8_Hburst_reset();
        $display($time, "   read_wrap8_byte_nonseq_wrap8_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b100;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 44
    task write_wrap8_halfword_nonseq_wrap8_Hburst_reset();
        $display($time, "   write_wrap8_halfword_nonseq_wrap8_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
  	tx.trans_type = Transaction::AHB_WRITE; // Set transaction type as WRITE

        tx.Hsize = 3'b001;
        tx.Hburst = 3'b100;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 45
    task read_wrap8_word_nonseq_wrap8_Hburst_reset();
        $display($time, "   read_wrap8_word_nonseq_wrap8_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b100;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 46
    task write_incr8_byte_nonseq_incr8_Hburst_reset();
        $display($time, "   write_incr8_byte_nonseq_incr8_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b101;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 47
    task read_incr8_halfword_nonseq_incr8_Hburst_reset();
        $display($time, "   read_incr8_halfword_nonseq_incr8_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b101;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 48
    task write_incr8_word_nonseq_incr8_Hburst_reset();
        $display($time, "   write_incr8_word_nonseq_incr8_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b101;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 49
    task read_single_byte_seq_single_Htransfer_reset();
        $display($time, "   read_single_byte_seq_single_Htransfer_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 50
    task write_single_halfword_seq_single_Htransfer_reset();
        $display($time, "   write_single_halfword_seq_single_Htransfer_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 51
    task read_single_word_seq_single_Htransfer_reset();
        $display($time, "   read_single_word_seq_single_Htransfer_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 52
    task write_single_byte_seq_single_Htransfer_error_reset();
        $display($time, "   write_single_byte_seq_single_Htransfer_error_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;

        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hresp = 1;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 53
    task read_incr_halfword_seq_incr_Hburst_reset();
        $display($time, "   read_incr_halfword_seq_incr_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 54
    task write_incr_word_seq_incr_Hburst_reset();
        $display($time, "   write_incr_word_seq_incr_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b001;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 55
    task read_wrap4_byte_seq_wrap4_Hburst_reset();
        $display($time, "   read_wrap4_byte_seq_wrap4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 56
    task write_wrap4_halfword_seq_wrap4_Hburst_reset();
        $display($time, "   write_wrap4_halfword_seq_wrap4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 57
    task read_wrap4_word_seq_wrap4_Hburst_reset();
        $display($time, "   read_wrap4_word_seq_wrap4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b010;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 58
    task write_incr4_byte_seq_incr4_Hburst_reset();
        $display($time, "   write_incr4_byte_seq_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 59
    task read_incr4_halfword_seq_incr4_Hburst_reset();
        $display($time, "   read_incr4_halfword_seq_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 60
    task write_incr4_word_seq_incr4_Hburst_reset();
        $display($time, "   write_incr4_word_seq_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b11;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 61
    task write_incr4_word_idle_incr4_Hburst_reset();
        $display($time, "   write_incr4_word_idle_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b00;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 62
    task write_incr4_word_busy_incr4_Hburst_reset();
        $display($time, "   write_incr4_word_busy_incr4_Hburst_reset task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b011;
        tx.Htrans = 2'b01;
        tx.Hwdata = $urandom();
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 63
    task write_single_byte_idle_single_Htransfer_error();
        $display($time, "   write_single_byte_idle_single_Htransfer_error task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b00;
        tx.Hwdata = $urandom();
        tx.hresp = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

endclass
// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Interface
// File:    interface.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 25-Jul-2023
//
// Description: 
// The SystemVerilog interface encapsulates the signals of a specific protocol 
// (in this case AHB-APB Bridge protocol) and provides a single handle to 
// manage these signals. It also helps in establishing communication between 
// different verification components, like driver, monitor, and DUT.
//
// In this module, there are two clocking blocks defined for the driver and 
// monitor. Clocking blocks allow precise control over when signals are driven 
// or sampled, which is crucial in design and verification.
//
// The 'drv_cb' block is used by the driver to drive signals to the DUT. On the 
// other hand, the 'mon_cb' block is used by the monitor to sample signals from 
// the DUT. This way, we ensure that both the driver and monitor are operating 
// synchronously with the clock.
//
// The modports 'master' and 'slave' are defined to represent the views of the 
// driver and monitor, respectively. The driver (master) drives the signals, 
// whereas the monitor (slave) samples the signals.
// -----------------------------------------------------------------------------


interface ahb_apb_bfm_if(input wire clk, resetn);

  // AHB signals
  logic Hwrite;     // AHB write signal
  logic Hreadyin;   // AHB ready input signal
  logic [1:0] Htrans; // AHB transfer type encoding
  logic [31:0] Hwdata; // AHB write data
  logic [31:0] Haddr;  // AHB address
  logic [31:0] Hrdata; // AHB read data
  logic [1:0] Hresp;   // AHB response
  logic Hreadyout;     // AHB ready output signal

  // APB signals
  wire Penable;       // APB enable signal
  wire Pwrite;        // APB write signal
  wire [2:0] Pselx;   // APB select signals
  wire [31:0] Pwdata; // APB write data
  wire [31:0] Paddr;  // APB address
  wire [31:0] Prdata; // APB read data

  // Clocking block for driver
  // This block defines the timing of the signals when they are driven by the driver
  clocking drv_cb @(posedge clk);
    default input #1ns output #1ns; // Default skew for input and output signals
    output Hwrite, Hreadyin, Htrans, Hwdata, Haddr; // AHB signals driven by the driver
    output Penable, Pwrite, Pselx, Pwdata, Paddr;   // APB signals driven by the driver
  endclocking

  // Clocking block for monitor
  // This block defines the timing of the signals when they are monitored
  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns; // Default skew for input and output signals
    input Hwrite, Hreadyin, Htrans, Hwdata, Haddr, Hrdata, Hresp, Hreadyout; // AHB signals monitored
    input Penable, Pwrite, Pselx, Pwdata, Paddr, Prdata; // APB signals monitored
  endclocking

  // Modports
  // These define the interface for the driver and monitor, respectively
  modport master(clocking drv_cb, input clk, resetn); // driver
  modport slave(clocking mon_cb, input clk, resetn); // monitor

endinterface

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


// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Scoreboard
// File:    scoreboard.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 26-Jul-2023
//
// Description: 
// The Scoreboard class plays a crucial role in verification process as it 
// validates the correctness of the design. It contains a memory model that
// mimics the behaviour of the design under test (DUT).
//
// The Scoreboard receives transactions from both the driver and the monitor, 
// allowing it to compare the expected and actual responses. This class has 
// methods to handle both data write and read operations. For a write operation, 
// it verifies that the data has been correctly written into the memory model. 
// For a read operation, it checks if the data read from the DUT matches with 
// the data stored in the memory model. Any discrepancy in data would result 
// in an assertion error, flagging a failure in the verification process.
// -----------------------------------------------------------------------------

class ahb_apb_scoreboard;

    Transaction tx1, tx2;
    mailbox #(Transaction) drv2sb;
    mailbox #(Transaction) mail2sb;
    logic [19:0] temp_addr; // We will only track the least significant 20 bits

    bit [31:0] mem_tb [2**20]; // memory of 2^20 locations each of 32 bits

    function new(mailbox #(Transaction) drv2sb, mailbox #(Transaction) mail2sb);
        this.drv2sb = drv2sb;
        this.mail2sb = mail2sb;
    endfunction

    task data_write();

        $display("Scoreboard check...");

        // Receive data from driver and monitor
        drv2sb.get(tx1);
        mail2sb.get(tx2);

        temp_addr = tx1.Haddr[19:0];

        // Write data to the memory model
        mem_tb[temp_addr] = tx1.Hwdata;

        $display("Input Address: %h", temp_addr);
        $display("Input Write Data: %h", tx1.Hwdata);
        $display("Data Stored: %h", mem_tb[temp_addr]);

        // Assert that the data was written correctly
            assert (tx1.Hwdata == mem_tb[temp_addr])
            else $error("Data failed to write");

        $display("");
	#10;
    endtask

    task data_read();

        $display("Scoreboard read");

        drv2sb.get(tx1);
        mail2sb.get(tx2);

        temp_addr = tx1.Haddr[19:0];

        $display("Temp address = %h", temp_addr);
        $display("Read data from DUT %h", tx2.Prdata); // data from monitor/DUT
        $display("Data from TB memory %h", mem_tb[temp_addr]);

        // Assert that the data read matches the data in the memory model
            assert (tx2.Prdata == mem_tb[temp_addr])
            else $error("Data reading failed");

        $display("");
	#10;
    endtask

endclass


// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Test
// File:    test.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 27-Jul-2023
//
// Description: 
// The Test class forms the backbone of any testbench in a SystemVerilog 
// verification environment. This class integrates all the test cases defined 
// in the environment and orchestrates their execution over the course of a 
// simulation run.
//
// In this particular scenario, the Test class creates an instance of the 
// environment class, providing it with the handle to the interface object. 
// The 'run' task of this class starts the environment and performs the test 
// sequences repeatedly over multiple clock cycles. 
// -----------------------------------------------------------------------------

class test;
  environment env;  // creates handle

  function new(virtual ahb_apb_bfm_if i);
    env = new(i); 
  endfunction : new
  
  task run();
    
    $display("in test");   
    env.create();  

    repeat(50)        
    begin 
      
      $display("in test repeat");

      env.env_write_single_halfword_nonseq_single_Htransfer_okay();
      #5;
      env.env_read_single_halfword_nonseq_single_Htransfer_okay();
      #5;
      env.env_write_single_byte_nonseq_single_Htransfer_error();
      #5;
      env.env_read_incr_halfword_nonseq_incr_Hburst_okay();
      #5;
      env.env_write_incr_word_nonseq_incr_Hburst_okay();
      #5;
      env.env_read_wrap4_byte_nonseq_wrap4_Hburst_okay();
      #5;
      env.env_write_wrap4_halfword_nonseq_wrap4_Hburst_okay();
      #5;
      env.env_read_wrap4_word_nonseq_wrap4_Hburst_okay();
      #5;
      env.env_write_incr4_byte_nonseq_incr4_Hburst_okay();
      #5;
      env.env_read_incr4_halfword_nonseq_incr4_Hburst_okay();
      #5;
      env.env_write_incr4_word_nonseq_incr4_Hburst_okay();
      #5;
      env.env_read_wrap8_byte_nonseq_wrap8_Hburst_okay();
      #5;
      env.env_write_wrap8_halfword_nonseq_wrap8_Hburst_okay();
      #5;
      env.env_read_wrap8_word_nonseq_wrap8_Hburst_okay();
      #5;
      env.env_write_incr8_byte_nonseq_incr8_Hburst_okay();
      #5;
      env.env_read_incr8_halfword_nonseq_incr8_Hburst_okay();
      #5;
      env.env_write_incr8_word_nonseq_incr8_Hburst_okay();
      #5;
      env.env_read_single_byte_seq_single_Htransfer_okay();
      #5;
      env.env_write_single_halfword_seq_single_Htransfer_okay();
      #5;
      env.env_read_single_word_seq_single_Htransfer_okay();
      #5;
      env.env_write_single_byte_seq_single_Htransfer_error();
      #5;
      env.env_read_incr_halfword_seq_incr_Hburst_okay();
      #5;
      env.env_write_incr_word_seq_incr_Hburst_okay();
      #5;
      env.env_read_wrap4_byte_seq_wrap4_Hburst_okay();
      #5;
      env.env_write_wrap4_halfword_seq_wrap4_Hburst_okay();
      #5;
      env.env_read_wrap4_word_seq_wrap4_Hburst_okay();
      #5;
      env.env_write_incr4_byte_seq_incr4_Hburst_okay();
      #5;
      env.env_read_incr4_halfword_seq_incr4_Hburst_okay();
      #5;
      env.env_write_incr4_word_seq_incr4_Hburst_okay();
      #5;
      env.env_read_single_byte_nonseq_single_Htransfer_reset();
      #5;
      env.env_write_single_halfword_nonseq_single_Htransfer_reset();
      #5;
      env.env_read_single_word_nonseq_single_Htransfer_reset();
      #5;
      env.env_write_incr_byte_nonseq_incr_Hburst_reset();
      #5;
      env.env_read_incr_halfword_nonseq_incr_Hburst_reset();
      #5;
      env.env_write_incr_word_nonseq_incr_Hburst_reset();
      #5;
      env.env_read_wrap4_byte_nonseq_wrap4_Hburst_reset();
      #5;
      env.env_write_wrap4_halfword_nonseq_wrap4_Hburst_reset();
      #5;
      env.env_read_wrap4_word_nonseq_wrap4_Hburst_reset();
      #5;
      env.env_write_incr4_byte_nonseq_incr4_Hburst_reset();
      #5;
      env.env_read_incr4_halfword_nonseq_incr4_Hburst_reset();
      #5;
      env.env_write_incr4_word_nonseq_incr4_Hburst_reset();
      #5;
      env.env_write_incr4_word_idle_incr4_Hburst_reset();
      #5;
      env.env_write_incr4_word_busy_incr4_Hburst_reset();
      #5;
      env.env_write_single_byte_idle_single_Htransfer_error();
      #5;
    
    end
  endtask
endclass

// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Top-level Module
// File:    top.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 28-Jul-2023
//
// Description: 
// The top-level module of the testbench, ahb_apb_top, integrates all the 
// components of the testbench and connects them with the DUT (Device Under 
// Verification). The DUT is an AHB to APB bridge, and its module name is 
// 'Bridge_Top'.
//
// The top module includes several files:
// 1. transactions.sv - defines the transaction class
// 2. generator.sv - defines the generator class
// 3. interface.sv - defines the interface class
// 4. driver.sv - defines the driver class
// 5. monitor.sv - defines the monitor class
// 6. scoreboard.sv - defines the scoreboard class
// 7. coverage.sv - defines the coverage collector class
// 8. environment.sv - defines the environment class
// 9. test.sv - defines the test class
// 10. bridge_top.v - this is presumably the Verilog source code for the DUT
//
// The top module also generates a clock signal 'clk' with a period of 10 ns 
// (half period of 5 ns). The reset signal 'reset' is initialized to 0 and then 
// set to 1 after 10 time units.
//
// The test class is instantiated as 'test_h'. The run method of the test 
// class is called to start the test.
//
// The simulation is stopped after 100000 time units using the '$stop' 
// system task.
//
// The DUT is instantiated as 'dut' and connected to the testbench using an 
// instance of the ahb_apb_bfm_if interface named 'bfm'. This interface 
// instance is used to drive signals into the DUT and monitor signals coming 
// from the DUT.
// -----------------------------------------------------------------------------


`include "transactions.sv"
`include "generator.sv"
`include "interface.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "environment.sv"
`include "test.sv"  
`include "bridge_top.v"  

module ahb_apb_top;

  logic clk, reset;

  // Generates clk with a time period of 5 ns
  always
  begin
    forever begin
      #5 clk = ~clk;
    end
  end

 

  ahb_apb_bfm_if bfm(clk, reset); // Connect clock and reset


  // Connecting DUT signals with signals present on the interface
// Connecting DUT signals with signals present on the interface
Bridge_Top dut(
    .Hclk(bfm.clk),
    .Hresetn(bfm.resetn),
    .Hwrite(bfm.Hwrite),
    .Hreadyin(bfm.Hreadyin),
    .Htrans(bfm.Htrans),
    .Hwdata(bfm.Hwdata),
    .Haddr(bfm.Haddr),
    .Hrdata(bfm.Hrdata),
    .Hresp(bfm.Hresp),
    .Hreadyout(bfm.Hreadyout),
    .Prdata(bfm.Prdata),
    .Pwdata(bfm.Pwdata),
    .Paddr(bfm.Paddr),
    .Pselx(bfm.Pselx),
    .Pwrite(bfm.Pwrite),
    .Penable(bfm.Penable)
);


  // test ahb_apb_test(bfm); // -> not initialized
    test test_h;
    Transaction trans;
  initial begin
    $display("in top");
    trans = new();
    trans.cov_cg.sample();  // -> to get the coverage
	test_h = new(bfm);
	test_h.run();

	
  end

 // Initialize clk and reset
  initial begin
    clk = 1;
    reset = 0;
    #10
    reset = 1;
	

    #100000;
    $stop; // Stops simulation
  end

endmodule


// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Transaction
// File:    transactions.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 25-Jul-2023
//
// Description: 
// The Transaction class defines the characteristics and behavior of a 
// transaction that can occur in the AHB APB Bridge. Each transaction contains 
// details such as the address, data, transaction type, and other properties 
// required for AHB and APB protocols. A set of constraints is defined to 
// ensure valid transactions are generated.
// 
// This class also features methods to update transaction type based on whether 
// a read or write operation is performed, print the details of the transaction, 
// and define a covergroup for coverage collection. The coverage is measured 
// for various operations, sizes, and burst types which ensures comprehensive 
// verification.
// -----------------------------------------------------------------------------


class Transaction;

  typedef enum {AHB_READ, AHB_WRITE} trans_type_e;
  trans_type_e trans_type;

  randc bit [31:0] Haddr;
  randc bit [31:0] Hwdata;
  randc bit Hwrite;
  randc bit [1:0] Htrans;
  randc bit [2:0] Hsize;
  randc bit [2:0] Hburst;
  randc bit [31:0] Paddr;
  randc bit [31:0] Pwdata;
  randc bit Pwrite;
  randc bit [2:0] Pselx;
  randc bit hresp;	// may remove later
  randc bit hreset;  // Reset signal

  randc bit Penable;  // Added this line
  randc bit [31:0] Prdata; //added this



  constraint address {
    Haddr[31:12] == 'b0;
  }
  constraint size_data {Hsize inside {0,1,2};}
  constraint burst_data {Hburst inside {0,1,2};}

covergroup cov_cg;   // -> no @(Htrans...) not events
 	   Hwrite_cp: coverpoint Hwrite {
      	  bins read  = {1'b0};
      	  bins write = {1'b1};
        }
        Htrans_cp: coverpoint Htrans {
            bins non_seq = {2'b10};
            bins idle    = {2'b00};
            bins seq     = {2'b11};
            //bins busy    = {2'b01};
        }
        Hsize_cp: coverpoint Hsize {
            bins size_byte     = {3'b000};
            bins size_halfword = {3'b001};
            bins size_word     = {3'b010};
        }
        Hburst_cp: coverpoint Hburst {
            bins single = {3'b000};
            bins incr   = {3'b001};
            bins wrap4  = {3'b010};
            bins incr4  = {3'b011};
        }
        // Cross coverage
    Hwrite_x_htrans: cross Hwrite_cp, Htrans_cp;
    Hwrite_x_hsize: cross Hwrite_cp, Hsize_cp;
    Hwrite_x_hburst: cross Hwrite_cp, Hburst_cp;
    endgroup

  function new();
    cov_cg = new;
  endfunction

  function void update_trans_type();
    if (Hwrite == 1) 
      trans_type = Transaction::AHB_WRITE;
    else
      trans_type = Transaction::AHB_READ;

    // Call cov_cg.sample() here after the trans_type is updated
    cov_cg.sample();
  endfunction

  function void print_transaction();
    $display("Transaction Details:");
    $display("-------------------");
    $display("Transaction Type: %s", trans_type.name());
    $display("Haddr: %0d", Haddr);
    $display("Hwdata: %0d", Hwdata);
    $display("Hwrite: %0b", Hwrite);
    $display("Htrans: %0b", Htrans);
    $display("Hsize: %0b", Hsize);
    $display("Hburst: %0b", Hburst);
    $display("Paddr: %0d", Paddr);
    $display("Pwdata: %0d", Pwdata);
    $display("Pwrite: %0b", Pwrite);
    $display("Pselx: %0b", Pselx);
    $display("Penable: %0b", Penable);
  endfunction

  

endclass
