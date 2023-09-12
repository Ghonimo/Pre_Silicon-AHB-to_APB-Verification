
// AHB Driver: Responsible for driving the AHB sequence items onto the interface
class ahb_driver extends uvm_driver #(ahb_sequence_item);
    `uvm_component_utils(ahb_driver)

    // AHB Driver interface
    virtual ahb_intf.ahb_driver drv_intf;

    // Sequence item for driver to DUT communication
    ahb_sequence_item drv2dut;

    // Configuration handle for environment setup
    ahb_apb_env_config env_config_h;

    // Temporary storage for data during Write operations
    static bit [31:0] temp_Hwdata; 

    // Indicates if there's a Write operation pending
    static int Write_Pending;

    // Constructor
    function new (string name = "ahb_driver",uvm_component parent);
        super.new (name, parent);
    endfunction


    // Build Phase: Fetch the configuration settings from the environment
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_apb_env_config)::get (this,"","ahb_apb_env_config",env_config_h))
            `uvm_fatal ("config", "can't get config from uvm_config_db")
    endfunction

    // Connect Phase: Connect the driver interface
    function void connect_phase (uvm_phase phase);
        drv_intf = env_config_h.ahb_vif;
    endfunction

    // Run Phase: Get the sequence item from the sequencer and drive it onto the interface
    task run_phase (uvm_phase phase);
        forever
        begin
            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();    
        end
    endtask

    // Drive the sequence item onto the interface
    virtual task drive_packet (ahb_sequence_item drv2dut);
        @(posedge drv_intf.clk)
        wait((drv_intf.ahb_driver_cb.HREADY));
        drv2dut.HREADY = drv_intf.ahb_driver_cb.HREADY;

        if(!(drv2dut.HTRANS == 2'b01))  //BUSY
        begin      

            drv_intf.ahb_driver_cb.HRESETn <=  drv2dut.HRESETn;
            drv_intf.ahb_driver_cb.HSELAHB <=  drv2dut.HSELAHB;
            drv_intf.ahb_driver_cb.HADDR   <=  drv2dut.HADDR;
            drv_intf.ahb_driver_cb.HTRANS  <=  drv2dut.HTRANS;
            drv_intf.ahb_driver_cb.HWRITE  <=  drv2dut.HWRITE;

            if(drv2dut.HWRITE == 1'b0)  // READ
                drv_intf.ahb_driver_cb.HWDATA  <=  32'hxxxx_xxxx; 

            else
            begin
                if(drv2dut.HTRANS == 2'b10)  // NONSEQ
                begin
                    temp_Hwdata  <=  drv2dut.HWDATA;
                    Write_Pending <= 1;
                end

                else if (drv2dut.HTRANS == 2'b11)  // SEQ
                begin
                    temp_Hwdata  <= drv2dut.HWDATA;
                    drv_intf.ahb_driver_cb.HWDATA   <= temp_Hwdata;
                    Write_Pending <= 1;
                end
                
                else if (drv2dut.HTRANS == 2'b00)  //T_IDLE
                begin
                    if(Write_Pending == 1)
                    begin
                        drv_intf.ahb_driver_cb.HWDATA   <= temp_Hwdata;
                        Write_Pending   <= 0;
                    end
                end
            end 
        end
        `uvm_info(get_type_name,$sformatf("AHB driver Delivered Tx: \n%s" ,drv2dut.sprint()),UVM_MEDIUM)
    endtask
endclass
