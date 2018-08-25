# MATLAB-NS3
Co-simulate MATLAB with NS-3 network simulator, combining the powers of MATLAB and NS-3. Describe the scenario in MATLAB, run simulation from MATLAB, capture the results and visualize them in MATLAB.
Optionally use the MATLAB PHY and Channel models, instead of the statistical models of NS-3.

This co-simulation code currently:
   * Supports modeling WLAN network and 802.11p based V2X scenarios. 
   * Works with NS-3.26 version.
   * Works on Linux. Can get it working on Windows, if the NS3 library port is available to Windows.
   * For high-fidelity WLAN PHY and Channel modeling, MATLAB WLAN Toolbox is recommended.
   * For proper visualization of the included examples, display should be of Full-HD (1920x1080) resolution.

Following example scenarios are included in this repository:
   * WLAN Infrastructure Example
   * Truck Platooning Example with V2X
   * Manhattan Grid Hazard Warning Example with V2X

See the included documentation in 'doc' folder, for more details.


Here is the folder hierarchy of this repository:
├───doc
├───mlCode
│   ├───mlWiFiPhyChannel
│   └───mlWrappers
├───native
│   ├───mexBindings
│   └───mlPhy
└───scenarios
    ├───advWifiScenario
    │   └───visualizer
    ├───manhattanHazardWarning
    │   ├───manhattanTopologyModel
    │   ├───traces
    │   └───visualizer
    └───truckPlatooning
        ├───highwayTopologyModel
        ├───traces
        └───visualizer
