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
    
  virtual ahb_apb_bfm_if vif;

    logic [31:0] temp_Haddr; // temporary variable  
    logic [11:0] Haddr_array [6] =  {8'h11, 8'h22, 12'h384, 12'hFD2, 12'h64, 12'hDAC}; // Haddress array
    logic [11:0] Haddr_Hburst[2] = {12'hab , 12'hde}; // Hburst
    int i =0;

    function new(mailbox #(Transaction)gen2driv,   virtual ahb_apb_bfm_if vif);
        this.gen2driv   = gen2driv;
        this.vif = vif;
    endfunction
    
    // Test Case 1
    task read_single_byte_nonseq_single_Htransfer_okay();
        $display($time, "   read_single_byte_nonseq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0; // Read operation
        tx.update_trans_type();
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
	tx.cov_cg.sample(); // After transaction is fully defined

        gen2driv.put(tx);
    endtask

    // Test Case 2
    task write_single_halfword_nonseq_single_Htransfer_okay();
        @(posedge vif.clk);
        $display("At posedge");
        $display($time, "   write_single_halfword_nonseq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 1; // Write operation
   	tx.update_trans_type();
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.Hwdata = $urandom(); // Generate random data for write
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask


    // Test Case 3
    task read_single_word_nonseq_single_Htransfer_okay();
    @(posedge vif.clk);
        $display("At posedge read");
        $display($time, "   read_single_word_nonseq_single_Htransfer_okay task in generator");
        tx = new();
        tx.Haddr = $urandom;
        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
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
