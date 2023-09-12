// AHB Agent: Comprises of Driver, Sequencer, and Monitor for AHB
class ahb_agent extends uvm_agent;
    `uvm_component_utils(ahb_agent)

    // Handle declarations for AHB driver, sequencer, monitor and environment configuration
    ahb_driver           drv_h;
    ahb_sequencer        sequencer_h;
    ahb_monitor          mon_h;
    ahb_apb_env_config   env_config_h;

    // Constructor for the AHB agent
    function new(string name = "ahb_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // Build phase: Instantiate the driver, sequencer, and monitor based on the configuration
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve the environment configuration from config DB
        if(!uvm_config_db #(ahb_apb_env_config)::get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal("CONFIG", "Can't get env_config from uvm_config_db")

        // Always create the monitor
        mon_h = ahb_monitor::type_id::create("mon_h", this);

        // If agent is active, create the driver and sequencer
        if(env_config_h.ahb_agent_is_active == UVM_ACTIVE) begin
            drv_h = ahb_driver::type_id::create("drv_h", this);
            sequencer_h = ahb_sequencer::type_id::create("sequencer_h", this);
        end
    endfunction

    // Connect phase: Connect the driver to the sequencer if agent is active
    function void connect_phase(uvm_phase phase);
        if(env_config_h.ahb_agent_is_active == UVM_ACTIVE) begin
            drv_h.seq_item_port.connect(sequencer_h.seq_item_export);
        end
    endfunction
endclass
