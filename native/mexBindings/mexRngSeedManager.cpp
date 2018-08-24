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
    SETSEED,
    SETRUN,
    GETNEXTSTREAMINDEX,
    GETSEED,
    GETRUN,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetSeed", "SetRun", "GetNextStreamIndex", "GetSeed", "GetRun"};

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
        case SETSEED:
        {
            if ((nlhs != 0) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg1 = (uint32_t) *mxGetPr(prhs[1]);
            RngSeedManager::SetSeed(arg1);
            break;
        }
        case SETRUN:
        {
            if ((nlhs != 0) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint64_t arg1 = (uint64_t) *mxGetPr(prhs[1]);
            RngSeedManager::SetRun(arg1);
            break;
        }
        case GETNEXTSTREAMINDEX:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint64_t output = RngSeedManager::GetNextStreamIndex();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETSEED:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t output = RngSeedManager::GetSeed();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETRUN:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint64_t output = RngSeedManager::GetRun();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        default:
            break;
    }
}
