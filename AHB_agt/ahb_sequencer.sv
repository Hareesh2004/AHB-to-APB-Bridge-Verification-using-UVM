class ahb_sequencer extends uvm_sequencer #(ahb_xtn) ;

        `uvm_component_utils(ahb_sequencer)

        extern function new(string name = "ahb_sequencer", uvm_component parent);

endclass

//constructor
function ahb_sequencer::new(string name = "ahb_sequencer", uvm_component parent);
        super.new(name, parent);
endfunction

