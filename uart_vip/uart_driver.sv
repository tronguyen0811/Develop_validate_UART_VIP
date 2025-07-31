class uart_driver extends uvm_driver #(uart_transaction);
  `uvm_component_utils(uart_driver)

  virtual uart_if uart_vif;
  uart_configuration cfg; 
  
  function new(string name = "uart_driver", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase); 
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif from uvm_config_db"))

    if(!uvm_config_db#(uart_configuration)::get(this,"","cfg",cfg))
      `uvm_fatal(get_type_name(), $sformatf("Failed to get cfg from uvm_config_db"))
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    forever begin 
      seq_item_port.get(req);      
      case(cfg.mode)
        uart_configuration::TX:    drive_tx(req);
        uart_configuration::RX:    `uvm_info(get_type_name(), $sformatf("No data transmission"), UVM_LOW)
        uart_configuration::TX_RX: drive_tx(req);
        default:                   `uvm_error(get_type_name(), $sformatf("Unknown mode"))
      endcase
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      seq_item_port.put(rsp);  
    end 
  endtask: run_phase

  task drive_tx(inout uart_transaction req);
    time period = baud_period_ns();

    //Start bit
    uart_vif.tx = 1'b0;
    #(period*1ns);
  
    //Data frame
    for(int i = 0; i < cfg.data_bits; i++) begin 
      uart_vif.tx = req.data[i];
      #(period*1ns);
    end
    
    //Parity bit
    if(cfg.use_parity) begin 
      bit parity_bit = calc_parity(req.data);
      uart_vif.tx = parity_bit;
      #(period*1ns);
    end

    //Stop bits
    repeat(cfg.stop_bits) begin
      uart_vif.tx = 1'b1;  
      #(period*1ns);
    end
  endtask: drive_tx

  function time baud_period_ns();
    return (cfg.baudrate > 0) ? (1e9 / cfg.baudrate): 0;
  endfunction

  function bit calc_parity(bit[7:0] data);
    bit parity = 0;
    for(int i = 0; i < cfg.data_bits; i++)
      parity ^= data[i];
    if(!cfg.parity_even)
      parity = ~parity;
    return parity;
  endfunction: calc_parity

endclass: uart_driver
