

`include "APB_Interface.v"
`include "APB_Controller.v"
`include "AHB_Slave_Interface.v"
`include "AHB_Master.v"

module Bridge_Top(Hclk,Hresetn,Hwrite,Hreadyin,Hreadyout,Hwdata,Haddr,Htrans,Prdata,Penable,Pwrite,Pselx,Paddr,Pwdata,Hresp,Hrdata);

input Hclk,Hresetn,Hwrite,Hreadyin;
input [31:0] Hwdata,Haddr,Prdata;
input[1:0] Htrans;
output Penable,Pwrite,Hreadyout;
output [1:0] Hresp; 
output [2:0] Pselx;
output [31:0] Paddr,Pwdata;
output [31:0] Hrdata;

//////////INTERMEDIATE SIGNALS

wire valid;
wire [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
wire Hwritereg;
wire [2:0] tempselx;

//////////MODULE INSTANTIATIONS
AHB_slave_interface AHBSlave (Hclk,Hresetn,Hwrite,Hreadyin,Htrans,Haddr,Hwdata,Prdata,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,Hwritereg,tempselx,Hresp);

APB_FSM_Controller APBControl ( Hclk,Hresetn,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwritereg,tempselx,Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);

// Instantiate APB_Interface module
wire Pwriteout, Penableout;
wire [2:0] Pselxout;
wire [31:0] Pwdataout, Paddrout;
reg [31:0] Prdataout;

APB_Interface APBIntf (Pwrite, Pselx, Penable, Paddr, Pwdata, Pwriteout, Pselxout, Penableout, Paddrout, Pwdataout, Prdataout);

endmodule
