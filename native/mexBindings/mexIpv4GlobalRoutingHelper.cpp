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
    IPV4GLOBALROUTINGHELPER,
    RECOMPUTEROUTINGTABLES,
    POPULATEROUTINGTABLES,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"new", "RecomputeRoutingTables", "PopulateRoutingTables", "delete"};

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
        case IPV4GLOBALROUTINGHELPER:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    Ipv4GlobalRoutingHelper *obj = new Ipv4GlobalRoutingHelper();
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = IPV4GRH;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 2:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    Ipv4GlobalRoutingHelper const & arg2 = *(reinterpret_cast<Ipv4GlobalRoutingHelper*>(tst2->vptr));
                    Ipv4GlobalRoutingHelper *obj = new Ipv4GlobalRoutingHelper(arg2);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = IPV4GRH;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == IPV4GRH)
                    delete reinterpret_cast<Ipv4GlobalRoutingHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        case RECOMPUTEROUTINGTABLES:
        {
            if ((nlhs != 0) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Ipv4GlobalRoutingHelper::RecomputeRoutingTables();
            break;
        }
        case POPULATEROUTINGTABLES:
        {
            if ((nlhs != 0) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Ipv4GlobalRoutingHelper::PopulateRoutingTables();
            break;
        }
        default:
            break;
    }
}
