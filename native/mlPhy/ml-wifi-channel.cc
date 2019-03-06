// Copyright (C) Vamsi.  2017-19 All rights reserved.
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
#include "ns3/log.h"
#include "ns3/pointer.h"
#include "ns3/net-device.h"
#include "ns3/node.h"
#include "ns3/propagation-loss-model.h"
#include "ns3/propagation-delay-model.h"
#include "ns3/mobility-model.h"
#include "ml-wifi-channel.h"
#include "ml-wifi-phy.h"
#include "ns3/wifi-utils.h"
#include "ns3/ptr.h"
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"
#include "ns3/network-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("MatlabWifiChannel");

NS_OBJECT_ENSURE_REGISTERED (MatlabWifiChannel);

TypeId MatlabWifiChannel::GetTypeId (void)
{
	static TypeId tid = TypeId ("MatlabWifiChannel")
		.SetParent<Channel> ()
		.AddConstructor<MatlabWifiChannel> ()
		.AddAttribute ("PropagationLossModel", "A pointer to the propagation loss model attached to this channel.",
				PointerValue (),
				MakePointerAccessor (&MatlabWifiChannel::m_loss),
				MakePointerChecker<PropagationLossModel> ())
		.AddAttribute ("PropagationDelayModel", "A pointer to the propagation delay model attached to this channel.",
				PointerValue (),
				MakePointerAccessor (&MatlabWifiChannel::m_delay),
				MakePointerChecker<PropagationDelayModel> ())
		;
	return tid;
}

MatlabWifiChannel::MatlabWifiChannel ()
{
	NS_LOG_FUNCTION (this);
}

MatlabWifiChannel::~MatlabWifiChannel ()
{
	NS_LOG_FUNCTION (this);
	m_phyList.clear ();
}

void MatlabWifiChannel::SetPropagationLossModel (const Ptr<PropagationLossModel> loss)
{
	NS_LOG_FUNCTION (this << loss);
	m_loss = loss;
}

void MatlabWifiChannel::SetPropagationDelayModel (const Ptr<PropagationDelayModel> delay)
{
	NS_LOG_FUNCTION (this << delay);
	m_delay = delay;
}

void MatlabWifiChannel::Send (Ptr<MatlabWifiPhy> sender, Ptr<const Packet> packet, double txPowerLevel, double txGain, double rxGain, Time duration) const
{
	NS_LOG_FUNCTION (this << sender << packet << txPowerLevel << duration.GetSeconds ());
	NodeProperties sourceNode, destinationNode;
	PacketTxVector pktTxVector;
	Ptr<MobilityModel> senderMobility = sender->GetMobility();
	Vector senderPos = senderMobility->GetPosition ();
	Vector senderVel = senderMobility->GetVelocity ();
	NS_ASSERT (senderMobility != 0);
	uint32_t j = 0;

	/* Reading tag from packet to access txVector */
	WifiPhyTag tag;
	bool found = packet->PeekPacketTag (tag);
	if(!found){
		NS_FATAL_ERROR ("Received Wi-Fi Signal with no WifiPhyTag");
		return;
	}
	WifiTxVector txVector = tag.GetWifiTxVector();

	if (txVector.GetMode ().GetModulationClass () == WIFI_MOD_CLASS_HT || 
			txVector.GetMode ().GetModulationClass () == WIFI_MOD_CLASS_VHT)
	{
		pktTxVector.rateMcs = txVector.GetMode ().GetMcsValue ();
		pktTxVector.isNotLegacy = 1;
	}
	else
	{
		/* Value here is multiple of 500 Kbps units */
		pktTxVector.rateMcs = txVector.GetMode ().GetDataRate (txVector.GetChannelWidth (), txVector.GetGuardInterval (), 1) * txVector.GetNss () / 500000;
		pktTxVector.isNotLegacy = 0;
	}

	sourceNode.nodeId = Simulator::GetContext();
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
			//For now don't account for inter channel interference nor channel bonding
			if ((*i)->GetChannelNumber () != sender->GetChannelNumber ())
			{
				continue;
			}

			/* Filling destination node details in a structure including its id,location,velocity,rxGain*/ 
			Ptr<MobilityModel> receiverMobility = (*i)->GetMobility ()->GetObject<MobilityModel> ();

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
			/* Calling MATLAB callback */

			int64_t time  = Simulator::Now().GetMilliSeconds();
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

			Time delay = m_delay->GetDelay (senderMobility, receiverMobility);

			/* Decoded packet along with calculated Rx power in DBM and SNR-Watts will be returned from MATLAB */
			MatlabPhyInfo mlPhyInfo;
			double rxPowerDbm = WSTPacket[packet->GetSize()];
			mlPhyInfo.snrW = WSTPacket[packet->GetSize() + 1];
			mlPhyInfo.flag = flag;
			NS_LOG_DEBUG ("propagation: txPower=" << txPowerLevel << "dbm, rxPower=" << rxPowerDbm << "dbm, " <<
					"distance=" << senderMobility->GetDistanceFrom (receiverMobility) << "m, delay=" << delay);
			Ptr<Packet> copy = packet->Copy ();
			Ptr<NetDevice> dstNetDevice = (*i)->GetDevice ();
			uint32_t dstNode;
			if (dstNetDevice == 0)
			{
				dstNode = 0xffffffff;
			}
			else
			{
				dstNode = dstNetDevice->GetNode ()->GetId ();
			}

			Simulator::ScheduleWithContext (dstNode,
					delay, &MatlabWifiChannel::Receive,
					(*i), copy, rxPowerDbm, duration, mlPhyInfo);
		}
	}
}

void MatlabWifiChannel::Receive (Ptr<MatlabWifiPhy> phy, Ptr<Packet> packet, double rxPowerDbm, Time duration, MatlabPhyInfo mlPhyInfo)
{
	NS_LOG_FUNCTION (phy << packet << rxPowerDbm << duration.GetSeconds ());
	phy->StartReceivePreambleAndHeader (packet, DbmToW (rxPowerDbm + phy->GetRxGain ()), duration, mlPhyInfo);
}

std::size_t MatlabWifiChannel::GetNDevices (void) const
{
	return m_phyList.size ();
}

Ptr<NetDevice> MatlabWifiChannel::GetDevice (std::size_t i) const
{
	return m_phyList[i]->GetDevice ()->GetObject<NetDevice> ();
}

void MatlabWifiChannel::Add (Ptr<MatlabWifiPhy> phy)
{
	NS_LOG_FUNCTION (this << phy);
	m_phyList.push_back (phy);
}

int64_t MatlabWifiChannel::AssignStreams (int64_t stream)
{
	NS_LOG_FUNCTION (this << stream);
	int64_t currentStream = stream;
	currentStream += m_loss->AssignStreams (stream);
	return (currentStream - stream);
}

void MatlabWifiChannel::SetMatlabWSTCallback(MATLAB_WST_CALLBACK matlabWSTCallback)
{
	WSTCallback = matlabWSTCallback;
}

