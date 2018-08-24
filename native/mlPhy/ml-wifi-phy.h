// Copyright (C) Vamsi.  2017-18 All rights reserved.
// Source code based on yans-wifi-phy.h of NS3

/*
 * Copyright (c) 2005,2006 INRIA
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
 * Authors: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
 *          Ghada Badawy <gbadawy@gmail.com>
 *          Sébastien Deronne <sebastien.deronne@gmail.com>
 */

#ifndef MATLAB_WIFI_PHY_H
#define MATLAB_WIFI_PHY_H

#include "ns3/wifi-phy.h"
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"

using namespace ns3;

class MatlabWifiChannel;
/**
 * \brief 802.11 PHY layer model
 * \ingroup wifi
 *
 * This PHY model depends on a channel loss and delay
 * model as provided by the ns3::PropagationLossModel
 * and ns3::PropagationDelayModel classes, both of which are
 * members of the ns3::MatlabWifiChannel class.
 */
class MatlabWifiPhy : public WifiPhy
{
	public:
		static TypeId GetTypeId (void);

		MatlabWifiPhy ();
		virtual ~MatlabWifiPhy ();

		/**
		 * Set the MatlabWifiChannel this MatlabWifiPhy is to be connected to.
		 *
		 * \param channel the MatlabWifiChannel this MatlabWifiPhy is to be connected to
		 */
		void SetChannel (Ptr<MatlabWifiChannel> channel);
		/**
		 * Starting receiving the plcp of a packet (i.e. the first bit of the preamble has arrived).
		 *
		 * \param packet the arriving packet
		 * \param rxPowerDbm the receive power in dBm
		 * \param txVector the TXVECTOR of the arriving packet
		 * \param preamble the preamble of the arriving packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::mpduType.
		 * \param rxDuration the duration needed for the reception of the packet
		 */
		void StartReceivePreambleAndHeader (Ptr<ns3::Packet> packet,
				double rxPowerDbm,
				WifiTxVector txVector,
				WifiPreamble preamble,
				enum mpduType mpdutype,
				Time rxDuration, 
				int flag);
		/**
		 * Starting receiving the payload of a packet (i.e. the first bit of the packet has arrived).
		 *
		 * \param packet the arriving packet
		 * \param txVector the TXVECTOR of the arriving packet
		 * \param preamble the preamble of the arriving packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::mpduType.
		 * \param event the corresponding event of the first time the packet arrives
		 */
		void StartReceivePacket (Ptr<ns3::Packet> packet,
				WifiTxVector txVector,
				WifiPreamble preamble,
				enum mpduType mpdutype,
				int flag);

		virtual void SetReceiveOkCallback (WifiPhy::RxOkCallback callback);
		virtual void SetReceiveErrorCallback (WifiPhy::RxErrorCallback callback);
		virtual void SendPacket (Ptr<const ns3::Packet> packet, WifiTxVector txVector, enum WifiPreamble preamble);
		virtual void SendPacket (Ptr<const ns3::Packet> packet, WifiTxVector txVector, enum WifiPreamble preamble, enum mpduType mpdutype);
		//virtual void SendPacketToMwPhy(Ptr<const Packet> packet, WifiTxVector txVector, enum WifiPreamble preamble, enum mpduType mpdutype);
		virtual void RegisterListener (WifiPhyListener *listener);
		virtual void UnregisterListener (WifiPhyListener *listener);
		virtual void SetSleepMode (void);
		virtual void ResumeFromSleep (void);
		virtual Ptr<ns3::WifiChannel> GetChannel (void) const;

	protected:
		// Inherited
		virtual void DoDispose (void);
		virtual bool DoChannelSwitch (uint16_t id);
		virtual bool DoFrequencySwitch (uint32_t frequency);

	private:

		/**
		 * The last bit of the packet has arrived.
		 *
		 * \param packet the packet that the last bit has arrived
		 * \param preamble the preamble of the arriving packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::mpduType.
		 * \param event the corresponding event of the first time the packet arrives
		 */
		void EndReceive (Ptr<ns3::Packet> packet, enum WifiPreamble preamble, enum mpduType mpdutype, Ptr<ns3::InterferenceHelper::Event> event, int flag);
		Ptr<MatlabWifiChannel> m_channel;        //!< MatlabWifiChannel that this MatlabWifiPhy is connected to
};


#endif /* MATLAB_WIFI_PHY_H */
