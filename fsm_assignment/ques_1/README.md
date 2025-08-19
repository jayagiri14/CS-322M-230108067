# Problem 1 (Mealy): Overlapping Sequence Detector

**Goal:** Detect serial bit pattern `1101` on `din` with overlap. Output `y` is a 1-cycle pulse when the last bit arrives.

- **Type:** Mealy
- **Reset:** Synchronous, active-high

## Deliverables
- State diagram with proper fallback edges (overlap)
- Waveform with `din` and `y`; mark detection cycles
- README: Streams tested and expected pulse indices

---

## Streams Tested and Expected Pulse Indices

### Test Stream 1: `1101`
- Input: `1 1 0 1`
- Expected pulse at index: **4**

### Test Stream 2: `1101101` (overlap)
- Input: `1 1 0 1 1 0 1`
- Expected pulses at indices: **4, 7**

### Test Stream 3: `01101101`
- Input: `0 1 1 0 1 1 0 1`
- Expected pulses at indices: **5, 8**

### Test Stream 4: `111101`
- Input: `1 1 1 1 0 1`
- Expected pulse at index: **6**

---

## Files
- `seq_detect_mealy.v`: Mealy sequence detector Verilog code
- `tb_seq_detect_mealy.v`: Testbench for the sequence detector
- `waves/`: VCD/PNG waveform outputs
