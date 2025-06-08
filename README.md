# Project Overview
This project focuses on designing and implementing a parameterized Arithmetic Logic Unit (ALU) in Verilog HDL. The ALU supports both arithmetic and logical operations, and includes a wide variety of instructions like addition, subtraction, multiplication, shifting, and bitwise operations. The design emphasizes modularity, parameterization, and testability, making it suitable for integration into larger digital systems or processors.
The ALU is designed to:
- Accept two 8-bit inputs (OPA, OPB) and a control command (CMD)
- Perform operations depending on the mode (arithmetic or logic)
- Handle signed and unsigned computations
- Generate useful status flags (COUT, OFLOW, E, G, L, ERR)
- Produce results with a 1-clock cycle delay for most operations and a 3-clock cycle delay for multiplication operations

---

## ALU Architecture
The ALU architecture includes the following key components:

**Control Unit**
- Receives control signals such as CMD, CE, MODE, and INP_VALID
- Decides the operation to be performed based on command and mode
- Register Bank
- Temporarily stores input operands and control signals on each clock edge for synchronous processing

**Arithmetic Block**
- Handles operations like add, subtract, increment, decrement, signed operations, and multiplication
- Uses internal flags to detect carry and overflow

**Logic Block**
- Performs bitwise operations: AND, OR, XOR, etc.
- Includes support for single-bit shifts and multi-bit rotates

**Flag Generator**
- Outputs status flags (COUT, OFLOW, E, G, L) based on result and inputs

**Multiplication Delay Unit**
- Uses intermediate registers to introduce a 3-cycle latency for MUL_1 and MUL_2 operations

---

## File Structure

| File Name             | Description                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `alu_Design.v`        | Main Verilog file that implements the parameterized ALU design. Supports arithmetic and logical operations, including shift, rotate, and signed/unsigned handling. |
| `alu_testbench.v`     | Testbench to validate the ALU. Applies a variety of test vectors and checks results and status flags.                                                              |
| `alu_project_doc.pdf` | Detailed documentation of the project including architecture, operation explanation, simulation results, and conclusions.                                          |
| `README.md`           | This file. Provides project overview, architecture, file structure, and usage guide.                                                                               |
| `Coverage Report`     | Simulation coverage report summarizing functional and code coverage achieved during verification.                                                                  |

---

## Results
- All functional requirements were met.
- ALU passed a wide range of test cases, including edge cases.
- Arithmetic and logical correctness verified through simulation.
- 1-cycle delay for most operations, 3-cycle delay for multiplication.
- High code modularity and parameter reusability.

---

## Future Improvements
- Add support for division and floating-point operations
- Optimize multiplication with faster algorithms
- Introduce pipelining to improve throughput
- Enhance error diagnostics
- Power-saving features like clock gating
- Greater parameter flexibility and modular integration

---

## Author
**Havala P N**,
Intern at Mirafra Technologies
