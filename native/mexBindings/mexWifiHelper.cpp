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

void cleanup(void)
{
    MEXIsLoaded = 0;
}

void* getElem(MemMngmt *obj)
{
    return obj->vptr;
}

typedef enum methodType
{
    SETSTANDARD,
    SETREMOTESTATIONMANAGER,
    WIFIHELPER,
    INSTALL,
    ASSIGNSTREAMS,
    ENABLELOGCOMPONENTS,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetStandard", "SetRemoteStationManager", "new", "Install", "AssignStreams", "EnableLogComponents", "delete"};

methodType_t identifyMethod(const char* cmd)
{
    for (int i = 0; i < TOTAL_METHODS; i++)
    {
        if (!strcmp(methodNames[i], cmd))
            return methodType_t(i);
    }
    return TOTAL_METHODS;
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
    switch(identifyMethod(cmd))
    {
        case SETSTANDARD:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
#ifndef MANUAL_CHANGE
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            WifiPhyStandard arg2 = *(reinterpret_cast<WifiPhyStandard*>(tst2->vptr));
#else
            WifiPhyStandard arg2 = WifiPhyStandard(*((uint32_t *)mxGetData(prhs[2])));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<WifiHelper*>(obj))->SetStandard(arg2);
#endif
            break;
        }
        case SETREMOTESTATIONMANAGER:
        {
            if ((nlhs != 0) || (nrhs > 19))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            std::string arg2 = std::string(mxArrayToString(prhs[2]));
            std::string arg3 = std::string(mxArrayToString(prhs[3]));
            MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
            AttributeValue const & arg4 = *(reinterpret_cast<AttributeValue*>(tst4->vptr));
            std::string arg5 = std::string(mxArrayToString(prhs[5]));
            MemMngmt *tst6=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[6]))));
            AttributeValue const & arg6 = *(reinterpret_cast<AttributeValue*>(tst6->vptr));
            std::string arg7 = std::string(mxArrayToString(prhs[7]));
            MemMngmt *tst8=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[8]))));
            AttributeValue const & arg8 = *(reinterpret_cast<AttributeValue*>(tst8->vptr));
            std::string arg9 = std::string(mxArrayToString(prhs[9]));
            MemMngmt *tst10=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[10]))));
            AttributeValue const & arg10 = *(reinterpret_cast<AttributeValue*>(tst10->vptr));
            std::string arg11 = std::string(mxArrayToString(prhs[11]));
            MemMngmt *tst12=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[12]))));
            AttributeValue const & arg12 = *(reinterpret_cast<AttributeValue*>(tst12->vptr));
            std::string arg13 = std::string(mxArrayToString(prhs[13]));
            MemMngmt *tst14=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[14]))));
            AttributeValue const & arg14 = *(reinterpret_cast<AttributeValue*>(tst14->vptr));
            std::string arg15 = std::string(mxArrayToString(prhs[15]));
            MemMngmt *tst16=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[16]))));
            AttributeValue const & arg16 = *(reinterpret_cast<AttributeValue*>(tst16->vptr));
            std::string arg17 = std::string(mxArrayToString(prhs[17]));
            MemMngmt *tst18=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[18]))));
            AttributeValue const & arg18 = *(reinterpret_cast<AttributeValue*>(tst18->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<WifiHelper*>(obj))->SetRemoteStationManager(arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18);
            break;
        }
        case WIFIHELPER:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            WifiHelper *obj = new WifiHelper();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = WIFIHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case INSTALL:
        {
            if ((nlhs != 1) || (nrhs > 5))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 5:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    WifiPhyHelper const & arg2 = *(reinterpret_cast<WifiPhyHelper*>(tst2->vptr));
                    MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
                    WifiMacHelper const & arg3 = *(reinterpret_cast<WifiMacHelper*>(tst3->vptr));
                    MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
#ifndef MANUAL_CHANGE
                    NodeContainer arg4 = *(reinterpret_cast<NodeContainer*>(tst4->vptr));
                    NetDeviceContainer *tmp = new NetDeviceContainer((reinterpret_cast<WifiHelper*>(obj))->Install(arg2, arg3, arg4));
#else
                    NetDeviceContainer *tmp;
                    if (tst4->objType == NODECONTOBJ)
                    {
                        NodeContainer arg4 = *(reinterpret_cast<NodeContainer*>(tst4->vptr));
                        tmp = new NetDeviceContainer((reinterpret_cast<WifiHelper*>(obj))->Install(arg2, arg3, arg4));
                    }
                    else if (tst4->objType == NODEOBJ_SP)
                    {
                        Ptr<Node> arg4 = *(reinterpret_cast<Ptr<Node>*>(tst4->vptr));
                        tmp = new NetDeviceContainer((reinterpret_cast<WifiHelper*>(obj))->Install(arg2, arg3, arg4));
                    }
                    else
                        mexErrMsgTxt("problem in wifi helper install");
#endif
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(tmp);
                    tst->objType = NETDEVCONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
            break;
        }
        case ASSIGNSTREAMS:
        {
            if ((nlhs != 1) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            NetDeviceContainer arg2 = *(reinterpret_cast<NetDeviceContainer*>(tst2->vptr));
            int64_t arg3 = (int64_t) *mxGetPr(prhs[3]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            int64_t output = (reinterpret_cast<WifiHelper*>(obj))->AssignStreams(arg2, arg3);
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == WIFIHELPOBJ)
                    delete reinterpret_cast<WifiHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        case ENABLELOGCOMPONENTS:
        {
            if ((nlhs != 0) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            WifiHelper::EnableLogComponents();
            break;
        }
        default:
            break;
    }
}
