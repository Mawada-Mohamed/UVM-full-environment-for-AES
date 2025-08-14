module AES_128_wrapper(
input bit valid_in,
input bit clk,
input bit reset,
output bit valid_out,
input bit[127:0] plain_text_128,
input bit[127:0] cipher_key_128,
output bit[127:0] cipher_text_128);
bit [127:0] cipher_text_128_reg;
bit [127:0] plain_text_128_reg;
bit [127:0] cipher_key_128_reg;
bit valid_in_output_reg;
   AES_Encrypt dut (
        .in(plain_text_128_reg),
        .key(cipher_key_128_reg),
        .out(cipher_text_128_reg)
    );
//handeling more than 1 clk cycle latency 
always @(posedge clk)begin
    if(!reset)begin 
    valid_in_output_reg<=0; 
    cipher_key_128_reg<=0;
    plain_text_128_reg<=0;
    end
    else begin
    if(valid_in)begin
    plain_text_128_reg<=plain_text_128;
    cipher_key_128_reg<=cipher_key_128;
    end
    valid_in_output_reg<=valid_in;
    end
end
always @(posedge clk)begin
    if(!reset)begin
    cipher_text_128<=0;    
    end
    else begin
    if(valid_in_output_reg)begin
    cipher_text_128<=cipher_text_128_reg;
    valid_out<=1;
    end
    else begin
    valid_out<=0;
    end 
    end 
end
endmodule 