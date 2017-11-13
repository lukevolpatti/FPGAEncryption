vlib work
vlog cryptMachine.v
vsim cryptMachine

log {/*}
add wave {/*}
force {CLOCK_50} 0 0ns, 1 10ns -r 20ns
force {KEY[0]} 0 0ns, 1 20ns
force {SW[9]} 0 0ns
force {SW[8]} 0 0ns
force {SW[7]} 0 0ns
force {SW[6]} 0 0ns
force {SW[5]} 0 0ns
force {SW[4]} 0 0ns
force {SW[3]} 0 0ns
force {SW[2]} 0 0ns
force {SW[1]} 0 0ns
#force {SW[0]} 0 0ns, 1 20ns
force {SW[0]} 1 0ns
force {KEY[1]} 0 0ns, 1 20ns -r 40ns
run 7000ns