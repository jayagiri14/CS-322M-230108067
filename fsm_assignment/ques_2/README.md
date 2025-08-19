# Traffic Light Controller

## Goal
Control North-South (NS) and East-West (EW) traffic lights using a shared 1 Hz tick signal. The controller cycles through four phases:
- NS Green: 5 ticks
- NS Yellow: 2 ticks
- EW Green: 5 ticks
- EW Yellow: 2 ticks

This sequence repeats indefinitely.

## Timing
- NS Green: 5 ticks (5 seconds)
- NS Yellow: 2 ticks (2 seconds)
- EW Green: 5 ticks (5 seconds)
- EW Yellow: 2 ticks (2 seconds)

## Outputs
- `ns_g`, `ns_y`, `ns_r`: North-South green, yellow, red
- `ew_g`, `ew_y`, `ew_r`: East-West green, yellow, red
- For each road, exactly one of {g, y, r} is high at any time.

## Controller Type
- Moore state machine
- Synchronous, active-high reset

## Deliverables
- **State Diagram:** Four states (NS Green, NS Yellow, EW Green, EW Yellow) with transitions on tick and durations as above.
- **Waveform:** Simulation waveform shows each phase lasting the correct number of ticks (5/2/5/2).

## 1 Hz Tick Generation and Verification
- The testbench (`tb_traffic_light.v`) generates a 1 Hz tick by dividing a 100 MHz clock: a counter increments every clock cycle, and `tick` pulses high for one clock cycle every 5 cycles (for simulation speed; in real hardware, use a divider for 1 Hz).
- Verification: The testbench displays the state of all outputs at each tick and writes a VCD file (`dump.vcd`) for waveform viewing. The waveform confirms the correct durations for each phase.

## Files
- `traffic_light.v`: RTL for the traffic light controller
- `tb_traffic_light.v`: Testbench with tick generation and output monitoring
- `waves/`: Place to store simulation waveforms (e.g., `dump.vcd`)

---

For the state diagram and waveform, see the simulation results and your design documentation.
