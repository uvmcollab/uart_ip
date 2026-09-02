# Design Specification
# UART Core (Universal Asynchronous Receiver Transmitter)
# Revision 2.0

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | — | Initial release |
| 2.0 | 2026-09-02 | Reset specification added; FIFO overflow/underflow behavior defined; oversampling algorithm refined; TX FIFO–Transmitter interaction clarified; signal descriptions added; acceptance criteria corrected |

---

## 1. Purpose

The purpose of this project is to design and implement a UART (Universal Asynchronous Receiver Transmitter) core using Verilog HDL or SystemVerilog targeting FPGA devices.

The UART core shall provide full-duplex asynchronous serial communication through transmit (TX) and receive (RX) interfaces.

The implementation shall be fully synthesizable and operate using a single system clock.

---

## 2. Scope

The design shall include the following functional blocks:

- Baud Rate Generator
- UART Receiver
- UART Transmitter
- Receive FIFO (RX FIFO)
- Transmit FIFO (TX FIFO)
- System Interface Logic

The following features are outside the scope of this project:

- RS-232 electrical conversion
- Software-programmable configuration registers
- Parity generation and checking
- RTS/CTS flow control
- Framing error detection
- Break detection

---

## 3. Reference Architecture

### 3.1 Reference Block Diagram

Figure 1 shows the expected functional decomposition of the UART subsystem.

![Figure 1 - UART Core Reference Architecture](./images/uart_reference_arch.png)

---

### 3.2 Architecture Overview

The UART subsystem shall be composed of the following functional blocks:

#### Baud Rate Generator

Generates the enable tick signal (`s_tick`) used by both the UART receiver and UART transmitter.

The generated tick shall operate at:

```text
16 × BAUD_RATE
```

and shall be used as an enable signal rather than as a separate clock.

---

#### UART Receiver

Receives serial data from the RX input and reconstructs parallel data bytes using a 16× oversampling mechanism.

The receiver shall:

- Detect the start bit.
- Recover serial data bits by sampling at the estimated midpoint of each bit.
- Verify the stop bit interval.
- Assert `rx_done_tick` for one clock cycle upon successful frame reception.

---

#### RX FIFO

Provides temporary storage for received data bytes.

The RX FIFO decouples the UART reception rate from the processing rate of the external system and reduces the possibility of data overrun.

---

#### UART Transmitter

Converts parallel data bytes into UART serial frames and transmits them on the TX output.

The transmitter shall:

- Generate start bits.
- Transmit data bits LSB first.
- Generate stop bits.
- Assert `tx_done_tick` for one clock cycle upon frame completion.

---

#### TX FIFO

Provides temporary storage for data waiting to be transmitted.

The TX FIFO decouples the UART transmission rate from the data production rate of the external system.

---

#### External System Interface

Represents the interface between the UART subsystem and the system using the UART core.

The external system shall:

- Read data from the RX FIFO.
- Write data into the TX FIFO.
- Monitor FIFO status signals.

---

### 3.3 Reference Connectivity

The expected functional signal flow is:

```text
RX → UART Receiver → RX FIFO → External System Interface

External System Interface → TX FIFO → UART Transmitter → TX
```

The Baud Rate Generator provides timing information to both serial communication subsystems:

```text
Baud Rate Generator → s_tick → UART Receiver

Baud Rate Generator → s_tick → UART Transmitter
```

---

> **Note:**
>
> The architecture shown in Figure 1 represents the expected functional decomposition of the UART subsystem.
>
> Internal implementation details, including finite-state machines, ASMD descriptions, datapath organization, counters, shift registers, synchronization structures, and module partitioning remain the responsibility of the designer.
>
> Designers are free to choose the internal implementation provided that all requirements defined in this specification are satisfied.

---

## 4. Communication Parameters

### Architectural Requirement

The UART architecture shall be parameterizable in order to support different clock frequencies and baud rates.

At minimum, the design shall provide parameters equivalent to:

```systemverilog
parameter CLK_FREQ;
parameter BAUD_RATE;
```

where:

```text
CLK_FREQ  = System clock frequency in Hz
BAUD_RATE = Desired communication speed in bps
```

Dynamic reconfiguration during runtime is not required. Reconfiguration may be performed at synthesis or elaboration time.

---

### Reference Configuration

The following configuration shall be used for development, simulation, verification, and project evaluation:

| Parameter | Value |
|-----------|-------|
| Clock Frequency | 100 MHz |
| Baud Rate | 19,200 bps |
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |
| Bit Order | LSB First |
| Mode | Full Duplex |
| Oversampling | 16× |

All mandatory verification scenarios shall be executed using this configuration.

---

### Frame Format

```text
Idle  Start   D0 D1 D2 D3 D4 D5 D6 D7   Stop  Idle
 1      0      <------ Data ------>      1      1
```

Where:

```text
D0 = LSB
D7 = MSB
```

The line shall remain at logic 1 (idle) until the next start bit.

---

## 5. System Clock and Reset

### Clock Requirement

The design shall operate using a single system clock.

The following are not allowed:

- Derived clock generation
- Clock gating
- Additional clock domains

All logic shall be synchronous to the system clock.

---

### Reference Clock

The target platform provides a reference clock of:

```text
100 MHz
```

All verification and acceptance tests shall use this frequency.

---

### Reset

The design shall implement a **synchronous, active-high** reset signal named `reset`.

When `reset` is asserted:

- All state machines shall return to their idle states.
- All internal counters and registers shall be cleared.
- Both FIFOs shall be emptied (read and write pointers reset to zero).
- The TX output shall be driven to logic 1 (idle line level).

`reset` shall be synchronous: its effect shall be registered on the rising edge of `clk`.

---

## 6. Baud Rate Generator

### Function

The baud-rate generator shall generate a periodic enable signal named:

```text
s_tick
```

used by the UART oversampling mechanism.

---

### Tick Frequency

The frequency of the generated signal shall be:

```text
s_tick frequency = 16 × BAUD_RATE
```

For the reference configuration:

```text
BAUD_RATE = 19,200 bps

s_tick frequency = 307,200 Hz
```

---

### Parameterization Requirement

The divisor used to generate `s_tick` shall be derived from the design parameters using the following relationship:

```text
DIVISOR = round( CLK_FREQ / (16 × BAUD_RATE) ) - 1
```

Where `round()` denotes rounding to the nearest integer.

For the reference configuration:

```text
CLK_FREQ  = 100,000,000 Hz
BAUD_RATE = 19,200 bps

CLK_FREQ / (16 × BAUD_RATE) = 325.52  →  round to 326

DIVISOR = 326 - 1 = 325
```

The implementation shall use a modulo counter that counts from `0` to `DIVISOR` inclusive. When the counter reaches `DIVISOR`, it shall reset to `0` and assert `s_tick` for exactly one clock cycle.

Hard-coded divisors tied to a specific clock frequency or baud rate shall not be used.

---

### Requirements

- `s_tick` shall remain asserted for exactly one clock cycle per period.
- `s_tick` shall be used as an enable pulse and not as a generated clock.

---

### Interface

#### Inputs

```text
clk
reset
```

#### Outputs

```text
s_tick
```

---

## 7. UART Receiver

### Function

The UART receiver shall:

- Detect the beginning of a frame.
- Recover serial data using 16× oversampling.
- Reconstruct the received byte.
- Indicate successful frame reception via `rx_done_tick`.

---

### Input Synchronization

The RX signal is asynchronous with respect to the system clock.

A two flip-flop synchronizer shall be implemented before the RX signal is used internally. All subsequent receiver logic shall operate on the synchronized version of the RX signal.

---

### Reception Algorithm

#### Start Bit Detection

The receiver shall monitor the synchronized RX line while in the idle state.

Upon detecting a falling edge (transition from `1` to `0`), the receiver shall begin the start bit verification sequence:

1. Wait **8 `s_tick` pulses** from the falling edge.
2. Sample the RX line at the 8th tick (estimated center of the start bit).
3. If RX is still `0`, confirm the start bit as valid and proceed to data reception.
4. If RX is `1` at the 8th tick, treat the event as a glitch and return to idle.

---

#### Data Reception

After confirming the start bit, the receiver shall recover eight data bits as follows:

- For each data bit, wait **16 `s_tick` pulses** from the previous sampling point.
- Sample RX at the 16th tick (estimated center of the bit period).
- Shift the sampled bit into the data register, LSB first (D0 received first).

This process shall repeat for all eight data bits (D0 through D7).

---

#### Stop Bit Verification

After receiving the eighth data bit:

- Wait **16 `s_tick` pulses**.
- Sample RX at the 16th tick.
- If RX is `1`, the stop bit is valid: assert `rx_done_tick` for one clock cycle.
- If RX is `0`, the stop bit is invalid: discard the received byte, do **not** assert `rx_done_tick`, and return to idle.

---

### Reception Complete Indicator

Upon successful reception of a valid frame:

```text
rx_done_tick
```

shall be asserted for **exactly one clock cycle**.

`rx_done_tick` shall not be asserted if the stop bit verification fails.

---

### Data Output

```text
dout[7:0]
```

shall hold the received byte. The value of `dout` shall remain stable until the next valid frame is received.

---

## 8. UART Transmitter

### Function

The UART transmitter shall convert an 8-bit parallel word into a serial UART frame and transmit it through the TX line.

---

### Transmission Start

Transmission shall begin when the internal signal:

```text
tx_start
```

is asserted for one clock cycle by the system interface logic.

`tx_start` is an **internal** signal. It is not exposed at the top-level interface. The system interface logic (see Section 3.2) is responsible for asserting `tx_start` when the TX FIFO contains data and the transmitter is idle.

While a transmission is in progress, any assertion of `tx_start` shall be ignored. The TX FIFO and system interface logic are responsible for ensuring transmissions are sequenced correctly.

---

### Transmission Sequence

#### Idle State

```text
tx = 1
```

The TX line shall be held at logic 1 whenever the transmitter is idle.

---

#### Start Bit

```text
tx = 0
```

for one full bit period (16 `s_tick` pulses).

---

#### Data Bits

Transmit eight bits, D0 through D7, where:

```text
D0 = LSB
```

Each data bit shall remain valid for one full bit interval (16 `s_tick` pulses).

---

#### Stop Bit

```text
tx = 1
```

for one full bit interval (16 `s_tick` pulses).

---

### Completion Indicator

Upon completion of a transmission:

```text
tx_done_tick
```

shall be asserted for **exactly one clock cycle**.

After asserting `tx_done_tick`, the transmitter shall return to idle and shall be ready to accept a new `tx_start`.

---

## 9. Receive FIFO

### Characteristics

- Data width: 8 bits
- Depth: 16 entries
- Reset state: empty (`rx_empty = 1`, `rx_full = 0`)

---

### Write Operation

The FIFO shall automatically store received data whenever:

```text
rx_done_tick = 1
```

**Overflow behavior:** If `rx_done_tick` is asserted while `rx_full = 1`, the incoming byte shall be **discarded**. The FIFO contents shall remain unchanged. No error flag is required beyond the existing `rx_full` signal, which the external system can monitor to avoid this condition.

---

### Read Operation

Read operations shall be controlled by the external system using the `rx_read` signal.

`rx_read` shall be treated as a **single-cycle pulse**. When asserted for one clock cycle, the FIFO shall present the next byte on `rx_data` on the following clock cycle and advance its read pointer.

Asserting `rx_read` while `rx_empty = 1` shall have no effect.

---

### Status Signals

```text
rx_empty  — asserted when the FIFO contains no data
rx_full   — asserted when the FIFO has reached its maximum capacity (16 entries)
```

---

## 10. Transmit FIFO

### Characteristics

- Data width: 8 bits
- Depth: 16 entries
- Reset state: empty (`tx_empty = 1`, `tx_full = 0`)

---

### Write Operation

Write operations shall be controlled by the external system using the `tx_write` signal.

`tx_write` shall be treated as a **single-cycle pulse**. When asserted for one clock cycle, the byte present on `tx_data` shall be written into the FIFO.

**Overflow behavior:** If `tx_write` is asserted while `tx_full = 1`, the incoming byte shall be **discarded**. The external system is responsible for monitoring `tx_full` before writing.

---

### Read Operation and Transmitter Coordination

Data shall be automatically fetched by the system interface logic to supply the UART Transmitter.

The system interface logic shall assert the internal `tx_start` signal when both of the following conditions are met:

1. The TX FIFO is not empty (`tx_empty = 0`).
2. The UART Transmitter is idle (no transmission in progress).

Upon asserting `tx_start`, one byte shall be read from the TX FIFO and forwarded to the transmitter. The read pointer shall advance accordingly.

When `tx_done_tick` is asserted, the system interface logic shall evaluate the above conditions again and initiate the next transmission if data remains in the FIFO.

---

### Status Signals

```text
tx_empty  — asserted when the FIFO contains no data pending transmission
tx_full   — asserted when the FIFO has reached its maximum capacity (16 entries)
```

---

## 11. Top-Level Interface

### Clock and Reset

```systemverilog
input  logic clk;     // System clock (100 MHz reference)
input  logic reset;   // Synchronous active-high reset
```

---

### Serial Interface

```systemverilog
input  logic rx;   // Serial receive line (asynchronous input)
output logic tx;   // Serial transmit line (idle = 1)
```

---

### Receive Interface

```systemverilog
output logic [7:0] rx_data;   // Data byte read from RX FIFO
input  logic       rx_read;   // Single-cycle pulse: read one byte from RX FIFO

output logic       rx_empty;  // RX FIFO is empty (no data available)
output logic       rx_full;   // RX FIFO is full (16 entries stored)
```

---

### Transmit Interface

```systemverilog
input  logic [7:0] tx_data;   // Data byte to write into TX FIFO
input  logic       tx_write;  // Single-cycle pulse: write tx_data into TX FIFO

output logic       tx_empty;  // TX FIFO is empty (no pending transmissions)
output logic       tx_full;   // TX FIFO is full (16 entries stored)
```

---

### Signal Timing Summary

| Signal | Direction | Type | Description |
|--------|-----------|------|-------------|
| `clk` | Input | Clock | System clock |
| `reset` | Input | Level | Synchronous active-high reset |
| `rx` | Input | Serial | Asynchronous serial receive line |
| `tx` | Output | Serial | Serial transmit line; idle = 1 |
| `rx_data` | Output | Bus | Byte output of RX FIFO; valid after asserting `rx_read` |
| `rx_read` | Input | Pulse | Assert for one cycle to dequeue one byte from RX FIFO |
| `rx_empty` | Output | Level | High when RX FIFO contains no data |
| `rx_full` | Output | Level | High when RX FIFO is at maximum capacity |
| `tx_data` | Input | Bus | Byte to enqueue into TX FIFO; sampled when `tx_write` is high |
| `tx_write` | Input | Pulse | Assert for one cycle to enqueue `tx_data` into TX FIFO |
| `tx_empty` | Output | Level | High when TX FIFO contains no pending data |
| `tx_full` | Output | Level | High when TX FIFO is at maximum capacity |

---

## 12. Design Constraints

### Allowed

- Moore or Mealy state machines
- Single-process or multi-process FSMs
- Binary or one-hot encoding
- Shift registers
- Parameterized modules

### Not Allowed

- Delays (`#`)
- Clock gating
- Non-synthesizable constructs
- Derived clock generation
- Asynchronous reset (all reset logic shall be synchronous)

---

## 13. Verification Requirements

The following scenarios shall be verified at minimum using the reference configuration (100 MHz clock, 19,200 bps).

### Receiver

- Single-byte reception: verify `rx_done_tick` is asserted for exactly one cycle and `dout` contains the correct byte.
- Continuous multi-byte reception: verify correct reception of a sequence of at least four consecutive bytes without data loss.
- Correct RX FIFO write: verify that each received byte is stored in the RX FIFO.
- Correct RX FIFO read: verify that bytes are dequeued in FIFO order using `rx_read`.
- RX FIFO overflow: verify that when the FIFO is full, additional received bytes are discarded without corrupting existing data.

### Transmitter

- Single-byte transmission: verify correct 8N1 frame on the TX line (start bit, 8 data bits LSB first, stop bit), and that `tx_done_tick` is asserted for exactly one cycle.
- Continuous multi-byte transmission: verify that a sequence of at least four bytes is transmitted correctly without gaps beyond the normal stop-bit interval.
- Correct TX FIFO operation: verify that bytes written via `tx_write` are transmitted in FIFO order.

### Loopback Test

Connect:

```text
TX → RX
```

and demonstrate:

```text
Transmitted Data = Received Data
```

for a minimum of eight distinct test values, including `0x00`, `0xFF`, `0xAA`, and `0x55`.

---

## 14. Acceptance Criteria

The design shall be considered correct when:

1. UART 8N1 frames are transmitted correctly using the reference configuration (100 MHz clock, 19,200 bps).
2. UART 8N1 frames are received correctly using 16× oversampling with the reference configuration.
3. The design operates exclusively from the **100 MHz** system clock.
4. Both RX and TX FIFOs are implemented, functional, and exhibit correct overflow protection behavior.
5. All verification scenarios listed in Section 13 pass successfully.
6. The design is fully synthesizable on FPGA devices.
7. Clock frequency and baud rate can be modified through RTL parameters (`CLK_FREQ`, `BAUD_RATE`) without requiring architectural changes.

---

## 15. References

[R1] Pong P. Chu,
*FPGA Prototyping by Verilog Examples: Xilinx Spartan-3 Version*,
Wiley-Interscience, 2008.

[R2] Pong P. Chu,
*FPGA Prototyping by SystemVerilog Examples: Xilinx MicroBlaze MCS SoC Edition*,
Wiley, 2016.

[R3] IEEE Standards Association,
*IEEE Standard for Verilog Hardware Description Language (IEEE 1364)*.

[R4] IEEE Standards Association,
*IEEE Standard for SystemVerilog Unified Hardware Design, Specification, and Verification Language (IEEE 1800)*.
