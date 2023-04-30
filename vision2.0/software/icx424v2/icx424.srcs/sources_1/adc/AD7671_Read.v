module AD7671_Read (
    input         sys_clk,
    input         rst_n,
    /*******************************/
    output        adc_cs_n_o,     //片选控制，低有效
    output        adc_rd_n_o,     //读取控制，低有效
    output        adc_cnvst_n_o,  //转换控制IO
    input         adc_busy_i,     //转换busy信号，高有效
    input  [15:0] adc_data_i,     //数据
    output        adc_reset_o,    //复位信号高有效
    output        adc_pd_o,       //电源控制，高有效
    /*******************************/
    input         ui_ready_i,
    output        ui_valid_o,
    output [15:0] ui_data_o
);
  /********************************************************/
  parameter FREQ_MHz = 10;  //模块时钟频率
  localparam TIME_1US = FREQ_MHz;
  localparam TIME_1MS = 1000 * TIME_1US;

  parameter EN_US = 5;  //转换使能时间控制
  parameter INIT_S = 1000 * TIME_1MS;  //上电时间控制
  parameter RST_MS = 20 * TIME_1MS;  //复位时间控制
  parameter SLEEP_MS = 100 * TIME_1MS;  //转换间隔时间控制
  /********************************************************/
  reg [3:0] S_STATE;
  reg [3:0] S_STATE_NEXT;

  localparam S_INIT = 0;
  localparam S_RESET = 1;
  localparam S_IDLE = 2;
  localparam S_EN = 3;
  localparam S_WAIT = 4;
  localparam S_READ = 5;
  localparam S_SLEEP = 6;
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      S_STATE <= S_INIT;
    end else begin
      S_STATE <= S_STATE_NEXT;
    end
  end
  /********************************************************/
  reg [31:0] clk_cnt;  //状态时间计数
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) clk_cnt <= 1'd0;
    else if (S_STATE != S_STATE_NEXT) clk_cnt <= 1'd0;
    else clk_cnt <= clk_cnt + 1'd1;
  end
  /********************************************************/
  always @(*) begin
    case (S_STATE)
      S_INIT: begin
        if (clk_cnt >= INIT_S) S_STATE_NEXT = S_IDLE;
        else S_STATE_NEXT = S_INIT;
      end
      S_RESET: begin
        if (clk_cnt >= RST_MS) S_STATE_NEXT = S_IDLE;
        else S_STATE_NEXT = S_RESET;
      end
      S_IDLE: begin
        if (ui_ready_i && adc_busy_i == 1'b0) S_STATE_NEXT = S_EN;
        else S_STATE_NEXT = S_IDLE;
      end
      S_EN: begin
        if (clk_cnt >= EN_US) S_STATE_NEXT = S_WAIT;
        else S_STATE_NEXT = S_EN;
      end
      S_WAIT: begin
        if (adc_busy_i == 1'b1) S_STATE_NEXT = S_WAIT;
        else S_STATE_NEXT = S_READ;
      end
      S_READ: begin
        S_STATE_NEXT = S_SLEEP;
      end
      S_SLEEP: begin
        if (clk_cnt >= SLEEP_MS) S_STATE_NEXT = S_IDLE;
        else S_STATE_NEXT = S_SLEEP;
      end
      default: begin
        S_STATE_NEXT = S_IDLE;
      end
    endcase
  end
  /********************************************************/
  reg cnvst_d0;
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) cnvst_d0 <= 1'd1;
    else if (S_STATE == S_EN) cnvst_d0 <= 1'd0;
    else cnvst_d0 <= 1'd1;
  end
  /********************************************************/
  reg [15:0] data_d0;
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) data_d0 <= 16'd1;
    else if (S_STATE == S_READ) data_d0 <= adc_data_i;
    else data_d0 <= data_d0;
  end
  /********************************************************/
  reg valid_d0;
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) valid_d0 <= 1'd0;
    else if (S_STATE == S_IDLE) valid_d0 <= 1'd1;
    else valid_d0 <= 1'd0;
  end
  /********************************************************/
  reg ctr_d0;
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) ctr_d0 <= 1'd1;
    else if (S_STATE == S_IDLE) ctr_d0 <= 1'd1;
    else ctr_d0 <= 1'd0;
  end
  /********************************************************/
  reg reset_d0;
  always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) reset_d0 <= 1'd1;
    else if (S_STATE == S_RESET) reset_d0 <= 1'd1;
    else reset_d0 <= 1'd0;
  end
  /********************************************************/
  assign adc_cs_n_o    = 1'b0;
  assign adc_rd_n_o    = 1'b0;
  assign adc_cnvst_n_o = cnvst_d0;
  assign ui_valid_o    = valid_d0;
  assign ui_data_o     = data_d0;
  assign adc_pd_o      = 1'b1;
  assign adc_reset_o   = reset_d0;
endmodule
