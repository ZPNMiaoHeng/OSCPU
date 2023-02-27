import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import difftest._
import Constant._
import utils._

class CSR extends Module {
  val io = IO(new Bundle {
    val pc = Input(UInt(32.W))
    val inst = Input(UInt(32.W))
    
    val IFDone = Input(Bool())
    val rs1Data = Input(UInt(64.W))
    val csrOp = Input(UInt( 4.W))
    val rAddr = Input(UInt(12.W))   // 将csr中数据读出，写入寄存器中

    val cmp_ren = Input(Bool())     // mtimecmp control
    val cmp_wen = Input(Bool())
    val cmp_addr = Input(UInt(64.W))
    val cmp_wdata = Input(UInt(64.W))
    val cmp_rdata = Output(UInt(64.W))
    val clintEn = Output(Bool())
    
    val rData = Output(UInt(64.W))    // csr指令写回寄存器的值
    val csrOp_WB = Output(UInt(4.W))

//* --------- csr ------------------------
    val mepc = Output(UInt(64.W))     // 退出异常mret 保存地址
    val mtvec = Output(UInt(64.W))    // Machine Trap-Vector Base-Address Register：ecall跳转地址 
    val mie = Output(UInt(64.W))
    val mstatus = Output(UInt(64.W))
  })

//* --------------------- csr regs -------------------------------
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

  val mtime = RegInit(UInt(64.W), 0.U)             //Clint
  val mtimecmp = RegInit(UInt(64.W), 0.U)          //Clint

  mtime := mtime + 1.U
  when (io.cmp_wen) {
    mtimecmp := io.cmp_wdata
  }
  val clintEn = ((io.mstatus(3) === 1.U) && (io.mie(7)===1.U) 
                  && (mtime >= mtimecmp)) && io.IFDone

//* csr write and read
//**************************************************************
// csrOp:   3      2            1  0
//      +------+---------------+------+
//      |csrRW |判断csr i type |csrOp |
//      +------+---------------+------+
//**************************************************************
  val csrOp   = io.csrOp
  val wAddr   = io.inst(31, 20)
  val rs1Data = Mux(csrOp(2)=== 1.U, 
                      Cat(0.U(59.W), io.inst(19, 15)),                      // csr i type instruction
                        io.rs1Data)
  val csrRW = ((csrOp(3) === 0.U) && (csrOp =/= "b0000".U))                 // csrrc/csrrs/csrrw+i
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
      "b01".U -> rs1Data.asUInt(),          // csrrw
      "b10".U -> (op1 | rs1Data).asUInt(),  // csrrs
      "b11".U -> (op1 & ~rs1Data).asUInt()  // csrrc
      )
    ),
  0.U)

  when((io.csrOp === "b1000".U) && io.IFDone) {         //ecall
    mcause  := 11.U
 //    mtvec  := //! 存储地址
    mepc    := io.pc
    mstatus := Cat(mstatus(63,13), "b11".U, mstatus(10,8), mstatus(3), mstatus(6, 4), "b0".U, mstatus(2, 0))
  } .elsewhen((io.csrOp === "b1001".U) && io.IFDone) {  //ebreak
    mstatus := Cat(mstatus(63,13), "b00".U, mstatus(10,8), "b1".U, mstatus(6, 4), mstatus(7), mstatus(2, 0))
  } .elsewhen(clintEn && io.IFDone) {    //!
    mepc := io.pc
    mcause := "h8000000000000007".U
    mstatus := Cat(mstatus(63,13), "b11".U, mstatus(10,8), mstatus(3), mstatus(6, 4), "b0".U, mstatus(2, 0))
  }

  mcycle := mcycle + 1.U
//* ------------------------------------- 写回寄存器 -------------------------------------------
  when(csrRW) {
    when(wAddr === Csrs.mcycle) {
      mcycle := wdata 
    }
    when(wAddr === Csrs.mtvec) {
      mtvec := RegNext(wdata)
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

//* --------------------------------------------------------------------------------
  val rDataT = LookupTreeDefault(io.rAddr, 0.U, List(   // 写入的csr 寄存器
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

  io.rData := RegNext(rDataT)

  io.mepc := mepc
  io.mtvec := mtvec
  io.csrOp_WB := io.csrOp
  io.mie := mie
  io.mstatus := mstatus
  io.clintEn := clintEn
  io.cmp_rdata := Mux(io.cmp_ren, 
                    Mux(io.cmp_addr === MTIME, 
                      mtime, mtimecmp), 0.U)

  // difftest for CSR state
  val dt_cs = Module(new DifftestCSRState)
  dt_cs.io.clock          := clock
  dt_cs.io.coreid         := 0.U
  dt_cs.io.priviledgeMode := 3.U        // machine mode
  dt_cs.io.mstatus        := mstatus
  dt_cs.io.sstatus        := mstatus & "h80000003000de122".U
  dt_cs.io.mepc           := mepc
  dt_cs.io.sepc           := 0.U
  dt_cs.io.mtval          := 0.U
  dt_cs.io.stval          := 0.U
  dt_cs.io.mtvec          := mtvec
  dt_cs.io.stvec          := 0.U
  dt_cs.io.mcause         := mcause
  dt_cs.io.scause         := 0.U
  dt_cs.io.satp           := 0.U
  dt_cs.io.mip            := 0.U
  dt_cs.io.mie            := mie
  dt_cs.io.mscratch       := mscratch
  dt_cs.io.sscratch       := 0.U
  dt_cs.io.mideleg        := 0.U
  dt_cs.io.medeleg        := 0.U
}