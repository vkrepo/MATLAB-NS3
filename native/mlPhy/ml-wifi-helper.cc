// Copyright (C) Vamsi.  2017-18 All rights reserved.
// Source code based on yans-wifi-helper.cc of NS3

/*
 * Copyright (c) 2008 INRIA
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
 *          Sébastien Deronne <sebastien.deronne@gmail.com>
 */

#include "ns3/log.h"
#include "ns3/names.h"
#include "ns3/propagation-loss-model.h"
#include "ns3/propagation-delay-model.h"
#include "ns3/error-rate-model.h"
#include "ml-wifi-phy.h"
#include "ml-wifi-helper.h"
#include "ns3/core-module.h"
#include "ns3/wifi-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("MatlabWifiHelper");

MatlabWifiChannelHelper::MatlabWifiChannelHelper ()
{
}

MatlabWifiChannelHelper MatlabWifiChannelHelper::Default (void)
{
	MatlabWifiChannelHelper helper;
	helper.SetPropagationDelay ("ns3::ConstantSpeedPropagationDelayModel");
	helper.AddPropagationLoss ("ns3::LogDistancePropagationLossModel");
	return helper;
}

void MatlabWifiChannelHelper::AddPropagationLoss (std::string type,
		std::string n0, const AttributeValue &v0,
		std::string n1, const AttributeValue &v1,
		std::string n2, const AttributeValue &v2,
		std::string n3, const AttributeValue &v3,
		std::string n4, const AttributeValue &v4,
		std::string n5, const AttributeValue &v5,
		std::string n6, const AttributeValue &v6,
		std::string n7, const AttributeValue &v7)
{
	ObjectFactory factory;
	factory.SetTypeId (type);
	factory.Set (n0, v0);
	factory.Set (n1, v1);
	factory.Set (n2, v2);
	factory.Set (n3, v3);
	factory.Set (n4, v4);
	factory.Set (n5, v5);
	factory.Set (n6, v6);
	factory.Set (n7, v7);
	m_propagationLoss.push_back (factory);
}

void MatlabWifiChannelHelper::SetPropagationDelay (std::string type,
		std::string n0, const AttributeValue &v0,
		std::string n1, const AttributeValue &v1,
		std::string n2, const AttributeValue &v2,
		std::string n3, const AttributeValue &v3,
		std::string n4, const AttributeValue &v4,
		std::string n5, const AttributeValue &v5,
		std::string n6, const AttributeValue &v6,
		std::string n7, const AttributeValue &v7)
{
	ObjectFactory factory;
	factory.SetTypeId (type);
	factory.Set (n0, v0);
	factory.Set (n1, v1);
	factory.Set (n2, v2);
	factory.Set (n3, v3);
	factory.Set (n4, v4);
	factory.Set (n5, v5);
	factory.Set (n6, v6);
	factory.Set (n7, v7);
	m_propagationDelay = factory;
}

Ptr<MatlabWifiChannel> MatlabWifiChannelHelper::Create (void) const
{
	Ptr<MatlabWifiChannel> channel = CreateObject<MatlabWifiChannel> ();
	Ptr<PropagationLossModel> prev = 0;
	for (std::vector<ObjectFactory>::const_iterator i = m_propagationLoss.begin (); i != m_propagationLoss.end (); ++i)
	{
		Ptr<PropagationLossModel> cur = (*i).Create<PropagationLossModel> ();
		if (prev != 0)
		{
			prev->SetNext (cur);
		}
		if (m_propagationLoss.begin () == i)
		{
			channel->SetPropagationLossModel (cur);
		}
		prev = cur;
	}
	Ptr<PropagationDelayModel> delay = m_propagationDelay.Create<PropagationDelayModel> ();
	channel->SetPropagationDelayModel (delay);
	channel->SetMatlabWSTCallback(matlabWSTCallback);
	return channel;
}

int64_t MatlabWifiChannelHelper::AssignStreams (Ptr<MatlabWifiChannel> c, int64_t stream)
{
	return c->AssignStreams (stream);
}

void MatlabWifiChannelHelper::RegisterWSTCallback(MATLAB_WST_CALLBACK ptr)
{
	matlabWSTCallback = ptr;
}

MatlabWifiPhyHelper::MatlabWifiPhyHelper (): m_channel (0)
{
	m_phy.SetTypeId ("MatlabWifiPhy");
}

MatlabWifiPhyHelper MatlabWifiPhyHelper::Default (void)
{
	MatlabWifiPhyHelper helper;
	helper.SetErrorRateModel ("ns3::NistErrorRateModel");
	return helper;
}

void MatlabWifiPhyHelper::SetChannel (Ptr<MatlabWifiChannel> channel)
{
	m_channel = channel;
}

void MatlabWifiPhyHelper::SetChannel (std::string channelName)
{
	Ptr<MatlabWifiChannel> channel = Names::Find<MatlabWifiChannel> (channelName);
	m_channel = channel;
}

Ptr<WifiPhy> MatlabWifiPhyHelper::Create (Ptr<Node> node, Ptr<NetDevice> device) const
{
	Ptr<MatlabWifiPhy> phy = m_phy.Create<MatlabWifiPhy> ();
	Ptr<ErrorRateModel> error = m_errorRateModel.Create<ErrorRateModel> ();
	phy->SetErrorRateModel (error);
	phy->SetChannel (m_channel);
	phy->SetDevice (device);
	return phy;
}

