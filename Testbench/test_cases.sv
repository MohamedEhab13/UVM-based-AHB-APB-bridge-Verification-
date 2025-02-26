 ;class base_test extends uvm_test ;
  `uvm_component_utils(base_test)

  env env_h ;
   
  ahb_cnfg ahb_cnfg_h ;
  apb_cnfg apb_cnfg_h ;
   
  reset_ahb_seq  ahb_reset_s  ;
  reset_apb_seq  apb_reset_s  ;

  // Constructor 
  function new(string name = "base_test" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = env::type_id::create("env_h",this);
    
    ahb_cnfg_h = ahb_cnfg::type_id::create("ahb_cnfg_h");
    apb_cnfg_h = apb_cnfg::type_id::create("apb_cnfg_h");
    
    ahb_reset_s = reset_ahb_seq::type_id::create("ahb_reset_s");
    apb_reset_s = reset_apb_seq::type_id::create("apb_reset_s");
    
    uvm_config_db #(ahb_cnfg)::set(this, "*" , "ahb_configuration" , ahb_cnfg_h);
    uvm_config_db #(apb_cnfg)::set(this, "*" , "apb_configuration" , apb_cnfg_h);
  endfunction : build_phase 

endclass :base_test

//-------------------------------------------------------------------------------


class single_write_test extends base_test ;
  `uvm_component_utils(single_write_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  data_ahb_seq            ahb_data_req ;
  NONSEQ_write_ahb_seq    ahb_nonseq_req ;
  OKAY_READY_apb_seq       apb_resp ;
  
  function new(string name = "single_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req = IDLE_ahb_seq::type_id::create("ahb_idle_req");
    ahb_data_req = data_ahb_seq::type_id::create("ahb_data_req");
    ahb_nonseq_req  = NONSEQ_write_ahb_seq::type_id::create("ahb_nonseq_req");
    apb_resp = OKAY_READY_apb_seq::type_id::create("apb_resp");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // Reset 
      fork 
        begin 
          repeat (4) begin 
           ahb_reset_s.start(env_h.ahb_agent_h.ahb_sequencer_h);
          end
        end
        
        begin 
          repeat (2) begin
           apb_reset_s.start(env_h.apb_agent_h.apb_sequencer_h);
          end
        end
      join_any 
    
    // IDLE 
    fork 
      begin 
        repeat (3) begin 
           ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
        end
      end
        
      begin 
        repeat (30) begin
         apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
        end
      end
    join_any
    
    // NONSEQ 
    repeat(1) begin 
    fork
      ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    join 
    end
    
    // IDLE 
    repeat(30) begin 
    fork
      ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    join 
    end
    
    
    phase.drop_objection(this);
  endtask

endclass : single_write_test

//------------------------------------------------------------------------------------------------------------


class double_write_test extends base_test ;
  `uvm_component_utils(double_write_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  data_ahb_seq            ahb_data_req ;
  NONSEQ_write_ahb_seq    ahb_nonseq_req ;
  SEQ_write_ahb_seq       ahb_seq_req ;
  OKAY_READY_apb_seq      apb_resp ;
  
  function new(string name = "double_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req = IDLE_ahb_seq::type_id::create("ahb_idle_req");
    ahb_data_req = data_ahb_seq::type_id::create("ahb_data_req");
    ahb_nonseq_req = NONSEQ_write_ahb_seq::type_id::create("ahb_nonseq_req");
    ahb_seq_req = SEQ_write_ahb_seq::type_id::create("ahb_seq_req");
    apb_resp = OKAY_READY_apb_seq::type_id::create("apb_resp");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
      // Reset 
      fork 
        begin 
          repeat (4) begin 
           ahb_reset_s.start(env_h.ahb_agent_h.ahb_sequencer_h);
          end
        end
        
        begin 
          repeat (2) begin
           apb_reset_s.start(env_h.apb_agent_h.apb_sequencer_h);
          end
        end
      join_any 
      
      // IDLE 
      fork 
        begin 
          repeat (3) begin 
           ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
          end
        end
        
        begin 
          repeat (40) begin
           apb_resp.start(env_h.apb_agent_h.apb_sequencer_h);
          end
        end
      join_any
    
    // NONSEQ
    repeat(1) begin
      ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    end
    
    // SEQ
    repeat(1) begin
      ahb_seq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    end
    
    // IDLE
    repeat(60) begin 
      ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
    end
    
     
    
    
    phase.drop_objection(this);
  endtask

endclass : double_write_test