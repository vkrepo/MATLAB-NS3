// Copyright (C) Vamsi.  2017-19 All rights reserved.
// Source code based on yans-wifi-phy.cc of NS3

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

#include "ns3/log.h"
#include "ns3/packet.h"
#include "ml-wifi-phy.h"
#include "ml-wifi-channel.h"
#include <iostream>
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"
using namespace ns3;
using namespace std;


NS_LOG_COMPONENT_DEFINE ("MatlabWifiPhy");

NS_OBJECT_ENSURE_REGISTERED (MatlabWifiPhy);

TypeId MatlabWifiPhy::GetTypeId (void)
{
	static TypeId tid = TypeId ("MatlabWifiPhy")
		.SetParent<WifiPhy> ()
		.AddConstructor<MatlabWifiPhy> ()
		;
	return tid;
}

MatlabWifiPhy::MatlabWifiPhy ()
{
	NS_LOG_FUNCTION (this);
}

MatlabWifiPhy::~MatlabWifiPhy ()
{
	NS_LOG_FUNCTION (this);
}

void MatlabWifiPhy::DoDispose (void)
{
	NS_LOG_FUNCTION (this);
	m_channel = 0;
	WifiPhy::DoDispose ();
}

Ptr<Channel> MatlabWifiPhy::GetChannel (void) const
{
	return m_channel;
}

void MatlabWifiPhy::SetChannel (const Ptr<MatlabWifiChannel> channel)
{
	NS_LOG_FUNCTION (this << channel);
	m_channel = channel;
	m_channel->Add (this);
}

void MatlabWifiPhy::StartTx (Ptr<Packet> packet, WifiTxVector txVector, Time txDuration)
{
	NS_LOG_DEBUG ("Start transmission: signal power before antenna gain=" << GetPowerDbm (txVector.GetTxPowerLevel ()) << "dBm");
	m_channel->Send (this, packet, GetPowerDbm (txVector.GetTxPowerLevel ()), GetTxGain(), GetRxGain(), txDuration);
}

//Overloading functions from wifi-phy. 
void MatlabWifiPhy::StartReceivePreambleAndHeader (Ptr<Packet> packet, double rxPowerW, Time rxDuration, MatlabPhyInfo mlPhyInfo)
{
	/* Reading tag from packet to access txVector */
	WifiPhyTag tag;
	bool found = packet->PeekPacketTag (tag);
	if (!found)
	{
		NS_FATAL_ERROR ("Received Wi-Fi Signal with no WifiPhyTag");
		return;
	}

	WifiTxVector txVector = tag.GetWifiTxVector ();
	Ptr<Event> event;
	event = m_interference.Add (packet,
			txVector,
			rxDuration,
			rxPowerW);

	//This function should be later split to check separately whether plcp preamble and plcp header can be successfully received.
	//Note: plcp preamble reception is not yet modeled.
	if (m_state->GetState () == WifiPhyState::OFF)
	{
		NS_LOG_DEBUG ("Cannot start RX because device is OFF");
		return;
	}

	NS_LOG_FUNCTION (this << packet << WToDbm (rxPowerW) << rxDuration);

	if (tag.GetFrameComplete () == 0)
	{
		NS_LOG_DEBUG ("drop packet because of incomplete frame");
		NotifyRxDrop (packet);
		m_plcpSuccess = false;
		return;
	}

	if (txVector.GetMode ().GetModulationClass () == WIFI_MOD_CLASS_HT
			&& (txVector.GetNss () != (1 + (txVector.GetMode ().GetMcsValue () / 8))))
	{
		NS_FATAL_ERROR ("MCS value does not match NSS value: MCS = " << +txVector.GetMode ().GetMcsValue () << ", NSS = " << +txVector.GetNss ());
	}

	Time endRx = Simulator::Now () + rxDuration;
	if (txVector.GetNss () > GetMaxSupportedRxSpatialStreams ())
	{
		NS_LOG_DEBUG ("drop packet because not enough RX antennas");
		NotifyRxDrop (packet);
		m_plcpSuccess = false;
		if (endRx > Simulator::Now () + m_state->GetDelayUntilIdle ())
		{
			//that packet will be noise _after_ the transmission of the
			//currently-transmitted packet.
			MaybeCcaBusyDuration ();
			return;
		}
	}

	MpduType mpdutype = tag.GetMpduType ();
	switch (m_state->GetState ())
	{
		case WifiPhyState::SWITCHING:
			NS_LOG_DEBUG ("drop packet because of channel switching");
			NotifyRxDrop (packet);
			m_plcpSuccess = false;
			/*
			 * Packets received on the upcoming channel are added to the event list
			 * during the switching state. This way the medium can be correctly sensed
			 * when the device listens to the channel for the first time after the
			 * switching e.g. after channel switching, the channel may be sensed as
			 * busy due to other devices' tramissions started before the end of
			 * the switching.
			 */
			if (endRx > Simulator::Now () + m_state->GetDelayUntilIdle ())
			{
				//that packet will be noise _after_ the completion of the
				//channel switching.
				MaybeCcaBusyDuration ();
				return;
			}
			break;
		case WifiPhyState::RX:
			NS_LOG_DEBUG ("drop packet because already in Rx (power=" <<
					rxPowerW << "W)");
			NotifyRxDrop (packet);
			if (endRx > Simulator::Now () + m_state->GetDelayUntilIdle ())
			{
				//that packet will be noise _after_ the reception of the
				//currently-received packet.
				MaybeCcaBusyDuration ();
				return;
			}
			break;
		case WifiPhyState::TX:
			NS_LOG_DEBUG ("drop packet because already in Tx (power=" <<
					rxPowerW << "W)");
			NotifyRxDrop (packet);
			if (endRx > Simulator::Now () + m_state->GetDelayUntilIdle ())
			{
				//that packet will be noise _after_ the transmission of the
				//currently-transmitted packet.
				MaybeCcaBusyDuration ();
				return;
			}
			break;
		case WifiPhyState::CCA_BUSY:
		case WifiPhyState::IDLE:
			StartRx (packet, txVector, mpdutype, rxPowerW, rxDuration, event, mlPhyInfo);
			break;
		case WifiPhyState::SLEEP:
			NS_LOG_DEBUG ("drop packet because in sleep mode");
			NotifyRxDrop (packet);
			m_plcpSuccess = false;
			break;
		default:
			NS_FATAL_ERROR ("Invalid WifiPhy state.");
			break;
	}
}

void MatlabWifiPhy::StartRx (Ptr<Packet> packet, WifiTxVector txVector, MpduType mpdutype, double rxPowerW, Time rxDuration, Ptr<Event> event, MatlabPhyInfo mlPhyInfo)
{
	NS_LOG_FUNCTION (this << packet << txVector << +mpdutype << rxPowerW << rxDuration);
	if (rxPowerW > DbmToW(GetEdThreshold ())) //checked here, no need to check in the payload reception (current implementation assumes constant rx power over the packet duration)
	{
		AmpduTag ampduTag;
		WifiPreamble preamble = txVector.GetPreambleType ();
		if (preamble == WIFI_PREAMBLE_NONE && (m_mpdusNum == 0 || m_plcpSuccess == false))
		{
			m_plcpSuccess = false;
			m_mpdusNum = 0;
			NS_LOG_DEBUG ("drop packet because no PLCP preamble/header has been received");
			NotifyRxDrop (packet);
			MaybeCcaBusyDuration ();
			return;
		}
		else if (preamble != WIFI_PREAMBLE_NONE && packet->PeekPacketTag (ampduTag) && m_mpdusNum == 0)
		{
			//received the first MPDU in an MPDU
			m_mpdusNum = ampduTag.GetRemainingNbOfMpdus ();
			m_rxMpduReferenceNumber++;
		}
		else if (preamble == WIFI_PREAMBLE_NONE && packet->PeekPacketTag (ampduTag) && m_mpdusNum > 0)
		{
			//received the other MPDUs that are part of the A-MPDU
			if (ampduTag.GetRemainingNbOfMpdus () < (m_mpdusNum - 1))
			{
				NS_LOG_DEBUG ("Missing MPDU from the A-MPDU " << m_mpdusNum - ampduTag.GetRemainingNbOfMpdus ());
				m_mpdusNum = ampduTag.GetRemainingNbOfMpdus ();
			}
			else
			{
				m_mpdusNum--;
			}
		}
		else if (preamble != WIFI_PREAMBLE_NONE && packet->PeekPacketTag (ampduTag) && m_mpdusNum > 0)
		{
			NS_LOG_DEBUG ("New A-MPDU started while " << m_mpdusNum << " MPDUs from previous are lost");
			m_mpdusNum = ampduTag.GetRemainingNbOfMpdus ();
		}
		else if (preamble != WIFI_PREAMBLE_NONE && m_mpdusNum > 0 )
		{
			NS_LOG_DEBUG ("Didn't receive the last MPDUs from an A-MPDU " << m_mpdusNum);
			m_mpdusNum = 0;
		}

		NS_LOG_DEBUG ("sync to signal (power=" << rxPowerW << "W)");
		m_state->SwitchToRx (rxDuration);
		NS_ASSERT (m_endPlcpRxEvent.IsExpired ());
		NotifyRxBegin (packet);
		m_interference.NotifyRxStart ();

		if (preamble != WIFI_PREAMBLE_NONE)
		{
			NS_ASSERT (m_endPlcpRxEvent.IsExpired ());
			Time preambleAndHeaderDuration = CalculatePlcpPreambleAndHeaderDuration (txVector);
			m_endPlcpRxEvent = Simulator::Schedule (preambleAndHeaderDuration, &MatlabWifiPhy::StartReceivePacket, this,
					packet, txVector, mpdutype, event, mlPhyInfo);
		}

		NS_ASSERT (m_endRxEvent.IsExpired ());
		m_endRxEvent = Simulator::Schedule (rxDuration, &MatlabWifiPhy::EndReceive, this,
				packet, preamble, mpdutype, event, mlPhyInfo);
	}
	else
	{
		NS_LOG_DEBUG ("drop packet because signal power too Small (" <<
				rxPowerW << "<" << DbmToW(GetEdThreshold ()) << ")");
		NotifyRxDrop (packet);
		m_plcpSuccess = false;
		MaybeCcaBusyDuration ();
	}
}

void MatlabWifiPhy::StartReceivePacket (Ptr<Packet> packet, WifiTxVector txVector, MpduType mpdutype, Ptr<Event> event, MatlabPhyInfo mlPhyInfo)
{
	NS_LOG_FUNCTION (this << packet << txVector.GetMode () << txVector.GetPreambleType () << +mpdutype);
	NS_ASSERT (IsStateRx ());
	NS_ASSERT (m_endPlcpRxEvent.IsExpired ());
	WifiMode txMode = txVector.GetMode ();

	int flag = mlPhyInfo.flag;

	if (flag == 0) //plcp reception succeeded
	{
		if (IsModeSupported (txMode) || IsMcsSupported (txMode))
		{
			NS_LOG_DEBUG ("receiving plcp payload"); //endReceive is already scheduled
			m_plcpSuccess = true;
		}
		else //mode is not allowed
		{
			NS_LOG_DEBUG ("drop packet because it was sent using an unsupported mode (" << txMode << ")");
			NotifyRxDrop (packet);
			m_plcpSuccess = false;
		}
	}
	else //plcp reception failed
	{
		NS_LOG_DEBUG ("drop packet because plcp preamble/header reception failed");
		NotifyRxDrop (packet);
		m_plcpSuccess = false;
	}
}

void MatlabWifiPhy::EndReceive (Ptr<Packet> packet, WifiPreamble preamble, MpduType mpdutype, Ptr<Event> event, MatlabPhyInfo mlPhyInfo)
{
	NS_LOG_FUNCTION (this << packet << event);
	NS_ASSERT (IsStateRx ());
	NS_ASSERT (event->GetEndTime () == Simulator::Now ());
	
	int flag = mlPhyInfo.flag;
	double snrW = mlPhyInfo.snrW;

	if (flag == 0) //plcp reception succeeded
	{
		NotifyRxEnd (packet);
		SignalNoiseDbm signalNoise;
		signalNoise.signal = WToDbm (event->GetRxPowerW ());
		signalNoise.noise = WToDbm (event->GetRxPowerW () / snrW);
		MpduInfo aMpdu;
		aMpdu.type = mpdutype;
		aMpdu.mpduRefNumber = m_rxMpduReferenceNumber;
		NotifyMonitorSniffRx (packet, GetFrequency (), event->GetTxVector (), aMpdu, signalNoise);
		m_state->SwitchFromRxEndOk (packet, snrW, event->GetTxVector ());
	}
	else
	{
		/* failure. */
		NotifyRxDrop (packet);
		m_state->SwitchFromRxEndError (packet, snrW);
	}

	if (preamble == WIFI_PREAMBLE_NONE && mpdutype == LAST_MPDU_IN_AGGREGATE)
	{
		m_plcpSuccess = false;
	}
}

void MatlabWifiPhy::MaybeCcaBusyDuration ()
{
	//We are here because we have received the first bit of a packet and we are
	//not going to be able to synchronize on it
	//In this model, CCA becomes busy when the aggregation of all signals as
	//tracked by the InterferenceHelper class is higher than the CcaBusyThreshold

	Time delayUntilCcaEnd = m_interference.GetEnergyDuration (DbmToW (GetCcaMode1Threshold ()));
	if (!delayUntilCcaEnd.IsZero ())
	{
		m_state->SwitchMaybeToCcaBusy (delayUntilCcaEnd);
	}
}
