`timescale 1ns/1ns
`include "uvm_macros.svh"
`include "bridge_pkg.sv"
`include "ahb_intf.sv"
`include "apb_intf.sv"


module top ; 
  
  import uvm_pkg::*;
  import bridge_pkg::* ;
  
  // AHB and APB clock declaration 
  bit hclk , pclk ;

   
  ahb_intf ahb_intf_h (hclk);  
  apb_intf apb_intf_h (pclk); 
  
  
  ahb3lite_apb_bridge DUT 
                      (// AHB Interface 
                      
                      .HRESETn(ahb_intf_h.HRESETn),
                      .HCLK(hclk),
                      .HSEL(ahb_intf_h.HSEL),
                      .HADDR(ahb_intf_h.HADDR),
                      .HWDATA(ahb_intf_h.HWDATA),
                      .HRDATA(ahb_intf_h.HRDATA),
                      .HWRITE(ahb_intf_h.HWRITE),
                      .HSIZE(ahb_intf_h.HSIZE),
                      .HBURST(ahb_intf_h.HBURST),
                      .HPROT(ahb_intf_h.HPROT),
                      .HTRANS(ahb_intf_h.HTRANS),
                      .HMASTLOCK(1'b1),
                      .HREADYOUT(ahb_intf_h.HREADYOUT),
                      .HREADY(ahb_intf_h.HREADY),
                      .HRESP(ahb_intf_h.HRESP),
                 
                  
                      // APB Interface 
                     .PRESETn(apb_intf_h.PRESETn),
                     .PCLK(pclk),
                     .PSEL(apb_intf_h.PSEL),
                     .PENABLE(apb_intf_h.PENABLE),
                     .PPROT(apb_intf_h.PPROT),
                     .PWRITE(apb_intf_h.PWRITE),
                     .PSTRB(apb_intf_h.PSTRB),
                     .PADDR(apb_intf_h.PADDR),
                     .PWDATA(apb_intf_h.PWDATA),
                     .PRDATA(apb_intf_h.PRDATA),
                     .PREADY(apb_intf_h.PREADY),
                     .PSLVERR(apb_intf_h.PSLVERR)              
                     ) ;
  
  
 // Clock Generation 
 initial begin
    forever begin 
       #5  hclk = ~hclk;
   //    #10 pclk = ~pclk;
    end
  end
  
  // Clock Generation 
 initial begin
    forever begin 
       
       #10 pclk = ~pclk;
    end
  end
  
  
  
 // Set the virtual interface handles to the config_db 
  initial begin     
    uvm_config_db # (virtual ahb_intf)::set(null,"*","ahb_intf_h",ahb_intf_h); 
    uvm_config_db # (virtual apb_intf)::set(null,"*","apb_intf_h",apb_intf_h);  
    run_test("double_write_test");
  end
  
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule 
  
  
