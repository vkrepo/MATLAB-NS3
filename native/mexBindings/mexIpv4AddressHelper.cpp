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
    SETBASE,
    IPV4ADDRESSHELPER,
    ASSIGN,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetBase", "new", "Assign", "delete"};

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
        case SETBASE:
        {
            if ((nlhs != 0) || (nrhs > 5))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
#ifndef MANUAL_CHANGE
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            Ipv4Address arg2 = *(reinterpret_cast<Ipv4Address*>(tst2->vptr));
            MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
            Ipv4Mask arg3 = *(reinterpret_cast<Ipv4Mask*>(tst3->vptr));
            MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
            Ipv4Address arg4 = *(reinterpret_cast<Ipv4Address*>(tst4->vptr));
            (reinterpret_cast<Ipv4AddressHelper*>(obj))->SetBase(arg2, arg3, arg4);
#else
            std::string arg2 = std::string(mxArrayToString(prhs[2]));
            std::string arg3 = std::string(mxArrayToString(prhs[3]));
            std::string arg4 = std::string(mxArrayToString(prhs[4]));
            (reinterpret_cast<Ipv4AddressHelper*>(obj))->SetBase(arg2.c_str(), arg3.c_str(), arg4.c_str());
#endif
            break;
        }
        case IPV4ADDRESSHELPER:
        {
            if ((nlhs != 1) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    Ipv4AddressHelper *obj = new Ipv4AddressHelper();
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = IPV4ADDRHELPOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 4:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    Ipv4Address arg2 = *(reinterpret_cast<Ipv4Address*>(tst2->vptr));
                    MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    Ipv4Mask arg3 = *(reinterpret_cast<Ipv4Mask*>(tst3->vptr));
                    MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
                    Ipv4Address arg4 = *(reinterpret_cast<Ipv4Address*>(tst4->vptr));
                    Ipv4AddressHelper *obj = new Ipv4AddressHelper(arg2, arg3, arg4);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = IPV4ADDRHELPOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
            break;
        }
        case ASSIGN:
        {
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            NetDeviceContainer const & arg2 = *(reinterpret_cast<NetDeviceContainer*>(tst2->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Ipv4InterfaceContainer *tmp = new Ipv4InterfaceContainer((reinterpret_cast<Ipv4AddressHelper*>(obj))->Assign(arg2));
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = IPV4INTERFACEHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == IPV4ADDRHELPOBJ)
                    delete reinterpret_cast<Ipv4AddressHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
