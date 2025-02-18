class env extends uvm_env;
  `uvm_component_utils(env)
  
  
  ahb_agent ahb_agent_h ;
  apb_agent apb_agent_h ;
  scoreboard scoreboard_h ;
  //coverage_collector coverage_collector_h ;
 
  
  
  // Constructor 
    function new(string name = "env" ,uvm_component parent);
         super.new(name,parent); 
    endfunction : new
              
              
  
  // Build Phase 
    function void build_phase(uvm_phase phase);
     super.build_phase(phase);     
      ahb_agent_h = ahb_agent::type_id::create("ahb_agent_h",this);
      apb_agent_h = apb_agent::type_id::create("apb_agent_h",this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);  
      //coverage_collector_h = coverage_collector::type_id::create("coverage_collector_h",this);     
    endfunction :build_phase    
              
  
  
    
  // Connect Phase 
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase); 
//       ahb_agent.ahb_monitor.monitor_ap.connect(scoreboard_h.sb_mon_port) ; // Connect monitor to scoreboard by analysis port              
//       ahb_agent.ahb_monitor.monitor_ap.connect(coverage_collector_h.cov_mon_port) ; // Connect monitor to Coverage by analysis port  
//       apb_agent.apb_monitor.monitor_ap.connect(scoreboard_h.sb_mon_port) ; // Connect monitor to scoreboard by analysis port              
//       apb_agent.apb_monitor.monitor_ap.connect(coverage_collector_h.cov_mon_port) ; // Connect monitor to Coverage by analysis port  
  endfunction :connect_phase
  
  
  // Run Phase 
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
    endtask : run_phase
  
endclass : env
