package pack;
import uvm_pkg::*;
`include "uvm_macros.svh";

//class uvm_sequence_item extends uvm_transaction--> Not a virtual class (object)
class my_seq_item extends uvm_sequence_item;
`uvm_object_utils(my_seq_item);
function new(string name="my_seq_item");
super.new(name);
endfunction 
rand bit reset;
rand bit valid_in;
rand bit[127:0]plain_text_128;
rand bit[127:0]cipher_key_128;
bit[127:0]cipher_text_128;
bit valid_out;
//constraints 
constraint C{
    reset dist{1:/90,0:/10};
    valid_in dist{1:/90,0:/10};
}
endclass 

class reset_sequence extends uvm_sequence;
`uvm_object_utils(reset_sequence);
my_seq_item seq;
function new(string name="reset_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b0;
finish_item(seq);
endtask 
endclass

class valid_sequence extends uvm_sequence;
`uvm_object_utils(valid_sequence);
my_seq_item seq;
function new(string name="valid_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.valid_in=1'b1;
finish_item(seq);
endtask 
endclass 

class random_sequence extends uvm_sequence;
`uvm_object_utils(random_sequence);
my_seq_item seq;
function new(string name="random_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
repeat(30)begin
start_item(seq);
assert(seq.randomize());
finish_item(seq);
end 
endtask 
endclass 

class all_zeros_sequence extends uvm_sequence;
`uvm_object_utils(all_zeros_sequence);
my_seq_item seq;
function new(string name="all_zeros_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.cipher_key_128=0;
seq.plain_text_128=0;
finish_item(seq);
endtask 
endclass 

class all_ones_sequence extends uvm_sequence;
`uvm_object_utils(all_ones_sequence);
my_seq_item seq;
function new(string name="all_ones_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.cipher_key_128=128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
seq.plain_text_128=128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
finish_item(seq);
endtask 
endclass

class repeated_key_sequence extends uvm_sequence; //same key different data_in
`uvm_object_utils(repeated_key_sequence);
my_seq_item seq;
function new(string name="repeated_key_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.plain_text_128=128'h00112233445566778899AABBCCDDEEFF;
seq.cipher_key_128=128'd340;
finish_item(seq);

start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.plain_text_128=128'h00112233445566778899AABBCCDDEEAA;
seq.cipher_key_128=128'd340;
finish_item(seq);
endtask 
endclass 

class consecutive_key_sequence extends uvm_sequence; //same key different data_in
`uvm_object_utils(consecutive_key_sequence);
my_seq_item seq;
function new(string name="consecutive_key_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.cipher_key_128=128'd500;
finish_item(seq);

start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.cipher_key_128=128'd501;
finish_item(seq);
endtask 
endclass 

class alternating_sequence extends uvm_sequence; //same key different data_in
`uvm_object_utils(alternating_sequence);
my_seq_item seq;
function new(string name="alternating_sequence");
super.new(name);
endfunction 
//No build phase here but we need to create the sequence item 
task pre_body;
seq=my_seq_item::type_id::create("seq");
endtask 

task body;
start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.plain_text_128=128'h55555555555555555555555555555555;
seq.cipher_key_128=128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
finish_item(seq);

start_item(seq);
assert(seq.randomize());
seq.reset=1'b1; //reset is disabled 
seq.plain_text_128=128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
seq.cipher_key_128=128'h55555555555555555555555555555555;
finish_item(seq);
endtask 
endclass 



//class uvm_driver #(type REQ=uvm_sequence_item,type RSP=REQ) extends uvm_component;
// uvm_seq_item_pull_port #(REQ, RSP) seq_item_port;
class driver extends uvm_driver #(my_seq_item);//--> child class extended from uvm_seq_item
`uvm_component_utils(driver);
//uvm_seq_item_pull_port #(REQ, RSP) seq_item_port;
my_seq_item seq;
virtual intf vif;

function new(string name= "driver", uvm_component parent=null);
super.new(name,parent);
endfunction

//function void uvm_component::build_phase(uvm_phase phase);
function void build_phase(uvm_phase phase);
super.build_phase(phase);
seq=my_seq_item::type_id::create("seq");

if(!uvm_config_db #(virtual intf)::get(this,"","driver_vif",vif))
`uvm_fatal("build_phase", "Driver unable to get vif");
endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
seq_item_port.get_next_item(seq);  
@(posedge vif.cb_drv); //non_blocking + clocking block
vif.cb_drv.reset<=seq.reset;
vif.cb_drv.valid_in<=seq.valid_in;
vif.cb_drv.plain_text_128<=seq.plain_text_128;
vif.cb_drv.cipher_key_128<=seq.cipher_key_128;
seq_item_port.item_done();
end
endtask 
endclass 

// uvm_seq_item_pull_imp #(REQ, RSP, this_type) seq_item_export;
class sequencer extends uvm_sequencer #(my_seq_item);
`uvm_component_utils(sequencer);
// uvm_seq_item_pull_imp #(REQ, RSP, this_type) seq_item_export;
my_seq_item seq;

function new(string name= "sequencer", uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
seq=my_seq_item::type_id::create("seq");

endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction
endclass 

class Monitor extends uvm_monitor;
`uvm_component_utils(Monitor);
//class uvm_analysis_port # (type T = int) extends uvm_port_base # (uvm_tlm_if_base #(T,T));
uvm_analysis_port #(my_seq_item) my_analysis_port;
my_seq_item seq;
virtual intf vif;

function new(string name= "Monitor", uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
seq=my_seq_item::type_id::create("seq");

my_analysis_port=new("my_analysis_port",this); //same as uvm_component 

if(!uvm_config_db #(virtual intf)::get(this,"","mon_vif",vif))
`uvm_fatal("build_phase", "Monitor unable to get vif");
endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction

virtual task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
@(posedge vif.cb_mon);
seq.reset=vif.reset;
seq.valid_in=vif.valid_in;
seq.cipher_key_128=vif.cipher_key_128;
seq.plain_text_128=vif.plain_text_128;
//O-U-T-P-U-T-S
seq.cipher_text_128=vif.cipher_text_128;
seq.valid_out=vif.valid_out;
my_analysis_port.write(seq);
end 
endtask 
endclass 

class agent extends uvm_agent;
`uvm_component_utils(agent);
uvm_analysis_port #(my_seq_item) my_analysis_port;
driver my_driver;
Monitor my_mon;
sequencer my_sequencer;
virtual intf vif;

function new(string name= "agent", uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
my_driver=driver::type_id::create("my_driver",this);
my_mon=Monitor::type_id::create("my_mon",this);
my_sequencer=sequencer::type_id::create("my_sequencer",this);

my_analysis_port=new("my_analysis_port",this);

if(!uvm_config_db #(virtual intf)::get(this,"","agent_vif",vif))
`uvm_fatal("build_phase", "Scoreboard unable to get vif");

uvm_config_db #(virtual intf)::set(this,"my_driver","driver_vif",vif);
uvm_config_db #(virtual intf)::set(this,"my_mon","mon_vif",vif);
endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
my_mon.my_analysis_port.connect(my_analysis_port); 
my_driver.seq_item_port.connect(my_sequencer.seq_item_export);
endfunction
endclass 

class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard);
uvm_analysis_imp #(my_seq_item,scoreboard) my_analysis_import;
my_seq_item seq;
////Golden Model variables 
bit[127:0]exp_out;
int fd;
int fscanf_ret;
int ret;
int error_count=0;
int correct_count=0;
bit [127:0]exp_out_ref;
bit [127:0] aes_queue[$];

function new(string name= "scoreboard", uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
seq=my_seq_item::type_id::create("seq");


my_analysis_import=new("my_analysis_import",this);
endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction

task write (my_seq_item t);
if(t.reset==0)begin
exp_out=0;
exp_out_ref=0;
aes_queue.delete();
 if (exp_out_ref === t.cipher_text_128) begin
      correct_count++;
    end else begin
      error_count++;
      `uvm_error("SCOREBOARD", $sformatf("FAILURE: DUT output=%0h != Expected output=%0h", t.cipher_text_128, exp_out_ref))
    end
end
else begin
  if(t.valid_in==1)begin//if valid_in=1--> Go to pythin code 
// Open file for writing input and key
    fd = $fopen("key.txt", "w");
    if (fd == 0) begin
      `uvm_error("SCOREBOARD", "Failed to open key.txt for writing")
      return;
    end

    $fdisplay(fd, "%h\n%h", t.plain_text_128, t.cipher_key_128);
    $fclose(fd);

    // Run the python script (blocking)
    ret = $system("python refrence_model.py");

    // Open output file for reading
    fd = $fopen("output.txt", "r");
    if (fd == 0) begin
      `uvm_error("SCOREBOARD", "Failed to open output.txt for reading")
      return;
    end

    fscanf_ret = $fscanf(fd, "%h", exp_out);
    $fclose(fd);

    if (fscanf_ret != 1) begin
      `uvm_error("SCOREBOARD", "Failed to read expected output")
      return;
    end
    //push dut outputs into queue
    aes_queue.push_back(exp_out);
  end 
    //only compares if valid_out=1 so that o/p passed through the register 
    if(t.valid_out==1)
    if (aes_queue.size() == 0) begin
        `uvm_error("SCOREBOARD", "No expected value available for comparison")
    end
    else begin
    exp_out_ref=aes_queue.pop_front();
    // Compare expected output with DUT output
    if (exp_out_ref === t.cipher_text_128) begin
      correct_count++;
    end else begin
      `uvm_error("SCOREBOARD", $sformatf("FAILURE: DUT output=%0h != Expected output=%0h,RESET=%0d", t.cipher_text_128, exp_out_ref,t.reset))
      error_count++;
    end
    end 
end 
endtask

function void report_phase(uvm_phase phase);
super.report_phase(phase);
`uvm_info("report_phase",$sformatf("Total successful Transactions :%0d",correct_count),UVM_MEDIUM);
`uvm_info("report_phase",$sformatf("Total failed Transactions :%0d",error_count),UVM_MEDIUM);
endfunction
endclass 

//virtual class uvm_subscriber #(type T=int) extends uvm_component;
class subscriber extends uvm_subscriber #(my_seq_item);
`uvm_component_utils(subscriber);
//uvm_analysis_imp #(T, this_type) analysis_export;
uvm_analysis_imp #(my_seq_item,subscriber) my_analysis_import;
my_seq_item seq;

 // Define coverage group
covergroup g1;
valid_in_cp: coverpoint seq.valid_in;
reset_cp: coverpoint seq.reset;
plain_text_128_cp:coverpoint seq.plain_text_128 {
    bins alt_1010 = {128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA}; // 1010 repeating pattern
    bins alt_0101 = {128'h55555555555555555555555555555555}; // 0101 repeating pattern
    bins min={0};
    bins max={128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF};
  }
cipher_key_128_cp: coverpoint seq.cipher_key_128{
    bins alt_1010_key = {128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA}; // 1010 repeating pattern
    bins alt_0101_key = {128'h55555555555555555555555555555555}; // 0101 repeating pattern
    bins min_key={0};
    bins max_key={128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF};
}
plain_text_key_cc:cross cipher_key_128_cp,plain_text_128_cp{
    bins mix_alt_1= binsof(plain_text_128_cp.alt_1010) && binsof(cipher_key_128_cp.alt_0101_key);
    bins mix_alt_2= binsof(plain_text_128_cp.alt_0101) && binsof(cipher_key_128_cp.alt_1010_key);
    option.cross_auto_bin_max=0;
}
endgroup

function new(string name= "subscriber", uvm_component parent=null);
super.new(name,parent);
g1=new;
endfunction

//pure virtual function void write(T t);-->since its pure so must be used(compilation error if not)-->T: type 
function void build_phase(uvm_phase phase);
super.build_phase(phase);
seq=my_seq_item::type_id::create("seq");
my_analysis_import=new("my_analysis_import",this);
endfunction 

function void write(my_seq_item t);
seq=t;
g1.sample();
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
endtask 
endclass 

class env extends uvm_env;
`uvm_component_utils(env);
agent my_agent;
subscriber my_sub;
scoreboard my_sb;
virtual intf vif;

function new(string name= "env", uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
my_agent=agent::type_id::create("my_agent",this);
my_sub=subscriber::type_id::create("my_sub",this);
my_sb=scoreboard::type_id::create("my_sb",this);

if(!uvm_config_db #(virtual intf)::get(this,"","env_vif",vif))
`uvm_fatal("build_phase", "Agent unable to get vif");

uvm_config_db #(virtual intf)::set(this,"my_agent","agent_vif",vif);
endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
my_agent.my_analysis_port.connect(my_sub.my_analysis_import);
my_agent.my_analysis_port.connect(my_sb.my_analysis_import);
endfunction
endclass 

// virtual task start (uvm_sequencer_base sequencer,
                    //   uvm_sequence_base parent_sequence = null,
                    //   int this_priority = -1,
                    //   bit call_pre_post = 1);
//The ~sequencer~ argument specifies the sequencer on which to run this sequence. --> Could be dealing with more than one sequence 
class my_test extends uvm_test;
`uvm_component_utils(my_test);
env my_env;
virtual intf vif;
reset_sequence rst_seq;
valid_sequence valid_seq;
random_sequence rand_seq;
all_zeros_sequence zero_seq;
all_ones_sequence ones_seq;
consecutive_key_sequence consec_seq;
alternating_sequence alt_seq;
repeated_key_sequence repeated_seq;

function new(string name= "my_test", uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
my_env=env::type_id::create("my_env",this);
rst_seq=reset_sequence::type_id::create("rst_seq");
valid_seq=valid_sequence::type_id::create("valid_seq");
rand_seq=random_sequence::type_id::create("rand_seq");
zero_seq=all_zeros_sequence::type_id::create("zero_seq");
ones_seq=all_ones_sequence::type_id::create("ones_seq");
consec_seq=consecutive_key_sequence::type_id::create("consec_seq");
alt_seq=alternating_sequence::type_id::create("alt_seq");
repeated_seq=repeated_key_sequence::type_id::create("repeated_seq");

//--> vif is the container created in my class(instance name of virtual)
if(!uvm_config_db #(virtual intf)::get(this,"","my_vif",vif)) 
`uvm_fatal("build_phase","TEST unable to get vif");

uvm_config_db #(virtual intf)::set(this,"my_env","env_vif",vif);
endfunction 

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
`uvm_info("Run_phase","Reset sequence started",UVM_LOW)
rst_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","Reset sequence ended",UVM_LOW)

`uvm_info("Run_phase","Valid sequence started",UVM_LOW)
valid_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","Valid sequence ended",UVM_LOW)


`uvm_info("Run_phase","All 0's sequence started",UVM_LOW)
zero_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","All 0's sequence ended",UVM_LOW)

`uvm_info("Run_phase","all 1's sequence started",UVM_LOW)
ones_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","all 1's sequence ended",UVM_LOW)

`uvm_info("Run_phase","Consecutive key sequence started",UVM_LOW)
consec_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","Consecutive key sequence ended",UVM_LOW)

`uvm_info("Run_phase","Alternating in plain text and key sequence started",UVM_LOW)
alt_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","Alternating in plain text and key sequence ended",UVM_LOW)

`uvm_info("Run_phase","Repeated key with different plain text sequence started",UVM_LOW)
repeated_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","Repeated key with different plain text sequence ended",UVM_LOW)

`uvm_info("Run_phase","Random sequence started",UVM_LOW)
rand_seq.start(my_env.my_agent.my_sequencer);
`uvm_info("Run_phase","Random sequence ended",UVM_LOW)

phase.drop_objection(this);
endtask 
endclass 
endpackage 

