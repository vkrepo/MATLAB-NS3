// Copyright (C) Vamsi.  2017-19 All rights reserved.
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
#include "ns3/interference-helper.h"

using namespace ns3;

class MatlabWifiChannel;

/**
 * \brief 802.11 PHY layer model
 * \ingroup wifi
 *
 * This PHY model depends on a channel loss and delay
 * model as provided in the MATLAB callback function, 
 * which is part of the MatlabWifiChannel class.
 */
class MatlabWifiPhy : public WifiPhy
{
	public:
		/**
		 * \brief Get the type ID.
		 * \return the object TypeId
		 */
		static TypeId GetTypeId (void);

		MatlabWifiPhy ();
		virtual ~MatlabWifiPhy ();

		/**
		 * Set the MatlabWifiChannel this MatlabWifiPhy is to be connected to.
		 *
		 * \param channel the MatlabWifiChannel this MatlabWifiPhy is to be connected to
		 */
		void SetChannel (const Ptr<MatlabWifiChannel> channel);

		/**
		 * \param packet the packet to send
		 * \param txVector the TXVECTOR that has tx parameters such as mode, the transmission mode to use to send
		 *        this packet, and txPowerLevel, a power level to use to send this packet. The real transmission
		 *        power is calculated as txPowerMin + txPowerLevel * (txPowerMax - txPowerMin) / nTxLevels
		 * \param txDuration duration of the transmission.
		 */
		void StartTx (Ptr<Packet> packet, WifiTxVector txVector, Time txDuration);

		virtual Ptr<Channel> GetChannel (void) const;

		//Overloading methods present in wifi-phy
		/**
		 * Starting receiving the plcp of a packet (i.e. the first bit of the preamble has arrived).
		 *
		 * \param packet the arriving packet
		 * \param rxPowerW the receive power in dBm
		 * \param rxDuration the duration needed for the reception of the packet
		 * \param mlPhyInfo contains snr and flag
		 */
		void StartReceivePreambleAndHeader (Ptr<Packet> packet,
				double rxPowerW,
				Time rxDuration, 
				struct MatlabPhyInfo mlPhyInfo);
		/**
		 * Starting receiving the payload of a packet (i.e. the first bit of the packet has arrived).
		 *
		 * \param packet the arriving packet
		 * \param txVector the TXVECTOR of the arriving packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::mpduType.
		 * \param event the corresponding event of the first time the packet arrives
		 * \param mlPhyInfo contains snr and flag
		 */
		void StartReceivePacket (Ptr<Packet> packet,
				WifiTxVector txVector,
				MpduType mpdutype,
				Ptr<Event> event,
				struct MatlabPhyInfo mlPhyInfo);



	protected:
		// Inherited
		virtual void DoDispose (void);


	private:
		//Overloading method present in wifi-phy
		/**
		 * Starting receiving the packet after having detected the medium is idle 
		 *
		 * \param packet the arriving packet
		 * \param txVector the TXVECTOR of the arriving packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::MpduType.
		 * \param rxPowerW the receive power in W
		 * \param rxDuration the duration needed for the reception of the packet
		 * \param event the corresponding event of the first time the packet arrives
		 * \param mlPhyInfo contains snr and flag
		 */

		void StartRx (Ptr<Packet> packet,
				WifiTxVector txVector,
				MpduType mpdutype,
				double rxPowerW,
				Time rxDuration,
				Ptr<Event> event,
				struct MatlabPhyInfo mlPhyInfo);

		/**
		 * The last bit of the packet has arrived.
		 *
		 * \param packet the packet that the last bit has arrived
		 * \param preamble the preamble of the arriving packet
		 * \param mpdutype the type of the MPDU as defined in WifiPhy::mpduType.
		 * \param event the corresponding event of the first time the packet arrives
		 * \param mlPhyInfo contains snr and flag
		 */
		void EndReceive (Ptr<Packet> packet, 
				WifiPreamble preamble, 
				MpduType mpdutype, 
				Ptr<Event> event, 
				struct MatlabPhyInfo mlPhyInfo);

		Ptr<MatlabWifiChannel> m_channel; //!< MatlabWifiChannel that this MatlabWifiPhy is connected to
		void MaybeCcaBusyDuration (void);
};


#endif /* MATLAB_WIFI_PHY_H */
