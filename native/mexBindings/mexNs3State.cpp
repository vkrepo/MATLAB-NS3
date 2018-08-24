/*
 * Copyright (C) Vamsi.  2017-18 All rights reserved.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License version 2.
 */

#include "ns3/core-module.h"
#include "ns3/node-container.h"
#include "ns3/net-device-container.h"
#include "ns3/udp-echo-helper.h"
#include "ns3/ipv4-interface-container.h"
#include "ns3/wave-net-device.h"
#include "ns3/wave-helper.h"
#include "mexNs3State.h"

using namespace ns3;

/** initialize linked list head with Null value */
static MemMngmt *nodeList = NULL;

static int count;


/**
 * This function will initializes the linked list
 * and frees the list elements that are freed in the previous
 * run of simulation
 */
void initmexNs3State()
{
    MemMngmt *temp;
    
    /** loops over each element of the linked list */
    while (nodeList != NULL)
    {
        temp = nodeList;
        /** deletes the list element from the list */
        bindMngrDelSingleElem(temp);
    }
    printf("MexNs3State Init\n");
}

/**
 * this is will deinit the ns3 interface
 */
void deinitmexNs3State()
{
    printf("MexNs3State deinit\n");
}

/**
 * this function will allocate memory for the list element
 * and initializes that element with default values
 */
static MemMngmt *createListElem()
{
    /** memory of MemMngmt structure is allocated */
    MemMngmt *temp = (MemMngmt *)malloc(sizeof(MemMngmt));
    /** sets the next and prev pointers to NULL value */
    temp->next = NULL;
    temp->prev = NULL;
    /** returns the list element */
    return temp;
}

/**
 * this function will create and add the list element to
 * to the start of the list
 */
MemMngmt *bindMngrNewElem()
{
    /** creates a list element with default values */
    MemMngmt *temp = createListElem();
    /** checks whether the nodeList pointer is NULL or not
     * if NULL, it will make the nodeList to point to that list element
     * else adds that element to the start of the list and modify the nodeList
     * pointer to point that element
     */
    if (nodeList == NULL)
    {
        /** making node list to point to that element */
        nodeList = temp;
        //nodeList->next = NULL;
        //nodeList->prev = NULL;
    }
    else
    {
        /** adding that new element to the start of the list */
        temp->next = nodeList;
        nodeList->prev = temp;
        nodeList = temp;
    }
    count++;
    /** returns the nodeList pointer */
    return nodeList;
}

/**
 * this function will delete an element from the list
 * temp [in] it is a pointer to MemMngmt structure
 */
void bindMngrDelSingleElem(MemMngmt *temp)
{
    /** error check whether nodeList is NULL or temp is NULL */
    if ((!nodeList) || (!temp))
        return ;
    
    /** it will check that only single element is present in the list or not*/
    if ((temp->prev == NULL) && (temp->next == NULL))
    {
        /** assigns null to nodeList */
        nodeList = NULL;
    }
    /** it will check that we are removing the starting element of the list or not */
    else if (temp->prev == NULL)
    {
        /** it will make temp->next element's prev pointer to NULL */
        temp->next->prev = NULL;
        /** makes the nodeList to point the next element */
        nodeList = temp->next;
    }
    /** it will check that we are removing the ending element of the list or not */
    else if (temp->next == NULL)
        temp->prev->next = NULL;
    /** it will check that we are removing the middle element of the list or not */
    else
    {
        temp->prev->next = temp->next;
        temp->next->prev = temp->prev;
    }
    /** free the memory of temp object */
    free(temp);
    count--;
}

/**
 * this function will check whether a particual element in the list or not
 * listref [in] it is a pointer to MemMngmt structure
 */
MemMngmt* bindMngrHasListElem(MemMngmt * listref)
{
    MemMngmt *temp = nodeList;
    /** loops over each element of the list */
    while(temp != NULL)
    {
        /** checks whether element is present or not */
        if (temp == listref)
            return temp;
        /** assinging next element of the list to temp */
        temp = temp->next;
    }
    return NULL;
}
/* EOF */

