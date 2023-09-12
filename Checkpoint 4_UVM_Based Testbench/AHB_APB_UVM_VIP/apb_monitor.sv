
class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_intf.apb_monitor mon_intf;

    apb_sequence_item           mon2sb;
    ahb_apb_env_config   env_config_h;

    uvm_analysis_port # (apb_sequence_item) monitor_port;

    function new (string name = "apb_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db # (ahb_apb_env_config) :: get(this,"","ahb_apb_env_config",env_config_h))
            `uvm_fatal(get_type_name, "can't get env_config_h from uvm_config_db")
        monitor_port = new("monitor_port",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        mon_intf = env_config_h.apb_vif;
    endfunction

    task run_phase (uvm_phase phase);
        @(posedge mon_intf.clk);
        forever
            monitor();
    endtask

    task monitor();
        begin
            @(posedge mon_intf.clk);
            mon2sb = apb_sequence_item::type_id::create("mon2sb",this);

            mon2sb.PRDATA   = mon_intf.apb_monitor_cb.PRDATA;
            mon2sb.PSLVERR  = mon_intf.apb_monitor_cb.PSLVERR;
            mon2sb.PREADY   = mon_intf.apb_monitor_cb.PREADY;
            mon2sb.PWDATA   = mon_intf.apb_monitor_cb.PWDATA;
            mon2sb.PENABLE  = mon_intf.apb_monitor_cb.PENABLE;
            mon2sb.PSELx    = mon_intf.apb_monitor_cb.PSELx;
            mon2sb.PADDR    = mon_intf.apb_monitor_cb.PADDR;
            mon2sb.PWRITE   = mon_intf.apb_monitor_cb.PWRITE;

            `uvm_info(get_type_name, $sformatf("APB monitor recieved TX: \n%s", mon2sb.sprint()), UVM_MEDIUM)
            monitor_port.write(mon2sb);
        end     
    endtask

endclass