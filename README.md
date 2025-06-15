# UVM_FPU(Floating Point Unit)
This project involves the design and UVM-based verification of a 32-bit IEEE-754 compliant Floating Point Unit (FPU) capable of performing:
Addition
Subtraction
Multiplication
Division
The FPU supports both normalized and denormalized numbers, and handles all IEEE 754 special cases: +0, -0, ±∞, and NaN.

## Team Members
Sanjeev Krishnan Kamalamurugan
Harshal Venkat Kapa
Pavani Patibandla
Sathish Thirumalaisamy

## Project File Structure

```
+---ClassBased_DV
|       |    Class based teestbench codes
+---DV
|       |    Conventional testbench codes
+---RTL
|       |    RTL design files of FPU
+---UVM
|       |    UVM based testbench
```

## To Run
In QuestaSim terminal, change to the respective testbench directory and execute the run.do file.

## Features & Architecture
IEEE-754 single precision (32-bit): 1 sign bit, 8 exponent bits, 23 mantissa bits
FSM-based control logic
Valid/Ready handshake protocol
Special case detection: NaN, Inf, Zero, Denormals

## Interface Signals
Signal	Description
clk	System clock
reset	Asynchronous active-high reset
valid	Indicates input operands are stable
ready	Indicates when output result is valid
din1	32-bit IEEE-754 operand A
din2	32-bit IEEE-754 operand B
op_sel	2-bit operation selector (00: add, ..., 11: div)
result	32-bit IEEE-754 output result

## Verification Strategy
Implemented using Universal Verification Methodology (UVM) in SystemVerilog.

## Verification Techniques
Dynamic simulation with directed and constrained-random tests
Gray-box testing (combines structure + behavior)
Scoreboard-based checking with golden reference comparison
Functional and code coverage targeting 100%

## UVM Components
Sequence Item – encapsulates input operands and operatio
Driver – generates and drives stimulus
Monitor – captures DUT transactions passively
Scoreboard – compares DUT result with expected
Environment – connects all UVM components
Agent – encapsulates monitor and driver

## Test Plan Highlights
Directed and randomized tests for corner cases and typical ops
Special value combinations: NaN, Inf, 0.0, denormals
Regression and edge-case tests for robustness

## Coverage Goals
Functional Coverage:
All opcodes
All operand categories: normal, special, toggle, edge
Cross-coverage: (op_sel x din1 x din2)

## Tools & Setup
QuestaSim – Simulation and Coverage
SystemVerilog + UVM
