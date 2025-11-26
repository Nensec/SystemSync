#include <common_constants.lsl>
#include <common_functions.lsl>

string WORN_CONTROLLER;
list RELAYS = ["2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17"];
list relaysToInitialize;

log(string message){llOwnerSay("[SystemSync] " + message);}

default
{
    on_rez( integer start_param)
    {
        llResetScript();
    }
    
    state_entry()
    {
        //log("Cleaning up old relays..");
        llLinksetDataWrite(SS_ACTIVERELAYS, "");
        llSetLinkPrimitiveParamsFast(LINK_ALL_CHILDREN, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0.0]);
        
        log("Trying to determine what system you wear, this should only take a moment..");
        llMessageLinked(LINK_ROOT, 0, SS_ADDSSDEVICE, "");
    }

    touch_start( integer num_detected )
    {
        llMessageLinked(LINK_ROOT, 0, SS_DEBUGMEMORY, "");
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if(str == SS_DEBUGMEMORY)
        {
            log("Detected controller: " + WORN_CONTROLLER + " with " + (string)llGetListLength(llList2ListStrided(llCSV2List(llLinksetDataRead(SS_ACTIVERELAYS)), 0, -1, 4)) + " relays.");
            printMemoryUsage();
            return;
        }

        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        list args = llDeleteSubList(split, 0, 0);

        //log("received command: " + command);
        if(command == SS_ADDCONFIRM && WORN_CONTROLLER == "")
        {
            WORN_CONTROLLER = llList2String(llParseString2List(str, (list)" ", []), 1);
            log("Detected controller system " + WORN_CONTROLLER + ". System Sync will now attempt to impersonate other controllers and create relays for devices for those systems.");
            llMessageLinked(LINK_ROOT, 0, SS_IMPERSONATE, "");
        }
        else if(command == SS_NAMEOBJECT)
        {
            string authority = llLinksetDataRead(SS_PREFIX);
            string objectName;
            if(authority)
            {
                objectName = authority + " ";
            }
            objectName += llLinksetDataRead(SS_UNITNAME);
            log("Naming device to " + objectName);
            llSetObjectName(objectName);
        }                    
        else if(command == SS_ADDDEVICE)
        {
            //log("Internal add command. " + llList2CSV(args));
            key deviceId = (key)args[0];
            list relay = findRelayByDevice(deviceId);
            //log("args: " + llList2CSV(args));
            
            if(relay == [])
            {
                //log("Creating a new relay");
                string activeRelayLsd = llLinksetDataRead(SS_ACTIVERELAYS);
                list activeRelays = []; // default to empty list
                if(activeRelayLsd != "") 
                    activeRelays = llCSV2List(activeRelayLsd); // if lsd is not empty then parse it into a list

                list relayPrimsInUse = llList2ListStrided(activeRelays, 0, -1, 4);

                integer i;
                for(i = 0; i < llGetListLength(RELAYS); i++)
                {
                    list currentRelay = llList2List(RELAYS, i, i); // gets the current relay from list RELAYS = ["2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17"];
                    if(llListFindList(relayPrimsInUse, currentRelay) == -1) // returns -1 if currentRelay is not in relayPrimsInUse
                    {
                        integer channel = (integer)args[1];
                        key primKey = llGetLinkKey((integer)currentRelay[0]);
                        //log("Using prim link " + (string)currentRelay[0] + "(" + (string)primKey + ") as relay for device: " + (string)deviceId + " system: " + (string)id + " on channel: " + (string)channel);

                        string newLsdData = llList2CSV(activeRelays += [(integer)currentRelay[0], deviceId, (string)id, channel]);
                        //log("Saving new LSD data for " + SS_ACTIVERELAYS + ": " + newLsdData);

                        llLinksetDataWrite(SS_ACTIVERELAYS, newLsdData);
                        relaysToInitialize += [(string)deviceId, (string)args[2]];
                        llRemoteLoadScriptPin(primKey, "_relay", 69420, TRUE, 0);
                        llMessageLinked(LINK_ALL_CHILDREN, 0, RC_RELAYSCHANGED, id);
                        return;
                    }
                }

                log("There are no free relays available, device cannot be added.");
            }
            else
            {
                // Device is already known with a relay, so this is probably a probe response
                //log("Device is already added with relay prim: " + (string)relay[0]);
                llMessageLinked(LINK_ROOT, 0, IC_ADDDEVICE + " " + (string)args[2], deviceId);
            }
        }
        else if(command == RC_RELAYREADY)
        {
            //log("relaysToInitialize " + llList2CSV(relaysToInitialize));
            integer relayDataIndex = llListFindList(relaysToInitialize, (list)((string)args[0]));
            list relayData = llList2List(relaysToInitialize, relayDataIndex, relayDataIndex + 1);
            relaysToInitialize = llDeleteSubList(relaysToInitialize, relayDataIndex, relayDataIndex + 1);
            //log("relayData " + llList2CSV(relayData));

            llMessageLinked(LINK_ROOT, 0, IC_ADDDEVICE + " " + (string)relayData[1], id);
        }
        else if(command == RC_RELAYAVAILABLE)
        {        
            llSleep(0.1); // Give the handlers a chance to clean up before we yeet this relay
            string activeRelayLsd = llLinksetDataRead(SS_ACTIVERELAYS);
            //llOwnerSay("[SystemSync] active relay data: " + activeRelayLsd);
            if(activeRelayLsd == "")
                return;

            list activeRelays = llCSV2List(activeRelayLsd);
            integer deviceIndex = llListFindList(activeRelays, (list)((string)id));
            activeRelays = llDeleteSubList(activeRelays, deviceIndex - 1, deviceIndex + 2);
            llLinksetDataWrite(SS_ACTIVERELAYS, llList2CSV(activeRelays));
        }
    }
}