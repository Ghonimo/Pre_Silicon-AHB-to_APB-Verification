# AHB-APB Bridge Verification Project 🌉

## Overview 📖
This repository contains the work and methodologies for the verification and validation of the AHB2APB bridge design. Our objective has been to employ both SystemVerilog and UVM-based test bench development methodologies to create Verification IP (VIP) components, ensuring a comprehensive and robust verification strategy for the AHB-APB Bridge design.

![AHB2APB Bridge Verification IP](https://raw.githubusercontent.com/Ghonimo/Pre_Silicon-AHB-to_APB-Verification/main/Checkpoint%204_UVM_Based%20Testbench/AHB2APB%20Bridge%20(1).jpg) 

## Key Phases 🚀

### Phase 1: SystemVerilog-based Verification
- Established a simulation environment using QuestaSim and validated the basic functionality of the AHB2APB bridge.
- Constructed a verification environment using SystemVerilog, which comprised several components like transaction models, generators, drivers, monitors, scoreboards, and coverage collectors.
- Employed a modular, bottom-up verification methodology, beginning with individual components and advancing to more complex subsystems.

### Phase 2: UVM-based Verification
- Transitioned from a traditional SystemVerilog approach to the Universal Verification Methodology (UVM).
- Developed a structured UVM environment with specialized components such as agents, sequencers, and an enhanced scoreboard.
- The UVM framework provided a blueprint for creating a highly reusable and modular verification environment, ensuring efficient testing of the AHB-APB Bridge design.

## Features 🌟
- Modular and Object-Oriented Programming (OOP) approach.
- Comprehensive test scenarios covering various functionalities of the bridge design.
- Two main phases of verification: SystemVerilog-based and UVM-based.
- Detailed documentation of each checkpoint and phase.

## Conclusion 🏁
The AHB-APB Bridge Verification Project serves as an exhaustive verification suite, ensuring the bridge design's functionality and performance align with industry standards and best practices.
