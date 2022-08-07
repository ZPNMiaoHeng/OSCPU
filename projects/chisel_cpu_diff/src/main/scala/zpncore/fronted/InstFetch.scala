import chisel3._
import chisel3.util._
import Constant._
/**
  ** 将ram中RomIo接口换成Axi取指接口
  ** 添加握手信号
  */
class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new CoreInst

    val nextPC = Input(UInt(WLEN.W))
    val pc = Output(UInt(WLEN.W))
    val inst = Output(UInt(WLEN.W))
    val fetchDone = Output(Bool())

  })
  val pc = RegInit("h7fff_fffc".U(WLEN.W))
  val fetchDone = RegInit(false.B) 
  val inst = RegInit(0.U(XLEN.W))

  io.imem.inst_valid := true.B
  val fire = io.imem.inst_valid && io.imem.inst_ready
 
  fetchDone := Mux(fire, true.B, false.B)                //* 取指信号完成标志
//  val alignment = pc % 16.U
  when(fire) {
    pc := io.nextPC
/*
    switch(alignment) {
      is(0.U) {
        inst := io.imem.inst_read(63, 32)
      }
      is(4.U) {
        inst := io.imem.inst_read(95, 64)
      }
      is(8.U) {
        inst := io.imem.inst_read(127, 96)
      }
      is (12.U) {
        inst := io.imem.inst_read(31, 0)
      }
    }
*/
      inst := io.imem.inst_read
  }

  io.imem.inst_req := REQ_READ                    //!false.B
  io.imem.inst_addr := pc.asUInt()
  io.imem.inst_size := SIZE_W

  io.pc := pc
  io.inst := inst
  io.fetchDone := fetchDone
}





































/*
class InstFetch extends Module {
  val io = IO(new Bundle {
//    val imem = new RomIO
    val imem = new CoreInst

    val nextPC = Input(UInt(WLEN.W))
    val pc = Output(UInt(WLEN.W))
    val inst = Output(UInt(WLEN.W))

  })
//  val pc = RegInit("h8000_0000".U(WLEN.W))
  val pc = RegInit("h7fff_fffc".U(WLEN.W))

  val fire = io.imem.inst_valid && io.imem.inst_ready
 
  when(fire) {
    pc := io.nextPC
//    io.inst := io.imem.inst_read
  }  


//  io.imem.en := true.B
//  io.imem.addr := pc.asUInt()

  io.imem.inst_valid := true.B
  io.imem.inst_req := REQ_READ                    //!false.B
  io.imem.inst_addr := pc.asUInt()
  io.imem.inst_size := SIZE_W

  io.pc := pc
//  io.inst := io.imem.rdata(31, 0)
  io.inst := Mux(fire, io.imem.inst_read, 0.U)
}
*/