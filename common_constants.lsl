#define SS_NAME "SystemSync"
#define SS_NAMESSMPLE "interop"
#define SS_PINGCHANNEL -78127655

// Linkset keys
#define SS_AVATAR "AVATAR"
#define SS_OWNERS "OWNERS"
#define SS_SOFTWARE "SOFTWARE"
#define SS_PREFIX "PREFIX"
#define SS_UNITNAME "UNITNAME"
#define SS_AUTHORITY "AUTHORITY"
#define SS_ACTIVERELAYS "ACTIVERELAYS" /* [primid, deviceid, system, channel] */
#define SS_TEMPCELCIUS "TEMPCELCIUS"
#define SS_CURRENTPOWER "CURRENTPOWER"
#define SS_REMAININGPOWER "REMAININGPOWER"

// Internal System Sync link message commands
#define SS_ADDSSDEVICE "ss-adddevice"
#define SS_REMOVEDEVICES "ss-removedevices"
#define SS_ADDCONFIRM "ss-addconfirm"
#define SS_IMPERSONATE "ss-impersonate"
#define SS_NAMEOBJECT "ss-nameobject" /* <unitname> */
#define SS_ADDDEVICE "ss-add" /* <key> <channel> <devicename> */
#define SS_DEBUGMEMORY "ss-debugmemory"

// Interop commands
#define IC_ADDDEVICE "ic-add" /* <name> */
#define IC_REMOVEDEVIVE "ic-remove" /* <name> */
#define IC_PROBE "ic-probe"
#define IC_COLORQ "ic-color-q"
#define IC_COLOR "ic-color" /* <[R, G, B, R, G, B...]> */

// Relay commands
#define RC_INITRELAY "rc-initrelay" /* <channel> */
#define RC_RELAYREADY "rc-relayready" /* <key> */
#define RC_KILLRELAY "rc-killrelay"
#define RC_KILLMECMD "rc-killmecmd" /* <killcommand> */
#define RC_RELAYAVAILABLE "rc-relayavailable"
#define RC_RELAYCOMMAND "rc-relaycommand" /* <channel> <originid> <message> */
#define RC_CREATERELAY "rc-createrelay" /* <origindeviceid> <system> <channel> */
#define RC_RELAYSCHANGED "rc-relayschanged"
