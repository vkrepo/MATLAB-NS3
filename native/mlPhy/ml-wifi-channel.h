// Copyright (C) Vamsi.  2017-19 All rights reserved.
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

#include "ns3/channel.h"
#include "ns3/ptr.h"
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"
#include "ns3/network-module.h"
#include "ns3/propagation-module.h"
#include "ml-wifi-phy.h"

using namespace ns3;

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

/**
 * MatlabPhyInfo contains packet error flag and SNR.
 * 	- flag of non-zero indicates that the packet should be dropped.
 * 	- snr indicates signal to noise ratio in W calculated in MATLAB
 */
struct MatlabPhyInfo
{
	int    flag;
	double snrW;
};

typedef double* (*MATLAB_WST_CALLBACK)(uint8_t *, int size,  NodeProperties *, NodeProperties *, PacketTxVector *, int64_t);
/**
 * \brief a channel to interconnect MatlabWifiPhy objects.
 * \ingroup wifi
 *
 * This class is expected to be used in tandem with the MatlabWifiPhy
 * class. By default no models are set; it is the user's responsibility
 * to set the models in MATLAB callback function.
 */
class MatlabWifiChannel : public Channel
{
	public:
		/**
		 * \brief Get the type ID.
		 * \return the object TypeId
		 */
		static TypeId GetTypeId (void);

		MatlabWifiChannel ();
		virtual ~MatlabWifiChannel ();

		//inherited from Channel.
		virtual std::size_t GetNDevices (void) const;
		virtual Ptr<NetDevice> GetDevice (std::size_t i) const;

		/**
		 * Adds the given MatlabWifiPhy to the PHY list
		 *
		 * \param phy the MatlabWifiPhy to be added to the PHY list
		 */
		void Add (Ptr<MatlabWifiPhy> phy);

		/**
		 * \param loss the new propagation loss model.
		 */
		void SetPropagationLossModel (const Ptr<PropagationLossModel> loss);
		/**
		 * \param delay the new propagation delay model.
		 */
		void SetPropagationDelayModel (const Ptr<PropagationDelayModel> delay);

		/**
		 * \param sender the phy object from which the packet is originating.
		 * \param packet the packet to send
		 * \param txPowerDbm the tx power associated to the packet, in dBm
		 * \param duration the transmission duration associated with the packet
		 *
		 * This method should not be invoked by normal users. It is
		 * currently invoked only from MatlabWifiPhy::StartTx.  The channel
		 * attempts to deliver the packet to all other MatlabWifiPhy objects
		 * on the channel (except for the sender).
		 */
		void Send (Ptr<MatlabWifiPhy> sender, Ptr<const Packet> packet, double txPowerLevel, double txGain, double rxGain, Time duration) const;

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
		 * \param receiver the device to which the packet is destined
		 * \param packet the packet being sent
		 * \param txPowerDbm the tx power associated to the packet being sent (dBm)
		 * \param duration the transmission duration associated with the packet being sent
		 * \param mlPhyInfo contains snr and flag
		 */
		static void Receive (Ptr<MatlabWifiPhy> receiver, Ptr<Packet> packet, double txPowerDbm, Time duration, MatlabPhyInfo mlPhyInfo);

		PhyList m_phyList;                   //!< List of MatlabWifiPhys connected to this MatlabWifiChannel
		Ptr<PropagationLossModel> m_loss;    //!< Propagation loss model
		Ptr<PropagationDelayModel> m_delay;  //!< Propagation delay model
};

#endif /* MATLAB_WIFI_CHANNEL_H */
