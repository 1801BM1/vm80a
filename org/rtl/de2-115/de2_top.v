//______________________________________________________________________________
//
// Top module for DE2-115 board based system
//______________________________________________________________________________
//
// External oscillator clock, feeds the PLLs
//
`define  OSC_CLOCK                  50000000
//
// Global system clock
//
`define  SYS_CLOCK                  50000000
//
// Console baudrate
//
`define  SYS_BAUD                   115200
//______________________________________________________________________________
//
// Reset button debounce interval (in ms))
//
`define  RESET_BUTTON_DEBOUNCE_MS   5
//
// Internal reset pulse width (in system clocks)
//
`define  RESET_PULSE_WIDTH_CLK      7

//______________________________________________________________________________
//
// Top project module - instantiates the DE2-115 board itself
//
module de2
(
   input          de2_clock_50,        // clock input 50 MHz
   input          de2_clock_50_2,      // clock input 50 MHz
   input          de2_clock_50_3,      // clock input 50 MHz
   input          de2_clock_25,        // Ethernet clock 25MHz
   input          de2_sma_clkin,       // SMA socket clock input
   output         de2_sma_clkout,      // SMA socket clock output
                                       //
   input    [3:0] de2_button,          // push buttons
   input   [17:0] de2_sw,              // DPDT toggle switches
                                       //
   output   [6:0] de2_hex0,            // seven segment digit 0
   output   [6:0] de2_hex1,            // seven segment digit 1
   output   [6:0] de2_hex2,            // seven segment digit 2
   output   [6:0] de2_hex3,            // seven segment digit 3
   output   [6:0] de2_hex4,            // seven segment digit 4
   output   [6:0] de2_hex5,            // seven segment digit 5
   output   [6:0] de2_hex6,            // seven segment digit 6
   output   [6:0] de2_hex7,            // seven segment digit 7
   output   [8:0] de2_ledg,            // LEDs green
   output  [17:0] de2_ledr,            // LEDs red
                                       //
   output         de2_uart_txd,        // UART transmitter
   input          de2_uart_rxd,        // UART receiver
   output         de2_uart_cts,        // UART clear to send
   input          de2_uart_rts,        // UART request to send
                                       //
   inout   [31:0] de2_dram_dq,         // SDRAM data bus 32 bits
   output  [12:0] de2_dram_addr,       // SDRAM address bus 13 bits
   output   [3:0] de2_dram_dqm,        // SDRAM byte data lane mask
   output         de2_dram_we_n,       // SDRAM write enable
   output         de2_dram_cas_n,      // SDRAM column address strobe
   output         de2_dram_ras_n,      // SDRAM row address strobe
   output         de2_dram_cs_n,       // SDRAM chip select
   output   [1:0] de2_dram_ba,         // SDRAM bank address
   output         de2_dram_clk,        // SDRAM clock
   output         de2_dram_cke,        // SDRAM clock enable
                                       //
   inout   [15:0] de2_sram_dq,         // SRAM Data bus 16 Bits
   output  [19:0] de2_sram_addr,       // SRAM Address bus 20 Bits
   output         de2_sram_ub_n,       // SRAM High-byte Data Mask
   output         de2_sram_lb_n,       // SRAM Low-byte Data Mask
   output         de2_sram_we_n,       // SRAM Write Enable
   output         de2_sram_ce_n,       // SRAM Chip Enable
   output         de2_sram_oe_n,       // SRAM Output Enable
                                       //
   inout    [7:0] de2_fl_dq,           // FLASH data bus 8 Bits
   output  [22:0] de2_fl_addr,         // FLASH address bus 23 Bits
   output         de2_fl_we_n,         // FLASH write enable
   output         de2_fl_rst_n,        // FLASH reset
   output         de2_fl_oe_n,         // FLASH output enable
   output         de2_fl_ce_n,         // FLASH chip enable
   output         de2_fl_wp_n,         // FLASH hardware write protect
   input          de2_fl_rb,           // FLASH ready/busy
                                       //
   output         de2_lcd_blig,        // LCD back light ON/OFF
   output         de2_lcd_on,          // LCD power ON
   output         de2_lcd_rw,          // LCD read/write select, 0 = write, 1 = read
   output         de2_lcd_en,          // LCD enable
   output         de2_lcd_rs,          // LCD command/data select, 0 = command, 1 = data
   inout    [7:0] de2_lcd_data,        // LCD data bus 8 bits
                                       //
   inout    [3:0] de2_sd_dat,          // SD Card Data
   inout          de2_sd_cmd,          // SD Card Command Signal
   output         de2_sd_clk,          // SD Card Clock
   input          de2_sd_wp_n,         // SD Card Write Protect
                                       //
   inout          de2_ps2_kbdat,       // PS2 Keyboard Data
   inout          de2_ps2_kbclk,       // PS2 Keyboard Clock
   inout          de2_ps2_msdat,       // PS2 Mouse Data
   inout          de2_ps2_msclk,       // PS2 Mouse Clock
                                       //
   output         de2_vga_hs,          // VGA H_SYNC
   output         de2_vga_vs,          // VGA V_SYNC
   output   [7:0] de2_vga_r,           // VGA Red[3:0]
   output   [7:0] de2_vga_g,           // VGA Green[3:0]
   output   [7:0] de2_vga_b,           // VGA Blue[3:0]
   output         de2_vga_blank_n,     // VGA blank
   output         de2_vga_clk,         // VGA clock
   output         de2_vga_sync_n,      // VGA synchro
                                       //
   output         de2_enet0_gtx_clk,   // Ethernet 0 RGMII
   input          de2_enet0_int_n,     //
   output         de2_enet0_mdc,       //
   inout          de2_enet0_mdio,      //
   output         de2_enet0_rst_n,     //
   input          de2_enet0_rx_clk,    //
   input          de2_enet0_rx_col,    //
   input          de2_enet0_rx_crs,    //
   input    [3:0] de2_enet0_rx_dat,    //
   input          de2_enet0_rx_dv,     //
   input          de2_enet0_rx_er,     //
   input          de2_enet0_tx_clk,    //
   output   [3:0] de2_enet0_tx_dat,    //
   output         de2_enet0_tx_en,     //
   output         de2_enet0_tx_er,     //
   input          de2_enet0_link100,   //
                                       //
   output         de2_enet1_gtx_clk,   // Ethernet 1 RGMII
   input          de2_enet1_int_n,     //
   output         de2_enet1_mdc,       //
   inout          de2_enet1_mdio,      //
   output         de2_enet1_rst_n,     //
   input          de2_enet1_rx_clk,    //
   input          de2_enet1_rx_col,    //
   input          de2_enet1_rx_crs,    //
   input    [3:0] de2_enet1_rx_dat,    //
   input          de2_enet1_rx_dv,     //
   input          de2_enet1_rx_er,     //
   input          de2_enet1_tx_clk,    //
   output   [3:0] de2_enet1_tx_dat,    //
   output         de2_enet1_tx_en,     //
   output         de2_enet1_tx_er,     //
   input          de2_enet1_link100,   //
                                       //
   inout   [15:0] de2_otg_dat,         // USB OTG controller
   output   [1:0] de2_otg_addr,        //
   output         de2_otg_cs_n,        //
   output         de2_otg_wr_n,        //
   output         de2_otg_rd_n,        //
   input    [1:0] de2_otg_int,         //
   output         de2_otg_rst_n,       //
   input    [1:0] de2_otg_dreq,        //
   output   [1:0] de2_otg_dack_n,      //
   inout          de2_otg_fspeed,      //
   inout          de2_otg_lspeed,      //
                                       //
   inout   [35:0] de2_gpio,            // GPIO Connection Data
   inout    [6:0] de2_exio,            // Extend IO pins
   input          de2_irda,            //
                                       //
   output         de2_aud_adclrck,     // Audio CODEC ADC LR Clock
   input          de2_aud_adcdat,      // Audio CODEC ADC Data
   output         de2_aud_daclrck,     // Audio CODEC DAC LR Clock
   output         de2_aud_dacdat,      // Audio CODEC DAC Data
   inout          de2_aud_bclk,        // Audio CODEC Bit-Stream Clock
   output         de2_aud_xck,         // Audio CODEC Chip Clock
                                       //
   inout          de2_i2c_dat,         // I2C Data, Audio and TV
   inout          de2_i2c_clk,         // I2C Clock, Audio and TV
   inout          de2_eeprom_dat,      // I2C Data, EEPROM
   inout          de2_eeprom_clk,      // I2C Clock, EEPROM
                                       //
   input          de2_td_clk27,        // TV Decoder
   input    [7:0] de2_td_dat,          //
   input          de2_td_hs,           //
   input          de2_td_vs,           //
   output         de2_td_rst_n,        //
                                       //
   input          de2_hsmc_clkin_p1,   // HSMC (LVDS)
   input          de2_hsmc_clkin_p2,   //
   input          de2_hsmc_clkin0,     //
   output         de2_hsmc_clkout_p1,  //
   output         de2_hsmc_clkout_p2,  //
   output         de2_hsmc_clkout0,    //
   inout    [3:0] de2_hsmc_d,          //
   input   [16:0] de2_hsmc_rxd_p,      //
   output  [16:0] de2_hsmc_txd_p       //
);

//______________________________________________________________________________
//
wire [31:0] baud = 921600/`SYS_BAUD-1;
wire clk, wr_n, rst_n, dbin;
wire  [7:0] dcpu;
wire  [7:0] dsys;
wire  [7:0] dsio;
wire  [7:0] dram;
wire [15:0] a;
wire uack;

reg f1, f2;
reg  [6:0] hex0, hex1, hex2, hex3;
reg  [6:0] hex4, hex5, hex6, hex7;
reg  [7:0] led;
reg  [7:0] rcnt = 8'h00;
reg  [2:0] div;
reg [15:0] div1ms;
reg ms, intrq, inta;
wire inte, sync;

assign clk = de2_clock_50;
assign rst_n = (rcnt == 8'hFF);
assign dsys = inta ? 8'hE7
            : (a[15:8] == 8'hFF) ? {4'h00, de2_button[3:0]}
    : (a[15:8] == 8'hFE) ? dsio
    : dram;

always @(posedge clk)
begin
   div <= div + 3'b001;
   f1  <= div[0];
   f2  <= ~div[0];

   if (sync) inta = dcpu[0];
   if (div1ms == ((`SYS_CLOCK/1000)-1))
      begin
         div1ms <= 16'h0000;
         ms <= 1;
      end
   else
      begin
         div1ms <= div1ms + 16'h0001;
         ms <= 0;
      end

   if (ms) intrq <= 1;
   if (inta) intrq <= 0;
end

always @(posedge clk)
begin
   if (~de2_button[3])
      rcnt <= 8'h00;
   else
      if (rcnt != 8'hFF) rcnt <= rcnt + 8'h01;
end

memini ram
(
   .address(a[13:0]),
   .clock(clk),
   .data(dcpu),
   .wren(~wr_n & rst_n & ~a[15] & ~a[14]),
   .q(dram)
);

always @(posedge clk)
begin
   if (~wr_n)
   begin
      if (a == 16'hFFFB) led  <= dcpu;
      if (a == 16'hFFFC) hex0 <= dcpu[6:0];
      if (a == 16'hFFFD) hex1 <= dcpu[6:0];
      if (a == 16'hFFFE) hex2 <= dcpu[6:0];
      if (a == 16'hFFFF) hex3 <= dcpu[6:0];
      if (a == 16'hFFF0) hex4 <= dcpu[6:0];
      if (a == 16'hFFF1) hex5 <= dcpu[6:0];
      if (a == 16'hFFF2) hex6 <= dcpu[6:0];
      if (a == 16'hFFF3) hex7 <= dcpu[6:0];
   end
end

//______________________________________________________________________________
//
`ifdef SYS_CLOCK
defparam uart.REFCLK = `SYS_CLOCK;
`endif

uart_wb uart
(
 .wb_clk_i(clk),
 .wb_rst_i(~rst_n),
 .wb_adr_i(a[0]),
 .wb_dat_i(dcpu),
   .wb_dat_o(dsio),
 .wb_cyc_i((~wr_n | dbin) & (a[15:8] == 8'hFE)),
 .wb_we_i(~wr_n & (a[15:8] == 8'hFE)),
 .wb_stb_i((~wr_n | (dbin & ~uack)) & (a[15:8] == 8'hFE)),
 .wb_ack_o(uack),

 .tx_dat_o(de2_uart_txd),
 .tx_cts_i(1'b0),
 .rx_dat_i(de2_uart_rxd),
 .rx_dtr_o(de2_uart_cts),

// .tx_ready(),
// .tx_empty(),
// .rx_ready(),

 .cfg_bdiv(baud[15:0]),
 .cfg_nbit(2'b11),
 .cfg_nstp(1'b1),
 .cfg_pena(1'b0),
 .cfg_podd(1'b0)
);

vm80a_core cpu
(
   .pin_clk(clk),
   .pin_f1(f1),
   .pin_f2(f2),
   .pin_reset(~rst_n),
   .pin_a(a),
   .pin_dout(dcpu),
   .pin_din(dsys),
   .pin_hold(1'b0),
   .pin_ready(1'b1),
   .pin_int(intrq),
   .pin_wr_n(wr_n),
   .pin_dbin(dbin),
   .pin_inte(inte),
   .pin_sync(sync)
);

assign de2_hex0 = ~hex0;
assign de2_hex1 = ~hex1;
assign de2_hex2 = ~hex2;
assign de2_hex3 = ~hex3;
assign de2_hex4 = ~hex4;
assign de2_hex5 = ~hex5;
assign de2_hex6 = ~hex6;
assign de2_hex7 = ~hex7;

assign de2_ledg[7:0] = led;
assign de2_ledg[8] = sync;

//______________________________________________________________________________
//
// Temporary and debug assignments
//
// assign   de2_uart_txd   = 1'bz;
// assign   de2_uart_cts   = 1'bz;

assign   de2_dram_dq    = 32'hzzzzzzzz;
assign   de2_dram_addr  = 13'h0000;
assign   de2_dram_dqm   = 4'b0;
assign   de2_dram_we_n  = 1'b1;
assign   de2_dram_cas_n = 1'b1;
assign   de2_dram_ras_n = 1'b1;
assign   de2_dram_cs_n  = 1'b1;
assign   de2_dram_ba[0] = 1'b0;
assign   de2_dram_ba[1] = 1'b0;
assign   de2_dram_clk   = 1'b0;
assign   de2_dram_cke   = 1'b0;

assign   de2_sram_dq    = 16'hzzzz;
assign   de2_sram_addr  = 20'h00000;
assign   de2_sram_ub_n  = 1'b1;
assign   de2_sram_lb_n  = 1'b1;
assign   de2_sram_we_n  = 1'b1;
assign   de2_sram_ce_n  = 1'b1;
assign   de2_sram_oe_n  = 1'b1;

assign   de2_fl_dq      = 8'hzz;
assign   de2_fl_addr    = 23'h000000;
assign   de2_fl_we_n    = 1'b1;
assign   de2_fl_rst_n   = 1'b0;
assign   de2_fl_oe_n    = 1'b1;
assign   de2_fl_ce_n    = 1'b1;
assign   de2_fl_wp_n    = 1'b0;

assign   de2_lcd_data   = 8'hzz;
assign   de2_lcd_blig   = 1'b0;
assign   de2_lcd_on     = 1'b0;
assign   de2_lcd_rw     = 1'b0;
assign   de2_lcd_en     = 1'b0;
assign   de2_lcd_rs     = 1'b0;

assign   de2_sd_dat     = 4'hz;
assign   de2_sd_cmd     = 1'hz;
assign   de2_sd_clk     = 1'h0;

assign   de2_ps2_kbdat  = 1'hz;
assign   de2_ps2_kbclk  = 1'hz;
assign   de2_ps2_msdat  = 1'hz;
assign   de2_ps2_msclk  = 1'hz;

assign   de2_vga_blank_n = 1'b0;
assign   de2_vga_hs     = 1'b00;
assign   de2_vga_vs     = 1'b00;
assign   de2_vga_r      = 8'h00;
assign   de2_vga_g      = 8'h00;
assign   de2_vga_b      = 8'h00;
assign   de2_vga_clk    = 1'b00;
assign   de2_vga_sync_n = 1'b00;
assign   de2_td_rst_n   = 1'b0;

assign   de2_gpio       = 36'hzzzzzzzzz;
assign   de2_exio       = 7'hzz;
assign   de2_ledr       = 18'hzzzzz;

assign   de2_enet0_gtx_clk = 1'b0;
assign   de2_enet0_mdc     = 1'b0;
assign   de2_enet0_mdio    = 1'bz;
assign   de2_enet0_rst_n   = 1'b0;
assign   de2_enet0_tx_dat  = 4'h0;
assign   de2_enet0_tx_en   = 1'b0;
assign   de2_enet0_tx_er   = 1'b0;

assign   de2_enet1_gtx_clk = 1'b0;
assign   de2_enet1_mdc     = 1'b0;
assign   de2_enet1_mdio    = 1'bz;
assign   de2_enet1_rst_n   = 1'b0;
assign   de2_enet1_tx_dat  = 4'h0;
assign   de2_enet1_tx_en   = 1'b0;
assign   de2_enet1_tx_er   = 1'b0;

assign   de2_i2c_dat       = 1'bz;
assign   de2_i2c_clk       = 1'bz;
assign   de2_eeprom_dat    = 1'bz;
assign   de2_eeprom_clk    = 1'bz;

assign   de2_otg_dat       = 16'hzzzz;
assign   de2_otg_addr      = 2'b00;
assign   de2_otg_cs_n      = 1'b1;
assign   de2_otg_wr_n      = 1'b1;
assign   de2_otg_rd_n      = 1'b1;
assign   de2_otg_rst_n     = 1'b1;
assign   de2_otg_dack_n    = 2'b11;
assign   de2_otg_fspeed    = 1'bz;
assign   de2_otg_lspeed    = 1'bz;

assign   de2_aud_adclrck   = 1'bz;
assign   de2_aud_daclrck   = 1'bz;
assign   de2_aud_dacdat    = 1'bz;
assign   de2_aud_bclk      = 1'b0;
assign   de2_aud_xck       = 1'b0;

assign   de2_hsmc_clkout_p1   = 1'b0;
assign   de2_hsmc_clkout_p2   = 1'b0;
assign   de2_hsmc_clkout0     = 1'b0;
assign   de2_hsmc_d           = 4'hz;
assign   de2_hsmc_txd_p       = 16'h0000;
assign   de2_sma_clkout       = 1'b0;

//______________________________________________________________________________
//
endmodule
