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
	Texture Studio v1.5 by [uL]Pottus

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
*/

#define FILTERSCRIPT

// Uncomment to turn on DEBUG mode
// #define DEBUG

// #define GUI_DEBUG

// Leave commented
//#define			COMPILE_DAYZ_INCLUDES

// Compile the GTA Object module for removing buildings
#define COMPILE_GTA_OBJECTS

#if defined DEBUG
	#define DB_DEBUG true
	#define DB_QUERY_ERRORS true
#endif


// Includes
#include <a_samp>

// Set max players
#undef MAX_PLAYERS
#define MAX_PLAYERS 10

// System defines
#define BroadcastCommand(%0,%1) CallLocalFunction("OnPlayerCommandText","is",%0,%1)

// System includes
#include <sqlitei>
#include <strlib>

// Plugins
#include <streamer>
#include <filemanager>
#include <sscanf2>


#include <YSI\y_iterate>

// GUI System
#include "tstudio\gui\guisys.pwn"

// YSI
#include <YSI\y_inline>
#include <YSI\y_dialog>
#include <YSI\y_hooks>
#include <YSI\y_commands>

// All SA textures
#if defined COMPILE_DAYZ_INCLUDES
	#include "tstudio\alltextures420.pwn"
#else
	#include "tstudio\alltextures.pwn"
#endif

// Valid SA models
#include "tstudio\validmodels.pwn"

// Model sizes
#include "tstudio\modelsizes.pwn"

// Include 3D Menus (By SDraw)
#include "tstudio\3dmenu.pwn"

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
#define         MAX_TEXT_LENGTH             128


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
	return SendClientMessage(playerid, STEALTH_YELLOW, "You need to finish editng your object before using this command"); }

// Checks if model is valid
#define ModelIsValid(%0); if(!IsValidModel(%0)) { \
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________"); \
	return SendClientMessage(playerid, STEALTH_YELLOW, "Invalid Model!"); }

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
	oGroup,                                     // Object group
	oModel,                                     // Object Model
	Text3D:oTextID,                             // Object 3d text label
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

// Theme data
new DB: ThemeDataDB;

// Checks if a map is open
new bool:MapOpen;

// Webcolor list
#include "tstudio\webcolors.pwn"

// Flymode
#include "tstudio\flymode.pwn"

// Text editor module
#include "tstudio\texteditor.pwn"

// Texture viewer
#include "tstudio\texviewer.pwn"

// Group editing
#include "tstudio\groups.pwn"

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
#if defined COMPILE_GTA_OBJECTS
	#include "tstudio\gtaobjects.pwn"
#endif

// Vehicles
#include "tstudio\vehiclecolors.pwn"
#include "tstudio\vehicles.pwn"

// Special includes
#if defined COMPILE_DAYZ_INCLUDES
//	#include "tstudio\420\mangle.pwn"
#endif

// Menu GUI
#include "tstudio\menugui.pwn"


////////////////////////////////////////////////////////////////////////////////
/// Standard Callbacks /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

public OnFilterScriptInit()
{
	print("----------------------------------------------");
	print("---------Texture Studio By [uL]Pottus---------");
	print("-------------------------------------Loaded---");

	SystemDB = db_open_persistent("tstudio/system.db");
	ThemeDataDB = db_open_persistent("tstudio/themedata.db");
	sqlite_ThemeSetup();
	sqlite_LoadBindString();
	return 1;
}

public OnFilterScriptExit()
{
	print("----------------------------------------------");
	print("---------Texture Studio By [uL]Pottus---------");
	print("-----------------------------------Unloaded---");

	// Delete all map objects
	DeleteMapObjects(false);

	// Clear all removed buildings
	ClearRemoveBuildings();

	foreach(new i : Player)
	{
 		ClearCopyBuffer(i);
	}

	// Always close map
	db_free_persistent(EditMap);
	db_free_persistent(SystemDB);
	db_free_persistent(ThemeDataDB);

	foreach(new i : Player)
	{
	    CancelSelectTextDraw(i);
	}

	return 1;
}

public OnPlayerConnect(playerid)
{
    RemoveAllBuildings(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	CurrObject[playerid] = -1;
	EditingMode[playerid] = false;
	TextDrawOpen[playerid] = false;
	PivotPointOn[playerid] = false;
	SetEditMode(playerid, EDIT_MODE_NONE);
	SetCurrTextDraw(playerid, TEXTDRAW_NONE);
	ClearCopyBuffer(playerid);
	return 1;
}

stock SetCurrObject(playerid, index)
{
    CurrObject[playerid] = index;
	CallLocalFunction("OnPlayerObjectSelectChange", "ii", playerid, index);
	return 1;
}

OnPlayerKeyStateChangeOEdit(playerid,newkeys,oldkeys)
{
	#pragma unused oldkeys
	if(GetEditMode(playerid) == EDIT_MODE_OBJECT)
	{
		// Clone object
	    if(newkeys & KEY_WALK)
		{
			Edit_SetObjectPos(CurrObject[playerid], CurrEditPos[playerid][0], CurrEditPos[playerid][1], CurrEditPos[playerid][2], CurrEditPos[playerid][3], CurrEditPos[playerid][4], CurrEditPos[playerid][5], true);
            SetCurrObject(playerid, CloneObject(CurrObject[playerid]));
            EditDynamicObject(playerid, ObjectData[CurrObject[playerid]][oID]);
            SendClientMessage(playerid, STEALTH_GREEN, "Object has been cloned");
	    }

		// Update object position
	    else if(newkeys & KEY_SECONDARY_ATTACK)
	    {
			Edit_SetObjectPos(CurrObject[playerid], CurrEditPos[playerid][0], CurrEditPos[playerid][1], CurrEditPos[playerid][2], CurrEditPos[playerid][3], CurrEditPos[playerid][4], CurrEditPos[playerid][5], true);
			SendClientMessage(playerid, STEALTH_GREEN, "Object position updated and saved");
	    }
	}
	return 0;
}

// player finished editing an object
hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	switch(GetEditMode(playerid))
	{
	    case EDIT_MODE_OBJECT:
	    {
			// Player finished editing an object
			if(response == EDIT_RESPONSE_FINAL)
			{
				Edit_SetObjectPos(CurrObject[playerid], x, y, z, rx, ry, rz, true);

				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Object edit has been saved");

				EditingMode[playerid] = false;
				SetEditMode(playerid, EDIT_MODE_NONE);
			}
			else if(response == EDIT_RESPONSE_UPDATE)
			{
				CurrEditPos[playerid][0] = x;
				CurrEditPos[playerid][1] = y;
				CurrEditPos[playerid][2] = z;
				CurrEditPos[playerid][3] = rx;
				CurrEditPos[playerid][4] = ry;
				CurrEditPos[playerid][5] = rz;
			}
			
			// Cancel editing
			else if(response == EDIT_RESPONSE_CANCEL)
			{
				SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);
				SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
				
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "Cancelled object editing");

				EditingMode[playerid] = false;
				SetEditMode(playerid, EDIT_MODE_NONE);
			}
		}

		case EDIT_MODE_PIVOT:
		{
			if(response == EDIT_RESPONSE_FINAL)
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Pivot has been saved");

				DestroyDynamicObject(PivotObject[playerid]);

				PivotPoint[playerid][xPos] = x;
				PivotPoint[playerid][yPos] = y;
				PivotPoint[playerid][zPos] = z;

				EditingMode[playerid] = false;
				SetEditMode(playerid, EDIT_MODE_NONE);

		    }
    		else if(response == EDIT_RESPONSE_CANCEL)
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "Cancelled Pivot editing");

				DestroyDynamicObject(PivotObject[playerid]);

				EditingMode[playerid] = false;
				SetEditMode(playerid, EDIT_MODE_NONE);

			}
		}
		case EDIT_MODE_OBJECTGROUP: OnPlayerEditDOGroup(playerid, objectid, response, x, y, z, rx, ry, rz);
		case EDIT_MODE_OBM: OnPlayerEditDOOBM(playerid, objectid, response, x, y, z, rx, ry, rz);
		
		case EDIT_MODE_VOBJECT: OnPlayerEditVObject(playerid, objectid, response, x, y, z, rx, ry, rz);
	}
	return 1;
}

// Player clicked a dynamic object
public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
{
	switch(GetEditMode(playerid))
	{
		case EDIT_MODE_SELECTION:
		{
		    new Keys,ud,lr,index;
		    GetPlayerKeys(playerid,Keys,ud,lr);

			// Find edit object
			foreach(new i : Objects)
			{
				// Object found
			    if(ObjectData[i][oID] == objectid)
				{
					index = i;
				    break;
				}
			}

			if(Keys & KEY_CTRL_BACK)
			{
				CopyCopyBuffer(playerid, index);

			    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		    	SendClientMessage(playerid, STEALTH_GREEN, "Copied object textures/color/text to buffer");
			}
			else if(Keys & KEY_WALK)
			{
				PasteCopyBuffer(playerid, index);
				
			    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Pasted your copy buffer to object");
			}
			else
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

				new line[128];
				format(line, sizeof(line), "You have selected object index %i for editing", index);
				SendClientMessage(playerid, STEALTH_GREEN, line);

				SetCurrObject(playerid, index);
			}
		}
	}
	return 1;
}

// Player clicked textdraw
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	// Text editing mode
	if(GetCurrTextDraw(playerid) == TEXTDRAW_TEXTEDIT) if(ClickTextDrawEditText(playerid, Text:clickedid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_MATERIALS) if(ClickTextDrawEditMat(playerid, Text:clickedid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_LISTSEL) if(ClickTextDrawListSel(playerid, Text:clickedid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_OSEARCH) if(ClickTextDrawOSearch(playerid, Text:clickedid)) return 1;
    
	return 0;
}



// Player clicked player textdraw
hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	// Text editing mode
    if(GetCurrTextDraw(playerid) == TEXTDRAW_TEXTEDIT) if(ClickPlayerTextDrawEditText(playerid, PlayerText:playertextid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_MATERIALS) if(ClickPlayerTextDrawEditMat(playerid, PlayerText:playertextid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_LISTSEL) if(ClickPlayerTextListSel(playerid, PlayerText:playertextid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_OSEARCH) if(ClickPlayerTextDrawOSearch(playerid, PlayerText:playertextid)) return 1;
	return 0;
}


public OnPlayerKeyStateChange(playerid,newkeys,oldkeys)
{
	if(OnPlayerKeyStateChangeOEdit(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateChange3DMenu(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateGroupChange(playerid, newkeys, oldkeys)) return 1;
    if(OnPlayerKeyStateMenuChange(playerid, newkeys, oldkeys)) return 1;
    if(OnPlayerKeyStateChangeTex(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateChangeLSel(playerid,newkeys,oldkeys)) return 1;
	return 1;
}


////////////////////////////////////////////////////////////////////////////////
/// Standard Callbacks End//////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
/// Sqlite query functions /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Load query stmt
static DBStatement:loadstmt;

// Loads map objects from a data base
sqlite_LoadMapObjects()
{
	new tmpobject[OBJECTINFO];
	new currindex;

	loadstmt = db_prepare(EditMap, "SELECT * FROM `Objects`");

	// Bind our results
    stmt_bind_result_field(loadstmt, 0, DB::TYPE_INT, currindex);
    stmt_bind_result_field(loadstmt, 1, DB::TYPE_INT, tmpobject[oModel]);
    stmt_bind_result_field(loadstmt, 2, DB::TYPE_FLOAT, tmpobject[oX]);
    stmt_bind_result_field(loadstmt, 3, DB::TYPE_FLOAT, tmpobject[oY]);
    stmt_bind_result_field(loadstmt, 4, DB::TYPE_FLOAT, tmpobject[oZ]);
    stmt_bind_result_field(loadstmt, 5, DB::TYPE_FLOAT, tmpobject[oRX]);
    stmt_bind_result_field(loadstmt, 6, DB::TYPE_FLOAT, tmpobject[oRY]);
    stmt_bind_result_field(loadstmt, 7, DB::TYPE_FLOAT, tmpobject[oRZ]);
    stmt_bind_result_field(loadstmt, 8, DB::TYPE_ARRAY, tmpobject[oTexIndex], MAX_MATERIALS);
    stmt_bind_result_field(loadstmt, 9, DB::TYPE_ARRAY, tmpobject[oColorIndex], MAX_MATERIALS);
    stmt_bind_result_field(loadstmt, 10, DB::TYPE_INT, tmpobject[ousetext]);
    stmt_bind_result_field(loadstmt, 11, DB::TYPE_INT, tmpobject[oFontFace]);
    stmt_bind_result_field(loadstmt, 12, DB::TYPE_INT, tmpobject[oFontSize]);
    stmt_bind_result_field(loadstmt, 13, DB::TYPE_INT, tmpobject[oFontBold]);
    stmt_bind_result_field(loadstmt, 14, DB::TYPE_INT, tmpobject[oFontColor]);
    stmt_bind_result_field(loadstmt, 15, DB::TYPE_INT, tmpobject[oBackColor]);
    stmt_bind_result_field(loadstmt, 16, DB::TYPE_INT, tmpobject[oAlignment]);
    stmt_bind_result_field(loadstmt, 17, DB::TYPE_INT, tmpobject[oTextFontSize]);
    stmt_bind_result_field(loadstmt, 18, DB::TYPE_STRING, tmpobject[oObjectText], MAX_TEXT_LENGTH);
    stmt_bind_result_field(loadstmt, 19, DB::TYPE_INT, tmpobject[oGroup]);

	// Execute query
    if(stmt_execute(loadstmt))
    {
        while(stmt_fetch_row(loadstmt))
        {
			// Load object into database at specified index (Don't save to sqlite database)
			AddDynamicObject(tmpobject[oModel], tmpobject[oX], tmpobject[oY], tmpobject[oZ], tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ], currindex, false);

			// Set textures and colors
			for(new i = 0; i < MAX_MATERIALS; i++)
			{
                ObjectData[currindex][oTexIndex][i] = tmpobject[oTexIndex][i];
	            ObjectData[currindex][oColorIndex][i] = tmpobject[oColorIndex][i];
			}

			// Get all text settings
		   	ObjectData[currindex][ousetext] = tmpobject[ousetext];
		    ObjectData[currindex][oFontFace] = tmpobject[oFontFace];
		    ObjectData[currindex][oFontSize] = tmpobject[oFontSize];
		    ObjectData[currindex][oFontBold] = tmpobject[oFontBold];
		    ObjectData[currindex][oFontColor] = tmpobject[oFontColor];
		    ObjectData[currindex][oBackColor] = tmpobject[oBackColor];
		    ObjectData[currindex][oAlignment] = tmpobject[oAlignment];
		    ObjectData[currindex][oTextFontSize] = tmpobject[oTextFontSize];
		    ObjectData[currindex][oGroup] = tmpobject[oGroup];

			// Get any text string
			format(ObjectData[currindex][oObjectText], MAX_TEXT_LENGTH, "%s", tmpobject[oObjectText]);

			// We need to update textures and materials
			UpdateMaterial(currindex);
			
			// Update the object text
			UpdateObjectText(currindex);

			// Update 3d text
			UpdateObject3DText(currindex, true);
        }
        return 1;
    }
    return 0;
}

// Insert stmt statement
new DBStatement:insertstmt;
new InsertObjectString[512];

// Sqlite query functions
sqlite_InsertObject(index)
{
	// Inserts a new index
	if(!InsertObjectString[0])
	{
		// Prepare query
		strimplode(" ",
			InsertObjectString,
			sizeof(InsertObjectString),
			"INSERT INTO `Objects`",
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
		insertstmt = db_prepare(EditMap, InsertObjectString);
	}
	
	// Bind values


	// Bind our results
    stmt_bind_value(insertstmt, 0, DB::TYPE_INT, index);
    stmt_bind_value(insertstmt, 1, DB::TYPE_INT, ObjectData[index][oModel]);
    stmt_bind_value(insertstmt, 2, DB::TYPE_FLOAT, ObjectData[index][oX]);
    stmt_bind_value(insertstmt, 3, DB::TYPE_FLOAT, ObjectData[index][oY]);
    stmt_bind_value(insertstmt, 4, DB::TYPE_FLOAT, ObjectData[index][oZ]);
    stmt_bind_value(insertstmt, 5, DB::TYPE_FLOAT, ObjectData[index][oRX]);
    stmt_bind_value(insertstmt, 6, DB::TYPE_FLOAT, ObjectData[index][oRY]);
    stmt_bind_value(insertstmt, 7, DB::TYPE_FLOAT, ObjectData[index][oRZ]);
    stmt_bind_value(insertstmt, 8, DB::TYPE_ARRAY, ObjectData[index][oTexIndex], MAX_MATERIALS);
    stmt_bind_value(insertstmt, 9, DB::TYPE_ARRAY, ObjectData[index][oColorIndex], MAX_MATERIALS);
    stmt_bind_value(insertstmt, 10, DB::TYPE_INT, ObjectData[index][ousetext]);
    stmt_bind_value(insertstmt, 11, DB::TYPE_INT, ObjectData[index][oFontFace]);
    stmt_bind_value(insertstmt, 12, DB::TYPE_INT, ObjectData[index][oFontSize]);
    stmt_bind_value(insertstmt, 13, DB::TYPE_INT, ObjectData[index][oFontBold]);
    stmt_bind_value(insertstmt, 14, DB::TYPE_INT, ObjectData[index][oFontColor]);
    stmt_bind_value(insertstmt, 15, DB::TYPE_INT, ObjectData[index][oBackColor]);
    stmt_bind_value(insertstmt, 16, DB::TYPE_INT, ObjectData[index][oAlignment]);
    stmt_bind_value(insertstmt, 17, DB::TYPE_INT, ObjectData[index][oTextFontSize]);
    stmt_bind_value(insertstmt, 18, DB::TYPE_STRING, ObjectData[index][oObjectText], MAX_TEXT_LENGTH);
    stmt_bind_value(insertstmt, 19, DB::TYPE_INT, ObjectData[index][oGroup]);
    
    stmt_execute(insertstmt);
}

// Remove a object from the database
sqlite_RemoveObject(index)
{
	new Query[128];
	format(Query, sizeof(Query), "DELETE FROM `Objects` WHERE `IndexID` = '%i'", index);
	
	db_free_result(db_query(EditMap, Query));
	return 1;
}


sqlite_CreateNewMap()
{
    sqlite_CreateMapDB();
    sqlite_CreateRBDB();
    sqlite_CreateVehicle();
}

new NewMapString[512];
sqlite_CreateMapDB()
{
	if(!NewMapString[0])
	{
		strimplode(" ",
			NewMapString,
			sizeof(NewMapString),
			"CREATE TABLE IF NOT EXISTS `Objects`",
			"(IndexID INTEGER,",
			"ModelID INTEGER,",
			"xPos REAL,",
			"yPos REAL,",
			"zPos REAL,",
			"rxRot REAL,",
			"ryRot REAL,",
			"rzRot REAL,",
			"TextureIndex TEXT,",
			"ColorIndex TEXT,",
			"usetext INTEGER,",
			"FontFace INTEGER,",
			"FontSize INTEGER,",
			"FontBold INTEGER,",
			"FontColor INTEGER,",
			"BackColor INTEGER,",
			"Alignment INTEGER,",
			"TextFontSize INTEGER,",
			"ObjectText TEXT,",
			"GroupID INTEGER);"
		);
	}

	db_exec(EditMap, NewMapString);
}

// Version 1.2 removebuilding import lines
new NewRemoveString[512];
sqlite_CreateRBDB()
{
	if(!NewRemoveString[0])
	{
		strimplode(" ",
			NewRemoveString,
			sizeof(NewRemoveString),
			"CREATE TABLE IF NOT EXISTS `RemovedBuildings`",
			"(ModelID INTEGER,",
			"xPos REAL,",
			"yPos REAL,",
			"zPos REAL,",
			"Range REAL);"
		);
	}
	db_exec(EditMap, NewRemoveString);
}

// Makes any version updates
sqlite_UpdateDB()
{
    sqlite_CreateRBDB();
    sqlite_CreateVehicle();
    
    // Version 1.3
    if(!ColumnExists(EditMap, "Objects", "GroupID")) db_exec(EditMap, "ALTER TABLE `Objects` ADD COLUMN `GroupID` INTEGER DEFAULT 0");

	return 1;
}


new DBStatement:texturestmt;
new TextureUpdateString[512];

// Saves a specific texture index to DB
sqlite_SaveMaterialIndex(index)
{
	// Inserts a new index
	if(!TextureUpdateString[0])
	{
		// Prepare query
		strimplode(" ",
			TextureUpdateString,
			sizeof(TextureUpdateString),
			"UPDATE `Objects` SET",
			"`TextureIndex` = ?",
			"WHERE `IndexID` = ?"
		);
        texturestmt = db_prepare(EditMap, TextureUpdateString);
	}
	
	// Bind values
	stmt_bind_value(texturestmt, 0, DB::TYPE_ARRAY, ObjectData[index][oTexIndex], MAX_MATERIALS);
	stmt_bind_value(texturestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(texturestmt);

	return 1;
}

new DBStatement:colorstmt;
new ColorUpdateString[512];

// Saves a specific texture index to DB
sqlite_SaveColorIndex(index)
{
	// Inserts a new index
	if(!ColorUpdateString[0])
	{
		// Prepare query
		strimplode(" ",
			ColorUpdateString,
			sizeof(ColorUpdateString),
			"UPDATE `Objects` SET",
			"`ColorIndex` = ?",
			"WHERE `IndexID` = ?"
		);
        colorstmt = db_prepare(EditMap, ColorUpdateString);
	}

	// Bind values
	stmt_bind_value(colorstmt, 0, DB::TYPE_ARRAY, ObjectData[index][oColorIndex], MAX_MATERIALS);
	stmt_bind_value(colorstmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(colorstmt);

	return 1;
}

new DBStatement:posupdatestmt;
new PosUpdateString[512];

sqlite_UpdateObjectPos(index)
{
	// Inserts a new index
	if(!PosUpdateString[0])
	{
		// Prepare query
		strimplode(" ",
			PosUpdateString,
			sizeof(PosUpdateString),
			"UPDATE `Objects` SET",
			"`xPos` = ?,",
			"`yPos` = ?,",
			"`zPos` = ?,",
			"`rxRot` = ?,",
			"`ryRot` = ?,",
			"`rzRot` = ?",
			"WHERE `IndexID` = ?"
		);
        posupdatestmt = db_prepare(EditMap, PosUpdateString);
	}

	// Bind values
	stmt_bind_value(posupdatestmt, 0, DB::TYPE_FLOAT, ObjectData[index][oX]);
	stmt_bind_value(posupdatestmt, 1, DB::TYPE_FLOAT, ObjectData[index][oY]);
	stmt_bind_value(posupdatestmt, 2, DB::TYPE_FLOAT, ObjectData[index][oZ]);
	stmt_bind_value(posupdatestmt, 3, DB::TYPE_FLOAT, ObjectData[index][oRX]);
	stmt_bind_value(posupdatestmt, 4, DB::TYPE_FLOAT, ObjectData[index][oRY]);
	stmt_bind_value(posupdatestmt, 5, DB::TYPE_FLOAT, ObjectData[index][oRZ]);
	stmt_bind_value(posupdatestmt, 6, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(posupdatestmt);
    
	foreach(new i : Player)
	{
		if(CurrObject[i] == index) OnObjectUpdatePos(i, index);
	}

    return 1;
}


// Update sql object text
new DBStatement:objecttextallsave;
new ObjectTextSave[512];

stock sqlite_SaveAllObjectText(index)
{
	if(!ObjectTextSave[0])
	{
		strimplode(" ",
			ObjectTextSave,
			sizeof(ObjectTextSave),
			"UPDATE `Objects` SET",
			"`usetext` = ?,",
			"`FontFace` = ?,",
			"`FontSize` = ?,",
			"`FontBold` = ?,",
			"`FontColor` = ?,",
			"`BackColor` = ?,",
			"`Alignment` = ?,",
			"`TextFontSize` = ?,",
			"`ObjectText` = ?",
			"WHERE `IndexID` = ?"
		);
		objecttextallsave = db_prepare(EditMap, ObjectTextSave);
	}
	
	// Bind values
	stmt_bind_value(objecttextallsave, 0, DB::TYPE_INT, ObjectData[index][ousetext]);
	stmt_bind_value(objecttextallsave, 1, DB::TYPE_INT, ObjectData[index][oFontFace]);
	stmt_bind_value(objecttextallsave, 2, DB::TYPE_INT, ObjectData[index][oFontSize]);
	stmt_bind_value(objecttextallsave, 3, DB::TYPE_INT, ObjectData[index][oFontBold]);
	stmt_bind_value(objecttextallsave, 4, DB::TYPE_INT, ObjectData[index][oFontColor]);
	stmt_bind_value(objecttextallsave, 5, DB::TYPE_INT, ObjectData[index][oBackColor]);
	stmt_bind_value(objecttextallsave, 6, DB::TYPE_INT, ObjectData[index][oAlignment]);
	stmt_bind_value(objecttextallsave, 7, DB::TYPE_INT, ObjectData[index][oTextFontSize]);
	stmt_bind_value(objecttextallsave, 8, DB::TYPE_STRING, ObjectData[index][oObjectText]);
	stmt_bind_value(objecttextallsave, 9, DB::TYPE_INT, index);

	stmt_execute(objecttextallsave);
}



// Update sql use text
new DBStatement:usetextupdatestmt;
new UseTextString[512];

stock sqlite_ObjUseText(index)
{
	if(!UseTextString[0])
	{
		strimplode(" ",
			UseTextString,
			sizeof(UseTextString),
			"UPDATE `Objects` SET",
			"`usetext` = ?",
			"WHERE `IndexID` = ?"
		);
		usetextupdatestmt = db_prepare(EditMap, UseTextString);
	}

	// Bind values
	stmt_bind_value(usetextupdatestmt, 0, DB::TYPE_INT, ObjectData[index][ousetext]);
	stmt_bind_value(usetextupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(usetextupdatestmt);
	return 1;
}

// Update sql fontface
new DBStatement:fontfaceupdatestmt;
new FontFaceString[512];

stock sqlite_ObjFontFace(index)
{
	if(!FontFaceString[0])
	{
		strimplode(" ",
			FontFaceString,
			sizeof(FontFaceString),
			"UPDATE `Objects` SET",
			"`FontFace` = ?",
			"WHERE `IndexID` = ?"
		);
		fontfaceupdatestmt = db_prepare(EditMap, FontFaceString);
	}

	// Bind values
	stmt_bind_value(fontfaceupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontFace]);
	stmt_bind_value(fontfaceupdatestmt, 1, DB::TYPE_INT, index);
	
	// Execute stmt
    stmt_execute(fontfaceupdatestmt);
	return 1;
}

// Update sql fontsize
new DBStatement:fontsizeupdatestmt;
new FontSizeString[512];

stock sqlite_ObjFontSize(index)
{
	if(!FontSizeString[0])
	{
		strimplode(" ",
			FontSizeString,
			sizeof(FontSizeString),
			"UPDATE `Objects` SET",
			"`FontSize` = ?",
			"WHERE `IndexID` = ?"
		);
		fontsizeupdatestmt = db_prepare(EditMap, FontSizeString);
	}

	// Bind values
	stmt_bind_value(fontsizeupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontSize]);
	stmt_bind_value(fontsizeupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontsizeupdatestmt);
	return 1;
}



// Update sql fontbold
new DBStatement:fontboldupdatestmt;
new FontBoldString[512];

stock sqlite_ObjFontBold(index)
{
	if(!FontBoldString[0])
	{
		strimplode(" ",
			FontBoldString,
			sizeof(FontBoldString),
			"UPDATE `Objects` SET",
			"`FontBold` = ?",
			"WHERE `IndexID` = ?"
		);
		fontboldupdatestmt = db_prepare(EditMap, FontBoldString);
	}

	// Bind values
	stmt_bind_value(fontboldupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontBold]);
	stmt_bind_value(fontboldupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontboldupdatestmt);
	return 1;
}

// Update sql fontcolor
new DBStatement:fontcolorupdatestmt;
new FontColorString[512];

stock sqlite_ObjFontColor(index)
{
	if(!FontColorString[0])
	{
		strimplode(" ",
			FontColorString,
			sizeof(FontColorString),
			"UPDATE `Objects` SET",
			"`FontColor` = ?",
			"WHERE `IndexID` = ?"
		);
		fontcolorupdatestmt = db_prepare(EditMap, FontColorString);
	}

	// Bind values
	stmt_bind_value(fontcolorupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontColor]);
	stmt_bind_value(fontcolorupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontcolorupdatestmt);
	return 1;
}

// Update sql backcolor
new DBStatement:backcolorupdatestmt;
new BackColorString[512];

stock sqlite_ObjBackColor(index)
{
	if(!BackColorString[0])
	{
		strimplode(" ",
			BackColorString,
			sizeof(BackColorString),
			"UPDATE `Objects` SET",
			"`BackColor` = ?",
			"WHERE `IndexID` = ?"
		);
		backcolorupdatestmt = db_prepare(EditMap, BackColorString);
	}

	// Bind values
	stmt_bind_value(backcolorupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oBackColor]);
	stmt_bind_value(backcolorupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(backcolorupdatestmt);
	return 1;
}

// Update sql alignment
new DBStatement:alignmentupdatestmt;
new AlignmentString[512];


stock sqlite_ObjAlignment(index)
{
	if(!AlignmentString[0])
	{
		strimplode(" ",
			AlignmentString,
			sizeof(AlignmentString),
			"UPDATE `Objects` SET",
			"`Alignment` = ?",
			"WHERE `IndexID` = ?"
		);
		alignmentupdatestmt = db_prepare(EditMap, AlignmentString);
	}

	// Bind values
	stmt_bind_value(alignmentupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oAlignment]);
	stmt_bind_value(alignmentupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(alignmentupdatestmt);
	return 1;
}

// Update sql textsize
new DBStatement:textsizeupdatestmt;
new TextSizeString[512];

stock sqlite_ObjFontTextSize(index)
{
	if(!TextSizeString[0])
	{
		strimplode(" ",
			TextSizeString,
			sizeof(TextSizeString),
			"UPDATE `Objects` SET",
			"`TextFontSize` = ?",
			"WHERE `IndexID` = ?"
		);
		textsizeupdatestmt = db_prepare(EditMap, TextSizeString);
	}

	// Bind values
	stmt_bind_value(textsizeupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oTextFontSize]);
	stmt_bind_value(textsizeupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(textsizeupdatestmt);
	return 1;
}

// Update sql object text
new DBStatement:objecttextupdatestmt;
new ObjectTextString[512];

stock sqlite_ObjObjectText(index)
{
	if(!ObjectTextString[0])
	{
		strimplode(" ",
			ObjectTextString,
			sizeof(ObjectTextString),
			"UPDATE `Objects` SET",
			"`ObjectText` = ?",
			"WHERE `IndexID` = ?"
		);
		objecttextupdatestmt = db_prepare(EditMap, ObjectTextString);
	}

	// Bind values
	stmt_bind_value(objecttextupdatestmt, 0, DB::TYPE_STRING, ObjectData[index][oObjectText]);
	stmt_bind_value(objecttextupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objecttextupdatestmt);
	return 1;
}

// Update sql object group
new DBStatement:objectgroupupdatestmt;
new ObjectGroupString[512];

stock sqlite_ObjGroup(index)
{
	if(!ObjectTextString[0])
	{
		strimplode(" ",
			ObjectGroupString,
			sizeof(ObjectGroupString),
			"UPDATE `Objects` SET",
			"`GroupID` = ?",
			"WHERE `IndexID` = ?"
		);
		objectgroupupdatestmt = db_prepare(EditMap, ObjectGroupString);
	}

	// Bind values
	stmt_bind_value(objectgroupupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oGroup]);
	stmt_bind_value(objectgroupupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objectgroupupdatestmt);
	return 1;
}


// Update sql object model
new DBStatement:objectmodelupdatestmt;
new ObjectModelString[512];

stock sqlite_ObjModel(index)
{
	if(!ObjectModelString[0])
	{
		strimplode(" ",
			ObjectModelString,
			sizeof(ObjectModelString),
			"UPDATE `Objects` SET",
			"`ModelID` = ?",
			"WHERE `IndexID` = ?"
		);
		objectmodelupdatestmt = db_prepare(EditMap, ObjectModelString);
	}

	// Bind values
	stmt_bind_value(objectmodelupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oModel]);
	stmt_bind_value(objectmodelupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objectmodelupdatestmt);
	return 1;
}





// Insert a remove building to DB
new DBStatement:insertremovebuldingstmt;
new InsertRemoveBuildingString[256];

stock sqlite_InsertRemoveBuilding(index)
{
	// Inserts a new index
	if(!InsertRemoveBuildingString[0])
	{
		// Prepare query
		strimplode(" ",
			InsertRemoveBuildingString,
			sizeof(InsertRemoveBuildingString),
			"INSERT INTO `RemovedBuildings`",
	        "VALUES(?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
		insertremovebuldingstmt = db_prepare(EditMap, InsertRemoveBuildingString);
	}

	// Bind our results
    stmt_bind_value(insertremovebuldingstmt, 0, DB::TYPE_INT, RemoveData[index][rModel]);
    stmt_bind_value(insertremovebuldingstmt, 1, DB::TYPE_FLOAT, RemoveData[index][rX]);
    stmt_bind_value(insertremovebuldingstmt, 2, DB::TYPE_FLOAT, RemoveData[index][rY]);
    stmt_bind_value(insertremovebuldingstmt, 3, DB::TYPE_FLOAT, RemoveData[index][rZ]);
    stmt_bind_value(insertremovebuldingstmt, 4, DB::TYPE_FLOAT, RemoveData[index][rRange]);

    stmt_execute(insertremovebuldingstmt);
}

// Load any remove buildings
new DBStatement:loadremovebuldingstmt;

stock sqlite_LoadRemoveBuildings()
{
	new tmpremove[REMOVEINFO];

	loadremovebuldingstmt = db_prepare(EditMap, "SELECT * FROM `RemovedBuildings`");

	// Bind our results
    stmt_bind_result_field(loadremovebuldingstmt, 0, DB::TYPE_INT, tmpremove[rModel]);
    stmt_bind_result_field(loadremovebuldingstmt, 1, DB::TYPE_FLOAT, tmpremove[rX]);
    stmt_bind_result_field(loadremovebuldingstmt, 2, DB::TYPE_FLOAT, tmpremove[rY]);
    stmt_bind_result_field(loadremovebuldingstmt, 3, DB::TYPE_FLOAT, tmpremove[rZ]);
    stmt_bind_result_field(loadremovebuldingstmt, 4, DB::TYPE_FLOAT, tmpremove[rRange]);

	// Execute query
    if(stmt_execute(loadremovebuldingstmt))
    {
        while(stmt_fetch_row(loadremovebuldingstmt))
        {
			// Add the removed building
			AddRemoveBuilding(tmpremove[rModel], tmpremove[rX], tmpremove[rY], tmpremove[rZ], tmpremove[rRange], false);
        }
        return 1;
    }
    return 0;
}


////////////////////////////////////////////////////////////////////////////////
/// Sqlite query functions end /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
/// Support functions //////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Resets all data on a object slot
ResetObjectIndex(index)
{
	new tmpobject[OBJECTINFO];
	ObjectData[index] = tmpobject;
	return 1;
}

// Sets the material/and or color of an object
UpdateMaterial(index)
{
	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		if(ObjectData[index][oTexIndex][i] != 0) SetDynamicObjectMaterial(ObjectData[index][oID], i, GetTModel(ObjectData[index][oTexIndex][i]), GetTXDName(ObjectData[index][oTexIndex][i]), GetTextureName(ObjectData[index][oTexIndex][i]), ObjectData[index][oColorIndex][i]);
		else if(ObjectData[index][oColorIndex][i] != 0) SetDynamicObjectMaterial(ObjectData[index][oID], i, -1, "none", "none", ObjectData[index][oColorIndex][i]);
	}
	return 1;
}

// Highlights a object
HighlightObject(index)
{
    for(new i = 0; i < MAX_MATERIALS; i++) SetDynamicObjectMaterial(ObjectData[index][oID], i, -1, "none", "none", HIGHLIGHT_OBJECT_COLOR);
	return 1;
}


// Updates any text for an object
UpdateObjectText(index)
{
	// Dialogs return literal values this will fix that issue to display correctly
	new tmptext[MAX_TEXT_LENGTH];
	strcat(tmptext, ObjectData[index][oObjectText], MAX_TEXT_LENGTH);
    FixText(tmptext);

	if(ObjectData[index][ousetext])
	{
		SetDynamicObjectMaterialText(ObjectData[index][oID],
			0,
			tmptext,
			FontSizes[ObjectData[index][oFontSize]],
			FontNames[ObjectData[index][oFontFace]],
			ObjectData[index][oTextFontSize],
			ObjectData[index][oFontBold],
			ObjectData[index][oFontColor],
			ObjectData[index][oBackColor],
			ObjectData[index][oAlignment]);
		return 1;
	}
	return 0;
}

// Fixes new line and tabs in material text
FixText(text[])
{
	new len = strlen(text);
	if(len > 1)
	{
		for(new i = 0; i < len; i++)
		{
			if(text[i] == 92)
			{
				// New line
			    if(text[i+1] == 'n')
			    {
					text[i] = '\n';
					for(new j = i+1; j < len; j++) text[j] = text[j+1], text[j+1] = 0;
					continue;
			    }

				// Tab
			    if(text[i+1] == 't')
			    {
					text[i] = '\t';
					for(new j = i+1; j < len-1; j++) text[j] = text[j+1], text[j+1] = 0;
					continue;
			    }

				// Literal
			    if(text[i+1] == 92)
			    {
					text[i] = 92;
					for(new j = i+1; j < len-1; j++) text[j] = text[j+1], text[j+1] = 0;
			    }
			}
		}
	}
	return 1;
}


Edit_SetObjectPos(index, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, bool:save)
{
	ObjectData[index][oX] = x;
    ObjectData[index][oY] = y;
    ObjectData[index][oZ] = z;
    ObjectData[index][oRX] = rx;
    ObjectData[index][oRY] = ry;
    ObjectData[index][oRZ] = rz;

	SetDynamicObjectPos(ObjectData[index][oID], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ]);
	SetDynamicObjectRot(ObjectData[index][oID], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ]);

	if(save)
	{
		// Update object 3d text position
		UpdateObject3DText(index);

		// Update the database
	    sqlite_UpdateObjectPos(index);
	}
	
	return 1;
}

UpdateObject3DText(index, bool:newobject=false)
{
	OnUpdateGroup3DText(index);

	if(!newobject) DestroyDynamic3DTextLabel(ObjectData[index][oTextID]);

	// 3D Text Label (To identify objects)
	new line[64];
	format(line, sizeof(line), "Ind: {33DD11}%i {FF8800}Grp:{33DD11} %i", index, ObjectData[index][oGroup]);


		// Shows the models index
	if(ObjectData[index][oAttachedVehicle] > -1)
	{
		ObjectData[index][oTextID] = CreateDynamic3DTextLabel(line, 0xFF8800FF, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], TEXT3D_DRAW_DIST, INVALID_PLAYER_ID, CarData[ObjectData[index][oAttachedVehicle]][CarID]);
		Update3DAttachCarPos(index, ObjectData[index][oAttachedVehicle]);
	}
	else ObjectData[index][oTextID] = CreateDynamic3DTextLabel(line, 0xFF8800FF, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], TEXT3D_DRAW_DIST);

	// Update the streamer
	foreach(new i : Player)
	{
	    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
	}

	return 1;
}

// Rotation functions (Thanks to Stylock)

// Calculates group object / whole map rotations
stock AttachObjectToPoint(objectid, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, &Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1)
{
    new
        Float:g_sin[3],
        Float:g_cos[3],

        Float:off_x,
        Float:off_y,
        Float:off_z;

    EDIT_FloatEulerFix(prx, pry, prz);


    off_x = ObjectData[objectid][oX] - px; // static offset
    off_y = ObjectData[objectid][oY] - py; // static offset
    off_z = ObjectData[objectid][oZ] - pz; // static offset
	
    // Calculate the new position
    EDIT_FloatConvertValue(prx, pry, prz, g_sin, g_cos);
    RetX = px + off_x * g_cos[1] * g_cos[2] - off_x * g_sin[0] * g_sin[1] * g_sin[2] - off_y * g_cos[0] * g_sin[2] + off_z * g_sin[1] * g_cos[2] + off_z * g_sin[0] * g_cos[1] * g_sin[2];
    RetY = py + off_x * g_cos[1] * g_sin[2] + off_x * g_sin[0] * g_sin[1] * g_cos[2] + off_y * g_cos[0] * g_cos[2] + off_z * g_sin[1] * g_sin[2] - off_z * g_sin[0] * g_cos[1] * g_cos[2];
    RetZ = pz - off_x * g_cos[0] * g_sin[1] + off_y * g_sin[0] + off_z * g_cos[0] * g_cos[1];

    if (sync_rotation)
    {
        // Calculate the new rotation
        EDIT_FloatConvertValue(asin(g_cos[0] * g_cos[1]), atan2(g_sin[0], g_cos[0] * g_sin[1]) + ObjectData[objectid][oRZ], atan2(g_cos[1] * g_cos[2] * g_sin[0] - g_sin[1] * g_sin[2], g_cos[2] * g_sin[1] - g_cos[1] * g_sin[0] * -g_sin[2]), g_sin, g_cos);
 	  	EDIT_FloatConvertValue(asin(g_cos[0] * g_sin[1]), atan2(g_cos[0] * g_cos[1], g_sin[0]), atan2(g_cos[2] * g_sin[0] * g_sin[1] - g_cos[1] * g_sin[2], g_cos[1] * g_cos[2] + g_sin[0] * g_sin[1] * g_sin[2]), g_sin, g_cos);
        EDIT_FloatConvertValue(atan2(g_sin[0], g_cos[0] * g_cos[1]) + ObjectData[objectid][oRX], asin(g_cos[0] * g_sin[1]), atan2(g_cos[2] * g_sin[0] * g_sin[1] + g_cos[1] * g_sin[2], g_cos[1] * g_cos[2] - g_sin[0] * g_sin[1] * g_sin[2]), g_sin, g_cos);

   	    RetRX = asin(g_cos[1] * g_sin[0]);
		RetRY = atan2(g_sin[1], g_cos[0] * g_cos[1]) + ObjectData[objectid][oRY];
		RetRZ = atan2(g_cos[0] * g_sin[2] - g_cos[2] * g_sin[0] * g_sin[1], g_cos[0] * g_cos[2] + g_sin[0] * g_sin[1] * g_sin[2]);
    }
}

stock AttachObjectToPoint_GroupEdit(objectid, Float:offx, Float:offy, Float:offz, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, &Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1)
{
    new
        Float:g_sin[3],
        Float:g_cos[3],
        Float:off_x,
        Float:off_y,
        Float:off_z;

    EDIT_FloatEulerFix(prx, pry, prz);

    off_x = offx - px; // static offset
    off_y = offy - py; // static offset
    off_z = offz - pz; // static offset

    // Calculate the new position
    EDIT_FloatConvertValue(prx, pry, prz, g_sin, g_cos);
    RetX = px + off_x * g_cos[1] * g_cos[2] - off_x * g_sin[0] * g_sin[1] * g_sin[2] - off_y * g_cos[0] * g_sin[2] + off_z * g_sin[1] * g_cos[2] + off_z * g_sin[0] * g_cos[1] * g_sin[2];
    RetY = py + off_x * g_cos[1] * g_sin[2] + off_x * g_sin[0] * g_sin[1] * g_cos[2] + off_y * g_cos[0] * g_cos[2] + off_z * g_sin[1] * g_sin[2] - off_z * g_sin[0] * g_cos[1] * g_cos[2];
    RetZ = pz - off_x * g_cos[0] * g_sin[1] + off_y * g_sin[0] + off_z * g_cos[0] * g_cos[1];

    if (sync_rotation)
    {
        // Calculate the new rotation
        EDIT_FloatConvertValue(asin(g_cos[0] * g_cos[1]), atan2(g_sin[0], g_cos[0] * g_sin[1]) + ObjectData[objectid][oRZ], atan2(g_cos[1] * g_cos[2] * g_sin[0] - g_sin[1] * g_sin[2], g_cos[2] * g_sin[1] - g_cos[1] * g_sin[0] * -g_sin[2]), g_sin, g_cos);
 	  	EDIT_FloatConvertValue(asin(g_cos[0] * g_sin[1]), atan2(g_cos[0] * g_cos[1], g_sin[0]), atan2(g_cos[2] * g_sin[0] * g_sin[1] - g_cos[1] * g_sin[2], g_cos[1] * g_cos[2] + g_sin[0] * g_sin[1] * g_sin[2]), g_sin, g_cos);
        EDIT_FloatConvertValue(atan2(g_sin[0], g_cos[0] * g_cos[1]) + ObjectData[objectid][oRX], asin(g_cos[0] * g_sin[1]), atan2(g_cos[2] * g_sin[0] * g_sin[1] + g_cos[1] * g_sin[2], g_cos[1] * g_cos[2] - g_sin[0] * g_sin[1] * g_sin[2]), g_sin, g_cos);

   	    RetRX = asin(g_cos[1] * g_sin[0]);
		RetRY = atan2(g_sin[1], g_cos[0] * g_cos[1]) + ObjectData[objectid][oRY];
		RetRZ = atan2(g_cos[0] * g_sin[2] - g_cos[2] * g_sin[0] * g_sin[1], g_cos[0] * g_cos[2] + g_sin[0] * g_sin[1] * g_sin[2]);
    }
}


stock AttachPoint(Float:offx, Float:offy, Float:offz, Float:offrx, Float:offry, Float:offrz, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, &Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1)
{
    new
        Float:g_sin[3],
        Float:g_cos[3],
        Float:off_x,
        Float:off_y,
        Float:off_z;

    EDIT_FloatEulerFix(prx, pry, prz);

    off_x = offx - px; // static offset
    off_y = offy - py; // static offset
    off_z = offz - pz; // static offset

    // Calculate the new position
    EDIT_FloatConvertValue(prx, pry, prz, g_sin, g_cos);
    RetX = px + off_x * g_cos[1] * g_cos[2] - off_x * g_sin[0] * g_sin[1] * g_sin[2] - off_y * g_cos[0] * g_sin[2] + off_z * g_sin[1] * g_cos[2] + off_z * g_sin[0] * g_cos[1] * g_sin[2];
    RetY = py + off_x * g_cos[1] * g_sin[2] + off_x * g_sin[0] * g_sin[1] * g_cos[2] + off_y * g_cos[0] * g_cos[2] + off_z * g_sin[1] * g_sin[2] - off_z * g_sin[0] * g_cos[1] * g_cos[2];
    RetZ = pz - off_x * g_cos[0] * g_sin[1] + off_y * g_sin[0] + off_z * g_cos[0] * g_cos[1];

    if (sync_rotation)
    {
        // Calculate the new rotation
        EDIT_FloatConvertValue(asin(g_cos[0] * g_cos[1]), atan2(g_sin[0], g_cos[0] * g_sin[1]) + offrz, atan2(g_cos[1] * g_cos[2] * g_sin[0] - g_sin[1] * g_sin[2], g_cos[2] * g_sin[1] - g_cos[1] * g_sin[0] * -g_sin[2]), g_sin, g_cos);
 	  	EDIT_FloatConvertValue(asin(g_cos[0] * g_sin[1]), atan2(g_cos[0] * g_cos[1], g_sin[0]), atan2(g_cos[2] * g_sin[0] * g_sin[1] - g_cos[1] * g_sin[2], g_cos[1] * g_cos[2] + g_sin[0] * g_sin[1] * g_sin[2]), g_sin, g_cos);
        EDIT_FloatConvertValue(atan2(g_sin[0], g_cos[0] * g_cos[1]) + offrx, asin(g_cos[0] * g_sin[1]), atan2(g_cos[2] * g_sin[0] * g_sin[1] + g_cos[1] * g_sin[2], g_cos[1] * g_cos[2] - g_sin[0] * g_sin[1] * g_sin[2]), g_sin, g_cos);

   	    RetRX = asin(g_cos[1] * g_sin[0]);
		RetRY = atan2(g_sin[1], g_cos[0] * g_cos[1]) + offry;
		RetRZ = atan2(g_cos[0] * g_sin[2] - g_cos[2] * g_sin[0] * g_sin[1], g_cos[0] * g_cos[2] + g_sin[0] * g_sin[1] * g_sin[2]);
    }
}





stock EDIT_FloatConvertValue(Float:rot_x, Float:rot_y, Float:rot_z, Float:sin[3], Float:cos[3])
{
    sin[0] = floatsin(rot_x, degrees);
    sin[1] = floatsin(rot_y, degrees);
    sin[2] = floatsin(rot_z, degrees);
    cos[0] = floatcos(rot_x, degrees);
    cos[1] = floatcos(rot_y, degrees);
    cos[2] = floatcos(rot_z, degrees);
    return 1;
}

/*
 * Fixes a bug that causes objects to not rotate
 * correctly when rotating on the Z axis only.
 */
stock EDIT_FloatEulerFix(&Float:rot_x, &Float:rot_y, &Float:rot_z)
{
    EDIT_FloatGetRemainder(rot_x, rot_y, rot_z);
    if((!floatcmp(rot_x, 0.0) || !floatcmp(rot_x, 360.0))
    && (!floatcmp(rot_y, 0.0) || !floatcmp(rot_y, 360.0)))
    {
        rot_y = 0.00000002;
    }
    return 1;
}

stock EDIT_FloatGetRemainder(&Float:rot_x, &Float:rot_y, &Float:rot_z)
{
    EDIT_FloatRemainder(rot_x, 360.0);
    EDIT_FloatRemainder(rot_y, 360.0);
    EDIT_FloatRemainder(rot_z, 360.0);
    return 1;
}

stock EDIT_FloatRemainder(&Float:remainder, Float:value)
{
    if(remainder >= value)
    {
        while(remainder >= value)
        {
            remainder = remainder - value;
        }
    }
    else if(remainder < 0.0)
    {
        while(remainder < 0.0)
        {
            remainder = remainder + value;
        }
    }
    return 1;
}

// Gets the center of the map
GetMapCenter(&Float:X, &Float:Y, &Float:Z)
{
	new Float:highX = -9999999.0;
	new Float:highY = -9999999.0;
	new Float:highZ = -9999999.0;

	new Float:lowX  = 9999999.0;
	new Float:lowY  = 9999999.0;
	new Float:lowZ  = 9999999.0;

	new count;

	foreach(new i : Objects)
	{
		if(ObjectData[i][oX] > highX) highX = ObjectData[i][oX];
		if(ObjectData[i][oY] > highY) highY = ObjectData[i][oY];
		if(ObjectData[i][oZ] > highZ) highZ = ObjectData[i][oZ];
		if(ObjectData[i][oX] < lowX) lowX = ObjectData[i][oX];
		if(ObjectData[i][oY] < lowY) lowY = ObjectData[i][oY];
		if(ObjectData[i][oZ] < lowZ) lowZ = ObjectData[i][oZ];
		count++;
	}

	// Not enough objects grouped
	if(count < 2) return 0;


	X = (highX + lowX) / 2;
	Y = (highY + lowY) / 2;
	Z = (highZ + lowZ) / 2;

	return 1;
}
////////////////////////////////////////////////////////////////////////////////
/// Support functions end///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Stock functions ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


stock AddDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, index = -1, bool:sqlsave = true)
{
	// Index was not specified get a free index
	if(index == -1) index = Iter_Free(Objects);

	//Found free index
	if(index != -1)
	{
		// Add iterator
		Iter_Add(Objects, index);

		// Create object and set data
		ObjectData[index][oID] = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, -1, -1, -1, 300.0);
		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

		// Update the streamer
		foreach(new i : Player)
		{
		    if(IsPlayerInRangeOfPoint(i, 300.0, x, y, z)) Streamer_Update(i);
		}

		ObjectData[index][oModel] = modelid;
		ObjectData[index][oX] = x;
		ObjectData[index][oY] = y;
		ObjectData[index][oZ] = z;
		ObjectData[index][oRX] = rx;
		ObjectData[index][oRY] = ry;
		ObjectData[index][oRZ] = rz;
		
		ObjectData[index][oAttachedVehicle] = -1;
		
		if(sqlsave)
		{
	   		ObjectData[index][ousetext] = 0;
	    	ObjectData[index][oFontFace] = 0;
	    	ObjectData[index][oFontSize] = 0;
	    	ObjectData[index][oFontBold] = 0;
	    	ObjectData[index][oFontColor] = 0;
	    	ObjectData[index][oBackColor] = 0;
	    	ObjectData[index][oAlignment] = 0;
	    	ObjectData[index][oTextFontSize] = 20;
	    	ObjectData[index][oGroup] = 0;

			format(ObjectData[index][oObjectText], MAX_TEXT_LENGTH, "%s", "None");

			sqlite_InsertObject(index);
		}

		return index;
	}
	else print("Error: Tried to add too many dynamic objects");
	return index;
}

stock DeleteDynamicObject(index, bool:sqlsave = true)
{
	OnDeleteGroup3DText(index);

	new next;
	if(Iter_Contains(Objects, index))
	{
		if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedObjectRef(ObjectData[index][oAttachedVehicle], index);

	    DestroyDynamicObject(ObjectData[index][oID]);
	    DestroyDynamic3DTextLabel(ObjectData[index][oTextID]);

	    Iter_SafeRemove(Objects, index, next);

		ResetObjectIndex(index);
		
		GroupUpdate(index);
		
		if(sqlsave) sqlite_RemoveObject(index);

		return next;
	}
	print("Error: Tried to delete a object which does not exist");
	return -1;
}

stock CloneObject(index)
{
	if(Iter_Contains(Objects, index))
	{
    	new cindex = AddDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ]);
        
  		ObjectData[cindex][ousetext] = ObjectData[index][ousetext];
	   	ObjectData[cindex][oFontFace] = ObjectData[index][oFontFace];
	   	ObjectData[cindex][oFontSize] = ObjectData[index][oFontSize];
	   	ObjectData[cindex][oFontBold] = ObjectData[index][oFontBold];
	   	ObjectData[cindex][oFontColor] = ObjectData[index][oFontColor];
	   	ObjectData[cindex][oBackColor] = ObjectData[index][oBackColor];
	   	ObjectData[cindex][oAlignment] = ObjectData[index][oAlignment];
	   	ObjectData[cindex][oTextFontSize] = ObjectData[index][oTextFontSize];
	   	ObjectData[cindex][oGroup] = ObjectData[index][oGroup];

		for(new i = 0; i < MAX_MATERIALS; i++)
		{
			ObjectData[cindex][oTexIndex][i] = ObjectData[index][oTexIndex][i];
			ObjectData[cindex][oColorIndex][i] = ObjectData[index][oColorIndex][i];
		}

		format(ObjectData[cindex][oObjectText], MAX_TEXT_LENGTH, "%s", ObjectData[index][oObjectText]);

		// Update the materials
		UpdateMaterial(cindex);

		// Update object text
		UpdateObjectText(cindex);
		
		// Update 3D text
		UpdateObject3DText(cindex, true);
		
		// Save materials to material database
		sqlite_SaveMaterialIndex(cindex);

		// Save colors to material database
		sqlite_SaveColorIndex(cindex);
		
		// Save any text
		sqlite_SaveAllObjectText(cindex);

		return cindex;
  	}
	printf("ERROR: Tried to clone a non-existant object");
	return -1;
}


// Deletes all map objects
stock DeleteMapObjects(bool:sqlsave)
{
	foreach(new i : Objects)
	{
        i = DeleteDynamicObject(i, sqlsave);
	}

	// Reset any player variables
	foreach(new i : Player)
	{
		SetCurrObject(i, -1);
	}
	return 1;
}

// Add a remove building
stock AddRemoveBuilding(model, Float:x, Float:y, Float:z, Float:range, savesql = true)
{
	for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
	{
	    if(RemoveData[i][rModel] == 0)
	    {
	        RemoveData[i][rModel] = model;
	        RemoveData[i][rX] = x;
	        RemoveData[i][rY] = y;
	        RemoveData[i][rZ] = z;
	        RemoveData[i][rRange] = range;
	        
			if(savesql) sqlite_InsertRemoveBuilding(i);

			foreach(new j : Player)
			{
				RemoveBuildingForPlayer(j, model, x, y, z, range);
			}
			return 1;
	    }
	}
	return 0;
}

stock ClearRemoveBuildings()
{
	new count;
	for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
	{
		if(RemoveData[i][rModel] != 0)
		{
		    RemoveData[i][rModel] = 0;
		    count++;
		}
	}
	if(count)
	{
		SendClientMessageToAll(STEALTH_YELLOW, "Warning: The previous map had removed objects you will have to reconnect to see them");

		#if defined COMPILE_GTA_OBJECTS
			ResetGTADeletedObjects();
		#endif
	}
	return 1;
}

stock RemoveAllBuildings(playerid)
{
	for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
	{
	    if(RemoveData[i][rModel] != 0)
	    {
			RemoveBuildingForPlayer(playerid, RemoveData[i][rModel], RemoveData[i][rX], RemoveData[i][rY], RemoveData[i][rZ], RemoveData[i][rRange]);
	    }
	}
}

// Is string a hexvalue
stock IsHexValue(hstring[])
{
	if(strlen(hstring) < 10) return 0;
	if(hstring[0] == 48 && hstring[1] == 120)
	{
		for(new i = 2; i < 10; i++)
		{
			if(hstring[i] == 48 || hstring[i] == 49 || hstring[i] == 50 || hstring[i] == 51 || hstring[i] == 52 ||
				hstring[i] == 53 || hstring[i] == 54 || hstring[i] == 55 || hstring[i] == 56 || hstring[i] == 57 ||
				hstring[i] == 65 || hstring[i] == 66 || hstring[i] == 67 || hstring[i] == 68 || hstring[i] == 69 ||
				hstring[i] == 70) continue;
			else return 0;
		}
	}
	else return 0;
	return 1;
}

// Get position in front of player also returns facing angle
stock GetPosFaInFrontOfPlayer(playerid, Float:OffDist, &Float:Pxx, &Float:Pyy, &Float:Pzz, &Float:Fa, Float:rotoff = 0.0)
{
	if(!IsPlayerConnected(playerid)) return 0;
	new
	    Float:playerpos[3],
		Float:FacingA;
	GetPlayerPos(playerid, playerpos[0], playerpos[1], playerpos[2]);
	GetPlayerFacingAngle(playerid, FacingA);
	FacingA += rotoff;

	Pxx = (playerpos[0] + OffDist * floatsin(-FacingA,degrees));
	Pyy = (playerpos[1] + OffDist * floatcos(-FacingA,degrees));
	Pzz = playerpos[2];
	Fa = (FacingA > 180) ? (FacingA - 180) : (FacingA + 180);
	return 1;
}

////////////////////////////////////////////////////////////////////////////////
/// Stock functions ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
/// Commands  //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Echo text to player useful for keybind (Autohotkey)
CMD:echo(playerid, arg[])
{
	SendClientMessage(playerid, -1, arg);
	return 1;
}


// Pick a map to load
CMD:loadmap(playerid, arg[])    // In GUI
{
	// Map was already open
	if(MapOpen)
	{
		// Confirm open map
	    inline Confirm(cpid, cdialogid, cresponse, clistitem, string:ctext[])
		{
			#pragma unused clistitem, cdialogid, cpid, ctext

			// Open a map
		    if(cresponse)
			{
				// Close map
				db_free_persistent(EditMap);

				// Delete all map objects
                DeleteMapObjects(false);

				// Clear all removed buildings
				ClearRemoveBuildings();
				
				// Load map
				LoadMap(playerid);
				
				// Clean up vehicles
				ClearVehicles();
				
				// Clear copy buffer
	            foreach(new i : Player)
				{
					ClearCopyBuffer(i);
				}
			}
		}
		Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_MSGBOX, "Texture Studio", "You have a map open are you sure you want to load another map?\n(Note: Your map is already saved)", "Ok", "Cancel");
	}
	else LoadMap(playerid);
	return 1;
}

// Load map function call
LoadMap(playerid)
{
	// Loop through saved maps

	new dir:dHandle = dir_open("./scriptfiles/tstudio/SavedMaps/");
	new item[40], type;
	new line[1024];
	new extension[3];
	new fcount;

	// Create a load list
	while(dir_list(dHandle, item, type))
	{
   		if(type != FM_DIR)
	    {
			// We need to check extension
			if(strlen(item) > 3)
			{
				format(extension, sizeof(extension), "%s%s", item[strlen(item) - 2],item[strlen(item) - 1]);

				// File is apparently a db
				if(!strcmp(extension, "db"))
				{
					format(line, sizeof(line), "%s\n%s", item, line);
					fcount++;
				}
			}
	    }
	}

	// Files were found
	if(fcount > 0)
	{
        inline Select(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused slistitem, sdialogid, spid

			// Player selected map to load
            if(sresponse)
            {
				new mapname[128];
				format(mapname, sizeof(mapname), "tstudio/SavedMaps/%s", stext);

				// Map is now open
                EditMap = db_open_persistent(mapname);

				// Perform any version updates
				sqlite_UpdateDB();

				// Load the maps remove buildings
			    sqlite_LoadRemoveBuildings();

                // Load the maps objects
                sqlite_LoadMapObjects();
                
				// Load any vehicles
			    sqlite_LoadCars();

				// Map is now open
                MapOpen = true;

				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "You have loaded a map");
            }
        }
        Dialog_ShowCallback(playerid, using inline Select, DIALOG_STYLE_LIST, "Texture Studio (Load Map)", line, "Ok", "Cancel");
	}
	// No files found
 	else
	{
	    inline CreateMap(cpid, cdialogid, cresponse, clistitem, string:ctext[])
	    {
            #pragma unused clistitem, cdialogid, cpid, ctext
 			if(cresponse) NewMap(playerid);
	    }
	    Dialog_ShowCallback(playerid, using inline CreateMap, DIALOG_STYLE_MSGBOX, "Texture Studio", "There are no maps to load create a new map?", "Ok", "Cancel");
	}
	return 1;
}

// Create a new map
CMD:newmap(playerid, arg[]) // In GUI
{
	// Map was already open
	if(MapOpen)
	{
		// Confirm open map
	    inline Confirm(cpid, cdialogid, cresponse, clistitem, string:ctext[])
		{
			#pragma unused clistitem, cdialogid, cpid, ctext

			// Open a map
		    if(cresponse)
			{
				// Close map
				db_free_persistent(EditMap);

				// Delete all map objects
                DeleteMapObjects(false);
                
				// Clear all removed buildings
				ClearRemoveBuildings();

				// Clean up vehicles
				ClearVehicles();
				
				// No map open
                MapOpen = false;

				// Load map
				NewMap(playerid);
				
				// Reset player variables
				foreach(new i : Player)
				{
                    CancelEdit(i);
					EditingMode[i] = false;
                    SetCurrObject(playerid, -1);
                    ClearCopyBuffer(i);
				}
			}
		}
		Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_MSGBOX, "Texture Studio", "You have a map open are you sure you want to create a new map?\n(Note: Your map is already saved)", "Ok", "Cancel");
	}
	else NewMap(playerid);
	return 1;
}

// New map function call
NewMap(playerid)
{
    inline CreateMap(cpid, cdialogid, cresponse, clistitem, string:ctext[])
	{
	    #pragma unused clistitem, cdialogid, cpid
		if(cresponse)
	    {
			if(!isnull(ctext))
			{
				new mapname[128];
				format(mapname, sizeof(mapname), "tstudio/SavedMaps/%s.db", ctext);

				if(!fexist(mapname))
				{
					// Open the map for editing
		            EditMap = db_open_persistent(mapname);

					// Create new table for map
		            sqlite_CreateNewMap();

					// Map is now open
		            MapOpen = true;

					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_GREEN, "You have created a new map");
				}
				else
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "A map with that name already exists");
					NewMap(playerid);
				}
			}
			else
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "You must give your new map a filename");
				NewMap(playerid);
			}
	    }
	}
	Dialog_ShowCallback(playerid, using inline CreateMap, DIALOG_STYLE_INPUT, "Texture Studio", "Enter a new map name", "Ok", "Cancel");
}

// Imports CreateObject() or CreateDynamic() raw code
CMD:importmap(playerid, arg[]) // In GUI
{
	if(MapOpen)
	{
		// The map already has objects
		if(Iter_Count(Objects))
		{
			// Ask to load more objects
		    inline Import(ipid, idialogid, iresponse, ilistitem, string:itext[])
			{
				#pragma unused ilistitem, idialogid, ipid, itext
				if(iresponse) ImportMap(playerid);
			}
	        Dialog_ShowCallback(playerid, using inline Import, DIALOG_STYLE_MSGBOX, "Texture Studio", "This map has objects are you import more objects?", "Ok", "Cancel");
		}
		// No map loaded import a new map
		else ImportMap(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "A map must be open before trying to import");
	}
	return 1;
}

// Import map function
ImportMap(playerid)
{
	new dir:dHandle = dir_open("./scriptfiles/tstudio/ImportMaps/");
	new templine[256];
	new tempmap[256];
	new item[40], itype;
	new line[1024];
	new fcount;
	new tmp[16];
	new tmpobject[OBJECTINFO];
	new tmpremove[REMOVEINFO];

	// Create a load list
	while(dir_list(dHandle, item, itype))
	{
   		if(itype != FM_DIR)
	    {
			format(line, sizeof(line), "%s\n%s", item, line);
			fcount++;
	    }
	}

	// Found import files
	if(fcount > 0)
	{
        inline Select(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused slistitem, sdialogid, spid
			// Selected a file
            if(sresponse)
            {
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Map importing has started, this make a while depending on map size");

				format(tempmap, 64, "tstudio/ImportMaps/%s",stext);

				new File:f;
				new icount, rcount;
				f = fopen(tempmap,io_read);

				// Read lines and import data
				while(fread(f,templine,sizeof(templine),false))
				{
					// Is the line a valid create object line?

					strtrim(templine);
					new type;
			  		if(strfind(templine, "CreateObject", true) != -1) type = 1;
			        if(strfind(templine, "CreateDynamicObject", true) != -1) type = 2;
			        if(strfind(templine, "RemoveBuildingForPlayer", true) != -1) type = 3;
					if(type == 0) continue;
					if(type == 1) strmid(templine, templine, 13, sizeof(templine), sizeof(templine));
					if(type == 2) strmid(templine, templine, 20, sizeof(templine), sizeof(templine));
					if(type == 3) strmid(templine, templine, 24, sizeof(templine), sizeof(templine));
					
					strmid(templine, templine, 0, strfind(templine, ");", true), sizeof(templine));

					if(type == 1 || type == 2)
					{
						sscanf(templine, "p<,>iffffff", tmpobject[oModel], tmpobject[oX], tmpobject[oY], tmpobject[oZ],
						    tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ]);

						// Create the new object
				        AddDynamicObject(tmpobject[oModel], tmpobject[oX], tmpobject[oY], tmpobject[oZ], tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ]);
	                    icount++;
					}
					else if(type == 3)
					{
						sscanf(templine, "p<,>s[16]iffff", tmp, tmpremove[rModel], tmpremove[rX], tmpremove[rY], tmpremove[rZ], tmpremove[rRange]);
						
						// Delete building
						AddRemoveBuilding(tmpremove[rModel], tmpremove[rX], tmpremove[rY], tmpremove[rZ], tmpremove[rRange], true);
						
					    rcount++;
					}
				}

				format(templine, sizeof(templine), "%i objects were imported, %i removed buildings were imported", icount, rcount);
				SendClientMessage(playerid, STEALTH_GREEN, templine);
				
				// Were done importing
				fclose(f);
            }
		}
        Dialog_ShowCallback(playerid, using inline Select, DIALOG_STYLE_LIST, "Texture Studio (Import Map)", line, "Ok", "Cancel");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There are no maps to import");
	}
	return 1;
}


CMD:export(playerid, arg[])
{
	MapOpenCheck();
	
	inline Export(epid, edialogid, eresponse, elistitem, string:etext[])
	{
        #pragma unused elistitem, edialogid, epid, etext
		if(eresponse)
		{
		    switch(elistitem)
		    {
		        case 0: BroadcastCommand(playerid, "/exportmap");
				case 1: BroadcastCommand(playerid, "/exportallmap");
		        case 2: BroadcastCommand(playerid, "/avexport");
		        case 3: BroadcastCommand(playerid, "/avexportall");
		    }
		}
	}
	
	Dialog_ShowCallback(playerid, using inline Export, DIALOG_STYLE_LIST, "Texture Studio (Export Mode)", "Export Map\nExport All Map To Filerscript\nExport Current Car\nExport All Cars", "Ok", "Cancel");
	return 1;
}


// Export map to create object
CMD:exportmap(playerid, arg[]) // In GUI
{
	MapOpenCheck();
	
	// Ask for a map name
	inline ExportMap(epid, edialogid, eresponse, elistitem, string:etext[])
	{
	    #pragma unused elistitem, edialogid, epid
	    if(eresponse)
	    {
			// Was a map name supplied ?
			if(!isnull(etext))
			{
				// Get the draw distance
	            inline DrawDist(dpid, ddialogid, dresponse, dlistitem, string:dtext[])
	            {
	                #pragma unused dlistitem, ddialogid, dpid
					new Float:dist;

					// Set the drawdistance
					if(dresponse)
					{
                        if(sscanf(dtext, "f", dist)) dist = 300.0;
					}
					else dist = 300.0;
					
					new exportmap[256];

					// Check map name length
					if(strlen(etext) >= 20)
					{
						SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
						SendClientMessage(playerid, STEALTH_YELLOW, "Choose a shorter map name to export to...");
						return 1;
					}

					// Format the output name
					format(exportmap, sizeof(exportmap), "tstudio/ExportMaps/%s.txt", etext);

					// Map exists ask to remove
				    if(fexist(exportmap))
					{
						inline RemoveMap(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
						{
					        #pragma unused rlistitem, rdialogid, rpid, rtext

							// Remove map and export
					        if(rresponse)
					        {
					            fremove(exportmap);
					            MapExport(playerid, exportmap, dist);
					        }
						}
						Dialog_ShowCallback(playerid, using inline RemoveMap, DIALOG_STYLE_MSGBOX, "Texture Studio (Export Map)", "A export exists with this name replace?", "Ok", "Cancel");
					}
					// We can start the export
					else MapExport(playerid, exportmap, dist);
				}
            	Dialog_ShowCallback(playerid, using inline DrawDist, DIALOG_STYLE_INPUT, "Texture Studio (Map Export)", "Enter the draw distance for objects\n(Note: Default draw distance is 300.0)", "Ok", "Cancel");
			}
			else
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "You can't export a map with no name");
				Dialog_ShowCallback(playerid, using inline ExportMap, DIALOG_STYLE_INPUT, "Texture Studio (Map Export)", "Enter a export map name", "Ok", "Cancel");
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline ExportMap, DIALOG_STYLE_INPUT, "Texture Studio (Map Export)", "Enter a export map name", "Ok", "Cancel");
	return 1;
}


// Start exporting
MapExport(playerid, mapname[], Float:drawdist)
{
	new exportmap[256];
	
	format(exportmap, sizeof(exportmap), "%s", mapname);
	
    inline ExportType(epid, edialogid, eresponse, elistitem, string:etext[])
    {
		#pragma unused edialogid, epid, etext
		if(eresponse)
		{
			new mobjects;
			new templine[256];
			new File:f;
			f = fopen(exportmap,io_write);

			fwrite(f,"//Map Exported with Texture Studio By: [uL]Pottus////////////////////////////////////////////////////////////////\r\n");
			fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
			fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

			if(RemoveData[0][rModel] != 0) fwrite(f,"\r\n//Remove Buildings///////////////////////////////////////////////////////////////////////////////////////////////\r\n");
			
			for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
			{
			    if(RemoveData[i][rModel] != 0)
			    {
					format(templine, sizeof(templine), "RemoveBuildingForPlayer(playerid, %i, %.3f, %.3f, %.3f, %.3f);\r\n", RemoveData[i][rModel], RemoveData[i][rX], RemoveData[i][rY], RemoveData[i][rZ], RemoveData[i][rRange]);
                    fwrite(f,templine);
				}
			}

			fwrite(f,"\r\n//Objects////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

			// Temp object for setting materials
			format(templine,sizeof(templine),"new tmpobjid;\r\n");
			fwrite(f,templine);

			// Write all objects with materials first
			foreach(new i : Objects)
			{
			    if(ObjectData[i][oAttachedVehicle] > -1) continue;

				new bool:writeobject;

				// Does the object have materials?
		        for(new j = 0; j < MAX_MATERIALS; j++)
		        {
		            if(ObjectData[i][oTexIndex][j] != 0 || ObjectData[i][oColorIndex][j] != 0 || ObjectData[i][ousetext])
		            {
						writeobject = true;
						break;
					}
				}

				// Object had materials we will write them to the export file
				if(writeobject)
				{
					mobjects++;

					// Write the create object line
					if(elistitem == 0)
					{
				        format(templine,sizeof(templine),"tmpobjid = CreateObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist);
				        fwrite(f,templine);
					}

					// Write the create dynamic object line
					else if(elistitem == 1)
					{
						format(templine,sizeof(templine),"tmpobjid = CreateDynamicObjectEx(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist,drawdist);
				        fwrite(f,templine);
					}
					else if(elistitem  == 2)
					{
						format(templine,sizeof(templine),"tmpobjid = CreateDynamicObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,-1,-1,-1,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist,drawdist);
				        fwrite(f,templine);
					}
					
					// Write all materials and colors
		  			for(new j = 0; j < MAX_MATERIALS; j++)
		        	{
						// Does object have a texture set?
			            if(ObjectData[i][oTexIndex][j] != 0)
			            {
							if(elistitem == 0)
							{
								format(templine,sizeof(templine),"SetObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, %i);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
							else if(elistitem == 1 || elistitem == 2)
							{
								format(templine,sizeof(templine),"SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, %i);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
			            }
			            // No texture how about a color?
			            else if(ObjectData[i][oColorIndex][j] != 0)
			            {
							if(elistitem == 0)
							{
								format(templine,sizeof(templine),"SetObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, %i);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
							else if(elistitem == 1 || elistitem == 2)
							{
								format(templine,sizeof(templine),"SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, %i);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
						}
					}
					
					// Write any text
					if(ObjectData[i][ousetext])
					{
						if(elistitem == 0)
						{
							format(templine,sizeof(templine),"SetObjectMaterialText(tmpobjid, %c%s%c, 0, %i, %c%s%c, %i, %i, %i, %i, %i);\r\n",
								34, ObjectData[i][oObjectText], 34,
								FontSizes[ObjectData[i][oFontSize]],
								34, FontNames[ObjectData[i][oFontFace]], 34,
								ObjectData[i][oTextFontSize],
								ObjectData[i][oFontBold],
								ObjectData[i][oFontColor],
								ObjectData[i][oBackColor],
								ObjectData[i][oAlignment]
							);
						}
						else if(elistitem == 1 || elistitem == 2)
						{
							format(templine,sizeof(templine),"SetDynamicObjectMaterialText(tmpobjid, 0, %c%s%c, %i, %c%s%c, %i, %i, %i, %i, %i);\r\n",
								34, ObjectData[i][oObjectText], 34,
								FontSizes[ObjectData[i][oFontSize]],
								34, FontNames[ObjectData[i][oFontFace]], 34,
								ObjectData[i][oTextFontSize],
								ObjectData[i][oFontBold],
								ObjectData[i][oFontColor],
								ObjectData[i][oBackColor],
								ObjectData[i][oAlignment]
							);
						}
						fwrite(f,templine);
					}
				}
			}

			if(mobjects)
			{
				fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
				fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
				fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
			}

			// We need to write all of the objects that didn't have materials set now
			foreach(new i : Objects)
			{
			    if(ObjectData[i][oAttachedVehicle] > -1) continue;

				new bool:writeobject = true;

				// Does the object have materials?
		        for(new j = 0; j < MAX_MATERIALS; j++)
		        {
					// This object has already been written
		            if(ObjectData[i][oTexIndex][j] != 0 || ObjectData[i][oColorIndex][j] != 0 || ObjectData[i][ousetext])
		            {
						writeobject = false;
						break;
					}
				}

				// Object has not been exported yet export
				if(writeobject)
				{
					if(elistitem == 0)
					{
				        format(templine,sizeof(templine),"tmpobjid = CreateObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist);
				        fwrite(f,templine);
					}
					else if(elistitem == 1)
					{
				        format(templine,sizeof(templine),"tmpobjid = CreateDynamicObjectEx(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist,drawdist);
				        fwrite(f,templine);
					}
					else if(elistitem == 2)
					{
						format(templine,sizeof(templine),"tmpobjid = CreateDynamicObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,-1,-1,-1,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist,drawdist);
				        fwrite(f,templine);
					}
				}
			}

			fclose(f);
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			format(templine, sizeof(templine), "Map has been exported to %s", exportmap);
			SendClientMessage(playerid, STEALTH_GREEN, templine);

		}
	}
    Dialog_ShowCallback(playerid, using inline ExportType, DIALOG_STYLE_LIST, "Texture Studio (Export Map)", "Type 1 - CreateObject()\nType 2 - CreateDynamicObjectEx()\nType 3 - CreateDyanmicObject", "Ok", "Cancel");

	return 1;
}

// Export map to create object
CMD:exportallmap(playerid, arg[]) // In GUI
{
	MapOpenCheck();

	// Ask for a map name
	inline ExportMap(epid, edialogid, eresponse, elistitem, string:etext[])
	{
	    #pragma unused elistitem, edialogid, epid
	    if(eresponse)
	    {
			// Was a map name supplied ?
			if(!isnull(etext))
			{
				// Get the draw distance
	            inline DrawDist(dpid, ddialogid, dresponse, dlistitem, string:dtext[])
	            {
	                #pragma unused dlistitem, ddialogid, dpid
					new Float:dist;

					// Set the drawdistance
					if(dresponse)
					{
                        if(sscanf(dtext, "f", dist)) dist = 300.0;
					}
					else dist = 300.0;

					new exportmap[256];

					// Check map name length
					if(strlen(etext) >= 20)
					{
						SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
						SendClientMessage(playerid, STEALTH_YELLOW, "Choose a shorter map name to export to...");
						return 1;
					}

					// Format the output name
					format(exportmap, sizeof(exportmap), "tstudio/ExportMaps/%s.pwn", etext);

					// Map exists ask to remove
				    if(fexist(exportmap))
					{
						inline RemoveMap(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
						{
					        #pragma unused rlistitem, rdialogid, rpid, rtext

							// Remove map and export
					        if(rresponse)
					        {
					            fremove(exportmap);
					            MapExportAll(playerid, exportmap, dist);
					        }
						}
						Dialog_ShowCallback(playerid, using inline RemoveMap, DIALOG_STYLE_MSGBOX, "Texture Studio (Export Map)", "A export exists with this name replace?", "Ok", "Cancel");
					}
					// We can start the export
					else MapExportAll(playerid, exportmap, dist);
				}
            	Dialog_ShowCallback(playerid, using inline DrawDist, DIALOG_STYLE_INPUT, "Texture Studio (Map Export)", "Enter the draw distance for objects\n(Note: Default draw distance is 300.0)", "Ok", "Cancel");
			}
			else
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "You can't export a map with no name");
				Dialog_ShowCallback(playerid, using inline ExportMap, DIALOG_STYLE_INPUT, "Texture Studio (Map All Export)", "Enter a export map name", "Ok", "Cancel");
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline ExportMap, DIALOG_STYLE_INPUT, "Texture Studio (Map All Export)", "Enter a export map name", "Ok", "Cancel");
	return 1;
}

static MapExportAll(playerid, name[], Float:drawdist)
{
	new File:f = fopen(name, io_write);
	new templine[256];
	new mobjects;

	// Header
	fwrite(f,"//Map Filterscript Exported with Texture Studio By: [uL]Pottus///////////////////////////////////////////////////\r\n");
	fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
	fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

	// Includes
	fwrite(f, "#include <a_samp>\r\n");
	fwrite(f, "#include <streamer>\r\n\n");

	new CarCount = Iter_Count(Cars);
	new CurrCar;

	// Car id
	for(new i = 0; i < CarCount; i++)
	{
		format(templine, sizeof(templine), "new carvid_%i;\r\n", i);
		fwrite(f, templine);
	}

	fwrite(f, "\n");

	// Init script
    fwrite(f, "public OnFilterScriptInit()\r\n");
    fwrite(f, "{ \r\n");
    fwrite(f,"    new tmpobjid;\r\n\n");

	foreach(new i : Cars)
	{
		format(templine, sizeof(templine), "    carvid_%i = CreateVehicle(%i,%.3f,%.3f,%.3f,%.3f,%i,%i,-1);\r\n",
	        CurrCar++, CarData[i][CarModel], CarData[i][CarSpawnX], CarData[i][CarSpawnY], CarData[i][CarSpawnZ], CarData[i][CarSpawnFA], CarData[i][CarColor1], CarData[i][CarColor2]
		);
        fwrite(f, templine);
	}

	CurrCar = 0;

    fwrite(f, "\n");

	foreach(new i : Cars)
	{
		// Mod components
		for(new j = 0; j < MAX_CAR_COMPONENTS; j++)
		{
		    if(CarData[i][CarComponents][j] > 0)
		    {
		        format(templine, sizeof(templine), "    AddVehicleComponent(carvid_%i, %i);\r\n", CurrCar, CarData[i][CarComponents][j]);
				fwrite(f, templine);
		    }
		}
		CurrCar++;
	}

    CurrCar = 0;

    fwrite(f, "\n");

	foreach(new i : Cars)
	{
		// Paintjob
		if(CarData[i][CarPaintJob] < 3)
		{
	        format(templine, sizeof(templine), "    ChangeVehiclePaintjob(carvid_%i, %i);\r\n", CurrCar, CarData[i][CarPaintJob]);
			fwrite(f, templine);
		}
		CurrCar++;
	}

    CurrCar = 0;

    fwrite(f, "\n");

	foreach(new i : Cars)
	{
		// Objects
	    for(new j = 0; j < MAX_CAR_OBJECTS; j++)
	    {
			// No object
	        if(CarData[i][CarObjectRef][j] == -1) continue;
	        new oindex = CarData[i][CarObjectRef][j];

			// Create object
			format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);\r\n",ObjectData[oindex][oModel]);
	        fwrite(f,templine);


			// Write all materials and colors
			for(new k = 0; k < MAX_MATERIALS; k++)
	    	{
				// Does object have a texture set?
	            if(ObjectData[oindex][oTexIndex][k] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, %i);\r\n",
						k, GetTModel(ObjectData[oindex][oTexIndex][k]), 34, GetTXDName(ObjectData[oindex][oTexIndex][k]), 34, 34,GetTextureName(ObjectData[oindex][oTexIndex][k]), 34, ObjectData[oindex][oColorIndex][k]
					);

					fwrite(f,templine);
	            }

	            // No texture how about a color?
	            else if(ObjectData[oindex][oColorIndex][k] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, %i);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[oindex][oColorIndex][k]);
					fwrite(f,templine);
				}
			}

			// Write any text
			if(ObjectData[oindex][ousetext])
			{
				format(templine,sizeof(templine),"    SetDynamicObjectMaterialText(tmpobjid, 0, %c%s%c, %i, %c%s%c, %i, %i, %i, %i, %i);\r\n",
					34, ObjectData[oindex][oObjectText], 34,
					FontSizes[ObjectData[oindex][oFontSize]],
					34, FontNames[ObjectData[oindex][oFontFace]], 34,
					ObjectData[oindex][oTextFontSize],
					ObjectData[oindex][oFontBold],
					ObjectData[oindex][oFontColor],
					ObjectData[oindex][oBackColor],
					ObjectData[oindex][oAlignment]
				);
				fwrite(f,templine);
			}

			// Attach object to vehicle
			format(templine, sizeof(templine), "    AttachDynamicObjectToVehicle(tmpobjid, carvid_%i, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f);\r\n",
				CurrCar, CarData[i][COX], CarData[i][COY][j], CarData[i][COZ][j], CarData[i][CORX][j], CarData[i][CORY][j], CarData[i][CORZ][j]
			);

			fwrite(f,templine);
		}
		CurrCar++;

		fwrite(f, "\n");
	}

	// Write Objects

	// Write all objects with materials first
	foreach(new i : Objects)
	{
	    if(ObjectData[i][oAttachedVehicle] > -1) continue;

		new bool:writeobject;

		// Does the object have materials?
        for(new j = 0; j < MAX_MATERIALS; j++)
        {
            if(ObjectData[i][oTexIndex][j] != 0 || ObjectData[i][oColorIndex][j] != 0 || ObjectData[i][ousetext])
            {
				writeobject = true;
				break;
			}
		}

		// Object had materials we will write them to the export file
		if(writeobject)
		{
			mobjects++;

			format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,-1,-1,-1,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist,drawdist);
	        fwrite(f,templine);

			// Write all materials and colors
  			for(new j = 0; j < MAX_MATERIALS; j++)
        	{
				// Does object have a texture set?
	            if(ObjectData[i][oTexIndex][j] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, %i);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
					fwrite(f,templine);
	            }
	            // No texture how about a color?
	            else if(ObjectData[i][oColorIndex][j] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, %i);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
					fwrite(f,templine);
				}
			}

			// Write any text
			if(ObjectData[i][ousetext])
			{
				format(templine,sizeof(templine),"    SetDynamicObjectMaterialText(tmpobjid, 0, %c%s%c, %i, %c%s%c, %i, %i, %i, %i, %i);\r\n",
					34, ObjectData[i][oObjectText], 34,
					FontSizes[ObjectData[i][oFontSize]],
					34, FontNames[ObjectData[i][oFontFace]], 34,
					ObjectData[i][oTextFontSize],
					ObjectData[i][oFontBold],
					ObjectData[i][oFontColor],
					ObjectData[i][oBackColor],
					ObjectData[i][oAlignment]
				);
				fwrite(f,templine);
			}
		}
	}

	// We need to write all of the objects that didn't have materials set now
	foreach(new i : Objects)
	{
	    if(ObjectData[i][oAttachedVehicle] > -1) continue;

		new bool:writeobject = true;

		// Does the object have materials?
        for(new j = 0; j < MAX_MATERIALS; j++)
        {
			// This object has already been written
            if(ObjectData[i][oTexIndex][j] != 0 || ObjectData[i][oColorIndex][j] != 0 || ObjectData[i][ousetext])
            {
				writeobject = false;
				break;
			}
		}

		// Object has not been exported yet export
		if(writeobject)
		{
			format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,-1,-1,-1,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist,drawdist);
	        fwrite(f,templine);
		}
	}
	
	fwrite(f, "\r\n");

	fwrite(f, "    for(new i = 0; i < MAX_PLAYERS; i++)\r\n");
    fwrite(f, "    { \r\n");
    fwrite(f, "        if(!IsPlayerConnected(i)) continue; \r\n");
    fwrite(f, "        OnPlayerConnect(i); \r\n");
	fwrite(f, "    } \r\n\n");
	fwrite(f, "    return 1; \r\n\n");
    fwrite(f, "} \r\n\n");

	CurrCar = 0;

	// Exit script
    fwrite(f, "public OnFilterScriptExit()\r\n");
    fwrite(f, "{ \r\n");

	foreach(new i : Cars)
	{
		format(templine, sizeof(templine), "    DestroyVehicle(carvid_%i);\r\n", CurrCar);
    	fwrite(f, templine);
        CurrCar++;
	}

    fwrite(f, "} \r\n\n");

	// Remove building script
    fwrite(f, "public OnPlayerConnect(playerid)\r\n");
    fwrite(f, "{ \r\n");

	for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
	{
	    if(RemoveData[i][rModel] != 0)
	    {
			format(templine, sizeof(templine), "	RemoveBuildingForPlayer(playerid, %i, %.3f, %.3f, %.3f, %.3f);\r\n", RemoveData[i][rModel], RemoveData[i][rX], RemoveData[i][rY], RemoveData[i][rZ], RemoveData[i][rRange]);
            fwrite(f,templine);
		}
	}

    fwrite(f, "} \r\n\n");

    CurrCar = 0;

	// Vehicle respawn
    fwrite(f, "public OnVehicleSpawn(vehicleid)\r\n");

    fwrite(f, "{ \r\n");
    foreach(new i : Cars)
    {
		if(CurrCar == 0) format(templine, sizeof(templine), "    if(vehicleid == carvid_%i)\r\n", CurrCar);
		else format(templine, sizeof(templine), "    else if(vehicleid == carvid_%i)\r\n", CurrCar);
        fwrite(f, templine);

		fwrite(f, "    {\r\n");

		// Mod components
		for(new j = 0; j < MAX_CAR_COMPONENTS; j++)
		{
		    if(CarData[i][CarComponents][j] > 0)
		    {
		        format(templine, sizeof(templine), "        AddVehicleComponent(carvid_%i, %i);\r\n", CurrCar, CarData[i][CarComponents][i]);
				fwrite(f, templine);
		    }
		}

		// Paintjob
		if(CarData[i][CarPaintJob] < 3)
		{
	        format(templine, sizeof(templine), "        ChangeVehiclePaintjob(carvid_%i, %i);\r\n", CurrCar, CarData[i][CarPaintJob]);
			fwrite(f, templine);
		}

	    fwrite(f, "    }\r\n");

        CurrCar++;
	}

    fwrite(f, "} \r\n");

    fclose(f);

	format(templine, sizeof(templine), "Exported vehicles to filterscript %s", name);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, templine);

	return 1;
}

// Selects a object for editing
CMD:sel(playerid, arg[]) // In GUI
{
	NoEditingMode(playerid);
	
    MapOpenCheck();
	
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /sel <index> selects a object to edit");
	new index = strval(arg);
	if(index < 0) return SendClientMessage(playerid, STEALTH_YELLOW, "The index can not be negative numbers");

	if(Iter_Contains(Objects, index))
	{
		new line[128];
		format(line, sizeof(line), "You have selected object index %i for editing", index);
		SendClientMessage(playerid, STEALTH_GREEN, line);
		
		SetCurrObject(playerid, index);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "That object does not exist!");
	}

	return 1;
}

CMD:dsel(playerid, arg[]) // In GUI
{
    MapOpenCheck();
	EditCheck(playerid);
	NoEditingMode(playerid);
	
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Selection has been deselected");

    SetCurrObject(playerid, -1);

	return 1;
}

// Selects the closest object to player
CMD:scsel(playerid, arg[]) // In GUI
{
	NoEditingMode(playerid);
    MapOpenCheck();
    
	new Float:dist = 9999999.0, Float:tmpdist, index = -1;

	foreach(new i : Objects)
	{
		tmpdist = GetPlayerDistanceFromPoint(playerid, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
		if(tmpdist < dist)
		{
		    dist = tmpdist;
		    index = i;
		}
	}

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(index > -1)
	{
		SetCurrObject(playerid, index);
		new line[128];
		format(line, sizeof(line), "You have selected object index %i for editing", index);
		SendClientMessage(playerid, STEALTH_GREEN, line);

	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "There are no objects");
	
	return 1;
}

// Deletes the closest object to player
CMD:dcsel(playerid, arg[]) // In GUI
{
	NoEditingMode(playerid);
    MapOpenCheck();

	new Float:dist = 9999999.0, Float:tmpdist, index = -1;

	foreach(new i : Objects)
	{
		tmpdist = GetPlayerDistanceFromPoint(playerid, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
		if(tmpdist < dist)
		{
		    dist = tmpdist;
		    index = i;
		}
	}

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(index > -1)
	{
		DeleteDynamicObject(index);

		foreach(new i : Player)
		{
			if(i == playerid) continue;
			if(CurrObject[index] == CurrObject[i]) SetCurrObject(i, -1);
		}
        SetCurrObject(playerid, -1);

		new line[128];
		format(line, sizeof(line), "You have deleted object index %i", index);
		SendClientMessage(playerid, STEALTH_GREEN, line);

	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "There are no objects");

	return 1;
}


CMD:csel(playerid, arg[]) // In GUI
{
    NoEditingMode(playerid);

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(Iter_Count(Objects))
	{
		SetEditMode(playerid, EDIT_MODE_SELECTION);
		SelectObject(playerid);
		SendClientMessage(playerid, STEALTH_GREEN, "Entered Object Selection Mode");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "There are no objects right now");
	
	return 1;
}


// Set a material of an object
CMD:mtset(playerid, arg[]) // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);
	
	if(GetEditMode(playerid) != EDIT_MODE_TEXTURING) NoEditingMode(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];
	new mindex;
	new tref;

	if(GetMaterials(playerid, arg, mindex, tref))
	{
		SetMaterials(index, mindex, tref);

		UpdateObjectText(index);

        UpdateTextureSlot(playerid, mindex);
        
       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
        
		// Update the streamer
		foreach(new i : Player)
		{
		    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
		}

		SendClientMessage(playerid, STEALTH_GREEN, "Changed Material");
	}
	return 1;
}

// Set all materials of a certain type
CMD:mtsetall(playerid, arg[]) // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];
	new mindex;
	new tref;

	if(GetMaterials(playerid, arg, mindex, tref))
	{
		foreach(new i : Objects)
		{
			if(ObjectData[i][oModel] == ObjectData[CurrObject[playerid]][oModel])
			{
				SetMaterials(i, mindex, tref);
				UpdateObjectText(i);
				
	        	if(ObjectData[i][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[i][oAttachedVehicle], i, VEHICLE_REATTACH_UPDATE);
			}
		}
		
        SendClientMessage(playerid, STEALTH_GREEN, "Changed All Materials");

		foreach(new i : Player)
		{
  			if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
		}
		UpdateTextureSlot(playerid, mindex);
	}
	return 1;
}

CMD:ogroup(playerid, arg[]) // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);
	
    new index = CurrObject[playerid];

    ObjectData[index][oGroup] = strval(arg);
    
    sqlite_ObjGroup(index);
    
    UpdateObject3DText(index);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	new line[128];
    format(line, sizeof(line), "You have changed the group ID of this object to: %i", ObjectData[index][oGroup]);
    SendClientMessage(playerid, STEALTH_GREEN, line);

	return 1;
}



stock ColumnExists(DB:database, table[], columnname[])
{
	new q[128];
	format(q, sizeof(q), "pragma table_info(%s)", table);

	new DBResult:r = db_query(database, q);
	new Field[64];
	if(db_num_rows(r))
	{
	    for(new i = 0; i < db_num_rows(r); i++)
	    {
	        db_get_field_assoc(r, "name", Field, 64);
	        if(!strcmp(Field, columnname))
	        {
	            db_free_result(r);
	            return 1;
	        }
			db_next_row(r);
	    }
	}
    db_free_result(r);
	return 0;
}


CMD:clone(playerid, arg[])  // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	SetCurrObject(playerid, CloneObject(CurrObject[playerid]));

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Cloned your selected object the new object is now your selection");

	return 1;
}

CMD:copy(playerid, arg[]) // in GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

    CopyCopyBuffer(playerid, CurrObject[playerid]);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Copied object textures/color/text to buffer");


    return 1;

}

stock CopyCopyBuffer(playerid, index)
{
    for(new i = 0; i < MAX_MATERIALS; i++)
    {
		CopyBuffer[playerid][cTexIndex][i] = ObjectData[index][oTexIndex][i];
		CopyBuffer[playerid][cColorIndex][i] = ObjectData[index][oColorIndex][i];
		CopyBuffer[playerid][cusetext] = ObjectData[index][ousetext];
		CopyBuffer[playerid][cFontFace] = ObjectData[index][oFontFace];
		CopyBuffer[playerid][cFontSize] = ObjectData[index][oFontSize];
		CopyBuffer[playerid][cFontBold] = ObjectData[index][oFontBold];
		CopyBuffer[playerid][cFontColor] = ObjectData[index][oFontColor];
		CopyBuffer[playerid][cBackColor] = ObjectData[index][oBackColor];
		CopyBuffer[playerid][cAlignment] = ObjectData[index][oAlignment];
		CopyBuffer[playerid][cTextFontSize] = ObjectData[index][oTextFontSize];
		CopyBuffer[playerid][cObjectText] = ObjectData[index][oObjectText];
    }
    return 1;
}

CMD:clear(playerid, arg[]) // in GUI
{
    ClearCopyBuffer(playerid);
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Cleared your copy buffer");
	return 1;
}

CMD:paste(playerid, arg[]) // in GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	PasteCopyBuffer(playerid, CurrObject[playerid]);
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Pasted your copy buffer to object");

	return 1;
}

stock PasteCopyBuffer(playerid, index)
{
    for(new i = 0; i < MAX_MATERIALS; i++)
    {
		ObjectData[index][oTexIndex][i] = CopyBuffer[playerid][cTexIndex][i];
		ObjectData[index][oColorIndex][i] = CopyBuffer[playerid][cColorIndex][i];
    }
    
	ObjectData[index][ousetext] = CopyBuffer[playerid][cusetext];
	ObjectData[index][oFontFace] = CopyBuffer[playerid][cFontFace];
	ObjectData[index][oFontSize] = CopyBuffer[playerid][cFontSize];
	ObjectData[index][oFontBold] = CopyBuffer[playerid][cFontBold];
	ObjectData[index][oFontColor] = CopyBuffer[playerid][cFontColor];
	ObjectData[index][oBackColor] = CopyBuffer[playerid][cBackColor];
	ObjectData[index][oAlignment] = CopyBuffer[playerid][cAlignment];
	ObjectData[index][oTextFontSize] = CopyBuffer[playerid][cTextFontSize];
	ObjectData[index][oObjectText] = CopyBuffer[playerid][cObjectText];
    
    // Destroy the object
    DestroyDynamicObject(ObjectData[index][oID]);

	// Re-create object
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], -1, -1, -1, 300.0);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

	// Update the streamer
	foreach(new i : Player)
	{
	    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
	}

	// Update the materials
	UpdateMaterial(index);
	
	// Update object text
	UpdateObjectText(index);

   	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);

	// Save materials to material database
	sqlite_SaveMaterialIndex(index);

	// Save colors to material database
	sqlite_SaveColorIndex(index);
	
	// Save all text
	sqlite_SaveAllObjectText(index);

	return 1;
}

stock ClearCopyBuffer(playerid)
{
    for(new i = 0; i < MAX_MATERIALS; i++)
    {
		CopyBuffer[playerid][cTexIndex][i] = 0;
		CopyBuffer[playerid][cColorIndex][i] = 0;
		CopyBuffer[playerid][cusetext] = 0;
		CopyBuffer[playerid][cFontFace] = 0;
		CopyBuffer[playerid][cFontSize] = 0;
		CopyBuffer[playerid][cFontBold] = 0;
		CopyBuffer[playerid][cFontColor] = 0;
		CopyBuffer[playerid][cBackColor] = 0;
		CopyBuffer[playerid][cAlignment] = 0;
		CopyBuffer[playerid][cTextFontSize] = 20;
		format(CopyBuffer[playerid][cObjectText], MAX_TEXT_LENGTH, "None");
    }
	return 1;
}

// Gets the mindex and tref from command arguments
stock GetMaterials(playerid, arg[], &mindex, &tref)
{
	if(sscanf(arg, "ii", mindex, tref))
	{
		SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /mtset <material index> <texture array reference>");
		return 0;
	}

	if(mindex < 0 || mindex > MAX_MATERIALS - 1)
	{
	    new line[128];
		format(line, sizeof(line), "The material selection must be between <0 - %i>", MAX_MATERIALS - 1);
		SendClientMessage(playerid, STEALTH_YELLOW, line);
		return 0;
	}

	if(tref < 0 || tref > MAX_TEXTURES - 1)
	{
		new line[128];
		format(line, sizeof(line), "The texture reference must be between <0 - %i>", MAX_TEXTURES - 1);
		SendClientMessage(playerid, STEALTH_YELLOW, line);
		return 0;
	}
	return 1;
}

// Set the materials for an object
SetMaterials(index, mindex, tref)
{
	// Set the texture
	ObjectData[index][oTexIndex][mindex] = tref;

	// Destroy the object
    DestroyDynamicObject(ObjectData[index][oID]);

	// Re-create object
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], -1, -1, -1, 300.0);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

	// Update streamer for all
	foreach(new i : Player) Streamer_UpdateEx(i, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ]);

	// Update the materials
	UpdateMaterial(index);

	// Save this material index to the data base
	sqlite_SaveMaterialIndex(index);
}


CMD:ogoto(playerid, arg[])   // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	if(!InFlyMode(playerid))
	{
	   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	   	SendClientMessage(playerid, STEALTH_YELLOW, "You must be in flymode to use this command");
	   	return 1;
	}

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
   	SendClientMessage(playerid, STEALTH_GREEN, "Moved to object currently being edited");
   	
	SetFlyModePos(playerid, ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);
	return 1;
}


// Set a color of an object
CMD:mtcolor(playerid, arg[]) // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

	if(GetEditMode(playerid) != EDIT_MODE_TEXTURING) NoEditingMode(playerid);

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];

	new mindex;
	new HexColor[12];
	
	sscanf(arg, "is[12]", mindex, HexColor);

	if(mindex < 0 || mindex > MAX_MATERIALS - 1)
	{
	    new line[128];
		format(line, sizeof(line), "The material selection must be between <0 - %i>", MAX_MATERIALS - 1);
		return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}
		
	if(IsHexValue(HexColor))
	{
		// Set the color
        sscanf(HexColor, "h", ObjectData[index][oColorIndex][mindex]);

		// Destroy the object
	    DestroyDynamicObject(ObjectData[index][oID]);

		// Re-create object
		ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], -1, -1, -1, 300.0);
		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

		// Update the materials
		UpdateMaterial(index);

		UpdateObjectText(index);

       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);

		// Save this material index to the data base
		sqlite_SaveColorIndex(index);
		
		// Update texture tool
        UpdateTextureSlot(playerid, mindex);

		// Update the streamer
		foreach(new i : Player)
		{
		    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
		}

		SendClientMessage(playerid, STEALTH_GREEN, "Changed Color");

	}
	else
	{
	    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	    SendClientMessage(playerid, STEALTH_YELLOW, "Invalid hex color.");
	}

	return 1;
}

// Set a color of an object
CMD:mtcolorall(playerid, arg[]) // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];

	new mindex;
	new HexColor[12];

	sscanf(arg, "is[12]", mindex, HexColor);

	if(mindex < 0 || mindex > MAX_MATERIALS - 1)
	{
	    new line[128];
		format(line, sizeof(line), "The material selection must be between <0 - %i>", MAX_MATERIALS - 1);
		return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}

	if(IsHexValue(HexColor))
	{
		new hcolor;
		sscanf(HexColor, "h", hcolor);
		
		foreach(new i : Objects)
		{
		    if(ObjectData[i][oModel] == ObjectData[CurrObject[playerid]][oModel])
		    {
		        ObjectData[i][oColorIndex][mindex] = hcolor;
		    
				// Destroy the object
			    DestroyDynamicObject(ObjectData[i][oID]);

				// Re-create object
				ObjectData[i][oID] = CreateDynamicObject(ObjectData[i][oModel], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ], -1, -1, -1, 300.0);
				Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[i][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

				// Update the materials
				UpdateMaterial(i);
				
				UpdateObjectText(i);
				
	        	if(ObjectData[i][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[i][oAttachedVehicle], i, VEHICLE_REATTACH_UPDATE);

				// Save this material index to the data base
				sqlite_SaveColorIndex(i);
		    }
		
		}
		// Update the streamer
		foreach(new i : Player)
		{
		    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
		}

		SendClientMessage(playerid, STEALTH_GREEN, "Changed All Color");

	}
	else
	{
	    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	    SendClientMessage(playerid, STEALTH_YELLOW, "Invalid hex color.");
	}

	return 1;
}

// Enter edit mode
CMD:editobject(playerid, arg[]) // In GUI
{
    MapOpenCheck();

	EditCheck(playerid);

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
   	
   	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1) return EditVehicleObject(playerid);
   	
   	if(!EditingMode[playerid])
	{
		EditingMode[playerid] = true;
		SetEditMode(playerid, EDIT_MODE_OBJECT);
		EditDynamicObject(playerid, ObjectData[CurrObject[playerid]][oID]);
		SendClientMessage(playerid, STEALTH_GREEN, "Entered Edit Object Mode");
		CurrEditPos[playerid][0] = ObjectData[CurrObject[playerid]][oX];
		CurrEditPos[playerid][1] = ObjectData[CurrObject[playerid]][oY];
		CurrEditPos[playerid][2] = ObjectData[CurrObject[playerid]][oZ];
		CurrEditPos[playerid][3] = ObjectData[CurrObject[playerid]][oRX];
		CurrEditPos[playerid][4] = ObjectData[CurrObject[playerid]][oRY];
		CurrEditPos[playerid][5] = ObjectData[CurrObject[playerid]][oRZ];
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "You are in editing mode already");
	return 1;
}

// Create an object
CMD:cobject(playerid, arg[]) // In gui
{
    MapOpenCheck();
	NoEditingMode(playerid);

 	new modelid;
	if(sscanf(arg, "i", modelid))
	{
	    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
        SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /cobject <modelid>");
		return 1;
	}

	ModelIsValid(modelid);

	// Set the initial object position
	new Float:px, Float:py, Float:pz, Float:fa;

	// Find the size of the object
	new Float:colradius = GetColSphereRadius(modelid);

	// Place in front of the player using collision radius
	GetPosFaInFrontOfPlayer(playerid, colradius + 1.0, px, py, pz, fa);

	pz -= 1.0;

	// Create the object
	SetCurrObject(playerid, AddDynamicObject(modelid, px, py, pz, 0.0, 0.0, 0.0));
	
	// Create 3D label
	UpdateObject3DText(CurrObject[playerid], true);
	
	// Object was created
	if(CurrObject[playerid] != -1)
	{
		// Update the streamer for this player
        Streamer_Update(playerid);

		// Show output message
		new line[128];
		new modelarray = GetModelArray(modelid);
		if(modelarray > -1) format(line, sizeof(line), "Created Object Index: %i Model Name: %s", CurrObject[playerid], GetModelName(modelarray));
		else format(line, sizeof(line), "Created Object Index: %i Model Name: Unknown", CurrObject[playerid]); 
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, line);

	}
	// Too many objects already created
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "You have too many objects created to create anymore!");
	}

	return 1;
}

CMD:dobject(playerid, arg[])  // In gui
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);
    
	DeleteDynamicObject(CurrObject[playerid]);

	foreach(new i : Player)
	{
		if(CurrObject[playerid] == CurrObject[i]) SetCurrObject(i, -1);
	}
	
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Your object has been destroyed");

	return 1;
}

CMD:rotreset(playerid, arg[])  // In gui
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

    ObjectData[CurrObject[playerid]][oRX] = 0.0;
    ObjectData[CurrObject[playerid]][oRY] = 0.0;
    ObjectData[CurrObject[playerid]][oRZ] = 0.0;

    SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Your objects rotation has been reset");

	return 1;
}


// Resets an objects materials and text
CMD:robject(playerid, arg[]) // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);
    
    new index = CurrObject[playerid];
    
	for(new i = 0; i < MAX_MATERIALS; i++)
	{
        ObjectData[index][oTexIndex][i] = 0;
        ObjectData[index][oColorIndex][i] = 0;
	}

    ObjectData[index][ousetext] = 0;
    ObjectData[index][oFontFace] = 0;
    ObjectData[index][oFontSize] = 0;
    ObjectData[index][oFontBold] = 0;
    ObjectData[index][oFontColor] = 0;
    ObjectData[index][oBackColor] = 0;
    ObjectData[index][oAlignment] = 0;
    ObjectData[index][oTextFontSize] = 20;
    
    format(ObjectData[index][oObjectText], MAX_TEXT_LENGTH, "None");

	DestroyDynamicObject(ObjectData[index][oID]);

	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], -1, -1, -1, 300.0);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

	sqlite_SaveColorIndex(index);
	sqlite_SaveMaterialIndex(index);
	sqlite_ObjUseText(index);
	sqlite_ObjFontFace(index);
	sqlite_ObjFontSize(index);
	sqlite_ObjFontBold(index);
	sqlite_ObjFontColor(index);
	sqlite_ObjBackColor(index);
	sqlite_ObjAlignment(index);
	sqlite_ObjFontTextSize(index);
	sqlite_ObjObjectText(index);

	// Update the streamer
	foreach(new i : Player)
	{
	    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
	}
	
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Reset object materials and text");
	
	return 1;
}




// Loops through all indexes and labels them with object text
enum INDEXCOLORINFO { FaceColor, BackColor }
stock const ShowIndexColors[MAX_MATERIALS][INDEXCOLORINFO] = {
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 },
	{ 0xFFFFFF66, 0xFF00FF33 }
};

CMD:sindex(playerid, arg[]) // in gui
{
    MapOpenCheck();
    EditCheck(playerid);
//    NoEditingMode(playerid);
    
	new size;
    if(isnull(arg)) size = 20;
    else size = strval(arg);
    if(size < 0 || size > 200) size = 20;

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, "Labelling your objects with text corresponding to index (/rindex to turn off label)");

	new line[8];
	
	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		format(line, sizeof(line), "%i", i);
		SetDynamicObjectMaterialText(ObjectData[CurrObject[playerid]][oID],
			i,
			line,
			10,
			"Ariel",
			size,
			1,
			ShowIndexColors[i][FaceColor],
			ShowIndexColors[i][BackColor],
			1);
	}
	return 1;

}

// Restores an object to it's original form
CMD:rindex(playerid, arg[]) // in gui
{
    MapOpenCheck();
    EditCheck(playerid);
//    NoEditingMode(playerid);

	new index = CurrObject[playerid];

	// Destroy the object
    DestroyDynamicObject(ObjectData[index][oID]);

	// Re-create object
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], -1, -1, -1, 300.0);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

	// Update the streamer
	foreach(new i : Player)
	{
	    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
	}

	// Update the materials
	UpdateMaterial(index);

	// Update object text
	UpdateObjectText(index);

   	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, "Reset current objects labels");

	return 1;
}

// Set a pivot point
CMD:pivot(playerid, arg[]) // In GUI
{
    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:x, Float:y, Float:z, Float:fa;
	GetPosFaInFrontOfPlayer(playerid, 2.0, x, y, z, fa);

	PivotObject[playerid] = CreateDynamicObject(1974, x, y, z, 0.0, 0.0, 0.0, -1, -1, playerid);

	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, PivotObject[playerid], E_STREAMER_DRAW_DISTANCE, 300.0);

	SetDynamicObjectMaterial(PivotObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

	Streamer_Update(playerid);

	EditingMode[playerid] = true;
	SetEditMode(playerid, EDIT_MODE_PIVOT);

	EditDynamicObject(playerid, PivotObject[playerid]);
	
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, "Editing your pivot point");
	
	return 1;
}

CMD:togpivot(playerid, arg[])
{
    MapOpenCheck();
    
	if(PivotPointOn[playerid])
	{
	    PivotPointOn[playerid] = false;
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	    SendClientMessage(playerid, STEALTH_GREEN, "Pivot point turned off");
	}
	else
	{
	    PivotPointOn[playerid] = true;
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	    SendClientMessage(playerid, STEALTH_GREEN, "Pivot point turned on");
	}

	return 1;
}


// Move object on X axis
CMD:ox(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);
    
	new Float:dist;
	
	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

    ObjectData[CurrObject[playerid]][oX] += dist;
    
    SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);

	UpdateObject3DText(CurrObject[playerid]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on Y axis
CMD:oy(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

    ObjectData[CurrObject[playerid]][oY] += dist;

    SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);

	UpdateObject3DText(CurrObject[playerid]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on Z axis
CMD:oz(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);
    
	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

    ObjectData[CurrObject[playerid]][oZ] += dist;

    SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);

	UpdateObject3DText(CurrObject[playerid]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on RX rot
CMD:rx(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:rot;

	rot = floatstr(arg);
	if(rot == 0) rot = 5.0;
	
	if(PivotPointOn[playerid])
	{
		new i = CurrObject[playerid];
		AttachObjectToPoint(i, PivotPoint[playerid][xPos], PivotPoint[playerid][yPos], PivotPoint[playerid][zPos], rot, 0.0, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
		SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		UpdateObject3DText(CurrObject[playerid]);
	}
	else
	{
	    ObjectData[CurrObject[playerid]][oRX] += rot;
	    SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
	}

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on RX rot
CMD:ry(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:rot;

	rot = floatstr(arg);
	if(rot == 0) rot = 5.0;
	
	
	if(PivotPointOn[playerid])
	{
		new i = CurrObject[playerid];
		AttachObjectToPoint(i, PivotPoint[playerid][xPos], PivotPoint[playerid][yPos], PivotPoint[playerid][zPos], 0.0, rot, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
		SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		UpdateObject3DText(CurrObject[playerid]);
	}
	else
	{
	    ObjectData[CurrObject[playerid]][oRY] += rot;
	    SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
	}

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on RX rot
CMD:rz(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:rot;

	rot = floatstr(arg);
	if(rot == 0) rot = 5.0;

	if(PivotPointOn[playerid])
	{
		new i = CurrObject[playerid];
		AttachObjectToPoint(i, PivotPoint[playerid][xPos], PivotPoint[playerid][yPos], PivotPoint[playerid][zPos], 0.0, 0.0, rot, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
		SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		UpdateObject3DText(CurrObject[playerid]);
	}
	else
	{
	    ObjectData[CurrObject[playerid]][oRZ] += rot;
	    SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
	}
	
    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move all objects on X axis
CMD:dox(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	foreach(new i : Objects)
	{
	    ObjectData[i][oX] += dist;

	    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		UpdateObject3DText(i);

	    sqlite_UpdateObjectPos(i);
	}
	
	return 1;
}

// Move all objects on Y axis
CMD:doy(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	foreach(new i : Objects)
	{
	    ObjectData[i][oY] += dist;

	    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		UpdateObject3DText(i);

	    sqlite_UpdateObjectPos(i);
	}

	return 1;
}

// Move all objects on Z axis
CMD:doz(playerid, arg[])  // In GUI
{
    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	foreach(new i : Objects)
	{
	    ObjectData[i][oZ] += dist;

	    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		UpdateObject3DText(i);

	    sqlite_UpdateObjectPos(i);
	}

	return 1;
}

// Rotate map on RX
CMD:drx(playerid, arg[])  // In GUI
{
	MapOpenCheck();
	
	new Float:Delta;
	if(isnull(arg)) Delta = 1.0;
	else if(sscanf(arg, "f", Delta))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /drx <rotation> ");
		return 1;
	}

	// We need to get the map center as the rotation node
	new Float:mCenterX, Float:mCenterY, Float:mCenterZ;
    if(GetMapCenter(mCenterX, mCenterY, mCenterZ))
	{
		// Loop through all objects and perform rotation calculations
		foreach(new i : Objects)
		{
			AttachObjectToPoint(i, mCenterX, mCenterY, mCenterZ, Delta, 0.0, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
			SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			UpdateObject3DText(i);
			
			sqlite_UpdateObjectPos(i);
		}

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Map RX rotation complete ");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There is not enough objects for this command to work");
	}

	return 1;
}

// Rotate map on RY
CMD:dry(playerid, arg[])  // In GUI
{
	MapOpenCheck();
	new Float:Delta;
	if(isnull(arg)) Delta = 1.0;
	else if(sscanf(arg, "f", Delta))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /dry <rotation> ");
		return 1;
	}

	// We need to get the map center as the rotation node
	new Float:mCenterX, Float:mCenterY, Float:mCenterZ;
    if(GetMapCenter(mCenterX, mCenterY, mCenterZ))
	{
		// Loop through all objects and perform rotation calculations
		foreach(new i : Objects)
		{
			AttachObjectToPoint(i, mCenterX, mCenterY, mCenterZ, 0.0, Delta, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
			SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			UpdateObject3DText(i);

			sqlite_UpdateObjectPos(i);
		}

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Map RY rotation complete ");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There is not enough objects for this command to work");
	}

	return 1;
}

// Rotate map on RZ
CMD:drz(playerid, arg[])  // In GUI
{
	MapOpenCheck();
	new Float:Delta;
	if(isnull(arg)) Delta = 1.0;
	else if(sscanf(arg, "f", Delta))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /drz <rotation> ");
		return 1;
	}

	// We need to get the map center as the rotation node
	new Float:mCenterX, Float:mCenterY, Float:mCenterZ;
    if(GetMapCenter(mCenterX, mCenterY, mCenterZ))
	{
		// Loop through all objects and perform rotation calculations
		foreach(new i : Objects)
		{
			AttachObjectToPoint(i, mCenterX, mCenterY, mCenterZ, 0.0, 0.0, Delta, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
			SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			UpdateObject3DText(i);

			sqlite_UpdateObjectPos(i);
		}

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Map RZ rotation complete ");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There is not enough objects for this command to work");
	}

	return 1;
}

// Extras
CMD:hidetext3d(playerid, arg[])
{
	HideGroupLabels(playerid);
	HideObjectText();
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "All 3D Text labels hidden");
	return 1;
}

CMD:showtext3d(playerid, arg[])
{
    ShowGroupLabels(playerid);
	ShowObjectText();
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "All 3D Text labels shown");
	return 1;
}

HideObjectText()
{
	foreach(new i : Objects)
	{
	    UpdateDynamic3DTextLabelText(ObjectData[i][oTextID], 0, "");
	}
	return 1;
}

ShowObjectText()
{
	foreach(new i : Objects)
	{
	    UpdateObject3DText(i, false);
	}
	return 1;
}

// Command list
CMD:thelp(playerid, arg[])
{
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Commands");
	SendClientMessage(playerid, STEALTH_GREEN, "Maps: /loadmap - /newmap - /importmap - /exportmap");
	SendClientMessage(playerid, STEALTH_GREEN, "Objects: /cobject - /dobject - /robject - /osearch");
	SendClientMessage(playerid, STEALTH_GREEN, "Objects: /sel - /csel - /lsel - /flymode - /ogoto");
	SendClientMessage(playerid, STEALTH_GREEN, "Objects/Pivot: /pivot - /togpivot");
	SendClientMessage(playerid, STEALTH_GREEN, "Removebuildings: /gtaobjects - /gtashow - /gtahide - /remobject - /swapbuilding");
	SendClientMessage(playerid, STEALTH_GREEN, "Vehicles: /avmodcar - /avsetspawn - /avnewcar - /avdeletecar - /avcarcolor");
	SendClientMessage(playerid, STEALTH_GREEN, "Vehicles: /avpaint - /avattach - /avmirror - /avdetach - /avsel");
	SendClientMessage(playerid, STEALTH_GREEN, "Vehicles: /editobject - /avox - /avoy - /avoz - /avrx - /avry - avrz");
	SendClientMessage(playerid, STEALTH_GREEN, "Vehicles: /avexport - /avexportall");
	SendClientMessage(playerid, STEALTH_GREEN, "Movement: /editobject - /ox - /oy - /oz - /rx - ry - /rz");
	SendClientMessage(playerid, STEALTH_GREEN, "Movement: /dox - /doy - /doz - /drx - /dry - /drz");
	SendClientMessage(playerid, STEALTH_GREEN, "Textures: /mtextures - /ttextures - /stexture - /mtset - /mtcolor - /mtsetall");
	SendClientMessage(playerid, STEALTH_GREEN, "Textures/Text: /setindex - /mtcolorall - /copy - /paste - /clear - /text");
	SendClientMessage(playerid, STEALTH_GREEN, "Textures/Indexes: /sindex - /rindex");
	SendClientMessage(playerid, STEALTH_GREEN, "Textures/Theme: /loadtheme - /savetheme - /deletetheme");
	SendClientMessage(playerid, STEALTH_GREEN, "Groups: /setgroup - /selectgroup - /gsel - /gadd - grem - /gclear /gclone /gdelete");
    SendClientMessage(playerid, STEALTH_GREEN, "Groups: /editgroup - /gox - /goy - /goz - /grx - /gry - /grz");
	SendClientMessage(playerid, STEALTH_GREEN, "Group/Prefab: /gaexport(N/A) - /gprefab - /prefabsetz - /prefab");
	SendClientMessage(playerid, STEALTH_GREEN, "Bind Editor: /bindeditor - /runbind");
	SendClientMessage(playerid, STEALTH_GREEN, "Other: /echo");
	return 1;
}
////////////////////////////////////////////////////////////////////////////////
/// Commands  End///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
