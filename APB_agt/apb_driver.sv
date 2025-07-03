class apb_driver extends uvm_driver ;

        `uvm_component_utils(apb_driver)

        virtual ahb2apb_if.apb_drv_mp vif;

        apb_agent_config m_cfg;


function new(string name = "apb_driver", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(apb_agent_config)::get(this, "", "apb_agent_config", m_cfg))
                `uvm_fatal("CONFIG", "cannot get m_cfg")
endfunction

function void connect_phase(uvm_phase phase);
vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
apb_xtn xtn;
forever
begin
send_to_dut(xtn);
end
endtask

task send_to_dut(apb_xtn xtn);
begin
`uvm_info("APB_DRIVER", $sformatf("printing from driver \n %s", xtn.sprint()), UVM_LOW)
wait(vif.apb_drv_cb.Pselx != 0)
if(!vif.apb_drv_cb.Pwrite)
wait(vif.apb_drv_cb.Penable)
vif.apb_drv_cb.Prdata <= {$urandom};
repeat(2)  @(vif.apb_drv_cb);
xtn.print();
end
endtask
endclass

