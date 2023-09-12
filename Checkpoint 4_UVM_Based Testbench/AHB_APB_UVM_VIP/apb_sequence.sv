// Basic APB Sequence class that generates random APB transactions.
class apb_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "apb_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate random APB transactions.
    task body();
        repeat(N_TX)  begin
            req = apb_sequence_item::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask
endclass

// APB Random Sequence class that generates specific APB transactions based on PSLVERR values.
class apb_random_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_random_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "apb_random_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific APB transactions.
    virtual task body();
        begin
            // Generate sequences with PSLVERR=0 for N_TX - 8 times.
            repeat(N_TX - 8) begin
                req = apb_sequence_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
            
            // Generate sequences with PSLVERR=1 for 10 times.
            repeat(10) begin
                req = apb_sequence_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b1;});
                finish_item(req);
            end

            // Generate a final sequence with PSLVERR=0.
            req = apb_sequence_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {req.PSLVERR == 8'b0;});
            finish_item(req);
        end
    endtask
endclass

// APB Single Write Sequence class to generate specific write transactions.
class apb_single_write_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_single_write_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "apb_single_write_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific write APB transactions.
    virtual task body();
        begin
            // Generate write sequences with PSLVERR=0 for 3 times.
            repeat(3) begin
                req = apb_sequence_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
        end
    endtask
endclass

// APB Single Read Sequence class to generate specific read transactions.
class apb_single_read_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_single_read_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "apb_single_read_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific read APB transactions.
    virtual task body();
        begin
            // Generate read sequences with PSLVERR=0 for 3 times.
            repeat(3) begin
                req = apb_sequence_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
        end
    endtask
endclass

// APB Burst Write Sequence class to generate specific burst write transactions.
class apb_burst_write_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_burst_write_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "apb_burst_write_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific burst write APB transactions.
    virtual task body();
        begin
            // Generate burst write sequences with PSLVERR=0 for N_TX + 3 times.
            repeat(N_TX + 3) begin
                req = apb_sequence_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
        end
    endtask
endclass

// APB Burst Read Sequence class to generate specific burst read transactions.
class apb_burst_read_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_burst_read_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "apb_burst_read_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific burst read APB transactions.
    virtual task body();
        begin
            // Generate burst read sequences with PSLVERR=0 for N_TX + 2 times.
            repeat(N_TX + 2) begin
                req = apb_sequence_item::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
        end
    endtask
endclass
