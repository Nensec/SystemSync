#include <common_constants.lsl>

// ARES
#define ARES_NAME "ARES"

// Internal bus commands
// Device commands
#define ARES_ADDSSDEVICE "add " + SS_NAMESSMPLE
#define ARES_ADDDEVICE "add" // <devicename> <version?> <pin?>
#define ARES_REMOVESSDEVICE "remove " + SS_NAMESSMPLE
#define ARES_REMOVEDEVICE "remove " // <devicename>
#define ARES_ADDCOMMAND "add-command" // <command>
#define ARES_AUTH "auth" // <devicekey> <avatarkey>
#define ARES_AUTHCOMPARE "auth-compare" // <deviceley> <avatarkey1> <avatarkey2>
#define ARES_CARRIERQ "carrier-q"
#define ARES_COLORQ "color-q"
#define ARES_COMMAND "command" // <userkey> <reciepientkey> <comand>
#define ARES_CONFIGDELET "conf-delete" // <settingname>
#define ARES_CONFIGGET "conf-get" // <settingname>
#define ARES_CONFSET "conf-set" // <settingname> <value>
#define ARES_DEVICES "devices"
#define ARES_FOLLOWQ "follow-q"
#define ARES_GENDERQ "gender-q" // <topic>
#define ARES_INTERNAL "internal" // <devicekey> <number> <key> <message>
#define ARES_LOAD "load" // <devicekey> <task> <wattage>
#define ARES_PERSONAQ "persona-q"
#define ARES_POLICYQ "policy-q" // <policy>
#define ARES_POWERQ "power-q"
#define ARES_SUBSYSTEMQ "subsystem-q" // <subsystem>
#define ARES_VERSION "version" // <devicekey> <version> <pin>

// Controller commands
#define ARES_ADDCONFIRM "add-confirm"
#define ARES_BOLTS "bolts" // on|off
#define ARES_BROKEN "broken"
#define ARES_ACCEPT "accept" // <devicekey>
#define ARES_ADDFAIL "add-fail"
#define ARES_CARRIER "carrier" // <devicekey> <avatarkey>
#define ARES_CHARGE "charge" // start|stop
#define ARES_COLOR "color" // <r> <g> <b>
#define ARES_COLOR2 "color-2" // <r> <g> <b>
#define ARES_COLOR3 "color-3" // <r> <g> <b>
#define ARES_COLOR4 "color-4" // <r> <g> <b>
#define ARES_COMMANDRESPONSE "command" // <avatarkey> <command> <parameters>
#define ARES_CONF "conf" // <settingname> <value>
#define ARES_DONE "done"
#define ARES_DEVICELIST "device-list" // [\n<device-address> <device-key>[\n<device-address> <device-key>[...]]]
#define ARES_ERRORRETRY "error retry"
#define ARES_FAN "fan" // <speed>
#define ARES_FIXED "fixed"
#define ARES_FOLLOW "follow" // <targetkey>
#define ARES_FREEZE "freeze>"
#define ARES_GENDER "gender" // <topic> <value>
#define ARES_INTEGRITY "integrity" // <integrity> <chassisstrength> <maxintegrity>
#define ARES_INTERFERENCESTATE "interference-state" // <type>
#define ARES_OFF "off"
#define ARES_ON "on"
#define ARES_PERSONA "persona" // <name>
#define ARES_POWER "power" // <powerperc>
#define ARES_PEEK "peek" // <avatarkey>
#define ARES_POKE "poke" // <avatarkey>
#define ARES_POLICY "policy" // <name> <state>
#define ARES_PORTCONNECT "port-connect" // <type>
#define ARES_PORT "port" // <type> <primkey> (power/audio-in/audio-out/data-1/data2)
#define ARES_PORTDISCONNECT "port-disconnect" // <type>
#define ARES_PORTREAL "port-real" // <type> <primkey>
#define ARES_PING "ping"
#define ARES_PROBE "probe"
#define ARES_RATE "rate" // <joulesamount>
#define ARES_SUBSYSTEM "subsustem" // <ss> 0|1 (video=1/audio=2/move=4/teleport=8/rapid=16/voice=32/mind=64/preamp=128/power-amp=256/radio-in=512/radio-out=1024/gps=2048/identify=4096)
#define ARES_REMOVECONFIRM "remove-confirm"
#define ARES_REMOVEFAIL "remove-fail"
#define ARES_SESSIONREADY "session-ready" // <key> <session-number>
#define ARES_TEMPERATURE "temperature" // <temperature>
#define ARES_UNFREEZE "unfreeze"
#define ARES_UNITNAME "name"
#define ARES_WAITTELEPORT "wait-teleport" // <time>
#define ARES_WEATHER "weather" // <type> <temperature>
#define ARES_WORKING "working"

// Device to device commands
#define ARES_BLOCKHOLO "block-holo"
#define ARES_CONNECTED "connected" // <devicekey>
#define ARES_DISCONNECTED "disconnected" // <devicekey>
#define ARES_ICON "icon" // <uuid>
#define ARES_ICONQ "icon-q"
#define ARES_RECONNECTED "reconnected" // <devicename>
#define ARES_ADDBUTTON "add-button" // <section-name> <icon> <command>
#define ARES_ADDBUTTONCONFIRM "add-button-confirm" // <section-name>
#define ARES_ADDBUTTONFAIL "add-button-fail" // <section-name>
#define ARES_ADDSECTION "add-section" // <section-name> <width>
#define ARES_ADDSECTIONCONFIRM "add-section-confirm" // <section-name>
#define ARES_CONFIGQ "config-q"
#define ARES_CONFIGUPDATE "config-update"
#define ARES_HATCH "hatch" // open|close
#define ARES_HATCHBLOCKED "hatch-blocked"
#define ARES_HATCHBLOCKEDQ "hatch-blocked-q"
#define ARES_INTERFERENCE "interference" // <type> <intensity> <duration> <sourcekey>
#define ARES_SHIELD "shield" // <duration> <intensity> <sourcekey> <type>
#define ARES_SIGN "sign" // <string>

// Combat commands
// -- perhaps make _ATOS.lsl?

// Weapon
// From weapon
#define ARES_WEAPONACTIVE "weapon active" // <kJ> <capacitykJ> <currentkJ> <currenttemp> <maxtemp>
#define ARES_WEAPONINFO "weapon info" // <kJ> <capacitykJ> <currentkJ> <currenttemp> <maxtemp>
#define ARES_WEAPONINACTIVE "weapon inactive"
#define ARES_WEAPONRELOAD "weapon reload"
#define ARES_WEAPONFIRE "weapon fire" // <temp>

// From controller
#define ARES_WEAPONCHARGE "weapon charge" // <amount>
#define ARES_CURRENTWEAPONACTIVE "weapon active" // <weapon> <kJ> <capacitykJ> <currentkJ> <currenttemp> <maxtemp>
#define ARES_DEFEND "defend"
#define ARES_SENTINELFLAGS "sentinel-flags" // <temp-units> <true-shield> <repair-allowed> <true-repair-allowed> <autoshield>

// Public bus
#define ARES_IFF "iff" // <responsechannel>
#define ARES_IDENTIFICATION "identification>" // <integrity> <temperature> <repairing> <serial> <os_name> <os_version> <group_key>

#define ARES_REPAIRSTART "repair start"
#define ARES_REPAIRSTOP "repair stop"
#define ARES_REPAIR "repair" // <amount>
#define ARES_HEAL "heal" // <heal>

#define ARES_ATOSDAMAGE "atos:" // <num> (comes directly after : )
#define ARES_MELEEDAMAGE "meleedamage"
#define ARES_ATDMG "[AT_DMG]"
#define ARES_VICE "vice" // ,<type>,<n> (CSV!)
#define ARES_OTHER "other"
