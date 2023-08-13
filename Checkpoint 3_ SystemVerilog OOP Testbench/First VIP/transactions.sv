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
