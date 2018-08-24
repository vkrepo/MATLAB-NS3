// Copyright (C) Vamsi.  2017-18 All rights reserved.
// Source code based on yans-wifi-channel.h of NS3

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

#ifndef MATLAB_WIFI_CHANNEL_H
#define MATLAB_WIFI_CHANNEL_H

#include <vector>
#include <stdint.h>
#include "ns3/packet.h"
#include "ns3/wifi-channel.h"
#include "ns3/wifi-mode.h"
#include "ns3/wifi-preamble.h"
#include "ns3/wifi-tx-vector.h"
#include "ml-wifi-phy.h"
#include "ns3/nstime.h"
#include "ns3/ptr.h"
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"
#include "ns3/network-module.h"
#include "ns3/propagation-module.h"

using namespace ns3;

class NetDevice;
class PropagationLossModel;
class PropagationDelayModel;

struct MatlabParameters
{
	double rxPowerDbm;
	enum mpduType type;
	Time duration;
	WifiTxVector txVector;
	WifiPreamble preamble;
};

struct NodeProperties
{
	uint32_t nodeId;
	double location[3];
	double velocity[3];
	double powerLevel;
	double txGain;
	double rxGain;
};

struct PacketTxVector
{
	int isNotLegacy;
	int rateMcs;
	int channelWidth;
};

typedef double* (*MATLAB_WST_CALLBACK)(uint8_t *, int size,  NodeProperties *, NodeProperties *, PacketTxVector *, int64_t);
/**
 * \brief A Matlab wifi channel
 * \ingroup wifi
 *
 * This class is expected to be used in tandem with the ns3::MatlabWifiPhy
 * class and contains a ns3::PropagationLossModel and a ns3::PropagationDelayModel.
 * By default, no propagation models are set so, it is the caller's responsability
 * to set them before using the channel.
 */
class MatlabWifiChannel : public WifiChannel
{
	public:
		static TypeId GetTypeId (void);

		MatlabWifiChannel ();
		virtual ~MatlabWifiChannel ();

		//inherited from Channel.
		virtual uint32_t GetNDevices (void) const;
		virtual Ptr<ns3::NetDevice> GetDevice (uint32_t i) const;

		/**
		 * Adds the given MatlabWifiPhy to the PHY list
		 *
		 * \param phy the MatlabWifiPhy to be added to the PHY list
		 */
		void Add (Ptr<MatlabWifiPhy> phy);

		/**
		 * \param loss the new propagation loss model.
		 */
		void SetPropagationLossModel (Ptr<ns3::PropagationLossModel> loss);
		/**
		 * \param delay the new propagation delay model.
		 */
		void SetPropagationDelayModel (Ptr<ns3::PropagationDelayModel> delay);

		/**
		 * \param sender the device from which the packet is originating.
		 * \param packet the packet to send
		 * \param txPowerDbm the tx power associated to the packet
		 * \param txVector the TXVECTOR associated to the packet
		 * \param preamble the preamble associated to the packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::mpduType.
		 * \param duration the transmission duration associated to the packet
		 *
		 * This method should not be invoked by normal users. It is
		 * currently invoked only from WifiPhy::Send. MatlabWifiChannel
		 * delivers packets only between PHYs with the same m_channelNumber,
		 * e.g. PHYs that are operating on the same channel.
		 */
		void Send (Ptr<MatlabWifiPhy> sender, Ptr<const ns3::Packet> packet, double txPowerLevel, double txGain, double rxGain,
				WifiTxVector txVector, WifiPreamble preamble, enum mpduType mpdutype, Time duration) const;

		/**
		 * Assign a fixed random variable stream number to the random variables
		 * used by this model.  Return the number of streams (possibly zero) that
		 * have been assigned.
		 *
		 * \param stream first stream index to use
		 *
		 * \return the number of stream indices assigned by this model
		 */
		int64_t AssignStreams (int64_t stream);
		MATLAB_WST_CALLBACK WSTCallback;

		void SetMatlabWSTCallback(MATLAB_WST_CALLBACK matlabWSTCallback); 

	private:
		/**
		 * A vector of pointers to MatlabWifiPhy.
		 */
		typedef std::vector<Ptr<MatlabWifiPhy> > PhyList;

		/**
		 * This method is scheduled by Send for each associated MatlabWifiPhy.
		 * The method then calls the corresponding MatlabWifiPhy that the first
		 * bit of the packet has arrived.
		 *
		 * \param i index of the corresponding MatlabWifiPhy in the PHY list
		 * \param packet the packet being sent
		 * \param atts a vector containing the received power in dBm and the packet type
		 * \param txVector the TXVECTOR of the packet
		 * \param preamble the type of preamble being used to send the packet
		 */
		void Receive (uint32_t i, Ptr<ns3::Packet> packet, struct MatlabParameters parameters, int flag) const;

		PhyList m_phyList;                   //!< List of MatlabWifiPhys connected to this MatlabWifiChannel
		Ptr<ns3::PropagationLossModel> m_loss;    //!< Propagation loss model
		Ptr<ns3::PropagationDelayModel> m_delay;  //!< Propagation delay model
};

#endif /* MATLAB_WIFI_CHANNEL_H */
