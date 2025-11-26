#include <common_constants.lsl>
#include <common_functions.lsl>
#include <ares_constants.lsl>

integer INTERNAL_BUS;
integer PUBLIC_BUS = -9999999;
key AVATAR;
key CONTROLLERKEY;
integer IS_ACTIVE = -1;
key LAST_DEVICE = NULL_KEY;
list MYRELAYS = [];

log(string message){if(IS_ACTIVE) llOwnerSay("[" + ARES_NAME + "] " + message); else llOwnerSay("[" + ARES_NAME + "] [IMPERSONATING] " + message);}

handleInternalBus(string command, list args, key id)
{
    if(IS_ACTIVE == -1 && command == ARES_ADDCONFIRM)
    {
        llMessageLinked(LINK_ROOT, 0, SS_ADDCONFIRM + " ARES", ARES_NAME);
        IS_ACTIVE = TRUE;
        CONTROLLERKEY = id;
    }

    if(IS_ACTIVE == FALSE)
    {
        //log("command: " + command + " args: " + llDumpList2String(args, " "));

        if(command == ARES_ADDDEVICE)
            llMessageLinked(LINK_ROOT, 0, SS_ADDDEVICE + " " + (string)id + " " + (string)INTERNAL_BUS + " " + (string)args[0], ARES_NAME);
        else if(command == ARES_COLORQ)        
            llMessageLinked(LINK_ROOT, 0, IC_COLORQ, ARES_NAME);        
    }
}

handlePublicBus(string command, list args, key id)
{
    if(IS_ACTIVE == FALSE)
    {
        if(command == ARES_PING)
        {
            llRegionSayTo(id, (integer)args[0], llLinksetDataRead(SS_PREFIX) + "-000-00-0000 ARES/0.5.5 " + (string)NULL_KEY + " V/SS " +  llDumpList2String(llParseString2List(llLinksetDataRead(SS_AUTHORITY), [" "], []), "_"));
        }
    }
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

    //log("[Relay Action] command: " + command + " args: " + llList2CSV(args));

    if(command == IC_ADDDEVICE)
    {
        llMessageLinked((integer)relay[0], 0, RC_KILLMECMD + " " + (string)INTERNAL_BUS + " " + ARES_REMOVEDEVICE + " interop_" + (string)args[0], CONTROLLERKEY);
        llMessageLinked((integer)relay[0], 0, ARES_ADDDEVICE + " " + (string)INTERNAL_BUS + " interop_" + (string)args[0], CONTROLLERKEY);
    }
    else if(command == IC_PROBE)
    {
        llMessageLinked((integer)relay[0], 0, ARES_PROBE + " " + (string)INTERNAL_BUS, CONTROLLERKEY);
    }
    else if(command == IC_COLOR)
    {
        llMessageLinked((integer)relay[0], 0, ARES_COLOR + " " + llDumpList2String(llList2List(args, 0, 2), " "), CONTROLLERKEY);
        integer colorsProvided = llGetListLength(args) / 3;
        integer i;
        for(i = 1; i < colorsProvided; i++)
            llMessageLinked((integer)relay[0], 0, ARES_COLOR + (string)(i + 1) + " " + llDumpList2String(llList2List(args, i, i + 2), " "), CONTROLLERKEY);
    }

    return TRUE;
}

handleRelayBroadcast(string command, list args, key deviceId)
{
    string commandToSend = "";
    if(command == IC_PROBE)
        commandToSend = ARES_PROBE + " " + (string)INTERNAL_BUS;

    //log("[Relay Broadcast] " + commandToSend);

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

handleRelayReponse(string command, list args, key deviceId) // <command> <channel> <deviceid> <args>
{
    if(command == RC_RELAYREADY)
    {        
        list relay = findRelayByDevice(deviceId);
        if(relay == [])
        {
            log("No relay found for device "+ (string)deviceId+"..?");
            return;
        }

        if((string)relay[2] == ARES_NAME)
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
    else if(command == SS_ADDCONFIRM)
        llRegionSayTo(deviceId, INTERNAL_BUS, ARES_ADDCONFIRM);
    else if(command == RC_RELAYCOMMAND) // <channel> <originid> <message>
    {
        list split = llList2List(args, 3, -1);

        if((integer)args[0] == INTERNAL_BUS)
        {
            string relayCommand = (string)args[2];
            if(relayCommand == ARES_ADDDEVICE)
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
        SYSTEMNAME = ARES_NAME;

        AVATAR = llGetOwner();
        INTERNAL_BUS = 105 - (integer)("0x" + llGetSubString((string)AVATAR, 29, 35));

        llListen(INTERNAL_BUS, "", NULL_KEY, "");
        llListen(PUBLIC_BUS, "", NULL_KEY, "");
    }

    link_message( integer sendenum, integer num, string str, key id )
    {
        if(id == ARES_NAME)
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
            IS_ACTIVE = -1;
            llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_REMOVESSDEVICE);
            llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_ADDSSDEVICE);
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
                    llMessageLinked((integer)relays[1], 0, ARES_REMOVEDEVICE + " " + (string)INTERNAL_BUS + " interop_" + (string)args[0], CONTROLLERKEY);
                }
                return;
            }

            if(llGetSubString(command, 0, 2) == "ss-") // only relay interop commands to the action handler
                return;

            if(!handleRelayAction(command, args, id))
            {
                // There is no relay for this device, so send the request ourselves and relay the response back to the avatar. Probably.

                if(command == IC_COLORQ)
                    llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, ARES_COLORQ);
            }
        }
        else if(IS_ACTIVE == FALSE)
        {
            // Sadly have to check twice because of how this entire thing is set up..
            if(command == IC_PROBE)
                handleRelayBroadcast(command, args, id);
            else if(command == SS_ADDCONFIRM)
                llRegionSayTo((key)args[0], INTERNAL_BUS, ARES_ADDCONFIRM);
            else if(command == IC_COLOR)
            {
                llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_COLOR + " " + llDumpList2String(llList2List(args, 0, 2), " "));
                integer colorsProvided = llGetListLength(args) / 3;
                integer i;
                for(i = 1; i < colorsProvided; i++)
                    llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_COLOR + "-" + (string)(i + 1) + " " + llDumpList2String(llList2List(args, i * 3, i * 3 + 2), " "));
            }
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
                IS_ACTIVE = FALSE;
                // Pretend we are ARES, ask for devices to report themselves
                llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_PROBE);
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
            //log("[Internal bus] from: " + (string)id + " (" + (string)(llGetObjectDetails(id, [OBJECT_NAME])) + ") message: " + message);
            handleInternalBus((string)split[0], llDeleteSubList(split, 0, 0) , id);
        }
        else if(channel == PUBLIC_BUS)
        {
            //log("[Public bus] from: " + (string)id + " (" + (string)(llGetObjectDetails(id, [OBJECT_NAME])) + ") message: " + message);
            handlePublicBus((string)split[0], llDeleteSubList(split, 0, 0) , id);
        }
    }
}