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
    EVENTID,
    ISRUNNING,
    GETCONTEXT,
    CANCEL,
    GETUID,
    ISEXPIRED,
    GETTS,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"new", "IsRunning", "GetContext", "Cancel", "GetUid", "IsExpired", "GetTs", "delete"};

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
        case EVENTID:
        {
            if ((nlhs != 1) || (nrhs > 5))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    EventId *obj = new EventId();
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = EVENTIDOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 5:
                {
#ifndef MANUAL_CHANGE
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    Ptr<ns3::EventImpl> const & arg2 = *(reinterpret_cast<EventImpl*>(tst2->vptr));
                    uint64_t arg3 = (uint64_t) *mxGetPr(prhs[2]);
                    uint32_t arg4 = (uint32_t) *mxGetPr(prhs[3]);
                    uint32_t arg5 = (uint32_t) *mxGetPr(prhs[4]);
                    EventId *obj = new EventId(arg2, arg3, arg4, arg5);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = EVENTIDOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
#endif
                    break;
                }
            }
            break;
        }
        case ISRUNNING:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            bool output = (reinterpret_cast<EventId*>(obj))->IsRunning();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETCONTEXT:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<EventId*>(obj))->GetContext();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case CANCEL:
        {
            if ((nlhs != 0) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<EventId*>(obj))->Cancel();
            break;
        }
        case GETUID:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<EventId*>(obj))->GetUid();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case ISEXPIRED:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            bool output = (reinterpret_cast<EventId*>(obj))->IsExpired();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETTS:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint64_t output = (reinterpret_cast<EventId*>(obj))->GetTs();
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
                if (obj->objType == EVENTIDOBJ)
                    delete reinterpret_cast<EventId*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
