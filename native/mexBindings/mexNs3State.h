/*
 * Copyright (C) Vamsi.  2017-18 All rights reserved.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License version 2.
 */

#ifndef __MEXNS3_STATE_H__
#define __MEXNS3_STATE_H__

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/wave-module.h"
#include "ns3/wifi-module.h"
#include "ns3/mobility-module.h"
#include "ns3/applications-module.h"
#include "ml-wifi-helper.h"
#include <iostream>
#include <string>
#include <map>
#include <iterator>

using namespace ns3;

/** starting enumeration value to smart pointer objects */
#define SMART_PTR_ENUM_START  1000

/** enumeration to distinguish c++ objects */
enum ClassObjTypes
{
    MATLABPHYHELPOBJ, MATLABCHANHELPOBJ, MATLABCHANOBJ, PSHOBJ, MOBILITYHELPOBJ, NODECONTOBJ, NETDEVCONTOBJ, YANSWIFICHANHELPOBJ, YANSWAVEPHYHELPOBJ, YANSWIFIPHYHELPOBJ, YANSWIFICHANOBJ, WAVEHELPOBJ, WIFI80211PHELPOBJ, QOSWAVEMACHELPOBJ, NQOSWAVEMACHELPOBJ, ATTRIVALUE, WIFIHELPOBJ, STRINGVALOBJ, DOUBLEVALOBJ, ONOFFHELPOBJ, APPCONTOBJ, CONSTVMMOBJ, NODEOBJ, NETDEVOBJ, EVENTIDOBJ, BOOLVALOBJ, CONSTPMMOBJ, MOBMODOBJ, CONSTAMMOBJ, WIFIPHYHELPOBJ, WIFIMACHELPOBJ, SSIDOBJ, EMPATTRVALOBJ, PACKETSOCKADDROBJ, UINTEGERVALOBJ, SSIDVALOBJ, NODELISTOBJ, RNGSEEDMNGROBJ, APPOBJ, TIMEOBJ, ADDROBJ, INTERNETSTACKHELPOBJ, IPV4ADDRHELPOBJ, IPV4INTERFACEHELPOBJ, UDPECHOSERVERHELPOBJ, UDPECHOCLIENTHELPOBJ, UDPSERVERHELPOBJ, UDPCLIENTHELPOBJ, TIMEVALUEOBJ, PKTSINKHELPER, INETSOCKADDROBJ, IPV4ADDROBJ, ADDRVALOBJ, IPV4GRH, DRVALUE, DEFAULT_OBJ_TYPE,
    YANSWIFICHANOBJ_SP = SMART_PTR_ENUM_START, CONSTVMMOBJ_SP, NODEOBJ_SP, NETDEVOBJ_SP, CONSTPMMOBJ_SP, MOBMODOBJ_SP, CONSTAMMOBJ_SP, SSIDOBJ_SP, PACKETSOCKADDROBJ_SP, APPOBJ_SP, TIMEOBJ_SP, SSIDVALOBJ_SP, BOOLVALOBJ_SP, STRINGVALOBJ_SP, DOUBLEVALOBJ_SP, EMPATTRVALOBJ_SP, UINTEGERVALOBJ_SP, MATLABCHANOBJ_SP, TIMEVALUEOBJ_SP, ADDRVALOBJ_SP, DRVALUES_SP, DEFAULT_OBJ_TYPE_SP
};

/** this is a memory management node. This will be used to maintain context of c++ objects */
struct MemMngmt
{
    void *vptr;
    ClassObjTypes objType;
    
    struct MemMngmt *next;
    struct MemMngmt *prev;
};

/** inits the bind manager */
void initmexNs3State();
/** deinits the bind manager */
void deinitmexNs3State();
/** creates and adds an element to the list */
MemMngmt *bindMngrNewElem();
/** deletes a single element from the linked list */
void bindMngrDelSingleElem(MemMngmt *listref);
/** this function will check the given list element in the list or not */
MemMngmt* bindMngrHasListElem(MemMngmt * listref);

/** this is a callback function signature which was in the mexSocketInterface.cpp file */
bool ReceivePkt (Ptr<ns3::NetDevice> dev, Ptr<const ns3::Packet> pkt, uint16_t mode, const Address &sender);

/** The method name is passed as first argument to mex call */
#define INPUT_Command_String_Index 0
/** This is the maximum length of the method name string */
#define CMD_BUFFER_SIZE 64

#endif /** __MEXNS3_STATE_H__ **/

