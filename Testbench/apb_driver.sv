import uvm_pkg::* ;


class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)

  
  // Sequence item Declaration  
  apb_seq_item apb_driver_item ;
  
  
  // Virtual Interface Declaration 
  virtual apb_intf apb_intf_h ;
  virtual apb_intf apb_driver_intf_h ;
  
  
 // Constructor  
  function new(string name = "apb_driver" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
 
   
 // Build Phase 
  function void build_phase(uvm_phase phase);    
    super.build_phase(phase);
    if(!(uvm_config_db #(virtual apb_intf)::get(this,"*","apb_intf_h",apb_intf_h))) 
    `uvm_error(get_type_name(),"failed to get virtual interface inside APB Driver class") 
  endfunction : build_phase 
      
      
 // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
	apb_driver_intf_h = apb_intf_h ;
  endfunction :connect_phase
           
        
  // Run Phase 
  task run_phase (uvm_phase phase);   
    super.run_phase(phase);
    forever begin    
      apb_driver_item = apb_seq_item::type_id::create("apb_driver_item");   
      seq_item_port.get_next_item(apb_driver_item) ;
      drive(apb_driver_item) ;
      seq_item_port.item_done() ;    
    end   
  endtask : run_phase 
      
      
      
 // drive task 
  virtual task drive (apb_seq_item apb_tr) ; // Drive task begin 
    apb_driver_intf_h.PRESETn <= apb_tr.PRESETn ;
    @(posedge apb_driver_intf_h.pclk) ;  
    if(apb_driver_intf_h.PSEL) begin // PSEL check begin 
      apb_driver_intf_h.PREADY <= apb_tr.PREADY ;
      apb_driver_intf_h.PSLVERR <= apb_tr.PSLVERR ;
      if(apb_driver_intf_h.PWRITE) // Check either write or read transfer 
        apb_driver_intf_h.PRDATA <= 32'hxxxx_xxxx ; // Write transfer 
      else  
        apb_driver_intf_h.PRDATA <= apb_driver_item.PRDATA ; // Read transfer     
      
    end // PSEL check end 
    
  endtask  // Drive task end 
  
  
endclass : apb_driver
 