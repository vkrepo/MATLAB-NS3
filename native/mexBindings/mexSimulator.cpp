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
    RUN,
    SCHEDULE,
    STOP,
    GETCONTEXT,
    CANCEL,
    DESTROY,
    NOW,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"Run", "Schedule", "Stop", "GetContext", "Cancel", "Destroy", "Now"};

methodType_t identifyMethod(const char* cmd)
{
    for (int i = 0; i < TOTAL_METHODS; i++)
    {
        if (!strcmp(methodNames[i], cmd))
            return methodType_t(i);
    }
    return TOTAL_METHODS;
}

#ifdef MANUAL_CHANGE
/**
 * this function will take two time variables and finds their difference
 * input: x, y
 * output: difference between time stamps
 */
double timeval_substract(struct timespec *x, struct timespec *y)
{
    double temp1 = 0 , temp2 = 0;
    temp1 = (double) ((x->tv_sec * 1000000000) + x->tv_nsec);
    temp2 = (double) ((y->tv_sec * 1000000000) + y->tv_nsec);
    return (temp2 - temp1);
}

/**
 * this is a function which calls MATLAB function on scheduled event times
 * inputs: buf, data
 */
void scheduleMatFunc(std::string buf, void* data)
{
    mxArray * args[] = {(mxArray*)data};
    mexCallMATLABWithTrap(0, nullptr, 1, args, buf.c_str());
    mxDestroyArray((mxArray*)data);
}
#endif

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
        case RUN:
        {
            if ((nlhs != 0) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Simulator::Run();
            break;
        }
        case SCHEDULE:
        {
#ifndef MANUAL_CHANGE
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 3:
                {
                    MemMngmt *tst1=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    Time const & arg1 = *(reinterpret_cast<Time*>(tst1->vptr));
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    void (*)(  ) * *arg2 = reinterpret_cast<void (*)(  ) **>(tst2->vptr);
                    EventId *tmp = new EventId(Simulator::Schedule(arg1, arg2));
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(tmp);
                    tst->objType = EVENTIDOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
#else
            if ((nlhs != 1) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            std::string buf = std::string(mxArrayToString(prhs[1]));
            double nextTime = *mxGetPr(prhs[2]);
            mxArray *f_handle = mxCreateStructMatrix(mxGetM(prhs[3]), mxGetN(prhs[3]), 0, NULL);
            for(int i = 0; i< mxGetNumberOfFields(prhs[3]); i++)
            {
                mxAddField(f_handle, mxGetFieldNameByNumber(prhs[3], i));
                mxArray * a = mxCreateDoubleMatrix(1,1,mxREAL);
                *(mxGetPr(a)) = 2;
                mxSetField(f_handle, 0, mxGetFieldNameByNumber(prhs[3], i), mxDuplicateArray(mxGetField(prhs[3], 0, mxGetFieldNameByNumber(prhs[3], i))));
            }
            mexMakeArrayPersistent(f_handle);
            EventId evObj = Simulator::Schedule(MilliSeconds(nextTime), &scheduleMatFunc, buf, (void *)f_handle);
            EventId * ev= new EventId();
            *ev = evObj;
            struct MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(ev);
            tst->objType = EVENTIDOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((struct MemMngmt*)tst);
#endif
            break;
        }
        case STOP:
        {
#ifndef MANUAL_CHANGE
            if ((nlhs != 0) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    Simulator::Stop();
                    break;
                }
                case 2:
                {
                    MemMngmt *tst1=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    Time const & arg1 = *(reinterpret_cast<Time*>(tst1->vptr));
                    Simulator::Stop(arg1);
                    break;
                }
            }
#else
            double simTime = *mxGetPr(prhs[1]);
            Simulator::Stop(Seconds(simTime));
#endif
            break;
        }
        case GETCONTEXT:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t output = Simulator::GetContext();
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
            MemMngmt *tst1=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            EventId const & arg1 = *(reinterpret_cast<EventId*>(tst1->vptr));
            Simulator::Cancel(arg1);
            break;
        }
        case DESTROY:
        {
            if ((nlhs != 0) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Simulator::Destroy();
            break;
        }
        case NOW:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
#ifndef MANUAL_CHANGE
            Time *tmp = new Time(Simulator::Now());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = TIMEOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
#else
            plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
            *(mxGetPr(plhs[0])) = Simulator::Now().GetSeconds();
#endif
            break;
        }
        default:
            break;
    }
}
