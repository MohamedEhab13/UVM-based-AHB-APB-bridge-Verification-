`uvm_analysis_imp_decl(_ahb_port) 
`uvm_analysis_imp_decl(_apb_port)

import uvm_pkg::* ;

class scoreboard extends uvm_scoreboard  ;
  `uvm_component_utils(scoreboard);

  // Ports Declaration 
  uvm_analysis_imp_ahb_port #(seq_item, scoreboard) ahb_ap ;
  uvm_analysis_imp_apb_port #(seq_item, scoreboard) apb_ap ;
  
  
  // Sequence items declaration 
  ahb_seq_item ahb_sb_item ; // Holds AHB monitor transaction 
  apb_seq_item apb_sb_item ; // Holds APB monitor transaction
  
  ahb_seq_item ahb_p ; // Hold AHB predicted transaction 
  apb_seq_item apb_p ; // Hold APB predicted transaction
  
  

  // Constructor
  function new (string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    ahb_ap = new ("ahb_ap" ,this);
    apb_ap = new ("apb_ap" ,this);
  endfunction : new



  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase) ;
  endfunction : build_phase
  
  
  // AHB port write function 
  virtual function void write_ahb_port(ahb_seq_item ahb_tr);  
    ahb_sb_item = ahb_seq_item::type_id::create("ahb_sb_item"); 
    ahb_sb_item.copy(ahb_tr) ; // To prevent unwanted change
  endfunction // AHB write function 
  
  
  // APB port write function 
  virtual function void write_apb_port(apb_seq_item apb_tr);
    apb_sb_item = apb_seq_item::type_id::create("apb_sb_item"); 
    apb_sb_item.copy(apb_tr) ; // To prevent unwanted change
  endfunction // APB write function 
  
  
  
endclass : scoreboard 
    
    
    
    
    
    
    
    
  