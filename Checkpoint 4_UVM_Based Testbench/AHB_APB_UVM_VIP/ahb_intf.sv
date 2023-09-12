interface ahb_intf (input logic clk);

    // Signal Declarations
    logic         HRESETn;
    logic [31:0]  HADDR;
    logic [31:0]  HWDATA;
    logic [31:0]  HRDATA;  
    logic [1:0]   HTRANS;
    logic         HWRITE;  
    logic         HSELAHB;
    logic         HREADY;
    logic         HRESP;

    // MODPORTS 
    modport AHB_DRIVER  (clocking ahb_driver_cb,  input clk);
    modport AHB_MONITOR (clocking ahb_monitor_cb, input clk);

    // AHB Driver Clocking Block
    clocking ahb_driver_cb @(posedge clk);
        default input #1 output #1;
        output HRESETn;
        output HADDR;
        output HTRANS;
        output HWRITE;
        output HWDATA;
        output HSELAHB;
        input  HREADY;
    endclocking

    // AHB Monitor Clocking Block
    clocking ahb_monitor_cb @(posedge clk);
        default input #1 output #1;
        input HRESETn;
        input HADDR;
        input HTRANS;
        input HWRITE;
        input HWDATA;
        input HSELAHB;
        input HRDATA;
        input HREADY;
        input HRESP;
    endclocking

endinterface
