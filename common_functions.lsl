#include <common_constants.lsl>

list findRelayByDevice(key deviceId)
{
    if(llStringLength(deviceId) != 36)
        return [];

    string activeRelayLsd = llLinksetDataRead(SS_ACTIVERELAYS);
    //llOwnerSay("[SystemSync] active relay data: " + activeRelayLsd);
    if(activeRelayLsd == "")
        return [];

    list activeRelays = llCSV2List(activeRelayLsd);
    integer relayDataIndex = llListFindList(activeRelays, (list)((string)deviceId)) - 1;
    //llOwnerSay("[SystemSync] relayDataIndex: " + (string)relayDataIndex);
    if(relayDataIndex < 0)
        return [];
    return llList2ListStrided(activeRelays, relayDataIndex, relayDataIndex + 3, 1);
}

string SYSTEMNAME;

list findRelaysBySystem()
{
    string activeRelayLsd = llLinksetDataRead(SS_ACTIVERELAYS);
    //llOwnerSay("[SystemSync] active relay data: " + activeRelayLsd);
    if(activeRelayLsd == "")
        return [];

    list activeRelays = llCSV2List(activeRelayLsd);

    integer i;
    integer len = llGetListLength(activeRelays);
    list relays = [];
    for(i = 0; i < len; i += 4)
    {
        string system = (string)activeRelays[i + 2];
        if(system == SYSTEMNAME)
            relays += llList2List(activeRelays, i, i + 3);
    }

    return relays;
}

printMemoryUsage()
{
    integer memuse = llGetUsedMemory();
    integer memmax = llGetMemoryLimit();
    integer MemPerc = (integer)(100.0 * (float)memuse/memmax);

    log("Memory Used: " + (string)memuse + "\nMemory Free: " + (string)llGetFreeMemory() + "\nMemory Limit: " + (string)memmax + "\nPercentage of Memory Usage: " + (string)MemPerc + "%");
}