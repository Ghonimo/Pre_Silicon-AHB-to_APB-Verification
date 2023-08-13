// -----------------------------------------------------------------------------
// Project: AHB APB Bridge Verification
// Module:  Scoreboard
// File:    scoreboard.sv
// -----------------------------------------------------------------------------
// Author:  Mohamed Ghonim
// Created: 26-Jul-2023
//
// Description: 
// The Scoreboard class plays a crucial role in verification process as it 
// validates the correctness of the design. It contains a memory model that
// mimics the behaviour of the design under test (DUT).
//
// The Scoreboard receives transactions from both the driver and the monitor, 
// allowing it to compare the expected and actual responses. This class has 
// methods to handle both data write and read operations. For a write operation, 
// it verifies that the data has been correctly written into the memory model. 
// For a read operation, it checks if the data read from the DUT matches with 
// the data stored in the memory model. Any discrepancy in data would result 
// in an assertion error, flagging a failure in the verification process.
// -----------------------------------------------------------------------------


class ahb_apb_scoreboard;

    Transaction tx1, tx2;
    mailbox #(Transaction) drv2sb;
    mailbox #(Transaction) mail2sb;
    logic [19:0] temp_addr; // We will only track the least significant 20 bits

    bit [31:0] mem_tb [2**20]; // memory of 2^20 locations each of 32 bits
  virtual ahb_apb_bfm_if vif;

    function new(mailbox #(Transaction) drv2sb, mailbox #(Transaction) mail2sb, virtual ahb_apb_bfm_if vif);
        this.drv2sb = drv2sb;
        this.mail2sb = mail2sb;
        this.vif = vif;
    endfunction

    task data_write();

        $display("Scoreboard check...");

        // Receive data from driver and monitor
        drv2sb.get(tx1);
        mail2sb.get(tx2);

        temp_addr = tx1.Haddr[19:0];

        // Write data to the memory model
        mem_tb[temp_addr] = tx1.Hwdata;

        $display("Input Address: %h", temp_addr);
        $display("Input Write Data: %h", tx1.Hwdata);
        $display("Data Stored: %h", mem_tb[temp_addr]);

        // Assert that the data was written correctly
        assert (tx1.Hwdata == mem_tb[temp_addr])
            else $error("Data failed to write");

        $display("");
	@(posedge vif.clk);
    endtask

    task data_read();

        $display("Scoreboard read");

        drv2sb.get(tx1);
        mail2sb.get(tx2);

        temp_addr = tx1.Haddr[19:0];

        $display("Temp address = %h", temp_addr);
        $display("Read data from DUT %h", tx2.Pwdata); // data from monitor/DUT
        $display("Data from TB memory %h", mem_tb[temp_addr]);

        // Assert that the data read matches the data in the memory model
        assert (tx2.Pwdata == mem_tb[temp_addr])
            else $error("Data reading failed");

        $display("");
	@(posedge vif.clk);
    endtask

endclass

