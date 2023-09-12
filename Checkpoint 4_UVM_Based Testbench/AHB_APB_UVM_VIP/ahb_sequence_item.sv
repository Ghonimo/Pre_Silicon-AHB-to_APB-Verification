// The ahb_sequence_item class represents a single AHB transaction item.
// This class extends uvm_sequence_item and provides randomization, printing, and post-randomization capabilities.
class ahb_sequence_item extends uvm_sequence_item;

    // UVM object macro
    `uvm_object_utils(ahb_sequence_item)

    // Randomizable transaction fields
    rand bit                   HRESETn;    // Reset signal
    rand bit [31:0]            HADDR;      // Address
    rand bit [1:0]             HTRANS;     // Transaction type
    rand bit                   HWRITE;     // Write enable flag
    rand bit [31:0]            HWDATA;     // Data to be written
    rand bit                   HSELAHB;    // AHB bridge select signal

    // Non-randomizable fields
    bit [31:0]                 HRDATA;     // Data read
    bit                        HREADY;     // Ready signal
    bit                        HRESP;      // Response signal

    // Counter to track the number of transactions
    static int ahb_no_of_transaction;

    // Constructor: Initializes the uvm_sequence_item
    function new(string name = "ahb_sequence_item");
        super.new(name);
    endfunction

    // Constraints to guide randomization
    constraint LOW_RESET        {HRESETn dist   {1:=9, 0:=1};}
    constraint VALID_ADDRESS    {HADDR   inside {[32'h0:32'h7ff]}; }
    constraint SELECT_BRIDGE    {HSELAHB dist   {1:=99, 0:=1};}

    // Function to print the fields of the item
    function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_field ("RESETn", HRESETn, 1, UVM_DEC);
        printer.print_field ("HADDR", HADDR, 32, UVM_HEX);
        printer.print_field ("HTRANS", HTRANS, 2, UVM_DEC);
        printer.print_field ("HWRITE", HWRITE, 1, UVM_DEC);
        printer.print_field ("HWDATA", HWDATA, 32, UVM_HEX);
        printer.print_field ("HSELAHB", HSELAHB, 1, UVM_DEC);
        printer.print_field ("HREADY", HREADY, 1, UVM_DEC);
    endfunction

    // Function called after each randomization to update transaction count and print details
    function void post_randomize();
        ahb_no_of_transaction++;
        `uvm_info("AHB_SEQUENCE_ITEM", $sformatf("Transaction [%0d]: %s", ahb_no_of_transaction, this.sprint()), UVM_MEDIUM)
    endfunction

endclass
