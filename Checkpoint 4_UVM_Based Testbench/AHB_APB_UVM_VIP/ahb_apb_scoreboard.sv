
// This scoreboard validates the data flow between the AHB and APB interfaces.
class ahb_apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ahb_apb_scoreboard)

    // FIFOs to hold packets from the AHB and APB monitors.
    uvm_tlm_analysis_fifo #(ahb_sequence_item) ahb_fifo;
    uvm_tlm_analysis_fifo #(apb_sequence_item) apb_fifo;

    // Variables to hold incoming and predicted packets for AHB and APB.
    ahb_sequence_item ahb_data_pkt, ahb_predicted_pkt, current_pkt, ahb_temp_data;
    apb_sequence_item apb_data_pkt, apb_predicted_pkt;

    int selected_slave;     // We can have up to 8 slaves, this scoreboard doesn't monitor all of them.

    // Counters to track the number of packets and verified data.
    int ahb_pkt_count = 0;
    int apb_pkt_count = 0;
    int verified_data_count = 0;

    // Covergroup to capture coverage metrics.
    covergroup cov_group;
        option.per_instance = 1;
        reset      : coverpoint current_pkt.HRESETn  { bins reset_val = {0}; }
        bus_write      : coverpoint current_pkt.HWRITE   { bins write_val = {1}; }
        bus_read       : coverpoint current_pkt.HWRITE   { bins read_val  = {0}; }
 
        trans_type    : coverpoint current_pkt.HTRANS {
            bins idle_val   = {2'b00};
            bins nonseq_val = {2'b10};
            bins seq_val    = {2'b11};
        }
        WRITE_COVERAGE: cross bus_write, trans_type;
        READ_COVERAGE : cross bus_read, trans_type;
    endgroup

    // Constructor: Initialize class members and create objects.
    function new (string sb_name, uvm_component sb_parent);
        super.new(sb_name, sb_parent);
        ahb_fifo = new("ahb_fifo", this);
        apb_fifo = new("apb_fifo", this);

        // Create the type_ids for the incoming and predicted packets.
        ahb_predicted_pkt = ahb_sequence_item::type_id::create("ahb_predicted_pkt", this);
        apb_predicted_pkt = apb_sequence_item::type_id::create("apb_predicted_pkt", this);
        ahb_temp_data = ahb_sequence_item::type_id::create("ahb_temp_data", this);
        cov_group = new;
    endfunction

    // run_phase: Continuously sample packets from the monitors and process them.
    task run_phase(uvm_phase phase);
        forever begin
            // Sample AHB packets from its monitor.
            ahb_fifo.get(ahb_data_pkt);
            ahb_pkt_count++;
            `uvm_info (get_type_name, $sformatf("[%0d] Scoreboard sampled ahb_data_pkt\n%s", ahb_pkt_count, ahb_data_pkt.sprint()), UVM_MEDIUM);

            // Sample APB packets from its monitor.
            apb_fifo.get(apb_data_pkt);
            apb_pkt_count++;
            `uvm_info (get_type_name, $sformatf("[%0d] Scoreboard sampled apb_data_pkt\n%s", apb_pkt_count, apb_data_pkt.sprint()), UVM_MEDIUM);

            // Predict the expected data based on sampled packets.
            predict_data();

            // Sample coverage.
            current_pkt = ahb_data_pkt;
            cov_group.sample();
        end
    endtask

    // Predict the expected data for APB and AHB based on the current transactions.
    task predict_data();
        // If AHB reset is active, skip the processing.
        if(ahb_data_pkt.HRESETn == 1'b0) return;

        // Process the AHB transaction type.
        if(ahb_data_pkt.HTRANS == 2'b10) begin
            ahb_temp_data.HADDR  = ahb_data_pkt.HADDR;
            ahb_temp_data.HWRITE = ahb_data_pkt.HWRITE;
        end 
        else if (ahb_data_pkt.HTRANS inside {2'b11, 2'b00}) begin
            apb_predicted_pkt.PADDR  = ahb_temp_data.HADDR;
            apb_predicted_pkt.PWRITE = ahb_temp_data.HWRITE;
            apb_predicted_pkt.PWDATA = ahb_data_pkt.HWDATA;

            // Configure the PSELx based on the address.
            configure_pselx();

            // Update the temporary AHB data.
            ahb_temp_data.HADDR  = ahb_data_pkt.HADDR;
            ahb_temp_data.HWRITE = ahb_data_pkt.HWRITE;          

            // Check APB data against the predicted data.
            check_apb_data();  
        end

        // If APB write enable is high and it's a read transaction.
        if(apb_data_pkt.PENABLE == 1'b1 & apb_data_pkt.PWRITE == 1'b0) begin
            ahb_predicted_pkt.HRDATA = apb_data_pkt.PRDATA[selected_slave];
            
            // Check AHB data against the predicted data.
            check_ahb_data();
        end
    endtask

    // Configure the PSELx signal based on the AHB address.
    task configure_pselx();
        if(ahb_temp_data.HADDR inside {[32'h000:32'h0FF]}) apb_predicted_pkt.PSELx = 8'h01;
        else if (ahb_temp_data.HADDR inside {[32'h100:32'h1FF]}) apb_predicted_pkt.PSELx = 8'h02;
        // Continue with other address ranges...
    endtask

    // Check the APB data against the predicted values.
    task check_apb_data();
        if(apb_predicted_pkt.PADDR  == apb_data_pkt.PADDR);
        if(apb_predicted_pkt.PWRITE == apb_data_pkt.PWRITE);
        if(apb_predicted_pkt.PSELx  == apb_data_pkt.PSELx);
        if(apb_predicted_pkt.PWDATA == apb_data_pkt.PWDATA);
        verified_data_count++;
    endtask

    // Check the AHB data against the predicted values.
    task check_ahb_data();
        if(ahb_predicted_pkt.HRDATA == ahb_data_pkt.HRDATA);
        verified_data_count++;
    endtask

    function void report_phase(uvm_phase phase);
    // Print the scoreboard summary at the end of the simulation.
        $display("\n=== Scoreboard Summary ===");
        $display("AHB Packets: %0d",ahb_pkt_count);
        $display("APB Packets: %0d", apb_pkt_count);
        $display("Verified Transactions: %d",verified_data_count);
        $display("Unverified Transactions: %d", (ahb_pkt_count-verified_data_count));

    // Print the coverage summary at the end of the simulation.
        $display("=== Coverage Report ===");
        $display("RESET: %0f%%", cov_group.reset.get_coverage());
        $display("WRITE: %0f%%", cov_group.bus_write.get_coverage());
        $display("READ: %0f%%", cov_group.bus_read.get_coverage());
        $display("=== End of Summary ===\n");
    endfunction

endclass
