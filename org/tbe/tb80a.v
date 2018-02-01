//
// Copyright (c) 2014 by 1801BM1@gmail.com
// Licensed under CC-BY 3.0 (https://creativecommons.org/licenses/by/3.0/)
//
//______________________________________________________________________________
//
`include "config.h"

//______________________________________________________________________________
//
module memory
(
   input       [15:0] a,
   input       [7:0]  din,
   output reg  [7:0]  dout,
   input       read,
   input       write
);
reg [7:0] mem [0:16383];
integer i;

always @ (posedge read)
begin
   dout = mem[a[13:0]];
end

always @ (negedge write)
begin
   mem[a[13:0]] = din;
   if (a >= 16'h4000)
      begin
         $display("Fault write @ %04X<-%02X", a, din);
         $stop;
      end
end

always @ (read)
begin
   if (a >= 16'h4000)
      begin
         $display("Fault read @ %04X", a);
         $stop;
      end
end

initial
begin
   for (i=0; i<16384; i = i + 1)
   begin
      mem[i] = 8'h00;
   end

   $readmemh("..\\..\\..\\tst\\rom\\memini.bin", mem);
end
endmodule

//______________________________________________________________________________
//

module tb80a();
//
// 580BM80A pins
//
tri1  [7:0]    d;
wire  [7:0]    d_in, d_sys;
reg   [7:0]    d_out, d_cyc;
wire           d_oe;

wire  [15:0]   a;
reg            clk;
reg            f1;
reg            f2;
reg            reset;
reg            ready;
reg            hold;
reg            intr;

wire           inte;
wire           hlda;
wire           waitr;
wire           sync;
wire           dbin;
wire           wr_n;

integer        i;
//______________________________________________________________________________
//
assign d = d_oe ? d_sys : 8'hZZ;
assign d_sys = d_cyc[0] ? 8'hE7 : d_in;

//_____________________________________________________________________________
//
// Clock generator
//
initial
begin
   clk = 1'b0;
   f1  = 1'b0;
   f2  = 1'b0;
   forever
      begin
         f1  = 1'b1;
         for (i=0; i<`SIM_CONFIG_F1; i = i + 1)
            begin
               clk = 1'b0;
               #(`SIM_CONFIG_CLOCK_HPERIOD);
               clk = 1'b1;
               #(`SIM_CONFIG_CLOCK_HPERIOD);
            end
         f1  = 1'b0;
         f2  = 1'b1;
         for (i=0; i<`SIM_CONFIG_F2; i = i + 1)
            begin
               clk = 1'b0;
               #(`SIM_CONFIG_CLOCK_HPERIOD);
               clk = 1'b1;
               #(`SIM_CONFIG_CLOCK_HPERIOD);
            end
         f2  = 1'b0;
         for (i=0; i<`SIM_CONFIG_F0; i = i + 1)
            begin
               clk = 1'b0;
               #(`SIM_CONFIG_CLOCK_HPERIOD);
               clk = 1'b1;
               #(`SIM_CONFIG_CLOCK_HPERIOD);
            end

      /*
         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);

         f1  = 1'b1;

         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);

         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);

         f1  = 1'b0;
         f2  = 1'b1;

         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);

         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);


         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         ckl = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);

         f2  = 1'b0;

         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);

         clk = 1'b0;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
         clk = 1'b1;
         #(`SIM_CONFIG_CLOCK_HPERIOD);
      */
      end
end

//
// Simulation time limit (first breakpoint)
//
initial
begin
   #`SIM_CONFIG_TIME_LIMIT $stop;
end

memory mem(.a(a), .din(d), .dout(d_in), .read(dbin), .write(~wr_n));

// always @ (DBIN) d_in    = a[7:0];
always @ (posedge wr_n) d_out   = d;
always @ (posedge sync) d_cyc   = d;

assign d_oe = dbin;
initial
begin
   reset = 1;
   intr  = 0;

   #(`SIM_CONFIG_CLOCK_HPERIOD*2*9*6);
   reset = 0;

   #(`SIM_CONFIG_CLOCK_HPERIOD*2*9*20);
   intr  = 1;
   #(`SIM_CONFIG_CLOCK_HPERIOD*2*9*20);
   intr  = 0;
end

initial
begin
   ready = 1;
   forever
      begin
         #(`SIM_CONFIG_CLOCK_HPERIOD*2*50);
         ready = 0;
         #(`SIM_CONFIG_CLOCK_HPERIOD*8);
         ready = 1;
      end
end

initial
begin
   hold = 0;
   #(`SIM_CONFIG_CLOCK_HPERIOD*4);
   forever
      begin
         #(`SIM_CONFIG_CLOCK_HPERIOD*2*500);
         hold = 1;
         #(`SIM_CONFIG_CLOCK_HPERIOD*80);
         hold = 0;
      end
end

//_____________________________________________________________________________
//
// Instantiation module under test
//
//
vm80a vm80a
(
   .pin_clk(clk),
   .pin_f1(f1),
   .pin_f2(f2),
   .pin_d(d),
   .pin_a(a),
   .pin_reset(reset),
   .pin_hold(hold),
   .pin_hlda(hlda),
   .pin_ready(ready),
   .pin_wait(waitr),
   .pin_int(intr),
   .pin_inte(inte),
   .pin_sync(sync),
   .pin_dbin(dbin),
   .pin_wr_n(wr_n)
);
endmodule

