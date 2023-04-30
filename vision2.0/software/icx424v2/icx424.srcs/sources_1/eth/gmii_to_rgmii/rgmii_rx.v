module rgmii_rx (
    input       rst_n,
    //��̫��RGMII�ӿ�
    input       rgmii_rxc,     //RGMII����ʱ��
    input       rgmii_rx_ctl,  //RGMII�������ݿ����ź�
    input [3:0] rgmii_rxd,     //RGMII��������    

    //��̫��GMII�ӿ�
    output           gmii_rx_clk,  //GMII����ʱ��
    output reg       gmii_rx_dv,   //GMII����������Ч�ź�
    output reg [7:0] gmii_rxd,     //GMII��������   
    output reg       gmii_rxd_err
);
  assign gmii_rx_clk = rgmii_rxc;


  wire [7:0] data;
  wire       data_en;
  wire       data_err;


  IDDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "OPPOSITE_EDGE", "SAME_EDGE" 
                                       //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1     (1'b0),             // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2     (1'b0),             // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE      ("SYNC")            // Set/Reset type: "SYNC" or "ASYNC" 
  ) IDDR_ctrl (
      .Q1(data_en),       // 1-bit output for positive edge of clock
      .Q2(data_err),      // 1-bit output for negative edge of clock
      .C (rgmii_rxc),     // 1-bit clock input
      .CE(1'b1),          // 1-bit clock enable input
      .D (rgmii_rx_ctl),  // 1-bit DDR data input
      .R (~rst_n),        // 1-bit reset
      .S (1'b0)           // 1-bit set
  );


  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      IDDR #(
          .DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "OPPOSITE_EDGE", "SAME_EDGE" 
                                           //    or "SAME_EDGE_PIPELINED" 
          .INIT_Q1     (1'b0),             // Initial value of Q1: 1'b0 or 1'b1
          .INIT_Q2     (1'b0),             // Initial value of Q2: 1'b0 or 1'b1
          .SRTYPE      ("SYNC")            // Set/Reset type: "SYNC" or "ASYNC" 
      ) IDDR_ctrl (
          .Q1(data[i]),       // 1-bit output for positive edge of clock
          .Q2(data[4+i]),     // 1-bit output for negative edge of clock
          .C (rgmii_rxc),     // 1-bit clock input
          .CE(1'b1),          // 1-bit clock enable input
          .D (rgmii_rxd[i]),  // 1-bit DDR data input
          .R (~rst_n),        // 1-bit reset
          .S (1'b0)           // 1-bit set
      );
    end
  endgenerate

  always @(posedge rgmii_rxc or negedge rst_n)
    if (!rst_n) gmii_rxd <= 8'd0;
    else gmii_rxd <= data;

  always @(posedge rgmii_rxc or negedge rst_n)
    if (!rst_n) gmii_rxd_err <= 1'b0;
    else gmii_rxd_err <= data_err;

  always @(posedge rgmii_rxc or negedge rst_n)
    if (!rst_n) gmii_rx_dv <= 1'b0;
    else gmii_rx_dv <= data_en;
endmodule
