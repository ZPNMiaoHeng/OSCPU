import chisel3._
import chisel3.util._
import Instructions._
import Constant._
import utils._
/**
  * 
  */

  class minidec extends Module {
    val io = IO(new Bundle {
      val inst = Input(UInt(WLEN.W))

      val rs1En = Output(Bool())
      val rs1Addr = Output(UInt(5.W))
      val bjp = Output(Bool())              // 跳转信号
      val jal = Output(Bool())              // pc + imm
      val jalr = Output(Bool())             // rs1 + imm
      val bxx = Output(Bool())              // pc + imm

      val imm = Output(UInt(XLEN.W))
    })
    
  val jalr = inst === JALR
  val jal = inst === JAL
  val jxx = jal| jalr

  val beq = inst === BEQ
  val bne = inst === BNE
  val blt = inst === BLT
  val bge = inst === BGE
  val bltu = inst === BLTU
  val bgeu = inst === BGEU
  val bxx = beq| bne| blt| bge| bltu| bgeu

  val bjp = jxx| bxx
  val rs1En = jalr| bxx
  val rs1Addr = Mux(rs1En, 0.U(5,W), inst(19, 15))

  val immOp = WireInit(0.U(3.W))
  immOp := Mux(typeJ, 4.U,
             Mux(bxx, 3.U,
              5.U))               // 0.U
  
  val imm = Module(new ImmGen)
  imm.io.inst := io.inst
  imm.io.immOp := immOp

  io.rs1En := rs1En
  io.rs1Addr := rs1Addr
  io.bjp := bjp
  io.jal := jal
  io.jalr := jalr
  io.bxx := bxx
  io.imm := imm.io.imm

  }


