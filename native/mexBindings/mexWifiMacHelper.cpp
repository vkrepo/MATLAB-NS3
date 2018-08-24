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
    WIFIMACHELPER,
    SETTYPE,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"new", "SetType", "delete"};

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
        case WIFIMACHELPER:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            WifiMacHelper *obj = new WifiMacHelper();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = WIFIMACHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case SETTYPE:
        {
            if ((nlhs != 0) || (nrhs > 25))
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
            std::string arg19 = std::string(mxArrayToString(prhs[19]));
            MemMngmt *tst20=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[20]))));
            AttributeValue const & arg20 = *(reinterpret_cast<AttributeValue*>(tst20->vptr));
            std::string arg21 = std::string(mxArrayToString(prhs[21]));
            MemMngmt *tst22=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[22]))));
            AttributeValue const & arg22 = *(reinterpret_cast<AttributeValue*>(tst22->vptr));
            std::string arg23 = std::string(mxArrayToString(prhs[23]));
            MemMngmt *tst24=  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[24]))));
            AttributeValue const & arg24 = *(reinterpret_cast<AttributeValue*>(tst24->vptr));
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<WifiMacHelper*>(obj))->SetType(arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == WIFIMACHELPOBJ)
                    delete reinterpret_cast<WifiMacHelper*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
