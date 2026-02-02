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


## Instructions on structure of custom_alloc.m file 
The uploaded file should contain a function (of the same name as the file) using the following proptotype:
[RESULTS,  MCS_Data, EV_Data, MCS_chgPt_occupied, MCS_chgPt_freeTime, chgPt_utilizationTime] = custom_alloc_function(MP_loc, MCS_Data, EV_Data, max_rounds, disp_flag_frames, disp_flag_results, EV_zone, time_slots, fig_num_rows)

MP_loc: Location of MPs (set from the interface)
MCS_Data: nx16 matrix (columns explained below)
EV_Data: mx14 matrix (columns explained below)
max_rounds: 1x1 value, definins the maximum number of rounds to be run
displ_flag_frames: 1x1 bool flag; set to true if run-time frames are needed
disp_flag_results: 1x1 bool flag; set to true if run-time results are needed
EV_zone: mx1 matrix; defines the zone number each EV is in
time_slots: 1xt matrix; defines the time-stamps for the run
fi_num_rows: 1x1 value; set via interface

## Data structures
MCS_Data: nx16 matrix 
Col #: Col meaning
1: MCS ID
2: MCS x-coordinate
3: MCS y-coordinate
4: MCS zone
5: Time MCS will be free at (finishes current service)
6: MCS battery capacity (in kWh)
7: Max charging points on MCS
8: MCS' energy tradre price ($)
9: MCS' travel cost ($)
10: MCS' charging cost ($)
11: Total distance travelled
12: Number of zone changes
13: Current battery SoC (kWh)
14: Allocated? (bool)
15: Total Earning ($)
16: Available? (bool)

