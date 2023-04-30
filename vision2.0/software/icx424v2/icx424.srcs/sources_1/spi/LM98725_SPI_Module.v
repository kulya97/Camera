
`timescale 1ns / 1ps

module LM98725_SPI_Module #(
    parameter ADDRESS = 16'HADAA
) (
    input             CLK,
    input             RST_N,
    input      [31:0] UART_IN,
    input             uart_ready,
    output reg        SCLK,
    output reg        SEN,
    output            SDI,
    input             SDO
);

  reg  [ 3:0] STATE_CS;  //״̬���ĵ�ǰ״̬
  reg  [ 3:0] STATE_NS;  //״̬������һ��״̬
  reg  [ 4:0] sdi_bit_cnt;  //������¼���ݷ��͸����ļ�����
  reg  [ 4:0] sdi_bit_cnt_n;
  reg  [ 4:0] sdo_bit_cnt;  //������¼���ݽ��ո����ļ�����
  reg  [ 4:0] sdo_bit_cnt_n;
  reg  [15:0] sdi_shift;  //��λ�Ĵ���,�����λ�����Ƹ�SDI 
  reg  [15:0] sdi_shift_n;  //SDI_shift����һ��״̬

  reg         uart_req;
  wire        initial_req;
  wire        UpdateReq;
  //    reg              stop;
  //    reg stop_n;
  wire        stop;
  reg         stop_n1;
  reg         stop_n2;
  reg  [ 7:0] start_cnt;
  reg  [ 7:0] start_cnt_n;
  reg  [ 9:0] period_cnt;
  reg  [ 9:0] period_cnt_n;

  reg  [ 4:0] time_cnt;  //���ڼ�¼ʱ�Ӹ����ļ�����
  reg  [ 4:0] time_cnt_n;
  reg  [ 4:0] delay_cnt;  //���ڼ�¼��ʱ�����ļ�����
  reg  [ 4:0] delay_cnt_n;
  reg         SCLK_N;  //SCLK����һ��״̬
  reg         SEN_N;  //SEN����һ��״̬
  reg  [ 7:0] DATA_OUT_N;  //DATA_OUT����һ��״̬
  reg  [15:0] DATA_IN;

  parameter STATE_IDLE = 4'h0;  //״̬���Ŀ���״̬
  parameter STATE_READY = 4'h1;  //״̬����׼��״̬,��SEN����
  parameter STATE_RECEIVE = 4'h2;  //״̬���Ľ���״̬,����8������
  parameter STATE_TRANSFORM = 4'h3;  //״̬����ת��״̬,����״̬
  parameter STATE_SEND = 4'h4;  //״̬���ķ���״̬,����16������
  parameter STATE_FINISH = 4'h5;  //״̬�����״̬,��SEN����

  reg  [29:0] begin_cnt;
  reg  [29:0] begin_cnt_n;

  reg  [ 7:0] DATA_OUT;
  wire        UpdateDone;
  wire        locked;
  wire        CLK_300M;
  //   wire RST_N;

  /* ���ö�ʱ����ʱ��Ϊ1000ms,���㷽��Ϊ  (10*10^3)us / (1/50)us */
  parameter SET_TIME_10MS = 30'd5_000_000;
  /* ʱ���·,������delay_cnt�Ĵ�����ֵ */
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N) begin_cnt <= 30'd0;
    else begin_cnt <= begin_cnt_n;
  end

  /* ��ϵ�·,����ʵ��10ms���ӳ�,�ȴ������ȶ� */
  always @(*) begin
    if (begin_cnt == SET_TIME_10MS) begin_cnt_n = begin_cnt;
    else begin_cnt_n <= begin_cnt + 1'b1;
  end

  //ʱ���·,������time_cnt�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      start_cnt <= 8'd0;  //��ʼ��time_cntֵ
    else start_cnt <= start_cnt_n;  //������time_cnt��ֵ
  end

  //��ϵ�·,���ڼ�¼ʱ�Ӹ����ļ�����
  always @(*) begin
    if (start_cnt == 8'd180)  //�ж�״̬���ĵ�ǰ״̬
      start_cnt_n = 8'd0;  //״̬�����ı䣨����ת���ͷ���״̬��,������������
    else if (stop) start_cnt_n = 8'd0;
    else start_cnt_n = start_cnt + 8'd1;  //����������ͼ�1
  end

  assign initial_req = (start_cnt == 8'd2);  //��ʶ�������

  //ʱ���·,������time_cnt�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      period_cnt <= 10'd0;  //��ʼ��time_cntֵ
    else period_cnt <= period_cnt_n;  //������time_cnt��ֵ
  end

  //��ϵ�·,���ڼ�¼ʱ�Ӹ����ļ�����
  always @(*) begin
    if (start_cnt == 8'd180 && begin_cnt == SET_TIME_10MS)  //�ж�״̬���ĵ�ǰ״̬
      period_cnt_n = period_cnt + 10'd1;  //״̬�����ı䣨����ת���ͷ���״̬��,������������
    else period_cnt_n = period_cnt;  //����������ͼ�1
  end

  assign stop = (period_cnt == 10'd27);

  //ʱ���·,������time_cnt�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      time_cnt <= 5'h0;  //��ʼ��time_cntֵ
    else time_cnt <= time_cnt_n;  //������time_cnt��ֵ
  end

  //��ϵ�·,���ڼ�¼ʱ�Ӹ����ļ�����
  always @(*) begin
    if ((STATE_CS != STATE_NS) && (STATE_NS != STATE_TRANSFORM) && (STATE_NS != STATE_SEND))  //�ж�״̬���ĵ�ǰ״̬
      time_cnt_n = 5'h0;  //״̬�����ı䣨����ת���ͷ���״̬��,������������
    else if (SCLK != SCLK_N)  //�ж�ʱ�ӵĵ�ǰ״̬
      time_cnt_n = 5'h0;  //ʱ�ӷ����仯,����������
    else time_cnt_n = time_cnt + 5'h1;  //����������ͼ�1
  end

  //ʱ���·,������delay_cnt�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      delay_cnt <= 4'h0;  //��ʼ��delay_cntֵ
    else delay_cnt <= delay_cnt_n;  //������delay_cnt��ֵ
  end

  //��ϵ�·,������¼��ʱ�����ļ�����
  always @(*) begin
    if (STATE_CS != STATE_TRANSFORM)  //�ж�״̬���ĵ�ǰ״̬
      delay_cnt_n = 4'h0;  //�����ǰ��״̬����ת��״̬,delay_cnt_n����0
    else if (SCLK && (!SCLK_N))  //�ж�ʱ�ӵĵ�ǰ״̬
      delay_cnt_n = delay_cnt + 4'h1;  //���SCLK��������״̬,delay_cnt_n�ͼ�1
    else delay_cnt_n = delay_cnt;  //���򱣳ֲ���
  end


  //ʱ���·,������sdi_bit_cnt�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      sdi_bit_cnt <= 5'h0;  //��ʼ��bit_cntֵ
    else sdi_bit_cnt <= sdi_bit_cnt_n;  //������bit_cnt��ֵ
  end

  //��ϵ�·,������¼���ݷ��͸����ļ�����
  always @(*) begin
    if (STATE_CS != STATE_SEND)  //�ж�״̬���ĵ�ǰ״̬
      sdi_bit_cnt_n = 5'h0;  //�����ǰ��״̬���ڷ���״̬,bit_cnt_n����0
    else if (SCLK && (!SCLK_N))  //�ж�ʱ�ӵĵ�ǰ״̬
      sdi_bit_cnt_n = sdi_bit_cnt + 5'h1;  //���SCLK��������״̬,bit_cnt_n�ͼ�1
    else sdi_bit_cnt_n = sdi_bit_cnt;  //���򱣳ֲ���
  end

  //ʱ���·,������sdo_bit_cnt�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      sdo_bit_cnt <= 5'h0;  //��ʼ��sdo_bit_cntֵ
    else sdo_bit_cnt <= sdo_bit_cnt_n;  //������sdo_bit_cnt��ֵ
  end

  //��ϵ�·,������¼���ݽ��ո����ļ�����
  always @(*) begin
    if (STATE_CS != STATE_RECEIVE)  //�ж�״̬���ĵ�ǰ״̬
      sdo_bit_cnt_n = 5'h0;  //�����ǰ��״̬���ڽ���״̬,bit_cnt_n����0
    else if (SCLK && (!SCLK_N))  //�ж�ʱ�ӵĵ�ǰ״̬
      sdo_bit_cnt_n = sdo_bit_cnt + 5'h1;  //���SCLK��������״̬,bit_cnt_n�ͼ�1
    else sdo_bit_cnt_n = sdo_bit_cnt;  //���򱣳ֲ���
  end

  //ʱ���·,������sdi_shift�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      sdi_shift <= 16'h0;  //��ʼ��shift_regֵ
    else sdi_shift <= sdi_shift_n;  //������shift_reg��ֵ
  end

  //��ϵ�·,��λ�Ĵ���,��DATA_IN�����������Ƹ�sdi_shift
  always @(*) begin
    if (UpdateReq)  //�жϿ�ʼ��ʶ
      sdi_shift_n = DATA_IN;  //�����־Ϊ1,��DATA_IN�����ݸ�ֵ����λ�Ĵ���
    else if (SCLK && (time_cnt == 5'h0) && (STATE_CS == STATE_SEND))  //�ж�SCLK��״̬,�Ҵ��ڷ���״̬
      sdi_shift_n = {sdi_shift[14:0], 1'h0};  //���SCLKΪ��,��λ�Ĵ�����ʼ��λ
    else sdi_shift_n = sdi_shift;  //���򱣳ֲ���
  end

  //ʱ���·,������DATA_OUT�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      DATA_OUT <= 8'b0;  //��ʼ��DATA_OUTֵ
    else DATA_OUT <= DATA_OUT_N;  //������DATA_OUT��ֵ
  end

  //��ϵ�·,��λ�Ĵ���,��SDO�����������Ƹ�DATA_OUT
  always @(*) begin
    if (UpdateReq)  //�жϿ�ʼ��ʶ
      DATA_OUT_N = 8'b0;  //��ʼ��DATA_OUTֵ
    else if (SCLK && (time_cnt == 5'h0) && (STATE_CS == STATE_RECEIVE))  //�ж�SCLK��״̬���Ҵ��ڽ���״̬
      DATA_OUT_N = {DATA_OUT[6:0], SDO};  //���SCLKΪ��,��λ�Ĵ�����ʼ��λ
    else DATA_OUT_N = DATA_OUT;  //���򱣳ֲ���
  end

  assign SDI = sdi_shift[15];
  //---------------------------------------------------------------------------
  //--    ״̬��
  //---------------------------------------------------------------------------

  //ʱ���·,������STATE_CS�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      STATE_CS <= STATE_IDLE;  //��ʼ��STATE_CSֵ
    else STATE_CS <= STATE_NS;  //������STATE_CS��ֵ
  end

  //��ϵ�·,����ʵ��״̬��
  always @(*) begin
    case (STATE_CS)  //�ж�״̬���ĵ�ǰ״̬
      STATE_IDLE:
      if (UpdateReq)  //�жϿ�ʼ��ʶ
        STATE_NS = STATE_READY;  //�����ʶ��Ϊ1,�����׼��״̬
      else if (begin_cnt != SET_TIME_10MS) STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����
      else STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����

      STATE_READY:
      if (time_cnt == 5'h1)  //�ȴ�����ʱ��
        STATE_NS = STATE_RECEIVE;  //����ʱ�ӵ��˱�������״̬
      else STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����

      STATE_RECEIVE:
      if ((sdo_bit_cnt == 5'h8) && (!SCLK))  //��������8��
        STATE_NS = STATE_TRANSFORM;  //������ɽ���ת��״̬
      else STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����

      STATE_TRANSFORM:
      if (delay_cnt == 5'h2)  //�ȴ�����SCLKʱ��
        STATE_NS = STATE_SEND;  //����ʱ�ӵ��˱���뷢��״̬
      else STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����

      STATE_SEND:
      if ((sdi_bit_cnt == 5'h10) && (!SCLK))  //��������16��
        STATE_NS = STATE_FINISH;  //������ɽ������״̬
      else STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����

      STATE_FINISH:
      if (time_cnt == 4'h2)  //�ȴ�����ʱ��
        STATE_NS = STATE_IDLE;  //���һ������ת��,������һ��ת��
      else STATE_NS = STATE_CS;  //���򱣳�ԭ״̬����

      default: STATE_NS = STATE_IDLE;
    endcase
  end

  //ʱ���·,������SEN�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      SEN <= 1'h1;  //��ʼ��SENֵ
    else SEN <= SEN_N;  //������SEN��ֵ
  end

  //��ϵ�·,��������SEN��Ƭѡ����
  always @(*) begin
    if (STATE_CS == STATE_READY)  //�ж�״̬���ĵ�ǰ״̬
      SEN_N = 1'h0;  //�����ǰ��״̬����׼��״̬,SEN_N����0
    else if ((STATE_CS == STATE_FINISH) && (time_cnt == 5'h1))  //�ж�״̬���ĵ�ǰ״̬
      SEN_N = 1'h1;  //�����ǰ��״̬�������״̬����ʱ�Ӽ���������1,SEN_N����1
    else SEN_N = SEN;  //���򱣳ֲ���
  end

  //ʱ���·,������SCLK�Ĵ�����ֵ
  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N)  //�жϸ�λ
      SCLK <= 1'h0;  //��ʼ��SCLKֵ
    else SCLK <= SCLK_N;  //������SCLK��ֵ
  end

  //��ϵ�·,��������SCLK��ʱ�Ӳ���
  always @(*) begin
    if (((STATE_CS == STATE_SEND) || (STATE_CS == STATE_RECEIVE) || (STATE_CS == STATE_TRANSFORM)) && (!SCLK) && (time_cnt == 5'h1))  //�ж�״̬���ĵ�ǰ״̬
      SCLK_N = 1'h1;  //���������������,ÿ����ʱ�Ӿͻ�����һ���ߵ�ƽ��DA_CLK
    else if (((STATE_CS == STATE_SEND) || (STATE_CS == STATE_RECEIVE) || (STATE_CS == STATE_TRANSFORM)) && (SCLK) && (time_cnt == 5'h1))  //�ж�״̬���ĵ�ǰ״̬
      SCLK_N = 1'h0;  //���������������,ÿ����ʱ�Ӿͻ�����һ���͵�ƽ��DA_CLK
    else SCLK_N = SCLK;  //���򱣳ֲ���
  end

  assign UpdateDone = (STATE_CS == STATE_FINISH);  //��ʶ�������

  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N) uart_req <= 1'd0;
    else if (uart_ready && (UART_IN[31:16] == ADDRESS)) uart_req <= 1'd1;
    else uart_req <= 1'd0;
  end

  assign UpdateReq = (uart_req || initial_req);

  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N) DATA_IN = 16'h0;
    else if (stop) DATA_IN = UART_IN[15:0];
    else begin
      case (period_cnt)  //cnt0��cntĩλ��Ч
        //PAGE 0
        0: DATA_IN = {8'h00, 8'b1010_0010};  //��Ч
        1: DATA_IN = {8'h00, 8'b1010_0010};
        2: DATA_IN = {8'h02, 8'b0100_0010};  //OSR
        3: DATA_IN = {8'h03, 8'h86};  //
        4: DATA_IN = {8'h04, 8'b0000_0000};  //Main Configuration 4 :CLPIN Enable
        5: DATA_IN = {8'h05, 8'b0100_0000};  //Main Configuration 5 :Output Enable
        6: DATA_IN = {8'h06, 8'b0000_0001};  //TEST PATTERN


        7:  DATA_IN = {8'h08, 8'h0F};  //OSR CLAMP Start Edge
        7:  DATA_IN = {8'h08, 8'h0F};  //OSR CLAMP Start Edge
        8:  DATA_IN = {8'h09, 8'h13};  //OSR CLAMP Stop Edge      
        9:  DATA_IN = {8'h0A, 8'h00};  //OSG CLAMP Start Edge
        10: DATA_IN = {8'h0B, 8'h04};  //OSG CLAMP Stop Edge
        11: DATA_IN = {8'h0E, 8'h00};  //OSR Sample Start Edge              
        12: DATA_IN = {8'h0F, 8'h04};  //OSR Sample Stop Edge              
        13: DATA_IN = {8'h10, 8'h10};  //OSG Sample Start Edge               
        14: DATA_IN = {8'h11, 8'h14};  //OSG Sample Stop Edge              
        15: DATA_IN = {8'h1F, 8'b0000_0001};  //to PAGE 1

        16: DATA_IN = {8'h00, 8'h00};  //CDS Gain Mode              
        //17:DATA_IN = {8'h01,8'hBD};//Red PGA    
        17: DATA_IN = {8'h01, 8'h61};  //Red PGA    
        18: DATA_IN = {8'h02, 8'hB2};  //Green PGA;              
        //19:DATA_IN = {8'h04,8'h75};//Red even DAC MSB   
        19: DATA_IN = {8'h04, 8'h70};  //Red even DAC MSB               
        20: DATA_IN = {8'h05, 8'b0000_0000};
        21: DATA_IN = {8'h06, 8'h72};  //Green even DAC MSB              
        22: DATA_IN = {8'h07, 8'h00};
        23: DATA_IN = {8'h10, 8'h40};  //Red Even digital offset
        24: DATA_IN = {8'h11, 8'h40};  //Green Even digital offset
        25: DATA_IN = {8'h1F, 8'b0000_0000};  //to PAGE 1

        26: DATA_IN = {8'h00, 8'b1010_0011};  //locked
        27: DATA_IN = {8'h00, 8'b1010_0011};  //last cnt��Ч       
        //PAGE 1
        default: DATA_IN = {8'h00, 8'b1010_0010};

      endcase
    end
  end

  //��ϵ�·,��������SEN��Ƭѡ����
  always @(*) begin
    if (STATE_CS == STATE_READY)  //�ж�״̬���ĵ�ǰ״̬
      SEN_N = 1'h0;  //�����ǰ��״̬����׼��״̬,SEN_N����0
    else if ((STATE_CS == STATE_FINISH) && (time_cnt == 5'h1))  //�ж�״̬���ĵ�ǰ״̬
      SEN_N = 1'h1;  //�����ǰ��״̬�������״̬����ʱ�Ӽ���������1,SEN_N����1
    else SEN_N = SEN;  //���򱣳ֲ���
  end

endmodule




