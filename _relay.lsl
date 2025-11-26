#include <common_constants.lsl>
#include <common_functions.lsl>

list LISTENHANDLERS;
key DEVICEID;
integer PRIMID;
string KILLME;
integer KILLCHANNEL;
list ALLRELAYS;
integer KNOWNATTACHMENTLOCATION;

log(string message){llOwnerSay("[Relay " + (string)PRIMID +"] " + message);}

initRelay(integer channel)
{
    if(~llListFindList(LISTENHANDLERS, (list)channel) == 0)
    {
        integer handler = llListen(channel, "", NULL_KEY, "");
        llListInsertList(LISTENHANDLERS, [handler], 0);
    }
}

killRelay()
{
    if(KILLME != "")
        llRegionSayTo(llGetOwner(), KILLCHANNEL, KILLME);
    llSetAlpha(0.0, ALL_SIDES);
    integer i;
    for(i = 0; i <= llGetListLength(LISTENHANDLERS); i++)
    {
        llListenRemove((integer)LISTENHANDLERS[i]);
    }
    llMessageLinked(LINK_ROOT, PRIMID, RC_RELAYAVAILABLE, DEVICEID);
    llRemoveInventory("_relay");
}

default
{
    on_rez( integer start_param)
    {
        if(KILLME != "")
            llRegionSayTo(llGetOwner(), KILLCHANNEL, KILLME);
        if(llGetLinkNumber() != LINK_ROOT)
            llRemoveInventory("_relay");
    }

    attach( key id )
    {
        killRelay();
    }

    state_entry()
    {
        PRIMID = llGetLinkNumber();

        if(PRIMID == LINK_ROOT)
        {
            llSetScriptState(llGetScriptName(), FALSE);  
            return;
        }

        llSetAlpha(0.5, ALL_SIDES);
        log("Initializing relay..");
        list activeRelays = llCSV2List(llLinksetDataRead(SS_ACTIVERELAYS));
        integer relayDataIndex = llListFindList(activeRelays, (list)((string)PRIMID));
        list relayData = llList2ListStrided(activeRelays, relayDataIndex, relayDataIndex + 3, 1);
        //log("Found data for relay: " + llList2CSV(relayData));
        initRelay((integer)relayData[3]);
        DEVICEID = (key)relayData[1];
        list objectInfo = llGetObjectDetails(DEVICEID, [OBJECT_NAME, OBJECT_ATTACHED_POINT]);
        llSetObjectName((string)objectInfo[0]);
        KNOWNATTACHMENTLOCATION = (integer)objectInfo[1];
        log("Attachment found: " + (string)objectInfo[0] + ", this relay will impersonate that device.");
        //log("Attachment found: " + (string)objectInfo[0] + " attached to: " + (string)objectInfo[1]);
        llSetTimerEvent(1);
        llMessageLinked(LINK_ROOT, PRIMID, RC_RELAYREADY + " " + (string)DEVICEID, DEVICEID);
        log("Relay ready!");
        llSetAlpha(1.0, ALL_SIDES);
    }

    touch_start( integer num_detected )
    {
        log("I am device: " + (string)DEVICEID + " (" + (string)llGetObjectDetails(DEVICEID, [OBJECT_NAME]) + ") attached to point: " + (string)KNOWNATTACHMENTLOCATION);
        printMemoryUsage();
    }

    timer()
    {
        list objectInfo = llGetObjectDetails(DEVICEID, [OBJECT_NAME, OBJECT_ATTACHED_POINT]);
        integer newAttachmentPoint = (integer)objectInfo[1];
        if(newAttachmentPoint != KNOWNATTACHMENTLOCATION)
        {
            killRelay();
            return;
        }

        llSetObjectName((string)objectInfo[0]);
    }

    listen( integer channel, string name, key id, string message )
    {
        if(id == DEVICEID || llListFindList(ALLRELAYS, (list)((string)id)) == -1)
        {
            // log("Command received from " + (string)id + " on channel " + (string)channel);
            // log("Command: " + message);
            llMessageLinked(LINK_ROOT, PRIMID, RC_RELAYCOMMAND + " " + (string)channel + " " + (string)id + " " + message, DEVICEID);
        }
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if(PRIMID == LINK_ROOT)
            return;

        //log(str);

        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        integer channel = (integer)split[1];

        if(command == RC_INITRELAY)
        {
            initRelay(channel);
        }
        else if(command == RC_KILLMECMD)
        {
            KILLCHANNEL = channel;
            list killargs = llDeleteSubList(split, 0, 1);
            KILLME = llDumpList2String(killargs, " ");
        }
        else if(command == RC_KILLRELAY)
        {
            killRelay();
        }
        else if(command == RC_RELAYSCHANGED)
        {
            //log("Updating relays");
            string activeRelaysLsd = llLinksetDataRead(SS_ACTIVERELAYS);
            list activeRelays = llCSV2List(activeRelaysLsd);

            ALLRELAYS = [];
            integer i;
            integer len = llGetListLength(activeRelays);
            for(i = 0; i < len; i += 4)
                ALLRELAYS += llList2List(activeRelays, i + 1, i + 1);
        }
        else
        {
            string commandToSend = llDumpList2String(llDeleteSubList(split, 1, 1), " ");

            //log("Sending to " + (string)id + " on channel: " + (string)channel + " the command: " + (string)commandToSend);
            llRegionSayTo(id, channel, commandToSend);
        }
    }
}