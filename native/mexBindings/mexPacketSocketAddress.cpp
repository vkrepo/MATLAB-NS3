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
    SETPHYSICALADDRESS,
    SETSINGLEDEVICE,
    PACKETSOCKETADDRESS,
    SETPROTOCOL,
#ifdef MANUAL_CHANGE
    GETADDRESSOPERATOR,
#endif
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetPhysicalAddress", "SetSingleDevice", "new", "SetProtocol",
#ifdef MANUAL_CHANGE
"GetAddressOperator",
#endif
"delete"};

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
        case SETPHYSICALADDRESS:
        {
#ifndef MANUAL_CHANGE
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            Address const arg2 = *(reinterpret_cast<Address const*>(tst2->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<PacketSocketAddress*>(obj))->SetPhysicalAddress(arg2);
#else
            if ((nlhs != 0) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            
            MemMngmt *tst2 =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            NetDeviceContainer ndev = *(reinterpret_cast<NetDeviceContainer*>(tst2->vptr));
            
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[3]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<PacketSocketAddress*>(obj))->SetPhysicalAddress(ndev.Get(arg2)->GetAddress());
#endif
            break;
        }
        case SETSINGLEDEVICE:
        {
#ifndef MANUAL_CHANGE
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<PacketSocketAddress*>(obj))->SetSingleDevice(arg2);
#else
            if ((nlhs != 0) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2 =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            NetDeviceContainer ndev = *(reinterpret_cast<NetDeviceContainer*>(tst2->vptr));
            
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[3]);
            void *obj =  getElem(bindMngrHasListElem((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<PacketSocketAddress*>(obj))->SetSingleDevice(ndev.Get(arg2)->GetIfIndex());
#endif
            break;
        }
        case PACKETSOCKETADDRESS:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            PacketSocketAddress *obj = new PacketSocketAddress();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = PACKETSOCKADDROBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case SETPROTOCOL:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint16_t arg2 = (uint16_t) *mxGetPr(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<PacketSocketAddress*>(obj))->SetProtocol(arg2);
            break;
        }
#ifdef MANUAL_CHANGE
        case GETADDRESSOPERATOR:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Address ad = Address(*(reinterpret_cast<PacketSocketAddress*>(obj)));
            Address *addr = new Address(ad);
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(addr);
            tst->objType = ADDROBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
        }
#endif
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == PACKETSOCKADDROBJ)
                    delete reinterpret_cast<PacketSocketAddress*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
