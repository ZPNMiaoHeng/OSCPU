/**
  ** 使用AXI4总线协议
  ** 使用读、写通道都使用 brust transfer：
  ** 1. brust= 2'b01 -> brust类型为 INCR(ram);
  ** 2. size = 3'b011 -> transfer大小为 8Bytes;
  ** 3. len = 8'b1 -> transfer个数为2;
  */

import chisel3._
import chisel3.util._

import Constant._

class AxiLite2Axi  extends Module {
  val io = IO(new Bundle {
    val out = new AxiIO
    val imem = Flipped(new AxiInst)
    val dmem = Flipped(new AxiData)  //!
  })
  val out = io.out
  val in1 = io.imem
  val in2 = io.dmem  //!

  val inst_ren = WireInit(false.B)
  val data_ren = WireInit(false.B) //!
  val data_wen = WireInit(false.B) //!

  inst_ren := in1.inst_valid && in1.inst_req === REQ_READ                    //* ICache 发出读请求：valid+ req
  data_ren := in2.data_valid && in2.data_req === REQ_READ  //!               //* DCache 发出读请求
  data_wen := in2.data_valid && in2.data_req === REQ_WRITE //!               //* DCache 发出写请求

  val ar_hs = out.ar.ready && out.ar.valid                                    // fire_ar
  val r_hs = out.r.valid && out.r.ready                                       // fire_r
  val aw_hs = out.aw.ready && out.aw.valid                                    //! fire_aw
  val w_hs = out.w.ready && out.w.valid                                       //! fire_w
  val b_hs = out.b.valid && out.b.ready                                       //! fire_r
  
  val r_done = r_hs && out.r.bits.last                                        // 主机得到data和last完成信号
  val w_done = b_hs && out.w.bits.last                                        //! 写请求完成标志

  val r_idle :: r_inst_addr :: r_inst_read :: r_inst_done :: r_data_addr :: r_data_read :: r_data_done :: Nil = Enum(7) //!
  val w_idle :: w_data_addr :: w_data_write :: w_data_resp :: w_data_done :: Nil = Enum(5) //!
  val r_state = RegInit(r_idle)
  val w_state = RegInit(w_idle) //!

//*--------------------------------- State Machine --------------------------------------------------------
    
    //! 写通道状态切换    

  switch (w_state) {
    is(w_idle) {
      when(data_wen) {             // 写使能有效
        w_state := w_data_addr 
      }
    }
    is(w_data_addr) {
      when(aw_hs) {                // 握手成功后，进入write状态
        w_state := w_data_write 
      }
    }
    is(w_data_write) {
      when(w_hs) {                  // w通道完成，进入等待b_resp信号状态
        w_state := w_data_resp 
      }
    }
    is(w_data_resp) {               // 
      when(w_done) {
        w_state := w_data_done
      }
    }
    is(w_data_done) {
      w_state := w_idle
    }
  }

    // 读通道状态切换
    
  switch (r_state) {
    is(r_idle) {
      when(inst_ren) {             // 读使能有效
        r_state := r_inst_addr 
      } .elsewhen (data_ren) {
        r_state := r_data_addr
      }
    }
    is(r_inst_addr) {
      when(ar_hs) {                // 握手成功后，进入read状态
        r_state := r_inst_read 
      }
    }
    is(r_inst_read) {
      when(r_done) {               // 读指令完成标志，进入done状态
        r_state := r_inst_done 
      }
    }
    is(r_inst_done) {              //! 取指完成后进入访存，不过访存优先级应该更高
      when (data_ren) {
        r_state := r_data_addr
      }
      .otherwise {
        r_state := r_idle
      }
    }
    is (r_data_addr) {
      when (ar_hs) {
        r_state := r_data_read
      }
    }
    is (r_data_read) {
      when (r_done) {
        r_state := r_data_done
      }
    }
    is (r_data_done) {
      r_state := r_idle
    }
  }

  val data_ok = RegInit(false.B)
  when (data_wen && w_state === w_data_done) {
    data_ok := true.B
  }
  .elsewhen (!data_wen) {
    data_ok := false.B
  } 
//*--------------------------------- Read Transaction --------------------------------------------------
  val axi_addr = Mux(r_state === r_inst_addr, (in1.inst_addr) & "hffff_fff0".U(32.W),
                  Mux(r_state === r_data_addr, (in2.data_addr) & "hffff_fff0".U(32.W), 0.U))  // Byte alignment

  out.ar.valid := (r_state === r_inst_addr || r_state === r_data_addr)
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
//! write address channel signals
//*--------------------------------- Write Transaction --------------------------------------------------
  val axi_waddr = Mux(r_state === w_data_addr, (in2.data_addr) & "hffff_fff0".U(32.W), 0.U)  // Byte alignment

  out.aw.valid        := w_state === w_data_addr
  out.aw.bits.addr    := axi_waddr
  out.aw.bits.prot    := "b000".U
  out.aw.bits.id      := 0.U
  out.aw.bits.user    := 0.U
  out.aw.bits.len     := 0.U
  out.aw.bits.size    := "b11".U
  out.aw.bits.burst   := "b01".U                           
  out.aw.bits.lock    := 0.U
  out.aw.bits.cache   := "b0010".U    //"b1111".U
  out.aw.bits.qos     := 0.U

  // write data channel signals
  out.w.valid         := w_state === w_data_write
  out.w.bits.data     := Mux(data_ok, in2.data_write(127,64), in2.data_write(63, 0))
  out.w.bits.strb     := in2.data_strb   //!掩码
  out.w.bits.last     := true.B

  out.b.ready         := true.B

  /* AXI <-> IF */
  in1.inst_ready := (r_state === r_inst_done)  // 指令读取完成
  in2.data_ready := (r_state === r_data_done) || (w_state === w_data_done && data_ok)            //! Load and Store
  
  val inst_read_h = RegInit(0.U(64.W))
  val inst_read_l = RegInit(0.U(64.W))
  val data_read_h = RegInit(0.U(64.W))
  val data_read_l = RegInit(0.U(64.W))

  when (r_hs) {
    when (out.r.bits.last) {
      inst_read_h := out.r.bits.data
      data_read_h := out.r.bits.data
    }
    .otherwise {
      inst_read_l := out.r.bits.data
      data_read_l := out.r.bits.data
    }
  }
  
  val alignment = in2.data_addr % 16.U                              // 16字节对齐（总线一次读取128bits）:接core时2使用
//  in1.inst_read := Cat(inst_read_h, inst_read_l) >> alignment * 8.U
  in2.data_read := Cat(data_read_h, data_read_l) >> alignment * 8.U

  in1.inst_read := Cat(inst_read_h, inst_read_l)
}

