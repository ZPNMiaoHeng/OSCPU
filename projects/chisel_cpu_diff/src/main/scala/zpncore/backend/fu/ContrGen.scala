import chisel3._
import chisel3.util._
import Instructions._
import Constant._
import utils._

class ContrGen extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(WLEN.W))

    val branch = Output(UInt(3.W))
    val immOp = Output(UInt(3.W))
    val rdEn = Output(Bool())
    val rdAddr = Output(UInt(5.W))
    val typeL = Output(Bool())
    val typeS = Output(Bool())
    val csrOp = Output(UInt(4.W))
    
    val aluCtr = new AluCtr
    val memCtr = new MemCtr
    val regCtrl = new RegCtrlIO
  })

  val inst = io.inst
// U type inst
  val instLui     = inst === LUI
  val instAuipc   = inst === AUIPC
  val typeU       = instLui || instAuipc

// I type inst 21
  val instAddi    = inst === ADDI
  val instAndi    = inst === ANDI 
  val instXori    = inst === XORI 
  val instOri     = inst === ORI  
  val instSlli    = inst === SLLI
  val instSrli    = inst === SRLI
  val instSrai    = inst === SRAI
  val instSlti    = inst === SLTI 
  val instSltiu   = inst === SLTIU
  val instAddiw   = inst === ADDIW           
  val instSlliw   = inst === SLLIW
  val instSrliw   = inst === SRLIW
  val instSraiw   = inst === SRAIW
  val instJalr    = inst === JALR
  val instLb      = inst === LB
  val instLh      = inst === LH
  val instLw      = inst === LW
  val instLd      = inst === LD
  val instLbu     = inst === LBU
  val instLhu     = inst === LHU
  val instLwu     = inst === LWU

//*CSR
  val csrrw   = inst === CSRRW
  val csrrs   = inst === CSRRS
  val csrrc   = inst === CSRRC
  val csrrwi  = inst === CSRRWI
  val csrrsi  = inst === CSRRSI
  val csrrci  = inst === CSRRCI

  val ecall   = inst === ECALL
  val mret    = inst === MRET

  val typeI       = instAddi   || instAndi   || instXori   || instOri   || instSlli  || instSrli  ||
                    instSrai   || instSlti   || instSltiu  || instAddiw || instSlliw || instSrliw ||
                    instSraiw  || instLb     || instLh     || instLw    || instLd    || instLbu   || 
                    instLhu    || instLwu    || csrrw      || csrrs     || ecall     || csrrc     || 
                    csrrsi     || csrrci
  val typeL = instLb || instLh || instLw || instLd || instLbu || 
             instLhu || instLwu

// J type 1
  val instJal     = inst === JAL
  val typeJ       = instJal || instJalr

//R-TYPE 16
  val instAdd     = inst === ADD
  val instSub     = inst === SUB
  val instSll     = inst === SLL
  val instSlt     = inst === SLT
  val instSltu    = inst === SLTU
  val instXor     = inst === XOR
  val instSrl     = inst === SRL
  val instSra     = inst === SRA
  val instOr      = inst === OR
  val instAnd     = inst === AND
  val instAddw    = inst === ADDW
  val instSubw    = inst === SUBW
  val instSllw    = inst === SLLW
  val instSrlw    = inst === SRLW
  val instSraw    = inst === SRAW
  val instRemw    = inst === REMW
  val instDiv     = inst === DIV
  val instDivw    = inst === DIVW
  val instMul     = inst === MUL
  val instMulw    = inst === MULW
  val typeR       = instAdd  || instSub  || instSll  || instSlt  || instSltu ||
                    instXor  || instSrl  || instSra  || instOr   || instAnd  ||
                    instAddw || instSubw || instSllw || instSrlw || instSraw ||
                    instRemw || instDiv  || instDivw || instMul  || instMulw ||
                    mret

// B type 6
  val instBeq      = inst === BEQ
  val instBne      = inst === BNE
  val instBlt      = inst === BLT
  val instBge      = inst === BGE
  val instBltu     = inst === BLTU
  val instBgeu     = inst === BGEU
  val typeB        = instBeq || instBne || instBlt || instBge ||instBltu || instBgeu

// S type 4
  val instSb       = inst === SB
  val instSh       = inst === SH
  val instSw       = inst === SW
  val instSd       = inst === SD
  val typeS        = instSb || instSh || instSw || instSd

// ebreak inst
  val Ebreak = inst === EBREAK

// 自定义指令集
  val my_inst = inst === MY_INST    //打印a0寄存器的值

// type+w
  val typeW        = instAddw || instSubw || instSllw || instSlliw ||
    instSraw || instSrlw ||instSrliw || instSraiw || instAddiw || instRemw ||
    instDivw || instMulw
//  io.typeW := typeW

  io.aluCtr.aluA := Mux(instAuipc || typeJ, 1.U, 0.U)                     /** 0 -> rs1; 1 -> pc */

  io.aluCtr.aluB := MuxCase("b01".U, List(
    (typeR || typeB) -> "b00".U,
    (typeJ) -> "b10".U))                                          // 00 -> rs2; 01 -> imm; 10 -> 4

    val aluAdd  = instAdd  || instAddiw || instJalr|| instLbu || instLb    ||
                  instLh   || instLhu   || instLw  || instLwu || instLd    ||
                  instSb   || instSh    || instSw  || instSd  || instAuipc ||
                  instLui  || instJal   || instAddi|| instAddw
    val aluSub  = instSub  || instSubw
    val aluSlt  = (instSlti || instSlt )
    val aluSltu = (instSltiu|| instSltu)
    val aluAnd  = (instAndi || instAnd )
    val aluOr   = (instOri  || instOr  )
    val aluXor  = (instXori || instXor )
    val aluSll  = (instSlli || instSlliw || instSll || instSllw)
    val aluSrl  = (instSrli || instSrliw || instSrl || instSrlw)
    val aluSra  = (instSrai || instSraiw || instSra || instSraw)
    val aluRem  = instRemw     /** 求余 */
    val aluDiv  = instDiv || instDivw
    val aluMul  = instMul || instMulw
  /** mul and div */

  io.aluCtr.aluOp := MuxCase("b0000".U, List(                                                                  // 加法器， 加法
    aluSub                                          -> "b1000".U,               // 加法器， 减法
    aluSll                                          -> "b0001".U,               // 移位器， 左移
    (instSlti || instSlt || instBlt || instBge)     -> "b0010".U,               // 做减法， 带符号小于置位结果输出， less按带符号结果设置
    (instBeq || instBne)                            -> "b1001".U,               // 相等比较 去做减法
    (instSltiu || instSltu || instBltu || instBgeu) -> "b1010".U,               // 做减法， 无符号小于置位结果输出， less按无符号结果设置
    (instLui)                                       -> "b0011".U,               // ALU 输入的B结果直接输出
    aluRem                                          -> "b1011".U,               // 求余数字
    aluXor                                          -> "b0100".U,               // 异或输出
    aluDiv                                          -> "b1100".U,               // 除法
    aluSrl                                          -> "b0101".U,               // 移位器， 逻辑右移
    aluSra                                          -> "b1101".U,               // 移位器， 算术右移
    aluOr                                           -> "b0110".U,               // 逻辑或
    aluMul                                          -> "b1110".U,               // 乘法
    aluAnd                                          -> "b0111".U))

  io.branch := MuxCase("b000".U, List( 
          (instJal)  -> "b001".U,
          (instJalr) -> "b010".U,
          (ecall)    -> "b011".U,
          (instBeq)  -> "b100".U,
          (instBne)  -> "b101".U,
          (instBlt || instBltu) -> "b110".U,
          (instBge || instBgeu) -> "b111".U))

  io.regCtrl.rs1En := ~(instLui || instAuipc || instJal)  /** ecall */
  io.regCtrl.rs2En :=  (typeR || typeB || typeS)
  io.regCtrl.rs1Addr := Mux(Ebreak || my_inst, "b01010".U, inst(19, 15)) //! add my_inst reg1
  io.regCtrl.rs2Addr := inst(24, 20)

  val wRegEn = ~(typeS || typeB || Ebreak )  /** Ecall Mret */
  io.rdEn := wRegEn
  io.rdAddr := Mux(wRegEn, inst(11, 7), 0.U)

  io.immOp := MuxCase("b111".U, List(
          (instAddi || instAddiw  || instSlti || instSltiu || instXori || instOri || instAndi || instSlli || instSlliw ||
           instSrli || instSrliw  || instSrai || instSraiw || instJalr || instLb || instLh || 
           instLw   || instLwu    ||  instLd || instLbu || instLhu ) -> "b000".U,                          // I Type
          (instAuipc || instLui)  -> "b001".U,                                                             // U Type
          (instSd || instSb || instSw || instSh)-> "b010".U,                                               // S Type
          (instBeq || instBne || instBlt || instBge || instBltu || instBgeu) -> "b011".U,                  // B Type
          (instJal) -> "b100".U))                                                                          // J Type

  io.memCtr.memtoReg := MuxCase("b00".U, List(                                                             // alu.R -> Reg
    (instLb || instLh || instLw || instLwu || instLd || instLbu || instLhu)     -> "b01".U,                // Mem   -> Reg
    (typeW)                                                                     -> "b10".U
//    (instBeq || instBne || instBlt || instBge || instBltu || instBgeu)          -> "b11".U               // 无用信号
  ))
  io.memCtr.memWr    := Mux(instSb || instSh || instSw || instSd, 1.U, 0.U)
  io.memCtr.memOP    := MuxCase("b111".U, List(
          (instLb || instSb) -> "b000".U,
          (instLh || instSh) -> "b001".U,
          (instLw || instSw) -> "b010".U,
          (instLd || instSd) -> "b011".U,
          (instLbu ) -> "b100".U,
          (instLhu ) -> "b101".U,
          (instLwu ) -> "b110".U))

  io.typeL := typeL
  io.typeS := typeS
  io.csrOp := MuxCase("b0000".U, List(          // 0 ## csr_func3
    (csrrw ) -> "b0001".U,
    (csrrs ) -> "b0010".U,
    (csrrc ) -> "b0011".U,
//    (      ) -> "b0100".U,
    (csrrwi) -> "b0101".U,
    (csrrsi) -> "b0110".U,
    (csrrci) -> "b0111".U,
    
    (ecall ) -> "b1000".U,
    (mret  ) -> "b1001".U
  ))
}