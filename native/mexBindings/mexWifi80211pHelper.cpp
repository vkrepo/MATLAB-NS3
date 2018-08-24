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
    INSTALL,
    WIFI80211PHELPER,
    DEFAULT,
    ENABLELOGCOMPONENTS,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetStandard", "Install", "new", "Default", "EnableLogComponents", "delete"};

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
#endif
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<Wifi80211pHelper*>(obj))->SetStandard(arg2);
            break;
        }
        case INSTALL:
        {
            if ((nlhs != 1) || (nrhs > 5))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            WifiPhyHelper const & arg2 = *(reinterpret_cast<WifiPhyHelper*>(tst2->vptr));
            MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
            WifiMacHelper const & arg3 = *(reinterpret_cast<WifiMacHelper*>(tst3->vptr));
            MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
            NodeContainer arg4 = *(reinterpret_cast<NodeContainer*>(tst4->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            NetDeviceContainer *tmp = new NetDeviceContainer((reinterpret_cast<Wifi80211pHelper*>(obj))->Install(arg2, arg3, arg4));
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = NETDEVCONTOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case WIFI80211PHELPER:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Wifi80211pHelper *obj = new Wifi80211pHelper();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = WIFI80211PHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == WIFI80211PHELPOBJ)
                    delete reinterpret_cast<Wifi80211pHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        case DEFAULT:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Wifi80211pHelper *tmp = new Wifi80211pHelper(Wifi80211pHelper::Default());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = WIFI80211PHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case ENABLELOGCOMPONENTS:
        {
            if ((nlhs != 0) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Wifi80211pHelper::EnableLogComponents();
            break;
        }
        default:
            break;
    }
}
