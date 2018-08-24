#
# Copyright (C) Vamsi.  2017-18 All rights reserved.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions
# of the GNU General Public License version 2.
#

g++ -std=c++11 -shared -o libmatlabphy.so -fPIC *.cc -I. -I../../ns-allinone-3.26/ns-3.26/build/ -L. -L../../ns-allinone-3.26/ns-3.26/build/ -lns3.26-internet-debug -lns3.26-internet-apps-debug -lns3.26-point-to-point-layout-debug -lns3.26-wifi-debug -lns3.26-csma-debug -lns3.26-lte-debug -lns3.26-propagation-debug -lns3.26-wimax-debug -lns3.26-csma-layout-debug -lns3.26-mesh-debug -lns3.26-spectrum-debug -lns3.26-dsdv-debug -lns3.26-mobility-debug -lns3.26-stats-debug -lns3.26-antenna-debug -lns3.26-dsr-debug -lns3.26-mpi-debug -lns3.26-aodv-debug -lns3.26-netanim-debug -lns3.26-tap-bridge-debug -lns3.26-applications-debug -lns3.26-energy-debug -lns3.26-network-debug -lns3.26-test-debug -lns3.26-bridge-debug -lns3.26-nix-vector-routing-debug -lns3.26-topology-read-debug -lns3.26-buildings-debug -lns3.26-fd-net-device-debug -lns3.26-olsr-debug -lns3.26-uan-debug -lns3.26-config-store-debug -lns3.26-flow-monitor-debug -lns3.26-point-to-point-debug -lns3.26-virtual-net-device-debug -lns3.26-netanim-debug -lns3.26-core-debug -lns3.26-wave-debug -lns3.26-lr-wpan-debug -lns3.26-sixlowpan-debug -lns3.26-traffic-control-debug

mv libmatlabphy.so ../../ns-allinone-3.26/ns-3.26/build/
