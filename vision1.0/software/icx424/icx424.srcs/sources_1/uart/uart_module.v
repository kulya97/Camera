module uart_module #(
    parameter CLK_FRE    = 50,      //Mhz
    parameter BPS        = 9600,  //uart bps
    parameter IDLE_CYCLE = 20,      //idle time
    parameter REG_SIZE   = 32
) (
    input                 sys_clk,        //system clock 50Mhz on board
    input                 rst_n,          //reset ,low active
    input                 uart_rx,
    output                uart_tx,
    output [REG_SIZE-1:0] uart_rx_reg,    //uart reg 
    output                uart_rx_ready,  //if update ready=1
    input  [        31:0] uart_tx_reg,
    input                 uart_tx_en
);
  /*******************************************************************/
  wire        tx_data_valid;
  wire        tx_data_ready;
  wire        tx_interrupt;
  wire [ 7:0] tx_data;

  wire        rx_data_valid;
  wire        rx_data_ready;
  wire        rx_interrupt;
  wire        rx_frame_idle;
  wire [ 7:0] rx_data;
  /*******************************************************************/
  wire [31:0] din;  // input wire [31 : 0] din
  wire        wr_en;  // input wire wr_en
  wire        rd_en;  // input wire rd_en
  wire [ 7:0] dout;  // output wire [7 : 0] dout
  wire        full;  // output wire full
  wire        empty;  // output wire empty
  wire        valid;
  /***********************************************************************/
  //开启接收数据
  assign rx_data_ready = 1'b1;
  /***********************************************************************/
  //写tx fifo数据
  assign wr_en         = uart_tx_en;
  assign din           = uart_tx_reg;
  /***********************************************************************/
  //读tx fifo数据
  assign rd_en         = valid && tx_data_ready;
  assign tx_data       = dout;
  /***********************************************************************/
  //发送数据
  assign tx_data_valid = valid && tx_data_ready;
  /***********************************************************************/
  uart_rx #(
      .CLK_FRE(CLK_FRE),
      .BAUD_RATE(BPS),
      .IDLE_CYCLE(IDLE_CYCLE)
  ) uart_rx_inst (
      .clk          (sys_clk),
      .rst_n        (rst_n),
      .rx_data      (rx_data),
      .rx_data_valid(rx_data_valid),
      .rx_data_ready(rx_data_ready),
      .rx_frame_idle(rx_frame_idle),
      .rx_interrupt (rx_interrupt),
      .rx_pin       (uart_rx)
  );

  uart_tx #(
      .CLK_FRE  (CLK_FRE),
      .BAUD_RATE(BPS)
  ) uart_tx_inst (
      .clk          (sys_clk),
      .rst_n        (rst_n),
      .tx_data      (tx_data),
      .tx_data_valid(tx_data_valid),
      .tx_data_ready(tx_data_ready),
      .tx_interrupt (tx_interrupt),
      .tx_pin       (uart_tx)
  );

  fifo_tx fifo_tx_inst (
      .clk  (sys_clk),  // input wire clk
      .din  (din),      // input wire [31 : 0] din
      .wr_en(wr_en),    // input wire wr_en
      .rd_en(rd_en),    // input wire rd_en
      .dout (dout),     // output wire [7 : 0] dout
      .full (full),     // output wire full
      .empty(empty),    // output wire empty
      .valid(valid)     // output wire valid
  );
  uart_reg #(
      .REG_SIZE(REG_SIZE)
  ) uart_reg0 (
      .clk          (sys_clk),
      .rst_n        (rst_n),
      .rx_data      (rx_data),
      .rx_data_valid(rx_data_valid),
      .rx_frame_idle(rx_frame_idle),
      .rx_interrupt (rx_interrupt),
      .reg_data     (uart_rx_reg),
      .reg_ready    (uart_rx_ready)
  );
  //   /*****************************************/
  //   wire        rx_fifo_valid;
  //   wire        rx_fifo_rd_en;
  //   wire [31:0] rx_fifo_dout;
  //   fifo_rx your_instance_name (
  //       .clk  (sys_clk),        // input wire clk
  //       .rst  (rst_n),          // input wire rst
  //       .din  (uart_rx_reg),    // input wire [31 : 0] din
  //       .wr_en(uart_rx_ready),  // input wire wr_en
  //       .rd_en(rx_fifo_rd_en),  // input wire rd_en
  //       .dout (rx_fifo_dout),   // output wire [31 : 0] dout
  //       .full (),               // output wire full
  //       .empty(),               // output wire empty
  //       .valid(rx_fifo_valid)   // output wire valid
  //   );
  //   reg sys_busy;
  //   assign rx_fifo_rd_en = rx_fifo_valid;

  //   always @(posedge sys_clk, negedge rst_n) begin
  //     if (!rst_n) begin
  //       ui_ready_i <= 1'b0;
  //     end else if (uart_ready && (UART_IN[31:16] == 16'hffff)) begin
  //       ui_ready_i <= 1'b1;
  //     end else begin
  //       ui_ready_i <= 1'b0;
  //     end
  //   end
  //   reg [3:0] current_state;
  //   reg [3:0] next_state;
  //   localparam S_INIT = 0;
  //   localparam S_RESET = 1;
  //   localparam S_IDLE = 2;
  //   localparam S_EN = 3;
  //   localparam S_WAIT = 4;
  //   localparam S_READ = 5;
  //   localparam S_SLEEP = 6;
  //   always @(posedge sys_clk, negedge rst_n) begin
  //     if (!rst_n) current_state <= S_IDLE;
  //     else current_state <= next_state;
  //   end
  // reg[15:0] state_cnt;
  // always@ (posedge sys_clk ,negedge rst_n)begin
  // if(!rst_n) state_cnt<=16'b0;
  // else if(next_state!=current_state)state_cnt<=16'd0;
  // else state_cnt<=
  // end
  //   
endmodule
