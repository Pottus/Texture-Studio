#tryinclude <YSI\y_iterate>

#if !defined _Y_ITERATE_LOCAL_VERSION
	#error y_iterate not found
#endif


// Common Data
#define         GUI_X_OFFSET    0.0
#define         GUI_Y_OFFSET    0.0

#define         ADD_ORDER           0
#define         REM_ORDER           1

#define         FUNC_NAME_SIZE  	20

// Player Textdraw Data
#define         MAX_PLAYER_GUI         10
#define         MAX_PLAYER_ELEMENTS    40

// Maximum Textdraw binds allowed
#define         MAX_PLAYER_BINDS        50

#define         MAX_PLAYER_GUI_TEXT    128

#define 		INVALID_MENU_PLAYERGUI       (PlayerGUIMenu:-1)


// World data
#define         MAX_GUI           100
#define         MAX_ELEMENTS      100

#define 		INVALID_MENU_GUI       (GUIMenu:-1)

#define         CLICK_NO_GROUP          0

enum GUIDEF {
	GUIText[MAX_PLAYER_GUI_TEXT],
	Float:GUIOffX,
	Float:GUIOffY,
	Float:GUILSizeX,
	Float:GUILSizeY,
	Float:GUITextSizeX,
	Float:GUITextSizeY,
	Float:GUIPModelRX,
	Float:GUIPModelRY,
	Float:GUIPModelRZ,
	Float:GUIPModelZoom,
	GUIPModel,
	GUIBackColor,
	GUIFont,
	GUIColor,
	GUIOutline,
	GUIProportional,
	GUIAlignment,
	GUIShawdow,
	GUIBox,
	GUIBoxColor,
	GUISelect,
}

// Used internally to return element indexes found
stock E_INDEX[MAX_ELEMENTS+1];
stock E_PLAYERINDEX[MAX_PLAYER_ELEMENTS+1];

// Used internally to return created element index
stock L_ELEMENT;

// Stop all textdraw clicks
new bool:GUIPaused[MAX_PLAYERS];

forward PlayerSetGUIPaused(playerid, bool:paused);
public PlayerSetGUIPaused(playerid, bool:paused)
{
    GUIPaused[playerid] = paused;
	return 1;
}

#include "tstudio\gui\guihook.pwn"
#include "tstudio\gui\gui.pwn"
#include "tstudio\gui\playergui.pwn"
