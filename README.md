# SimCharge
SimCharge is a simulation platform for benchmarking EV charging allocation mechanisms,
with explicit support for mobile charging stations (MCSs).

SimCharge is introduced in the paper (still under review):
> Z. Hussain, R. Mizouni, T. H. El-Fouly, S. Singh, and H. Otrok,  
> *SimCharge: Towards Standardized Evaluation of EV Charging via Mobile Charging Solutions*,  
> IEEE International Conference on Smart Mobility, 2026.
> 
## Scope and Intent

SimCharge is intended as an **evaluation and benchmarking tool**, not as a reference implementation of a specific charging or market mechanism.  
The platform separates **simulation assumptions** from **allocation logic**, allowing different mechanisms to be evaluated under identical conditions.

This release focuses on providing a reusable simulation framework and baseline mechanisms suitable for comparative evaluation.

## Key Features

- Configurable area of interest (AoI) and meeting-point layouts
- Explicit modeling of EV and MCS agents
- Support for EV mobility and MCS relocation
- Modular, mechanism-agnostic allocation interface
- Baseline allocation strategies:
  - Random allocation
  - Greedy nearest assignment
  - RSMB auction-based allocation (as described in prior publications)
- Real-time visualization of system state and performance metrics
- Export of time-series metrics as CSV files for post-simulation analysis
- Graphical user interface for scenario configuration and execution

---

### Included Baselines
- **Random allocation**
- **Greedy nearest assignment**
- **RSMB auction-based allocation** (used in Husain et. al.,  “Blockcharge: A blockchain-based auction framework for ev charging via mobile stations,” Applied Energy, vol. 377, p. 124638, 2025.)

### Custom Mechanisms
Users may upload custom allocation mechanisms as MATLAB (`.m`) files via the interface.

- All **mechanism-specific parameters and logic** must be handled within the uploaded file.
- Common simulation parameters and system state are provided by the simulator.
- Custom mechanisms must conform to the **input/output specifications** described in the documentation.
  
## Paper
If you use this simulator, please cite: TBA

## Notes
Some datasets and components used in prior studies are not included in this release.
Example configurations are provided for benchmarking and reproducibility.
