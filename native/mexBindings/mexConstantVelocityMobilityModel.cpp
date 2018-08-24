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
        return (void*)PeekPointer(*(reinterpret_cast<Ptr<ConstantVelocityMobilityModel>*>(obj->vptr)));
    else
        return obj->vptr;
}

typedef enum methodType
{
    SETVELOCITY,
    CONSTANTVELOCITYMOBILITYMODEL,
    DELETE,
    TOTAL_METHODS
}methodType_t;

static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SetVelocity", "new", "delete"};

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
    const mwSize *dims;
    /** gets the dimensions of the cell array */
    dims = mxGetDimensions(data);
    std::vector<double> vec;
    
    double * temp = mxGetPr(data);
    for( int j = 0; j < dims[1]; j++)
    {
        vec.push_back(temp[j]);
    }
    return Vector(vec[0], vec[1], vec[2]);
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
        case SETVELOCITY:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            Vector const & arg2 = convmxArrayToVector(prhs[2]);
            void *obj =  getElem(bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1])))));
            (reinterpret_cast<ConstantVelocityMobilityModel*>(obj))->SetVelocity(arg2);
            break;
        }
        case CONSTANTVELOCITYMOBILITYMODEL:
        {
            if ((nlhs != 1) || (nrhs > 1))
            {
                mexErrMsgTxt("enter correct number of input and output args");
            }
            ConstantVelocityMobilityModel *obj = new ConstantVelocityMobilityModel();
            MemMngmt *tst = bindMngrNewElem();
            tst->vptr = reinterpret_cast<void*>(obj);
            tst->objType = CONSTVMMOBJ;
            plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
            *((uint64_t *)mxGetData(plhs[0])) = reinterpret_cast<uint64_t>((MemMngmt*)tst);
            break;
        }
        case DELETE:
        {
            MemMngmt *obj =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            if (obj)
            {
                if (obj->objType == CONSTVMMOBJ)
                    delete reinterpret_cast<ConstantVelocityMobilityModel*>(obj->vptr);
                else
                    delete reinterpret_cast<Ptr<ConstantVelocityMobilityModel>*>(obj->vptr);
                bindMngrDelSingleElem(obj);
            }
            break;
        }
        default:
            break;
    }
}
