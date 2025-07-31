# Develop and Validate UART VIP
## Overview
This project was developed as part of the UART IP verification effort, with a focus on the development and validation of a reusable UART Verification IP (VIP) using SystemVerilog and Universal Verification Methodology (UVM).

The objective is to demonstrate a solid understanding of UART protocol, UVM-based testbench, VIP architecture and transaction modeling by building a robust environment to interact with a DUT (UART IP).

## Tools and Methodology
- Languages: SystemVerilog (for environment development and testbench creation)
- Methodology: UVM (Universal Verification Methodology)
- EDA Tool: QuestaSim (for simulation, waveform analysis and debugging)

## Project Structure
The repository is organized into the following directories:

- `rtl/` - Dummy UART RTL (used to interconnect 2 UART VIPs)
- `uart_vip/` - UART VIP that generates and monitors UART transactions
- `tb/` - UVM testbench components including environment, scoreboard, testbench
- `sequences/` - Transaction-level sequences for test scenarios
- `testcases/` - Test cases verifying different UART features
- `sim/` - Simulation scripts, Makefile and regression setup
- `docs/` - Protocol summary, validate plan and testbench structure

## Project Documents
For further details, please refer to the following:
- [UART Protocol Summary](https://github.com/tronguyen0811/Develop_Validate_UART_VIP/blob/main/docs/UART_protocol_summary.pdf)
- [Validate Plan](https://github.com/tronguyen0811/Develop_Validate_UART_VIP/blob/main/docs/validate_plan.xlsx)

## Testbench Structure
The testbench is designed using UVM to validate the UART VIP functionality:
![Testbench structure to validate UART VIP](https://github.com/tronguyen0811/Develop_Validate_UART_VIP/blob/main/docs/testbench_structure.png)

**Key Components:**
- **uart_lhs_config/uart_rhs_config**: Configuration object for the LHS/RHS UART agent (transfer mode, baudrate, data width, parity, stop bits)
- **uart_lhs_agent/uart_rhs_agent**: Represent UART transmitter and receiver endpoints
- **uart_scoreboard**: Compares transmitted and received data to check for correctness

## How to use
- Navigate to the `sim/` directory
- Source the project environment: `source project_env.bash` 
- Compile the design: `make build` 
- Run an individual testcase: `make run TESTNAME=<testname>`
- Run full regression: `./regress.pl`
- View available commands: `make help`

## Result
- Regression report is available in: `sim/regress.rpt` 
- Testcase-specific logs can be found in: `sim/log/`

## Conclusion
This project strengthened my UVM-based verification skills and helped me gain hands-on experience with:
- Developing reusable UVM-based VIP
- Architecting modular and scalable testbenches
- Debugging and validating UART protocol compliance using waveform and scoreboard analysis

As this is a learning project, any suggestions or feedback that could help me improve are greatly appreciated. Thank you for visiting!