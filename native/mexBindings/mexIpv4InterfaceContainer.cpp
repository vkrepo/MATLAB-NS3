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
    GETADDRESS,
    ADD,
    IPV4INTERFACECONTAINER,
    GETN,
    SETMETRIC,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"GetAddress", "Add", "new", "GetN", "SetMetric", "delete"};

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
        case GETADDRESS:
        {
            if ((nlhs != 1) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
            uint32_t arg3 = (uint32_t) *mxGetPr(prhs[3]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Ipv4Address *output = new Ipv4Address((reinterpret_cast<Ipv4InterfaceContainer*>(obj))->GetAddress(arg2, arg3));
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(output);
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case ADD:
        {
            if ((nlhs != 0) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 3:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    Ipv4InterfaceContainer const & arg2 = *(reinterpret_cast<Ipv4InterfaceContainer*>(tst2->vptr));
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
                    (reinterpret_cast<Ipv4InterfaceContainer*>(obj))->Add(arg2);
                    break;
                }
                case 4:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    Ptr<ns3::Ipv4> arg2 = *(reinterpret_cast<Ptr<ns3::Ipv4>*>(tst2->vptr));
                    uint32_t arg3 = (uint32_t) *mxGetPr(prhs[3]);
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
                    (reinterpret_cast<Ipv4InterfaceContainer*>(obj))->Add(arg2, arg3);
                    break;
                }
            }
            break;
        }
        case IPV4INTERFACECONTAINER:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Ipv4InterfaceContainer *obj = new Ipv4InterfaceContainer();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = IPV4INTERFACEHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case GETN:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Ipv4InterfaceContainer*>(obj))->GetN();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case SETMETRIC:
        {
            if ((nlhs != 0) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
            uint16_t arg3 = (uint16_t) *mxGetPr(prhs[3]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<Ipv4InterfaceContainer*>(obj))->SetMetric(arg2, arg3);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == IPV4INTERFACEHELPOBJ)
                    delete reinterpret_cast<Ipv4InterfaceContainer*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
