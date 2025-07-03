class ahb_seq extends uvm_sequence #(ahb_xtn);

        `uvm_object_utils(ahb_seq)

bit [31:0] haddr,start_address,Boundary_address;
        bit hwrite;
        bit [2:0] hsize;
        bit [2:0] hburst;
        bit[9:0]hlength;

function new(string name = "ahb_seq");
        super.new(name);
endfunction
endclass

class single_seq extends ahb_seq;

        `uvm_object_utils(single_seq)

function new(string name = "single_seq");
        super.new(name);
endfunction

task body();
req = ahb_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {Htrans == 2'b10 && Hburst == 3'b0;});
`uvm_info("SINGLE SEQ","printing from single sequence of AHB bus",UVM_LOW)
req.print;
finish_item(req);
        haddr = req.Haddr;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hwrite = req.Hwrite;
endtask
endclass

class INC_sequence extends ahb_seq;
 `uvm_object_utils(INC_sequence)

bit [31:0] haddr,start_address,Boundary_address;
        bit hwrite;
        bit [2:0] hsize;
        bit [2:0] hburst;
	 bit[9:0]hlength;

function new(string name = "INC_sequence");
        super.new(name);
endfunction

task body();
req = ahb_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {Htrans==2'b10;
                                Hburst inside {3,5,7};});
finish_item(req);
        haddr = req.Haddr;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hwrite = req.Hwrite;
        hlength = req.Hlength;


for(int i=1; i<hlength; i++)
begin
start_item(req);
assert(req.randomize() with {Htrans==2'b11;
                                Hburst==hburst;
                                Hsize==hsize;
                                Hwrite==hwrite;
                                Haddr==haddr+(2**hsize);});
req.print;
finish_item(req);
haddr = req.Haddr;
end
endtask
endclass

class WRAP_sequence extends ahb_seq;
 `uvm_object_utils(WRAP_sequence)

bit [31:0] haddr,start_address,Boundary_address;
        bit hwrite;
        bit [2:0] hsize;
        bit [2:0] hburst;
        bit[9:0]hlength;
	function new(string name = "WRAP_sequence");
        super.new(name);
endfunction

task body();
req = ahb_xtn::type_id::create("req");
start_item(req);
assert(req.randomize() with {Htrans==2'b10;
                                Hburst inside {6};});
finish_item(req);
        haddr = req.Haddr;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hwrite = req.Hwrite;
        hlength = req.Hlength;

start_address = int'((haddr/((2**hsize)*(hlength))) * (2**hsize)*hlength);
Boundary_address = start_address+((2**hsize)*hlength);


$display("start_address =%p", start_address);

$display("Boundary_address =%p", Boundary_address);

$display("H_address =%p", haddr);


haddr = req.Haddr + (2**hsize);
for(int i=1;i<hlength;i++)
begin
if(Boundary_address == haddr)
 haddr=start_address;
start_item(req);
assert(req.randomize() with {Htrans == 2'b11;
                                Hburst==hburst;
                                Hsize==hsize;
                                Hwrite==hwrite;
                                Haddr==haddr;});
req.print;
finish_item(req);
haddr=req.Haddr+(2**hsize);
end
endtask
endclass

