// The apb_agent class encapsulates the components and behavior of the APB agent.
// The agent consists of a sequencer to generate transactions, a driver to
// drive the transactions to the DUT and a monitor to observe the bus signals.

class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    // Configuration handle to retrieve settings specific to this agent
    ahb_apb_env_config env_config_h;

    // Components of the agent
    apb_sequencer sequencer_h;
    apb_driver    drv_h;
    apb_monitor   mon_h;

    // Constructor: Initialize the agent with a name and parent
    function new(string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Create and configure the agent components based on the configuration
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Fetch the configuration settings for the agent
        if (!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal("config", "Failed to retrieve env_config_h from uvm_config_db")

        // Create the monitor to observe the bus signals
        mon_h = apb_monitor::type_id::create("mon_h", this);

        // If agent is active, create the driver and sequencer
        if (env_config_h.apb_agent_is_active == UVM_ACTIVE) begin
            drv_h = apb_driver::type_id::create("drv_h", this);
            sequencer_h = apb_sequencer::type_id::create("sequencer_h", this);
        end
    endfunction

    // Connect Phase: Connect the sequencer to the driver if the agent is active
    function void connect_phase(uvm_phase phase);
        if (env_config_h.apb_agent_is_active == UVM_ACTIVE) begin
            drv_h.seq_item_port.connect(sequencer_h.seq_item_export);
        end
    endfunction

endclass
