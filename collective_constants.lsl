#include <common_constants.lsl>

// Collective
#define COLL_NAME "COLLECTIVE"

// Internal bus commands
// Device commands
#define COLL_ADDSSDEVICE "add " + SS_NAME
#define COLL_ADDDEVICE "add" // <devicename>
#define COLL_REMOVEDEVICE "remove" // devicename
#define COLL_ADDCONFIRM "add-confirm"
#define COLL_REMOVESSDEVICE "remove " + SS_NAME
#define COLL_ADDCOMMAND "add-command" // <command>
#define COLL_REMOVECOMMANDS "remove-commands"
#define COLL_IDENTIFY "identify" 
#define COLL_IDENTIFICATION "identification" // <prefix> <unitname> <authority>
#define COLL_OWNERS "owners" // <owners>
#define COLL_SOFTWARE "software" // <osname> <version>
#define COLL_FOLLOW "follow" // <avatarkey>
#define COLL_FOLLOWING "following" // <avatarkey> <devicekey>
#define COLL_FOLLOWSTOP "followstop" // <NULL_KEY>
#define COLL_SAFEWORDQ "safe-q"
#define COLL_SAFEWORD "safeword" // <safeword>
#define COLL_POWERQ "power-q"
#define COLL_WATTAGE "wattage" // <power>
#define COLL_ON "on"
#define COLL_OFF "off"
#define COLL_POWERON "power on"
#define COLL_POWEROFF "power off"
#define COLL_COLORQ "color-q"
#define COLL_COLOR "color" // <red> <green> <blue>
#define COLL_DURABILITYQ "durability-q"
#define COLL_DURABILITY "durability" // <dura%> <maxdura>
#define COLL_FOLLOWQ "follow-q"
#define COLL_POSEQ "pose-q"
#define COLL_POSE "Pose" // <posename>
#define COLL_TEMPQ "temp-q"
#define COLL_TEMPERATURE "temperature" // <tempcelcius>
#define COLL_GENDERQ "gender-q"
#define COLL_GENDER "Gender" // <gender>
#define COLL_TOUCHPASS "TouchPass" // <key>
#define COLL_AUTHRESPONSE "auth response"
#define COLL_AUTH "auth" // <devicekey> <avatarkey>
#define COLL_AUTHACCEPT "accept" // <avatarkey>
#define COLL_AUTHDENY "denyaccess"
#define COLL_AUTHCOMPARE "auth-compare" // <devicekey> <keytocheck> <keyinuse>
#define COLL_PRIORITYAUTH "priority-auth" // <devicekey> <key>
#define COLL_ADDDRAIN "add-drain" // <power>
#define COLL_REMOVEDRAIN "remove-drain"
#define COLL_SECURE "Secure"
#define COLL_RELEASE "Release"

// Undocumented commands
#define COLL_Q_IDENTIFICATION "identification" // <prefix> <unitname> <authority>

// Controller commands
#define COLL_BATTERY "battery" // <power%
#define COLL_PROBE "probe"
#define COLL_RESTART "restart"
#define COLL_COMMAND "command" // <command> <args>
#define COLL_TOUCH "touch" // <avatarkey>
#define COLL_STATUS "status" // <avatarkey>
#define COLL_PING "Ping"
#define COLL_PONG "Pong"

// Collective public bus commands
#define COLL_CHARGE "charge" // <value> OR <value%>
#define COLL_REPAIR "repair" // <value>
