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
    SETPROPAGATIONDELAY,
    ADDPROPAGATIONLOSS,
    YANSWIFICHANNELHELPER,
    CREATE,
    DEFAULT,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetPropagationDelay", "AddPropagationLoss", "new", "Create", "Default", "delete"};

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
        case SETPROPAGATIONDELAY:
        {
            if ((nlhs != 0) || (nrhs > 19))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            std::string arg2 = std::string(mxArrayToString(prhs[2]));
            std::string arg3 = std::string(mxArrayToString(prhs[3]));
            MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
            AttributeValue const & arg4 = *(reinterpret_cast<AttributeValue*>(tst4->vptr));
            std::string arg5 = std::string(mxArrayToString(prhs[5]));
            MemMngmt *tst6=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[6]))));
            AttributeValue const & arg6 = *(reinterpret_cast<AttributeValue*>(tst6->vptr));
            std::string arg7 = std::string(mxArrayToString(prhs[7]));
            MemMngmt *tst8=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[8]))));
            AttributeValue const & arg8 = *(reinterpret_cast<AttributeValue*>(tst8->vptr));
            std::string arg9 = std::string(mxArrayToString(prhs[9]));
            MemMngmt *tst10=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[10]))));
            AttributeValue const & arg10 = *(reinterpret_cast<AttributeValue*>(tst10->vptr));
            std::string arg11 = std::string(mxArrayToString(prhs[11]));
            MemMngmt *tst12=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[12]))));
            AttributeValue const & arg12 = *(reinterpret_cast<AttributeValue*>(tst12->vptr));
            std::string arg13 = std::string(mxArrayToString(prhs[13]));
            MemMngmt *tst14=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[14]))));
            AttributeValue const & arg14 = *(reinterpret_cast<AttributeValue*>(tst14->vptr));
            std::string arg15 = std::string(mxArrayToString(prhs[15]));
            MemMngmt *tst16=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[16]))));
            AttributeValue const & arg16 = *(reinterpret_cast<AttributeValue*>(tst16->vptr));
            std::string arg17 = std::string(mxArrayToString(prhs[17]));
            MemMngmt *tst18=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[18]))));
            AttributeValue const & arg18 = *(reinterpret_cast<AttributeValue*>(tst18->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<YansWifiChannelHelper*>(obj))->SetPropagationDelay(arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18);
            break;
        }
        case ADDPROPAGATIONLOSS:
        {
            if ((nlhs != 0) || (nrhs > 19))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            std::string arg2 = std::string(mxArrayToString(prhs[2]));
            std::string arg3 = std::string(mxArrayToString(prhs[3]));
            MemMngmt *tst4=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[4]))));
            AttributeValue const & arg4 = *(reinterpret_cast<AttributeValue*>(tst4->vptr));
            std::string arg5 = std::string(mxArrayToString(prhs[5]));
            MemMngmt *tst6=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[6]))));
            AttributeValue const & arg6 = *(reinterpret_cast<AttributeValue*>(tst6->vptr));
            std::string arg7 = std::string(mxArrayToString(prhs[7]));
            MemMngmt *tst8=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[8]))));
            AttributeValue const & arg8 = *(reinterpret_cast<AttributeValue*>(tst8->vptr));
            std::string arg9 = std::string(mxArrayToString(prhs[9]));
            MemMngmt *tst10=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[10]))));
            AttributeValue const & arg10 = *(reinterpret_cast<AttributeValue*>(tst10->vptr));
            std::string arg11 = std::string(mxArrayToString(prhs[11]));
            MemMngmt *tst12=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[12]))));
            AttributeValue const & arg12 = *(reinterpret_cast<AttributeValue*>(tst12->vptr));
            std::string arg13 = std::string(mxArrayToString(prhs[13]));
            MemMngmt *tst14=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[14]))));
            AttributeValue const & arg14 = *(reinterpret_cast<AttributeValue*>(tst14->vptr));
            std::string arg15 = std::string(mxArrayToString(prhs[15]));
            MemMngmt *tst16=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[16]))));
            AttributeValue const & arg16 = *(reinterpret_cast<AttributeValue*>(tst16->vptr));
            std::string arg17 = std::string(mxArrayToString(prhs[17]));
            MemMngmt *tst18=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[18]))));
            AttributeValue const & arg18 = *(reinterpret_cast<AttributeValue*>(tst18->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<YansWifiChannelHelper*>(obj))->AddPropagationLoss(arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18);
            break;
        }
        case YANSWIFICHANNELHELPER:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            YansWifiChannelHelper *obj = new YansWifiChannelHelper();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = YANSWIFICHANHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case CREATE:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Ptr<ns3::YansWifiChannel> *tmp = new Ptr<ns3::YansWifiChannel>((reinterpret_cast<YansWifiChannelHelper*>(obj))->Create());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = YANSWIFICHANOBJ_SP;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == YANSWIFICHANHELPOBJ)
                    delete reinterpret_cast<YansWifiChannelHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        case DEFAULT:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            YansWifiChannelHelper *tmp = new YansWifiChannelHelper(YansWifiChannelHelper::Default());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = YANSWIFICHANHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        default:
            break;
    }
}
