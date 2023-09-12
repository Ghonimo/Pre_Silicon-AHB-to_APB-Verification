
// AHB-APB Environment Configuration Class
class ahb_apb_env_config extends uvm_object;
    `uvm_object_utils(ahb_apb_env_config)

    // Configuration flags for activating components in the environment
    bit ahb_agent_enabled;       // Flag to determine if AHB agent should be instantiated
    bit apb_agent_enabled;       // Flag to determine if APB agent should be instantiated
    bit scoreboard_enabled;      // Flag to determine if scoreboard should be instantiated

    // Configuration for AHB and APB agent activity modes (ACTIVE/PASSIVE)
    uvm_active_passive_enum ahb_agent_is_active;
    uvm_active_passive_enum apb_agent_is_active;

    // Virtual interface handles for AHB and APB
    virtual ahb_intf ahb_vif;
    virtual apb_intf apb_vif;

    // Constructor for the AHB-APB environment configuration
    function new(string name = "ahb_apb_env_config");
        super.new(name);
    endfunction
endclass
