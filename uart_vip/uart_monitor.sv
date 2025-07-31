class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  virtual uart_if uart_vif;
  uart_configuration cfg;
  uvm_analysis_port #(uart_transaction) uart_observe_port_tx;  
  uvm_analysis_port #(uart_transaction) uart_observe_port_rx;
  
  function new(string name = "uart_monitor", uvm_component parent);
    super.new(name, parent);
    uart_observe_port_tx = new("uart_observe_port_tx",this);
    uart_observe_port_rx = new("uart_observe_port_rx",this);
  endfunction: new  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif", uart_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get uart_vif from uvm_config_db"))
    if(!uvm_config_db #(uart_configuration)::get(this,"","cfg", cfg))  
      `uvm_fatal(get_type_name(),$sformatf("Failed to get cfg from uvm_config_db"))
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    fork
      if(cfg.mode == uart_configuration::TX || cfg.mode == uart_configuration::TX_RX)
        capture_port(uart_vif.tx, 1);
      if(cfg.mode == uart_configuration::RX || cfg.mode == uart_configuration::TX_RX)  
        capture_port(uart_vif.rx, 0);
    join
  endtask: run_phase

  function time baud_period_ns(); 
    return (cfg.baudrate > 0) ? (1e9 / cfg.baudrate): 0;
  endfunction

  task capture_port(ref logic port, input bit is_tx);
    uart_transaction trans;
    time period = baud_period_ns();
  
    forever begin 
      //Start bit
      @(negedge port);
      if(port) continue;
      #(period*1ns/2);  
      trans = uart_transaction::type_id::create("trans", this);
      
      //Data frame
      for(int i = 0; i < cfg.data_bits; i++) begin
        #(period*1ns);
        trans.data[i] = port;
      end
      
      //Parity bit
      if(cfg.use_parity) begin
        #(period*1ns);
        trans.parity = port;
      end
      
      //Stop bits
      for(int i = 0; i < cfg.stop_bits; i++) begin 
        #(period*1ns);
        trans.stopbit[i] = port;
      end
    
      if(is_tx)
        uart_observe_port_tx.write(trans);
      else
        uart_observe_port_rx.write(trans);
    end  
  
  endtask: capture_port

endclass: uart_monitor
