module APB_Interface(Hclk, Pwrite,Pselx,Penable,Paddr,Pwdata,Pwriteout,Pselxout,Penableout,Paddrout,Pwdataout,Prdata);

input Hclk; 
input Pwrite,Penable;
input [2:0] Pselx;
input [31:0] Pwdata,Paddr;

output Pwriteout,Penableout;
output [2:0] Pselxout;
output [31:0] Pwdataout,Paddrout;
output reg [31:0] Prdata;

assign Penableout=Penable;
assign Pselxout=Pselx;
assign Pwriteout=Pwrite;
assign Paddrout=Paddr;
assign Pwdataout=Pwdata;

reg [31:0] Prdata_reg; // New register to hold the value of Prdata

always @(posedge Hclk)
 begin
  if (~Pwrite && Penable)
   Prdata_reg=($random)%256; // Update Prdata_reg when a new read operation starts
  else
   Prdata_reg=0; // Reset Prdata_reg when not reading
 end

assign Prdata = Prdata_reg; // Prdata now holds its value for the entire duration of the read operation

endmodule

