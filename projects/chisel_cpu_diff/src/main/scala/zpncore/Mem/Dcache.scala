/**
  ** DCache: 
  ** 1. 两路组相连；way=2, wayDataSize = 2K, wayCacheLineNum = 128；
  ** 2. 年龄替换算法；写入cacheline为1，另一个清零。替换age=0的cacheline；
  ** 3. 阻塞式状态机：只有当前指令完成才能读取下一条；
  ** 4. 写回写分配策略，只有cacheLine发生改变时，才会通过总线写回；
  ** 5. 添加dirty寄存器：
  */

import chisel3._
import chisel3.util._

import Constant._
import utils._

class DCache extends Module {
  val io = IO(new Bundle {
    val imem = Flipped(new CoreData)
    val out  = new AxiData
  })

  val in = io.imem
  val out = io.out
  val cacheLineNum = 128
//  val cacheWData = RegInit(0.U(128.W))    //* 写 cacheLine
//  val cacheRData = WireInit(0.U(128.W))    //* 读 cacheLine
//  val cacheWEn = WireInit(false.B)
//  val fillCacheDone = WireInit(false.B)
//*way0 and way1
  val way0V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way0Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way0Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way0Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way0Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))

  val way1V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way1Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way1Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way1Age = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  val way1Dirty = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(1.W))))
  
//*------------------------------------------------------------------
  val validAddr = in.data_addr
  val reqTag = validAddr(31,11)
  val reqIndex = validAddr(10, 4)
  val reqOff = validAddr(3, 0)

  val way0Hit = way0V(reqIndex) && (way0Tag(reqIndex) === reqTag)  //* 两路组相连 Hit情况
  val way1Hit = way1V(reqIndex) && (way1Tag(reqIndex) === reqTag)
//  val cacheRIndex = Mux(way0Hit, Cat(0.U(1.W), reqIndex), Cat(1.U(1.W), reqIndex))
//  val cacheWIndex = WireInit(0.U(8.W))
  val cacheHitEn = way0Hit || way1Hit
  val cacheDirtyEn = (way0Hit && way0Dirty(reqIndex)) || (way1Hit && way1Dirty(reqIndex))

  val req = Module(new S011HD1P_X32Y2D128)
  req.io.CLK := clock
  req.io.CEN := true.B
  req.io.WEN := cacheWEn
  req.io.A   := Mux(!cacheWEn, cacheRIndex , cacheWIndex)
  req.io.D   := cacheWData
  cacheRData := req.io.Q

//*------------------------------ DCache Machine --------------------------------
  val s_CACHE_IDLE :: s_CACHE_HIT :: s_CACHE_DIRTY :: s_CACHE_WRITE :: s_CACHE_READ :: s_CACHE_DONE :: Nil = Enum(6)
  val state = RegInit(s_IDLE)

  switch (state) {
    is(s_IDLE) {
      when (in.data_valid) {
        state := s_CACHE_HIT
    }
  }
    is(s_CACHE_HIT) {
      when (cacheHitEn) {
        state := s_IDLE
      } .otherwise { 
        state := s_CACHE_DIRTY
    }
  }
    is(s_CACHE_DIRTY) {
      when(cacheDirtyEn) {
        state := s_CACHE_WRITE
      } .otherwise {
        state := s_CACHE_READ
      }
    }
     is(s_CACHE_WRITE) {
      when( out.data_ready) {      //*写入完成信号
        state := s_CACHE_READ
      }
    }
    is(s_CACHE_READ) {
      when( out.data_ready ) {    //* 读取完成信号
        state := s_CACHE_DONE
      }
    }
    is(s_CACHE_DONE) {
      state := s_CACHE_IDLE
    }
}

//*----------------------------- control signals --------------------------------
//  val sHitEn = state === s_CACHE_HIT
//  val sDirtyEn = state === s_CACHE_Dirty

  val sWriteEn = state === s_CACHE_WRITE   //* 将这个CacheLIne中数据写到存储器中

  val sReadEn = state === s_CACHE_READ     //* 将存储器中对应位置写入到cacheLine中
  val axiEn = sWriteEn || sReadEn
  out.data_valid := axiEn
  out.data_req := Mux(sWriteEn, REQ_WRITE, REQ_READ)
  out.data_addr := Mux(axiEn, validAddr, 0.U)
  out.data_size := Mux(axiEn, SIZE_W, 0.U) //??
  out.data_strb := Mux(sWriteEn, in.data_strb, 0.U)
  out.data_write := Mux(sWriteEn, , 0.U)


  val sDoneEn = state === s_CACHE_DONE
  val rData = Mux(sDoneEn, out.data_read, 0.U)
  in.data_ready := sDoneEn
  in.data_read := LookupTreeDefault(reqOff(3, 2), 0.U , List(
    "b00".U -> rData(31 , 0 ),
    "b01".U -> rData(63 , 32),
    "b10".U -> rData(95 , 64),
    "b11".U -> rData(127, 96)
  ))
