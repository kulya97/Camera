module AD7671_Module (
    input         sys_clk,
    input         rst_n,
    output        adc_cs_n_o,
    output        adc_rd_n_o,
    output        adc_reset_o,
    output        adc_pd_o,
    output        adc_cnvst_n_o,
    input         adc_busy_i,
    input  [15:0] adc_data_i,
    /*******************************/
    output        ui_valid_o,
    output [15:0] ui_data_o,
    input  [31:0] UART_IN,
    input         uart_ready
);
  reg ui_ready_i;

  always @(posedge sys_clk, negedge rst_n) begin
    if (!rst_n) begin
      ui_ready_i <= 1'b0;
    end else if (uart_ready && (UART_IN[31:16] == 16'hcccc)) begin
      ui_ready_i <= 1'b1;
    end else begin
      ui_ready_i <= 1'b0;
    end
  end
// wire ui_ready_i=1'b1;
  AD7671_Read AD7671_Read0 (
      .sys_clk      (sys_clk),
      .rst_n        (rst_n),
      .adc_cs_n_o   (adc_cs_n_o),
      .adc_rd_n_o   (adc_rd_n_o),
      .adc_cnvst_n_o(adc_cnvst_n_o),
      .adc_busy_i   (adc_busy_i),
      .adc_reset_o  (adc_reset_o),
      .adc_pd_o     (adc_pd_o),
      .adc_data_i   (adc_data_i),
      .ui_ready_i   (ui_ready_i),
      .ui_valid_o   (ui_valid_o),
      .ui_data_o    (ui_data_o)
  );


endmodule
