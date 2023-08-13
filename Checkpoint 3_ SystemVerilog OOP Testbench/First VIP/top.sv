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


