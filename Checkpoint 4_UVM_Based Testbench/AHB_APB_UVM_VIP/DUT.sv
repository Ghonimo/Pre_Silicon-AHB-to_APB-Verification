
// Bridge Top

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

endmodule

module APB_Interface(Pwrite,Pselx,Penable,Paddr,Pwdata,Pwriteout,Pselxout,Penableout,Paddrout,Pwdataout,Prdata);

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

always @(*)
 begin
  if (~Pwrite && Penable)
   Prdata=($random)%256;
  else
   Prdata=0;
 end

endmodule

module APB_FSM_Controller( Hclk,Hresetn,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwritereg,tempselx, 
			   Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);

input Hclk,Hresetn,valid,Hwrite,Hwritereg;
input [31:0] Hwdata,Haddr,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata;
input [2:0] tempselx;
output reg Pwrite,Penable;
output reg Hreadyout;  
output reg [2:0] Pselx;
output reg [31:0] Paddr,Pwdata;

/////////PARAMETERS

parameter ST_IDLE=3'b000;
parameter ST_WWAIT=3'b001;
parameter ST_READ= 3'b010;
parameter ST_WRITE=3'b011;
parameter ST_WRITEP=3'b100;
parameter ST_RENABLE=3'b101;
parameter ST_WENABLE=3'b110;
parameter ST_WENABLEP=3'b111;


///// PRESENT STATE LOGIC

reg [2:0] PRESENT_STATE,NEXT_STATE;

always @(posedge Hclk)
 begin:PRESENT_STATE_LOGIC
  if (~Hresetn)
    PRESENT_STATE<=ST_IDLE;
  else
    PRESENT_STATE<=NEXT_STATE;
 end


//////// NEXT STATE LOGIC

always @(PRESENT_STATE,valid,Hwrite,Hwritereg)
 begin:NEXT_STATE_LOGIC
  case (PRESENT_STATE)
    
 	ST_IDLE:begin
		 if (~valid)
		  NEXT_STATE=ST_IDLE;
		 else if (valid && Hwrite)
		  NEXT_STATE=ST_WWAIT;
		 else 
		  NEXT_STATE=ST_READ;
		end    

	ST_WWAIT:begin
		 if (~valid)
		  NEXT_STATE=ST_WRITE;
		 else
		  NEXT_STATE=ST_WRITEP;
		end

	ST_READ: begin
		   NEXT_STATE=ST_RENABLE;
		 end

	ST_WRITE:begin
		  if (~valid)
		   NEXT_STATE=ST_WENABLE;
		  else
		   NEXT_STATE=ST_WENABLEP;
		 end

	ST_WRITEP:begin
		   NEXT_STATE=ST_WENABLEP;
		  end

	ST_RENABLE:begin
		     if (~valid)
		      NEXT_STATE=ST_IDLE;
		     else if (valid && Hwrite)
		      NEXT_STATE=ST_WWAIT;
		     else
		      NEXT_STATE=ST_READ;
		   end

	ST_WENABLE:begin
		     if (~valid)
		      NEXT_STATE=ST_IDLE;
		     else if (valid && Hwrite)
		      NEXT_STATE=ST_WWAIT;
		     else
		      NEXT_STATE=ST_READ;
		   end

	ST_WENABLEP:begin
		      if (~valid && Hwritereg)
		       NEXT_STATE=ST_WRITE;
		      else if (valid && Hwritereg)
		       NEXT_STATE=ST_WRITEP;
		      else
		       NEXT_STATE=ST_READ;
		    end

	default: begin
		   NEXT_STATE=ST_IDLE;
		  end
  endcase
 end


///////////OUTPUT LOGIC:COMBINATIONAL

reg Penable_temp,Hreadyout_temp,Pwrite_temp;
reg [2:0] Pselx_temp;
reg [31:0] Paddr_temp, Pwdata_temp;

always @(*)
 begin:OUTPUT_COMBINATIONAL_LOGIC
   case(PRESENT_STATE)
    
	ST_IDLE: begin
			  if (valid && ~Hwrite) 
			   begin:IDLE_TO_READ
			        Paddr_temp=Haddr;
				Pwrite_temp=Hwrite;
				Pselx_temp=tempselx;
				Penable_temp=0;
				Hreadyout_temp=0;
			   end
			  
			  else if (valid && Hwrite)
			   begin:IDLE_TO_WWAIT
			        Pselx_temp=0;
				Penable_temp=0;
				Hreadyout_temp=1;			   
			   end
			   
			  else
                            begin:IDLE_TO_IDLE
			        Pselx_temp=0;
				Penable_temp=0;
				Hreadyout_temp=1;	
			   end
		     end    

	ST_WWAIT:begin
	          if (~valid) 
			   begin:WAIT_TO_WRITE
			    Paddr_temp=Haddr1;
				Pwrite_temp=1;
				Pselx_temp=tempselx;
				Penable_temp=0;
				Pwdata_temp=Hwdata;
				Hreadyout_temp=0;
			   end
			  
			  else 
			   begin:WAIT_TO_WRITEP
			    Paddr_temp=Haddr1;
				Pwrite_temp=1;
				Pselx_temp=tempselx;
				Pwdata_temp=Hwdata;
				Penable_temp=0;
				Hreadyout_temp=0;		   
			   end
			   
		     end  

	ST_READ: begin:READ_TO_RENABLE
			  Penable_temp=1;
			  Hreadyout_temp=1;
		     end

	ST_WRITE:begin
              if (~valid) 
			   begin:WRITE_TO_WENABLE
				Penable_temp=1;
				Hreadyout_temp=1;
			   end
			  
			  else 
			   begin:WRITE_TO_WENABLEP ///DOUBT
				Penable_temp=1;
				Hreadyout_temp=1;		   
			   end
		     end

	ST_WRITEP:begin:WRITEP_TO_WENABLEP
               Penable_temp=1;
			   Hreadyout_temp=1;
		      end

	ST_RENABLE:begin
	            if (valid && ~Hwrite) 
				 begin:RENABLE_TO_READ
					Paddr_temp=Haddr;
					Pwrite_temp=Hwrite;
					Pselx_temp=tempselx;
					Penable_temp=0;
					Hreadyout_temp=0;
				 end
			  
			  else if (valid && Hwrite)
			    begin:RENABLE_TO_WWAIT
			     Pselx_temp=0;
				 Penable_temp=0;
				 Hreadyout_temp=1;			   
			    end
			   
			  else
                begin:RENABLE_TO_IDLE
			     Pselx_temp=0;
				 Penable_temp=0;
				 Hreadyout_temp=1;	
			    end

		       end

	ST_WENABLEP:begin
                 if (~valid && Hwritereg) 
			      begin:WENABLEP_TO_WRITEP
			       Paddr_temp=Haddr2;
				   Pwrite_temp=Hwrite;
				   Pselx_temp=tempselx;
				   Penable_temp=0;
				   Pwdata_temp=Hwdata;
				   Hreadyout_temp=0;
				  end

			  
			    else 
			     begin:WENABLEP_TO_WRITE_OR_READ /////DOUBT
			      Paddr_temp=Haddr2;
				  Pwrite_temp=Hwrite;
				  Pselx_temp=tempselx;
				  Pwdata_temp=Hwdata;
				  Penable_temp=0;
				  Hreadyout_temp=0;		   
			     end
		        end

	ST_WENABLE :begin
	             if (~valid && Hwritereg) 
			      begin:WENABLE_TO_IDLE
				   Pselx_temp=0;
				   Penable_temp=0;
				   Hreadyout_temp=0;
				  end

			  
			    else 
			     begin:WENABLE_TO_WAIT_OR_READ /////DOUBT
				  Pselx_temp=0;
				  Penable_temp=0;
				  Hreadyout_temp=0;		   
			     end

		        end

 endcase
end


////////////OUTPUT LOGIC:SEQUENTIAL

always @(posedge Hclk)
 begin
  
  if (~Hresetn)
   begin
    Paddr<=0;
	Pwrite<=0;
	Pselx<=0;
	Pwdata<=0;
	Penable<=0;
	Hreadyout<=0;
   end
  
  else
   begin
        Paddr<=Paddr_temp;
	Pwrite<=Pwrite_temp;
	Pselx<=Pselx_temp;
	Pwdata<=Pwdata_temp;
	Penable<=Penable_temp;
	Hreadyout<=Hreadyout_temp;
   end
 end

endmodule

module AHB_slave_interface(Hclk,Hresetn,Hwrite,Hreadyin,Htrans,Haddr,Hwdata,
			   Prdata,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,Hwritereg,tempselx,Hresp);
input Hclk,Hresetn;
input Hwrite,Hreadyin;
input [1:0] Htrans;
input [31:0] Haddr,Hwdata,Prdata;
output reg valid;
output reg [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
output [31:0] Hrdata; 
output reg Hwritereg;
output reg [2:0] tempselx;
output  [1:0] Hresp;



/// Implementing Pipeline Logic for Address,Data and Control Signal

	always @(posedge Hclk)
		begin
		
			if (~Hresetn)
				begin
					Haddr1<=0;
					Haddr2<=0;
				end
			else
				begin
					Haddr1<=Haddr;
					Haddr2<=Haddr1;
				end
		
		end

	always @(posedge Hclk)
		begin
		
			if (~Hresetn)
				begin
					Hwdata1<=0;
					Hwdata2<=0;
				end
			else
				begin
					Hwdata1<=Hwdata;
					Hwdata2<=Hwdata1;
				end
		
		end
		
	always @(posedge Hclk)
		begin	
			if (~Hresetn)
				Hwritereg<=0;
			else
				Hwritereg<=Hwrite;
		end
		
		
/// Implementing Valid Logic Generation

	always @(Hreadyin,Haddr,Htrans,Hresetn)
		begin
			valid=0;
			if (Hresetn && Hreadyin && (Haddr>=32'h8000_0000 && Haddr<32'h8C00_0000) && (Htrans==2'b10 || Htrans==2'b11) )
				valid=1;

		end
		
/// Implementing Tempselx Logic

	always @(Haddr,Hresetn)
		begin
			tempselx=3'b000;
			if (Hresetn && Haddr>=32'h8000_0000 && Haddr<32'h8400_0000)
				tempselx=3'b001;
			else if (Hresetn && Haddr>=32'h8400_0000 && Haddr<32'h8800_0000)
				tempselx=3'b010;
			else if (Hresetn && Haddr>=32'h8800_0000 && Haddr<32'h8C00_0000)
				tempselx=3'b100;

		end
	

assign Hrdata = Prdata;
assign Hresp=2'b00;

endmodule

module AHB_Master(Hclk,Hresetn,Hresp,Hrdata,Hwrite,Hreadyin,Hreadyout,Htrans,Hwdata,Haddr);

input Hclk,Hresetn,Hreadyout;
input [1:0]Hresp;
input [31:0] Hrdata;
output reg Hwrite,Hreadyin;
output reg [1:0] Htrans;
output reg [31:0] Hwdata,Haddr;

reg [2:0] Hburst;
reg [2:0] Hsize;



task single_write();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=1;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_0001;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
    Hwdata=8'hA3;
   end 
 end
endtask


task single_read();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=0;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_00A2;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
   end 
 end
endtask


endmodule
