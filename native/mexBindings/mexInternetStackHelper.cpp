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
    INSTALLALL,
    INTERNETSTACKHELPER,
    INSTALL,
    SETROUTINGHELPER,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"InstallAll", "new", "Install", "SetRoutingHelper", "delete"};

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
        case INSTALLALL:
        {
            if ((nlhs != 0) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<InternetStackHelper*>(obj))->InstallAll();
            break;
        }
        case INTERNETSTACKHELPER:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    InternetStackHelper *obj = new InternetStackHelper();
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = INTERNETSTACKHELPOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 2:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    InternetStackHelper const & arg2 = *(reinterpret_cast<InternetStackHelper*>(tst2->vptr));
                    InternetStackHelper *obj = new InternetStackHelper(arg2);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = INTERNETSTACKHELPOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
            break;
        }
        case INSTALL:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 3:
                {
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
#ifndef MANUAL_CHANGE
                    std::string arg2 = std::string(mxArrayToString(prhs[2]));
#else
                    MemMngmt *tst = bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    if (tst->objType == NODEOBJ_SP)
                    {
                        Ptr<Node> arg2 = *(reinterpret_cast<Ptr<Node>*>(tst->vptr));
                        (reinterpret_cast<InternetStackHelper*>(obj))->Install(arg2);
                    }
                    else if (tst->objType == NODECONTOBJ)
                    {
                        NodeContainer arg2 = *(reinterpret_cast<NodeContainer*>(tst->vptr));
                        (reinterpret_cast<InternetStackHelper*>(obj))->Install(arg2);
                    }
                    else
                        mexErrMsgTxt("error in internet stack installation");
#endif
                    break;
                }
            }
            break;
        }
        case SETROUTINGHELPER:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 3:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    Ipv4RoutingHelper const & arg2 = *(reinterpret_cast<Ipv4RoutingHelper*>(tst2->vptr));
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
                    (reinterpret_cast<InternetStackHelper*>(obj))->SetRoutingHelper(arg2);
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
                if (obj->objType == INTERNETSTACKHELPOBJ)
                    delete reinterpret_cast<InternetStackHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
