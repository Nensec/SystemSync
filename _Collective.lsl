#include <common_constants.lsl>
#include <common_functions.lsl>
#include <collective_constants.lsl>

integer INTERNAL_BUS;
integer PUBLIC_BUS = -9345678;
key AVATAR;
integer IS_ACTIVE = -1;
key CONTROLLERKEY;
list MYRELAYS = [];

log(string message){if(IS_ACTIVE) llOwnerSay("[" + COLL_NAME + "] " + message); else llOwnerSay("[" + COLL_NAME + "] [IMPERSONATING] " + message);}

handleInternalBus(string command, list args, key id)
{
    if(IS_ACTIVE == -1 && command == COLL_ADDCONFIRM)
    {
        //log("Setting IS_ACTIVE to true");
        IS_ACTIVE = TRUE;
        CONTROLLERKEY = id;
        llMessageLinked(LINK_ROOT, 0, SS_ADDCONFIRM + " Collective", COLL_NAME);
        llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, COLL_IDENTIFY);
    }

    if(IS_ACTIVE == FALSE)
    {
        if(command == COLL_ADDDEVICE)
            llMessageLinked(LINK_ROOT, 0, SS_ADDDEVICE + " " + (string)id + " " + (string)INTERNAL_BUS + " " + (string)args[0], COLL_NAME);
    }
    else if(IS_ACTIVE == TRUE)
    {
        if(command == COLL_PROBE)
        {
            if(id != CONTROLLERKEY)
            {
                //log("Controller key changed..?");
                if(llGetOwnerKey(id) == AVATAR)
                    CONTROLLERKEY = id;
                else
                    return;
            }

            llRegionSayTo(AVATAR, INTERNAL_BUS, COLL_ADDSSDEVICE);
            llMessageLinked(LINK_ROOT, 0, IC_PROBE, COLL_NAME);
        }
        else if(command == COLL_IDENTIFICATION)
        {
            if((string)args[0] == COLL_OWNERS)
                llLinksetDataWrite(SS_OWNERS, (string)args[1]);
            else if((string)args[0] == COLL_SOFTWARE)
                llLinksetDataWrite(SS_SOFTWARE, (string)args[1]);
            else
            {
                llLinksetDataWrite(SS_PREFIX, (string)args[0]);
                llLinksetDataWrite(SS_UNITNAME, (string)args[1]);
                llLinksetDataWrite(SS_AUTHORITY, llDumpList2String(llList2List(args, 2, -1), " "));
            }

            llMessageLinked(LINK_ROOT, 0, SS_NAMEOBJECT, COLL_NAME);
        }
        else if(command == COLL_ADDCONFIRM)
            llMessageLinked(LINK_ROOT, 0, SS_ADDCONFIRM, COLL_NAME);
        else if(command == COLL_TEMPERATURE)
            llLinksetDataWrite(SS_TEMPCELCIUS, (string)args[0]);
        else if(command == COLL_WATTAGE)
            llLinksetDataWrite(SS_CURRENTPOWER, (string)args[0]);
        else if(command == COLL_BATTERY)
            llLinksetDataWrite(SS_REMAININGPOWER, (string)args[0]);
        else if(command == COLL_COLOR)
            llMessageLinked(LINK_ROOT, 0, IC_COLOR + " " + llDumpList2String(args + args + args + args, " "), COLL_NAME);
    }
}

handlePublicBus(string command, list args, key id)
{
}

integer handleRelayAction(string command, list args, key deviceId)
{
    //log("Received relay action: " + command);

    if(llStringLength((string)deviceId) != 36)
        return FALSE;

    list relay = findRelayByDevice(deviceId);
    if(relay == [])
    {
        log("No relay found for device "+ (string)deviceId+"..?");
        return FALSE;
    }

    //log("[Relay Action] command: " + command + " args: " + llDumpList2String(args, " "));

    if(command == IC_ADDDEVICE)
    {
        llMessageLinked((integer)relay[0], 0, RC_KILLMECMD + " " + (string)INTERNAL_BUS + " " + COLL_REMOVEDEVICE + " Interop_" + (string)args[0], CONTROLLERKEY);
        llMessageLinked((integer)relay[0], 0, COLL_ADDDEVICE + " " + (string)INTERNAL_BUS + " Interop_" + (string)args[0], CONTROLLERKEY);
    }

    return TRUE;
}

handleRelayBroadcast(string command, list args, key deviceId)
{
    string commandToSend = "";
    if(command == IC_PROBE)
        commandToSend = COLL_PROBE + " " + (string)INTERNAL_BUS;

    //log("[Broadcast] " + commandToSend);

    if(commandToSend != "")
    {
        list relays = findRelaysBySystem();
        integer i;
        for(i = 0; i < llGetListLength(relays); i += 4)
        {
            list relay = llList2List(relays, i, i + 3);
            //log("[Relay Broacast] Broadcasting to relay: " + llList2CSV(relay));
            llMessageLinked((integer)relay[0], 0, commandToSend, (key)relay[1]);
        }
    }
}

handleRelayReponse(string command, list args, key deviceId)
{
    if(command == RC_RELAYREADY)
    {        
        list relay = findRelayByDevice(deviceId);
        if(relay == [])
        {
            log("No relay found for device "+ (string)deviceId+"..?");
            return;
        }

        if((string)relay[2] == COLL_NAME)
            MYRELAYS += relay;
    }

    if(llListFindList(MYRELAYS, (list)((string)deviceId)) == -1)
        return; // Not my circus

    //log("[Relay Response] command: " + command + " args: " + llList2CSV(args));

    if(command == RC_RELAYAVAILABLE)
    {
        integer relayIndex = llListFindList(MYRELAYS, (list)deviceId);
        if(relayIndex != -1)
            MYRELAYS = llDeleteSubList(MYRELAYS, relayIndex - 1, relayIndex + 2);
    }
    else if(command == RC_RELAYCOMMAND) // <channel> <originid> <message>
    {
        list split = llList2List(args, 3, -1);

        if((integer)args[0] == INTERNAL_BUS)
        {
            string relayCommand = (string)args[2];
            if(relayCommand == COLL_ADDDEVICE)
                if(llListFindList(MYRELAYS, (list)((string)deviceId)) == -1) // we ignore relayed add commands from the internal bus, because those do not belong to this device
                    return;
            handleInternalBus(relayCommand, split, (key)args[1]);
        }
        else if((integer)args[0] == PUBLIC_BUS)
            handlePublicBus((string)args[2], split, (key)args[1]);
    }
}

default
{
    on_rez( integer start_param)
    {
        llResetScript();
    }

    state_entry()
    {
        SYSTEMNAME = COLL_NAME;

        AVATAR = llGetOwner();
        INTERNAL_BUS = -1 - (integer)("0x" + llGetSubString( (string) AVATAR, -7, -1) ) + 5515;

        llListen(INTERNAL_BUS, "", NULL_KEY, "");
        llListen(PUBLIC_BUS, "", NULL_KEY, "");
    }

    link_message( integer sendenum, integer num, string str, key id )
    {
        if(id == COLL_NAME)
            return;

        if(str == SS_DEBUGMEMORY)
        {
            log("Is active: " + (string)IS_ACTIVE + " with " + (string)llGetListLength(llList2ListStrided(MYRELAYS, 0, -1, 4)) + " relays.");
            printMemoryUsage();
            return;
        }

        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        list args = llDeleteSubList(split, 0, 0);

        if(command == SS_ADDSSDEVICE)
        {
            //log("Setting IS_ACTIVE to unknown");
            IS_ACTIVE = -1;
            llRegionSayTo(AVATAR, INTERNAL_BUS, COLL_REMOVESSDEVICE);
            llRegionSayTo(AVATAR, INTERNAL_BUS, COLL_ADDSSDEVICE);
            return;
        }

        if(IS_ACTIVE == TRUE)
        {
            if(command == SS_REMOVEDEVICES)
            {
                list relays = llList2ListStrided(findRelaysBySystem(), 0, -1, 4);
                integer i;
                integer len = llGetListLength(relays);
                for(i = 0; i < len; i++)
                {
                    llMessageLinked((integer)relays[1], 0, COLL_REMOVEDEVICE + " " + (string)INTERNAL_BUS + " Interop_" + (string)args[0], CONTROLLERKEY);
                }
                return;
            }

            if(llGetSubString(command, 0, 2) == "ss-") // only relay interop commands to the action handler
                return;
                
            if(!handleRelayAction(command, args, id))
            {
                //log("[Relay Action Fallback] command: " + command + " args: " + llDumpList2String(args, " "));

                // There is no relay for this device, so send the request ourselves and relay the response back to the avatar. Probably.

                if(command == IC_COLORQ)
                    llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, COLL_COLORQ);
            }
        }
        else if(IS_ACTIVE == FALSE)
        {
            // Sadly have to check twice because of how this entire thing is set up..
            if(command == IC_PROBE)
                handleRelayBroadcast(command, args, id);
            else
            {
                //log("[Relay Handler] " + str);
                handleRelayReponse(command, args, id);
            }
        }
        else if(IS_ACTIVE == -1)
        {
            if(command == SS_IMPERSONATE)
            {
                //log("Setting IS_ACTIVE to false");
                IS_ACTIVE = FALSE;
                // Pretend we are Collective, ask for devices to report themselves                
                llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, COLL_PROBE);
            }
        }
    }

    listen( integer channel, string name, key id, string message )
    {
        list split = llParseString2List(message, [" "], []);

        if(channel == INTERNAL_BUS)
        {
            if(llListFindList(MYRELAYS, (list)((string)id)) != -1)
            {
                //log("[Internal bus] Relay detected for internal bus message, ignoring and letting relay handle things..");
                return;
            }
            // if((string)split[0] != COLL_TEMPERATURE && (string)split[0] != COLL_WATTAGE && (string)split[0] != COLL_BATTERY)
            //     log("[Internal bus] from: " + (string)id + " (" + (string)(llGetObjectDetails(id, [OBJECT_NAME])) + ") message: " + message);
            handleInternalBus((string)split[0], llDeleteSubList(split, 0, 0) , id);
        }
        else if(channel == PUBLIC_BUS)
        {
            //log("[Public bus] from: " + (string)id + " (" + (string)(llGetObjectDetails(id, [OBJECT_NAME])) + ") message: " + message);
            handlePublicBus((string)split[0], llDeleteSubList(split, 0, 0) , id);
        }
    }
}