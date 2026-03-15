class coverage_mon extends uvm_subscriber #(trace#(3));
    `uvm_component_utils(coverage_mon)

    trace#(3) tx;

    virtual intf vif;

    real cov;


    covergroup cg0;
        coverpoint tx.opCode {bins allOp[14] = {[0:13]};}
        coverpoint tx.targetCore {bins allCores[3] = {[0:2]};}
        coverpoint tx.rd {bins allDest = {[0:31]};}
        coverpoint tx.rs {bins allSource = {[0:31]};}
        coverpoint tx.rt {bins allTarget = {[0:31]};}
        coverpoint tx.rst;
    endgroup

    function new(string name = "coverage_mon", uvm_component parent = null);
        super.new(name, parent);

        tx = trace#(3)::type_id::create("tx");

        cg0 = new();
    endfunction

    virtual function void write(trace#(3) t);
        `uvm_info(get_type_name(), "Reading data from monitor for coverage", UVM_HIGH)
        tx = t;

        cg0.sample();
        cov = cg0.get_coverage();
        `uvm_info(get_full_name(), $sformatf("Coverage is %d", cov), UVM_HIGH)
    endfunction 
endclass


