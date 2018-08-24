// Copyright (C) Vamsi.  2017-18 All rights reserved.
// Source code based on yans-wifi-channel.cc of NS3

/*
 * Copyright (c) 2006,2007 INRIA
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author: Mathieu Lacage, <mathieu.lacage@sophia.inria.fr>
 */

#include "ns3/packet.h"
#include "ns3/simulator.h"
#include "ns3/mobility-model.h"
#include "ns3/net-device.h"
#include "ns3/node.h"
#include "ns3/ptr.h"
#include "ns3/log.h"
#include "ns3/pointer.h"
#include "ns3/object-factory.h"
#include "ml-wifi-channel.h"
#include "ns3/propagation-loss-model.h"
#include "ns3/propagation-delay-model.h"
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"
#include "ns3/network-module.h"

using namespace ns3;
NS_LOG_COMPONENT_DEFINE ("MatlabWifiChannel");

NS_OBJECT_ENSURE_REGISTERED (MatlabWifiChannel);

TypeId MatlabWifiChannel::GetTypeId (void)
{
	static TypeId tid = TypeId ("MatlabWifiChannel")
		.SetParent<WifiChannel> ()
		.AddConstructor<MatlabWifiChannel> ()
		.AddAttribute ("PropagationLossModel", "A pointer to the propagation loss model attached to this channel.",
				PointerValue (),
				MakePointerAccessor (&MatlabWifiChannel::m_loss),
				MakePointerChecker<ns3::PropagationLossModel> ())
		.AddAttribute ("PropagationDelayModel", "A pointer to the propagation delay model attached to this channel.",
				PointerValue (),
				MakePointerAccessor (&MatlabWifiChannel::m_delay),
				MakePointerChecker<ns3::PropagationDelayModel> ())
		;
	return tid;
}

MatlabWifiChannel::MatlabWifiChannel ()
{
}

MatlabWifiChannel::~MatlabWifiChannel ()
{
	NS_LOG_FUNCTION_NOARGS ();
	m_phyList.clear ();
}

void MatlabWifiChannel::SetPropagationLossModel (Ptr<ns3::PropagationLossModel> loss)
{
	m_loss = loss;
}

void MatlabWifiChannel::SetPropagationDelayModel (Ptr<ns3::PropagationDelayModel> delay)
{
	m_delay = delay;
}

void MatlabWifiChannel::Send (Ptr<MatlabWifiPhy> sender, Ptr<const ns3::Packet> packet, double txPowerLevel, double txGain, double rxGain, 
		WifiTxVector txVector, WifiPreamble preamble, enum mpduType mpdutype, Time duration) const
{
	NodeProperties sourceNode, destinationNode;
	PacketTxVector pktTxVector;
	Ptr<ns3::MobilityModel> senderMobility = sender->GetMobility ()->GetObject<MobilityModel> ();
	Vector senderPos = senderMobility->GetPosition ();
	Vector senderVel = senderMobility->GetVelocity ();
	NS_ASSERT (senderMobility != 0);
	uint32_t j = 0;

	if (txVector.GetMode ().GetModulationClass () == WIFI_MOD_CLASS_HT || txVector.GetMode ().GetModulationClass () == WIFI_MOD_CLASS_VHT)
	{
		pktTxVector.rateMcs = txVector.GetMode ().GetMcsValue ();
		pktTxVector.isNotLegacy = 1;
	}
	else
	{
		/* Value here is multipless of 500 Kbps units */
		pktTxVector.rateMcs = txVector.GetMode ().GetDataRate (txVector.GetChannelWidth (), txVector.IsShortGuardInterval (), 1) * txVector.GetNss () / 500000;
		pktTxVector.isNotLegacy = 0;
	}

	sourceNode.nodeId = ns3::Simulator::GetContext();
	sourceNode.location[0] = senderPos.x;
	sourceNode.location[1] = senderPos.y;
	sourceNode.location[2] = senderPos.z;
	sourceNode.velocity[0] = senderVel.x;
	sourceNode.velocity[1] = senderVel.y;
	sourceNode.velocity[2] = senderVel.z;
	sourceNode.powerLevel = txPowerLevel;
	sourceNode.txGain = txGain;

	for (PhyList::const_iterator i = m_phyList.begin (); i != m_phyList.end (); i++, j++)
	{
		if (sender != (*i))
		{
			//For now don't account for inter channel interference
			if ((*i)->GetChannelNumber () != sender->GetChannelNumber ())
			{
				continue;
			}

			/* Filling destination node details in a structure including its id,location,velocity,rxGain*/ 
			Ptr<ns3::MobilityModel> receiverMobility = (*i)->GetMobility ()->GetObject<MobilityModel> ();
			Vector receiverPos = receiverMobility->GetPosition ();
			Vector receiverVel = receiverMobility->GetVelocity ();
			destinationNode.nodeId = j;
			destinationNode.location[0] = receiverPos.x;
			destinationNode.location[1] = receiverPos.y;
			destinationNode.location[2] = receiverPos.z;
			destinationNode.velocity[0] = receiverVel.x;
			destinationNode.velocity[1] = receiverVel.y;
			destinationNode.velocity[2] = receiverVel.z;

			destinationNode.rxGain = rxGain;
			uint8_t *buffer = new uint8_t[packet->GetSize()];
			/* Copying the data from packet into buffer */
			packet->CopyData(buffer,packet->GetSize());
			int size = packet->GetSize();

			pktTxVector.channelWidth = txVector.GetChannelWidth ();
			/* Calling matlab callback */

			int64_t time  = ns3::Simulator::Now().GetMilliSeconds();
			double *WSTPacket = WSTCallback(buffer, size, &sourceNode, &destinationNode, &pktTxVector, time);

			// TODO:: Here we are comparing the packet but ideally CRC should be there.
			// Compare the modified packet and actual packet and set a flag to scehdule this packet or drop this packet.
			// Remember that MATLAB has already performed encoding and decoding.
			// The packet received here is the recovered packet

			uint8_t buffer2[packet->GetSize()];
			int flag = 0;
			int index = -1;
			for(int k=0; k<size; k++)
			{
				if((double )buffer[k] != WSTPacket[k])
				{
					index = k;
					flag = 1;
					break;
				}
			}
			/* if(flag == 1)
			   printf("The packet is corrupted at index %d\n",index);
			   else
			   printf("Packet is not corrupted\n"); */
			Time delay = m_delay->GetDelay (senderMobility, receiverMobility);

			/* Rx power DBM will be calculated on matlab and the value is sent to ns3 */
			double rxPowerDbm = WSTPacket[packet->GetSize()];
			Ptr<ns3::Packet> copy = packet->Copy ();
			Ptr<ns3::Object> dstNetDevice = m_phyList[j]->GetDevice ();
			uint32_t dstNode;
			if (dstNetDevice == 0)
			{
				dstNode = 0xffffffff;
			}
			else
			{
				dstNode = dstNetDevice->GetObject<ns3::NetDevice> ()->GetNode ()->GetId ();
			}

			struct MatlabParameters parameters;
			parameters.rxPowerDbm = rxPowerDbm;
			parameters.type = mpdutype;
			parameters.duration = duration;
			parameters.txVector = txVector;
			parameters.preamble = preamble;
			// std::cout<<ns3::Simulator::Now()<<std::endl;
			// WifiMode payloadMode = txVector.GetMode ();
			// std::cout<<"mode is"<<payloadMode<<std::endl;
			// std::cout<<"MCSvalue is"<<payloadMode.GetMcsValue ()<<std::endl;
			Simulator::ScheduleWithContext (dstNode,
					delay, &MatlabWifiChannel::Receive, this,
					j, copy, parameters, flag);
		}
	}
}

void MatlabWifiChannel::Receive (uint32_t i, Ptr<ns3::Packet> packet, struct MatlabParameters parameters, int flag) const
{
	m_phyList[i]->StartReceivePreambleAndHeader (packet, parameters.rxPowerDbm, parameters.txVector, parameters.preamble, parameters.type, parameters.duration, flag);
}

uint32_t MatlabWifiChannel::GetNDevices (void) const
{
	return m_phyList.size ();
}

Ptr<ns3::NetDevice> MatlabWifiChannel::GetDevice (uint32_t i) const
{
	return m_phyList[i]->GetDevice ()->GetObject<ns3::NetDevice> ();
}

void MatlabWifiChannel::Add (Ptr<MatlabWifiPhy> phy)
{
	m_phyList.push_back (phy);
}

int64_t MatlabWifiChannel::AssignStreams (int64_t stream)
{
	int64_t currentStream = stream;
	currentStream += m_loss->AssignStreams (stream);
	return (currentStream - stream);
}
void MatlabWifiChannel::SetMatlabWSTCallback(MATLAB_WST_CALLBACK matlabWSTCallback)
{
	WSTCallback = matlabWSTCallback;
}
