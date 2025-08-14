module top;
import uvm_pkg::*;
import pack::*;

bit clk;
initial begin
    forever #5 clk=~clk;
end
intf intf1(clk);
AES_128_wrapper wrapper (intf1.valid_in,intf1.clk,intf1.reset,intf1.valid_out,intf1.plain_text_128,intf1.cipher_key_128,intf1.cipher_text_128);

initial begin
    uvm_config_db #(virtual intf)::set(null,"uvm_test_top","my_vif",intf1);
    run_test("my_test");
end
endmodule 
