class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)

  virtual uart_if uart_vif;
  uart_configuration cfg;
  uart_sequencer sequencer;
  uart_driver driver;
  uart_monitor monitor;

  function new(string name = "uart_agent", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_fb"))
    if(!uvm_config_db #(uart_configuration)::get(this,"","cfg", cfg))
      `uvm_fatal(get_type_name(), $sformatf("Failed to get cfg from uvm_config_fb"))
  
    if(is_active == UVM_ACTIVE) begin 
      `uvm_info(get_type_name(), $sformatf("Active agent is configured"), UVM_LOW)
      sequencer = uart_sequencer::type_id::create("sequencer", this);
      driver = uart_driver::type_id::create("driver", this);
      monitor = uart_monitor::type_id::create("monitor", this);
    
      uvm_config_db #(virtual uart_if)::set(this,"driver","uart_vif", uart_vif);
      uvm_config_db #(virtual uart_if)::set(this,"monitor","uart_vif", uart_vif);
      uvm_config_db #(uart_configuration)::set(this,"driver","cfg", cfg);
      uvm_config_db #(uart_configuration)::set(this,"monitor","cfg", cfg);
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("Passive agent is configured"), UVM_LOW)  
      monitor = uart_monitor::type_id::create("monitor", this);

      uvm_config_db #(virtual uart_if)::set(this,"monitor","uart_vif", uart_vif);
      uvm_config_db #(uart_configuration)::set(this,"monitor","cfg", cfg);
    end
  endfunction: build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction: connect_phase
    
endclass: uart_agent
