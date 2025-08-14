interface intf(input bit clk);
bit valid_in;
bit reset;
bit valid_out;
bit [127:0] plain_text_128;
bit [127:0] cipher_key_128;
bit [127:0] cipher_text_128;

//clocking block --> Driver 1st
clocking cb_drv @(posedge clk);
default input #1ns output #0ns;
output valid_in,reset,plain_text_128,cipher_key_128;
endclocking 

//clocking block --> Mon 2nd 
clocking cb_mon @(posedge clk);
default input #2ns output #0ns; // Sample late
input valid_in,reset,plain_text_128,cipher_key_128;
input valid_out,cipher_text_128;
endclocking 
endinterface 