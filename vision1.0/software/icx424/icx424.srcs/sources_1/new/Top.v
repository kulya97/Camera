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
  assign ADC_SH_R   = 1'b0;
  assign ADC_CAL    = 1'b0;
  assign ADC_RST    = 1'b1;
  assign ADC_PDN    = 1'b1;
  assign CM_PWR_DWN = 1'b1;
  assign CM_SPARE   = 1'b1;
  /****************************************************************************************/
  wire sys_clk_in, sys_clk, uart_clk, timing_clk, spi_clk;
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
      // Status and control signals
      .reset     (1'b0),        // input reset
      .locked    (locked),      // output locked
      // Clock in ports
      .clk_in1   (sys_clk_in)   // input clk_in1
  );
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
      .clk      (CCD_CLK),
      .rst_n    (RST_N),
      .sign_i   (uart_ready_flag),
      .pulse_r_o(sync_uart_ready_flag),
      .pulse_f_o(),
      .sign_o   ()
  );
  Sync_Pulse_Fast2Slow Sync_Pulse_Fast2Slow1 (
      .clka    (CLK_50M),
      .clkb    (CLK_SPI_10M),
      .rst_n   (RST_N),
      .pulse_i (uart_ready_flag),
      .pulse_o (sync_uart_ready_flag1),
      .signal_o()
  );
  /****************************************************************************************/
  LM98725_SPI_Module #(
      .ADDRESS(16'HADAA)
  ) LM98725_ModuleA (
      .CLK       (CLK_SPI_10M),
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
      .pixel_cnt  (pixel_cnt)
  );
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

endmodule
