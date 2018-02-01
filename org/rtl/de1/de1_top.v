//______________________________________________________________________________
//
// Top module for DE1 board based system

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

		////////////////////////	UART	////////////////////////
		UART_TXD,						//	UART Transmitter
		UART_RXD,						//	UART Receiver
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,						//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 12 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 0
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		////////////////////	Flash Interface		////////////////
		FL_DQ,							//	FLASH Data bus 8 Bits
		FL_ADDR,						//	FLASH Address bus 22 Bits
		FL_WE_N,						//	FLASH Write Enable
		FL_RST_N,						//	FLASH Reset
		FL_OE_N,						//	FLASH Output Enable
		FL_CE_N,						//	FLASH Chip Enable
		////////////////////	SRAM Interface		////////////////
		SRAM_DQ,						//	SRAM Data bus 16 Bits
		SRAM_ADDR,						//	SRAM Address bus 18 Bits
		SRAM_UB_N,						//	SRAM High-byte Data Mask 
		SRAM_LB_N,						//	SRAM Low-byte Data Mask 
		SRAM_WE_N,						//	SRAM Write Enable
		SRAM_CE_N,						//	SRAM Chip Enable
		SRAM_OE_N,						//	SRAM Output Enable
		////////////////////	SD_Card Interface	////////////////
		SD_DAT,							//	SD Card Data
		SD_DAT3,						//	SD Card Data 3
		SD_CMD,							//	SD Card Command Signal
		SD_CLK,							//	SD Card Clock
		////////////////////	USB JTAG link	////////////////////
		TDI,  							// CPLD -> FPGA (data in)
		TCK,  							// CPLD -> FPGA (clk)
		TCS,  							// CPLD -> FPGA (CS)
	    TDO,  							// FPGA -> CPLD (data out)
		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		////////////////////	PS2		////////////////////////////
		PS2_DAT,						//	PS2 Data
		PS2_CLK,						//	PS2 Clock
		////////////////////	VGA		////////////////////////////
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_R,   						//	VGA Red[3:0]
		VGA_G,	 						//	VGA Green[3:0]
		VGA_B,  						//	VGA Blue[3:0]
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK,						//	Audio CODEC Chip Clock
		////////////////////	GPIO	////////////////////////////
		GPIO_0,							//	GPIO Connection 0
		GPIO_1							//	GPIO Connection 1
	);

////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0;					//	Seven Segment Digit 0
output	[6:0]	HEX1;					//	Seven Segment Digit 1
output	[6:0]	HEX2;					//	Seven Segment Digit 2
output	[6:0]	HEX3;					//	Seven Segment Digit 3
////////////////////////////	LED		////////////////////////////
output	[7:0]	LEDG;					//	LED Green[7:0]
output	[9:0]	LEDR;					//	LED Red[9:0]
////////////////////////////	UART	////////////////////////////
output			UART_TXD;				//	UART Transmitter
input			UART_RXD;				//	UART Receiver
///////////////////////		SDRAM Interface	////////////////////////
inout	[15:0]	DRAM_DQ;				//	SDRAM Data bus 16 Bits
output	[11:0]	DRAM_ADDR;				//	SDRAM Address bus 12 Bits
output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
output			DRAM_WE_N;				//	SDRAM Write Enable
output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
output			DRAM_CS_N;				//	SDRAM Chip Select
output			DRAM_BA_0;				//	SDRAM Bank Address 0
output			DRAM_BA_1;				//	SDRAM Bank Address 0
output			DRAM_CLK;				//	SDRAM Clock
output			DRAM_CKE;				//	SDRAM Clock Enable
////////////////////////	Flash Interface	////////////////////////
inout	[7:0]	FL_DQ;					//	FLASH Data bus 8 Bits
output	[21:0]	FL_ADDR;				//	FLASH Address bus 22 Bits
output			FL_WE_N;				//	FLASH Write Enable
output			FL_RST_N;				//	FLASH Reset
output			FL_OE_N;				//	FLASH Output Enable
output			FL_CE_N;				//	FLASH Chip Enable
////////////////////////	SRAM Interface	////////////////////////
inout	[15:0]	SRAM_DQ;				//	SRAM Data bus 16 Bits
output	[17:0]	SRAM_ADDR;				//	SRAM Address bus 18 Bits
output			SRAM_UB_N;				//	SRAM High-byte Data Mask 
output			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
output			SRAM_WE_N;				//	SRAM Write Enable
output			SRAM_CE_N;				//	SRAM Chip Enable
output			SRAM_OE_N;				//	SRAM Output Enable
////////////////////	SD Card Interface	////////////////////////
inout			SD_DAT;					//	SD Card Data
inout			SD_DAT3;				//	SD Card Data 3
inout			SD_CMD;					//	SD Card Command Signal
output			SD_CLK;					//	SD Card Clock
////////////////////////	I2C		////////////////////////////////
inout			I2C_SDAT;				//	I2C Data
output			I2C_SCLK;				//	I2C Clock
////////////////////////	PS2		////////////////////////////////
input		 	PS2_DAT;				//	PS2 Data
input			PS2_CLK;				//	PS2 Clock
////////////////////	USB JTAG link	////////////////////////////
input  			TDI;					// CPLD -> FPGA (data in)
input  			TCK;					// CPLD -> FPGA (clk)
input  			TCS;					// CPLD -> FPGA (CS)
output 			TDO;					// FPGA -> CPLD (data out)
////////////////////////	VGA			////////////////////////////
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output	[3:0]	VGA_R;   				//	VGA Red[3:0]
output	[3:0]	VGA_G;	 				//	VGA Green[3:0]
output	[3:0]	VGA_B;   				//	VGA Blue[3:0]
////////////////////	Audio CODEC		////////////////////////////
output			AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
input			AUD_ADCDAT;				//	Audio CODEC ADC Data
output			AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
output			AUD_DACDAT;				//	Audio CODEC DAC Data
inout			AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
output			AUD_XCK;				//	Audio CODEC Chip Clock
////////////////////////	GPIO	////////////////////////////////
inout	[35:0]	GPIO_0;					//	GPIO Connection 0
inout	[35:0]	GPIO_1;					//	GPIO Connection 1
////////////////////////////////////////////////////////////////////

//	All inout port turn to tri-state
assign	DRAM_DQ		=	16'hzzzz;
assign	FL_DQ		=	8'hzz;
assign	SRAM_DQ		=	16'hzzzz;
assign	SD_DAT		=	1'bz;
assign	I2C_SDAT	=	1'bz;
assign	GPIO_0		=	36'hzzzzzzzzz;
assign	GPIO_1		=	36'hzzzzzzzzz;
//	Audio
assign	AUD_ADCLRCK	=	AUD_DACLRCK;
assign	AUD_XCK		=	AUD_CTRL_CLK;

wire	[15:0]	mSEG7_DIG;
wire			VGA_CTRL_CLK;
wire			AUD_CTRL_CLK;
wire	[9:0]	mVGA_X;
wire	[9:0]	mVGA_Y;
wire	[9:0]	mVGA_R;
wire	[9:0]	mVGA_G;
wire	[9:0]	mVGA_B;
wire	[9:0]	mPAR_R;
wire	[9:0]	mPAR_G;
wire	[9:0]	mPAR_B;
wire	[9:0]	mOSD_R;
wire	[9:0]	mOSD_G;
wire	[9:0]	mOSD_B;
wire	[9:0]	oVGA_R;
wire	[9:0]	oVGA_G;
wire	[9:0]	oVGA_B;
wire	[19:0]	mVGA_ADDR;
reg		[27:0]	Cont;
reg		[9:0]	mLEDR;
reg				ST;

always@(posedge CLOCK_50)		Cont	<=	Cont+1'b1;

assign	mSEG7_DIG	=	{	Cont[27:24],Cont[27:24],Cont[27:24],Cont[27:24]	};

//	VGA Data 10-bit to 4-bit
assign	VGA_R		=	oVGA_R[9:6];
assign	VGA_G		=	oVGA_G[9:6];
assign	VGA_B		=	oVGA_B[9:6];
//	VGA Source Select
assign	mVGA_R		=	SW[0]	?	mPAR_R	:	mOSD_R	;
assign	mVGA_G		=	SW[0]	?	mPAR_G	:	mOSD_G	;
assign	mVGA_B		=	SW[0]	?	mPAR_B	:	mOSD_B	;

SEG7_LUT_4 			u0	(	HEX0,HEX1,HEX2,HEX3,mSEG7_DIG );

LEDR_Driver			u1	(	LEDR,CLOCK_27[0],KEY[0]);

LEDG_Driver			u2	(	LEDG,CLOCK_24[0],KEY[0]);

VGA_Audio_PLL 		u3	(	.inclk0(CLOCK_27[0]),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK)	);

VGA_Controller		u4	(	//	Host Side
							.iCursor_RGB_EN(4'h7),	
							.oAddress(mVGA_ADDR),					
							.oCoord_X(mVGA_X),
							.oCoord_Y(mVGA_Y),
							.iRed(mVGA_R),
							.iGreen(mVGA_G),
							.iBlue(mVGA_B),
							//	VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(KEY[0])	);

VGA_Pattern			u5	(	//	Read Out Side
							.oRed(mPAR_R),
							.oGreen(mPAR_G),
							.oBlue(mPAR_B),
							.iVGA_X(mVGA_X),
							.iVGA_Y(mVGA_Y),
							.iVGA_CLK(VGA_CTRL_CLK),
							//	Control Signals
							.iRST_N(KEY[0])	);

VGA_OSD_RAM			u6	(	//	Read Out Side
							.oRed(mOSD_R),
							.oGreen(mOSD_G),
							.oBlue(mOSD_B),
							.iVGA_ADDR(mVGA_ADDR),
							.iVGA_X(mVGA_X),
							.iVGA_Y(mVGA_Y),
							.iVGA_CLK(VGA_CTRL_CLK),
							//	CLUT
							.iON_R(1023),
							.iON_G(1023),
							.iON_B(1023),
							.iOFF_R(0),
							.iOFF_G(0),
							.iOFF_B(512),
							//	Control Signals
							.iRST_N(KEY[0])	);

I2C_AV_Config 		u7	(	//	Host Side
							.iCLK(CLOCK_50),
							.iRST_N(KEY[0]),
							//	I2C Side
							.I2C_SCLK(I2C_SCLK),
							.I2C_SDAT(I2C_SDAT)	);

AUDIO_DAC 			u8	(	//	Audio Side
							.oAUD_BCK(AUD_BCLK),
							.oAUD_DATA(AUD_DACDAT),
							.oAUD_LRCK(AUD_DACLRCK),
							//	Control Signals
							.iSrc_Select(SW[9]),
				         .iCLK_18_4(AUD_CTRL_CLK),
							.iRST_N(KEY[0])	);

endmodule
