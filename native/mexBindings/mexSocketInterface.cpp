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

const static uint16_t WSMP_PROT_NUMBER = 0x88DC;
std::string rxCallback;
static int MEXIsLoaded = 0;

void cleanup(void)
{
    MEXIsLoaded = 0;
}

#define MAX_RECV_BUFFER_SIZE 1500
bool ReceivePkt (Ptr<NetDevice> dev, Ptr<const Packet> pkt, uint16_t mode, const Address &sender)
{
    unsigned char buf[MAX_RECV_BUFFER_SIZE]= {0};
    
    /** Accept only if received packet size is less than max buffer size */
    if(pkt->GetSize() <= MAX_RECV_BUFFER_SIZE)
    {
        pkt->CopyData (&buf[0], pkt->GetSize());
        mxArray *mwPkt = mxCreateNumericMatrix(pkt->GetSize(), 1, mxUINT8_CLASS, mxREAL);
        
        mxArray *node_id = mxCreateDoubleMatrix(1, 1, mxREAL);
        *(mxGetPr(node_id)) = Simulator::GetContext();
        
        mxArray *protocol = mxCreateDoubleMatrix(1, 1, mxREAL);
        *(mxGetPr(protocol)) = mode;
        
        mxArray  *pkt_size = mxCreateDoubleMatrix(1, 1, mxREAL);
        *(mxGetPr(pkt_size)) = pkt->GetSize();
        
        unsigned char *startPtr = ((unsigned char*)(mxGetPr(mwPkt)));
        memcpy(startPtr,buf,pkt->GetSize());
        
        
        mxArray* args[] = {node_id, mwPkt, pkt_size, protocol};
        mexCallMATLABWithTrap(0, nullptr, 4, args, rxCallback.c_str());
    }
    return true;
}

typedef enum methodType
{
    SEND_PACKET,
    RECEIVE_PACKET,
    TOTAL_METHODS
}methodType_t;


static char methodNames[TOTAL_METHODS][CMD_BUFFER_SIZE] = {"SendPacket", "ReceivePacket"};

methodType_t identifyMethod(const char* cmd)
{
    for (int i = 0; i < TOTAL_METHODS; i++)
    {
        if (!strcmp(methodNames[i], cmd))
            return methodType_t(i);
    }
    return TOTAL_METHODS;
}


static void displayBuf(uint8_t buf[], int size)
{
    for(int j=0; j< size; j++)
        mexPrintf("%d\n", buf[j]);;
}
static void fillBufWithMxArray(const mxArray *data, uint8_t buf[])
{
    unsigned char   *pr;
    mwSize total_num_of_elements, index;
    
    pr = (unsigned char *)mxGetData(data);
    total_num_of_elements = mxGetNumberOfElements(data);
    for (index=0; index<total_num_of_elements; index++)
        buf[index] = *pr++;
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
        case SEND_PACKET:
        {
            if ((nlhs != 0) || (nrhs > 7))
            {
                mexErrMsgTxt("enter correct number of input and output args");
                return;
            }
            
            uint32_t bufLen = (uint32_t) *mxGetPr(prhs[2]);
            uint8_t buffer[bufLen] = {0};
            
            fillBufWithMxArray(prhs[1], buffer);
            //displayBuf(buffer, bufLen);
            Packet* obj;
            obj = new Packet(buffer, bufLen);
            SeqTsHeader seqTs;
            seqTs.SetSeq (1);
            obj->AddHeader (seqTs);
            uint32_t nodeId = (uint32_t) *mxGetPr(prhs[3]);
            uint32_t channel = (uint32_t) *mxGetPr(prhs[4]);
            
            char protNum[7]; // String like '0x88DC' so size 6+1
            char destAdd[18]; // String like 'FF:FF:FF:FF:FF:FF' 17+1
            mxGetString(prhs[5], protNum, sizeof(protNum));
            mxGetString(prhs[6], destAdd, sizeof(destAdd));
            Ptr<Node> node =  NodeList::GetNode(nodeId);
            Ptr<WaveNetDevice>  sender = DynamicCast<WaveNetDevice>(node->GetDevice(0));
            Mac48Address bssWildcard = Mac48Address(destAdd);
            const TxInfo txInfo(channel);
            if(strtol(protNum, NULL, 16) == WSMP_PROT_NUMBER)
            {
                sender->SendX  (obj, bssWildcard, WSMP_PROT_NUMBER, txInfo);
            }
            else
            {
                // TODO: Send NON-WSMP packet
            }
            
            break;
        }
        
        case RECEIVE_PACKET:
        {
            if ((nlhs != 0) || (nrhs > 3))
            {
                mexErrMsgTxt("enter correct number of input and output args");
                return;
            }
            rxCallback = std::string(mxArrayToString(prhs[2]));
            MemMngmt *tst2 =  bindMngrHasListElem ((MemMngmt *)(*((uint64_t *)mxGetData(prhs[1]))));
            NetDeviceContainer* const& netDevC = (reinterpret_cast<NetDeviceContainer*>(tst2->vptr));
            for (uint32_t i = 0; i != netDevC->GetN (); ++i)
            {
                /** dynamic casts netdevice to wave netdevice */
                Ptr<WaveNetDevice> device = DynamicCast<WaveNetDevice> (netDevC->Get (i));
                device->SetReceiveCallback (MakeCallback(&ReceivePkt)); /* enabled for wsm recv callback */
            }
            
            break;
        }
    }
}
