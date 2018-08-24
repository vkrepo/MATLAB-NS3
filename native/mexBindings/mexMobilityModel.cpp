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
        return (void*)PeekPointer(*(reinterpret_cast<Ptr<MobilityModel>*>(obj->vptr)));
    else
        return obj->vptr;
}

typedef enum methodType
{
    SETPOSITION,
    GETVELOCITY,
    GETPOSITION,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetPosition", "GetVelocity", "GetPosition"};

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
static Vector convmxArrayToVector(const mxArray *data)
{
    double value[3]={0};
    /** gets the dimensions of the cell array */
    const mwSize *dims = mxGetDimensions(data);
    
    double *temp = mxGetPr(data);
    for( int j = 0; j < dims[1]; j++)
    {
        value[j] = temp[j];
    }
    return Vector(value[0], value[1], value[2]);
}

static mxArray* convVectorTomxArray(Vector& data)
{
    mxArray* temp = mxCreateDoubleMatrix(1, 3, mxREAL);
    double * output = mxGetPr(temp);
    output[0] = data.x;
    output[1] = data.y;
    output[2] = data.z;
    return temp;
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
        case SETPOSITION:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Vector const & arg2 = convmxArrayToVector(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<MobilityModel*>(obj))->SetPosition(arg2);
            break;
        }
        case GETVELOCITY:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Vector output = (reinterpret_cast<MobilityModel*>(obj))->GetVelocity();
            plhs[0] = convVectorTomxArray(output);
            break;
        }
        case GETPOSITION:
        {
            if ((nlhs != 1) || (nrhs > 2))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            Vector output = (reinterpret_cast<MobilityModel*>(obj))->GetPosition();
            plhs[0] = convVectorTomxArray(output);
            break;
        }
        default:
            break;
    }
}
