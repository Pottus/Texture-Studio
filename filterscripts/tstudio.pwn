/*
		A
            ....
            ,DDDDDD      ..DDDDDDD=...        . .......
            DDDDDDD     .DDDDDDDDDDDD.        .~DDDD8:.
         ..DD.DDDDD     DDDDDDZ.7DDDDD8.   .7DDDDDDDDDDD.
    .. ..,DD..DDDDD....=DDDDDD...DDDDDD....DDDDDDDD.DDDDD..
      =.DDDD...DDD,D...DDDDDDD...DDDDDD...8DDDD$..8.ODDDD  .
    ...Z.~8I..,D:.I.. .DDDDDD8...DDDDDD...DDDD...D,..8DDD8D.
  ...+DD...D. D...D..     .....D8DDDDDD..DDDD..O,D  .DDD.+..
  .,DDDDD..=. =..D+8O     .=DDDDDDDDDD...D8DD. .O$  .D...D..
..DDDD7..~+.~$.8...DD   .:D.ODDDDDD8..  .DDDD8...8..D,...D~.
DDDDDDDD=...~,...I8DD.DODDZ..8DD.,..     DDO88D........ID8D~
DDDDDDDDDDID~DDDDDDDD.O.,D8..$..?...     DD8Z...8.Z:,?...7I.
+DDDDDDDDDDDDDDDDDDDD..Z..Z..8 .DDDDDDDD.8DDD88,=?:~..~?DD..
.DDDDDDDDDDDDDDDDDDDD+ZD7.....+Z,+DDDDD+..DDDDD7$D$8?DDDD:..
.DDDDDDDD8ZZZ8DDDDD8D.8.....+Z..=DDDDDD...DDDDDDDDDDDDDDD...
 ...        .DDDDDD  ..DDDDI?8DDDDDDDDD....DDDDDDDDDDDDZ.
            .8DDDDD....DD8DO$Z??$$ODDDD.   .?DDDDDDDDD.
            ........................  ..   ............
										Production

 _______        _                     _____ _             _ _
|__   __|      | |                   / ____| |           | (_)
   | | _____  _| |_ _   _ _ __ ___  | (___ | |_ _   _  __| |_  ___
   | |/ _ \ \/ / __| | | | '__/ _ \  \___ \| __| | | |/ _` | |/ _ \
   | |  __/>  <| |_| |_| | | |  __/  ____) | |_| |_| | (_| | | (_) |
   |_|\___/_/\_\\__|\__,_|_|  \___| |_____/ \__|\__,_|\__,_|_|\___/
	Texture Studio v1.9d by [uL]Pottus and Crayder

You may modify and re-release this this script if you please just rememeber the
mule who built it!

About Texture Studio:

Well after releasing the texture viewer and getting back a lot of positive feedback
I couldn't help but one up myself. The challange create a companion map editor using
all the techniques I've learned with SA-MP scripting to create an extensible mapping
script as fast as possible. Basically that means texture studio was built in one day
but I of course I had some good reference code from medit and in fact this script
works very similarily to medit but with a greatly enhanced core design.

Commands: (Currently 65 commands)

	Maps:
	/loadmap - Load a map
	/newmap - Create a new map
	/importmap - Import CreateObject() or CreateDynamicObject() raw code
	/export - Export a map to code or vehicle


	Objects:
	/cobject <objectid> - Create an object
	/dobject - Delete your selected object
	/robject - Resets an objects text and materials
	/osearch - Search for a object
	/sel <objectid> - Select a object id index
	/csel - Use the mouse to select an object
	/lsel - Use a list / preview to display objects
	/flymode - Enter flymode
	/ogoto - Goto your selected object (must be in flymode)
	/pivot - Set a pivot position to rotate objects around
	/togpivot - Turn on/off pivot rotation
	/oprop - Object property editor
	
	Movement:
	/editobject - Edit object mode
	/ox - /oy - /oz - Standard movement commands
	/rx - ry - /rz - Standard rotation commands
	/dox - /doy - /doz - Delta move map
	/drx - /dry - /drz - Rotate map around map center

	
	Textures/Text/Indexes/Theme:
	/mtextures - Show a list of textures in a list
	/ttextures - Show a list of textures in (Theme)
	/stexture - Texture editor
	/mtset <index> <textureref> - Set a material
	/mtsetall <index> <textureref> - Set a material to ALL objects of the same modelid
	/mtcolor <index> <Hex Color ARGB> - Sets a material color
	/mtcolorall <index> <Hex Color ARGB> - Sets a material color to ALL objects of the same modelid
	/copy - Copy object properties to buffer from currently selected object
	/paste - Paste object properties from buffer to currently selected object
	/clear - Clear object properties from buffer
	/text - Open the object text editor
	/sindex - Set text on a object will show material IDs
	/rindex - Removes material indexes shown on an object
	/loadtheme - Load a texture theme
	/savetheme - Saves a texture theme
	/deletetheme - Delete a texture theme
	/tsearch - Find a texture by part of name

	Groups/Prefabs:
	/setgroup - Sets a group id for a group objects
	/selectgroup - Select a group of objects to edit
	/gsel - Open up click select to add/remove objects from your group
	/gadd - Add an object to your group useful for objects that cannot be clicked on
	/grem - Remove a specific object from your group
	/gclear - Clear your group selection
	/gclone - Clone your group selection
	/gdelete - Delete all objects in your group
	/editgroup - Start editing a group
	/gox - /goy - /goz - Stardard group movement commands
	/gox - /goy - /goz - Stardard group rotation commands
	/gaexport - Exports a group of objects to a attached object FS (Not yet completed)
	/gprefab - Export a group of objects to a loadable prefab file
	/prefabsetz - Set the load offset of a prefab file
	/prefab <LoadName"> - Load a prefab file, /prefab will show all prefabs
	/0group - This will move all grouped objects center to 0,0,0 useful for getting attached object offsets (Not in the GUI yet)

	Vehicles:
	/avmodcar - Mod a car it will teleport the vehicle to the correct mod garage if modable
	/avsetspawn - Set the spawn position of a vehicle
	/avnewcar - Create a new car
	/avdeletecar - Delete an unwanted car
	/avcarcolor - Set vehicle car color
	/avpaint - Set a vehicles paintjob
	/avattach - Attach currently selected object to currently selected vehicle
	/avdetach - Detach currently selected object from vehicle
	/avsel - Select a vehicle to edit
	/avexport - Export a car to filterscript
	/avexportall - Export all cars to filterscript
	/avox - /avoy - /avoz - Standard vehicle object movement commands
	/avrx - /avry - /avrz - Standard vehicle object rotation commands
	/avmirror - Mirror currently selected object on vehicle
	(Special note: using /editobject on an attached object will edit the object on the vehicle)

	Bind Editor:
	/bindeditor - Open the bind editor you can enter a series of commands to execute
	/runbind <index> - Runs a bind
	
	Other:
	/echo - Will echo back any text sent this is useful for autohotkey so that you can create
	displayed output for your keybinds

	
Keycombos:
	/csel:
	Holding 'H' while clicking an object will copy properites to buffer
	Holding 'Walk Key' while clicking an object will paste properties from buffer

	/editgroup:
	Hold 'Walk Key' to set the group rotation pivot you can only do this once per edit
	
	GUI:
	When in fly mode to open the GUI press 'Jump Key' otherwise it can be opened by pressing 'N' Key

	Texture Viewer:
	In Fly mode instead of pressing Y/H to scroll through textures hold enter/exit vehicle and press ANALOG Left ---- ANALOG Right
	Pressing sprint will add textures to your theme in fly mode press sprint+aim to add textures to theme in walk mode
	Walk key will apply the selected texture to your object

Change Log:
	v1.0 - First release
	v1.1 - Updated features
		- Fixed a bug with OnPlayerEditDyanmicObject()
		- Added some new commands to texture or color all like objects
		- Added text editing support (New map files will not be compatible)
		- Whole map movement/rotation
		- Texture viewer is now in compiled into this FS
	v1.2 - Added support for importing RemoveBuildingForPlayer() this will be saved to DB
		- Can now copy/paste texture and text from one object to another
	v1.3 - Complete GUI implementation that calls all commands
		- Groups added you can edit group selections
	    - Texture editor texture objects with a GUI
	    - You can make your own texture themes
	    - Prefabs can be saved/loaded
	    - Texture themes can now be created "default_theme" is always loaded when a player connects
	    - You can make your own command based binds and execute them
	v1.4 - New command /lsel gives a new advanced object selection method
	    - Fix a spelling mistake in the gui
	    - Added /oprop command to directly edit all object properties
	    - Map exporting now has a option for CreateDynamicObject() instead of CreateDynamicObjectEx()
	v1.5 - Greatly enhanced /osearch command
	v1.5a - Added a feature to clone in edit object mode simply press 'walk' to clone the object
	    - You can press enter/exit vehicle to save a objects position in edit object mode
	v1.5b - Added /obmedit command an object metric tool
	v1.5c - Improved object metric tool to include rotation translations
	    - Added degree option to object metric tool
	v1.5d - Minor update to object metric tool to set object orientation for rotation translation
	v1.5e - Important fix
	v1.6 - Editable vehicles
	    - A few bug fixes with texturing and overlapping key presses with other systems
	v1.6a - New command /tsearch search for textures useful for finding the index of a known texture
	v1.6b - Added feature to export map including cars to filterscript
	    - New command /avmirror mirror objects on a car
	    - Completely rebuild the all objects array some where missing it should be complete now
	v1.6c - Text length is now 128 characters and will accept \n for new line
	    - Fixed a issue with folders now showing on github
	v1.6d - Fixed an issue with exporting objects if an object had text the parameters were out of order
	    - Any object should be able to be created now there even LOD
	    - Re-organized the project slightly
	v1.7 - /undo command (Note you can't undo edits on vehicles currently)
*/

/*      NONE    MAJOR   MINOR   PATCH
-  0x   00      00      00      00
-  Major: X.00 (# 1-10)
-  Minor: 0.X0 (# 1-10)
-  Patch: 0.0X (Letter a-z, not A-Z)
*/
#define TS_VERSION (0x00010904)

#define FILTERSCRIPT

// Uncomment to turn on DEBUG mode
// #define DEBUG

// #define GUI_DEBUG

// Compile the Angular Map Extension module
//#define COMPILE_MANGLE

// Compile the local input module for advanced keys and mouse control
//#define COMPILE_LOCAL_INPUT

#if defined DEBUG
	#define DB_DEBUG true
	#define DB_QUERY_ERRORS true
#endif

// Includes
#include <a_samp>

// Set max players
#undef MAX_PLAYERS
#define MAX_PLAYERS 10

// "tsfunc" definition, to replace "stock"
#define tsfunc
	
// System defines
#define BroadcastCommand(%0,%1) CallLocalFunction("OnPlayerCommandText","is",%0,%1)

// System includes
#include <sqlitei>
#include <formatex>
#include <strlib>

// Plugins
#include <streamer>
#include <filemanager>
#include <sscanf2>

// GUI System
#include "tstudio\gui\guisys.pwn"

// YSI
#include <YSI\y_iterate>
#include <YSI\y_inline>
#include <YSI\y_dialog>
#define Y_COMMANDS_NO_IPC 
#include <YSI\y_commands>

// All SA Textures
#include "tstudio\alltextures.pwn"

// Valid SA models
#include "tstudio\validmodels.pwn"

// Model sizes
#include "tstudio\modelsizes.pwn"

// Include 3D Menus (By SDraw)
#include "tstudio\3dmenu.pwn"

// Command Buffer
#include "tstudio\cmdbuffer.pwn"

// Common functions
#include <functions>

// Colors
#define         STEALTH_GREEN          0x33DD1100
#define         STEALTH_ORANGE         0xFF880000
#define         STEALTH_YELLOW         0xFFFF00AA

// Maximum number of objects
#define         MAX_TEXTURE_OBJECTS         10000

// Maximum number of remove buildings (Anymore than 1000 will likely crash GTA)
#define         MAX_REMOVE_BUILDING         1000

// Maximum of editable materials (16 is the limit even if set higher)
#define         MAX_MATERIALS               16

// Highlight color for an object
#define         HIGHLIGHT_OBJECT_COLOR      0xFFFF0000

// Maximum text length
#define         MAX_TEXT_LENGTH             129

// Max Groups
#define         MAX_GROUPS                  201


// 3D Text drawdistance
new             Float:TEXT3D_DRAW_DIST  =   100.0;

// Vehicle attach update types
#define         VEHICLE_ATTACH_UPDATE           0
#define         VEHICLE_REATTACH_UPDATE         1

forward OnPlayerObjectSelectChange(playerid, index);
forward OnObjectUpdatePos(playerid, index);
forward OnUpdateGroup3DText(index);
forward OnDeleteGroup3DText(index);

// ARGB
#define ARGB(%0,%1,%2,%3) ((((%0) & 0xFF) << 24) | (((%1) & 0xFF) << 16) | (((%2) & 0xFF) << 8) | (((%3) & 0xFF) << 0))

// Edit check makes sure the player is actually editing an object before doing certain commands
#define EditCheck(%0); if(CurrObject[%0] == -1) { \
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________"); \
	return SendClientMessage(playerid, STEALTH_YELLOW, "You need to select an object to use this command"); }

// Don't let player use command if they are editing an object
#define NoEditingMode(%0); if(EditingMode[%0]) { \
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________"); \
	return SendClientMessage(playerid, STEALTH_YELLOW, "You need to finish editing your object before using this command"); }

// Checks if a map is open
#define MapOpenCheck(); if(!MapOpen) { \
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________"); \
	return SendClientMessage(playerid, STEALTH_YELLOW, "There is no map currently open"); }

// Removebuilding information enum
enum REMOVEINFO
{
	rModel,
	Float:rX,
	Float:rY,
	Float:rZ,
	Float:rRange,
}

// Removebuilding array
new RemoveData[MAX_REMOVE_BUILDING][REMOVEINFO];

// Object information ENUM
enum OBJECTINFO
{
	oID,                                        // Object id
#if defined COMPILE_MANGLE
	oCAID,                                      // ColAndreas index
#endif
	oGroup,                                     // Object group
	oModel,                                     // Object Model
	Text3D:oTextID,                             // Object 3d text label
    oNote[64],                                  // Object note
	Float:oX,                                   // Position Z
	Float:oY,                                   // Position Z
	Float:oZ,                                   // Position Z
	Float:oRX,                                  // Rotation Z
	Float:oRY,                                  // Rotation Z
	Float:oRZ,                                  // Rotation Z
	oTexIndex[MAX_MATERIALS],                   // Texture index ref
	oColorIndex[MAX_MATERIALS],                 // Material List
	ousetext,              						// Use text
	oFontFace,    								// Font face reference
	oFontSize,    								// Font size reference
	oFontBold,    								// Font bold
	oFontColor,   								// Font color
	oBackColor,   								// Font back color
	oAlignment,   								// Font alignment
	oTextFontSize, 							 	// Font text size
	oObjectText[MAX_TEXT_LENGTH],              	// Font text
	oAttachedVehicle,                           // Vehicle object is attached to
    Float:oDD                                   // Draw distance
}

// Copy object material / color
enum COPYINFO
{
	cTexIndex[MAX_MATERIALS],                   // Texture index ref
	cColorIndex[MAX_MATERIALS],                 // Material List
	cusetext,              						// Use text
	cFontFace,    								// Font face reference
	cFontSize,    								// Font size reference
	cFontBold,    								// Font bold
	cFontColor,   								// Font color
	cBackColor,   								// Font back color
	cAlignment,   								// Font alignment
	cTextFontSize, 							 	// Font text size
	cObjectText[MAX_TEXT_LENGTH],              	// Font text
}

enum XYZ { Float:xPos, Float:yPos, Float:zPos }
enum XYZR { Float:xPos, Float:yPos, Float:zPos, Float:rxPos, Float:ryPos, Float:rzPos }

// Copy buffer data
new CopyBuffer[MAX_PLAYERS][COPYINFO];

// Object information array
new ObjectData[MAX_TEXTURE_OBJECTS][OBJECTINFO];

// 3D Text Options
enum TEXTOPTIONS
{
    bool:tShowText,
    bool:tShowNote,
    bool:tShowModel,
    bool:tShowGroup,
    bool:tShowGrouped,
	bool:tAlwaysShowNew
}
new TextOption[TEXTOPTIONS] = {
    true, false, false, true, true, false
};

// Map Options
enum MAPOPTIONS
{
    mVersion,
    mAuthor[MAX_PLAYER_NAME],
    mLastEdit,
    mSpawn[XYZ],
    
    mInterior,
    mVirtualWorld
}
new MapSetting[MAPOPTIONS];

// Sets the current object a player is editing
new CurrObject[MAX_PLAYERS] = { -1, ... };

// In edit object mode
new bool:EditingMode[MAX_PLAYERS];

// Set textdraw open
new bool:TextDrawOpen[MAX_PLAYERS];

// Current players textdraw
new CurrTextDraw[MAX_PLAYERS];

// Pivot object reference
new PivotObject[MAX_PLAYERS];

// Pivot point
new PivotPoint[MAX_PLAYERS][XYZ];

// Turns pivot point on/off
new bool:PivotPointOn[MAX_PLAYERS];

// Save the current editing position
new Float:CurrEditPos[MAX_PLAYERS][6];

// Currmode
#define 		EDIT_MODE_NONE          0
#define 		EDIT_MODE_OBJECT        1
#define         EDIT_MODE_CP            2
#define         EDIT_MODE_SELECTION     3
#define         EDIT_MODE_TEXT          4
#define         EDIT_MODE_GROUP         5
#define         EDIT_MODE_PIVOT         6
#define         EDIT_MODE_OBJECTGROUP   7
#define         EDIT_MODE_TEXTURING     8
#define         EDIT_MODE_LISTSEL       9
#define         EDIT_MODE_OSEARCH       10
#define         EDIT_MODE_OBM           11
#define         EDIT_MODE_VOBJECT 		12
#define         EDIT_MODE_MODCAR        13


// Textdraw modes
#define         TEXTDRAW_NONE    		0
#define         TEXTDRAW_TEXTEDIT	    1
#define         TEXTDRAW_MATERIALS      2
#define         TEXTDRAW_LISTSEL        3
#define         TEXTDRAW_OSEARCH        4


// Set the players editing mode
#define SetEditMode(%0,%1) CurrMode[%0] = %1

// Get the players editing mode
#define GetEditMode(%0) CurrMode[%0]

// Toggle players textdraw open closed
#define ToggleTextDrawOpen(%0,%1) TextDrawOpen[%0] = %1

// Sets Current TD draw index
#define SetCurrTextDraw(%0,%1) CurrTextDraw[%0] = %1

// Gets Current TD draw index
#define GetCurrTextDraw(%0) CurrTextDraw[%0]

// Get the font face of a player object
#define GetObjectUseText(%0) ObjectData[%0][ousetext]

// Get the font face of a player object
#define GetObjectFontFace(%0) ObjectData[%0][oFontFace]

// Get the font size of a player object
#define GetObjectFontSize(%0) ObjectData[%0][oFontSize]

// Get the font bold of a player object
#define GetObjectFontBold(%0) ObjectData[%0][oFontBold]

// Get the font color of a player object
#define GetObjectFontColor(%0) ObjectData[%0][oFontColor]

// Get the back color of a player object
#define GetObjectBackColor(%0) ObjectData[%0][oBackColor]

// Get the alignment of a player object
#define GetObjectAlignment(%0) ObjectData[%0][oAlignment]

// Get the font size of a player object
#define GetObjectTextFontSize(%0) ObjectData[%0][oTextFontSize]

// Get the text of a player object
#define GetObjectObjectText(%0) ObjectData[%0][oObjectText]

// Set use text
#define SetObjectUseText(%0,%1) ObjectData[%0][ousetext] = %1

// Set object object text
#define SetObjectObjectText(%0,%1) format(ObjectData[%0][oObjectText], MAX_TEXT_LENGTH, "%s", %1)

// Set font face
#define SetObjectFontFace(%0,%1) ObjectData[%0][oFontFace] = %1

// Set font size
#define SetObjectFontSize(%0,%1) ObjectData[%0][oFontSize] = %1

// Set font bold
#define SetObjectFontBold(%0,%1) ObjectData[%0][oFontBold] = %1

// Set the alignment of a player object
#define SetObjectAlignment(%0,%1) ObjectData[%0][oAlignment] = %1

// Set the font size of a player object
#define SetObjectTextFontSize(%0,%1) ObjectData[%0][oTextFontSize] = %1

// Set font color
#define SetFontColor(%0,%1) ObjectData[%0][oFontColor] = %1

// Set font color
#define SetBackColor(%0,%1) ObjectData[%0][oBackColor] = %1


// Current mode player is in
new CurrMode[MAX_PLAYERS];

// Iterator for ObjectData
new Iterator:Objects<MAX_TEXTURE_OBJECTS>;

// System database
new DB: SystemDB;

// Database for the edit map
new DB: EditMap;

// Current map name
new MapName[128];

// Theme data
new DB: ThemeDataDB;

// Checks if a map is open
new bool:MapOpen;

// Undo module
#include "tstudio\undo.pwn"

// Webcolor list
#include "tstudio\webcolors.pwn"

// Flymode
#include "tstudio\flymode.pwn"

// Text editor module
#include "tstudio\texteditor.pwn"

// Texture viewer
#include "tstudio\texviewer.pwn"

// ===== Restriction Variables =====
new Iterator:Restriction[MAX_GROUPS]<MAX_PLAYERS>, bool:gRestricted[MAX_GROUPS] = {false, ...};

// playerid, object index (must be 0 or more than 50, if not it must be in a group with no restrictions, if not then the restriction must allow this player)
#define CanSelectObject(%0,%1) \
    (!(0 <= %1 < MAX_TEXTURE_OBJECTS) || (!gRestricted[ObjectData[%1][oGroup]] || !(0 < ObjectData[%1][oGroup] < MAX_GROUPS) || !Iter_Count(Restriction[ObjectData[%1][oGroup]]) || Iter_Contains(Restriction[ObjectData[%1][oGroup]], playerid) || IsPlayerAdmin(playerid)))
// playerid, group index (it must be a group with no restrictions, if not then the restriction must allow this player)
#define CanSelectGroup(%0,%1) \
    (!(0 < %1 < MAX_GROUPS) || (!gRestricted[%1] || !Iter_Count(Restriction[%1]) || Iter_Contains(Restriction[%1], playerid) || IsPlayerAdmin(playerid)))
    //not in this ? then safely test these
// ===== Not a very good modular technique... =====
    
// Group editing
#include "tstudio\groups.pwn"

// RCON Restrictor
#include "tstudio\restrict.pwn"

// List selection
#include "tstudio\listsel.pwn"

// Object property editor/viewer
#include "tstudio\propeditor.pwn"

// Object search
#include "tstudio\osearch.pwn"

// Objectmetry module
#include "tstudio\objm.pwn"
#include "tstudio\obmedit.pwn"

// GTA objects module
#include "tstudio\gtaobjects.pwn"

// Local input module
#if defined COMPILE_LOCAL_INPUT
	#include "tstudio\localinput.pwn"
#endif

// Vehicles
#include "tstudio\vehiclecolors.pwn"
#include "tstudio\vehicles.pwn"

// Special includes
#if defined COMPILE_MANGLE
	#include "tstudio\mangle.pwn"
#endif

// Menu GUI
#include "tstudio\menugui.pwn"

// Help Command
#include "tstudio\helpcmd.pwn"

// Main system
#include "tstudio\tsmain.pwn"

// SA-MP Introspect by Slice and Y_Less, automatically included with debug mode.
#if debug > 1
	#define AMX_NAME "tstudio.amx"
	#include <interpreter>
	
	#include "tstudio\debugging.pwn"
#endif
