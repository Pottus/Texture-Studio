#include "tstudio\menudata.pwn"

static PlayerGUIMenu:PlayerMainMenu[MAX_PLAYERS];
static PlayerGUIMenu:PlayerObjectMenu[MAX_PLAYERS];
static PlayerGUIMenu:PlayerGroupMenu[MAX_PLAYERS];
static PlayerGUIMenu:PlayerSubMenu[MAX_PLAYERS];


// Main menu
static GUIMenu:MainMenu;

// Object / Group Menu
static GUIMenu:ObjectMenu;
static GUIMenu:GroupMenu;

// Object sub menus
static GUIMenu:SelectionSubMenu;
static GUIMenu:ObjectSubMenu;
static GUIMenu:TextureSubMenu;

// Group sub menus
static GUIMenu:GroupSelSubMenu;
static GUIMenu:GroupPrefabMenu;


// Save all bind elements for custom binding
static BindElementIDS[8];

// Indexes for object movement text
static ObjectMovementIndex[15];
static ObjectGroupMovementIndex[15];
static CurrObjectPosition[MAX_PLAYERS][9];
static CurrGroupPosition[MAX_PLAYERS][9];


// Movement Increments
static Float:CurrMovementInc[MAX_PLAYERS];
static Float:CurrRotationInc[MAX_PLAYERS];
static Float:CurrMovementGInc[MAX_PLAYERS];
static Float:CurrRotationGInc[MAX_PLAYERS];

// Turn delta map movements on/off
static bool:DeltaMapMovement[MAX_PLAYERS];

#define         EXIT_GUI_MENU 		1

////////////////////////////////////////////////////////////////////////////////
// Main menu defines ///////////////////////////////////////////////////////////
/*
								   (0000)
 						(0           0           00)
                    Base Group - Sub Group - Elements
*/
////////////////////////////////////////////////////////////////////////////////
// Map commands
#define         CLICK_NEW_MAP       	1101
#define         CLICK_LOAD_MAP          1102
#define         CLICK_IMPORT_MAP        1103
#define         CLICK_EXPORT_MAP        1104

////////////////////////////////////////////////////////////////////////////////

// Modes
#define         CLICK_OBJECT_MODE    	2100
#define         CLICK_GROUP_MODE        2200
#define         CLICK_FLY_MODE          2300

// Object Mode 2100 ////////////////////////////////////////////////////////////


// Submenu Selection

// Object sub
#define         CLICK_OBJECTEDIT_MENU   	2101
#define			CLICK_OBJECTEDIT_COBJECT    2102
#define			CLICK_OBJECTEDIT_DOBJECT    2103
#define			CLICK_OBJECTEDIT_CLONE      2104
#define			CLICK_OBJECTEDIT_GOTO       2105
#define         CLICK_OBJECTEDIT_EDIT       2106
#define         CLICK_OBJECTEDIT_OGROUP     2107
#define			CLICK_OBJECTEDIT_RROT       2109

// Selection sub
#define			CLICK_SELECTION_MENU    	2111
#define         CLICK_SELECT_OBJECT     	2112
#define         CLICK_DESELECT_OBJECT   	2113
#define         CLICK_SELECT_CLOSEST    	2114
#define         CLICK_SELECT_CLICK      	2115
#define         CLICK_SELECT_LIST	      	2116
#define         CLICK_SELECT_OPROP          2117
#define         CLICK_SELECT_DCLOSEST   	2118


// Texture sub
#define         CLICK_TEXTURE_MENU		 	2121
#define			CLICK_TEXTURE_TEXEDIT       2122
#define         CLICK_TEXTURE_TEXTEDIT      2123
#define         CLICK_TEXTURE_SHOWINDEX     2124
#define         CLICK_TEXTURE_HIDEINDEX     2125
#define         CLICK_TEXTURE_COPY          2126
#define         CLICK_TEXTURE_PASTE         2127
#define         CLICK_TEXTURE_CLEAR		    2128
#define         CLICK_TEXTURE_VIEWER        2129
#define         CLICK_TEXTURE_THEMEV        2130
#define         CLICK_TEXTURE_THEMET        2131
#define         CLICK_TEXTURE_SEARCH        2132

// Search for object
#define			CLICK_SEARCH_MENU           2141
#define         CLICK_PIVOT_MENU            2142
#define         CLICK_TOGPIVOT_MENU         2143

// Movement Menu
#define			CLICK_MOVEMENT_MENU     	2150


////////////////////////////////////////////////////////////////////////////////

// Group Mode 2200
#define			CLICK_GROUPSEL_MENU         2201
#define			CLICK_GROUPPF_MENU          2202
#define         CLICK_MOVEMENTG_MENU        2203

#define         CLICK_PIVOTG_MENU           2142
#define         CLICK_TOGPIVOTG_MENU        2143
#define			CLICK_ZEROGROUP_MENU        2144
#define         CLICK_OBJECTMETRY_MENU      2145

// Group selection sub
#define         CLICK_GROUP_CSEL            2211
#define         CLICK_GROUP_GADD            2212
#define         CLICK_GROUP_GREM            2213
#define         CLICK_GROUP_CLEAR           2214
#define         CLICK_GROUP_CLONE           2215
#define         CLICK_GROUP_GALL            2216
#define         CLICK_GROUP_SETGROUP        2217
#define         CLICK_GROUP_SELECTGROUP     2218
#define         CLICK_GROUP_GDELETE         2219
#define         CLICK_GROUP_EDIT            2220
#define         CLICK_GROUP_INFRONT         2221

// Group prefab selection
#define			CLICK_GROUP_GPREFAB         2231
#define			CLICK_GROUP_LOADPF          2232
#define         CLICK_GROUP_LOADZPF         2233

// User binds
#define         CLICK_BIND_1            	9101
#define         CLICK_BIND_2            	9102
#define         CLICK_BIND_3            	9103
#define         CLICK_BIND_4            	9104
#define         CLICK_BIND_5            	9105
#define         CLICK_BIND_6            	9106
#define         CLICK_BIND_7            	9107
#define         CLICK_BIND_8            	9108


////////////////////////////////////////////////////////////////////////////////

// Initialize all GUIMenus
public OnFilterScriptInit()
{
// Static menu draws ///////////////////////////////////////////////////////
	MainMenu = CreateGUI("MainMenu");

	// Object Menu / group menu
	ObjectMenu = CreateGUI("ObjectMenu");
	GroupMenu = CreateGUI("GroupMenu");
	
	// Object sub menu
	ObjectSubMenu = CreateGUI("SubObjectEdit");
	SelectionSubMenu = CreateGUI("SubMenuSel");
	TextureSubMenu = CreateGUI("SubMenuTex");

	// Group sub Menu
	GroupSelSubMenu = CreateGUI("SubMenuGroupSel");
	GroupPrefabMenu = CreateGUI("SubMenuGroupPF");
	
/////////////////////////////////////////////////////////////////////////////

// Load main menu //////////////////////////////////////////////////////////////
	LoadGUIMenu(MainMenu,MainMenuText,0.0, 0.0, CLICK_NO_GROUP, E_INDEX);

	LoadGUIMenu(MainMenu,MenuButton,535.0, 135.0, CLICK_NEW_MAP, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "New Map");
	GUISetPlayerText(MainMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(MainMenu,MenuButton,535.0, 150.0, CLICK_LOAD_MAP, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "Load Map");
	GUISetPlayerText(MainMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(MainMenu,MenuButton,535.0, 165.0, CLICK_IMPORT_MAP, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "Import Map");
	GUISetPlayerText(MainMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(MainMenu,MenuButton,535.0, 180.0, CLICK_EXPORT_MAP, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "Export");
	GUISetPlayerText(MainMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIElement(MainMenu,MainMenuText[2],0.0,-200.0);
	
	LoadGUIMenu(MainMenu,MenuButton,535.0, 210.0, CLICK_OBJECT_MODE, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "Object Mode");
	
	LoadGUIMenu(MainMenu,MenuButton,535.0, 225.0, CLICK_GROUP_MODE, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "Group Mode");

	LoadGUIMenu(MainMenu,MenuButton,535.0, 240.0, CLICK_FLY_MODE, E_INDEX);
	GUISetPlayerText(MainMenu, E_INDEX[1], "Fly Mode");
	GUISetPlayerText(MainMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIElement(MainMenu,MainMenuText[2],0.0,-140.0);

	new Float:inc = 0.0;
	new line[128];

	for(new i = 0; i < sizeof(BindElementIDS); i++)
	{
		format(line, sizeof(line), "User Bind %i", i);
		LoadGUIMenu(MainMenu,MenuButton,535.0, 270.0+inc, CLICK_BIND_1+i, E_INDEX);
		GUISetPlayerText(MainMenu, E_INDEX[1], line);
        GUISetPlayerText(MainMenu, E_INDEX[2], "LD_BEAT:square");
        
		BindElementIDS[i] = E_INDEX[1];
		inc+=15.0;
	}
	
// Load object menu/////////////////////////////////////////////////////////

	LoadGUIMenu(ObjectMenu,MainMenuText,-100.0, 0.0, CLICK_NO_GROUP, E_INDEX);
	
	LoadGUIMenu(ObjectMenu,MenuButton,435.0, 135.0, CLICK_OBJECTEDIT_MENU, E_INDEX);
	GUISetPlayerText(ObjectMenu, E_INDEX[1], "Object Editor");

	LoadGUIMenu(ObjectMenu,MenuButton,435.0, 150.0, CLICK_SELECTION_MENU, E_INDEX);
	GUISetPlayerText(ObjectMenu, E_INDEX[1], "Selection");

	LoadGUIMenu(ObjectMenu,MenuButton,435.0, 165.0, CLICK_TEXTURE_MENU, E_INDEX);
	GUISetPlayerText(ObjectMenu, E_INDEX[1], "Textures");

	LoadGUIMenu(ObjectMenu,MenuButton,435.0, 180.0, CLICK_SEARCH_MENU, E_INDEX);
	GUISetPlayerText(ObjectMenu, E_INDEX[1], "Object Search");
	GUISetPlayerText(ObjectMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectMenu,MenuButton,435.0, 195.0, CLICK_PIVOT_MENU, E_INDEX);
	GUISetPlayerText(ObjectMenu, E_INDEX[1], "Set Pivot");
	GUISetPlayerText(ObjectMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectMenu,MenuButton,435.0, 210.0, CLICK_TOGPIVOT_MENU, E_INDEX);
	GUISetPlayerText(ObjectMenu, E_INDEX[1], "Toggle Pivot");
	GUISetPlayerText(ObjectMenu, E_INDEX[2], "LD_BEAT:square");


 	// +x:0 +y:1 +z:2 +rx:3 +ry:4 +rz:5 -x:6 -y:7 -z:8 -rx:9 -ry:10 -rz:11
	LoadGUIMenu(ObjectMenu,MovementMenu,-100.0, 0.0, CLICK_MOVEMENT_MENU, E_INDEX);
	for(new i = 0; i < 15; i++) { ObjectMovementIndex[i] = E_INDEX[i]; }


// Sub-Menus ///////////////////////////////////////////////////////////////////

	// Edit sub
	LoadGUIMenu(ObjectSubMenu,SubMenuText,-200.0, 0.0, EXIT_GUI_MENU, E_INDEX);
    GUISetPlayerText(ObjectSubMenu, E_INDEX[6], "Object Editor");

	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 135.0, CLICK_OBJECTEDIT_COBJECT, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Create Object");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 150.0, CLICK_OBJECTEDIT_RROT, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Reset Rotation");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");
	
	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 165.0, CLICK_OBJECTEDIT_CLONE, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Clone");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 180.0, CLICK_OBJECTEDIT_GOTO, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Goto");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 195.0, CLICK_OBJECTEDIT_EDIT, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Edit Object");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 210.0, CLICK_OBJECTEDIT_OGROUP, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Assign Group");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(ObjectSubMenu,MenuButton,335.0, 225.0, CLICK_OBJECTEDIT_DOBJECT, E_INDEX);
	GUISetPlayerText(ObjectSubMenu, E_INDEX[1], "Delete Object");
	GUISetPlayerText(ObjectSubMenu, E_INDEX[2], "LD_BEAT:square");


	// Selection sub
	LoadGUIMenu(SelectionSubMenu,SubMenuText,-200.0, 15.0, EXIT_GUI_MENU, E_INDEX);

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 150.0, CLICK_SELECT_OBJECT, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "Select");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 165.0, CLICK_DESELECT_OBJECT, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "Deselect");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 180.0, CLICK_SELECT_CLOSEST, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "Select Closest");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 195.0, CLICK_SELECT_CLICK, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "Click Select");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 210.0, CLICK_SELECT_LIST, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "List Select");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 225.0, CLICK_SELECT_OPROP, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "Property Editor");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(SelectionSubMenu,MenuButton,335.0, 240.0, CLICK_SELECT_DCLOSEST, E_INDEX);
	GUISetPlayerText(SelectionSubMenu, E_INDEX[1], "Delete Closest");
	GUISetPlayerText(SelectionSubMenu, E_INDEX[2], "LD_BEAT:square");

	// Texture Sub
    LoadGUIMenu(TextureSubMenu,SubMenuTexText,-200.0, 30.0, EXIT_GUI_MENU, E_INDEX);
    GUISetPlayerText(TextureSubMenu, E_INDEX[6], "Textures");
    
   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 165.0, CLICK_TEXTURE_TEXEDIT, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Texture Editor");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 180.0, CLICK_TEXTURE_TEXTEDIT, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Text Editor");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");
	
   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 195.0, CLICK_TEXTURE_SHOWINDEX, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Show Indexes");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 210.0, CLICK_TEXTURE_HIDEINDEX, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Hide Indexes");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");
	
   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 225.0, CLICK_TEXTURE_COPY, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Copy Properties");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 240.0, CLICK_TEXTURE_CLEAR, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Clear Properties");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 255.0, CLICK_TEXTURE_PASTE, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Paste Properties");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");
	
   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 270.0, CLICK_TEXTURE_VIEWER, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Texture Viewer");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 285.0, CLICK_TEXTURE_THEMEV, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Theme Viewer");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 300.0, CLICK_TEXTURE_THEMET, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Texture Themes");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

   	LoadGUIMenu(TextureSubMenu,MenuButton,335.0, 315.0, CLICK_TEXTURE_SEARCH, E_INDEX);
	GUISetPlayerText(TextureSubMenu, E_INDEX[1], "Texture Search");
	GUISetPlayerText(TextureSubMenu, E_INDEX[2], "LD_BEAT:square");

	// Load Group Menu
	LoadGUIMenu(GroupMenu,MainMenuText,-100.0, 0.0, CLICK_NO_GROUP, E_INDEX);

	LoadGUIMenu(GroupMenu,MenuButton,435.0, 135.0, CLICK_GROUPSEL_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[1], "Selection");
	
	LoadGUIMenu(GroupMenu,MenuButton,435.0, 150.0, CLICK_GROUPPF_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[1], "Prefabs");

	LoadGUIMenu(GroupMenu,MenuButton,435.0, 165.0, CLICK_PIVOTG_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[1], "Set Pivot");
	GUISetPlayerText(GroupMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupMenu,MenuButton,435.0, 180.0, CLICK_TOGPIVOTG_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[1], "Toggle Pivot");
	GUISetPlayerText(GroupMenu, E_INDEX[2], "LD_BEAT:square");
	
	LoadGUIMenu(GroupMenu,MenuButton,435.0, 195.0, CLICK_ZEROGROUP_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[1], "Group to 0,0,0");
	GUISetPlayerText(GroupMenu, E_INDEX[2], "LD_BEAT:square");
	
	LoadGUIMenu(GroupMenu,MenuButton,435.0, 195.0, CLICK_OBJECTMETRY_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[1], "Objectmetry");
	GUISetPlayerText(GroupMenu, E_INDEX[2], "LD_BEAT:square");


	LoadGUIMenu(GroupMenu,MovementMenu,-100.0, 0.0, CLICK_MOVEMENTG_MENU, E_INDEX);
	GUISetPlayerText(GroupMenu, E_INDEX[12], "_");
	for(new i = 0; i < 15; i++) { ObjectGroupMovementIndex[i] = E_INDEX[i]; }

	
	// Selection sub
	LoadGUIMenu(GroupSelSubMenu,SubMenuTexText,-200.0, 0.0, EXIT_GUI_MENU, E_INDEX);

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 135.0, CLICK_GROUP_CSEL, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Click Select");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 150.0, CLICK_GROUP_GADD, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Add");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 165.0, CLICK_GROUP_GREM, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Remove");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 180.0, CLICK_GROUP_CLEAR, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Clear");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 195.0, CLICK_GROUP_CLONE, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Clone");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 210.0, CLICK_GROUP_GALL, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group All");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 225.0, CLICK_GROUP_SETGROUP, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Set Group");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 240.0, CLICK_GROUP_SELECTGROUP, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Select Group");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 255.0, CLICK_GROUP_EDIT, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Edit");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");
	
	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 270.0, CLICK_GROUP_INFRONT, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Infront");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupSelSubMenu,MenuButton,335.0, 285.0, CLICK_GROUP_GDELETE, E_INDEX);
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[1], "Group Delete");
	GUISetPlayerText(GroupSelSubMenu, E_INDEX[2], "LD_BEAT:square");
	

	// Prefab sub
	LoadGUIMenu(GroupPrefabMenu,SubMenuText,-200.0, 15.0, EXIT_GUI_MENU, E_INDEX);
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[6], "Prefabs");

	LoadGUIMenu(GroupPrefabMenu,MenuButton,335.0, 150.0, CLICK_GROUP_GPREFAB, E_INDEX);
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[1], "Prefab Group");
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[2], "LD_BEAT:square");
	
	LoadGUIMenu(GroupPrefabMenu,MenuButton,335.0, 165.0, CLICK_GROUP_LOADPF, E_INDEX);
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[1], "Load Prefab");
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[2], "LD_BEAT:square");

	LoadGUIMenu(GroupPrefabMenu,MenuButton,335.0, 180.0, CLICK_GROUP_LOADZPF, E_INDEX);
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[1], "Set Load Z");
	GUISetPlayerText(GroupPrefabMenu, E_INDEX[2], "LD_BEAT:square");

	////////////////////////////////////////////////////////////////////////////

	foreach(new i : Player)
	{
	    CreatePlayerMenus(i);
	}

	#if defined MG_OnFilterScriptInit
		MG_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit MG_OnFilterScriptInit
#if defined MG_OnFilterScriptInit
	forward MG_OnFilterScriptInit();
#endif


public OnPlayerConnect(playerid)
{
	CreatePlayerMenus(playerid);

	#if defined MG_OnPlayerConnect
		MG_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect MG_OnPlayerConnect
#if defined MG_OnPlayerConnect
	forward MG_OnPlayerConnect(playerid);
#endif

static CreatePlayerMenus(playerid)
{
	// Set selection
	SetPlayerGUISelectionColor(playerid, 0x00FF00FF);
	
	// Main menu
	PlayerMainMenu[playerid] = PlayerCreateGUI(playerid, "MainMenu");
    PlayerLoadGUIMenu(playerid,PlayerMainMenu[playerid], MainMenuPlayerText, 0.0, 0.0, EXIT_GUI_MENU, E_PLAYERINDEX);

	// Bind menus
	PlayerBindGUITextDraw(playerid, PlayerMainMenu[playerid], MainMenu);
	
	// Object menu
	PlayerObjectMenu[playerid] = PlayerCreateGUI(playerid, "ObjectMenu");
    PlayerLoadGUIMenu(playerid,PlayerObjectMenu[playerid], MainMenuPlayerText,-100.0, 0.0, EXIT_GUI_MENU, E_PLAYERINDEX);
    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[0], "Object Menu");
    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[2], "_");
    PlayerGUISetSelectable(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[2], 0);

    PlayerLoadGUIMenu(playerid,PlayerObjectMenu[playerid], MovementInfo,-100.0, 0.0, EXIT_GUI_MENU, E_PLAYERINDEX);
	for(new i = 0; i < 8; i++) { CurrObjectPosition[playerid][i] = E_PLAYERINDEX[i]; }
    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[6], "Off");
    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[7], "1.0");
    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[8], "5.0");

   	// Group Menu
   	PlayerGroupMenu[playerid] = PlayerCreateGUI(playerid, "GroupMenu");
    PlayerLoadGUIMenu(playerid,PlayerGroupMenu[playerid], MainMenuPlayerText,-100.0, 0.0, EXIT_GUI_MENU, E_PLAYERINDEX);
    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[0], "Group Menu");
    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[2], "_");
    PlayerGUISetSelectable(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[2], 0);

    PlayerLoadGUIMenu(playerid,PlayerGroupMenu[playerid], MovementInfo,-100.0, 0.0, EXIT_GUI_MENU, E_PLAYERINDEX);
	for(new i = 0; i < 8; i++) { CurrGroupPosition[playerid][i] = E_PLAYERINDEX[i]; }
	PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[3], "------");
	PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[4], "------");
	PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[5], "------");
    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[6], "_");
    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[7], "1.0");
    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[8], "5.0");


	// Bind menus
	PlayerBindGUITextDraw(playerid, PlayerObjectMenu[playerid], ObjectMenu);
	PlayerBindGUITextDraw(playerid, PlayerGroupMenu[playerid], GroupMenu);

	// Sub-menus forces all sub menus to close by closing submenu
	PlayerSubMenu[playerid] = PlayerCreateGUI(playerid, "SubMenu");

	// Submenu binding
	PlayerBindGUITextDraw(playerid, PlayerSubMenu[playerid], SelectionSubMenu);
	PlayerBindGUITextDraw(playerid, PlayerSubMenu[playerid], ObjectSubMenu);
	PlayerBindGUITextDraw(playerid, PlayerSubMenu[playerid], TextureSubMenu);
	
	// Group binding
	PlayerBindGUITextDraw(playerid, PlayerSubMenu[playerid], GroupSelSubMenu);
	PlayerBindGUITextDraw(playerid, PlayerSubMenu[playerid], GroupPrefabMenu);
	

	// Default rotation / movement
	CurrMovementInc[playerid] = 1.0;
   	CurrRotationInc[playerid] = 5.0;
	CurrMovementGInc[playerid] = 1.0;
   	CurrRotationGInc[playerid] = 5.0;

	// Default delta off
   	DeltaMapMovement[playerid] = false;
   	


	return 1;
}

OnPlayerKeyStateMenuChange(playerid, newkeys, oldkeys)
{
	#pragma unused oldkeys
	if( newkeys & KEY_NO || (IsFlyMode(playerid) && newkeys & KEY_JUMP) )
	{
	    if(!EditingMode[playerid])
	    {
            PlayerShowGUIMenu(playerid, PlayerMainMenu[playerid], true);
            PlayerSelectGUITextDraw(playerid);
			return 1;
		}
	}
	return 0;
}


HideGUIInterface(playerid)
{
    PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]);
	PlayerHideGUIMenu(playerid, PlayerObjectMenu[playerid]);
	PlayerHideGUIMenu(playerid, PlayerMainMenu[playerid]);
	PlayerCancelSelectGUITextDraw(playerid);
	return 1;
}

// Main Menu ///////////////////////////////////////////////////////////////////
OnPlayerGUIClick:MainMenu(playerid, group, gindex, pindex)
{
	// Exit
	if(group == EXIT_GUI_MENU)
	{
		if(pindex == 1) HideGUIInterface(playerid);
		else if(pindex == 2) PlayerCancelSelectGUITextDraw(playerid, true);
	}
	return 1;
}

OnGUIClick:MainMenu(playerid, group, gindex, pindex)
{
	// Call newmap function
	switch(group)
	{
		// Map commands
	    case CLICK_NEW_MAP: { BroadcastCommand(playerid, "/newmap"); }
	    case CLICK_LOAD_MAP: { BroadcastCommand(playerid, "/loadmap"); }
	    case CLICK_IMPORT_MAP: { BroadcastCommand(playerid, "/importmap"); }
	    case CLICK_EXPORT_MAP: { BroadcastCommand(playerid, "/export"); }

		// Mode commands
	    case CLICK_OBJECT_MODE:
		{
			MapOpenCheck();
			PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]);
			PlayerHideGUIMenu(playerid, PlayerGroupMenu[playerid]);
			PlayerShowGUIMenu(playerid, PlayerObjectMenu[playerid], true);
		}
	    case CLICK_GROUP_MODE:
		{
			MapOpenCheck();
			PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]);
			PlayerHideGUIMenu(playerid, PlayerObjectMenu[playerid]);
			PlayerShowGUIMenu(playerid, PlayerGroupMenu[playerid], true);
		}
	    case CLICK_FLY_MODE: { BroadcastCommand(playerid, "/flymode"); }
	    case CLICK_BIND_1..CLICK_BIND_8:
	    {
	        new line[128];
	        format(line, sizeof(line), "/runbind %i", group - CLICK_BIND_1);
	        BroadcastCommand(playerid, line);
	    }
	}
	return 1;
}


OnPlayerGUIClose:MainMenu(playerid, group, gindex)
{
	// Always close the submenu
    PlayerHideGUIMenu(playerid, PlayerObjectMenu[playerid]);
	return 1;
}

//Object Menu///////////////////////////////////////////////////////////////////
OnPlayerGUIClick:ObjectMenu(playerid, group, gindex, pindex)
{
	// Exit
	if(group == EXIT_GUI_MENU)
	{
		PlayerHideGUIMenu(playerid, PlayerObjectMenu[playerid]);
		PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);
	}
	return 1;
}

OnGUIClick:ObjectMenu(playerid, group, gindex, pindex)
{
	// Call newmap function
	switch(group)
	{
		// Edit objects
		case CLICK_OBJECTEDIT_MENU:
		{
			// Open the sub-menu controller (Don't show binds)
			PlayerShowGUIMenu(playerid, PlayerSubMenu[playerid], true);

			// Hide all menus
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);

			// Show the Sub object menu
            ShowGUIMenu(playerid, ObjectSubMenu);
		}

		// Map commands
	    case CLICK_SELECTION_MENU:
		{
			// Open the sub-menu controller (Don't show binds)
			PlayerShowGUIMenu(playerid, PlayerSubMenu[playerid], true);

			// Hide all menus
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);

			// Show the Sub selection menu
            ShowGUIMenu(playerid, SelectionSubMenu);
		}
		
		// Texture commands
		case CLICK_TEXTURE_MENU:
		{
			// Open the sub-menu controller (Don't show binds)
			PlayerShowGUIMenu(playerid, PlayerSubMenu[playerid], true);

			// Hide all menus
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);

			// Show the Sub texture menu
            ShowGUIMenu(playerid, TextureSubMenu);
		}
		// Search object
		case CLICK_SEARCH_MENU:
		{
			inline SearchObject(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				if(response)
				{
					new line[128];
					format(line, sizeof(line), "/osearch %s", text);
					PlayerSetGUIPaused(playerid, true);
					BroadcastCommand(playerid, line);
				}
			}
	        Dialog_ShowCallback(playerid, using inline SearchObject, DIALOG_STYLE_INPUT, "Texture Studio", "Input object search string", "Ok", "Cancel");
		}
		
		case CLICK_PIVOT_MENU:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayEditPivot", 1000, false, "i", playerid);
		}
		case CLICK_TOGPIVOT_MENU: { BroadcastCommand(playerid, "/togpivot"); }
		
		case CLICK_MOVEMENT_MENU:
		{
			if(CurrObject[playerid] == -1) return 1;
            // +x:0 +y:1 +z:2 +rx:3 +ry:4 +rz:5 -x:6 -y:7 -z:8 -rx:9 -ry:10 -rz:11
			new line[128];
			if(ObjectMovementIndex[0] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/dox %0.3f", CurrMovementInc[playerid]);
					else format(line, sizeof(line), "/ox %0.3f", CurrMovementInc[playerid]);
				}
				else format(line, sizeof(line), "/avox %0.3f", CurrMovementInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[1] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/doy %0.3f", CurrMovementInc[playerid]);
					else format(line, sizeof(line), "/oy %0.3f", CurrMovementInc[playerid]);
				}
                else format(line, sizeof(line), "/avoy %0.3f", CurrMovementInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[2] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/doz %0.3f", CurrMovementInc[playerid]);
					else format(line, sizeof(line), "/oz %0.3f", CurrMovementInc[playerid]);
				}
				else format(line, sizeof(line), "/avoz %0.3f", CurrMovementInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[3] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/drx %0.3f", CurrRotationInc[playerid]);
					else format(line, sizeof(line), "/rx %0.3f", CurrRotationInc[playerid]);
				}
				else format(line, sizeof(line), "/avrx %0.3f", CurrRotationInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[4] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/dry %0.3f", CurrRotationInc[playerid]);
					else format(line, sizeof(line), "/ry %0.3f", CurrRotationInc[playerid]);
				}
				else format(line, sizeof(line), "/avry %0.3f", CurrRotationInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[5] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/drz %0.3f", CurrRotationInc[playerid]);
					else format(line, sizeof(line), "/rz %0.3f", CurrRotationInc[playerid]);
				}
				else format(line, sizeof(line), "/avrz %0.3f", CurrRotationInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[6] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/dox %0.3f", CurrMovementInc[playerid]*-1);
					else format(line, sizeof(line), "/ox %0.3f", CurrMovementInc[playerid]*-1);
				}
				else format(line, sizeof(line), "/avox %0.3f", CurrMovementInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[7] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/doy %0.3f", CurrMovementInc[playerid]*-1);
					else format(line, sizeof(line), "/oy %0.3f", CurrMovementInc[playerid]*-1);
				}
				else format(line, sizeof(line), "/avoy %0.3f", CurrMovementInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[8] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/doz %0.3f", CurrMovementInc[playerid]*-1);
					else format(line, sizeof(line), "/oz %0.3f", CurrMovementInc[playerid]*-1);
				}
				else format(line, sizeof(line), "/avoz %0.3f", CurrMovementInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[9] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/drx %0.3f", CurrRotationInc[playerid]*-1);
					else format(line, sizeof(line), "/rx %0.3f", CurrRotationInc[playerid]*-1);
				}
				else format(line, sizeof(line), "/avrx %0.3f", CurrRotationInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[10] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/dry %0.3f", CurrRotationInc[playerid]*-1);
					else format(line, sizeof(line), "/ry %0.3f", CurrRotationInc[playerid]*-1);
				}
				else format(line, sizeof(line), "/avry %0.3f", CurrRotationInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectMovementIndex[11] == pindex)
			{
				if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
				{
					if(DeltaMapMovement[playerid]) format(line, sizeof(line), "/drz %0.3f", CurrRotationInc[playerid]*-1);
					else format(line, sizeof(line), "/rz %0.3f", CurrRotationInc[playerid]*-1);
				}
				else format(line, sizeof(line), "/avrz %0.3f", CurrRotationInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			// Delta mode on/off
			else if(ObjectMovementIndex[12] == pindex)
			{
				if(DeltaMapMovement[playerid])
				{
				    DeltaMapMovement[playerid] = false;
				    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[6], "Off");
				}
				else
				{
				    DeltaMapMovement[playerid] = true;
				    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[6], "On");
				}
			}
			// Set object position
			else if(ObjectMovementIndex[13] == pindex)
			{
				inline SetMovementInc(pid, dialogid, response, listitem, string:text[])
				{
					#pragma unused listitem, dialogid, pid, text
					if(response)
					{
						new Float:tmp;
					    if(sscanf(text, "f", tmp)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a increment value!");
					    if(tmp < -100.0 || tmp > 100.0) return SendClientMessage(playerid, STEALTH_YELLOW, "Out of range increment! <-100.0 - 100.0>");
					    CurrMovementInc[playerid] = tmp;
					    format(line, sizeof(line), "%0.3f", tmp);
					    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[7], line);
					}
				}
                Dialog_ShowCallback(playerid, using inline SetMovementInc, DIALOG_STYLE_INPUT, "Texture Studio", "Input object movement inc", "Ok", "Cancel");
			}

			else if(ObjectMovementIndex[14] == pindex)
			{
				inline SetMovementRot(pid, dialogid, response, listitem, string:text[])
				{
					#pragma unused listitem, dialogid, pid, text
					if(response)
					{
						new Float:tmp;
					    if(sscanf(text, "f", tmp)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a increment value!");
					    if(tmp < -100.0 || tmp > 100.0) return SendClientMessage(playerid, STEALTH_YELLOW, "Out of range increment! <-100.0 - 100.0>");
					    CurrRotationInc[playerid] = tmp;
					    format(line, sizeof(line), "%0.3f", tmp);
					    PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], E_PLAYERINDEX[8], line);
					}
				}
                Dialog_ShowCallback(playerid, using inline SetMovementRot, DIALOG_STYLE_INPUT, "Texture Studio", "Input object rotation inc", "Ok", "Cancel");
			}
		}
	}
	return 1;
}

OnPlayerGUIClose:ObjectMenu(playerid, group, gindex)
{

	return 1;
}

//Sub-menus//////////////////////////////////////////////////////////////////////

	// Object menu
OnGUIClick:SubObjectEdit(playerid, group, gindex, pindex)
{
	// Exit
	switch(group)
	{
	    case EXIT_GUI_MENU: { PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]); }
	    case CLICK_OBJECTEDIT_COBJECT:
		{
			inline ChooseObject(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/cobject %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline ChooseObject, DIALOG_STYLE_INPUT, "Texture Studio", "Input objectid to create", "Ok", "Cancel");
		}
	    case CLICK_OBJECTEDIT_RROT: { BroadcastCommand(playerid, "/rotreset"); }
	    case CLICK_OBJECTEDIT_DOBJECT: { BroadcastCommand(playerid, "/dobject"); }
	    case CLICK_OBJECTEDIT_CLONE: { BroadcastCommand(playerid, "/clone"); }
	    case CLICK_OBJECTEDIT_GOTO: { BroadcastCommand(playerid, "/ogoto"); }
	    case CLICK_OBJECTEDIT_EDIT:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayEditObject", 1000, false, "i", playerid);
		}
		case CLICK_OBJECTEDIT_OGROUP:
		{
			inline GroupAssign(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/ogroup %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline GroupAssign, DIALOG_STYLE_INPUT, "Texture Studio", "Input group assignment for object", "Ok", "Cancel");
		}
	}

	return 1;
}

// Selection menu
OnGUIClick:SubMenuSel(playerid, group, gindex, pindex)
{
	// Exit
	switch(group)
	{
	    case EXIT_GUI_MENU: { PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]); }
	    case CLICK_SELECT_OBJECT:
		{
			inline ChooseSelection(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/sel %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline ChooseSelection, DIALOG_STYLE_INPUT, "Texture Studio", "Input object selection ID", "Ok", "Cancel");
		}
		case CLICK_DESELECT_OBJECT: { BroadcastCommand(playerid, "/dsel"); }
		case CLICK_SELECT_CLOSEST: { BroadcastCommand(playerid, "/scsel"); }
		case CLICK_SELECT_CLICK:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayCSel", 1000, false, "i", playerid);
		}
		case CLICK_SELECT_LIST:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayLSel", 1000, false, "i", playerid);
		}
		
		case CLICK_SELECT_OPROP: { BroadcastCommand(playerid, "/oprop"); }
		
		case CLICK_SELECT_DCLOSEST: { BroadcastCommand(playerid, "/dcsel"); }
	}
	return 1;
}



// Texture menu
OnGUIClick:SubMenuTex(playerid, group, gindex, pindex)
{
	// Exit
	switch(group)
	{
	    case EXIT_GUI_MENU: { PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]); }
		case CLICK_TEXTURE_TEXEDIT:
		{
			// Gets messy if we leave the submenu open
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);

			// This menu will always be the first in open stack
			GUIHideFirstInStack(playerid);
			BroadcastCommand(playerid, "/stexture");
		}
		case CLICK_TEXTURE_TEXTEDIT:
		{
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);
			GUIHideFirstInStack(playerid);
			BroadcastCommand(playerid, "/text");
		}
		case CLICK_TEXTURE_SHOWINDEX: { BroadcastCommand(playerid, "/sindex"); }
		case CLICK_TEXTURE_HIDEINDEX: { BroadcastCommand(playerid, "/rindex"); }
		case CLICK_TEXTURE_COPY: { BroadcastCommand(playerid, "/copy"); }
		case CLICK_TEXTURE_PASTE: { BroadcastCommand(playerid, "/paste"); }
		case CLICK_TEXTURE_CLEAR: { BroadcastCommand(playerid, "/clear"); }
		case CLICK_TEXTURE_VIEWER: { BroadcastCommand(playerid, "/mtextures"); }
		case CLICK_TEXTURE_THEMEV: { BroadcastCommand(playerid, "/ttextures"); }
		case CLICK_TEXTURE_THEMET:
		{
			inline ThemeMenu(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
		        if(response)
		        {
		            switch(listitem)
		            {
		                case 0: { BroadcastCommand(playerid, "/savetheme"); }
		                case 1: { BroadcastCommand(playerid, "/loadtheme"); }
		                case 2: { BroadcastCommand(playerid, "/deletetheme"); }
		            }
		        }
			}
			Dialog_ShowCallback(playerid, using inline ThemeMenu, DIALOG_STYLE_LIST, "Texture Studio", "Save Theme\nLoad Theme\nDelete Theme", "Ok", "Cancel");

		}
		case CLICK_TEXTURE_SEARCH:
		{
			inline TextureSearch(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/tsearch %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline TextureSearch, DIALOG_STYLE_INPUT, "Texture Studio", "Search for a texture name", "Ok", "Cancel");
		}
	}
	return 1;
}


//Group Menu///////////////////////////////////////////////////////////////////
OnPlayerGUIClick:GroupMenu(playerid, group, gindex, pindex)
{
	// Exit
	if(group == EXIT_GUI_MENU)
	{
		PlayerHideGUIMenu(playerid, PlayerGroupMenu[playerid]);
		PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);
	}
	return 1;
}

OnGUIClick:GroupMenu(playerid, group, gindex, pindex)
{
	switch(group)
	{
		case CLICK_GROUPSEL_MENU:
		{
			// Open the sub-menu controller (Don't show binds)
			PlayerShowGUIMenu(playerid, PlayerSubMenu[playerid], true);

			// Hide all menus
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);

			// Show the Sub object menu
            ShowGUIMenu(playerid, GroupSelSubMenu);
		}

		// Edit objects
		case CLICK_GROUPPF_MENU:
		{
			// Open the sub-menu controller (Don't show binds)
			PlayerShowGUIMenu(playerid, PlayerSubMenu[playerid], true);

			// Hide all menus
			PlayerHideAllGUIBindMenu(playerid, PlayerSubMenu[playerid]);

			// Show the Sub object menu
            ShowGUIMenu(playerid, GroupPrefabMenu);
		}

		// Pivot
		case CLICK_PIVOTG_MENU:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayEditPivot", 1000, false, "i", playerid);
		}
		case CLICK_TOGPIVOTG_MENU: { BroadcastCommand(playerid, "/togpivot"); }

		// Send group to 0,0,0 position
		case CLICK_ZEROGROUP_MENU:
		{
			inline ZeroGroup(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
		        if(response) BroadcastCommand(playerid, "/0group");
			}
			Dialog_ShowCallback(playerid, using inline ZeroGroup, DIALOG_STYLE_MSGBOX, "Texture Studio", "This will set your currently grouped\nobjects to the 0,0,0 postion", "Ok", "Cancel");
		}

		// Objectmetry editor
        case CLICK_OBJECTMETRY_MENU: { BroadcastCommand(playerid, "/obmedit"); }

		case CLICK_MOVEMENTG_MENU:
		{
            // +x:0 +y:1 +z:2 +rx:3 +ry:4 +rz:5 -x:6 -y:7 -z:8 -rx:9 -ry:10 -rz:11
			new line[128];
			if(ObjectGroupMovementIndex[0] == pindex)
			{
				format(line, sizeof(line), "/gox %0.3f", CurrMovementGInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[1] == pindex)
			{
				format(line, sizeof(line), "/goy %0.3f", CurrMovementGInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[2] == pindex)
			{
				format(line, sizeof(line), "/goz %0.3f", CurrMovementGInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[3] == pindex)
			{
				format(line, sizeof(line), "/grx %0.3f", CurrRotationGInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[4] == pindex)
			{
				format(line, sizeof(line), "/gry %0.3f", CurrRotationGInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[5] == pindex)
			{
				format(line, sizeof(line), "/grz %0.3f", CurrRotationGInc[playerid]);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[6] == pindex)
			{
				format(line, sizeof(line), "/gox %0.3f", CurrMovementGInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[7] == pindex)
			{
				format(line, sizeof(line), "/goy %0.3f", CurrMovementGInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[8] == pindex)
			{
				format(line, sizeof(line), "/goz %0.3f", CurrMovementGInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[9] == pindex)
			{
				format(line, sizeof(line), "/grx %0.3f", CurrRotationGInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[10] == pindex)
			{
				format(line, sizeof(line), "/gry %0.3f", CurrRotationGInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			else if(ObjectGroupMovementIndex[11] == pindex)
			{
				format(line, sizeof(line), "/grz %0.3f", CurrRotationGInc[playerid]*-1);
				BroadcastCommand(playerid, line);
			}
			
			
			// Set object position
			else if(ObjectGroupMovementIndex[13] == pindex)
			{
				inline SetMovementGInc(pid, dialogid, response, listitem, string:text[])
				{
					#pragma unused listitem, dialogid, pid, text
					if(response)
					{
						new Float:tmp;
					    if(sscanf(text, "f", tmp)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a increment value!");
					    if(tmp < -100.0 || tmp > 100.0) return SendClientMessage(playerid, STEALTH_YELLOW, "Out of range increment! <-100.0 - 100.0>");
					    CurrMovementGInc[playerid] = tmp;
					    format(line, sizeof(line), "%0.3f", tmp);
					    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[7], line);
					}
				}
                Dialog_ShowCallback(playerid, using inline SetMovementGInc, DIALOG_STYLE_INPUT, "Texture Studio", "Input group movement inc", "Ok", "Cancel");
			}

			else if(ObjectGroupMovementIndex[14] == pindex)
			{
				inline SetMovementGRot(pid, dialogid, response, listitem, string:text[])
				{
					#pragma unused listitem, dialogid, pid, text
					if(response)
					{
						new Float:tmp;
					    if(sscanf(text, "f", tmp)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a increment value!");
					    if(tmp < -100.0 || tmp > 100.0) return SendClientMessage(playerid, STEALTH_YELLOW, "Out of range increment! <-100.0 - 100.0>");
					    CurrRotationGInc[playerid] = tmp;
					    format(line, sizeof(line), "%0.3f", tmp);
					    PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], E_PLAYERINDEX[8], line);
					}
				}
                Dialog_ShowCallback(playerid, using inline SetMovementGRot, DIALOG_STYLE_INPUT, "Texture Studio", "Input group rotation inc", "Ok", "Cancel");
			}
		}
	}
	return 1;
}

// Sub menu group selection
OnGUIClick:SubMenuGroupSel(playerid, group, gindex, pindex)
{
	switch(group)
	{
	    case EXIT_GUI_MENU: { PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]); }
		case CLICK_GROUP_CSEL:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayGSel", 1000, false, "i", playerid);
		}
		case CLICK_GROUP_GADD:
		{
			inline AddGroupObject(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/gadd %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline AddGroupObject, DIALOG_STYLE_INPUT, "Texture Studio", "Input object to add to group", "Ok", "Cancel");
		}
		
		case CLICK_GROUP_GREM:
		{
			inline RemGroupObject(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/grem %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline RemGroupObject, DIALOG_STYLE_INPUT, "Texture Studio", "Input object to remove from group", "Ok", "Cancel");
		}
		case CLICK_GROUP_CLEAR:  { BroadcastCommand(playerid, "/gclear"); }
		case CLICK_GROUP_CLONE:  { BroadcastCommand(playerid, "/gclone"); }
		case CLICK_GROUP_GALL:  { BroadcastCommand(playerid, "/gall"); }
		case CLICK_GROUP_SETGROUP:
		{
			inline SetGroup(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/setgroup %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline SetGroup, DIALOG_STYLE_INPUT, "Texture Studio", "Set grouped objects to group", "Ok", "Cancel");
		}

		case CLICK_GROUP_SELECTGROUP:
		{
			inline SelectGroup(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				new line[128];
				format(line, sizeof(line), "/selectgroup %s", text);
				if(response) { BroadcastCommand(playerid, line); }
			}
			Dialog_ShowCallback(playerid, using inline SelectGroup, DIALOG_STYLE_INPUT, "Texture Studio", "Input group to select", "Ok", "Cancel");
		}

		case CLICK_GROUP_GDELETE:
		{

			inline ConfirmGDelete(pid, dialogid, response, listitem, string:text[])
			{
				#pragma unused listitem, dialogid, pid, text
				if(response) { BroadcastCommand(playerid, "/gdelete"); }
			}
			Dialog_ShowCallback(playerid, using inline ConfirmGDelete, DIALOG_STYLE_MSGBOX, "Texture Studio", "Are you sure you want to delete all objects in this group?", "Ok", "Cancel");
		}
		case CLICK_GROUP_EDIT:
		{
			// Force cancel
			PlayerCancelSelectGUITextDraw(playerid, true);

			// csel mode (We need to delay to use this mode effectively)
			SetTimerEx("DelayGEdit", 1000, false, "i", playerid);
		}
		
		case CLICK_GROUP_INFRONT: { BroadcastCommand(playerid, "/ginfront"); }
		
	}
	return 1;
}

new list[4096];

// Submenu group Prefabs
OnGUIClick:SubMenuGroupPF(playerid, group, gindex, pindex)
{
	switch(group)
	{
	    case EXIT_GUI_MENU: { PlayerHideGUIMenu(playerid, PlayerSubMenu[playerid]); }
		case CLICK_GROUP_GPREFAB: { BroadcastCommand(playerid, "/gprefab"); }
		case CLICK_GROUP_LOADPF:
		{
			new dir:dHandle = dir_open("./scriptfiles/tstudio/PreFabs/");
			new item[40], type;
			new extension[3];
			new total;
			list[0] = '\0';

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
							strmid(item, item, 0, strlen(item)-3, 40);
							format(list, sizeof(list), "%s%s\n", list, item);
							total++;
						}
				    }
				}
			}
			if(total == 0) SendClientMessage(playerid, STEALTH_YELLOW, "There are no prefabs to list!");
			else
			{
				inline SelectPrefab(pid, dialogid, response, listitem, string:text[])
				{
					#pragma unused listitem, dialogid, pid, text
					if(response)
					{
						new line[128];
						format(line, sizeof(line), "/prefab %s", text);
						BroadcastCommand(playerid, line);
					}
				}
				Dialog_ShowCallback(playerid, using inline SelectPrefab, DIALOG_STYLE_LIST, "Texture Studio - Load Prefab", list, "Ok", "Cancel");
			}
		}
		case CLICK_GROUP_LOADZPF:
		{
			new dir:dHandle = dir_open("./scriptfiles/tstudio/PreFabs/");
			new item[40], type;
			new extension[3];
			new total;

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
							strmid(item, item, 0, strlen(item)-3, 40);
							format(list, sizeof(list), "%s%s\n", list, item);
							total++;
						}
				    }
				}
			}
			if(total == 0) SendClientMessage(playerid, STEALTH_YELLOW, "There are no prefabs to list!");
			else
			{
				inline SelectLoadZ(pid, dialogid, response, listitem, string:text[])
				{
					#pragma unused listitem, dialogid, pid, text
					if(response)
					{
                        inline ChooseZ(zpid, zdialogid, zresponse, zlistitem, string:ztext[])
                        {
                            #pragma unused zlistitem, zdialogid, zpid, ztext
							if(zresponse)
							{
								new Float:zheight;
	                            if(!sscanf(ztext, "f", zheight))
								{
									new line[128];
									format(line, sizeof(line), "/prefabsetz %s %f", text, zheight);
									BroadcastCommand(playerid, line);
								}
							}
                        }
						Dialog_ShowCallback(playerid, using inline ChooseZ, DIALOG_STYLE_INPUT, "Texture Studio - Set Prefab Load Z", "Enter the load Z-Offset for this prefab", "Ok", "Cancel");
					}
				}
				Dialog_ShowCallback(playerid, using inline SelectLoadZ, DIALOG_STYLE_LIST, "Texture Studio - Load Prefab", list, "Ok", "Cancel");
			}
		}
	}
	return 1;
}
////////////////////////////////////////////////////////////////////////////////

forward DelayLSel(playerid);
public DelayLSel(playerid) { if(IsPlayerConnected(playerid)) BroadcastCommand(playerid, "/lsel"); }

forward DelayCSel(playerid);
public DelayCSel(playerid) { if(IsPlayerConnected(playerid)) BroadcastCommand(playerid, "/csel"); }

forward DelayGSel(playerid);
public DelayGSel(playerid) { if(IsPlayerConnected(playerid)) BroadcastCommand(playerid, "/gsel"); }


forward DelayEditObject(playerid);
public DelayEditObject(playerid) { if(IsPlayerConnected(playerid)) BroadcastCommand(playerid, "/editobject"); }

forward DelayEditPivot(playerid);
public DelayEditPivot(playerid) { if(IsPlayerConnected(playerid)) BroadcastCommand(playerid, "/pivot"); }

forward DelayGEdit(playerid);
public DelayGEdit(playerid) { if(IsPlayerConnected(playerid)) BroadcastCommand(playerid, "/editgroup"); }

public OnPlayerObjectSelectChange(playerid, index)
{
	UpdatePlayerOSelText(playerid);
	return 1;
}

public OnObjectUpdatePos(playerid, index)
{
	UpdatePlayerOSelText(playerid);
	return 1;
}

tsfunc UpdatePlayerOSelText(playerid)
{
	if(CurrObject[playerid] == -1)
	{
		PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][0], "X:0.0");
		PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][1], "Y:0.0");
		PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][2], "Z:0.0");
		PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][3], "RX:0.0");
		PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][4], "RY:0.0");
		PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][5], "RZ:0.0");
	}
	else
	{
	    new line[16];
		if(ObjectData[CurrObject[playerid]][oAttachedVehicle] == -1)
		{
			format(line, sizeof(line), "X:%0.2f", ObjectData[CurrObject[playerid]][oX]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][0], line);

			format(line, sizeof(line), "Y:%0.2f", ObjectData[CurrObject[playerid]][oY]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][1], line);

			format(line, sizeof(line), "Z:%0.2f", ObjectData[CurrObject[playerid]][oZ]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][2], line);

			format(line, sizeof(line), "RX:%0.2f", ObjectData[CurrObject[playerid]][oRX]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][3], line);

			format(line, sizeof(line), "RY:%0.2f", ObjectData[CurrObject[playerid]][oRY]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][4], line);

			format(line, sizeof(line), "RZ:%0.2f", ObjectData[CurrObject[playerid]][oRZ]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][5], line);
		}
		else
		{
			new index = ObjectData[CurrObject[playerid]][oAttachedVehicle];
			new refindex = GetCarObjectRefIndex(index, CurrObject[playerid]);
			
			format(line, sizeof(line), "X:%0.2f", CarData[index][COX][refindex]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][0], line);

			format(line, sizeof(line), "Y:%0.2f", CarData[index][COY][refindex]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][1], line);

			format(line, sizeof(line), "Z:%0.2f", CarData[index][COZ][refindex]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][2], line);

			format(line, sizeof(line), "RX:%0.2f", CarData[index][CORX][refindex]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][3], line);

			format(line, sizeof(line), "RY:%0.2f", CarData[index][CORY][refindex]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][4], line);

			format(line, sizeof(line), "RZ:%0.2f", CarData[index][CORZ][refindex]);
			PlayerGUISetPlayerText(playerid, PlayerObjectMenu[playerid], CurrObjectPosition[playerid][5], line);
		
		
		}
	}
	return 1;
}



tsfunc UpdatePlayerGSelText(playerid)
{
	new Float:x, Float:y, Float:z;
	if(!GetGroupCenter(playerid, x, y, z))
	{
		PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], CurrGroupPosition[playerid][0], "X:0.0");
		PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], CurrGroupPosition[playerid][1], "Y:0.0");
		PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], CurrGroupPosition[playerid][2], "Z:0.0");
	}
	else
	{
	    new line[16];
		format(line, sizeof(line), "X:%0.2f", x);
		PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], CurrGroupPosition[playerid][0], line);

		format(line, sizeof(line), "Y:%0.2f", y);
		PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], CurrGroupPosition[playerid][1], line);

		format(line, sizeof(line), "Z:%0.2f", z);
		PlayerGUISetPlayerText(playerid, PlayerGroupMenu[playerid], CurrGroupPosition[playerid][2], line);
	}
	return 1;
}






////////////////////////////////////////////////////////////////////////////////
// Commands
#define     MAX_CLICK_BINDS     		10
#define     MAX_BIND_TEXT_LENGTH        16
#define     MAX_BINDS_PER_BIND          10
#define     MAX_BIND_LENGTH             128


static bool:BindUsed[MAX_CLICK_BINDS];
static CommandBindText[MAX_CLICK_BINDS][MAX_BIND_TEXT_LENGTH];
static CommandBindData[MAX_CLICK_BINDS][MAX_BINDS_PER_BIND][MAX_BIND_LENGTH];
static tmpCommandBindText[MAX_BIND_TEXT_LENGTH];
static tmpCommandBindData[MAX_BINDS_PER_BIND][MAX_BIND_LENGTH];

YCMD:runbind(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Run a saved bind. Used to simplify a repeated process.");
		return 1;
	}

    NoEditingMode(playerid);
	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage /runbind <0-9>");
	new bind = strval(arg);
	if(bind < 0 || bind > (MAX_CLICK_BINDS - 1)) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage /runbind <0-9>");
	if(!BindUsed[bind]) return SendClientMessage(playerid, STEALTH_YELLOW, "That bind is not used, type /bindeditor to create one");

	// Broadcast commands from command binds
	for(new i = 0; i < MAX_BINDS_PER_BIND; i++)
	{
		if(!isnull(CommandBindData[bind][i])) BroadcastCommand(playerid, CommandBindData[bind][i]);
	}

	return 1;
}

/*
YCMD:makebind(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Create a bind out of the specified number of last commands.");
		return 1;
	}

	new index, range;
	sscanf(arg, "iI(1)", index, range);
	
	if(0 > index > MAX_CLICK_BINDS) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage /makebind <Bind Index (0-9)> <Number of Commands (1-10)>");
	if(1 > range > MAX_COMMAND_BUFFER) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage /makebind <Bind Index (0-9)> <Number of Commands (1-10)>");
	
	for(new x; x < range; x++) { 
		//CommandBindData[index][x] = CommandBuffer[playerid][range - 1 - x];
		format(CommandBindData[index][x], 128, "%s", CommandBuffer[playerid][range - 1 - x]);
		printf("%i: %s", x, CommandBindData[index][x]);
	}
	
	BindUsed[index] = true;

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, sprintf("%i is now the last %i commands", index, range));
	
	return 1;
}
*/

YCMD:bindeditor(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Edit currently saved binds.");
		return 1;
	}

    NoEditingMode(playerid);

	new line[1024];

	// Show bind dialog
    inline ChooseBind(cpid, cdialogid, cresponse, clistitem, string:ctext[])
	{
		#pragma unused clistitem, cdialogid, cpid, ctext
		if(cresponse)
		{
			// Edit option for bind
			inline ChooseEditOption(opid, odialogid, oresponse, olistitem, string:otext[])
			{
	            #pragma unused olistitem, odialogid, opid, otext
				if(oresponse)
				{
					// Change text
					if(olistitem == 0)
					{
				   		inline SetBindName(spid, sdialogid, sresponse, slistitem, string:stext[])
					   	{
					        #pragma unused slistitem, sdialogid, spid, stext
							if(sresponse)
							{
								new len = strlen(stext);
								if(len > 0 && len < 16)
								{
									format(CommandBindText[clistitem], MAX_BIND_LENGTH, "%s", stext);

									if(clistitem <= sizeof(BindElementIDS))
									{
										GUISetPlayerText(MainMenu, BindElementIDS[clistitem], CommandBindText[clistitem]);
									}
									BindUsed[clistitem] = true;
									sqlite_DeleteBindString(clistitem);
									sqlite_InsertBindString(clistitem);
								}
								else
								{
									if(len < 1) SendClientMessage(playerid, STEALTH_YELLOW, "Bind name too short");
									else SendClientMessage(playerid, STEALTH_YELLOW, "Bind name too long");
								}
								Dialog_ShowCallback(playerid, using inline ChooseEditOption, DIALOG_STYLE_LIST, "Texture Studio - Choose Edit Type", "Edit Bind Name\nEdit Bind Text\nDelete Bind", "Ok", "Cancel");
							}
							Dialog_ShowCallback(playerid, using inline ChooseEditOption, DIALOG_STYLE_LIST, "Texture Studio - Choose Edit Type", "Edit Bind Name\nEdit Bind Text\nDelete Bind", "Ok", "Cancel");
						}
						Dialog_ShowCallback(playerid, using inline SetBindName, DIALOG_STYLE_INPUT, "Texture Studio - Edit Bind Text", "Set Bind Name", "Ok", "Cancel");

					}
					else if(olistitem == 1)
					{
						if(BindUsed[clistitem])
						{
				            inline EditLine(epid, edialogid, eresponse, elistitem, string:etext[])
							{
				                #pragma unused elistitem, edialogid, epid, etext
								if(eresponse)
								{
					   				inline SetBind(spid, sdialogid, sresponse, slistitem, string:stext[])
								   	{
						                #pragma unused slistitem, sdialogid, spid, stext
										if(sresponse)
										{
											format(CommandBindData[clistitem][elistitem], MAX_BIND_LENGTH, "%s", stext);

											sqlite_DeleteBindString(clistitem);
											sqlite_InsertBindString(clistitem);
										}

										format(line, sizeof(line), "");
									    for(new i = 0; i < MAX_BINDS_PER_BIND; i++) { format(line, sizeof(line), "%s%i: %s\n", line, i, CommandBindData[clistitem][i]); }
										Dialog_ShowCallback(playerid, using inline EditLine, DIALOG_STYLE_LIST, "Texture Studio - Edit Bind Text", line, "Ok", "Cancel");
									}
									Dialog_ShowCallback(playerid, using inline SetBind, DIALOG_STYLE_INPUT, "Texture Studio - Edit Bind Text", "Set Bind", "Ok", "Cancel");
								}
							}
							format(line, sizeof(line), "");
						    for(new i = 0; i < MAX_BINDS_PER_BIND; i++) { format(line, sizeof(line), "%s%i: %s\n", line, i, CommandBindData[clistitem][i]); }
							Dialog_ShowCallback(playerid, using inline EditLine, DIALOG_STYLE_LIST, "Texture Studio - Edit Bind Text", line, "Ok", "Cancel");
						}
						else
						{
                            SendClientMessage(playerid, STEALTH_YELLOW, "You must set a name to edit this bind!");
						    Dialog_ShowCallback(playerid, using inline ChooseEditOption, DIALOG_STYLE_LIST, "Texture Studio - Choose Edit Type", "Edit Bind Name\nEdit Bind Text\nDelete Bind", "Ok", "Cancel");
						}
					}
					else if(olistitem == 2)
					{
			            inline DeleteBind(dpid, dialogid, dresponse, dlistitem, string:dtext[])
						{
                            #pragma unused dlistitem, dialogid, dpid, dtext
                            if(dresponse)
                            {
                                sqlite_DeleteBindString(clistitem);

                                BindUsed[clistitem] = false;

								format(CommandBindText[clistitem], MAX_BIND_TEXT_LENGTH, "");

								if(clistitem <= sizeof(BindElementIDS))
								{
									new TDText[16];
									format(TDText, sizeof(TDText), "User Bind %0", clistitem);
									GUISetPlayerText(MainMenu, BindElementIDS[clistitem], TDText);
								}

								for(new i = 0; i < MAX_BINDS_PER_BIND; i++) { format (CommandBindData[clistitem][i], MAX_BIND_LENGTH, ""); }

								format(line, sizeof(line), "");
								for(new i = 0; i < MAX_CLICK_BINDS; i++)
								{
								    if(BindUsed[i]) format(line, sizeof(line), "%s%s\n", line, CommandBindText[i]);
								    else format(line, sizeof(line), "%sUnused\n", line);
								}
								Dialog_ShowCallback(playerid, using inline ChooseBind, DIALOG_STYLE_LIST, "Texture Studio - Edit Binds", line, "Ok", "Cancel");
							}
							else Dialog_ShowCallback(playerid, using inline ChooseEditOption, DIALOG_STYLE_LIST, "Texture Studio - Choose Edit Type", "Edit Bind Name\nEdit Bind Text\nDelete Bind", "Ok", "Cancel");
						}
						Dialog_ShowCallback(playerid, using inline DeleteBind, DIALOG_STYLE_MSGBOX, "Texture Studio - Delete", "Delete this bind?", "Ok", "Cancel");
					}
				}
			}
			Dialog_ShowCallback(playerid, using inline ChooseEditOption, DIALOG_STYLE_LIST, "Texture Studio - Choose Edit Type", "Edit Bind Name\nEdit Bind Text\nDelete Bind", "Ok", "Cancel");
		}
	}

	format(line, sizeof(line), "");
	for(new i = 0; i < MAX_CLICK_BINDS; i++)
	{
	    if(BindUsed[i]) format(line, sizeof(line), "%s%s\n", line, CommandBindText[i]);
	    else format(line, sizeof(line), "%sUnused\n", line);
	}


	Dialog_ShowCallback(playerid, using inline ChooseBind, DIALOG_STYLE_LIST, "Texture Studio - Edit Binds", line, "Ok", "Cancel");
	return 1;
}

new LoadBindString[512];
static DBStatement:loadkeybindsstmt;

sqlite_LoadBindString()
{
	for(new i = 0; i < MAX_CLICK_BINDS; i++) { BindUsed[i] = false; }

	if(!LoadBindString[0])
	{
		strimplode(" ",
			LoadBindString,
			sizeof(LoadBindString),
			"CREATE TABLE IF NOT EXISTS `KeyBinds`",
			"(IndexID INTEGER,",
			"BindName TEXT,",
			"Bind_1 TEXT,",
			"Bind_2 TEXT,",
			"Bind_3 TEXT,",
			"Bind_4 TEXT,",
			"Bind_5 TEXT,",
			"Bind_6 TEXT,",
			"Bind_7 TEXT,",
			"Bind_8 TEXT,",
			"Bind_9 TEXT,",
			"Bind_10 TEXT);"

		);
	}
	db_exec(SystemDB, LoadBindString);

	loadkeybindsstmt = db_prepare(SystemDB, "SELECT * FROM `KeyBinds`");
	new index;

	// Bind our results
    stmt_bind_result_field(loadkeybindsstmt, 0, DB::TYPE_INT, index);
    stmt_bind_result_field(loadkeybindsstmt, 1, DB::TYPE_STRING, tmpCommandBindText, 16);
    stmt_bind_result_field(loadkeybindsstmt, 2, DB::TYPE_STRING, tmpCommandBindData[0], 128);
    stmt_bind_result_field(loadkeybindsstmt, 3, DB::TYPE_STRING, tmpCommandBindData[1], 128);
    stmt_bind_result_field(loadkeybindsstmt, 4, DB::TYPE_STRING, tmpCommandBindData[2], 128);
    stmt_bind_result_field(loadkeybindsstmt, 5, DB::TYPE_STRING, tmpCommandBindData[3], 128);
    stmt_bind_result_field(loadkeybindsstmt, 6, DB::TYPE_STRING, tmpCommandBindData[4], 128);
    stmt_bind_result_field(loadkeybindsstmt, 7, DB::TYPE_STRING, tmpCommandBindData[5], 128);
    stmt_bind_result_field(loadkeybindsstmt, 8, DB::TYPE_STRING, tmpCommandBindData[6], 128);
    stmt_bind_result_field(loadkeybindsstmt, 9, DB::TYPE_STRING, tmpCommandBindData[7], 128);
    stmt_bind_result_field(loadkeybindsstmt, 10, DB::TYPE_STRING, tmpCommandBindData[8], 128);
    stmt_bind_result_field(loadkeybindsstmt, 11, DB::TYPE_STRING, tmpCommandBindData[9], 128);

	// Execute query
    if(stmt_execute(loadkeybindsstmt))
    {
        while(stmt_fetch_row(loadkeybindsstmt))
        {
            BindUsed[index] = true;
            format(CommandBindText[index], 16, "%s", tmpCommandBindText);
			if(index <= sizeof(BindElementIDS))
			{
				GUISetPlayerText(MainMenu, BindElementIDS[index], CommandBindText[index]);
			}

			for(new i = 0; i < MAX_BINDS_PER_BIND; i++) { CommandBindData[index][i] = tmpCommandBindData[i]; }
        }
		stmt_close(loadkeybindsstmt);
        return 1;
    }
	stmt_close(loadkeybindsstmt);
    return 0;
}

// Insert Key bind
static DBStatement:insertkeybindsstmt;
new InsertBindString[512];

sqlite_InsertBindString(index)
{
	if(!InsertBindString[0])
	{
		strimplode(" ",
			InsertBindString,
			sizeof(InsertBindString),
			"CREATE TABLE IF NOT EXISTS `KeyBinds`",
			"(IndexID INTEGER,",
			"BindName TEXT,",
			"Bind_1 TEXT,",
			"Bind_2 TEXT,",
			"Bind_3 TEXT,",
			"Bind_4 TEXT,",
			"Bind_5 TEXT,",
			"Bind_6 TEXT,",
			"Bind_7 TEXT,",
			"Bind_8 TEXT,",
			"Bind_9 TEXT,",
			"Bind_10 TEXT);"

		);

		strimplode(" ",
		InsertBindString,
			sizeof(InsertBindString),
			"INSERT INTO `KeyBinds`",
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);

        insertkeybindsstmt = db_prepare(SystemDB, InsertBindString);
	}

		// Bind our results
    stmt_bind_value(insertkeybindsstmt, 0, DB::TYPE_INT, index);
    stmt_bind_value(insertkeybindsstmt, 1, DB::TYPE_STRING, CommandBindText[index], 16);
    stmt_bind_value(insertkeybindsstmt, 2, DB::TYPE_STRING, CommandBindData[index][0], 128);
    stmt_bind_value(insertkeybindsstmt, 3, DB::TYPE_STRING, CommandBindData[index][1], 128);
    stmt_bind_value(insertkeybindsstmt, 4, DB::TYPE_STRING, CommandBindData[index][2], 128);
    stmt_bind_value(insertkeybindsstmt, 5, DB::TYPE_STRING, CommandBindData[index][3], 128);
    stmt_bind_value(insertkeybindsstmt, 6, DB::TYPE_STRING, CommandBindData[index][4], 128);
    stmt_bind_value(insertkeybindsstmt, 7, DB::TYPE_STRING, CommandBindData[index][5], 128);
    stmt_bind_value(insertkeybindsstmt, 8, DB::TYPE_STRING, CommandBindData[index][6], 128);
    stmt_bind_value(insertkeybindsstmt, 9, DB::TYPE_STRING, CommandBindData[index][7], 128);
    stmt_bind_value(insertkeybindsstmt, 10, DB::TYPE_STRING, CommandBindData[index][8], 128);
    stmt_bind_value(insertkeybindsstmt, 11, DB::TYPE_STRING, CommandBindData[index][9], 128);

	stmt_execute(insertkeybindsstmt);
	return 1;
}

sqlite_DeleteBindString(index)
{
	new q[128];
	format(q, sizeof(q), "DELETE FROM `KeyBinds` WHERE `IndexID` = %i", index);
	db_free_result(db_query(SystemDB, q));
	return 1;
}

