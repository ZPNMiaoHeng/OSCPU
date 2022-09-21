/**
  ** 根据输入的BWEN选择写入寄存器相应的位置，其余保持原值不变化
  ** 
  */

module S011HD1P_X32Y2D128_BW(
    Q, CLK, CEN, WEN, BWEN, A, D
);
parameter Bits = 128;
parameter Word_Depth = 256;
parameter Add_Width = 8;
parameter Wen_Width = 128;

output reg [Bits-1:0] Q;
input                 CLK;
input                 CEN;
input                 WEN;
input [Wen_Width-1:0] BWEN;            
input [Add_Width-1:0] A;
input [Bits-1:0]      D;

wire cen  = CEN;
wire wen  = WEN;
wire [Wen_Width-1:0] bwen = BWEN;                // 掩码？？

reg [Bits-1:0] ram [0:Word_Depth-1];
always @(posedge CLK) begin
    if(wen) begin
        ram[A] <= (D & bwen) | (ram[A] & ~bwen);
    end
    Q <= cen ? ram[A] : {4{$random}};
end

endmodule
