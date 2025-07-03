class ahb2apb_scoreboard extends uvm_scoreboard;

        `uvm_component_utils(ahb2apb_scoreboard)

        uvm_tlm_analysis_fifo #(ahb_xtn) fifo_ahb[];
        uvm_tlm_analysis_fifo #(apb_xtn) fifo_apb[];


        ahb_xtn ahb_cov_data;
        apb_xtn apb_cov_data;

        ahb2apb_env_config e_cfg;

        //int data_verified_count;

     // ahb_xtn q[$];

        extern function new(string name = "ahb2apb_scoreboard", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern function void check_data(apb_xtn xtn);
        extern function void compare_data(int Hdata, Pdata, Haddr, Paddr);

//coverage
covergroup ahb_fcov;
                option.per_instance = 1;
                SIZE: coverpoint ahb_cov_data.Hsize {bins b2[] = {[0:2]} ;}
                TRANS: coverpoint ahb_cov_data.Htrans {bins trans[] = {[0:3]} ;}
                ADDR: coverpoint ahb_cov_data.Haddr {bins first_slave = {[32'h8000_0000:32'h8000_03ff]} ;
                                                     bins second_slave = {[32'h8400_0000:32'h8400_03ff]};
                                                     bins third_slave = {[32'h8800_0000:32'h8800_03ff]};
                                                     bins fourth_slave = {[32'h8c00_0000:32'h8c00_03ff]};}
        endgroup


covergroup apb_fcov;
                option.per_instance = 1;
                ADDR : coverpoint apb_cov_data.Paddr {bins first_slave = {[32'h8000_0000:32'h8000_03ff]};
                                                      bins second_slave = {[32'h8400_0000:32'h8400_03ff]};
                                                      bins third_slave = {[32'h8800_0000:32'h8800_03ff]};
                                                      bins fourth_slave = {[32'h8c00_0000:32'h8c00_03ff]};}

                SEL : coverpoint apb_cov_data.Pselx {bins first_slave = {4'b0001};
                                                     bins second_slave = {4'b0010};
						     bins third_slave = {4'b0100};
                                                     bins fourth_slave = {4'b1000};}

        endgroup
endclass
//constructor
function ahb2apb_scoreboard::new(string name = "ahb2apb_scoreboard", uvm_component parent);
        super.new(name, parent);
        ahb_fcov = new();
        apb_fcov = new();
        ahb_cov_data = new();
        apb_cov_data = new();
endfunction

//build phase
function void ahb2apb_scoreboard::build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb2apb_env_config)::get(this, "", "ahb2apb_env_config", e_cfg))
                `uvm_fatal("EN_cfg", "no update")
        ahb_data = ahb_xtn::type_id::create("ahb_data", this);
        apb_data = apb_xtn::type_id::create("apb_data", this);

        fifo_ahb = new[e_cfg.no_of_ahb_agent];
        foreach(fifo_ahb[i])
                begin
                        fifo_ahb[i] = new($sformatf("fifo_ahb[%0d]", i), this);
                end
        fifo_apb = new[e_cfg.no_of_apb_agent];
        foreach(fifo_apb[i])
                begin
                        fifo_apb[i] = new($sformatf("fifo_apb[%0d]", i), this);
                end
endfunction

//run phase
task ahb2apb_scoreboard::run_phase(uvm_phase phase);

                        forever
                                begin
                                fork
                                begin
                                        fifo_ahb[0].get(ahb_cov_data);
					`uvm_info("WRITE SB", "write data", UVM_LOW)
                                        ahb_cov_data.print;
                                        //q.push_back(ahb_data);
                                        ahb_fcov.sample();
                                end

                                                begin
                                                        fifo_apb[0].get(apb_cov_data);
                                                        `uvm_info("READ SB[0]", "read data", UVM_LOW)
                                                        apb_cov_data.print;
                                                        check_data(ahb_cov_data,apb_cov_data);
                                                        apb_fcov.sample();
                                                end
                                        join
                end
endtask

//check data
function void ahb2apb_scoreboard::check_data(ahb_xtn ahb_cov_data,apb_xtn apb_cov_data);
        $display("I am in scoreboard %p",q);
        if(ahb_cov_data.Hwrite)
                begin
                        case(ahb_cov_data.Hsize)
                                2'b00 : begin
                                                if(ahb_cov_data.Haddr[1:0] == 2'b00)
                                                        compare_data(ahb_cov_data.Hwdata[7:0], apb_cov_data.Pwdata[7:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b01)
                                                        compare_data(ahb_cov_data.Hwdata[15:8], apb_cov_data.Pwdata[7:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b10)
                                                        compare_data(ahb_cov_data.Hwdata[23:16], apb_cov_data.Pwdata[7:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov__data.Haddr[1:0] == 2'b11)
                                                        compare_data(ahb_cov_data.Hwdata[31:24], apb_cov_data.Pwdata[7:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                        end
                                2'b01 : begin
                                                if(ahb_cov_data.Haddr[1:0] == 2'b00)
						 compare_data(ahb_cov_data.Hwdata[15:0], apb_cov_data.Pwdata[15:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b10)
                                                        compare_data(ahb_cov_data.Hwdata[31:16], apb_cov_data.Pwdata[15:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                        end
                                2'b10 : begin
                                                compare_data(ahb_cov_data.Hwdata[31:0], apb_cov_data.Pwdata[31:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                        end
                        endcase
                end
        else
                begin
                        case(ahb_cov_data.Hsize)
                                2'b00 : begin
                                                if(ahb_cov_data.Haddr[1:0] == 2'b00)
                                                        compare_data(ahb_cov_data.Hrdata[7:0], apb_cov_data.Prdata[7:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b01)
                                                        compare_data(ahb_cov_data.Hrdata[7:0], apb_cov_data.Prdata[15:8], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b10)
                                                        compare_data(ahb_cov_data.Hrdata[7:0], apb_cov_data.Prdata[23:16], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b11)
                                                        compare_data(ahb_cov_data.Hrdata[7:0], apb_cov_data.Prdata[31:24], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                        end
                                2'b01 : begin
                                                if(ahb_cov_data.Haddr[1:0] == 2'b00)
                                                        compare_data(ahb_cov_data.Hrdata[15:0], apb_cov_data.Prdata[15:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                                if(ahb_cov_data.Haddr[1:0] == 2'b10)
                                                        compare_data(ahb_cov_data.Hrdata[15:0], apb_cov_data.Prdata[31:16], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                        end
                                2'b10 : begin
                                                compare_data(ahb_cov_data.Hrdata[31:0], apb_cov_data.Prdata[31:0], ahb_cov_data.Haddr, apb_cov_data.Paddr);
                                        end
                        endcase

                end
endfunction
function void ahb2apb_scoreboard::compare_data(int Hdata, Pdata, Haddr, Paddr);
        if(ahb_cov_data.Haddr == apb_cov_data.Pdata)
                `uvm_info("SB", "ADDRESS MATCHED SUCCESSFULLY", UVM_LOW)
        else
                `uvm_info("SB", "ADDRESS MATCHING FAILED",UVM_LOW)
        if(ahb_cov_data.Hwrite)
        begin
                if(Hdata == Pdata)
                `uvm_info("SB", "READ DATA MATCHED SUCCESSFULLY", UVM_LOW)
        else
                `uvm_info("SB", "READ DATA MATCHING FAILED",UVM_LOW)
        end
//      data_verified_count++;
                ahb_fcov.sample();
                apb_fcov.sample();
endfunction

