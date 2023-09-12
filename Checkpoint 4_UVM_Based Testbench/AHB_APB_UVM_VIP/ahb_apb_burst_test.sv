// This class focuses on the burst write test sequence for the ahb_apb testbench
class ahb_apb_burst_write_test extends ahb_apb_base_test;
    `uvm_component_utils(ahb_apb_burst_write_test)

    // Sequence handle to generate burst write traffic on AHB and APB
    ahb_burst_write_sequence ahb_seq_h;
    apb_burst_write_sequence apb_seq_h;

    // Constructor
    function new(string name = "ahb_apb_burst_write_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase: Instantiate the burst write sequences
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_seq_h = ahb_burst_write_sequence::type_id::create("ahb_seq_h");
        apb_seq_h = apb_burst_write_sequence::type_id::create("apb_seq_h");
    endfunction

    // Run Phase: Start the burst write sequences on the respective sequencers
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            ahb_seq_h.start(env_h.ahb_agent_h.sequencer_h);
            apb_seq_h.start(env_h.apb_agent_h.sequencer_h);
        join
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 50);
    endtask
endclass

// This class focuses on the burst read test sequence for the ahb_apb testbench
class ahb_apb_burst_read_test extends ahb_apb_base_test;
    `uvm_component_utils(ahb_apb_burst_read_test)

    // Sequence handle to generate burst read traffic on AHB and APB
    ahb_burst_read_sequence ahb_seq_h;
    apb_burst_read_sequence apb_seq_h;

    // Constructor
    function new(string name = "ahb_apb_burst_read_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase: Instantiate the burst read sequences
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_seq_h = ahb_burst_read_sequence::type_id::create("ahb_seq_h");
        apb_seq_h = apb_burst_read_sequence::type_id::create("apb_seq_h");
    endfunction

    // Run Phase: Start the burst read sequences on the respective sequencers
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            ahb_seq_h.start(env_h.ahb_agent_h.sequencer_h);
            apb_seq_h.start(env_h.apb_agent_h.sequencer_h);
        join
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 50);
    endtask
endclass
