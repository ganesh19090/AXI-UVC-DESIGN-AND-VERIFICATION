`include "uvm_macros.svh"
import uvm_pkg::*;

// Component constructor macro
`define COMP_CONS \
  function new(string name="", uvm_component parent); \
    super.new(name, parent); \
  endfunction

// Object constructor macro
`define OBJ_CONS \
  function new(string name=""); \
    super.new(name); \
  endfunction

typedef enum bit [1:0] {
	FIXED=2'b00,
	INCR=2'b01,
	WRAP=2'b10,
	RSVD=2'b11
}burst_t;

typedef enum bit [1:0] {
	OKAY=2'b00,
	EXOKAY=2'b01,
	SLVERR=2'b10,
	DECERR=2'b11
}resp_t;
class axi_common extends uvm_component;

  // factory registration
  `uvm_component_utils(axi_common)

  // new constructor
  `COMP_CONS

endclass

