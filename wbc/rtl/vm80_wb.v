//
// Copyright (c) 2014-2018 by 1801BM1@gmail.com
// Licensed under CC-BY 3.0 (https://creativecommons.org/licenses/by/3.0/)
//
// Wishbone compatibe version of revengineered 580BM80A/i8080A
//______________________________________________________________________________
//
module vm80_wb
(
   input          wb_clk_i,      // module clock
   input          wb_rst_i,      // module reset
                                 //
   output[15:0]   wb_adr_o,      // address bus outputs
   output[7:0]    wb_dat_o,      // data bus output
   input [7:0]    wb_dat_i,      // data bus input
   output         wb_cyc_o,      // master wishbone cycle
   output         wb_we_o,       // master wishbone direction
   output         wb_stb_o,      // master wishbone strobe
   input          wb_ack_i,      // master wishbone acknowledge
                                 //
                                 // Wishbone cycle tags
   output   [5:0] wb_tgc_o,      // [0] M1 command fetch
                                 // [1] IO space tag
                                 // [2] Write cycle tag
                                 // [3] Stack operation
                                 // [4] Interrupt acknowledge
                                 // [5] Processor halted
                                 //
   input          vm_cena,       // clock enable
   input          vm_irq,        // interrupt request
   output         vm_inte        // interrupt enable flag
);

//______________________________________________________________________________
//
wire           clk;              // global module clock
wire           ena;              // global clock enable
reg            reset;            // latched module reset

reg   [15:0]   a;                // output address buffer
wire  [7:0]    d;                // internal data bus mux
reg   [7:0]    db;               // data output buffer
reg   [7:0]    di;               // data input buffer

reg            dbin_rd, wb_cyc;
reg            wb_stb, wb_we;
wire           ready, dad_m45;
wire           io_rdy, io_ena;
reg   [2:0]    io_cnt;

reg   [15:0]   r16_pc, r16_hl, r16_de, r16_bc, r16_sp, r16_wz;
wire  [15:0]   mxi, mxo;
wire           mxr0, mxr1, mxr2, mxr3, mxr4, mxr5;
wire           mxwh, mxwl, mxrh, mxrl, mxw16, mxwadr;
wire           dec16, inc16, iad16;
reg            xchg_dh, xchg_tt;
wire           t1467, t1513, t1514, t1519;

wire           sy_wo_n, sy_stack;

reg            t1, t2, tw, t3, t4, t5;
reg            m1, m2, m3, m4, m5;

wire           thalt, start, eom, ms0, ms1, m789, m836;
reg            intr, inta, inte, minta;
wire           irq;

reg   [7:0]    i;
wire           i25, i14, i03, imx, acc_sel;
wire           id_op, id_io, id_in, id_popsw, id_pupsw,
               id_nop, id_lxi, id_inx, id_inr, id_dcr, id_idr, id_mvi, id_dad,
               id_dcx, id_opa, id_idm, id_hlt, id_mov, id_opm, id_pop, id_rst,
               id_cxx, id_jxx, id_rxx, id_ret, id_jmp, id_opi, id_out, id_11x,
               id_rlc, id_rxc, id_rar, id_sha, id_daa, id_cma, id_stc, id_cmc,
               id_add, id_adc, id_sub, id_sbb, id_ana, id_xra, id_ora, id_cmp,
               id_lsax, id_mvim, id_shld, id_lhld, id_mvmr, id_mvrm, id_push,
               id_xthl, id_sphl, id_pchl, id_xchg, id_call, id_eidi, id_stlda;

wire           id80, id81, id82, id83, id84, id85, id86, id00, id01,
               id02, id03, id04, id05, id06, id07, id08, id09, id10;
wire           goto, jmpflag;
reg            jmptake, tree1t;
wire           tree1, tree2;

reg   [7:0]    xr, r, acc;
wire  [7:0]    x, s, c;
wire           cl, ch, daa, daa_6x, daa_x6;
wire           alu_xout, alu_xwr, alu_xrd, alu_ald, alu_awr, alu_ard,
               alu_rld, alu_r00, alu_rwr, alu_srd, alu_zrd, alu_pha;

reg            psw_z, psw_s, psw_p, psw_c, psw_ac, tmp_c;
wire           psw_ld, psw_wr, psw_oe;

//_____________________________________________________________________________
//
// Wishbone logic
//
assign clk     = wb_clk_i;
//
// Latch the external reset (can has the huge input tree)
//
always @(posedge clk) reset <= wb_rst_i;

//
// We cannot stop the T-state machine while writing, no present written data on the bus,
// we should wait, but the state machine goes to T3 (at that data and write strobe are)
// and does not wait there (8080 waits on the transfer T2->T3). So we have to use
// the global clock enable.
//
assign io_ena     = ~(wb_cyc_o & wb_we_o & wb_stb_o & ~wb_ack_i);
assign io_rdy     = ~sy_wo_n | (wb_cyc_o & wb_stb_o & wb_ack_i);
//
// Use former ready external input to stall the CPU while reading
//
assign dad_m45 = (m4 | m5) & id_dad;
assign ready   = dad_m45 | io_rdy;
//
// Implement wishbone output registers
//
assign wb_adr_o   = a;
assign wb_dat_o   = db;
assign wb_cyc_o   = wb_cyc;
assign wb_stb_o   = wb_stb;
assign wb_we_o    = wb_we;

always @(posedge clk or posedge reset)
begin
   if (reset)
      begin
         wb_cyc <= 1'b0;
         wb_stb <= 1'b0;
         wb_we  <= 1'b0;
      end
   else
      if (wb_ack_i & wb_stb_o & wb_cyc)
         begin
            wb_cyc <= 1'b0;
            wb_stb <= 1'b0;
            wb_we  <= 1'b0;
         end
      else
         begin
            wb_we <= ~sy_wo_n;

            if ( (t1 & ~dad_m45 & ~sy_wo_n)
               | (t1 &  sy_wo_n))
                  wb_cyc <= 1'b1;

            if ( (t2  & ~dad_m45 & ~sy_wo_n)
               | (t1 & sy_wo_n))
                  wb_stb <= 1'b1;
         end
end

always @(posedge clk)
if (ena)
begin
   dbin_rd <= (t2 | tw) & sy_wo_n & (m1 | ~id_hlt);
   if ((t2 | tw) & sy_wo_n) di <= wb_dat_i;
   if (~sy_wo_n & t2) db <= d;
end

//______________________________________________________________________________
//
// Clock moderator for slow origial speed emulation, vm_cena is used for
// The entire core stopped before entering the T1 tick
//
assign ena = ~(~io_ena | eom & (io_cnt != 3'b000));

always @(posedge clk or posedge reset)
begin
   if (reset)
      io_cnt <= 3'b000;
   else
      begin
         if (~ena & vm_cena & (io_cnt != 3'b000))
            io_cnt <= io_cnt - 3'b001;

         if (ena & ~vm_cena & (io_cnt != 3'b111))
            io_cnt <= io_cnt + 3'b001;
   end
end

//______________________________________________________________________________
//
// Internal data bus mux
//
assign d[7]    = ~alu_zrd &
               ( dbin_rd & di[7]
               | mxrl & mxo[7]
               | mxrh & mxo[15]
               | alu_xrd & xr[7]
               | alu_ard & acc[7]
               | alu_srd & s[7]
               | psw_oe & psw_s);

assign d[6]    = ~alu_zrd &
               ( dbin_rd & di[6]
               | mxrl & mxo[6]
               | mxrh & mxo[14]
               | alu_xrd & xr[6]
               | alu_ard & acc[6]
               | alu_srd & s[6]
               | psw_oe & psw_z);

assign d[5]    = ~alu_zrd &
               ( dbin_rd & di[5]
               | mxrl & mxo[5]
               | mxrh & mxo[13]
               | alu_xrd & xr[5]
               | alu_ard & acc[5]
               | alu_srd & s[5]
               | psw_oe & 1'b0);

assign d[4]    = ~alu_zrd &
               ( dbin_rd & di[4]
               | mxrl & mxo[4]
               | mxrh & mxo[12]
               | alu_xrd & xr[4]
               | alu_ard & acc[4]
               | alu_srd & s[4]
               | psw_oe & psw_ac);

assign d[3]    = ~alu_zrd &
               ( dbin_rd & di[3]
               | mxrl & mxo[3]
               | mxrh & mxo[11]
               | alu_xrd & xr[3]
               | alu_ard & acc[3]
               | alu_srd & s[3]
               | psw_oe & 1'b0);

assign d[2]    = ~alu_zrd &
               ( dbin_rd & di[2]
               | mxrl & mxo[2]
               | mxrh & mxo[10]
               | alu_xrd & xr[2]
               | alu_ard & acc[2]
               | alu_srd & s[2]
               | psw_oe & psw_p);

assign d[1]    = ~alu_zrd &
               ( dbin_rd & di[1]
               | mxrl & mxo[1]
               | mxrh & mxo[9]
               | alu_xrd & xr[1]
               | alu_ard & acc[1]
               | alu_srd & s[1]
               | psw_oe & 1'b1);

assign d[0]    = ~alu_zrd &
               ( dbin_rd & di[0]
               | mxrl & mxo[0]
               | mxrh & mxo[8]
               | alu_xrd & xr[0]
               | alu_ard & acc[0]
               | alu_srd & s[0]
               | psw_oe & psw_c);

//______________________________________________________________________________
//
// register unit - 6 16-bit registers
//
//    r0 - pc
//    r1 - hl, de (runtime alias via xchg_dh flag)
//    r2 - de, hl (runtime alias via xchg_dh flag)
//    r3 - bc
//    r4 - sp
//    r5 - wz
//
assign      t1467    = tree1 | (id04 & t4 & ~id_xthl);

assign      t1513    = (t4 & id07)
                     | id07 & ((t1 & (m4 | m5)) | (t3 & (m2 | m3)) | t5);

assign      t1514    = (t4 & id08)
                     | t1 & m4 & id_lsax
                     | t2 & id10 & ~sy_wo_n
                     | t3 & id10 & sy_wo_n & (m4 | m5)
                     | t5 & id08 & m1;
assign      t1519    = tree2 | (id00 & t4 & ~id_xthl);

assign      mxi      = inc16 ? (a + 16'h0001)
                     : dec16 ? (a - 16'h0001)
                     : a;

assign      inc16    = iad16 & ~dec16;
assign      dec16    = iad16 & id05 & (t4 | t5 | m4 | m5);
assign      iad16    = ~(id00 & (t4 | t5)) & (~minta | m5 | t4 | t5 | (m4 & ~id02));

assign      mxw16    = t2 & ( (m1 | m2)
                            | (m3 & ~id_xthl)
                            | ((m4 | m5) & ~id_dad & ~id09))
                     | t3 & m4 & id09
                     | t5 & (m5 | (m1 & ~id08));

assign      mxwadr   = t4 & ~id_dad & ~id_hlt
                     | t1 & (m1 | m2 | m3 | ((m4 | m5) & ~id_hlt & ~id_dad));


assign      mxrh     = id08 & t4 & ~i03
                     | (t1 | t2) & m5 & id_dad
                     | t2 & ((m5 & id_shld) | (m4 & id03));

assign      mxrl     = id08 & t4 & i03
                     | (t1 | t2) & m4 & id_dad
                     | t2 & ((m4 & id_shld) | (m5 & id03));

assign      mxwh     = reset
                     | t3 & (m1 | m3 | (m4 & id_io) | (m5 & id06))
                     | ((t3 & m4) | (t5 & m1)) & id08 & ~i03;

assign      mxwl     = reset
                     | t3 & (m2 | (m4 & id06) | (m5 & id_rst))
                     | ((t3 & m4) | (t5 & m1)) & id08 & i03;

assign      mxr0     = t1 & ( (m1 & ~goto)
                            | (m2 & ~id_xthl)
                            | (m3 & ~id_xthl)
                            | (m4 & id02))
                     | t2 & (  m1
                            | (m2 & ~id_xthl)
                            | (m3 & ~id_xthl)
                            | (m4 & (id02 | id_rst | id_cxx | id_call))
                            | (m5 & (id_rst | id_cxx | id_call)))
                     | t3 & ( (m4 & (id_ret | id_rxx))
                            | (m5 & (id_ret | id_rxx)))
                     | t5 & id_pchl;

assign      mxr1     =  xchg_dh & (((t1513 | t1514) & (~i14 & i25)) | t1519)
                     | ~xchg_dh & (t1513 | t1514) & (i14 & ~i25);

assign      mxr2     =  xchg_dh & (t1513 | t1514) & (i14 & ~i25)
                     | ~xchg_dh & (((t1513 | t1514) & (~i14 & i25)) | t1519);

assign      mxr3     = (t1513 | t1514) & (~i14 & ~i25);
assign      mxr4     = t1467 | (t1513 & i14 & i25);
assign      mxr5     = ~(t1467 | t1513 | t1514 | t1519 | mxr0);

always @ (posedge clk)
if (ena)
begin
   xchg_tt <= id_xchg & t2;
   xchg_dh <= ~reset & ((xchg_tt & ~(id_xchg & t2)) ? ~xchg_dh : xchg_dh);
end

assign mxo  = (mxr0 ? r16_pc : 16'h0000)
            | (mxr1 ? r16_hl : 16'h0000)
            | (mxr2 ? r16_de : 16'h0000)
            | (mxr3 ? r16_bc : 16'h0000)
            | (mxr4 ? r16_sp : 16'h0000)
            | (mxr5 ? r16_wz : 16'h0000);

always @ (posedge clk)
if (ena)
begin
   if (mxwadr) a <= mxo;
   if (mxw16)
      begin
         if (mxr0) r16_pc <= mxi;
         if (mxr1) r16_hl <= mxi;
         if (mxr2) r16_de <= mxi;
         if (mxr3) r16_bc <= mxi;
         if (mxr4) r16_sp <= mxi;
         if (mxr5) r16_wz <= mxi;
      end
   else
      begin
         if (mxwl)
            begin
               if (mxr0) r16_pc[7:0] <= d;
               if (mxr1) r16_hl[7:0] <= d;
               if (mxr2) r16_de[7:0] <= d;
               if (mxr3) r16_bc[7:0] <= d;
               if (mxr4) r16_sp[7:0] <= d;
               if (mxr5) r16_wz[7:0] <= d;
            end
         if (mxwh)
            begin
               if (mxr0) r16_pc[15:8] <= d;
               if (mxr1) r16_hl[15:8] <= d;
               if (mxr2) r16_de[15:8] <= d;
               if (mxr3) r16_bc[15:8] <= d;
               if (mxr4) r16_sp[15:8] <= d;
               if (mxr5) r16_wz[15:8] <= d;
            end
      end
end

//______________________________________________________________________________
//
// processor state
//
assign wb_tgc_o[0]   = m1;                         // command fetch
assign wb_tgc_o[1]   = m5 & (id_in | id_out);      // in/out transfer
assign wb_tgc_o[2]   = ~sy_wo_n;                   // write operation
assign wb_tgc_o[3]   = t1 ? tree1 : tree1t;        // stack operation
assign wb_tgc_o[4]   = inta;                       // interrupt acknowledge
assign wb_tgc_o[5]   = id_hlt;                     // processor halted

assign sy_wo_n  = m1 | m2 | m3 | (((m4 & ~id86) | (m5 & ~id85)) & ~dad_m45);
assign sy_stack = t1 & tree1
                | t3 & m3 & id_cxx & ~jmptake
                | t5 & m1 & id_rxx & ~jmptake;

always @(posedge clk)
   if (ena & t1)
         tree1t <= tree1;

//______________________________________________________________________________
//
// Ticks state machine
//
assign thalt   = ~m1 & id_hlt;

always @(posedge clk or posedge reset)
begin
   if (reset)
      begin
         t1 <= 1'b1;
         t2 <= 1'b0;
         tw <= 1'b0;
         t3 <= 1'b0;
         t4 <= 1'b0;
         t5 <= 1'b0;
      end
   else
      if (ena)
         begin
            t1 <= start;
            t2 <= ~start & t1;
            tw <= ~start & (t2 | tw) & (~ready | thalt);
            t3 <= ~start & (t2 | tw) &  ready & ~thalt;
            t4 <= ~start & t3 & ms0 & ~ms1;
            t5 <= ~start & t4 & ms0 & ~ms1;
         end
end

//______________________________________________________________________________
//
assign start   = reset | eom | (id_hlt & minta & m4);
assign m836    = m1 & id82;
assign m789    = (id84 & m3) | (id83 & ~id_mvim & m4) | m5;
assign eom     = t5
               | t4 & m1 & id80
               | t3 & m2
               | t3 & m3
               | t3 & m4
               | t3 & m5 & ~id_xthl;

assign ms0 = ~reset & (~(minta & m4) | ~id_hlt) & ~(sy_stack & ~t1) & ~(eom & ~m836);
assign ms1 = ~reset & (~(minta & m4) | ~id_hlt) & ~(sy_stack & ~t1) & ~((m789 | id81) & ~m836) & eom;

//______________________________________________________________________________
//
// Processor M-cycles state machine
//
always @(posedge clk or posedge reset)
begin
   if (reset)
      begin
            m1 <= 1'b1;
            m2 <= 1'b0;
            m3 <= 1'b0;
            m4 <= 1'b0;
            m5 <= 1'b0;
      end
   else
      if (ena)
         begin
            m1 <= (~ms0 & ~ms1) | (~ms1 & m1);
            m2 <= (~ms0 | ~ms1) & ((ms0 & m2) | (ms1 & m1));
            m3 <= (ms0 & m3) | (ms1 & m2);
            m4 <= (ms0 & m4) | (ms1 & m3) | (ms0 & ms1);
            m5 <= (ms0 & m5) | (ms1 & m4);
         end
end

//______________________________________________________________________________
//
// Interrupt logic
// Interrupt acknowledge in the halt mode and other stuff removed
//
assign irq = intr & inte & ~reset;
assign vm_inte = inte;

always @(posedge clk or posedge reset)
begin
   if (reset)
      begin
         inta  <= 0;
         inte  <= 0;
         minta <= 0;
      end
   else
      if (ena)
         begin
            intr <= vm_irq;

            if (irq & (~ms0 & ~ms1 | tw & id_hlt) & ~id_eidi) inta <= 1;
            if (~intr | id_eidi | (t5 & id_rst)) inta <= 0;

            if (inta)        minta <= 1;
            if (~ms0 & ~ms1) minta <= 0;

            if (t1 & id_eidi) inte <= i[3];
            if (t1 & inta) inte <= 0;
         end
end
//______________________________________________________________________________
//
// Instruction register and decoder
//
function cmp
(
   input [7:0] i,
   input [7:0] c,
   input [7:0] m
);
   cmp = &(~(i ^ c) | m);
endfunction

assign imx     = ~(id_op | (id_mov & t4));
assign i25     = imx ? i[5] : i[2];
assign i14     = imx ? i[4] : i[1];
assign i03     = imx ? i[3] : i[0];
assign acc_sel = imx ? (i[5:3] == 3'b111) : (i[2:0] == 3'b111);

assign jmpflag =    (psw_c &  i14 & ~i25)    // Intel original: d[0] instead of psw_c
                  | (psw_p & ~i14 &  i25)    // Intel original: d[2] instead of psw_p
                  | (psw_z & ~i14 & ~i25)    // Intel original: d[6] instead of psw_z
                  | (psw_s &  i14 &  i25);   // Intel original: d[7] instead of psw_s


always @(posedge clk or posedge reset)
begin
   if (reset)
      i <= 8'h00;
   else
      if (ena & m1 & t3)
         i <= di;
end

assign goto    = id_rst | id_jmp | id_call | (jmptake & (id_cxx | id_jxx));

assign tree1   = (t1 & ((m2 & id00)
                      | (m3 & id00)
                      | (m4 & (id01 | id04))
                      | (m5 & (id01 | id04)))
               | t2 & ( (m2 & id00)
                      | (m4 & id01)
                      | (m5 & id01))
               | t3 & ( (m4 & (id04 | id_sphl)))
               | t5 & ( (m1 & (id04 | id_sphl)))) & ~(~jmptake & id_cxx & t5);

assign tree2   = t1 & ( (m4 & (id_mov | id_idr | id_op))
                      | (m5 & id08))
               | t2 & ( (m4 & (id_shld | id00 | id_dad))
                      | (m5 & (id_shld | id00 | id_dad)))
               | t3 & ( (m4 & (id_lhld | id_dad))
                      | (m5 & (id_lhld | id_dad)))
               | t5 & m5;

always @(posedge clk)
   if (ena & t4)
      jmptake <= i03 ? jmpflag : ~jmpflag;

assign id_nop     = cmp(i, 8'b00xxx000, 8'b00111000);
assign id_lxi     = cmp(i, 8'b00xx0001, 8'b00110000);
assign id_lsax    = cmp(i, 8'b000xx010, 8'b00011000);
assign id_inx     = cmp(i, 8'b00xx0011, 8'b00110000);
assign id_inr     = cmp(i, 8'b00xxx100, 8'b00111000);
assign id_dcr     = cmp(i, 8'b00xxx101, 8'b00111000);
assign id_idr     = cmp(i, 8'b00xxx10x, 8'b00111001);
assign id_mvi     = cmp(i, 8'b00xxx110, 8'b00111000);
assign id_dad     = cmp(i, 8'b00xx1001, 8'b00110000);
assign id_dcx     = cmp(i, 8'b00xx1011, 8'b00110000);
assign id_opa     = cmp(i, 8'b00xxx111, 8'b00111000);
assign id_idm     = cmp(i, 8'b0011010x, 8'b00000001);
assign id_stlda   = cmp(i, 8'b0011x010, 8'b00001000);
assign id_mvim    = cmp(i, 8'b00110110, 8'b00000000);
assign id_shld    = cmp(i, 8'b00100010, 8'b00000000);
assign id_lhld    = cmp(i, 8'b00101010, 8'b00000000);
assign id_mvmr    = cmp(i, 8'b01110xxx, 8'b00000111) & ~id_hlt;
assign id_mvrm    = cmp(i, 8'b01xxx110, 8'b00111000) & ~id_hlt;
assign id_hlt     = cmp(i, 8'b01110110, 8'b00000000);
assign id_mov     = cmp(i, 8'b01xxxxxx, 8'b00111111);
assign id_op      = cmp(i, 8'b10xxxxxx, 8'b00111111);
assign id_opm     = cmp(i, 8'b10xxx110, 8'b00111000);
assign id_pop     = cmp(i, 8'b11xx0001, 8'b00110000);
assign id_push    = cmp(i, 8'b11xx0101, 8'b00110000);
assign id_rst     = cmp(i, 8'b11xxx111, 8'b00111000);
assign id_xthl    = cmp(i, 8'b11100011, 8'b00000000);
assign id_sphl    = cmp(i, 8'b11111001, 8'b00000000);
assign id_pchl    = cmp(i, 8'b11101001, 8'b00000000);
assign id_xchg    = cmp(i, 8'b11101011, 8'b00000000);
assign id_cxx     = cmp(i, 8'b11xxx100, 8'b00111000);
assign id_jxx     = cmp(i, 8'b11xxx010, 8'b00111000);
assign id_rxx     = cmp(i, 8'b11xxx000, 8'b00111000);
assign id_ret     = cmp(i, 8'b110x1001, 8'b00010000);
assign id_call    = cmp(i, 8'b11xx1101, 8'b00110000);
assign id_eidi    = cmp(i, 8'b1111x011, 8'b00001000);
assign id_jmp     = cmp(i, 8'b1100x011, 8'b00001000);
assign id_io      = cmp(i, 8'b1101x011, 8'b00001000);
assign id_opi     = cmp(i, 8'b11xxx110, 8'b00111000);
assign id_in      = cmp(i, 8'b11011011, 8'b00000000);
assign id_popsw   = cmp(i, 8'b11110001, 8'b00000000);
assign id_out     = cmp(i, 8'b11010011, 8'b00000000);
assign id_11x     = cmp(i, 8'b11xxxxxx, 8'b00111111);
assign id_pupsw   = cmp(i, 8'b11110101, 8'b00000000);

assign id_rxc     = ~i[5] & i[3] & id_opa;
assign id_sha     = ~i[5]        & id_opa;
assign id_rlc     = (i[5:3] == 3'b000) & id_opa;
assign id_rar     = (i[5:3] == 3'b011) & id_opa;
assign id_daa     = (i[5:3] == 3'b100) & id_opa;
assign id_cma     = (i[5:3] == 3'b101) & id_opa;
assign id_stc     = (i[5:3] == 3'b110) & id_opa;
assign id_cmc     = (i[5:3] == 3'b111) & id_opa;

assign id_add     = (i[5:3] == 3'b000) & (id_op | id_opi);
assign id_adc     = (i[5:3] == 3'b001) & (id_op | id_opi);
assign id_sub     = (i[5:3] == 3'b010) & (id_op | id_opi);
assign id_sbb     = (i[5:3] == 3'b011) & (id_op | id_opi);
assign id_ana     = (i[5:3] == 3'b100) & (id_op | id_opi);
assign id_xra     = (i[5:3] == 3'b101) & (id_op | id_opi);
assign id_ora     = (i[5:3] == 3'b110) & (id_op | id_opi);
assign id_cmp     = (i[5:3] == 3'b111) & (id_op | id_opi);

assign id80       = id_lxi  | id_pop   | id_opm  | id_idm  | id_dad
                  | id_xthl | id_xchg  | id_jxx  | id_ret  | id_eidi
                  | id_nop  | id_stlda | id_mvmr | id_mvrm | id_hlt
                  | id_opa  | id_mvim  | id_jmp  | id_io   | id_opi
                  | id_mvi  | id_lsax  | id_lhld | id_shld | id_op;
assign id81       = id_dcx  | id_inx   | id_sphl | id_pchl | id_xchg
                  | id_eidi | id_nop   | id_opa  | id_op   | id_mov
                  | (id_idr & ~id82);
assign id82       = id_pop  | id_push  | id_opm  | id_idm  | id_dad
                  | id_rst  | id_ret   | id_rxx  | id_mvrm | id_mvmr
                  | id_hlt  | id_mvim  | id_io   | id_opi  | id_mvi
                  | id_lsax;
assign id83       = id_opm  | id_stlda | id_mvmr | id_mvrm | id_opi
                  | id_mvi  | id_lsax;
assign id84       = id_lxi  | id_jxx   | id_jmp;
assign id85       = id_push | id_idm   | id_rst  | id_xthl | id_cxx
                  | id_call | id_mvim  | id_shld | (id_io & ~i[3]);
assign id86       = id_push | id_rst   | id_xthl | id_cxx  | id_call
                  | id_mvmr | id_shld  | (~i[3] & (id_lsax | id_stlda));

assign id00       = id_xthl   | id_pchl  | id_sphl;
assign id01       = id_pop    | id_rxx   | id_ret;
assign id02       = id_mvi    | id_opi   | id_io;
assign id03       = id_rst    | id_push  | id_xthl | id_cxx  | id_call;
assign id04       = id_rst    | id_push  | id_xthl | id_cxx  | id_call;
assign id05       = id_rst    | id_push  | id_xthl | id_cxx  | id_call | id_dcx;
assign id06       = id_pop    | id_rxx   | id_ret  | id_dad  | id_lhld | id_io;
assign id07       = id_dcx    | id_inx   | id_lxi  | id_dad;
assign id08       = id_mov    | id_mvi   | id_idr  | id_op;
assign id09       = id_rst    | id_push  | id_xthl | id_cxx  | id_call | id_shld;
assign id10       = id_pop    | id_push  | id_mvrm | id_mvi;

//______________________________________________________________________________
//
// arithmetic and logic unit (refactored)
//
assign alu_xwr  = t4 & (id_rst | id_out | ~id_11x)
                | t3 & m4 & ~(id_dad | id_out | id_rst)
                | t2 & (m4 | m5) & id_dad;

assign alu_xout = ~(id_sub | id_sbb | id_cmp | id_cma);
assign alu_xrd = t5 & m1 & ~id_inr & ~id_dcr
               | t3 & m5 & id_rst
               | t2 & ~sy_wo_n & (id_io | id_mvim | id_stlda | id_lsax | id_mvmr);

assign alu_pha = (t2 & m1) | (t1 & m5);
assign alu_r00 = id_dcr & t4;

assign alu_ald = alu_pha & ( id_adc | id_add | id_daa | id_xra | id_sbb
                         | id_sub | id_ana | id_ora | id_sha | id_cma);

assign alu_ard = t4 & m1 & ((acc_sel & id08) | id_opa | id_stlda | id_lsax | id_io)
               | t2 & m4 & id_pupsw;

assign alu_awr = t3 & m5 & id_popsw
               | t3 & m5 & (id_io | id_mvim) & sy_wo_n
               | t3 & m4 & (id_stlda | id_lsax | id_mvmr) & sy_wo_n
               | acc_sel & id08 & (t5 & m1 | t3 & m4);

assign alu_srd = t2 & m5 & (id_inr | id_dcr)
               | t3 & m5 & id_dad
               | t3 & m4 & id_dad
               | t5 & m1 & (id_inr | id_dcr);

assign alu_rwr = t3 & m1
               | t1 & (m4 | m5) & id_dad;

assign alu_rld = t4 & (id_sha | id_op | id_opi);

assign daa = id_daa & t4;
assign daa_x6 = (acc[3] & (acc[2] | acc[1])) | psw_ac;
assign daa_6x = ((acc[3] & (acc[2] | acc[1])) & acc[4] & acc[7])
              | (acc[7] & (acc[6] | acc[5])) | tmp_c;

assign x  = alu_xout ? xr : ~xr;
assign s  = {7'b0000000, id_rlc & c[7]}
          | ((id_rxc | id_ora | id_ana | id_xra) ? 8'h00 : (x + r + cl))
          | (id_rxc  ? {ch, r[7:1]} : 8'h00)
          | (id_ora  ? (x | r) : 8'h00)
          | (id_ana  ? (x & r) : 8'h00)
          | (id_xra  ? (x ^ r) : 8'h00);

assign cl = tmp_c & ~id_daa & ~id_rlc & ~id_ora & ~id_xra & ~id_rxc;
assign ch = tmp_c & id_rar | r[0] & ~id_rar;

assign c[0] = (r[0] & x[0]) | (cl & (r[0] | x[0]));
assign c[1] = (r[1] & x[1]) | (c[0] & (r[1] | x[1]));
assign c[2] = (r[2] & x[2]) | (c[1] & (r[2] | x[2]));
assign c[3] = (r[3] & x[3]) | (c[2] & (r[3] | x[3]));
assign c[4] = (r[4] & x[4]) | (c[3] & (r[4] | x[4]));
assign c[5] = (r[5] & x[5]) | (c[4] & (r[5] | x[5]));
assign c[6] = (r[6] & x[6]) | (c[5] & (r[6] | x[6]));
assign c[7] = (r[7] & x[7]) | (c[6] & (r[7] | x[7]));

assign alu_zrd = reset | (m1 & t3);
assign psw_ld  = t3 & m4 & id_popsw;
assign psw_wr  = t2 & m1 & (id_opi | id_inr | id_dcr | id_daa | id_op);
assign psw_oe  = t2 & m5 & id_pupsw;

always @(posedge clk)
if (ena)
begin
   if (alu_xwr) xr <= id_rst ? (i & 8'b00111000) : d;
   if (alu_awr) acc <= d;
   if (alu_ald) acc <= s;
   if (alu_rld) r <= acc;
   if (alu_rwr) r <= d;
   if (alu_r00) r <= 8'hff;
   if (daa)
      begin
         r[1] <= daa_x6;
         r[2] <= daa_x6;
         r[5] <= daa_6x;
         r[6] <= daa_6x;
      end
   if (psw_ld)
      begin
         psw_c  <= d[0]; // x register was in original Intel design
         psw_p  <= d[2];
         psw_ac <= d[4];
         psw_z  <= d[6];
         psw_s  <= d[7];
      end
   if (psw_wr)
      begin
         psw_p  <= ~(^s);
         psw_ac <= (c[3] & ~id_xra & ~id_ora & ~id_rxc) | (id_ana & (x[3] | r[3]));
         psw_z  <= ~(|s);
         psw_s  <= s[7];
      end
   if (alu_pha)
      begin
         if (id_cmp | id_sbb | id_sub)                   psw_c <= id_rxc ? ~x[0] : ~c[7];
         if (id_dad | id_sha | id_adc | id_add)          psw_c <= id_rxc ? x[0] : c[7];
         if (id_xra | id_stc | id_ora | id_ana | id_cmc) psw_c <= ~tmp_c;
      end
   if (daa & daa_6x) psw_c <= 1'b1;

   if ((t3 & m1) | (t2 & m5 & id_dad)) tmp_c <= psw_c;
   if (t4)
      begin
         if (id_sbb)                                              tmp_c <= ~psw_c;
         if (id_dad | id_cma | id_dcr | id_add | id_stc)          tmp_c <= 1'b0;
         if (id_inr | id_ora | id_xra | id_ana | id_cmp | id_sub) tmp_c <= 1'b1;
      end
end

//______________________________________________________________________________
//
endmodule
