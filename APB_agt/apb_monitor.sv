class apb_monitor extends uvm_monitor;

        `uvm_component_utils(apb_monitor)

        virtual ahb2apb_if.apb_mon_mp vif;

        apb_agent_config m_cfg;
        uvm_analysis_port #(apb_xtn) monitor_port;

//constructor
function new(string name = "apb_monitor", uvm_component parent);
        super.new(name, parent);
endfunction

//build phase
function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(apb_agent_config)::get(this, "", "apb_agent_config", m_cfg))
                `uvm_fatal("CONFIG", "cannot get cfg")
endfunction

function void connect_phase(uvm_phase phase);
vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
forever
begin
collect_data;
end
endtask

task collect_data();
apb_xtn mon_data;
mon_data=apb_xtn::type_id::create("mon_data");
wait(vif.apb_mon_cb.Penable)
mon_data.Paddr=vif.apb_mon_cb.Paddr;
mon_data.Pwrite=vif.apb_mon_cb.Pwrite;
mon_data.Pselx=vif.apb_mon_cb.Pselx;
if(mon_data.Pwrite)
mon_data.Pwdata = vif.apb_mon_cb.Pwdata;
else
mon_data.Prdata = vif.apb_mon_cb.Prdata;
@(vif.apb_mon_cb);
`uvm_info("ROUTER_RD_MONITOR",$sformatf("printing from monitor \n %s",mon_data.sprint()),UVM_LOW)
monitor_port.write(mon_data);
endtask

endclass

