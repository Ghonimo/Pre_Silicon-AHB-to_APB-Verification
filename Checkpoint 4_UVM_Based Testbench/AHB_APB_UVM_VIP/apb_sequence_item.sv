
`ifndef N
    `define N 8 //Number of slaves (N here is the number of slaves)
`endif

class apb_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(apb_sequence_item)

    // Randomized data members
    rand bit [31:0]     PRDATA [`N-1:0];
    rand bit [`N-1:0]   PSLVERR;
    rand bit [`N-1:0]   PREADY;

    // Non-randomized data members
         bit [`N-1:0]   PWDATA;
         bit            PENABLE;
         bit [`N-1:0]   PSELx;
         bit [`N-1:0]   PADDR;
         bit            PWRITE;

    // Static members
     static int apb_no_of_transaction;

    // Constraint task
     constraint VALID_READY       {PREADY   dist {8'hFF:= 99, 8'h00:= 1};}
     constraint LOW_APB_ERROR     {PSLVERR  dist {8'hFF:= 99, 8'h00:= 1};}

    // Constructor
     function new(string name = "apb_sequence_item");
          super.new(name);
     endfunction

    // Printing function
     function void do_print(uvm_printer printer);
          super.do_print(printer);
          printer.print_field("PSLVERR",this.PSLVERR   ,1,UVM_DEC);
          printer.print_field("PREADY",this.PREADY     ,1,UVM_DEC);
     endfunction

    // Post randomization function
     function void post_randomize();
          apb_no_of_transaction++;
           `uvm_info("APB_SEQUENCE_ITEM", $sformatf("Random Tx: [%0d] is %s\n" ,apb_no_of_transaction, this.sprint()),UVM_HIGH)
     endfunction
endclass