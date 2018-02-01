`timescale 1ns/1ps

module ax309_mem
(
   input [13:0] addra,
   input        clka,
   input  [7:0] dina,
   input        wea,
   output [7:0] douta
);

reg [7:0]   mem [0:16383];
reg [13:0]  areg;
reg         wreg;

always @ (posedge clka)
begin
   areg <= addra;
   wreg <= wea;

   if (wreg)
      mem[areg] <= dina;
end

assign douta = mem[areg];
//
// $readmemh synthezable in XST
// Use inferred block memory instead core generator (work too boring, difficult to change content)
//
initial
begin
   $readmemh("..\\..\\..\\tst\\rom\\memini.mem", mem, 0, 16383);
end
endmodule
