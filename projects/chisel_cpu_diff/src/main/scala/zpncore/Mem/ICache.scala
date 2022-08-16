/**
  ** ICache: 两路组相连、年龄替换算法
  */
import chisel3._
import chisel3.util._

import Constant._
import utils._

class ICache extends Module {
  val io = IO(new Bundle {
    val imem = Flipped(new CoreInst)
    val out  = new AxiInst
    )}
}
  val in = io.imem
  val out = io.out
  val cacheLineNum = 128
//*way0 and way1
  val way0Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way0V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way0Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))
  val way1Tag = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(21.W))))
  val way1V = RegInit(VecInit(Seq.fill(cacheLineNum)(false.B)))
  val way1Off = RegInit(VecInit(Seq.fill(cacheLineNum)(0.U(4.W))))

  val s_IDLE :: s_READ_CACHE :: s_FILL :: s_FILL_WAIT :: Nil = Enum(4)
  val state = RegInit(s_IDLE)

  val reqAddr = RegInit(0.U(32.W))
  val validAddr = Mux(state === s_READ_CACHE), in.inst_addr, reqAddr)  //* 更新inst

  val reqTag = validAddr(31,11)
  val reqIndex = validAddr(10, 4)
  val reqOff = validAddr( 3, 0)

  val way0Hit = way0V(reqIndex) && (way0Tag(reqIndex) === reqTag)
  val way1Hit = way1V(reqIndex) && (way1Tag(reqIndex) === reqTag)
  val cacheHit = way0Hit || way1Hit

  val cache_data_out = Wire(UInt(RW_DATA_WIDTH.W))

  val inst_valid  = WireInit(false.B)
  val inst_req    = WireInit(false.B)
  val inst_addr   = WireInit(0.U(32.W))
  val inst_size   = WireInit(0.U(2.W))
  val inst_read   = MuxLookup(req_offset(3, 2), 0.U, Array(
                      "b00".U -> cache_data_out( 31, 0),
                      "b01".U -> cache_data_out( 63,32),
                      "b10".U -> cache_data_out( 95,64),
                      "b11".U -> cache_data_out(127,96),
                    ))
  val inst_ready  = state === s_READ_CACHE && cacheHit               //* 从cache取到数据

  val cache_fill  = RegInit(false.B)
  val cache_wen   = RegInit(false.B)
  val cache_wdata = RegInit(0.U(RW_DATA_WIDTH.W))
//-------- ICache SFM --------------------------------
  switch (state) {
    is (s_IDLE) {
      when (in.inst_valid) {
        state := s_READ_CACHE
      }
    }

    is (s_READ_CACHE) {
      when (in.inst_valid) {
        reqAddr := in.inst_addr
        when (cacheHit) {
          state    := s_READ_CACHE
        }
        .otherwise {
          state    := s_FILL
        }
      }
      .otherwise {
        state := s_IDLE
      }
    }

    is (s_FILL) {
      when (~cache_fill) {                           //* 去总线上读取数据
        state       := s_FILL
        out.inst_valid  := true.B
        out.inst_req    := REQ_READ
        out.inst_addr   := req_addr
        out.inst_size   := SIZE_W
      }
      .otherwise {
        state       := s_FILL_WAIT
      }
      when (out.inst_ready) {
        cache_fill  := true.B
        cache_wen   := true.B
        cache_wdata := out.inst_read
        inst_valid  := false.B
      }
    }

    is (s_FILL_WAIT) {
      /*替换算法*/
      cache_fill        := false.B
      cache_wen         := false.B
      valid(req_index)  := true.B
      tag(req_index)    := req_tag
      offset(req_index) := req_offset
      state             := s_READ_CACHE
    }
  }