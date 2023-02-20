import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import difftest._
import Constant._
import utils._

class CSR extends Module {
  val io = IO(new Bundle {
    val pc      = Input(UInt(32.W))
    val inst    = Input(UInt(32.W))
    
    val rs1Data = Input(UInt(64.W))
    val csrOp   = Input(UInt( 4.W))
    val rAddr   = Input(UInt(12.W))   // 将csr中数据读出，写入寄存器中
    
    val rData = Output(UInt(64.W))    // csr指令写回寄存器的值
//    val mtvec = Output(UInt(64.W))    // Machine Trap-Vector Base-Address Register：ecall跳转地址
//    val mepc  = Output(UInt(64.W))    // 退出异常mret 保存地址
    
  })
  val mstatus = RegInit(UInt(64.W), "h00001800".U) // Machine Mode
  val mtvec   = RegInit(UInt(64.W), 0.U)           // Machine Trap-Vector Base-Address Register
  val mepc    = RegInit(UInt(64.W), 0.U)           // Machine Exception Program Counter
  val mcause  = RegInit(UInt(64.W), 0.U)           // Machine Cause

  val mhartid   = RegInit(UInt(64.W), 0.U)
  val mie       = RegInit(UInt(64.W), 0.U)
  val mip       = RegInit(UInt(64.W), 0.U)
  val mscratch  = RegInit(UInt(64.W), 0.U)
  val mcycle    = RegInit(UInt(64.W), 0.U)
  val minstret  = RegInit(UInt(64.W), 0.U)

//* csr write and read
//**************************************************************
// csrOp:3      2            1  0
// +------+---------------+------+
// |csrRW |判断csr i type |csrOp |
// +------+---------------+------+
//**************************************************************
  val csrOp   = io.csrOp
  val wAddr   = io.inst(31, 20)
  val rs1Data = Mux(csrOp(2)=== 1.U, 
                      Cat(0.U(59.W), io.inst(19, 15)), // csr i type instruction
                        io.rs1Data)
  val csrRW = (csrOp(3) === 0.U)                                                  // csrrc/csrrs/csrrw+i
//  val csrEM = (csrOp === "b1000".U) || (csrOp === "b1001".U) // ecall/mret
  val op1 = LookupTreeDefault(wAddr, 0.U, List(                             //  csr reg rs1 and write back
    Csrs.mstatus  -> mstatus,
    Csrs.mcause   -> mcause,
    Csrs.mie      -> mie,
    Csrs.mtvec    -> mtvec,
    Csrs.mscratch -> mscratch,
    Csrs.mepc     -> mepc,
    Csrs.mip      -> mip,
    Csrs.mcycle   -> mcycle,
    Csrs.minstret -> minstret
  ))

  val wdata = Mux(csrRW, 
    LookupTreeDefault(csrOp(1, 0), 0.U, List(
      "b01".U -> op1.asUInt()            , // csrrw
      "b10".U -> (op1 | rs1Data).asUInt(), // csrrs
      "b11".U -> (op1 & rs1Data).asUInt() // csrrc
      )
    ),
  0.U)

  when(csrRW) {
    when(wAddr === Csrs.mcycle) {
      mcycle := wdata 
    }
    when(wAddr === Csrs.mtvec) {
      mtvec := wdata 
    } 
    when(wAddr === Csrs.mepc) {
      mepc := wdata 
    } 
    when(wAddr === Csrs.mcause) {
      mcause := wdata 
    } 
    when(wAddr === Csrs.mstatus) {
      mstatus := Cat((wdata(16) & wdata(15)) | (wdata(14) && wdata(13)), wdata(62, 0))
    } 
    when(wAddr === Csrs.mie) {
      mie := wdata 
    } 
    when(wAddr === Csrs.mscratch) {
      mscratch := wdata 
    }
  }

  io.rData := LookupTreeDefault(io.rAddr, 0.U, List(   // 写入的csr 寄存器
    Csrs.mstatus  -> mstatus,
    Csrs.mcause   -> mcause,
    Csrs.mie      -> mie,
    Csrs.mtvec    -> mtvec,
    Csrs.mscratch -> mscratch,
    Csrs.mepc     -> mepc,
    Csrs.mip      -> mip,
    Csrs.mcycle   -> mcycle,
    Csrs.minstret -> minstret,
  ))

/*
  // ECALL
  when (srcOp === "b1000".U) {
    mepc    := io.pc
    mcause  := 11.U
    mstatus := Cat(mstatus(63,13), Fill(2, 1.U), mstatus(10,8), mstatus(3), mstatus(6, 4), 0.U, mstatus(2, 0))
  }

  // MRET : 退出机器模式，MIE位置MPIE
  when (sysop === "b1001".U) {
    mstatus := Cat(mstatus(63,13), Fill(2, 0.U), mstatus(10,8), 1.U, mstatus(6, 4), mstatus(7), mstatus(2, 0))
  }
*/

}