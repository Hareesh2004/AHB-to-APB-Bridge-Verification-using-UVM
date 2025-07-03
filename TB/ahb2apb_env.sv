class ahb2apb_env extends uvm_env;

        `uvm_component_utils(ahb2apb_env)

        ahb_agent_top ahb_agt_top;
        apb_agent_top apb_agt_top;

        ahb2apb_env_config m_cfg;

        extern function new(string name = "ahb2apb_env", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        //extern function void end_of_elaboration_phase(uvm_phase phase);       

endclass

//constructor
function ahb2apb_env::new(string name = "ahb2apb_env", uvm_component parent);
        super.new(name, parent);
endfunction

//build phase
function void ahb2apb_env::build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb2apb_env_config)::get(this, "", "ahb2apb_env_config", m_cfg))
                `uvm_fatal("CONFIG", "cannot get m_cfg")
        if(m_cfg.has_ahb_agent)
                begin
                        ahb_agt_top = ahb_agent_top::type_id::create("ahb_agt_top", this);
                end
        if(m_cfg.has_apb_agent)
                begin
                        apb_agt_top = apb_agent_top::type_id::create("apb_agt_top", this);
                end
endfunction


