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
    val cnt = Output(UInt(4.W))
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

    val cnt = Counter(16)
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
    r.bits.data := Mux(sR && io.fpga.en, "h00000113_00000093".U, "h00000013_00000013".U)
    // r.bits.data := Mux(sR && io.fpga.en, "h00000113_00000093".U, 0.U)
    r.bits.resp := DontCare
    r.bits.last := DontCare


    // 80000000:	00000093          	li	ra,0
    // 80000004:	00000113          	li	sp,0
    // 80000008:	00208733          	add	a4,ra,sp
    // 8000000c:	00000393          	li	t2,0
}

