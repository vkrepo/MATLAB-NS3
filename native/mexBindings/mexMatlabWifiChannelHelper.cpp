/*
 * Copyright (C) Vamsi.  2017-18 All rights reserved.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License version 2.
 */
#include "mex.h"
#include "mexNs3State.h"
#include "ml-wifi-channel.h"

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

static std::string callback;

typedef enum methodType
{
    CALLBACKREGISTRATION,
    SETPROPAGATIONDELAY,
    ADDPROPAGATIONLOSS,
    MATLABWIFICHANNELHELPER,
    CREATE,
    DEFAULT,
    DELETE,
    TOTAL_METHODS
}methodType_t;


static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"CallBackRegistration","SetPropagationDelay", "AddPropagationLoss", "new", "Create", "Default", "delete"};

double* WSTCallback(uint8_t *data, int size, NodeProperties *senderDetails, NodeProperties *receiverDetails, PacketTxVector *vector , int64_t time)
{
    double sendPos[3], recPos[3];
    double *dynamicData1, *dynamicData2, *dynamicData3, *dynamicData4, *dynamicData5, *dynamicData6, *dynamicData7, *dynamicData8;
    uint32_t *dynamicData9, *dynamicData10, *dynamicData11, *dynamicData12, *dynamicData13;
    int64_t *dynamicData14;
    const char *field_names[] = {"senderPosition", "receiverPosition", "powerLevel", 
	    "txGain", "rxGain", "senderVelocity", "receiverVelocity", "senderId", 
	    "receiverId", "rateMcs", "channelBW", "isNotLegacy"};
    int64_t nfields = 12;	//No. of elements in field_names array

    for(int i=0; i<3; i++)
    {
        sendPos[i] = senderDetails->location[i];
        recPos[i] =  receiverDetails->location[i];
    }
    mxArray *outArgs[1];
    dynamicData1 = (double*)mxMalloc(size * sizeof(double));
    dynamicData2 = (double*)mxMalloc(3 * sizeof(double));
    dynamicData3 = (double*)mxMalloc(3 * sizeof(double ));
    dynamicData4 = (double*)mxMalloc(sizeof(double));
    dynamicData5 = (double*)mxMalloc(sizeof(double));
    dynamicData6 = (double*)mxMalloc(sizeof(double));
    dynamicData7 = (double*)mxMalloc(3*sizeof(double));
    dynamicData8 = (double*)mxMalloc(3*sizeof(double));
    dynamicData9 = (uint32_t*)mxMalloc(sizeof(uint32_t));
    dynamicData10 = (uint32_t*)mxMalloc(sizeof(uint32_t));
    dynamicData11 = (uint32_t*)mxMalloc(sizeof(uint32_t));
    dynamicData12 = (uint32_t*)mxMalloc(sizeof(uint32_t));
    dynamicData13 = (uint32_t*)mxMalloc(sizeof(uint32_t));
    dynamicData14 = (int64_t *)mxMalloc(sizeof(int64_t));
    
    
    mxArray* txPacket = mxCreateNumericMatrix(1, size, mxDOUBLE_CLASS, mxREAL);
    mxArray* senderPosition = mxCreateNumericMatrix(1, 3, mxDOUBLE_CLASS, mxREAL);
    mxArray* receiverPosition = mxCreateNumericMatrix(1, 3, mxDOUBLE_CLASS, mxREAL);
    mxArray* powerLevel = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray* txGain = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray* rxGain = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray* senderVelocity = mxCreateNumericMatrix(1, 3, mxDOUBLE_CLASS, mxREAL);
    mxArray* receiverVelocity = mxCreateNumericMatrix(1, 3, mxDOUBLE_CLASS, mxREAL);
    mxArray* senderId = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    mxArray* receiverId = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    mxArray* rateMcs = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    mxArray* channelBW = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    mxArray* isNotLegacy = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    mxArray* timeStamp = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);

    mxArray* txParameters = mxCreateStructMatrix(1, 1, nfields, field_names);

    for(int i=0; i<size; i++)
    {
        dynamicData1[i]=data[i];
    }
    for(int i=0; i<3; i++)
    {
        dynamicData2[i]=sendPos[i];
        dynamicData3[i]=recPos[i];
    }
    *dynamicData4 = senderDetails->powerLevel;
    *dynamicData5 = senderDetails->txGain;
    *dynamicData6 = receiverDetails->rxGain;
    for(int i=0; i<3; i++)
    {
        dynamicData7[i] = senderDetails->velocity[i];
        dynamicData8[i] = receiverDetails->velocity[i];
    }
    *dynamicData9 = senderDetails->nodeId;
    *dynamicData10 = receiverDetails->nodeId;
    *dynamicData11 = vector->rateMcs;
    *dynamicData12 = vector->channelWidth;
    *dynamicData13 = vector->isNotLegacy;
    *dynamicData14 = time;
    
    mxSetData(txPacket, dynamicData1);
    mxSetData(senderPosition, dynamicData2);
    mxSetData(receiverPosition, dynamicData3);
    mxSetData(powerLevel, dynamicData4);
    mxSetData(txGain, dynamicData5);
    mxSetData(rxGain, dynamicData6);
    mxSetData(senderVelocity, dynamicData7);
    mxSetData(receiverVelocity, dynamicData8);
    mxSetData(senderId, dynamicData9);
    mxSetData(receiverId, dynamicData10);
    mxSetData(rateMcs, dynamicData11);
    mxSetData(channelBW, dynamicData12);
    mxSetData(isNotLegacy, dynamicData13);
    mxSetData(timeStamp, dynamicData14);

    mxSetFieldByNumber(txParameters, 0, 0, senderPosition);
    mxSetFieldByNumber(txParameters, 0, 1, receiverPosition);
    mxSetFieldByNumber(txParameters, 0, 2, powerLevel);
    mxSetFieldByNumber(txParameters, 0, 3, txGain);
    mxSetFieldByNumber(txParameters, 0, 4, rxGain);
    mxSetFieldByNumber(txParameters, 0, 5, senderVelocity);
    mxSetFieldByNumber(txParameters, 0, 6, receiverVelocity);
    mxSetFieldByNumber(txParameters, 0, 7, senderId);
    mxSetFieldByNumber(txParameters, 0, 8, receiverId);
    mxSetFieldByNumber(txParameters, 0, 9, rateMcs);
    mxSetFieldByNumber(txParameters, 0, 10, channelBW);
    mxSetFieldByNumber(txParameters, 0, 11, isNotLegacy);
    
    const char* matlabFunc = callback.c_str();
    mxArray* inputArgs[] = {txPacket, txParameters, timeStamp};
    mexCallMATLAB(1, outArgs, 3, inputArgs, matlabFunc);
    double *ptr = mxGetPr(outArgs[0]);
    return ptr;
}

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
        
        case CALLBACKREGISTRATION:
        {
            callback = std::string(mxArrayToString(prhs[2]));
            break;
        }
        
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
            void *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            (reinterpret_cast<MatlabWifiChannelHelper*>(obj))->SetPropagationDelay(arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18);
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
            (reinterpret_cast<MatlabWifiChannelHelper*>(obj))->AddPropagationLoss(arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18);
            break;
        }
        case MATLABWIFICHANNELHELPER:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            MatlabWifiChannelHelper *obj = new MatlabWifiChannelHelper();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = MATLABCHANHELPOBJ;
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
            (reinterpret_cast<MatlabWifiChannelHelper*>(obj))->RegisterWSTCallback(&WSTCallback);
            Ptr<MatlabWifiChannel> *arg2= new Ptr<MatlabWifiChannel>((reinterpret_cast<MatlabWifiChannelHelper*>(obj))->Create());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(arg2);
            tst->objType = MATLABCHANOBJ_SP;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if(obj)
            {
                if(obj->objType == MATLABCHANHELPOBJ)
                {
                    delete reinterpret_cast<MatlabWifiChannelHelper*>(obj->vptr);
                }
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
            MatlabWifiChannelHelper *tmp = new MatlabWifiChannelHelper(MatlabWifiChannelHelper::Default());
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(tmp);
            tst->objType = MATLABCHANHELPOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        default:
            break;
    }
}
