/**
  ** Date 8/21
  ** 设计思路：
  ** 1. 从0x8000_0000开始取指，等握手成功取到指令；
  ** 2. 暂停状态，将IF模块内一切暂停，IFDone拉高；
  **   a. 暂停触发：访存指令数据冒险，MEM模块触发总线访存；
  ** 3. IFDone无效（未完成取指）暂停流水线一切。
    ****************************************************************
  ** Modified: stall有效时，valid拉低不再去读取指令，IFDone拉高
    ****************************************************************
  *! BUG:第一次fire时，但memDone低电平，导致只能第二次握手才有效
  */

import chisel3._
import chisel3.util._
import Constant._
import javax.swing.plaf.metal.MetalTreeUI

class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new CoreInst

//    val pcSrc = Input(UInt(2.W))              //* =/=0,预测失败，flush+nextpc  //改进：EX阶段检测跳转方向是否向后，不然
    // true pc
    val takenMiss = Input(Bool())
    val nextPC = Input(UInt(WLEN.W))          //

    val stall = Input(Bool())
    val memDone = Input(Bool())
    val exc = Input(Bool())
    val intr = Input(Bool())

    val out = Output(new BUS_R)
    val IFDone = Output(Bool())                          //* 有效时才取到指令。后面流水级才能运行，否则处于暂停状态

    val preRs1En = Output(Bool())
    val preRs1Addr = Output(UInt(5.W))
    val preRs1Data = Input(UInt(64.W))
    val preRs1x1Data = Input(UInt(64.W))
  })
  val minidec = Module(new minidec)
  val bht = Module(new bht)

  val pc = RegInit("h8000_0000".U(WLEN.W))               //* nextPC = 0x8000_0000,可以取到正确指令
  val inst = RegInit(0.U(WLEN.W))

  io.imem.inst_valid := !io.stall                       //* IF valid一直有效，请求AXI传输指令
  io.imem.inst_req   := REQ_READ
  io.imem.inst_addr := pc.asUInt()
  io.imem.inst_size  := SIZE_W
  
  val fire = Mux(io.stall, true.B, 
                    io.imem.inst_valid && io.imem.inst_ready)  //* 握手成功，从总线上取出指令

// 握手成功，从总线上取到指令，更新寄存器PC与inst
  val ifInst = Mux(fire && (!io.stall), io.imem.inst_read, inst)
  val ifIntr = RegNext(io.intr)
  val ifPCfire = RegNext(fire)
  val ifPCstall = RegNext(io.stall)

  val ifPC = Mux(ifPCfire && !ifPCstall && !ifIntr,   // 更新下一周期地址 :中断信号打一拍，防止下一周期pc+4
//                Mux(io.pcSrc === 0.U && !io.exc, pc + 4.U, io.nextPC),  // 无中断异常情况下，pc+4
                Mux(io.exc | io.takenMiss, io.nextPC,
                  Mux(bht.io.takenPre, bht.io.takenPrePC, pc + 4.U)),
                Mux(io.intr, io.nextPC, pc)
              )

  pc := ifPC                                          //* 更新pc/inst寄存器值,并保持当前寄存器状态 
  inst := ifInst

  io.IFDone := fire && io.memDone
// --------------------------------------------------
  minidec.io.inst := ifInst

  // bht.io.pc := ifPC   //pc
  bht.io.pc := pc
  bht.io.jal := minidec.io.jal
  bht.io.jalr := minidec.io.jalr
  bht.io.bxx := minidec.io.bxx
  bht.io.imm := minidec.io.imm
  bht.io.rs1Addr := minidec.io.rs1Addr

  bht.io.rs1Data := io.preRs1Data
  bht.io.rs1x1Data := io.preRs1x1Data
  io.preRs1En := minidec.io.rs1En
  io.preRs1Addr := minidec.io.rs1Addr

  // val takenPre = RegInit(false.B)
  // val takenPrePC = RegInit(0.U(64.W))
  // when(ifPCfire) {
  //   takenPre := bht.io.takenPre
  //   takenPrePC := bht.io.takenPrePC
  // }
  
    // takenPre := Mux(ifPCfire, bht.io.takenPre, 0.U)
    // takenPrePC := Mux(ifPCfire, bht.io.takenPrePC, 0.U)

//------------------- IF ----------------------------
  io.out.valid    := fire
  io.out.pc       := ifPC
  io.out.inst     := ifInst
  io.out.typeL    := false.B
  io.out.aluA     := 0.U
  io.out.aluB     := 0.U
  io.out.aluOp    := 0.U
  io.out.branch   := 0.U
  io.out.memtoReg := 0.U
  io.out.memWr    := 0.U
  io.out.memOp    := 0.U
  io.out.memAddr  := 0.U
  io.out.rdEn     := false.B
  io.out.rdAddr   := 0.U
  io.out.rs1Data  := 0.U
  io.out.rs2Data  := 0.U
  io.out.imm      := 0.U
  io.out.pcSrc    := 0.U
  io.out.nextPC   := 0.U
  io.out.aluRes   := 0.U
  io.out.memData  := 0.U

  io.out.csrOp := 0.U
  io.out.takenPre := bht.io.takenPre
  io.out.takenPrePC := bht.io.takenPrePC
}
