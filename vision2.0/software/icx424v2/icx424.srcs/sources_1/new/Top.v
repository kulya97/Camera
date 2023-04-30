`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/17 00:57:53
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top (
    input             sys_clk_p,   //input differential clock
    input             sys_clk_n,
    input             rst_n,
    //timing
    output            XV1,
    output            XV2,
    output            XSG2,
    output            XV3,
    output            XSG3,
    output            XSUB,
    output            H1,
    output            H2,
    output            RG,
    //adc
    output            ADC_CLK,
    input             ADC_OUTCLK,
    input      [15:0] ADC_DATA,
    output            ADC_SCLK,
    output            ADC_SEN,
    output            ADC_SDI,
    input             ADC_SDO,
    output            ADC_SH_R,
    output            ADC_CAL,
    output            ADC_RST,
    output            ADC_PDN,
    //uart
    input             UART_RX,
    output            UART_TX,
    //
    //PL以太网RGMII接口   
    input             eth_rxc,     //RGMII接收数据时钟
    input             eth_rx_ctl,  //RGMII输入数据有效信号
    input      [ 3:0] eth_rxd,     //RGMII输入数据
    output            eth_txc,     //RGMII发送数据时钟    
    output            eth_tx_ctl,  //RGMII输出数据有效信号
    output     [ 3:0] eth_txd,     //RGMII输出数据          
    output            eth_rst_n,   //以太网芯片复位信号，低电平有效   
    //cameralink
    output            CM_LVAL,
    output            CM_FVAL,
    output            CM_DVAL,
    output            CM_TXCLK,
    output     [15:0] CM_DATA,
    output            CM_PWR_DWN,
    output            CM_SPARE,
    output reg        LED
);

  /****************************************************************************************/
  wire sys_clk_in, sys_clk, uart_clk, timing_clk, spi_clk, eth_clk;
  wire RST_N, locked;
  assign RST_N = locked;
  IBUFDS sys_clk_ibufgds (
      .O (sys_clk_in),
      .I (sys_clk_p),
      .IB(sys_clk_n)
  );
  clk_wiz_0 instance_name (
      // Clock out ports
      .sys_clk   (sys_clk),     // output sys_clk
      .uart_clk  (uart_clk),    // output uart_clk
      .timing_clk(timing_clk),  // output timing_clk
      .spi_clk   (spi_clk),     // output spi_clk
      .eth_clk   (eth_clk),
      // Status and control signals
      .reset     (1'b0),        // input reset
      .locked    (locked),      // output locked
      // Clock in ports
      .clk_in1   (sys_clk_in)   // input clk_in1
  );
  /****************************************************************************************/
  assign ADC_SH_R   = 1'b0;
  assign ADC_CAL    = 1'b0;
  assign ADC_RST    = locked;
  assign ADC_PDN    = locked;
  assign CM_PWR_DWN = locked;
  assign CM_SPARE   = locked;
  /****************************************************************************************/
  reg [31:0] timer;
  always @(posedge sys_clk or negedge RST_N) begin
    if (~RST_N) timer <= 32'd0;
    else if (timer == 32'd9_999_999) timer <= 32'd0;
    else timer <= timer + 1'b1;
  end
  always @(posedge sys_clk or negedge RST_N) begin
    if (~RST_N) LED <= 1'b0;
    else if (timer == 32'd2_499_999) LED <= !LED;
  end
  /****************************************************************************************/
  wire [31:0] UART_REG;  //
  wire        uart_ready_flag;  //
  wire        sync_uart_ready_flag;  //
  wire        sync_uart_ready_flag1;
  wire [31:0] uart_tx_reg;
  wire        uart_tx_en;
  uart_module uart0 (
      .sys_clk      (uart_clk),
      .rst_n        (RST_N),
      .uart_rx      (UART_RX),
      .uart_tx      (UART_TX),
      .uart_rx_reg  (UART_REG),
      .uart_rx_ready(uart_ready_flag),
      .uart_tx_reg  (UART_REG),
      .uart_tx_en   (uart_ready_flag)
  );
  Sync_Pulse_Slow2Fast Sync_Pulse_Slow2Fast1 (
      .clk      (timing_clk),
      .rst_n    (RST_N),
      .sign_i   (uart_ready_flag),
      .pulse_r_o(sync_uart_ready_flag),
      .pulse_f_o(),
      .sign_o   ()
  );
  Sync_Pulse_Fast2Slow Sync_Pulse_Fast2Slow1 (
      .clka    (uart_clk),
      .clkb    (spi_clk),
      .rst_n   (RST_N),
      .pulse_i (uart_ready_flag),
      .pulse_o (sync_uart_ready_flag1),
      .signal_o()
  );
  /****************************************************************************************/
  LM98725_SPI_Module #(
      .ADDRESS(16'HADAA)
  ) LM98725_ModuleA (
      .CLK       (spi_clk),
      .RST_N     (RST_N),
      .UART_IN   (UART_REG),
      .uart_ready(sync_uart_ready_flag1),
      .SCLK      (ADC_SCLK),
      .SEN       (ADC_SEN),
      .SDI       (ADC_SDI),
      .SDO       (ADC_SDO)
  );


  /****************************************************************************************/
  wire pixel_clk, frame_valid, line_valid, data_valid;
  wire V1, V2, V3, V_TR, FSUB, HF1, HF2, FRG;
  wire sys_en;
  ICX424_Timing ICX424_Timing0 (
      .sys_clk    (timing_clk),
      .rst_n      (RST_N),
      .sys_en     (sys_en),
      .V1         (V1),
      .V2         (V2),
      .V3         (V3),
      .V_TR       (V_TR),
      .FSUB       (FSUB),
      .HF1        (HF1),
      .HF2        (HF2),
      .FRG        (FRG),
      .pixel_clk  (pixel_clk),
      .frame_valid(frame_valid),
      .line_valid (line_valid),
      .data_valid (data_valid),
      .line_cnt   (line_cnt),
      .pixel_cnt  (pixel_cnt),
      .UART_IN    (UART_REG),
      .uart_ready (sync_uart_ready_flag)
  );
  assign sys_en   = 1'b1;
  assign XV1      = !V1;
  assign XV2      = !V2;
  assign XSG2     = !V_TR;
  assign XV3      = !V3;
  assign XSG3     = !V_TR;
  assign XSUB     = !FSUB;
  assign H1       = !HF1;
  assign H2       = !HF2;
  assign RG       = !FRG;

  assign ADC_CLK  = pixel_clk;
  assign CM_FVAL  = frame_valid;
  assign CM_LVAL  = line_valid;
  assign CM_DVAL  = data_valid;
  assign CM_TXCLK = pixel_clk;
  assign CM_DATA  = ADC_DATA;


  ila_0 your_instance_name (
	.clk(timing_clk), // input wire clk


	.probe0(ADC_CLK), // input wire [0:0]  probe0  
	.probe1(ADC_DATA), // input wire [15:0]  probe1 
	.probe2(ADC_OUTCLK), // input wire [0:0]  probe2 
	.probe3(frame_valid) // input wire [0:0]  probe3
);

  //parameter define
  //开发板MAC地址 
  parameter BOARD_MAC = 48'h00_11_22_33_44_55;
  //开发板IP地址 
  parameter BOARD_IP = {8'd192, 8'd168, 8'd0, 8'd10};
  //目的MAC地址 
  parameter DES_MAC = 48'hff_ff_ff_ff_ff_ff;
  //目的IP地址 
  parameter DES_IP = {8'd192, 8'd168, 8'd0, 8'd2};
  //输入数据IO延时,此处为0,即不延时(如果为n,表示延时n*78ps) 
  parameter IDELAY_VALUE = 0;
  eth_udp_loop #(
      .BOARD_MAC   (BOARD_MAC),
      .BOARD_IP    (BOARD_IP),
      .DES_MAC     (DES_MAC),
      .DES_IP      (DES_IP),
      .IDELAY_VALUE(IDELAY_VALUE)
  ) u_eth_udp_loop (
      .sys_rst_n (RST_N),
      .eth_rxc   (eth_rxc),
      .eth_rx_ctl(eth_rx_ctl),
      .eth_rxd   (eth_rxd[3:0]),

      .eth_txc   (eth_txc),
      .eth_tx_ctl(eth_tx_ctl),
      .eth_txd   (eth_txd[3:0]),
      .eth_rst_n (eth_rst_n)
  );

endmodule

