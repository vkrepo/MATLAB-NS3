/*
 * Copyright (C) Vamsi.  2017-18 All rights reserved.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License version 2.
 */

#include "mex.h"
#include "mexNs3State.h"

using namespace ns3;
static int MEXIsLoaded = 0;

static std::map<std::string, std::string> nspath = {{"WifiPhy", "/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Phy/"}, {"WifiMac", "/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/"},
{"WavePhy", "/NodeList/*/DeviceList/*/$ns3::WaveNetDevice/PhyEntities/*/"}, {"WaveMac", "/NodeList/*/DeviceList/*/$ns3::WaveNetDevice/MacEntities/*/"}
};
static std::map<std::string, std::string> funcMc ={{"Mac/Tx", ""}, {"Mac/Rx", ""}, {"Mac/RxDrop", ""}, {"Phy/RxError", ""}, {"Phy/RxOk", ""}, {"Phy/Tx", ""}};

void cleanup(void)
{
    nspath.clear();
    funcMc.clear();
    MEXIsLoaded = 0;
}

typedef enum methodType
{
    CONNECT,
    SET,
    SETDEFAULT,
    TOTAL_METHODS
}methodType_t;


static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"Connect", "Set", "SetDefault"};

methodType_t identifyMethod(const char* cmd)
{
    for (int i = 0; i < TOTAL_METHODS; i++)
    {
        if (!strcmp(methodNames[i], cmd))
            return methodType_t(i);
    }
    return TOTAL_METHODS;
}

double timeval_substract(struct timespec *x, struct timespec *y)
{
    double temp1 = 0 , temp2 = 0;
    temp1 = (double) ((x->tv_sec * 1000000000) + x->tv_nsec);
    temp2 = (double) ((y->tv_sec * 1000000000) + y->tv_nsec);
    return (temp2 - temp1);
}

void PhyTxTrace (Ptr<const Packet> packet, WifiMode mode, WifiPreamble preamble, uint8_t txPower)
{
    static int count = 0, count1 =0 , count2 = 0, count3 = 0;
    count++;
    struct timespec x, y;
    
    mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(node_id)) = Simulator::GetContext() + 1;
    
    
    mxArray* param1 = mxCreateString("PhyTx");
    mxArray *value1 = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(value1)) = 0;
    
    mxArray * args [] = {node_id, param1, value1};
    mexCallMATLABWithTrap(0, nullptr, 3, args, (funcMc["Phy/Tx"]).c_str());
}

void PacketRxOk (Ptr< const Packet > packet, double snr, WifiMode mode, WifiPreamble preamble)
{
    static int count = 0, count1 = 0 , count2 = 0, count3 = 0;
    count++;
    struct timespec x, y;
    mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(node_id)) = Simulator::GetContext() + 1;
    
    mxArray* param1 = mxCreateString("PhyRxOk");
    mxArray *value1 = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(value1)) = 0;
    
    mxArray * args [] = {node_id, param1, value1};
    mexCallMATLABWithTrap(0, nullptr, 3, args, (funcMc["Phy/RxOk"]).c_str());
}

void PacketRxError (Ptr<const Packet> packet, double snr)
{
    static int count = 0;
    count++;
    struct timespec x, y;
    clock_gettime(CLOCK_REALTIME, &x);
    mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(node_id)) = Simulator::GetContext() + 1;
    mxArray* param1 = mxCreateString("RxError");
    mxArray *value1 = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(value1)) = 0;
    
    mxArray* args[] = {node_id, param1, value1};
    mexCallMATLABWithTrap(0, nullptr, 3, args, (funcMc["Phy/RxError"]).c_str());
    clock_gettime(CLOCK_REALTIME, &y);
}

void MacTx (Ptr<const Packet> packet)
{
    static int count = 0;
    count++;
    struct timespec x, y;
    clock_gettime(CLOCK_REALTIME, &x);
    mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(node_id)) = Simulator::GetContext() + 1;
    
    mxArray* param1 = mxCreateString("MacTx");
    mxArray *value1 = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(value1)) = 0;
    
    mxArray * args [] = {node_id, param1, value1/*pkt_size*/};
    mexCallMATLABWithTrap(0, nullptr, 3, args, (funcMc["Mac/Tx"]).c_str());
    clock_gettime(CLOCK_REALTIME, &y);
}

void MacRx (Ptr<const Packet> packet)
{
    static int count = 0;
    count++;
    
    struct timespec x, y;
    clock_gettime(CLOCK_REALTIME, &x);
    mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(node_id)) = Simulator::GetContext() + 1;
    
    mxArray* param1 = mxCreateString("MacRx");
    mxArray *value1 = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(value1)) = 0;
    
    
    mxArray * args [] = {node_id, param1, value1/*pkt_size*/};
    mexCallMATLABWithTrap(0, nullptr, 3, args, (funcMc["Mac/Rx"]).c_str());
    clock_gettime(CLOCK_REALTIME, &y);
}


void MacRxDrop (Ptr<const Packet> p)
{
    static int count = 0;
    count++;
    struct timespec x, y;
    clock_gettime(CLOCK_REALTIME, &x);
    mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(node_id)) = Simulator::GetContext() + 1;
    
    mxArray* param1 = mxCreateString("MacRxDrop");
    mxArray *value1 = mxCreateDoubleMatrix(1, 1, mxREAL);
    *(mxGetPr(value1)) = 0;
    
    mxArray* args[] = {node_id, param1, value1};
    mexCallMATLABWithTrap(0, nullptr, 3, args, (funcMc["Mac/RxDrop"]).c_str());
    clock_gettime(CLOCK_REALTIME, &y);
}


void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (!MEXIsLoaded)
    {
        mexAtExit(cleanup);
        MEXIsLoaded = 1;
    }
    uint16_t indx = 0;
    char cmd[CMD_BUFFER_SIZE];
    if (nrhs < 1 || mxGetString(prhs[INPUT_Command_String_Index], cmd, sizeof(cmd)))
    {
        mexErrMsgTxt("Check your inputs");
    }
    std::string cmptName = std::string(mxArrayToString(prhs[1]));
    std::string eventName = std::string(mxArrayToString(prhs[2]));
    std::string slash = std::string("/");
    std::string path;
    if (cmptName != std::string(""))
        path = nspath[cmptName] + eventName;
    
    switch(identifyMethod(cmd))
    {
        case CONNECT:
        {
            std::string clbk = std::string(mxArrayToString(prhs[3]));
            if (std::string("WifiMac/MacTx") == (cmptName + slash + eventName))
            {
                Config::ConnectWithoutContext(path, MakeCallback(&MacTx));
                funcMc["Mac/Tx"] = clbk;
            }
            else if (std::string("WifiMac/MacRx") == (cmptName + slash + eventName))
            {
                Config::ConnectWithoutContext(path, MakeCallback(&MacRx));
                funcMc["Mac/Rx"] = clbk;
            }
            else if (std::string("WifiMac/MacRxDrop") == (cmptName + slash + eventName))
            {
                Config::ConnectWithoutContext(path, MakeCallback(&MacRxDrop));
                funcMc["Mac/RxDrop"] = clbk;
            }
            else if (std::string("WifiPhy/Tx") == (cmptName + slash + eventName))
            {
                path = nspath[cmptName] + std::string("State/") + eventName;
                Config::ConnectWithoutContext(path, MakeCallback(&PhyTxTrace));
                funcMc["Phy/Tx"] = clbk;
            }
            else if (std::string("WifiPhy/RxOk") == (cmptName + slash + eventName))
            {
                path = nspath[cmptName] + std::string("State/") + eventName;
                Config::ConnectWithoutContext(path, MakeCallback(&PacketRxOk));
                funcMc["Phy/RxOk"] = clbk;
            }
            else if (std::string("WifiPhy/RxError") == (cmptName + slash + eventName))
            {
                path = nspath[cmptName] + std::string("State/") + eventName;
                Config::ConnectWithoutContext(path, MakeCallback(&PacketRxError));
                funcMc["Phy/RxError"] = clbk;
            }
            else if (std::string("WaveMac/MacTx") == (cmptName + slash + eventName))
            {
                Config::ConnectWithoutContext(path, MakeCallback(&MacTx));
                funcMc["Mac/Tx"] = clbk;
            }
            else if (std::string("WaveMac/MacRx") == (cmptName + slash + eventName))
            {
                Config::ConnectWithoutContext(path, MakeCallback(&MacRx));
                funcMc["Mac/Rx"] = clbk;
            }
            else if (std::string("WaveMac/MacRxDrop") == (cmptName + slash + eventName))
            {
                Config::ConnectWithoutContext(path, MakeCallback(&MacRxDrop));
                funcMc["Mac/RxDrop"] = clbk;
            }
            else if (std::string("WavePhy/Tx") == (cmptName + slash + eventName))
            {
                path = nspath[cmptName] + std::string("State/") + eventName;
                Config::ConnectWithoutContext(path, MakeCallback(&PhyTxTrace));
                funcMc["Phy/Tx"] = clbk;
            }
            else if (std::string("WavePhy/RxOk") == (cmptName + slash + eventName))
            {
                path = nspath[cmptName] + std::string("State/") + eventName;
                Config::ConnectWithoutContext(path, MakeCallback(&PacketRxOk));
                funcMc["Phy/RxOk"] = clbk;
            }
            else if (std::string("WavePhy/RxError") == (cmptName + slash + eventName))
            {
                path = nspath[cmptName] + std::string("State/") + eventName;
                Config::ConnectWithoutContext(path, MakeCallback(&PacketRxError));
                funcMc["Phy/RxError"] = clbk;
            }
            else
                std::cout<<"Enter valid traces"<<std::endl;
            break;
        }
        case SET:
        {
            MemMngmt *tst =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
            AttributeValue const & arg = *(reinterpret_cast<AttributeValue*>(tst->vptr));
            Config::Set(path, arg);
            break;
        }
        case SETDEFAULT:
        {
            MemMngmt *tst =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
            AttributeValue const & arg = *(reinterpret_cast<AttributeValue*>(tst->vptr));
            Config::SetDefault(eventName, arg);
            break;
        }
        default:
            break;
    }
}
