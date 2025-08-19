
# Verilog FSM Handshake Project

## Goal
Design and simulate two finite state machines (FSMs)—Master and Slave—communicating via a 4-phase handshake protocol with an 8-bit data bus.

### Protocol (per byte):
1. **Master** drives data and raises `req`.
2. **Slave** latches data on `req` and asserts `ack` (holds for 2 cycles).
3. **Master** sees `ack`, drops `req`; **Slave** then drops `ack`.
4. Repeat for 4 bytes. After the last byte, **Master** asserts `done` (1 cycle).

- **Reset:** Synchronous, active-high
- **Clock:** Common `clk`

## Deliverables
- Two state diagrams (Master FSM, Slave FSM)
- Timing diagram (showing `req`, `ack`, and `data`)
- Simulation waveform showing 4 handshakes and the `done` pulse

## Files
- `master_fsm.v`: Master FSM module
- `slave_fsm.v`: Slave FSM module
- `link_top.v`: Top-level integration module
- `tb_link_top.v`: Testbench for the system
