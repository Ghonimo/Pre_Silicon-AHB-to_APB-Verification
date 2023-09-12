// Necessary UVM imports and macros
import uvm_pkg::*;
`include "uvm_macros.svh"

// Global settings
int N_TX = 500;  // Set the number of transactions to be generated, change/adjust this as needed
// When we have a burst transaction, we will generate a random number of transactions between 1 and MAX_BURST

// Including necessary sequence items, environment configurations, and components
`include "ahb_sequence_item.sv"
`include "apb_sequence_item.sv"
`include "ahb_apb_env_config.sv"

// Including AHB Components
`include "ahb_sequencer.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"
`include "ahb_agent.sv"

// Including APB Components
`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"

// Including scoreboard and environment
`include "ahb_apb_scoreboard.sv"
`include "ahb_apb_env.sv"

// Including sequences and tests
`include "ahb_sequence.sv"
`include "apb_sequence.sv"
`include "ahb_apb_test.sv"
`include "ahb_apb_single_test.sv"
`include "ahb_apb_burst_test.sv"

module tb_top();
    // Clock signal
    bit clk;

    // AHB and APB interface instantiation (Bus Functional Models - BFMs)
    ahb_intf AHB_INF (clk);  // AHB interface
    apb_intf APB_INF (clk);  // APB interface

    // DUT instantiation
    Bridge_Top DUT (
        .Hclk(clk),
        .Hresetn(AHB_INF.HRESETn),
        .Hwrite(AHB_INF.HWRITE),
        .Hreadyin(1'b1),           	// Always ready (no wait states implemented)
        .Htrans(AHB_INF.HTRANS),
        .Hwdata(AHB_INF.HWDATA),
        .Haddr(AHB_INF.HADDR),
        .Hrdata(AHB_INF.HRDATA),
        .Hresp(AHB_INF.HRESP),
        .Hreadyout(AHB_INF.HREADY),

		// Only one APB interface implemented, this one interface
		// will minmic different slaves connected to the bridge
        .Prdata(APB_INF.PRDATA[0]),	
        .Pwdata(APB_INF.PWDATA),
        .Paddr(APB_INF.PADDR),
        .Pselx(APB_INF.PSELx[2:0]),
        .Pwrite(APB_INF.PWRITE),
        .Penable(APB_INF.PENABLE)
    );

    // Initialization block to configure the UVM environment
    initial begin
        // Set the virtual interface handles to the config_db
        uvm_config_db # (virtual ahb_intf)::set(null,"*","ahb_vif",AHB_INF); 
        uvm_config_db # (virtual apb_intf)::set(null,"*","apb_vif",APB_INF);

        // Uncomment the desired test to run
        // run_test("ahb_apb_single_write_test");
        // run_test("ahb_apb_single_read_test");
        run_test("ahb_apb_burst_write_test");
        // run_test("ahb_apb_burst_read_test");
    end

    // Clock generation block
    initial begin
        clk = 1'b0;
        forever
            #5 clk = ~clk;
    end
endmodule
