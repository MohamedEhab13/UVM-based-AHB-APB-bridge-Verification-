// Random AHB sequence 
class rand_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(rand_ahb_seq)
  
  ahb_seq_item rand_ahb_item ;
  
  function  new(string name = "rand_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    rand_ahb_item = ahb_seq_item::type_id::create("rand_ahb_item") ;
    start_item(rand_ahb_item) ; 
    assert(rand_ahb_item.randomize())           
    else
   `uvm_error(get_type_name(),"randomization failed in rand_ahb_sequence")  
    finish_item(rand_ahb_item);	 
  endtask
  
endclass: rand_ahb_seq

//-------------------------------------------------------------------------------------------------

// Reset AHB sequence 
class reset_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(reset_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "reset_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {ahb_transaction.HRESETn == 0 ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in reset_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: reset_ahb_seq


//-------------------------------------------------------------------------------------------------

// Data phase AHB sequence 
class data_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(data_ahb_seq)
 
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "data_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWDATA == 32'h111 ;
           ahb_transaction.HADDR == 32'hf00 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
      `uvm_error(get_type_name(),"randomization failed in data_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: data_ahb_seq


//-------------------------------------------------------------------------------------------------

// IDLE AHB sequence 
class IDLE_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(IDLE_ahb_seq)
 
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "IDLE_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
      `uvm_error(get_type_name(),"randomization failed in IDLE_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: IDLE_ahb_seq

//-------------------------------------------------------------------------------------------------

// NONSEQ write AHB sequence 
class NONSEQ_write_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(NONSEQ_write_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "NONSEQ_write_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 1 ;
           ahb_transaction.HREADY == 1 ;
           ahb_transaction.HWDATA == 32'hfff ;
           ahb_transaction.HADDR == 32'hf00 ;
           ahb_transaction.HSIZE == 3'b010 ; // 32-bit size 
           ahb_transaction.HTRANS == NONSEQ ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in NONSEQ_write_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: NONSEQ_write_ahb_seq

//-------------------------------------------------------------------------------------------------

// NONSEQ read AHB sequence 
class NONSEQ_read_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(NONSEQ_read_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "NONSEQ_read_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize() with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 0 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
     `uvm_error(get_type_name(),"randomization failed in NONSEQ_read_ahb_seq")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: NONSEQ_read_ahb_seq


//-------------------------------------------------------------------------------------------------


// Single read AHB request sequence consists of 3 cycles 
// 1- IDLE transfer type transaction 
// 2- NONSEQ transfer type with low HWRITE transaction  
// 3- IDLE transfer type transaction 

class single_read_ahb_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(single_read_ahb_seq)
  
  ahb_seq_item ahb_transaction ;
  
  function  new(string name = "single_read_ahb_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    
    // Cycle No.1
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize()with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 0 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in single_read_ahb_seq cycle 1")  
    finish_item(ahb_transaction);	 
    
    //Cycle No.2
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize()with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ; 
           ahb_transaction.HWRITE == 0 ;
           ahb_transaction.HTRANS == NONSEQ ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in single_read_ahb_seq cycle 2")  
    finish_item(ahb_transaction); 
    
    // Cycle No.3
    ahb_transaction = ahb_seq_item::type_id::create("ahb_transaction") ;
    start_item(ahb_transaction) ; 
    assert(ahb_transaction.randomize()with {
           ahb_transaction.HRESETn == 1 ;
           ahb_transaction.HSEL == 1 ;
           ahb_transaction.HWRITE == 0 ;
           ahb_transaction.HTRANS == IDLE ;})           
    else
    `uvm_error(get_type_name(),"randomization failed in single_read_ahb_seq cycle 3")  
    finish_item(ahb_transaction);	 
  endtask
  
endclass: single_read_ahb_seq

//------------------------------------------------------------------------------------------------------------