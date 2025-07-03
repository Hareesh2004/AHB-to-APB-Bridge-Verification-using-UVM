class ahb_monitor extends uvm_monitor;

        `uvm_component_utils(ahb_monitor)

        virtual ahb2apb_if.ahb_mon_mp vif;
        ahb_agent_config m_cfg;
        uvm_analysis_port #(ahb_xtn) monitor_port;

//constructor
function new(string name = "ahb_monitor", uvm_component parent);
        super.new(name, parent);
        monitor_port = new("monitor_port", this);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_agent_config)::get(this, "", "ahb_agent_config", m_cfg))
                `uvm_fatal("CONFIG", "cannot get m_cfg")
endfunction

function void connect_phase(uvm_phase phase);
        vif = m_cfg.vif;
endfunction

task collect_data();
        ahb_xtn mon_data;
//      begin
                mon_data = ahb_xtn::type_id::create("mon_data");
                wait(vif.ahb_mon_cb.Hreadyout !== 1'b1)
                @(vif.ahb_mon_cb);
                wait(vif.ahb_mon_cb.Htrans !== 2'b11 && vif.ahb_mon_cb.Htrans == 2'b10 )
                @(vif.ahb_mon_cb);
                begin
                mon_data.Haddr = vif.ahb_mon_cb.Haddr;
                mon_data.Htrans = vif.ahb_mon_cb.Htr !==1'b1ans;
                mon_data.Hwrite = vif.ahb_mon_cb.Hwrite;
                mon_data.Hsize = vif.ahb_mon_cb.Hsize;
                mon_data.Hburst = vif.ahb_mon_cb.Hburst;
                @(vif.ahb_mon_cb);
                wait(vif.ahb_mon_cb.Hreadyout !==1'b1)
                @(vif.ahb_mon_cb);
                if(vif.ahb_mon_cb.Hwrite)
                        mon_data.Hwdata = vif.ahb_mon_cb.Hwdata;
                else
                        mon_data.Hrdata = vif.ahb_mon_cb.Hrdata;
                 mon_data.print();       
                `uvm_info("ROUTER_WR_MONITOR", $sformatf("printing from monitor \n %s", mon_data.sprint()), UVM_LOW)
                monitor_port.write(mon_data);
        end
endtask

task run_phase(uvm_phase phase);
        forever
                collect_data();
endtask

endclass

