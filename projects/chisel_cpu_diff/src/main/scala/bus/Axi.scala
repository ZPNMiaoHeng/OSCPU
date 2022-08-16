import chisel3._
import chisel3.util._

import Constant._

class AxiLite2Axi  extends Module {
  val io = IO(new Bundle {
    val out = new AxiIO
    val imem = Flipped(new AxiInst)
 //   val dmem = Flipped(new AxiData)
  })
  val out = io.out
  val in1 = io.imem
//  val in2 = io.dmem

  val inst_ren = WireInit(false.B)
  inst_ren := in1.inst_valid && in1.inst_req === REQ_READ                    // core 指定读取valid+ req

  val ar_hs = out.ar.ready && out.ar.valid                                     // fire_ar
  val r_hs = out.r.ready && out.r.valid                                       // fire_r
  
  val r_done = r_hs && out.r.bits.last                                        //* 主机得到data和last完成信号

  val r_idle :: r_inst_addr :: r_inst_read :: r_inst_done :: Nil = Enum(4)
  val r_state = RegInit(r_idle)

    // ------------------State Machine------------------TODO
    
    // 写通道状态切换    

    // 读通道状态切换
    
  switch (r_state) {
    is(r_idle) {
      when(inst_ren) {             //* 读使能有效
        r_state := r_inst_addr 
      }
    }
    is(r_inst_addr) {
      when(ar_hs) {                //* 握手成功后，进入read状态
        r_state := r_inst_read 
      }
    }
    is(r_inst_read) {
      when(r_done) {               //* 读指令完成标志，进入done状态
        r_state := r_inst_done 
      }
    }
    is(r_inst_done) {
      r_state := r_idle
    }
  }

    // ------------------Write Transaction------------------
  val axi_addr = Mux(r_state === r_inst_addr, (in1.inst_addr) & "hffff_fff0".U(32.W), 0.U)  // Byte alignment
//  val axi_addr = (in1.inst_addr + 4.U) & "hffff_fff0".U(32.W) // Byte alignment

  out.ar.valid := (r_state === r_inst_addr)
  out.ar.bits.addr := axi_addr
  out.ar.bits.len := 1.U
  out.ar.bits.size := "b11".U

  out.ar.bits.prot    := "b000".U
  out.ar.bits.id      := 0.U
  out.ar.bits.user    := 0.U
  out.ar.bits.burst   := "b01".U
  out.ar.bits.lock    := 0.U
  out.ar.bits.cache   := "b0010".U
  out.ar.bits.qos     := 0.U

  out.r.ready := true.B
//! write

// write address channel signals
  out.aw.valid        := false.B     //w_state === w_data_addr
  out.aw.bits.addr    := 0.U    //axi_waddr
  out.aw.bits.prot    := "b000".U
  out.aw.bits.id      := 0.U
  out.aw.bits.user    := 0.U
  out.aw.bits.len     := 0.U
  out.aw.bits.size    := 0.U//"b11".U
  out.aw.bits.burst   := 0.U//"b01".U
  out.aw.bits.lock    := 0.U
  out.aw.bits.cache   := 0.U//"b0010".U
  out.aw.bits.qos     := 0.U

  // write data channel signals
  out.w.valid         := false.B   //w_state === w_data_write
  out.w.bits.data     := 0.U  //Mux(data_ok, in2.data_write(127,64), in2.data_write(63, 0))
  out.w.bits.strb     := 0.U  //in2.data_strb
  out.w.bits.last     := false.B   //true.B

  out.b.ready         := false.B//true.B

  /* AXI <-> IF */
  in1.inst_ready := (r_state === r_inst_done)  //* 指令读取完成
  
  val inst_read_h = RegInit(0.U(64.W))
  val inst_read_l = RegInit(0.U(64.W))

  when (r_hs) {
    when (out.r.bits.last) {
      inst_read_h := out.r.bits.data
    }
    .otherwise {
      inst_read_l := out.r.bits.data
    }
  }
  
  val alignment = in1.inst_addr % 16.U                              //* 16字节对齐（总线一次读取128bits）
  in1.inst_read := Cat(inst_read_h, inst_read_l) >> alignment * 8.U

}