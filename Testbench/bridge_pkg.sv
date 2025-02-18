package bridge_pkg;

  import uvm_pkg::*;

  localparam int HADDR_SIZE = 32;
  localparam int HDATA_SIZE = 32;
  localparam int PADDR_SIZE = 10;
  localparam int PDATA_SIZE = 8;
  localparam int SYNC_DEPTH = 3;



  localparam [1:0] IDLE   = 2'b00;
  localparam [1:0] BUSY   = 2'b01;
  localparam [1:0] NONSEQ = 2'b10;
  localparam [1:0] SEQ    = 2'b11;

  `include "uvm_macros.svh"

  `include "ahb_sequence_item.sv"
  `include "apb_sequence_item.sv"

  `include "ahb_sequences.sv"
  `include "apb_sequences.sv"

  `include "ahb_sequencer.sv"
  `include "apb_sequencer.sv" 

  `include "ahb_driver.sv"
  `include "apb_driver.sv"

  `include "ahb_monitor.sv"
  `include "apb_monitor.sv"

  //`include "scoreboard.sv"

  //`include "coverage.sv"

  `include "ahb_agent.sv"
  `include "apb_agent.sv"

  `include "env.sv"

  `include "test_cases.sv"

endpackage 