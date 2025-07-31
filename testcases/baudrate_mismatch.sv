class baudrate_mismatch extends uart_base_test;
  `uvm_component_utils(baudrate_mismatch)
  
  uart_sequence lhs_seq;
  uart_sequence rhs_seq;
  uart_configuration cfg_tmp;
  
  function new(string name = "baudrate_mismatch", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg_tmp = uart_configuration::type_id::create("cfg_tmp",this);
    assert(cfg_tmp.randomize() with {mode == uart_configuration::TX_RX;});
    set_lhs_mode(cfg_tmp.mode);
    cfg_tmp.baudrate = 19200;
    set_lhs_baudrate(cfg_tmp.baudrate);
    set_lhs_data_bits(cfg_tmp.data_bits);
    set_lhs_stop_bits(cfg_tmp.stop_bits);
    set_lhs_use_parity(cfg_tmp.use_parity);
    set_lhs_parity_even(cfg_tmp.parity_even); 
    `uvm_info(get_type_name(),$sformatf("Configuration LHS : \n%s",cfg_tmp.sprint()),UVM_LOW)  

    set_rhs_mode(cfg_tmp.mode);
    cfg_tmp.baudrate = 115200;
    set_rhs_baudrate(cfg_tmp.baudrate);
    set_rhs_data_bits(cfg_tmp.data_bits);
    set_rhs_stop_bits(cfg_tmp.stop_bits);
    set_rhs_use_parity(cfg_tmp.use_parity);
    set_rhs_parity_even(cfg_tmp.parity_even);     
    `uvm_info(get_type_name(),$sformatf("Configuration RHS: \n%s",cfg_tmp.sprint()),UVM_LOW)  
  endfunction  
  
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    err_catcher.add_error_catcher_msg("Mismatch lhs_tx vs rhs_rx");
    err_catcher.add_error_catcher_msg("Mismatch rhs_tx vs lhs_rx");          
    phase.drop_objection(this);
  endtask

  virtual task run_phase(uvm_phase phase); 
    phase.raise_objection(this);          
    lhs_seq = uart_sequence::type_id::create("lhs_seq");
    rhs_seq = uart_sequence::type_id::create("rhs_seq");    
    fork
      lhs_seq.start(uart_env.uart_lhs_agent.sequencer);
      rhs_seq.start(uart_env.uart_rhs_agent.sequencer);
    join    
    phase.drop_objection(this);
  endtask

endclass 
