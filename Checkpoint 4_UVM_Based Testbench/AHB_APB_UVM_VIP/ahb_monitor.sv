// AHB Monitor: Monitors the AHB interface and sends transactions to the scoreboard.
class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)

    // Monitor interface and configuration objects
    virtual              ahb_intf.ahb_monitor mon_intf;
    ahb_sequence_item    mon2sb;
    ahb_apb_env_config   env_config_h;

    // Port to send transactions to the scoreboard
    uvm_analysis_port # (ahb_sequence_item) monitor_port;

    // Constructor: Initializes the component
    function new (string name = "ahb_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase: Retrieves the configuration object and initializes the monitor port
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve environment configuration
        if(!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal(get_type_name, "can't retrieve env_config from uvm_config_db")
        
        // Initialize monitor port
        monitor_port = new("monitor_port", this);
    endfunction

    // Connect Phase: Connects to the AHB interface
    function void connect_phase(uvm_phase phase);
        mon_intf = env_config_h.ahb_vif;
    endfunction

    // Run Phase: Continuously monitors the interface for transactions
    task run_phase(uvm_phase phase);
        @(posedge mon_intf.clk);
        forever
            monitor_transaction();
    endtask

    // Monitor Task: Captures transactions from the AHB interface and sends them to the scoreboard
    task monitor_transaction();
        begin
            // Wait for clock edge
            @(posedge mon_intf.clk);
            
            // Create a new transaction item
            mon2sb = ahb_sequence_item::type_id::create("mon2sb", this);

            // Capture transaction data from the interface
            mon2sb.HRESETn  = mon_intf.ahb_monitor_cb.HRESETn;
            mon2sb.HADDR    = mon_intf.ahb_monitor_cb.HADDR;
            mon2sb.HTRANS   = mon_intf.ahb_monitor_cb.HTRANS;
            mon2sb.HWRITE   = mon_intf.ahb_monitor_cb.HWRITE;
            mon2sb.HWDATA   = mon_intf.ahb_monitor_cb.HWDATA;
            mon2sb.HSELAHB  = mon_intf.ahb_monitor_cb.HSELAHB;
            mon2sb.HRDATA   = mon_intf.ahb_monitor_cb.HRDATA;
            mon2sb.HREADY   = mon_intf.ahb_monitor_cb.HREADY;
            mon2sb.HRESP    = mon_intf.ahb_monitor_cb.HRESP;

            // Log transaction details and send to the scoreboard
            `uvm_info(get_type_name, $sformatf("AHB monitor captured TX: \n%s", mon2sb.sprint()), UVM_MEDIUM)
            monitor_port.write(mon2sb);
        end     
    endtask
endclass
