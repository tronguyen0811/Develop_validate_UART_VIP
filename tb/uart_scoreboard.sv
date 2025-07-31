`uvm_analysis_imp_decl(_lhs_tx)
`uvm_analysis_imp_decl(_lhs_rx)
`uvm_analysis_imp_decl(_rhs_tx)
`uvm_analysis_imp_decl(_rhs_rx)

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)
  
  uvm_analysis_imp_lhs_tx #(uart_transaction, uart_scoreboard) lhs_tx_export;
  uvm_analysis_imp_lhs_rx #(uart_transaction, uart_scoreboard) lhs_rx_export;
  uvm_analysis_imp_rhs_tx #(uart_transaction, uart_scoreboard) rhs_tx_export;  
  uvm_analysis_imp_rhs_rx #(uart_transaction, uart_scoreboard) rhs_rx_export;  
  
  uart_transaction lhs_tx_queue[$];
  uart_transaction lhs_rx_queue[$];
  uart_transaction rhs_tx_queue[$];
  uart_transaction rhs_rx_queue[$];

  function new(string name = "uart_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase); 
    super.build_phase(phase);
    lhs_tx_export = new("lhs_tx_export", this);
    lhs_rx_export = new("lhs_rx_export", this);
    rhs_tx_export = new("rhs_tx_export", this);
    rhs_rx_export = new("rhs_rx_export", this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  endtask: run_phase
  
  virtual function void write_lhs_tx(uart_transaction trans);
    lhs_tx_queue.push_back(trans);
    compare_lhs_to_rhs();
  endfunction: write_lhs_tx  
  
  virtual function void write_lhs_rx(uart_transaction trans);
    lhs_rx_queue.push_back(trans);
    compare_rhs_to_lhs();
  endfunction: write_lhs_rx

  virtual function void write_rhs_tx(uart_transaction trans);
    rhs_tx_queue.push_back(trans);
    compare_rhs_to_lhs();
  endfunction: write_rhs_tx  

  virtual function void write_rhs_rx(uart_transaction trans);
    rhs_rx_queue.push_back(trans);
    compare_lhs_to_rhs();
  endfunction: write_rhs_rx

  function void compare_lhs_to_rhs();
    while(lhs_tx_queue.size() > 0 && rhs_rx_queue.size() > 0) begin
      uart_transaction tx_trans = lhs_tx_queue.pop_front();
      uart_transaction rx_trans = rhs_rx_queue.pop_front();    
      if(tx_trans.data != rx_trans.data || tx_trans.parity != rx_trans.parity || tx_trans.stopbit != rx_trans.stopbit) begin
        `uvm_error(get_type_name(),$sformatf("Mismatch lhs_tx vs rhs_rx"))
        `uvm_info(get_type_name(), $sformatf("\n\nLHS_TX_trans:\n%s\nRHS_RX_trans:\n%s",tx_trans.sprint(),rx_trans.sprint()),UVM_LOW)
      end
      else   
        `uvm_info(get_type_name(),$sformatf("Data transmission from lhs_tx to rhs_rx was successful:\n%s",rx_trans.sprint()),UVM_LOW)    
    end
  endfunction: compare_lhs_to_rhs

  function void compare_rhs_to_lhs();
    while(rhs_tx_queue.size() > 0 && lhs_rx_queue.size() > 0) begin
      uart_transaction tx_trans = rhs_tx_queue.pop_front();
      uart_transaction rx_trans = lhs_rx_queue.pop_front();    
      if(tx_trans.data != rx_trans.data || tx_trans.parity != rx_trans.parity || tx_trans.stopbit != rx_trans.stopbit) begin
        `uvm_error(get_type_name(),$sformatf("Mismatch rhs_tx vs lhs_rx"))  
        `uvm_info(get_type_name(), $sformatf("\n\nRHS_TX_trans:\n%s\nLHS_RX_trans:\n%s",tx_trans.sprint(),rx_trans.sprint()),UVM_LOW)
      end
      else   
        `uvm_info(get_type_name(),$sformatf("Data transmission from rhs_tx to lhs_rx was successful:\n%s",rx_trans.sprint()),UVM_LOW)
    end
  endfunction: compare_rhs_to_lhs

endclass: uart_scoreboard
