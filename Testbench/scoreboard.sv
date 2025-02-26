`uvm_analysis_imp_decl(_ahb_port) 
`uvm_analysis_imp_decl(_apb_port)

import uvm_pkg::* ;


class scoreboard extends uvm_scoreboard  ;
  `uvm_component_utils(scoreboard);

  // Ports Declaration 
  uvm_analysis_imp_ahb_port #(ahb_seq_item, scoreboard) ahb_ap ;
  uvm_analysis_imp_apb_port #(apb_seq_item, scoreboard) apb_ap ;
  
  
  // Sequence items declaration 
  ahb_seq_item ahb_sb ; // Holds AHB monitor transaction 
  ahb_seq_item ahb_p ; // Holds AHB predicted transaction 
  ahb_seq_item ahb_prev ; // Holds the previous AHB transaction 
  
  apb_seq_item apb_p ; // Hold APB predicted transaction
  apb_seq_item apb_sb ; // Holds APB monitor transaction
  apb_seq_item apb_prev ; // Holds the previous APB transaction 
  
  // Some Really Helpful Signals 
  bit write_command ; // Asserted when write transfer is requested (stay high for one cycle)
  bit write_pending ; // Asserted as long as there is write transfer ongoing (stay high for multiple cycles)
  bit apb_enable ; // Used to Assert predicted PENABLE in setup phase  
  bit [6:0] apb_beat ; // Holds the number of beats 
  bit [6:0] apb_beat_count ; // Counter to check if the beats are done 
  bit apb_sample ; // Goes High when new data asserted on PWDATA bus to trigger the pridict fucntion   
  bit ahb_write_ack ; // Indicates write transfer completion so predicted HREADYOUT can be asserted 
  bit next_beat ; // Asserted at start of beats 
  bit apb_psel ; // Control predicted PSEL along write process 
  bit apb_write ; // Goes high at receiving the apb transaction and stay high untill ack strobe goes back to AHB
  bit   [             3:0] ahb_write_count ; // Counter for AHB to APB domains transition  
  bit   [             3:0] apb_write_count ; // Counter for APB to AHB domains transition 
  logic [HDATA_SIZE  -1:0] HWDATA_temp ; // Holds AHB write data untill transaction is received by APB
  logic [HADDR_SIZE  -1:0] HADDR_temp ; // Holds AHB Address untill transaction is received by APB
  logic [             3:0] HPROT_temp ; // Holds AHB protection untill transaction is received by APB
  logic [             2:0] HSIZE_temp ; // Hold AHB transfer size untill transaction is received by APB
  bit                  HREADYOUT_temp ; // Control predicted HREADYOUT 
  bit seq , nonseq ;
  
  
  // Constructor
  function new (string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    ahb_ap = new ("ahb_ap" ,this); // Create AHB analysis port 
    apb_ap = new ("apb_ap" ,this); // Create APB analysis port 
  endfunction : new


  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase) ;
    ahb_prev = ahb_seq_item::type_id::create("ahb_prev"); 
    apb_prev = apb_seq_item::type_id::create("apb_prev"); 
  endfunction : build_phase
  
  
   //--------------------------//
  // AHB port write function  //
 //--------------------------//
  virtual function void write_ahb_port(ahb_seq_item ahb_tr);  
    
    // Create Actual and Predicted transactions
    ahb_sb = ahb_seq_item::type_id::create("ahb_sb"); 
    ahb_p = ahb_seq_item::type_id::create("ahb_p"); 
    ahb_sb.copy(ahb_tr) ; // To prevent unwanted change
    
    // AHB Reset Check 
    if(!ahb_sb.HRESETn) begin 
      ahb_p.Reset() ;
      ahb_compare(ahb_sb, ahb_p) ;
    end 
      
    else begin // If No Reset Asserted :
      
      seq = (ahb_sb.HTRANS == SEQ) ;
      nonseq = (ahb_sb.HTRANS == NONSEQ) ;
      
      // Check if beats are done to increament the counter for APB to AHB ackwnoledge 
      if ((apb_beat_count == (apb_beat + 1)) && apb_write) begin 
        apb_write_count = apb_write_count + 1 ;
      end
      
      // Check if APB to AHB ackwnoledge is done 
      if (apb_write_count == 8) begin 
          apb_write_count = 0 ;
          apb_write = 0 ; 
          ahb_write_ack = 1 ;
          apb_psel = 1 ;
          apb_beat_count = 0 ;
      end
      
      // Reset some signal after finishing write transfer 
      if(ahb_write_ack) begin 
        write_command = 0 ;
        HREADYOUT_temp = 0 ;
        ahb_write_count = 0 ;
        next_beat = 0 ;
        ahb_write_ack = 0 ;    
      end      
  
      // Check if last cycle had Write command 
      if(write_command) begin 
        HWDATA_temp    = ahb_sb.HWDATA ;
        HREADYOUT_temp = 1'b1 ;
        if (ahb_write_count == 8)begin 
          ahb_write_count = 5 ;
          next_beat = 1 ;
        end
        else begin  
          ahb_write_count = ahb_write_count + 1 ; 
        end
      end
           
      // Check if current transaction is write command 
        if ((seq || nonseq) && ahb_sb.HREADY && ahb_sb.HREADYOUT && ahb_sb.HSEL && ahb_sb.HWRITE ) begin 
        write_command = 1 ;
        HADDR_temp = ahb_sb.HADDR ;
        HPROT_temp = ahb_sb.HPROT ;
        HSIZE_temp = ahb_sb.HSIZE ;
        $display("write start") ;
      end
      
        
      // AHB Predict and Compare Functions Call     
      ahb_predict() ;
      ahb_compare(ahb_sb, ahb_p) ;
          
    end // If No Reset Asserted End 
    
    // Save the current transaction to be used next cycle     
    ahb_prev.copy(ahb_sb) ; 
     
  endfunction // AHB write function 
  
  
   //-------------------------//
  // APB port write function //
 //-------------------------//
  virtual function void write_apb_port(apb_seq_item apb_tr);
    apb_sb = apb_seq_item::type_id::create("apb_sb");
    apb_p = apb_seq_item::type_id::create("apb_p");
    apb_sb.copy(apb_tr) ; // To prevent unwanted change
    
    // APB Reset Check 
    if(!apb_sb.PRESETn) begin 
      apb_p.Reset() ;
      apb_compare(apb_sb, apb_p) ;
    end 
    
    else begin // If No Reset Asserted 
      
     apb_enable = apb_sample ? 1 : 0 ;
      
     apb_beat = write_command ? apb_beats(HSIZE_temp) : apb_beat ;
      $display("apb beat = %d" , apb_beat) ;
      
     /* Check if a new WDATA is asserted on the bus 
      * counter goes from 0 to 8 fisrt time in transition from AHB domain to APB domain 
      * then it goes from 5 to 8 for extra beats 
      */
     if(ahb_write_count == 8) begin 
        apb_sample = 1 ;
        apb_write = 1 ;
        apb_beat_count = apb_beat_count + 1 ;
        $display("ahb_write_count = ", ahb_write_count) ;
     end
     else 
        apb_sample = 0 ;
      
      
      
     // APB Predict and Compare Functions Call     
     apb_predict() ;
     apb_compare(apb_sb, apb_p) ; 
      
      
      
    end // If No Reset Asserted End 
    
   // Save the current transaction to be used next cycle     
   apb_prev.copy(apb_sb) ; 
  endfunction // APB write function 
  
  
  // -------------------------------- Predict Section -----------------------------------\\
  
   //----------------------//
  // AHB Predict Function //
 //----------------------// 
  function void ahb_predict () ;
    ahb_p.copy(ahb_prev) ;
    ahb_p.HREADYOUT = (HREADYOUT_temp) ? 0 : 1 ;
  endfunction // ahb_predict End
  
   //----------------------//
  // APB Predict Function //
 //----------------------// 
  function void apb_predict () ;
    // Single Write
    if(apb_sample) begin 
      
      apb_p.PSEL    = 1'b1 ;
      apb_p.PENABLE = 1'b0 ; 
      apb_p.PPROT   = PROT(HPROT_temp) ;
      apb_p.PWRITE  = 1'b1 ;
      if (next_beat) begin 
        apb_p.PADDR  = apb_prev.PADDR + (1 << PDATA_SIZE/8) ;
        apb_p.PWDATA = HWDATA_temp >> data_offset(HADDR_temp) + (PDATA_SIZE*(apb_beat_count - 1)) ;
        apb_p.PSTRB  = pstrb(HSIZE_temp, apb_prev.PADDR + (1 << HSIZE_temp)) ;
      end
      else begin 
        apb_p.PADDR   = HADDR_temp[PADDR_SIZE-1:0] ;
        apb_p.PWDATA  = HWDATA_temp >> data_offset(HADDR_temp) ;
        apb_p.PSTRB   = pstrb(HSIZE_temp , apb_p.PADDR) ;
      end
      ahb_write_count = ((apb_beat_count == (apb_beat + 1)) && apb_write) ?  0 : ahb_write_count ; 
    end
    // Pending or No Operation
    else begin 
      apb_p.copy(apb_prev) ;
      apb_p.PSEL = apb_psel ? 0 : apb_p.PSEL ;
      apb_p.PENABLE = apb_enable ? 1 : 0 ;
      apb_psel = ((apb_beat_count == (apb_beat + 1)) && apb_write) ? 1 : 0 ;
    end
  endfunction // apb_predict End
          
  //--------------------------------- Compare Section ------------------------------------\\
  // AHB Compare Function 
  function void ahb_compare (ahb_seq_item a_item, ahb_seq_item p_item) ;   
    bit pass ; 
    
    
    
  
      pass = (a_item.HRDATA    === p_item.HRDATA)    &&
             (a_item.HREADYOUT ==  p_item.HREADYOUT) &&
             (a_item.HRESP     ==  p_item.HRESP) ;
    
      if (pass)
        `uvm_info(get_type_name(),"AHB PASS", UVM_LOW)
      else  
        `uvm_error(get_type_name(),"AHB FAIL")
        
        $display("Actual");
        a_item.print() ;
        $display(" ");
        $display(" ");
        $display("Predicted");
        p_item.print() ;
      
      
  endfunction 
      
      
  // APB Compare Function 
  function void apb_compare (apb_seq_item a_item, apb_seq_item p_item) ;
    bit pass ; 
    
    pass = (a_item.PSEL    == p_item.PSEL)    &&
           (a_item.PENABLE == p_item.PENABLE) &&
           (a_item.PPROT   == p_item.PPROT)   &&
           (a_item.PWRITE  == p_item.PWRITE)  &&
           (a_item.PSTRB   == p_item.PSTRB)   &&
           (a_item.PADDR   == p_item.PADDR)   &&
           (a_item.PWDATA  == p_item.PWDATA)  ;
    
    if (pass)
      `uvm_info(get_type_name(),"APB PASS", UVM_LOW)
    else  
      `uvm_error(get_type_name(),"APB FAIL")
      
      $display("Actual");
      a_item.print() ;
      $display(" ");
      $display(" ");
      $display("Predicted");
      p_item.print() ;
    
      
  endfunction 
          
  // ----------------------------- Commonly used Functions Section ------------------------- \\         
 
  // PROT function to resolve 4-bit HPROT to 3-bit PPROT 
  function bit [2:0] PROT(logic [3:0] hprot) ; 
    if (hprot[1]) // Privileged vs User access  
      PROT[0] = 1 ;   
    if (!hprot[0]) // Data vs Instruction access 
      PROT[2] = 1 ;
 endfunction           
  
endclass : scoreboard 
    
    
    
    
    
    
    
    
  