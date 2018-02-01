//
// Copyright (c) 2014-2015 by 1801BM1@gmail.com
//
// Universal Serial Asynchronous Receiver-Transmitter (simplified 8251)
//______________________________________________________________________________
//
module uart_wb #(parameter REFCLK=50000000)
(
   input             wb_clk_i,   // system clock
   input             wb_rst_i,   // peripheral reset
                                 //
   input  [0:0]      wb_adr_i,   //
   input  [7:0]      wb_dat_i,   //
   output reg [7:0]  wb_dat_o,   //
   input             wb_cyc_i,   //
   input             wb_we_i,    //
   input             wb_stb_i,   //
   output reg        wb_ack_o,   //
                                 //
   output            tx_dat_o,   // output serial data (txd)
   input             tx_cts_i,   // enable transmitter (rts)
   input             rx_dat_i,   // input serial data (rxd)
   output            rx_dtr_o,   // receiver ready (cts)
                                 //
   output            tx_ready_o, // tx ready request
   output            tx_empty_o, // tx empty request
   output            rx_ready_o, // rx ready request
                                 //
   input [15:0]      cfg_bdiv,   // baudrate divisor: (921600/baud)-1
   input [1:0]       cfg_nbit,   // word length: 00-5, 01-6, 10-7, 11-8 bit
   input             cfg_nstp,   // tx stop bits: 0 - 1 stop, 1 - 2 stop
   input             cfg_pena,   // parity control enable
   input             cfg_podd    // odd parity (complete to odd ones)
);

wire  [63:0]   add_arg;
reg   [16:0]   add_reg;
reg   [15:0]   baud_div;
reg            baud_x16;
wire           baud_ref;

reg   [1:0]    tx_cts_reg;
reg   [1:0]    rx_dat_reg;

wire           csr_wstb;
wire           rbr_rstb;
wire           thr_wstb;

wire           tx_par;
reg   [7:0]    tx_thr;
reg   [9:0]    tx_shr;
reg   [7:0]    tx_bcnt;
reg            tx_busy;
reg            tx_ready, tx_empty, tx_break;

wire           rx_dat;
reg   [7:0]    rx_rbr;
reg   [8:0]    rx_shr;
reg   [7:0]    rx_bcnt;
reg            rx_ready, rx_perr, rx_ovf, rx_break;
wire           rx_load, rx_stb;
reg            rx_frame, rx_start, rx_par;

//______________________________________________________________________________
//
// Caution note: the arithmetic expressions should be calculated in 64-bit width
//
assign   add_arg = (64'h0000000000100000 * 64'd921600)/REFCLK;
assign   baud_ref = add_reg[16];
//
// Phase accumulator to generate 921600 * 16 Hz reference clock strobe
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
   if (wb_rst_i)
      add_reg <= 17'h00000;
   else
   begin
      add_reg <= {1'b0, add_reg[15:0]} + add_arg[16:0];
   end
end
//
// Baud rate x16 generator
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
   if (wb_rst_i)
   begin
      baud_div <= 16'h0000;
      baud_x16 <= 1'b0;
   end
   else
   begin
      if (baud_ref)
         if (baud_div == 16'h0000)
            baud_div <= cfg_bdiv;
         else
            baud_div <= baud_div - 16'h0001;

      baud_x16 <= baud_ref & (baud_div == 16'h0000);
   end

end

//______________________________________________________________________________
//
assign csr_wstb = wb_cyc_i & wb_stb_i &  wb_we_i &  wb_ack_o &  wb_adr_i[0];
assign thr_wstb = wb_cyc_i & wb_stb_i &  wb_we_i &  wb_ack_o & ~wb_adr_i[0];
assign rbr_rstb = wb_cyc_i & wb_stb_i & ~wb_we_i & ~wb_ack_o & ~wb_adr_i[0];
//
// Output data multiplexed register
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
   if (wb_rst_i)
      wb_dat_o <= 8'h00;
   else
      if (wb_cyc_i & wb_stb_i & ~wb_ack_o)
         begin
            if (wb_adr_i[0])
               wb_dat_o <= (tx_ready << 7)
                        | (tx_break << 6)
                        | (tx_empty << 5)
                        | (rx_ready << 3)
                        | (rx_break << 2)
                        | (rx_perr << 1)
                        | (rx_ovf  << 0);
            else
               wb_dat_o <= rx_rbr;
         end
end

always @(posedge wb_clk_i)
   wb_ack_o <= wb_cyc_i & wb_stb_i & ~wb_ack_o;

//
// Control register bits
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
   if (wb_rst_i)
      tx_break <= 1'b0;
   else
      if (csr_wstb) tx_break <= wb_dat_i[6];
end

//______________________________________________________________________________
//
// Interrupts
//
assign tx_ready_o = tx_ready;
assign tx_empty_o = tx_empty;
assign rx_ready_o = rx_ready;

//______________________________________________________________________________
//
// Metastability issues
//
always @(posedge wb_clk_i)
begin
   tx_cts_reg[0] <= ~tx_cts_i;
   tx_cts_reg[1] <= tx_cts_reg[0];

   rx_dat_reg[0] <= rx_dat_i;
   rx_dat_reg[1] <= rx_dat_reg[0];
end

//______________________________________________________________________________
//
// Transmitter unit
//
assign tx_par = tx_thr[0] ^ tx_thr[1] ^ tx_thr[2] ^ tx_thr[3] ^ tx_thr[4]
              ^ (tx_thr[5] & (cfg_nbit >= 2'b01))
              ^ (tx_thr[6] & (cfg_nbit >= 2'b10))
              ^ (tx_thr[7] & (cfg_nbit == 2'b11))
              ^ cfg_podd;
assign tx_dat_o = tx_shr[0] & ~tx_break;

always @(posedge wb_clk_i or posedge wb_rst_i)
begin
   if (wb_rst_i)
   begin
      tx_ready <= 1'b1;
      tx_empty <= 1'b1;
      tx_shr  <= 10'o1777;
      tx_busy <= 1'b0;
      tx_bcnt <= 8'b00000000;
      tx_thr  <= 8'b00000000;
   end
   else
   begin
      tx_empty <= tx_ready & ~tx_busy;
      //
      // Transmitter hold register write
      //
      if (thr_wstb)
      begin
         tx_ready <= 1'b0;
         tx_thr <= wb_dat_i[7:0];
      end

      if (baud_x16)
      begin
         //
         // Transmit process
         //
         if (tx_busy)
         begin
            if (tx_bcnt == 8'b00000001)
               tx_busy <= 1'b0;

            if (tx_bcnt != 8'b00000000)
               tx_bcnt <= tx_bcnt - 8'b00000001;

            if (tx_bcnt[3:0] == 4'b0000)
               tx_shr  <= {1'b1, tx_shr[9:1]};
         end

         //
         // Starting new word transmit
         //
         if (~tx_ready & ~tx_busy & tx_cts_reg[1])
         begin
            tx_busy    <= 1'b1;
            tx_ready   <= ~thr_wstb;
            tx_bcnt    <= {4'b0110 + {2'b00, cfg_nbit} + {3'b000, cfg_pena} + {3'b000, cfg_nstp}, 4'b1111};

            if (cfg_pena)
               case(cfg_nbit)
                  2'b00:   tx_shr <= {3'b111, tx_par, tx_thr[4:0], 1'b0};
                  2'b01:   tx_shr <= {2'b11,  tx_par, tx_thr[5:0], 1'b0};
                  2'b10:   tx_shr <= {1'b1,   tx_par, tx_thr[6:0], 1'b0};
                  default: tx_shr <= {        tx_par, tx_thr[7:0], 1'b0};
               endcase
            else
               case(cfg_nbit)
                  2'b00:   tx_shr <= {4'b1111, tx_thr[4:0], 1'b0};
                  2'b01:   tx_shr <= {3'b111,  tx_thr[5:0], 1'b0};
                  2'b10:   tx_shr <= {2'b11,   tx_thr[6:0], 1'b0};
                  default: tx_shr <= {1'b1,    tx_thr[7:0], 1'b0};
               endcase
         end
      end
   end
end

//______________________________________________________________________________
//
// Receiver unit
//
assign rx_dtr_o = rx_ready;
assign rx_dat   = rx_dat_reg[1];

assign rx_load = rx_stb & (rx_bcnt[7:4] == 4'b0000);
assign rx_stb  = (rx_bcnt[3:0] == 4'b0001) & baud_x16;

always @(posedge wb_clk_i or posedge wb_rst_i)
begin
   if (wb_rst_i)
   begin
      rx_ready <= 1'b0;
      rx_break <= 1'b0;
      rx_perr  <= 1'b0;
      rx_ovf   <= 1'b0;
      rx_frame <= 1'b0;
      rx_start <= 1'b0;
      rx_par   <= 1'b0;
      rx_rbr  <= 8'b00000000;
      rx_shr  <= 9'b00000000;
      rx_bcnt <= 8'b00000000;
   end
   else
   begin
      if (rx_load)
      begin
         rx_ready  <= 1'b1;
         case(cfg_nbit)
            2'b00:   rx_rbr <= {3'b000, rx_shr[4:0]};
            2'b01:   rx_rbr <= {2'b00, rx_shr[5:0]};
            2'b10:   rx_rbr <= {1'b0, rx_shr[6:0]};
            default: rx_rbr <= rx_shr[7:0];
         endcase
         rx_perr  <= rx_par;
         rx_ovf   <= rx_ready;
         rx_break <= ~rx_dat;
      end
      else
         if (rbr_rstb)
         begin
            rx_ready <= 1'b0;
            rx_perr  <= 1'b0;
            rx_ovf   <= 1'b0;
         end

      if (baud_x16)
      begin
         if (~rx_frame)
            //
            // Waiting for start bit
            //
            if (~rx_dat)
            begin
               rx_par   <= cfg_pena & cfg_podd;
               rx_start <= 1'b1;
               rx_frame <= 1'b1;
               rx_bcnt  <= {4'b0110 + {2'b00, cfg_nbit} + {3'b000, cfg_pena}, 4'b0111};
            end
            else
            begin
               rx_start <= 1'b0;
               rx_bcnt  <= 8'b00000000;
            end
         else
         begin
            //
            // Receiving frame
            //
            if (rx_bcnt != 8'b00000000)
               rx_bcnt <= rx_bcnt - 8'b00000001;
            //
            // Start bit monitoring
            //
            if (rx_start)
            begin
               if (rx_dat)
               begin
                  //
                  // Spurrious start bit
                  //
                  rx_start <= 1'b0;
                  rx_frame <= 1'b0;
                  rx_bcnt  <= 8'b00000000;
               end
               else
                  if (rx_bcnt[3:0] == 4'b0010)
                     rx_start <= 1'b0;
            end
            else
            begin
               //
               // Receiving data
               //
               if (rx_stb)
               begin
                  rx_par <= (rx_par ^ rx_dat) & cfg_pena;
                  if (cfg_pena)
                     case(cfg_nbit)
                        2'b00:   rx_shr <= {3'b000, rx_dat, rx_shr[5:1]};
                        2'b01:   rx_shr <= {2'b00, rx_dat, rx_shr[6:1]};
                        2'b10:   rx_shr <= {1'b0, rx_dat, rx_shr[7:1]};
                        default: rx_shr <= {rx_dat, rx_shr[8:1]};
                     endcase
                  else
                     case(cfg_nbit)
                        2'b00:   rx_shr <= {4'b0000, rx_dat, rx_shr[4:1]};
                        2'b01:   rx_shr <= {3'b000, rx_dat, rx_shr[5:1]};
                        2'b10:   rx_shr <= {2'b00, rx_dat, rx_shr[6:1]};
                        default: rx_shr <= {1'b0, rx_dat, rx_shr[7:1]};
                     endcase
                  if (rx_load & rx_dat)
                  begin
                     //
                     // Stop bit detected
                     //
                     rx_frame <= 1'b0;
                     rx_bcnt  <= 8'b00000000;
                  end
               end
               if ((rx_bcnt == 8'b00000000) & rx_dat)
                  rx_frame <= 1'b0;
            end
         end
      end
   end
end
endmodule
