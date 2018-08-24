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

void *getElem(MemMngmt *obj)
{
    return obj->vptr;
}

typedef enum methodType
{
    MOBILITYHELPER,
    SETPOSITIONALLOCATOR,
    SETMOBILITYMODEL,
    PUSHREFERENCEMOBILITYMODEL,
    POPREFERENCEMOBILITYMODEL,
    GETMOBILITYMODELTYPE,
    INSTALL,
    INSTALLALL,
    ASSIGNSTREAMS,
    ENABLEASCII,
    ENABLEASCIIALL,
    GETDISTANCESQUAREDBETWEEN,
    DELETE,
    TOTAL_METHODS
}methodType_t;


static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"new", "SetPositionAllocator", "SetMobilityModel", "PushReferenceMobilityModel", "PopReferenceMobilityModel", "GetMobilityModelType", "Install", "InstallAll", "AssignStreams", "EnableAscii", "EnableAsciiAll", "GetDistanceSquaredBetween", "delete"};

methodType_t identifyMethod(const char* cmd)
{
    for(int i = 0; i < TOTAL_METHODS; i++)
    {
        if (!strcmp(methodNames[i], cmd))
            return methodType_t(i);
    }
    return TOTAL_METHODS;
}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (!MEXIsLoaded)
    {
        mexAtExit(cleanup);
        MEXIsLoaded = 1;
    }
    char cmd[CMD_BUFFER_SIZE];
    if (nrhs < 1 || mxGetString(prhs[INPUT_Command_String_Index], cmd, sizeof(cmd)))
    {
        mexErrMsgTxt("Check your inputs");
    }
    switch(identifyMethod(cmd))
    {
        case MOBILITYHELPER:
        {
            if ((nlhs != 1) || (nrhs != 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(new MobilityHelper());
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case SETPOSITIONALLOCATOR:
        {
            char subarg[128];
            if ((nlhs != 0) || (nrhs > 21))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            mxGetString(prhs[2], subarg, sizeof(subarg));
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
            std::string arg19 = std::string(mxArrayToString(prhs[19]));
            MemMngmt *tst20 =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[20]))));
            AttributeValue const & arg20 = *(reinterpret_cast<AttributeValue*>(tst20->vptr));
            
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<MobilityHelper*>(obj))->SetPositionAllocator(subarg, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20);
            break;
        }
        case SETMOBILITYMODEL:
        {
            char subarg[128];
            if ((nlhs != 0) || (nrhs != 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            mxGetString(prhs[2], subarg, sizeof(subarg));
            (reinterpret_cast<MobilityHelper*>(obj))->SetMobilityModel(subarg);
            break;
        }
        case PUSHREFERENCEMOBILITYMODEL:
        {
            break;
        }
        case POPREFERENCEMOBILITYMODEL:
        {
            break;
        }
        case GETMOBILITYMODELTYPE:
        {
            break;
        }
        case INSTALL:
        {
            if ((nlhs != 0) || (nrhs != 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            MemMngmt *tst3 =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[2]))));
            if (tst3->objType == NODECONTOBJ)
            {
                NodeContainer nc= *(reinterpret_cast<NodeContainer*>(tst3->vptr));
                (reinterpret_cast<MobilityHelper*>(obj))->Install(nc);
            }
            else if(tst3->objType == NODEOBJ_SP)
            {
                Ptr<ns3::Node> node = *(reinterpret_cast<Ptr<Node>*>(tst3->vptr));
                (reinterpret_cast<MobilityHelper*>(obj))->Install(node);
            }
            else
            {
                mexErrMsgTxt("MOBILITY HELPER INSTALLATION PROBLEM\n");
            }
            break;
        }
        case INSTALLALL:
        {
            break;
        }
        case ASSIGNSTREAMS:
        {
            break;
        }
        case ENABLEASCII:
        {
            break;
        }
        case ENABLEASCIIALL:
        {
            break;
        }
        case GETDISTANCESQUAREDBETWEEN:
        {
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if(obj)
            {
                if (obj->objType == MOBILITYHELPOBJ)
                {
                    delete reinterpret_cast<MobilityHelper*>(obj->vptr);
                }
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
