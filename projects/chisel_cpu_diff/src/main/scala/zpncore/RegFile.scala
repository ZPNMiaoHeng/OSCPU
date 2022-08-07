import chisel3._
import chisel3.util.experimental._
import difftest._

class RegFile extends Module {
  val io = IO(new Bundle {
    val rs1Data = Output(UInt(64.W))
    val rs2Data = Output(UInt(64.W))
    val rdData = Input(UInt(64.W))
    val fetchDone = Input(Bool())

    val ctrl = Flipped(new RegCtrlIO)
  })

  val rf = RegInit(VecInit(Seq.fill(32)(0.U(64.W))))

  when (io.ctrl.rdEn && (io.ctrl.rdAddr =/= 0.U) && io.fetchDone) {
    rf(io.ctrl.rdAddr) := io.rdData
  }

  io.rs1Data := Mux((io.ctrl.rs1Addr =/= 0.U && io.ctrl.rs1En =/= 0.U), rf(io.ctrl.rs1Addr), 0.U)
  io.rs2Data := Mux((io.ctrl.rs2Addr =/= 0.U && io.ctrl.rs2En =/= 0.U), rf(io.ctrl.rs2Addr), 0.U)

  val dt_ar = Module(new DifftestArchIntRegState)
  dt_ar.io.clock  := clock
  dt_ar.io.coreid := 0.U
  dt_ar.io.gpr    := rf

  BoringUtils.addSource(rf(10), "rf_a0")
}
