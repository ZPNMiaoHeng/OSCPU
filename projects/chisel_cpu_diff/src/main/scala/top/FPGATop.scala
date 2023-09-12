import chisel3._
import chisel3.util._

// case class ZpnCoreConfig (
//   FPGAPlatform: Boolean = true,
//   EnableDebug: Boolean = Settings.get("EnableDebug"),
//   EnhancedLog: Boolean = true 
// )

// class FPGAIO(implicit val p: ZpnCoreConfig) extends Bundle {
class FPGAIO extends Bundle {
    val en = Input(Bool())
    // val inst = Valid(Input(UInt(32.W)))
    val cnt = Output(UInt(6.W))
    // val cnt_top = Output(Bool())
}

class FPGATop extends Module {
  val io = IO(new Bundle {
    val fpga = new FPGAIO
  })

  val zpncore = Module(new SimTop)

  zpncore.io.memAXI_0.aw <> DontCare // top.io.out.aw
  zpncore.io.memAXI_0.w  <> DontCare // top.io.out.w
  zpncore.io.memAXI_0.b  <> DontCare // top.io.out.b
    val s_IDLE :: s_AR :: s_R :: Nil = Enum(3)
    val state = RegInit(s_IDLE)

    val cnt = Counter(64)
    when(io.fpga.en) {
        cnt.inc()
    }

    val cnt_value = cnt.value
    val ar = zpncore.io.memAXI_0.ar
    val r = zpncore.io.memAXI_0.r
    io.fpga.cnt := cnt_value

    switch(state) {
        is(s_IDLE) {
            when(ar.valid) {
                state := s_AR
            }
        }

        is(s_AR) {
            when(ar.ready) {
                state := s_R
            }
        }

        is(s_R) {
            when(r.valid) {
                state := s_IDLE
            }
        }
    }
    val sAR = state === s_AR
    val sR = state === s_R
    ar.ready := sAR && ar.bits.addr === ("h8000_0000".U)
    r.valid := sR && io.fpga.en
    r.bits.data := Mux(sR && io.fpga.en, "h00000393_00208733_00000113_00000093".U, 0.U)
    r.bits.resp := DontCare
    r.bits.last := DontCare


    // 80000000:	00000093          	li	ra,0
    // 80000004:	00000113          	li	sp,0
    // 80000008:	00208733          	add	a4,ra,sp
    // 8000000c:	00000393          	li	t2,0
}


/* 
    一次输入端口也是太多,需要129
*/

// class FPGAIO(implicit val p: ZpnCoreConfig) extends Bundle {
//     // val en = Input(Bool())
//     val inst = Valid(Input(UInt(128.W)))
//     val cnt = Output(UInt(6.W))
//     // val cnt_top = Output(Bool())
// }

// class FPGATop_in extends Module {
//   val io = IO(new Bundle {
//     val fpga = new FPGAIO
//     // val axi = Flipped(new AxiIO)
//   })

//   val zpncore = Module(new SimTop)

//     // zpncore.io.memAXI_0 <> io.axi
//   zpncore.io.memAXI_0.aw <> Dontcare // top.io.out.aw
//   zpncore.io.memAXI_0.w  <> Dontcare // top.io.out.w
//   zpncore.io.memAXI_0.b  <> Dontcare // top.io.out.b
// //   zpncore.io.memAXI_0.ar <> top.io.out.ar
// //   zpncore.io.memAXI_0.r  <> top.io.out.r

//     // val counter = RegInit(0.U(6.W))
//     val cnt = Counter(64)
//     when(io.fpga.inst.valid) {
//         cnt.inc()
//     }

//     val cnt_value = cnt.value
//     val ar = zpncore.io.memAXI_0.ar
//     val r = zpncore.io.memAXI_0.r
//     io.fpga.cnt := cnt_value
//     when(zpncore.io.memAXI_0.ar.valid) {
//         when(zpncore.io.memAXI_0.ar.addr == ("h8000_0000".U + 4 * cnt_value)) {   // Firsr inst
//             ar.ready := true.B
//         }
//     }
//     when(io.fpga.io.inst.valid) {
//         r.valid := io.fpga.io.inst.valid
//         r.
//     }

// }
