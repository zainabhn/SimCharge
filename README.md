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

## Data Structures

### `MCS_Data` Matrix

`MCS_Data` is an `n × 16` matrix, where each row corresponds to a mobile charging station (MCS).

| Column | Description |
|-------:|-------------|
| 1 | MCS identifier |
| 2 | MCS x-coordinate |
| 3 | MCS y-coordinate |
| 4 | MCS zone index |
| 5 | Time at which the MCS becomes free (end of current service) |
| 6 | MCS battery capacity (kWh) |
| 7 | Maximum number of charging points on the MCS |
| 8 | Energy trading price (\$/kWh) |
| 9 | Travel cost (\$ per unit distance) |
| 10 | Charging cost (\$ per unit energy) |
| 11 | Total distance traveled |
| 12 | Number of zone changes |
| 13 | Current battery state of charge (kWh) |
| 14 | Allocation status (boolean) |
| 15 | Total earnings (\$) |
| 16 | Availability status (boolean) |

### `EV_Data` Matrix

`EV_Data` is an `n × 14` matrix, where each row corresponds to an electric vehicle (EV).

| Column | Description |
|-------:|-------------|
| 1 | EV identifier |
| 2 | EV x-coordinate |
| 3 | EV y-coordinate |
| 4 | Current zone index |
| 5 | Departure time (or service-related time parameter; may be unused) |
| 6 | Current state of charge (SoC) as a percentage |
| 7 | Requested state of charge (SoC) as a percentage |
| 8 | Current battery energy (kWh) |
| 9 | Requested battery energy (kWh) |
| 10 | Waiting time until service (set when EV is served) |
| 11 | Required fast charging time (minutes) |
| 12 | Maximum budget (\$) |
| 13 | Arrival time (if enabled; may be unused in some scenarios) |
| 14 | Departure time from AoI |

