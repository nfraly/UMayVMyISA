class coreTest extends uvm_test;
    `uvm_component_utils(coreTest);

    function new(string name = "coreTest", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    env e0;
    reg_item testObj;
    virtual intf vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        e0 = env::type_id::create("e0", this);

        if (!uvm_config_db#(virtual intf)::get(this, null, "intf", vif))
            `uvm_fatal("TEST", "Did not get vif");
        uvm_config_db#(virtual intf)::set(this, "e0.a0.*", "intf", vif);

        //some setup here we aren't ready for

        testObj = gen_item_seq::type_id::create("testObj");
        testObj.randomize();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        apply_reset(); //define reset pattern
        seq.start(e0.a0.s0)l //define this
        repeat(SOMEAMOUNTOFTIME);
        phase.drop_objection(this);
    endtask

    virtual task apply_reset();
        //define this later
        DEFINEMENOW;
    endtask

endclass
