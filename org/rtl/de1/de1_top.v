//______________________________________________________________________________
//
// Top module for DE1 board based system
//
//______________________________________________________________________________
//
// External oscillator clock, feeds the PLLs
//
`define  OSC_CLOCK                  50000000
//
// Global system clock
//
`define  SYS_CLOCK                  50000000

//______________________________________________________________________________
//
// Reset button debounce interval (in ms))
//
`define  RESET_BUTTON_DEBOUNCE_MS   5
//
// Internal reset pulse width (in system clocks)
//
`define  RESET_PULSE_WIDTH_CLK      7
//
// Console baudrate
//
`define  SYS_BAUD                   115200

//______________________________________________________________________________
//
// Top project module - instantiates the DE1 board itself
//
module de1
(
   input    [1:0] de1_clock_24,        // clock input 24 MHz
   input    [1:0] de1_clock_27,        // clock input 27 MHz
   input          de1_clock_50,        // clock input 50 MHz
   input          de1_clock_ext,       // external clock input
                                       //
   input    [3:0] de1_button,          // push button[3:0]
                                       //
   input    [9:0] de1_sw,              // DPDT toggle switch[9:0]
   output   [6:0] de1_hex0,            // seven segment digit 0
   output   [6:0] de1_hex1,            // seven segment digit 1
   output   [6:0] de1_hex2,            // seven segment digit 2
   output   [6:0] de1_hex3,            // seven segment digit 3
   output   [7:0] de1_ledg,            // LED green[7:0]
   output   [9:0] de1_ledr,            // LED red[9:0]
                                       //
   output         de1_uart_txd,        // UART transmitter
   input          de1_uart_rxd,        // UART receiver
                                       //
   inout   [15:0] de1_dram_dq,         // SDRAM data bus 16 bits
   output  [11:0] de1_dram_addr,       // SDRAM address bus 12 bits
   output         de1_dram_ldqm,       // SDRAM low-byte data mask
   output         de1_dram_udqm,       // SDRAM high-byte data mask
   output         de1_dram_we_n,       // SDRAM write enable
   output         de1_dram_cas_n,      // SDRAM column address strobe
   output         de1_dram_ras_n,      // SDRAM row address strobe
   output         de1_dram_cs_n,       // SDRAM chip select
   output   [1:0] de1_dram_ba,         // SDRAM bank address
   output         de1_dram_clk,        // SDRAM clock
   output         de1_dram_cke,        // SDRAM clock enable
                                       //
   inout    [7:0] de1_fl_dq,           // FLASH data bus 8 Bits
   output  [21:0] de1_fl_addr,         // FLASH address bus 22 Bits
   output         de1_fl_we_n,         // FLASH write enable
   output         de1_fl_rst_n,        // FLASH reset
   output         de1_fl_oe_n,         // FLASH output enable
   output         de1_fl_ce_n,         // FLASH chip enable
                                       //
   inout   [15:0] de1_sram_dq,         // SRAM Data bus 16 Bits
   output  [17:0] de1_sram_addr,       // SRAM Address bus 18 Bits
   output         de1_sram_ub_n,       // SRAM High-byte Data Mask
   output         de1_sram_lb_n,       // SRAM Low-byte Data Mask
   output         de1_sram_we_n,       // SRAM Write Enable
   output         de1_sram_ce_n,       // SRAM Chip Enable
   output         de1_sram_oe_n,       // SRAM Output Enable
                                       //
   inout          de1_sd_mosi,         // SD Card Data Output
   inout          de1_sd_miso,         // SD Card Data Input
   inout          de1_sd_cmd,          // SD Card Command Signal
   output         de1_sd_clk,          // SD Card Clock
                                       //
   input          de1_tdi,             // CPLD -> FPGA (data in)
   input          de1_tck,             // CPLD -> FPGA (clk)
   input          de1_tms,             // CPLD -> FPGA (mode select)
   output         de1_tdo,             // FPGA -> CPLD (data out)
                                       //
   inout          de1_i2c_dat,         // I2C Data
   output         de1_i2c_clk,         // I2C Clock
   inout          de1_ps2_dat,         // PS2 Data
   inout          de1_ps2_clk,         // PS2 Clock
                                       //
   output         de1_vga_hs,          // VGA H_SYNC
   output         de1_vga_vs,          // VGA V_SYNC
   output   [3:0] de1_vga_r,           // VGA Red[3:0]
   output   [3:0] de1_vga_g,           // VGA Green[3:0]
   output   [3:0] de1_vga_b,           // VGA Blue[3:0]
                                       //
   output         de1_aud_adclrck,     // Audio CODEC ADC LR Clock
   input          de1_aud_adcdat,      // Audio CODEC ADC Data
   output         de1_aud_daclrck,     // Audio CODEC DAC LR Clock
   output         de1_aud_dacdat,      // Audio CODEC DAC Data
   inout          de1_aud_bclk,        // Audio CODEC Bit-Stream Clock
   output         de1_aud_xck,         // Audio CODEC Chip Clock
                                       //
   inout [35:0]   de1_gpio0,           // GPIO Connection 0
   inout [35:0]   de1_gpio1            // GPIO Connection 1
);

//______________________________________________________________________________
//
// Top module for DE1 board based system
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
reg  [7:0] led;
reg  [7:0] rcnt = 8'h00;
reg  [2:0] div;
reg [15:0] div1ms;
reg ms, intrq, inta;
wire inte, sync;

assign clk = de1_clock_50;
assign rst_n = (rcnt == 8'hFF);
assign dsys = inta ? 8'hE7
            : (a[15:8] == 8'hFF) ? {4'h0, de1_button[3:0]}
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
   if (~de1_button[3])
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

   .tx_dat_o(de1_uart_txd),
   .tx_cts_i(1'b0),
   .rx_dat_i(de1_uart_rxd),
// .rx_dtr_o(de1_uart_cts),

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

assign de1_hex0 = ~hex0;
assign de1_hex1 = ~hex1;
assign de1_hex2 = ~hex2;
assign de1_hex3 = ~hex3;

assign de1_ledr[7:0] = led;
assign de1_ledr[9] = ~wr_n;
assign de1_ledr[8] = sync;

//______________________________________________________________________________
//
// Temporary and debug assignments
//
assign   de1_dram_dq    = 16'hzzzz;
assign   de1_dram_addr  = 12'h000;
assign   de1_dram_ldqm  = 1'b0;
assign   de1_dram_udqm  = 1'b0;
assign   de1_dram_we_n  = 1'b1;
assign   de1_dram_cas_n = 1'b1;
assign   de1_dram_ras_n = 1'b1;
assign   de1_dram_cs_n  = 1'b1;
assign   de1_dram_ba[0] = 1'b0;
assign   de1_dram_ba[1] = 1'b0;
assign   de1_dram_clk   = 1'b0;
assign   de1_dram_cke   = 1'b0;

assign   de1_fl_dq      = 7'hzz;
assign   de1_fl_addr    = 22'hzzzzzz;
assign   de1_fl_we_n    = 1'b1;
assign   de1_fl_rst_n   = 1'b0;
assign   de1_fl_oe_n    = 1'b1;
assign   de1_fl_ce_n    = 1'b1;

assign   de1_sram_dq    = 16'hzzzz;
assign   de1_sram_addr  = 18'h00000;
assign   de1_sram_we_n  = 1'b1;
assign   de1_sram_ce_n  = 1'b1;
assign   de1_sram_oe_n  = 1'b1;
assign   de1_sram_lb_n  = 1'b1;
assign   de1_sram_ub_n  = 1'b1;

assign   de1_sd_clk     = 1'b0;
assign   de1_sd_mosi    = 1'hz;
assign   de1_sd_miso    = 1'hz;
assign   de1_sd_cmd     = 1'hz;

assign   de1_ps2_dat    = 1'hz;
assign   de1_ps2_clk    = 1'hz;
assign   de1_i2c_dat    = 1'hz;
assign   de1_i2c_clk    = 1'hz;

assign   de1_vga_hs     = 1'b0;
assign   de1_vga_vs     = 1'b0;
assign   de1_vga_r      = 4'h0;
assign   de1_vga_g      = 4'h0;
assign   de1_vga_b      = 4'h0;

assign   de1_gpio0      = 35'hzzzzzzzzz;
assign   de1_gpio1      = 35'hzzzzzzzzz;
assign   de1_ledg       = 8'hzz;

assign   de1_aud_adclrck = 1'b0;
assign   de1_aud_daclrck = 1'b0;
assign   de1_aud_dacdat  = 1'b0;
assign   de1_aud_xck     = 1'b0;

//______________________________________________________________________________
//
endmodule
