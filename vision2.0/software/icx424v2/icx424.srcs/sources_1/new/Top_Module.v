`timescale 1ns / 1ps

module Top_Module #(
    parameter CL_FREQ_MHz        = 10,
    parameter CL_LINE_N          = 1,
    parameter CL_PIXEL_N         = 1060,
    parameter DDR_ADDR_WIDTH     = 28,
    parameter DDR_DATA_WIDTH     = 16,
    parameter DDR_APP_DATA_WIDTH = 128
) (
    //系统时钟和复位
    input  SYS_CLK_50M,
    input  FPGA_CPLD1_IO2,  //RESET
    //串口通信接口
    input  UART_RX,
    output UART_TX,
    //CPLD1
    output FPGA_CPLD1_IO0,  //TXD
    input  FPGA_CPLD1_IO1,  //RXD

    //ADC CLK
    output ADC1_CLK,
    output ADC2_CLK,
    output ADC3_CLK,
    output ADC4_CLK,

    output        ADC_PD,
    //ADC 
    input         ADC1_OUTCLK,
    input  [15:0] ADC1_DATA,
    input         ADC2_OUTCLK,
    input  [15:0] ADC2_DATA,
    input         ADC3_OUTCLK,
    input  [15:0] ADC3_DATA,
    input         ADC4_OUTCLK,
    input  [15:0] ADC4_DATA,

    //clk_10mhz
    output FPGA_CLK1,
    output FPGA_CLK2,
    output FPGA_CLK3,
    output FPGA_CLK4,
    output FPGA_CLK5,
    output FPGA_CLK6,
    output FPGA_CLK7,
    output FPGA_CLK8,
    output FPGA_CLK9,
    output FPGA_CLK10,
    output FPGA_CLK11,
    output FPGA_CLK12,
    output FPGA_CLK13,
    output FPGA_CLK14,
    output FPGA_CLK15,
    output FPGA_CLK16,
    output FPGA_CLK17,
    output FPGA_CLK18,
    output FPGA_CLK19,
    output FPGA_CLK20,
    output FPGA_CLK21,
    output FPGA_CLK22,
    output FPGA_CLK23,
    output FPGA_CLK24,

    output FPGA_HF_CLK1,
    output FPGA_HF_CLK2,
    output FPGA_HF_CLK3,
    output FPGA_HF_CLK4,
    output FPGA_HF_CLK5,
    output FPGA_HF_CLK6,
    output FPGA_HF_CLK7,
    output FPGA_HF_CLK8,
    output FPGA_HF_CLK9,
    output FPGA_HF_CLK10,
    output FPGA_HF_CLK11,
    output FPGA_HF_CLK12,
    //LV4 CLOCKS

    output FPGA_LV4_CLKA1,
    output FPGA_LV4_CLKB1,
    output FPGA_LV4_CLKC1,

    output FPGA_LV4_CLKA2,
    output FPGA_LV4_CLKB2,
    output FPGA_LV4_CLKC2,

    output FPGA_LV4_CLKA3,
    output FPGA_LV4_CLKB3,
    output FPGA_LV4_CLKC3,

    output FPGA_LV4_CLKA4,
    output FPGA_LV4_CLKB4,
    output FPGA_LV4_CLKC4,

    output FPGA_LV4_CLKA5,
    output FPGA_LV4_CLKB5,
    output FPGA_LV4_CLKC5,

    output FPGA_LV4_CLKA6, 
    output FPGA_LV4_CLKB6,
    output FPGA_LV4_CLKC6,

    output FPGA_LV4_CLKA7,
    output FPGA_LV4_CLKB7,
    output FPGA_LV4_CLKC7,

    output FPGA_LV4_CLKA8,
    output FPGA_LV4_CLKB8,
    output FPGA_LV4_CLKC8,


    //LV3 CLOCKS
    output FPGA_LV3_CLKA1,
    output FPGA_LV3_CLKB1,

    output FPGA_LV3_CLKA2,
    output FPGA_LV3_CLKB2,

    output FPGA_LV3_CLKA3,
    output FPGA_LV3_CLKB3,

    output FPGA_LV3_CLKA4,
    output FPGA_LV3_CLKB4,

    output FPGA_LV3_CLKA5,
    output FPGA_LV3_CLKB5,

    output FPGA_LV3_CLKA6,
    output FPGA_LV3_CLKB6,

    output FPGA_LV3_CLKA7,
    output FPGA_LV3_CLKB7,

    output FPGA_LV3_CLKA8,
    output FPGA_LV3_CLKB8,

    output FPGA_LED0,
    output FPGA_LED1,
    // //DDR3 Interface
    // // Inouts
    // inout  [15:0] DDR3_0_dq,
    // inout  [ 1:0] DDR3_0_dqs_n,
    // inout  [ 1:0] DDR3_0_dqs_p,

    // // Outputs
    // output [13:0] DDR3_0_addr,
    // output [ 2:0] DDR3_0_ba,
    // output        DDR3_0_ras_n,
    // output        DDR3_0_cas_n,
    // output        DDR3_0_we_n,
    // output        DDR3_0_reset_n,
    // output [ 0:0] DDR3_0_ck_p,
    // output [ 0:0] DDR3_0_ck_n,
    // output [ 0:0] DDR3_0_cke,
    // output [ 0:0] DDR3_0_cs_n,
    // output [ 1:0] DDR3_0_dm,
    // output [ 0:0] DDR3_0_odt,

    output CPLD0_CLK,
    output CPLD1_CLK,

    output PHY_RESET,

    //Cameralink模块
    output        CL_LVAL,
    output        CL_FVAL,
    output        CL_DVAL,
    output        CL_PWR_DWN,
    output        CL_SPARE,
    output        CL_TXCLK,
    output [15:0] CL_DATA
    //     //Cameralink模块
    // output CM_LVAL,
    // output CM_FVAL,
    // output CM_DVAL,
    // output CM_PWR_DWN,
    // output CM_SPARE,
    // output CM_TXCLK,
    // output [15:0]CM_DATA
);
  wire CLK_50M;
  wire CLK_50M_BUF;

  wire CLK_160M;
  wire CLK_100M;
  wire CLK_CPLD_25M;
  wire CLK_DDR_200M;
  wire CLK_UART_50M;
  wire CLK_SPI_10M;
  wire CLK_CAMERALINK_50M;
  wire locked;
  wire RST_N;

  wire pixel_clk;

  wire CCD_CLK;
  assign CCD_CLK  = CLK_160M;
  /////////////////////////////////////////////////////////
  assign ADC1_CLK = pixel_clk;
  assign ADC2_CLK = pixel_clk;
  assign ADC3_CLK = pixel_clk;
  assign ADC4_CLK = pixel_clk;

  IBUF #(
      .IBUF_LOW_PWR("FALSE"),   // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards 
      .IOSTANDARD  ("DEFAULT")  // Specify the input I/O standard
  ) IBUF_inst (
      .O(CLK_50M_BUF),  // Buffer output
      .I(SYS_CLK_50M)   // Buffer input (connect directly to top-level port)
  );
  BUFG BUFG_inst (
      .O(CLK_50M),     // 1-bit output: Clock output
      .I(CLK_50M_BUF)  // 1-bit input: Clock input
  );
  //例化MMCM时钟模块
  MMCM MMCM0 (
      .CLK_IN  (CLK_50M),
      .clk_out1(CLK_100M),
      .clk_out2(CLK_UART_50M),
      .clk_out3(CLK_CPLD_25M),
      .clk_out4(CLK_SPI_10M),
      .clk_out5(CLK_DDR_200M),
      .clk_out6(CLK_CAMERALINK_50M),
      .locked  (locked)
  );

  clk_wiz_0 clk_wiz_0_inst0 (
      .clk_in1 (CLK_100M),
      .resetn  (1'B1),
      .clk_out1(CLK_160M),
      .clk_out2(clk_1mhz),
      .clk_out3(),
      .locked  ()
  );

  assign RST_N     = FPGA_CPLD1_IO2 && locked;
  assign ADC_PD    = RST_N;
  assign PHY_RESET = RST_N;

  wire dps_alm_in;
  assign CPLD0_CLK      = CLK_CPLD_25M;
  assign CPLD1_CLK      = CLK_CPLD_25M;

  assign FPGA_CPLD1_IO0 = UART_RX;
  assign UART_TX        = FPGA_CPLD1_IO1;

  assign FPGA_LED0      = locked;
  assign FPGA_LED1      = locked;



  reg        clk_1m;
  reg [15:0] clk_cnt;
  always @(posedge clk_1mhz or negedge RST_N) begin
    if (!RST_N) begin
      clk_cnt <= 1'b0;
      clk_1m  <= 1'b0;
    end else if (clk_cnt == 3'd5) begin
      clk_cnt <= 16'd0;
      clk_1m  <= !clk_1m;
    end else begin
      clk_cnt <= clk_cnt + 1'd1;
      clk_1m  <= clk_1m;
    end
  end
  /****************************************************************************************/
  wire [31:0] UART_REG;  //32位串口寄存器
  wire        uart_ready_flag;  //串口指令ready信号
  wire        sync_uart_ready_flag;  //同步串口指令ready信号
  //串口
  wire [31:0] uart_tx_reg;
  wire        uart_tx_en;

  uart_module uart0 (
      .sys_clk      (CLK_UART_50M),
      .rst_n        (RST_N),
      .uart_rx      (UART_RX),
      .uart_tx      (),
      .uart_rx_reg  (UART_REG),
      .uart_rx_ready(uart_ready_flag),
      .uart_tx_reg  (UART_REG),
      .uart_tx_en   (uart_ready_flag)
  );

  //例化脉冲同步模块

  Sync_Pulse_Slow2Fast sync01 (
      .clk      (CCD_CLK),
      .rst_n    (RST_N),
      .sign_i   (uart_ready_flag),
      .pulse_r_o(sync_uart_ready_flag),
      .pulse_f_o(),
      .sign_o   ()
  );
  //例化脉冲同步模块
  Sync_Pulse_Fast2Slow Sync_Pulse_Fast2Slow1 (
      .clka    (CLK_50M),
      .clkb    (CLK_SPI_10M),
      .rst_n   (RST_N),
      .pulse_i (uart_ready_flag),
      .pulse_o (sync_uart_ready_flag1),
      .signal_o()
  );

  //***************************************************************************
  wire spi1_sclk;
  wire spi2_sclk;
  wire spi3_sclk;
  wire spi4_sclk;
  wire spi5_sclk;
  wire spi6_sclk;
  wire spi7_sclk;
  wire spi8_sclk;
  wire spi9_sclk;

  wire spi1_cs;
  wire spi2_cs;
  wire spi3_cs;
  wire spi4_cs;
  wire spi5_cs;
  wire spi6_cs;
  wire spi7_cs;
  wire spi8_cs;
  wire spi9_cs;

  wire spi1_init_stop;
  wire spi2_init_stop;
  wire spi3_init_stop;
  wire spi4_init_stop;
  wire spi5_init_stop;
  wire spi6_init_stop;
  wire spi7_init_stop;
  wire spi8_init_stop;
  wire spi9_init_stop;
  //***************************************************************************        
  //FOR LEVEL CLK        
  //***************************************************************************        
  FOR_LEV_CLK FOR_CLK_Module1 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA1),
      .FPGA_CLKB (FPGA_LV4_CLKB1),
      .FPGA_CLKC (FPGA_LV4_CLKC1)
  );

  FOR_LEV_CLK FOR_CLK_Module2 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA2),
      .FPGA_CLKB (FPGA_LV4_CLKB2),
      .FPGA_CLKC (FPGA_LV4_CLKC2)
  );

  FOR_LEV_CLK FOR_CLK_Module3 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA3),
      .FPGA_CLKB (FPGA_LV4_CLKB3),
      .FPGA_CLKC (FPGA_LV4_CLKC3)
  );

  FOR_LEV_CLK FOR_CLK_Module4 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA4),
      .FPGA_CLKB (FPGA_LV4_CLKB4),
      .FPGA_CLKC (FPGA_LV4_CLKC4)
  );

  FOR_LEV_CLK FOR_CLK_Module5 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA5),
      .FPGA_CLKB (FPGA_LV4_CLKB5),
      .FPGA_CLKC (FPGA_LV4_CLKC5)
  );

  FOR_LEV_CLK FOR_CLK_Module6 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA6),
      .FPGA_CLKB (FPGA_LV4_CLKB6),
      .FPGA_CLKC (FPGA_LV4_CLKC6)
  );

  FOR_LEV_CLK FOR_CLK_Module7 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA7),
      .FPGA_CLKB (FPGA_LV4_CLKB7),
      .FPGA_CLKC (FPGA_LV4_CLKC7)
  );

  FOR_LEV_CLK FOR_CLK_Module8 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV4_CLKA8),
      .FPGA_CLKB (FPGA_LV4_CLKB8),
      .FPGA_CLKC (FPGA_LV4_CLKC8)
  );

  //***************************************************************************        
  //THREE LEVEL CLK        
  //***************************************************************************        
  THREE_LEV_CLK THREE_CLK_Module1 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA1),
      .FPGA_CLKB (FPGA_LV3_CLKB1)
  );

  THREE_LEV_CLK THREE_CLK_Module2 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA2),
      .FPGA_CLKB (FPGA_LV3_CLKB2)
  );

  THREE_LEV_CLK THREE_CLK_Module3 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA3),
      .FPGA_CLKB (FPGA_LV3_CLKB3)
  );

  THREE_LEV_CLK THREE_CLK_Module4 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA4),
      .FPGA_CLKB (FPGA_LV3_CLKB4)
  );

  THREE_LEV_CLK THREE_CLK_Module5 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA5),
      .FPGA_CLKB (FPGA_LV3_CLKB5)
  );

  THREE_LEV_CLK THREE_CLK_Module6 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA6),
      .FPGA_CLKB (FPGA_LV3_CLKB6)
  );

  THREE_LEV_CLK THREE_CLK_Module7 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA7),
      .FPGA_CLKB (FPGA_LV3_CLKB7)
  );

  THREE_LEV_CLK THREE_CLK_Module8 (
      .reset_n   (RST_N),
      .sys_clk_in(clk_1m),
      .FPGA_CLKA (FPGA_LV3_CLKA8),
      .FPGA_CLKB (FPGA_LV3_CLKB8)
  );



  //Cameralink模块
  assign CL_PWR_DWN    = 1'b1;
  assign CL_SPARE      = 1'b1;
  //assign CL_TXCLK = cl_dclk;
  assign CL_DATA       = 16'hffff;

  assign FPGA_CLK1     = clk_1mhz;
  assign FPGA_CLK2     = clk_1mhz;
  assign FPGA_CLK3     = clk_1mhz;
  assign FPGA_CLK4     = clk_1mhz;
  assign FPGA_CLK5     = clk_1mhz;
  assign FPGA_CLK6     = clk_1mhz;
  assign FPGA_CLK7     = clk_1mhz;
  assign FPGA_CLK8     = clk_1mhz;
  assign FPGA_CLK9     = clk_1mhz;
  assign FPGA_CLK10    = clk_1mhz;
  assign FPGA_CLK11    = clk_1mhz;
  assign FPGA_CLK12    = clk_1mhz;
  assign FPGA_CLK13    = clk_1mhz;
  assign FPGA_CLK14    = clk_1mhz;
  assign FPGA_CLK15    = clk_1mhz;
  assign FPGA_CLK16    = clk_1mhz;
  assign FPGA_CLK17    = clk_1mhz;
  assign FPGA_CLK18    = clk_1mhz;
  assign FPGA_CLK19    = clk_1mhz;
  assign FPGA_CLK20    = clk_1mhz;
  assign FPGA_CLK21    = clk_1mhz;
  assign FPGA_CLK22    = clk_1mhz;
  assign FPGA_CLK23    = clk_1mhz;
  assign FPGA_CLK24    = clk_1mhz;


  assign FPGA_HF_CLK1  = clk_1mhz;
  assign FPGA_HF_CLK2  = clk_1mhz;
  assign FPGA_HF_CLK3  = clk_1mhz;
  assign FPGA_HF_CLK4  = clk_1mhz;
  assign FPGA_HF_CLK5  = clk_1mhz;
  assign FPGA_HF_CLK6  = clk_1mhz;
  assign FPGA_HF_CLK7  = clk_1mhz;
  assign FPGA_HF_CLK8  = clk_1mhz;
  assign FPGA_HF_CLK9  = clk_1mhz;
  assign FPGA_HF_CLK10 = clk_1mhz;
  assign FPGA_HF_CLK11 = clk_1mhz;
  assign FPGA_HF_CLK12 = clk_1mhz;

endmodule

