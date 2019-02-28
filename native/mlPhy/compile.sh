#
# Copyright (C) Vamsi.  2017-18 All rights reserved.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions
# of the GNU General Public License version 2.
#

g++ -std=c++11 -shared -o libmatlabphy.so -fPIC *.cc -I. -I../../ns-allinone-3.29/ns-3.29/build/ -L. -L../../ns-allinone-3.29/ns-3.29/build/lib/ -lns3.29-internet-debug -lns3.29-internet-apps-debug -lns3.29-point-to-point-layout-debug -lns3.29-wifi-debug -lns3.29-csma-debug -lns3.29-lte-debug -lns3.29-propagation-debug -lns3.29-wimax-debug -lns3.29-csma-layout-debug -lns3.29-mesh-debug -lns3.29-spectrum-debug -lns3.29-dsdv-debug -lns3.29-mobility-debug -lns3.29-stats-debug -lns3.29-antenna-debug -lns3.29-dsr-debug -lns3.29-mpi-debug -lns3.29-aodv-debug -lns3.29-netanim-debug -lns3.29-tap-bridge-debug -lns3.29-applications-debug -lns3.29-energy-debug -lns3.29-network-debug -lns3.29-test-debug -lns3.29-bridge-debug -lns3.29-nix-vector-routing-debug -lns3.29-topology-read-debug -lns3.29-buildings-debug -lns3.29-fd-net-device-debug -lns3.29-olsr-debug -lns3.29-uan-debug -lns3.29-config-store-debug -lns3.29-flow-monitor-debug -lns3.29-point-to-point-debug -lns3.29-virtual-net-device-debug -lns3.29-netanim-debug -lns3.29-core-debug -lns3.29-wave-debug -lns3.29-lr-wpan-debug -lns3.29-sixlowpan-debug -lns3.29-traffic-control-debug

mv libmatlabphy.so ../../ns-allinone-3.29/ns-3.29/build/lib/
