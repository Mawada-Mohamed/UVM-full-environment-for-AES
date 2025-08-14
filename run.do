vlib work
vlog -f src_files.list +cover
vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all
coverage save aes.ucdb -onexit
run -all