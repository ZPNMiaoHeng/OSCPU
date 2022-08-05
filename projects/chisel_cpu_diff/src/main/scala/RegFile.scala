import chisel3._
import chisel3.util.experimental._
import difftest._

class RegFile extends Module {
  val io = IO(new Bundle {
    val rs1Addr = Input(UInt(5.W))
    val rs2Addr = Input(UInt(5.W))
    val rs1Data = Output(UInt(64.W))
    val rs2Data = Output(UInt(64.W))
    val rdAddr = Input(UInt(5.W))
    val rdData = Input(UInt(64.W))
    val rdEn = Input(Bool())
  })

  val rf = RegInit(VecInit(Seq.fill(32)(0.U(64.W))))

  when (io.rdEn && (io.rdAddr =/= 0.U)) {
    rf(io.rdAddr) := io.rdData;
  }

  io.rs1Data := Mux((io.rs1Addr =/= 0.U), rf(io.rs1Addr), 0.U)
  io.rs2Data := Mux((io.rs2Addr =/= 0.U), rf(io.rs2Addr), 0.U)

  val dt_ar = Module(new DifftestArchIntRegState)
  dt_ar.io.clock  := clock
  dt_ar.io.coreid := 0.U
  dt_ar.io.gpr    := rf

  BoringUtils.addSource(rf(10), "rf_a0")
}

