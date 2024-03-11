/**
  ** ICache: 
  ** 1. 两路组相连；way=2, wayDataSize = 2K, wayCacheLineNum = 128;
  ** 2. 年龄替换算法；写入cacheline为1，另一个清零。替换age=0的cacheline;
  ** 3. 阻塞式状态机：只有当前指令完成才能读取下一条;
  */
import chisel3._
import chisel3.util._

import Constant._
import utils._

class ICache extends Module {
  val io = IO(new Bundle {
    val imem = Flipped(new CoreInst)
    val out  = new AxiInst
  })

  val in = io.imem
  val out = io.out
  val cacheLineNum = 128
  val cacheWData = RegInit(0.U(128.W))     //* 写 cacheLine
  val cacheRData = WireInit(0.U(128.W))    //* 读 cacheLine
  val cacheWEn = WireInit(false.B)
  val fillCacheDone = WireInit(false.B)
//*way0 and way1
  val way0V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way0Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way0Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way0Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val way1V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way1Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way1Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way1Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  
  val s_IDLE :: s_READ_CACHE :: s_AXI_FILL :: s_FILL_CACHE :: Nil = Enum(4)
  val state = RegInit(s_IDLE)

  val validAddr = in.inst_addr
  // val preAddr = RegNext(in.inst_addr)
  val reqTag = validAddr(31,11)
  val reqIndex = validAddr(10, 4)
  val reqOff = validAddr(3, 0)

  // val sameCachelineEn = (preAddr(31, 4) === validAddr(31, 4))

  val way0Hit = way0V(reqIndex) && (way0Tag(reqIndex) === reqTag)  //* 两路组相连 Hit情况
  val way1Hit = way1V(reqIndex) && (way1Tag(reqIndex) === reqTag)
  val cacheRIndex = Mux(way0Hit, Cat(0.U(1.W), reqIndex), Cat(1.U(1.W), reqIndex))
  val cacheWIndex = WireInit(0.U(8.W))
  val cacheHitEn = way0Hit || way1Hit

  val req = Module(new S011HD1P_X32Y2D128)
  req.io.CLK := clock
  req.io.CEN := true.B
  req.io.WEN := cacheWEn
  req.io.A   := Mux(!cacheWEn, cacheRIndex , cacheWIndex)
  req.io.D   := cacheWData
  cacheRData := req.io.Q

//*-------------------------------------- Cache FSM -----------------------------------------------
  switch(state) {
    is(s_IDLE) {
      when(in.inst_valid) {
        state := s_READ_CACHE
      }
    }

    is(s_READ_CACHE) {
      when(cacheHitEn) {
        state := s_IDLE
      } .otherwise {
        state := s_AXI_FILL
      }
    }

    is(s_AXI_FILL) {
      when(out.inst_ready) {
        state := s_FILL_CACHE
      }
    }

    is(s_FILL_CACHE) {
        state := RegNext(s_READ_CACHE)
    }
  }
//*------------------------------------------------------------------------------------------//
  val sReadEn = state === s_READ_CACHE                             // 在Cache中读取相对应的指令
  val rData = Mux(sReadEn && cacheHitEn, cacheRData, 0.U)
  // in.inst_ready := Mux(sameCachelineEn, true.B, sReadEn) && cacheHitEn  //*同一个cacheline，不需要访问sram
  in.inst_ready := sReadEn && cacheHitEn
  in.inst_read := LookupTreeDefault(reqOff(3, 2), 0.U , List(
    "b00".U -> rData(31 , 0 ),
    "b01".U -> rData(63 , 32),
    "b10".U -> rData(95 , 64),
    "b11".U -> rData(127, 96)
  ))
  
  val sAxiEn = state === s_AXI_FILL                                 // 从总线上读回来的数据
  out.inst_valid := sAxiEn
  out.inst_req := Mux(sAxiEn, REQ_READ, 0.U)
  out.inst_addr := Mux(sAxiEn, validAddr, 0.U)
  out.inst_size := Mux(sAxiEn, SIZE_W, 0.U)
  cacheWData := Mux(sAxiEn && out.inst_ready, out.inst_read, 0.U)

  /* cacheLine、set */
  val sFillEn = state === s_FILL_CACHE

  val ageWay0En = (way0Age(reqIndex) === 0.U) && sFillEn        //* 年龄替换算法
  val ageWay1En = (way1Age(reqIndex) === 0.U) && sFillEn        //* 年龄替换算法
  val cacheLineWay = Mux(ageWay0En, 0.U, 1.U)                 //* 0.U->way0, 1.U->way1, way0优先级更高
  way0Age(reqIndex) := Mux(ageWay0En, 1.U, 0.U)
  way1Age(reqIndex) := Mux(ageWay0En, 0.U, 1.U)

  cacheWEn := sFillEn
  cacheWIndex := Cat(cacheLineWay, reqIndex)                    // cacheWIndex(7:0) = cacheLineWay ## set(6:0)
  when(ageWay0En) {                                             //* 更新wayV与wayTag
    way0Tag(reqIndex) := reqTag
    way0V(reqIndex) := true.B
  } .elsewhen(ageWay1En) {
    way1Tag(reqIndex) := reqTag
    way1V(reqIndex) := true.B
  }
}

class S011HD1P_X32Y2D128 extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val Q   = Output(UInt(128.W))
    val CLK = Input(Clock())
    val CEN = Input(Bool())
    val WEN = Input(Bool())
    val A   = Input(UInt(8.W))
    val D   = Input(UInt(128.W))
  })
  addResource("/vsrc/S011HD1P_X32Y2D128.v")
}