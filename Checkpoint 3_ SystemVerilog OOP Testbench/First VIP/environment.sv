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

