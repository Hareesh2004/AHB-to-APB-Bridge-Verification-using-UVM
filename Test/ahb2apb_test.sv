class ahb2apb_test extends uvm_test;

        `uvm_component_utils(ahb2apb_test)

        ahb2apb_env env;
        ahb2apb_env_config e_cfg;
        ahb_agent_config ahb_cfg[];
        apb_agent_config apb_cfg[];

        bit has_ahb_agent = 1;
        bit has_apb_agent = 1;
        int no_of_ahb_agent = 1;
        int no_of_apb_agent = 1;

        extern function new(string name = "ahb2apb_test", uvm_component parent);
        extern function void config_ahb2apb();
        extern function void build_phase(uvm_phase phase);
        extern function void end_of_elaboration_phase(uvm_phase phase);

endclass

//constructor
function ahb2apb_test::new(string name = "ahb2apb_test", uvm_component parent);
        super.new(name, parent);
endfunction

//config router
function void ahb2apb_test::config_ahb2apb();
        if(has_ahb_agent)
                begin
                        ahb_cfg = new[no_of_ahb_agent];
                        foreach(ahb_cfg[i])
                                begin
                                        ahb_cfg[i] = ahb_agent_config::type_id::create($sformatf("ahb_cfg[%0d]", i));
                                        if(!uvm_config_db #(virtual ahb2apb_if)::get(this, "", "vif_ahb", ahb_cfg[i].vif))
                                                `uvm_fatal("VIF CONFIG.WRITE", "cannot get cfg")
                                        ahb_cfg[i].is_active = UVM_ACTIVE;
                                        e_cfg.ahb_agt_cfg[i] = ahb_cfg[i];
                                end
                end

if(has_apb_agent)
                begin
                        apb_cfg = new[no_of_apb_agent];
			 foreach(apb_cfg[i])
                                begin
                                        apb_cfg[i] = apb_agent_config::type_id::create($sformatf("apb_cfg[%0d]", i));
                                        if(!uvm_config_db #(virtual ahb2apb_if)::get(this, "", "vif_apb", apb_cfg[i].vif))
                                                `uvm_fatal("VIF CONFIG . READ", "cannot get the cfg")
                                        apb_cfg[i].is_active = UVM_ACTIVE;
                                        e_cfg.apb_agt_cfg[i] = apb_cfg[i];
                                end
                end

        e_cfg.has_ahb_agent = has_ahb_agent;
        e_cfg.has_apb_agent = has_apb_agent;
        e_cfg.no_of_ahb_agent = no_of_ahb_agent;
        e_cfg.no_of_apb_agent = no_of_apb_agent;
endfunction

//build phase
function void ahb2apb_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
        e_cfg = ahb2apb_env_config::type_id::create("e_cfg");
        if(has_ahb_agent)
                begin
                        e_cfg.ahb_agt_cfg = new[no_of_ahb_agent];
                end
        if(has_apb_agent)
                begin
                        e_cfg.apb_agt_cfg = new[no_of_apb_agent];
                end

        config_ahb2apb();
        uvm_config_db #(ahb2apb_env_config)::set(this, "*", "ahb2apb_env_config", e_cfg);
        env = ahb2apb_env::type_id::create("env", this);
endfunction

function void ahb2apb_test::end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
                uvm_top.print_topology();
endfunction


class single_test extends ahb2apb_test;

        `uvm_component_utils(single_test)

        single_seq single_seqh;

        extern function new(string name = "single_test", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

endclass

//constructor
function single_test::new(string name = "single_test", uvm_component parent);
        super.new(name, parent);
endfunction

//build phase
function void single_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TOPOLOGY", "Printing UVM component hierarchy", UVM_LOW)
    uvm_top.print_topology();
endfunction

//run phase
task single_test::run_phase(uvm_phase phase);
phase.raise_objection(this);
        single_seqh = single_seq::type_id::create("single_seqh");
        single_seqh.start(env.ahb_agt_top.agnth[0].m_seqr);
        phase.drop_objection(this);
endtask


class INC_test extends ahb2apb_test;

        `uvm_component_utils(INC_test)
	INC_sequence INC_seqh;

        extern function new(string name = "INC_test", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

endclass

//constructor
function INC_test::new(string name = "INC_test", uvm_component parent);
        super.new(name, parent);
endfunction

//build phase
function void INC_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
`uvm_info("TOPOLOGY", "Printing UVM component hierarchy", UVM_LOW)
    uvm_top.print_topology();
endfunction

//run phase
task INC_test::run_phase(uvm_phase phase);
phase.raise_objection(this);
        INC_seqh = INC_sequence::type_id::create("INC_seqh");
        INC_seqh.start(env.ahb_agt_top.agnth[0].m_seqr);
        phase.drop_objection(this);
endtask


class WRAP_test extends ahb2apb_test;

        `uvm_component_utils(WRAP_test)

        WRAP_sequence WRAP_seqh;

        extern function new(string name = "WRAP_test", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

//constructor
function WRAP_test::new(string name = "WRAP_test", uvm_component parent);
        super.new(name, parent);
endfunction

//build phase
function void WRAP_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
`uvm_info("TOPOLOGY", "Printing UVM component hierarchy", UVM_LOW)
    uvm_top.print_topology();
endfunction

//run phase
task WRAP_test::run_phase(uvm_phase phase);
phase.raise_objection(this);
        WRAP_seqh = WRAP_sequence::type_id::create("WRAP_seqh");
        WRAP_seqh.start(env.ahb_agt_top.agnth[0].m_seqr);
        phase.drop_objection(this);
endtask

