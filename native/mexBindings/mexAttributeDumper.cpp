/*
 * Copyright (C) Vamsi.  2017-18 All rights reserved.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License version 2.
 */

#include "mex.h"
#include "mexNs3State.h"
#include "ns3/config-store-module.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    std::string filename = std::string(mxArrayToString(prhs[0]));
    // Invoke just before entering Simulator::Run ()
    Config::SetDefault ("ns3::ConfigStore::Filename", StringValue (filename.c_str()));
    Config::SetDefault ("ns3::ConfigStore::Mode", StringValue ("Save"));
    ConfigStore outputConfig;
    outputConfig.ConfigureAttributes ();
}
