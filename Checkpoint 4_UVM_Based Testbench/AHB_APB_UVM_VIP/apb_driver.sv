// The apb_driver class is responsible for driving APB interface signals
// based on the received transaction items. The driver interfaces with
// the DUT through the apb_intf and uses the apb_sequence_item
// to fetch transactions to be driven.

class apb_driver extends uvm_driver #(apb_sequence_item);
    `uvm_component_utils(apb_driver)

    // Interface to the APB DUT
    virtual apb_intf.apb_driver drv_intf;

    // Sequence item that contains the transaction details
    apb_sequence_item drv2dut;

    // Configuration handle to get environment settings
    ahb_apb_env_config env_config_h;

    // Constructor: Initialize the apb_driver with a name and parent
    function new (string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Fetch configuration settings from the config_db
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal ("config", "Failed to retrieve env_config_h from uvm_config_db")
    endfunction

    // Connect Phase: Link the driver to the APB interface
    function void connect_phase(uvm_phase phase);
        drv_intf = env_config_h.apb_vif;
    endfunction

    // Run Phase: Continuously fetch sequence items and drive them onto the interface
    task run_phase(uvm_phase phase);
        forever 
        begin
            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();
        end
    endtask

    // Drive the received sequence item onto the APB interface
    virtual task drive_packet (apb_sequence_item drv2dut);
        @(posedge drv_intf.clk);
        drv_intf.apb_driver_cb.PRDATA   <= drv2dut.PRDATA;
        drv_intf.apb_driver_cb.PSLVERR  <= drv2dut.PSLVERR;
        drv_intf.apb_driver_cb.PREADY   <= drv2dut.PREADY;
        
        `uvm_info(get_type_name(), $sformatf("APB driver delivered Tx: \n%s", drv2dut.sprint()), UVM_MEDIUM)
    endtask

endclass
