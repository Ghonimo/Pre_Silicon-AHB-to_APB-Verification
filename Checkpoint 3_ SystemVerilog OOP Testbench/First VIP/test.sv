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

