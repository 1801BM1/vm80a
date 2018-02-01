//______________________________________________________________________________
//
// Top module for AX309 board based system
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
// Top project module - instantiates the AX309 board itself
//
module ax309
(
   input          ax3_clock_50,        // clock input 50 MHz
                                       //
   input          ax3_reset_n,         // push reset button
   input    [3:0] ax3_button,          // push button [3:0]
   output   [3:0] ax3_led,             // led outputs [3:0]
   output   [7:0] ax3_hex,             // seven segment digit mask
   output   [5:0] ax3_hsel,            // seven segment digit select
// output         ax3_buzzer,          //
                                       //
   output         ax3_uart_txd,        // UART transmitter
   input          ax3_uart_rxd         // UART receiver
//                                       //
// inout   [15:0] ax3_dram_dq,         // SDRAM data bus 16 bits
// output  [12:0] ax3_dram_addr,       // SDRAM address bus 13 bits
// output         ax3_dram_ldqm,       // SDRAM low-byte data mask
// output         ax3_dram_udqm,       // SDRAM high-byte data mask
// output         ax3_dram_we_n,       // SDRAM write enable
// output         ax3_dram_cas_n,      // SDRAM column address strobe
// output         ax3_dram_ras_n,      // SDRAM row address strobe
// output         ax3_dram_cs_n,       // SDRAM chip select
// output   [1:0] ax3_dram_ba,         // SDRAM bank address
// output         ax3_dram_clk,        // SDRAM clock
// output         ax3_dram_cke,        // SDRAM clock enable
//                                     //
// output         ax3_spi_cs_n,        // SPI FLASH chip select
// output         ax3_spi_clk,         // SPI FLASH clock
// output         ax3_spi_mosi,        // SPI FLASH master output
// input          ax3_spi_miso,        // SPI FLASH master input
//                                     //
// inout          ax3_sd_cs_n,         // SD Card chip select
// inout          ax3_sd_clk,          // SD Card clock
// inout          ax3_sd_mosi,         // SD Card master output
// inout          ax3_sd_miso,         // SD Card master input
//                                     //
// inout          ax3_i2c_clk,         // I2C Clock
// inout          ax3_i2c_dat,         // I2C Data
// output         ax3_rtc_rst_n,       // RTC DS1302 reset
// output         ax3_rtc_sclk,        // RTC DS1302_serial clock
// inout          ax3_rtc_sdat,        // RTC DS1302 serial data_
//                                     //
// output         ax3_vga_hs,          // VGA H_SYNC
// output         ax3_vga_vs,          // VGA V_SYNC
// output   [4:0] ax3_vga_r,           // VGA Red[4:0]
// output   [5:0] ax3_vga_g,           // VGA Green[5:0]
// output   [4:0] ax3_vga_b,           // VGA Blue[4:0]
//                                     //
// inout   [33:0] ax3_gpio0,           // GPIO Connection 0
// inout   [33:0] ax3_gpio1            // GPIO Connection 1
);

//______________________________________________________________________________
//
// Top module for AX309 board based system
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
reg  [7:0] hex0, hex1, hex2, hex3, hex4, hex5;
reg  [2:0] hsel;
reg  [1:0] led;
reg  [7:0] rcnt = 8'h00;
reg  [2:0] div;
reg [15:0] div1ms;
reg ms, intrq, inta;
wire inte, sync;

assign clk = ax3_clock_50;
assign rst_n = (rcnt == 8'hFF);
assign dsys = inta ? 8'hE7
            : (a[15:8] == 8'hFF) ? {4'h0, ax3_button[3:0]}
            : (a[15:8] == 8'hFE) ? dsio
            : dram;

assign ax3_hex = (hsel == 3'b000) ? ~hex0
               : (hsel == 3'b001) ? ~hex1
               : (hsel == 3'b010) ? ~hex2
               : (hsel == 3'b011) ? ~hex3
               : (hsel == 3'b100) ? ~hex4
               : (hsel == 3'b101) ? ~hex5 : 8'hFF;

assign ax3_hsel[0] = ~(hsel == 3'b000);
assign ax3_hsel[1] = ~(hsel == 3'b001);
assign ax3_hsel[2] = ~(hsel == 3'b010);
assign ax3_hsel[3] = ~(hsel == 3'b011);
assign ax3_hsel[4] = ~(hsel == 3'b100);
assign ax3_hsel[5] = ~(hsel == 3'b101);

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

   if (~rst_n)
      hsel <= 3'b000;
   else
      if (ms)
         if (hsel == 3'b000)
            hsel <= 3'b101;
         else
            hsel <= hsel - 3'b001;
end

always @(posedge clk)
begin
   if (~ax3_reset_n)
      rcnt <= 8'h00;
   else
      if (rcnt != 8'hFF) rcnt <= rcnt + 8'h01;
end

/*
memini ram
(
   .address(a[13:0]),
   .clock(clk),
   .wren(~wr_n & rst_n & ~a[15] & ~a[14]),
   .data(dcpu),
   .q(dram)
);
*/
ax309_mem ram
(
   .addra(a[13:0]),
   .clka(clk),
   .wea(~wr_n & rst_n & ~a[15] & ~a[14]),
   .dina(dcpu),
   .douta(dram)
);

always @(posedge clk)
begin
   if (~wr_n)
   begin
      if (a == 16'hFFFB) led  <= dcpu[1:0];
      if (a == 16'hFFFC) hex0 <= dcpu[7:0];
      if (a == 16'hFFFD) hex1 <= dcpu[7:0];
      if (a == 16'hFFFE) hex2 <= dcpu[7:0];
      if (a == 16'hFFFF) hex3 <= dcpu[7:0];
      if (a == 16'hFFF0) hex4 <= dcpu[7:0];
      if (a == 16'hFFF1) hex5 <= dcpu[7:0];
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

   .tx_dat_o(ax3_uart_txd),
   .tx_cts_i(1'b0),
   .rx_dat_i(ax3_uart_rxd),

// .rx_dtr_o(),
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

assign ax3_led[1:0] = led;
assign ax3_led[2]   = ~wr_n;
assign ax3_led[3]   = sync;

//______________________________________________________________________________
//
// Temporary and debug assignments
//
// assign   ax3_dram_dq    = 16'hzzzz;
// assign   ax3_dram_addr  = 13'h0000;
// assign   ax3_dram_ldqm  = 1'b0;
// assign   ax3_dram_udqm  = 1'b0;
// assign   ax3_dram_we_n  = 1'b1;
// assign   ax3_dram_cas_n = 1'b1;
// assign   ax3_dram_ras_n = 1'b1;
// assign   ax3_dram_cs_n  = 1'b1;
// assign   ax3_dram_ba[0] = 1'b0;
// assign   ax3_dram_ba[1] = 1'b0;
// assign   ax3_dram_clk   = 1'b0;
// assign   ax3_dram_cke   = 1'b0;
//
// assign   ax3_spi_cs_n   = 1'b1;
// assign   ax3_spi_clk    = 1'b0;
// assign   ax3_spi_mosi   = 1'bz;
//
// assign   ax3_sd_cs_n    = 1'bz;
// assign   ax3_sd_clk     = 1'b0;
// assign   ax3_sd_mosi    = 1'bz;
// assign   ax3_sd_miso    = 1'bz;
//
// assign   ax3_i2c_dat    = 1'hz;
// assign   ax3_i2c_clk    = 1'hz;
// assign   ax3_rtc_rst_n  = 1'hz;
// assign   ax3_rtc_sclk   = 1'hz;
// assign   ax3_rtc_sdat   = 1'hz;
assign   ax3_buzzer     = 1'hz;
//
// assign   ax3_vga_hs     = 1'b0;
// assign   ax3_vga_vs     = 1'b0;
// assign   ax3_vga_r      = 5'h0;
// assign   ax3_vga_g      = 6'h0;
// assign   ax3_vga_b      = 5'h0;
//
// assign   ax3_gpio0      = 34'hzzzzzzzzz;
// assign   ax3_gpio1      = 34'hzzzzzzzzz;
//
endmodule
