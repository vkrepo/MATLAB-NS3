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
    if (obj->objType >= SMART_PTR_ENUM_START )
        return (void*)PeekPointer(*(reinterpret_cast<Ptr<Node>*>(obj->vptr)));
    else
        return obj->vptr;
}

typedef enum methodType
{
    NODE,
    GETAPPLICATION,
    ADDDEVICE,
    GETSYSTEMID,
    GETID,
    ADDAPPLICATION,
    GETNDEVICES,
    GETDEVICE,
    GETLOCALTIME,
    GETNAPPLICATIONS,
    CHECKSUMENABLED,
#ifdef MANUAL_CHANGE
    GETOBJECT,
#endif
    DELETE,
    TOTAL_METHODS
}methodType_t;


static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"new", "GetApplication", "AddDevice", "GetSystemId", "GetId", "AddApplication", "GetNDevices", "GetDevice", "GetLocalTime", "GetNApplications", "ChecksumEnabled",
#ifdef MANUAL_CHANGE
"GetObject",
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
        case NODE:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            switch(nrhs)
            {
                case 1:
                {
                    Node *obj = new Node();
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODEOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
                case 2:
                {
                    uint32_t arg2 = (uint32_t) *mxGetPr(prhs[1]);
                    Node *obj = new Node(arg2);
                    MemMngmt *tst = bindMngrNewElem();
                    tst->vptr = reinterpret_cast<void*>(obj);
                    tst->objType = NODEOBJ;
                    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                    *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
                    break;
                }
            }
            break;
        }
        case GETAPPLICATION:
        {
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Ptr<ns3::Application> *tmp = new Ptr<ns3::Application>((reinterpret_cast<Node*>(obj))->GetApplication(arg2));
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = APPOBJ_SP;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case ADDDEVICE:
        {
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            Ptr<ns3::NetDevice> arg2 = *(reinterpret_cast<Ptr<ns3::NetDevice>*>(tst2->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Node*>(obj))->AddDevice(arg2);
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETSYSTEMID:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Node*>(obj))->GetSystemId();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETID:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Node*>(obj))->GetId();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case ADDAPPLICATION:
        {
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst2=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            Ptr<ns3::Application> arg2 = *(reinterpret_cast<Ptr<ns3::Application>*>(tst2->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Node*>(obj))->AddApplication(arg2);
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETNDEVICES:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Node*>(obj))->GetNDevices();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
        case GETDEVICE:
        {
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            uint32_t arg2 = (uint32_t) *mxGetPr(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Ptr<ns3::NetDevice> *tmp = new Ptr<ns3::NetDevice>((reinterpret_cast<Node*>(obj))->GetDevice(arg2));
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = NETDEVOBJ_SP;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case GETLOCALTIME:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Time *tmp = new Time((reinterpret_cast<Node*>(obj))->GetLocalTime());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = TIMEOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case GETNAPPLICATIONS:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            uint32_t output = (reinterpret_cast<Node*>(obj))->GetNApplications();
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
                if (obj->objType == NODEOBJ)
                    delete reinterpret_cast<Node*>(obj->vptr);
                else
                    delete reinterpret_cast<Ptr<Node>*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        case CHECKSUMENABLED:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            bool output = Node::ChecksumEnabled();
            mxArray* temp = mxCreateDoubleMatrix(1, 1, mxREAL);
            *mxGetPr(temp) = output;
            plhs[0] = temp;
            break;
        }
#ifdef MANUAL_CHANGE
        case GETOBJECT:
        {
            char subarg[64];
            if ((nlhs != 1) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            mxGetString(prhs[2], subarg, sizeof(subarg));
            
            if(strcmp(subarg, "ns3::ConstantVelocityMobilityModel") == 0)
            {
                Ptr<ConstantVelocityMobilityModel> *cvmm = new Ptr<ConstantVelocityMobilityModel>((reinterpret_cast<Node*>(obj))->GetObject<ConstantVelocityMobilityModel>());
                MemMngmt *tst = bindMngrNewElem();
                tst->vptr = reinterpret_cast<void*>(cvmm);
                tst->objType = CONSTVMMOBJ_SP;
                plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            }
            else if(strcmp(subarg, "ns3::ConstantAccelerationMobilityModel") == 0)
            {
                Ptr<ConstantAccelerationMobilityModel> *camm = new Ptr<ConstantAccelerationMobilityModel>((reinterpret_cast<Node*>(obj))->GetObject<ConstantAccelerationMobilityModel>());
                MemMngmt *tst = bindMngrNewElem();
                tst->vptr = reinterpret_cast<void*>(camm);
                tst->objType = CONSTAMMOBJ_SP;
                plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            }
            else if(strcmp(subarg, "ns3::ConstantPositionMobilityModel") == 0)
            {
                Ptr<ConstantPositionMobilityModel> *cpmm = new Ptr<ConstantPositionMobilityModel>((reinterpret_cast<Node*>(obj))->GetObject<ConstantPositionMobilityModel>());
                MemMngmt *tst = bindMngrNewElem();
                tst->vptr = reinterpret_cast<void*>(cpmm);
                tst->objType = CONSTPMMOBJ_SP;
                plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            }
            else
            {
                plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
                *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)0);
            }
            break;
        }
#endif
        default:
            break;
    }
}
