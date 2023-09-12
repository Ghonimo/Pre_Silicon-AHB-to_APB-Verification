`ifndef N
    `define N 8 // Number of slaves (N here is the number of slaves)
`endif

interface apb_intf (input logic clk);

    // Signal Declarations
    bit [31:0]     PRDATA [`N-1:0];
    bit [31:0]     PWDATA;
    bit [31:0]     PADDR; 
    bit [`N-1:0]   PSLVERR;
    bit [`N-1:0]   PREADY;
    bit [`N-1:0]   PSELx;
    bit            PENABLE;
    bit            PWRITE;

    // MODPORTS 
    modport APB_DRIVER  (clocking apb_driver_cb, input clk);
    modport APB_MONITOR (clocking apb_monitor_cb, input clk);

    // APB DRIVER Clocking Block
    clocking apb_driver_cb @(posedge clk);
        default input #1 output #1;
        output  PRDATA;
        output  PSLVERR;
        output  PREADY;
    endclocking

    // APB MONITOR Clocking Block
    clocking apb_monitor_cb @(posedge clk);
        default input #1 output #1;
        input PRDATA;
        input PSLVERR;
        input PREADY;
        input PWDATA;
        input PENABLE;
        input PSELx;
        input PADDR;
        input PWRITE;
    endclocking
endinterface
