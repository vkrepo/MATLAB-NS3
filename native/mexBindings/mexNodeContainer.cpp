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
    CREATE,
    NODECONTAINER,
    ADD,
    GETN,
    GET,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"Create", "new", "Add", "GetN", "Get", "delete"};

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
        case CREATE:
        {
            if ((nlhs != 0) || (nrhs > 4))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 3:
                {
                    uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
                    (reinterpret_cast<NodeContainer*>(obj))->Create(arg2);
                    break;
                }
                case 4:
                {
                    uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
                    uint32_t arg3 = (uint32_t) *mxGetPr(prhs[3]);
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
                    (reinterpret_cast<NodeContainer*>(obj))->Create(arg2, arg3);
                    break;
                }
            }
            break;
        }
        case NODECONTAINER:
        {
            if ((nlhs != 1) || (nrhs > 6))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    NodeContainer *obj = new NodeContainer();
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODECONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 2:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    Ptr<ns3::Node> arg2 = *(reinterpret_cast<Ptr<ns3::Node>*>(tst2->vptr));
                    NodeContainer *obj = new NodeContainer(arg2);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODECONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 3:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    NodeContainer const & arg2 = *(reinterpret_cast<NodeContainer*>(tst2->vptr));
                    MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    NodeContainer const & arg3 = *(reinterpret_cast<NodeContainer*>(tst3->vptr));
                    NodeContainer *obj = new NodeContainer(arg2, arg3);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODECONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 4:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    NodeContainer const & arg2 = *(reinterpret_cast<NodeContainer*>(tst2->vptr));
                    MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    NodeContainer const & arg3 = *(reinterpret_cast<NodeContainer*>(tst3->vptr));
                    MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
                    NodeContainer const & arg4 = *(reinterpret_cast<NodeContainer*>(tst4->vptr));
                    NodeContainer *obj = new NodeContainer(arg2, arg3, arg4);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODECONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 5:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    NodeContainer const & arg2 = *(reinterpret_cast<NodeContainer*>(tst2->vptr));
                    MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    NodeContainer const & arg3 = *(reinterpret_cast<NodeContainer*>(tst3->vptr));
                    MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
                    NodeContainer const & arg4 = *(reinterpret_cast<NodeContainer*>(tst4->vptr));
                    MemMngmt *tst5=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
                    NodeContainer const & arg5 = *(reinterpret_cast<NodeContainer*>(tst5->vptr));
                    NodeContainer *obj = new NodeContainer(arg2, arg3, arg4, arg5);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODECONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 6:
                {
                    MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
                    NodeContainer const & arg2 = *(reinterpret_cast<NodeContainer*>(tst2->vptr));
                    MemMngmt *tst3=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
                    NodeContainer const & arg3 = *(reinterpret_cast<NodeContainer*>(tst3->vptr));
                    MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[3]))));
                    NodeContainer const & arg4 = *(reinterpret_cast<NodeContainer*>(tst4->vptr));
                    MemMngmt *tst5=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
                    NodeContainer const & arg5 = *(reinterpret_cast<NodeContainer*>(tst5->vptr));
                    MemMngmt *tst6=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[5]))));
                    NodeContainer const & arg6 = *(reinterpret_cast<NodeContainer*>(tst6->vptr));
                    NodeContainer *obj = new NodeContainer(arg2, arg3, arg4, arg5, arg6);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODECONTOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
            break;
        }
        case ADD:
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
                    NodeContainer arg2 = *(reinterpret_cast<NodeContainer*>(tst2->vptr));
                    void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
                    (reinterpret_cast<NodeContainer*>(obj))->Add(arg2);
                    break;
                }
            }
            break;
        }
        case GETN:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<NodeContainer*>(obj))->GetN();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GET:
        {
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Ptr<ns3::Node> *tmp = new Ptr<ns3::Node>((reinterpret_cast<NodeContainer*>(obj))->Get(arg2));
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = NODEOBJ_SP;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == NODECONTOBJ)
                    delete reinterpret_cast<NodeContainer*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
