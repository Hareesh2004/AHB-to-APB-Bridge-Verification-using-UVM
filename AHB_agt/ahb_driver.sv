class ahb_driver extends uvm_driver #(ahb_xtn) ;

        `uvm_component_utils(ahb_driver)

        virtual ahb2apb_if.ahb_drv_mp vif;

        ahb_agent_config m_cfg;



function new(string name = "ahb_driver", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_agent_config)::get(this, "", "ahb_agent_config", m_cfg))
                `uvm_fatal("CONFIG", "cannot get() method")
endfunction

function void connect_phase(uvm_phase phase);
        vif = m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 0;
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1;
        forever
                begin
                        seq_item_port.get_next_item(req);
                        send_to_dut(req);
                        seq_item_port.item_done();
                end
endtask

task send_to_dut(ahb_xtn xtn);
        `uvm_info("AHB_DRIVER", $sformatf("printing from driver \n %s",xtn.sprint()), UVM_LOW)
        wait(vif.ahb_drv_cb.Hreadyout!== 1'b1)
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Htrans <= xtn.Htrans;
        vif.ahb_drv_cb.Haddr <= xtn.Haddr;
        vif.ahb_drv_cb.Hsize <= xtn.Hsize;
        vif.ahb_drv_cb.Hburst <= xtn.Hburst;
        vif.ahb_drv_cb.Hwrite <= xtn.Hwrite;
	vif.ahb_drv_cb.Hreadyin <= 1'b1;
        @(vif.ahb_drv_cb);
        wait(vif.ahb_drv_cb.Hreadyout !== 1'b1)
        @(vif.ahb_drv_cb);
        if(xtn.Hwrite == 1'b1)
                vif.ahb_drv_cb.Hwdata <= xtn.Hwdata;
        else
                vif.ahb_drv_cb.Htrans <= 32'b0;
                `uvm_info(get_type_name(),"this is driver",UVM_LOW)
                xtn.print();
endtask
endclass

