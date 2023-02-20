import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import difftest._
import Constant._

class Csr extends Module {
  val io = IO(new Bundle {
    val pc    = Input(UInt(32.W))
    val inst  = Input(UInt(32.W))
    val rs1   = Input(UInt(64.W))
    val raddr = Input(UInt(12.W))
    val csrOp = Input(UInt( 4.W))     // csr ID类型信号
    
    val rData = Output(UInt(64.W))    // csr指令写回寄存器的值
    val mtvec = Output(UInt(64.W))    // Machine Trap-Vector Base-Address Register：ecall跳转地址
    val mepc  = Output(UInt(64.W))    // 退出异常mret 保存地址
    
  })
  val mstatus = RegInit(UInt(64.W), "h00001800".U)                 // Machine Mode
  val mtvec   = RegInit(UInt(64.W), 0.U)                           // Machine Trap-Vector Base-Address Register
  val mepc    = RegInit(UInt(64.W), 0.U)
  val mcause  = RegInit(UInt(64.W), 0.U)

  val csrOp    = io.csrOp
  val csrRegOp = io.inst(31, 20)
  val rs1 = Mux(csrOp(2)=== 1.U, Cat(0.U(59.W), io.inst(19, 15), io.rs1)
  val csrRW = (csrOp(4) === 0.U)                             // csrrc/csrrs/csrrw+i
  val csrEM = (csrOp === "b1000".U) || (csrOp === "b1001".U) // ecall/mret
  val csrReg = LookupTreeDefault(csrRegOp, 0.U, List(   //  csr reg rs1 and write back
//    Csrs.mhartid  -> mhartid  ,
    Csrs.mcause   -> mcause   ,
//    Csrs.mie      -> mie      ,
    Csrs.mtvec    -> mtvec    ,
//    Csrs.mscratch -> mscratch ,
    Csrs.mepc     -> mepc     ,
//    Csrs.mip      -> mip      ,
//    Csrs.mcycle   -> mcycle   ,
//    Csrs.minstret -> minstret ,
  ))
  
  val rdata = LookupTreeDefault(raddr, 0.U, List(   // 写入的csr 寄存器
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

  val csrRes = Mux(csrRW, LookupTreeDefault(csrOp(1, 0), 0.U, List(
    "b01".U -> csrReg & rs1, // csrrw
    "b10".U -> csrReg | rs1, // csrrs
    "b11".U -> csrReg      , // csrrc
  )) ,0.U)
  when(csrRW) {
    when(csrRegOp === Csrs.mcycle) {
      mcycle := wdata 
    }
    when(csrRegOp === Csrs.mtvec) {
      mtvec := wdata 
    }
    when(csrRegOp === Csrs.mepc) {
      mepc := wdata 
    }
    when(csrRegOp === Csrs.mcause) {
      mcause := wdata 
    }
    when(csrRegOp === Csrs.mstatus) {
      mstatus := Cat((wdata(16) & wdata(15)) | (wdata(14) && wdata(13)), wdata(62, 0))  // ???
    }
    when(csrRegOp === Csrs.mie) {
      mie := wdata 
    }
    when(csrRegOp === Csrs.mscratch) {
      mscratch := wdata 
    }
  }  



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


}