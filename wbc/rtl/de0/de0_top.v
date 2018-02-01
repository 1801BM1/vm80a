//______________________________________________________________________________
//
// Top module for DE0 board based system

//______________________________________________________________________________
//
// External oscillator clock, feeds the PLLs
//
`define  OSC_CLOCK                  50000000
//
// Global system clock
//
//`define  SYS_CLOCK                 50000000
`define  SYS_CLOCK                  100000000
//
// Console baudrate
//
`define  SYS_BAUD                   115200
//
// Retro clock for non-turbo clock mode
//
`define  CPU_CLOCK                  2500000

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
// Provides the 1 microseconds and 1 milliseconds strobes
//
module de0_timer #(parameter REFCLK=100000000, CPUCLK=2500000)
(
   input       clk,
   input       rst,
   output reg  ena_f2,
   output reg  ena_us,
   output reg  ena_ms,
   output reg  irq_50
);
localparam F2_COUNTER_WIDTH = log2(REFCLK/CPUCLK);
localparam US_COUNTER_WIDTH = log2(REFCLK/1000000);
localparam MS_COUNTER_WIDTH = log2(1000);

reg   [F2_COUNTER_WIDTH-1:0] count_f2;
reg   [US_COUNTER_WIDTH-1:0] count_us;
reg   [MS_COUNTER_WIDTH-1:0] count_ms;
reg   [4:0] count_50;

always @(posedge clk, posedge rst)
begin
   if (rst)
      begin
         ena_f2   <= 1'b0;
         ena_us   <= 1'b0;
         ena_ms   <= 1'b0;
         count_f2 <= 0;
         count_us <= 0;
         count_ms <= 980;
         count_50 <= 0;
      end
   else
      begin
         //
         // F2 retro clock interval counter
         // (use this simpler inmplementation,
         // but the phase accumulator is better
         // if more precise CPU clock desired)
         //
         if (count_f2 == ((REFCLK/CPUCLK)-1))
            begin
               ena_f2 <= 1'b1;
               count_f2 <= 0;
            end
         else
            begin
               ena_f2 <= 1'b0;
               count_f2 <= count_f2 + 1'b1;
            end
         //
         // One microsecond interval counter
         //
         if (count_us == ((REFCLK/1000000)-1))
            begin
               ena_us <= 1'b1;
               count_us <= 0;
            end
         else
            begin
               ena_us <= 1'b0;
               count_us <= count_us + 1'b1;
            end
         //
         // One millisecond interval counter
         //
         if (ena_us)
            if (count_ms == (1000-1))
               begin
                  ena_ms <= 1'b1;
                  count_ms <= 0;
               end
            else
               begin
                  ena_ms <= 1'b0;
                  count_ms <= count_ms + 1'b1;
               end
         else
            ena_ms <= 1'b0;
         //
         // 50Hz timer output
         //
         if (ena_ms)
            if (count_50 == 19)
            begin
               irq_50 <= 1'b0;
               count_50 <= 0;
            end
            else
            begin
               if (count_50 == 9)
                  irq_50 <= 1'b1;

               count_50 <= count_50 + 1'b1;
            end
      end
end

function integer log2(input integer value);
   begin
      for (log2=0; value>0; log2=log2+1)
         value = value >> 1;
   end
endfunction
endmodule

//______________________________________________________________________________
//
// Initialized RAM block - 16K x 8
//
module mem_wb
(
   input          wb_clk_i,
   input  [13:0]  wb_adr_i,
   input  [7:0]   wb_dat_i,
   output [7:0]   wb_dat_o,
   input          wb_cyc_i,
   input          wb_we_i,
   input          wb_stb_i,
   output         wb_ack_o
);
reg ack;

memini ram
(
   .clock(wb_clk_i),
   .address(wb_adr_i[13:0]),
   .wren(wb_we_i & wb_cyc_i & wb_stb_i),
   .data(wb_dat_i),
   .q(wb_dat_o)
);

assign wb_ack_o = wb_cyc_i & wb_stb_i & (ack | wb_we_i);
always @ (posedge wb_clk_i) ack <= wb_cyc_i;
endmodule

//______________________________________________________________________________
//
// Top project module - instantiates the DE0 board itself
//
module de0
(
   input          de0_clock_50,        // clock input 50 MHz
   input          de0_clock_50_2,      // clock input 50 MHz
                                       //
   input    [2:0] de0_button,          // push button[2:0]
                                       //
   input    [9:0] de0_sw,              // DPDT toggle switch[9:0]
   output   [7:0] de0_hex0,            // seven segment digit 0
   output   [7:0] de0_hex1,            // seven segment digit 1
   output   [7:0] de0_hex2,            // seven segment digit 2
   output   [7:0] de0_hex3,            // seven segment digit 3
   output   [9:0] de0_led,             // LED green[9:0]
                                       //
   output         de0_uart_txd,        // UART transmitter
   input          de0_uart_rxd,        // UART receiver
   output         de0_uart_cts,        // UART clear to send
   input          de0_uart_rts,        // UART request to send
                                       //
   inout   [15:0] de0_dram_dq,         // SDRAM data bus 16 bits
   output  [12:0] de0_dram_addr,       // SDRAM address bus 13 bits
   output         de0_dram_ldqm,       // SDRAM low-byte data mask
   output         de0_dram_udqm,       // SDRAM high-byte data mask
   output         de0_dram_we_n,       // SDRAM write enable
   output         de0_dram_cas_n,      // SDRAM column address strobe
   output         de0_dram_ras_n,      // SDRAM row address strobe
   output         de0_dram_cs_n,       // SDRAM chip select
   output   [1:0] de0_dram_ba,         // SDRAM bank address
   output         de0_dram_clk,        // SDRAM clock
   output         de0_dram_cke,        // SDRAM clock enable
                                       //
   inout   [15:0] de0_fl_dq,           // FLASH data bus 15 Bits
   output  [21:0] de0_fl_addr,         // FLASH address bus 22 Bits
   output         de0_fl_we_n,         // FLASH write enable
   output         de0_fl_rst_n,        // FLASH reset
   output         de0_fl_oe_n,         // FLASH output enable
   output         de0_fl_ce_n,         // FLASH chip enable
   output         de0_fl_wp_n,         // FLASH hardware write protect
   output         de0_fl_byte_n,       // FLASH selects 8/16-bit mode
   input          de0_fl_rb,           // FLASH ready/busy
                                       //
   output         de0_lcd_blig,        // LCD back light ON/OFF
   output         de0_lcd_rw,          // LCD read/write select, 0 = write, 1 = read
   output         de0_lcd_en,          // LCD enable
   output         de0_lcd_rs,          // LCD command/data select, 0 = command, 1 = data
   inout    [7:0] de0_lcd_data,        // LCD data bus 8 bits
                                       //
   inout          de0_sd_mosi,         // SD Card Data Output
   inout          de0_sd_miso,         // SD Card Data Input
   inout          de0_sd_cmd,          // SD Card Command Signal
   output         de0_sd_clk,          // SD Card Clock
   input          de0_sd_wp_n,         // SD Card Write Protect
                                       //
   inout          de0_ps2_kbdat,       // PS2 Keyboard Data
   inout          de0_ps2_kbclk,       // PS2 Keyboard Clock
   inout          de0_ps2_msdat,       // PS2 Mouse Data
   inout          de0_ps2_msclk,       // PS2 Mouse Clock
                                       //
   output         de0_vga_hs,          // VGA H_SYNC
   output         de0_vga_vs,          // VGA V_SYNC
   output   [3:0] de0_vga_r,           // VGA Red[3:0]
   output   [3:0] de0_vga_g,           // VGA Green[3:0]
   output   [3:0] de0_vga_b,           // VGA Blue[3:0]
                                       //
   input    [1:0] de0_gpio0_clkin,     // GPIO Connection 0 Clock In Bus
   output   [1:0] de0_gpio0_clkout,    // GPIO Connection 0 Clock Out Bus
   inout   [31:0] de0_gpio0_d,         // GPIO Connection 0 Data Bus
                                       //
   input    [1:0] de0_gpio1_clkin,     // GPIO Connection 1 Clock In Bus
   output   [1:0] de0_gpio1_clkout,    // GPIO Connection 1 Clock Out Bus
   inout   [31:0] de0_gpio1_d          // GPIO Connection 1 Data Bus
);

//______________________________________________________________________________
//
wire [31:0] baud = 921600/`SYS_BAUD-1;
wire clk50, pll_clk, pll_lock, ena_us, ena_ms, ena_f2;
reg         vm_turbo;

wire        wb_rst;                    //
wire        wb_clk;                    //
wire [15:0] wb_adr;                    // master address out bus
wire  [7:0] wb_out;                    // master data out bus
wire  [7:0] wb_mux;                    // master data in bus
wire        wb_cyc;                    // master wishbone cycle
wire        wb_we;                     // master wishbone direction
wire        wb_stb;                    // master wishbone strobe
wire        wb_ack;                    // master wishbone acknowledgement
wire [5:0]  wb_tag;                    // 8080 tags
                                       //
wire [3:0]  mx_stb;                    //
wire [3:0]  mx_ack;                    // system wishbone data mux
wire [7:0]  mx_dat[3:0];               //
                                       //
reg  [7:0]  hex0, hex1, hex2, hex3;
reg  [7:0]  led;
reg  [7:0]  rcnt = 8'h00;
reg         vm_irq;
wire        vm_inte;
wire        vm_cena;

//______________________________________________________________________________
//
// Clock and Reset section
//
assign wb_clk = pll_clk;
assign clk50  = de0_clock_50_2;
assign wb_rst = ~(rcnt == 8'hFF);
assign vm_cena = 1'b1; // vm_turbo | ena_f2;

de0_pll100 corepll
(
   .inclk0(clk50),
   .c0(pll_clk),
   .locked(pll_lock)
);

always @(posedge wb_clk)
begin
   //
   // SW0 selects turbo/original clock mode for the core
   //
   vm_turbo <= de0_sw[0];

   if (~de0_button[2])
      begin
         vm_irq <= 0;
      end
   else
      begin
         if (ena_ms)    vm_irq <= 1;
         if (mx_ack[3]) vm_irq <= 0;
      end

   if (~de0_button[2] | ~pll_lock)
      rcnt <= 8'h00;
   else
      if (rcnt != 8'hFF)
         rcnt <= rcnt + 8'h01;
end

//______________________________________________________________________________
//
`ifdef SYS_CLOCK
defparam uart.REFCLK = `SYS_CLOCK;
`endif

uart_wb uart
(
   .wb_clk_i(wb_clk),
   .wb_rst_i(wb_rst),
   .wb_adr_i(wb_adr[0]),
   .wb_dat_i(wb_out),
   .wb_dat_o(mx_dat[1]),
   .wb_cyc_i(wb_cyc),
   .wb_we_i(wb_we),
   .wb_stb_i(mx_stb[1]),
   .wb_ack_o(mx_ack[1]),

   .tx_dat_o(de0_uart_txd),
   .tx_cts_i(1'b0),
   .rx_dat_i(de0_uart_rxd),
   .rx_dtr_o(de0_uart_cts),

// .tx_ready(),
// .tx_empty(),
// .rx_ready(),

   .cfg_bdiv(baud[15:0]),
   .cfg_nbit(2'b11),
   .cfg_nstp(1'b1),
   .cfg_pena(1'b0),
   .cfg_podd(1'b0)
);

//______________________________________________________________________________
//
// Wishbone i8080 CPU
//
vm80_wb cpu
(
   .wb_clk_i(wb_clk),
   .wb_rst_i(wb_rst),
   .wb_adr_o(wb_adr),
   .wb_dat_o(wb_out),
   .wb_dat_i(wb_mux),
   .wb_cyc_o(wb_cyc),
   .wb_we_o(wb_we),
   .wb_stb_o(wb_stb),
   .wb_ack_i(wb_ack),
   .wb_tgc_o(wb_tag),

   .vm_cena(vm_cena),
   .vm_irq(vm_irq),
   .vm_inte(vm_inte)
);

mem_wb mem(
   .wb_clk_i(wb_clk),
   .wb_adr_i(wb_adr),
   .wb_dat_i(wb_out),
   .wb_dat_o(mx_dat[0]),
   .wb_cyc_i(wb_cyc),
   .wb_we_i(wb_we),
   .wb_stb_i(mx_stb[0]),
   .wb_ack_o(mx_ack[0])
);

//______________________________________________________________________________
//
always @(posedge wb_clk)
begin
   if (mx_stb[2])
   begin
      if (wb_adr == 16'hFFFB) led  <= wb_out;
      if (wb_adr == 16'hFFFC) hex0 <= wb_out;
      if (wb_adr == 16'hFFFD) hex1 <= wb_out;
      if (wb_adr == 16'hFFFE) hex2 <= wb_out;
      if (wb_adr == 16'hFFFF) hex3 <= wb_out;
   end
end

assign de0_hex0 = ~hex0;
assign de0_hex1 = ~hex1;
assign de0_hex2 = ~hex2;
assign de0_hex3 = ~hex3;

assign de0_led[7:0] = led;
assign de0_led[9] = vm_turbo;
assign de0_led[8] = wb_stb &  wb_we;

assign mx_ack[2]  = mx_stb[2];
assign mx_ack[3]  = mx_stb[3];
assign mx_dat[2]  = {5'h00, de0_button[2:0]};
assign mx_dat[3]  = 8'hE7; // interrupt rst 4

//______________________________________________________________________________
//
assign mx_stb[0]  = wb_stb & wb_cyc & (wb_adr[15:14] == 2'b00) & ~wb_tag[4];
assign mx_stb[1]  = wb_stb & wb_cyc & (wb_adr[15:8]  == 8'hFE) & ~wb_tag[4];
assign mx_stb[2]  = wb_stb & wb_cyc & (wb_adr[15:8]  == 8'hFF) & ~wb_tag[4];
assign mx_stb[3]  = wb_stb & wb_cyc & wb_tag[4];   // interrupt acknowledge

assign wb_ack     = mx_ack[0] | mx_ack[1] | mx_ack[2] | mx_ack[3];
assign wb_mux     = (mx_stb[0] ? mx_dat[0] : 8'h00)
                  | (mx_stb[1] ? mx_dat[1] : 8'h00)
                  | (mx_stb[2] ? mx_dat[2] : 8'h00)
                  | (mx_stb[3] ? mx_dat[3] : 8'h00);

//______________________________________________________________________________
//
`ifdef SYS_CLOCK
defparam timer.REFCLK = `SYS_CLOCK;
`endif

`ifdef CPU_CLOCK
defparam timer.CPUCLK = `CPU_CLOCK;
`endif

de0_timer timer
(
   .clk(wb_clk),
   .rst(wb_rst),
   .ena_f2(ena_f2),
   .ena_us(ena_us),
   .ena_ms(ena_ms)
);

//______________________________________________________________________________
//
// Temporary and debug assignments
//
// assign   de0_uart_txd   = 1'bz;
// assign   de0_uart_cts   = 1'bz;

assign   de0_dram_dq    = 16'hzzzz;
assign   de0_dram_addr  = 13'h0000;
assign   de0_dram_ldqm  = 1'b0;
assign   de0_dram_udqm  = 1'b0;
assign   de0_dram_we_n  = 1'b1;
assign   de0_dram_cas_n = 1'b1;
assign   de0_dram_ras_n = 1'b1;
assign   de0_dram_cs_n  = 1'b1;

assign   de0_dram_ba[0] = 1'b0;
assign   de0_dram_ba[1] = 1'b0;
assign   de0_dram_clk   = 1'b0;
assign   de0_dram_cke   = 1'b0;

assign   de0_fl_dq      = 16'hzzzz;
assign   de0_fl_addr    = 22'hzzzzzz;
assign   de0_fl_we_n    = 1'b1;
assign   de0_fl_rst_n   = 1'b0;
assign   de0_fl_oe_n    = 1'b1;
assign   de0_fl_ce_n    = 1'b1;
assign   de0_fl_wp_n    = 1'b0;
assign   de0_fl_byte_n  = 1'b1;

assign   de0_lcd_data   = 8'hzz;
assign   de0_lcd_blig   = 1'b0;
assign   de0_lcd_rw     = 1'b0;
assign   de0_lcd_en     = 1'b0;
assign   de0_lcd_rs     = 1'b0;

assign   de0_sd_clk     = 1'h0;
assign   de0_sd_mosi    = 1'hz;
assign   de0_sd_miso    = 1'hz;
assign   de0_sd_cmd     = 1'hz;

assign   de0_ps2_kbdat  = 1'hz;
assign   de0_ps2_kbclk  = 1'hz;
assign   de0_ps2_msdat  = 1'hz;
assign   de0_ps2_msclk  = 1'hz;

assign   de0_vga_hs     = 1'b0;
assign   de0_vga_vs     = 1'b0;
assign   de0_vga_r      = 4'h0;
assign   de0_vga_g      = 4'h0;
assign   de0_vga_b      = 4'h0;

assign   de0_gpio0_clkout  = 2'b00;
assign   de0_gpio1_clkout  = 2'b00;
assign   de0_gpio0_d       = 32'hzzzzzzzz;
assign   de0_gpio1_d       = 32'hzzzzzzzz;

//______________________________________________________________________________
//
endmodule
