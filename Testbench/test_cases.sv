 ;class base_test extends uvm_test ;
  `uvm_component_utils(base_test)

  env env_h ;
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
    ahb_reset_s = reset_ahb_seq::type_id::create("ahb_reset_s");
    apb_reset_s = reset_apb_seq::type_id::create("apb_reset_s");
  endfunction : build_phase 

endclass :base_test

//-------------------------------------------------------------------------------


class single_read_test extends base_test ;
  `uvm_component_utils(single_read_test)
  
  IDLE_ahb_seq            ahb_idle_req ;
  data_ahb_seq            ahb_data_req ;
  NONSEQ_write_ahb_seq    ahb_nonseq_req ;
  OKAY_BUSY_apb_seq       apb_resp ;
  
  function new(string name = "single_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_idle_req = IDLE_ahb_seq::type_id::create("ahb_idle_req");
    ahb_data_req = data_ahb_seq::type_id::create("ahb_data_req");
    ahb_nonseq_req = NONSEQ_write_ahb_seq::type_id::create("ahb_nonseq_req");
    apb_resp = OKAY_BUSY_apb_seq::type_id::create("apb_resp");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat(10) begin 
      fork 
        ahb_reset_s.start(env_h.ahb_agent_h.ahb_sequencer_h);
        apb_reset_s.start(env_h.apb_agent_h.apb_sequencer_h);
      join 
    end
    
    repeat(3) begin 
    fork
      ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      apb_resp.start(env_h.apb_agent_h.apb_sequencer_h); 
    join 
    end
    
    repeat(1) begin 
    fork
      ahb_nonseq_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      apb_resp.start(env_h.apb_agent_h.apb_sequencer_h); 
    join 
    end
    
//     repeat(1) begin 
//     fork
//       ahb_data_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
//       apb_resp.start(env_h.apb_agent_h.apb_sequencer_h); 
//     join 
//     end
    
    repeat(12) begin 
    fork
      ahb_idle_req.start(env_h.ahb_agent_h.ahb_sequencer_h);
      apb_resp.start(env_h.apb_agent_h.apb_sequencer_h); 
    join 
    end
    
    phase.drop_objection(this);
  endtask

endclass