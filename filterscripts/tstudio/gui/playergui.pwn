/*
Stock functions
PlayerApplyGUIArray(playerid, PlayerGUIMenu:gindex, pindex, GUIType, useoffset = 0, Float:xoffset = 0.0, Float:yoffset = 0.0)
PlayerLoadGUIMenu(playerid,MenuArray,PlayerGUIMenu:gindex,xoffset, yoffset, textsizeoffsetx, textsizeoffsety);
PlayerShowGUIMenu(playerid, PlayerGUIMenu:gindex)
PlayerHideGUIMenu(playerid, PlayerGUIMenu:gindex)
PlayerShowGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
PlayerHideGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
PlayerGUIMenu:PlayerCreateGUI(playerid)
PlayerGUIDestroy(playerid, PlayerGUIMenu:gindex)
PlayerCreateGUIElement(playerid, PlayerGUIMenu:gindex, Float:xoffset, Float:yoffset)
PlayerDeleteGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
PlayerUpdateGUIMenu(playerid, PlayerGUIMenu:gindex, pindex)
PlayerUpdateGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
PlayerBindTextDraw(playerid, PlayerGUIMenu:gindex, GUIMenu:tindex)
PlayerClearBindTextDraw(playerid, PlayerGUIMenu:gindex, GUIMenu:tindex)
PlayerSelectGUITextDraw(playerid)

// Setter functions
PlayerGUISetPlayerText(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIText])
PlayerGUISetBackColor(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIBackColor])
PlayerGUISetFont(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIFont])
PlayerGUISetLetterSize(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUILSizeX], GUIType[GUILSizeY])
PlayerGUISetColor(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIColor])
PlayerGUISetOutline(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIOutline])
PlayerGUISetProportional(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIProportional])
PlayerGUISetShadow(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIShawdow])
PlayerGUISetBox(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIBox])
PlayerGUISetBoxColor(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIBoxColor])
PlayerGUISetTextSize(playerid, PlayerGUIMenu:gindex, pindex, xoffset, yoffset)
PlayerGUISetSelectable(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUISelect])
PlayerGUISetPreviewModel(playerid, PlayerGUIMenu:gindex, pindex, value)
PlayerGUISetPreviewModelRot(playerid, gindex, pindex, GUIType[GUIPModelRX], GUIType[GUIPModelRY], GUIType[GUIPModelRZ], GUIType[GUIPModelZoom]);


// Array data for TD menu
	{
		"New Textdraw",                 // Text
		0.0,                    // OffsetX
		0.0,           			// OffsetY
		0.5,                    // LetterSizeX
		1.0, 		            // LetterSizeY
		0.0,                    // TextsizeX
		0.0,           			// TextsizeY
		0.0,                    // Preview Model RX
		0.0,                    // Preview Model RY
		0.0,                    // Preview Model RZ
		0.0,                    // Preview Model Zoom
		0,                      // Preview model
		0,                      // Backcolor
		0,                      // Font
		-1,                      // Color
		0,                      // Outline
		0,                      // Proportional
		0,                      // Alignment
		0,                      // Shadow
		0,                      // Box
		0,                      // Box color
		0                       // Select
	},
*/

// Valid check
#define PlayerGUIValid(%0,%1,%2) if(!PlayerGUIData[%0][_:%1][PlayerGUIActive]) return 0;\
	if(!PlayerGUIData[%0][_:%1][PlayerGUIUsed][%2]) return 0
#define PlayerGUIValidIndex(%0,%1) if(!PlayerGUIData[%0][_:%1][PlayerGUIActive]) return 0
#define PlayerGUIValidElement(%0,%1,%2) if(!PlayerGUIData[%0][_:%1][PlayerGUIUsed][%2]) return 0


// Called when a player clicks a textdraw
#define OnPlayerGUIClick:%1(%2,%3,%4,%5) \
	forward ONGUIP_%1(%2,%3,%4,%5); \
	public ONGUIP_%1(%2,%3,%4,%5)
	
// Called when a player clicks a textdraw
#define OnPlayerGUIClose:%1(%2,%3,%4) \
	forward ONGUIC_%1(%2,%3,%4); \
	public ONGUIC_%1(%2,%3,%4)

enum GUIPLAYERMENUINFO {
	bool:PlayerGUIActive,
	bool:PlayerGUIIsVisible,
	bool:IgnoreClose,
	PlayerGUICallFunc[20],
	bool:PlayerGUIUsed[MAX_PLAYER_ELEMENTS],
	PlayerGUIElementGroups[MAX_PLAYER_ELEMENTS],
	GUIMenu:PlayerTextDrawBinds[MAX_PLAYER_BINDS],
	PlayerText:PlayerGUIid[MAX_PLAYER_ELEMENTS],
	Float:PlayerGUIOffsetX[MAX_PLAYER_ELEMENTS],
	Float:PlayerGUIOffsetY[MAX_PLAYER_ELEMENTS],
}

// Store all GUI data
static PlayerGUIData[MAX_PLAYERS][MAX_PLAYER_GUI][GUIPLAYERMENUINFO];

// GUI order (last opened GUI's will close when when selectable is on)
static PlayerGUIOrderData[MAX_PLAYERS][MAX_PLAYER_GUI];

// Selection color player currently is using
static PlayerGUISelectionColor[MAX_PLAYERS];

// Ignore the next textdraw close (used internally)
static bool:IgnoreNextClose[MAX_PLAYERS];

static bool:SelectionOn[MAX_PLAYERS];

// Init playergui //////////////////////////////////////////////////////////////
public OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    for(new j = 0; j < MAX_PLAYER_GUI; j++)
		{
			PlayerGUIOrderData[i][j] = -1;
			for(new k = 0; k < MAX_PLAYER_BINDS; k++) { PlayerGUIData[i][j][PlayerTextDrawBinds][k] = INVALID_MENU_GUI; }
		}
	}

	#if defined PG_OnFilterScriptInit
		PG_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit PG_OnFilterScriptInit
#if defined PG_OnFilterScriptInit
	forward PG_OnFilterScriptInit();
#endif

////////////////////////////////////////////////////////////////////////////////

public OnFilterScriptExit()
{
	foreach(new i : Player)
	{
	    for(new j = 0; j < MAX_PLAYER_GUI; j++)
		{
		    if(PlayerGUIData[i][j][PlayerGUIActive]) PlayerGUIDestroy(i, PlayerGUIMenu:j);
			for(new k = 0; k < MAX_PLAYER_BINDS; k++) { PlayerGUIData[i][j][PlayerTextDrawBinds][k] = INVALID_MENU_GUI; }
		}
	}

	#if defined PG_OnFilterScriptExit
		PG_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit PG_OnFilterScriptExit
#if defined PG_OnFilterScriptExit
	forward PG_OnFilterScriptExit();
#endif

////////////////////////////////////////////////////////////////////////////////

public OnPlayerDisconnect(playerid, reason)
{
    for(new i = 0; i < MAX_PLAYER_GUI; i++)
	{
	    if(PlayerGUIData[playerid][i][PlayerGUIActive]) ResetPlayerGUIData(playerid, i);
	}

 	for(new i = 0; i < MAX_PLAYER_GUI; i++)
	{
		PlayerGUIOrderData[playerid][i] = -1;
		for(new j = 0; j < MAX_PLAYER_BINDS; j++) { PlayerGUIData[playerid][i][PlayerTextDrawBinds][j] = INVALID_MENU_GUI; }
	}

	IgnoreNextClose[playerid] = false;
	SelectionOn[playerid] = false;
	GUIPaused[playerid] = false;

	#if defined PG_OnPlayerDisconnect
		PG_OnPlayerDisconnect(playerid,reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect PG_OnPlayerDisconnect
#if defined PG_OnPlayerDisconnect
	forward PG_OnPlayerDisconnect(playerid,reason);
#endif

////////////////////////////////////////////////////////////////////////////////
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(!GUIPaused[playerid])
	{
		if(clickedid == Text:INVALID_TEXT_DRAW)
		{
			if(IgnoreNextClose[playerid])
			{
			    IgnoreNextClose[playerid] = false;
				SelectionOn[playerid] = false;
			    return 1;
			}
			if(GUIHideFirstInStack(playerid)) return 1;
		}
	}

	#if defined PG_OnPlayerClickTextDraw
		PG_OnPlayerClickTextDraw(playerid, Text:clickedid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw PG_OnPlayerClickTextDraw
#if defined PG_OnPlayerClickTextDraw
	forward PG_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

GUIHideFirstInStack(playerid)
{
	// Hide first visible in order stack
	for(new i = MAX_PLAYER_GUI - 1; i >= 0; i--)
	{
		if(PlayerGUIData[playerid][i][PlayerGUIIsVisible])
		{
			new CallFunc[32];
		    format(CallFunc, sizeof(CallFunc), "ONGUIC_%s", PlayerGUIData[playerid][i][PlayerGUICallFunc]);
		    CallLocalFunction(CallFunc, "iii", playerid, PlayerGUIData[playerid][i][PlayerGUIElementGroups], i);

			PlayerHideGUIMenu(playerid, PlayerGUIMenu:i, false);
			return 1;
		}
	}
	return 0;
}

////////////////////////////////////////////////////////////////////////////////


public GUIOnPCPDT(playerid, PlayerText:playertextid)
{
	if(!GUIPaused[playerid])
	{
		for(new i = 0; i < MAX_PLAYER_GUI; i++)
		{
	        if(PlayerGUIData[playerid][i][PlayerGUIActive])
	        {
				for(new j = 0; j < MAX_PLAYER_ELEMENTS; j++)
				{
				    if(PlayerGUIData[playerid][i][PlayerGUIUsed][j])
				    {
				        if(PlayerGUIData[playerid][i][PlayerGUIid][j] == playertextid)
				        {
				            new CallFunc[32];
				            format(CallFunc, sizeof(CallFunc), "ONGUIP_%s", PlayerGUIData[playerid][i][PlayerGUICallFunc]);
				            return CallLocalFunction(CallFunc, "iiii", playerid, PlayerGUIData[playerid][i][PlayerGUIElementGroups], i, j);
				        }
				    }
				}
	        }
		}
	}
	return 0;
}
////////////////////////////////////////////////////////////////////////////////

stock SetPlayerGUISelectionColor(playerid, color)
{
	PlayerGUISelectionColor[playerid] = color;
	return 1;
}

stock PlayerSelectGUITextDraw(playerid)
{
	SelectTextDraw(playerid, PlayerGUISelectionColor[playerid]);
	SelectionOn[playerid] = true;
	return 1;
}

stock PlayerCancelSelectGUITextDraw(playerid, bool:ignore = false)
{
	SelectionOn[playerid] = false;
	if(ignore) IgnoreNextClose[playerid] = true;
	CancelSelectTextDraw(playerid);
	return 1;
}

stock PlayerGUISelection(playerid) { return SelectionOn[playerid]; }

// Ignore a menu closing
stock PlayerGUIIgnoreClose(playerid, PlayerGUIMenu:gindex, bool:ignore)
{
    PlayerGUIData[playerid][_:gindex][IgnoreClose] = ignore;
	return 1;
}


// Apply a template array to a GUI
stock PlayerApplyGUIArray(playerid, PlayerGUIMenu:gindex, pindex, GUIType[GUIDEF], Float:xoffset = 0.0, Float:yoffset = 0.0)
{
	PlayerGUIValid(playerid, gindex, pindex);
	
	// Only text
	if(GUIType[GUIFont] < 4)
	{
	    xoffset += GUIType[GUITextSizeX];
	    yoffset += GUI_Y_OFFSET+GUIType[GUITextSizeY];
	}
	else
	{
	    xoffset = GUIType[GUITextSizeX];
	    yoffset = GUIType[GUITextSizeY];
	}

  	PlayerGUISetPlayerText(playerid, gindex, pindex, GUIType[GUIText]);
  	PlayerGUISetBackColor(playerid, gindex, pindex, GUIType[GUIBackColor]);
    PlayerGUISetFont(playerid, gindex, pindex, GUIType[GUIFont]);
	PlayerGUISetLetterSize(playerid, gindex, pindex, GUIType[GUILSizeX], GUIType[GUILSizeY]);
	PlayerGUISetColor(playerid, gindex, pindex, GUIType[GUIColor]);
	PlayerGUISetOutline(playerid, gindex, pindex, GUIType[GUIOutline]);
	PlayerGUISetProportional(playerid, gindex, pindex, GUIType[GUIProportional]);
	PlayerGUISetAlignment(playerid, gindex, pindex, GUIType[GUIAlignment]);
	PlayerGUISetShadow(playerid, gindex, pindex, GUIType[GUIShawdow]);

	if(GUIType[GUIBox])
	{
		PlayerGUISetBox(playerid, gindex, pindex, GUIType[GUIBox]);
		PlayerGUISetBoxColor(playerid, gindex, pindex, GUIType[GUIBoxColor]);
		PlayerGUISetTextSize(playerid, gindex, pindex, xoffset, yoffset);
	}

	if(GUIType[GUIPModel] > 0)
	{
		PlayerGUISetPreviewModel(playerid, gindex, pindex, GUIType[GUIPModel]);
		PlayerGUISetPreviewModelRot(playerid, gindex, pindex, GUIType[GUIPModelRX], GUIType[GUIPModelRY], GUIType[GUIPModelRZ], GUIType[GUIPModelZoom]);
	}
	
	PlayerGUISetSelectable(playerid, gindex, pindex, GUIType[GUISelect]);

	return 1;
}


// Bind textdraw to player textdraw will show/hide
stock PlayerBindGUITextDraw(playerid, PlayerGUIMenu:gindex, GUIMenu:tindex)
{
	for(new i = 0; i < MAX_PLAYER_BINDS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][i] == tindex)
		{
			print("ERROR: Textdraw is already bound to this players playertextdraw");
			return -1;
		}
	}

	for(new i = 0; i < MAX_PLAYER_BINDS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][i] == INVALID_MENU_GUI)
		{
			#if defined GUI_DEBUG
			    printf("PlayerBindGUITextDraw::playerid:%i PlayerGUIMenu:%i, GUIMenu:%i, Index:%i", playerid, _:gindex, _:tindex, i);
			#endif

		    PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][i] = tindex;
		    return i;
		}
	}
	print("ERROR: Tried to bind too many textdraws");
	return -1;
}

// Clear any bindines
stock PlayerClearBindTextDraw(playerid, PlayerGUIMenu:gindex, GUIMenu:tindex)
{
	for(new i = 0; i < MAX_PLAYER_BINDS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][i] == tindex)
		{
            HideGUIMenu(playerid, PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][i]);
			PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][i] = INVALID_MENU_GUI;
			return 0;
		}
	}
	print("ERROR: Textdraw was not bound to this players playertextdraw");
	return 0;
}


// Show the given menu
stock PlayerShowGUIMenu(playerid, PlayerGUIMenu:gindex, showbinds = true, bool:visible = true)
{
    PlayerGUIValidIndex(playerid, gindex);
	PlayerGUIData[playerid][_:gindex][PlayerGUIIsVisible] = visible;
	
	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i])
		{
			PlayerTextDrawShow(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][i]);
			// Show any binds
			if(showbinds)
			{
				for(new j = 0; j < MAX_PLAYER_BINDS; j++)
				{
				    if(PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][j] != INVALID_MENU_GUI) ShowGUIMenu(playerid, PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][j]);
				}
			}
		}
	}
	return 1;
}

// Hides all bound menus
stock PlayerHideAllGUIBindMenu(playerid, PlayerGUIMenu:gindex)
{
    PlayerGUIValidIndex(playerid, gindex);

	// Hide any binds
	for(new j = 0; j < MAX_PLAYER_BINDS; j++)
	{
	    if(PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][j] != INVALID_MENU_GUI) HideGUIMenu(playerid, PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][j]);
	}
	return 1;
}

// Hide the given menu
stock PlayerHideGUIMenu(playerid, PlayerGUIMenu:gindex, bool:visible = false)
{
    PlayerGUIValidIndex(playerid, gindex);
	PlayerGUIData[playerid][_:gindex][PlayerGUIIsVisible] = visible;

	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i]) PlayerTextDrawHide(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][i]);
		// Hide any binds
		for(new j = 0; j < MAX_PLAYER_BINDS; j++)
		{
		    if(PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][j] != INVALID_MENU_GUI) HideGUIMenu(playerid, PlayerGUIData[playerid][_:gindex][PlayerTextDrawBinds][j]);
		}
	}

	new count;
	for(new j = 0; j < MAX_PLAYER_GUI; j++)
	{
	    if(PlayerGUIData[playerid][j][PlayerGUIIsVisible])
		{
		    count++;
		    break;
		}
	}

	if(!PlayerGUIData[playerid][_:gindex][IgnoreClose] && count) PlayerSelectGUITextDraw(playerid);
 	else if(!PlayerGUIData[playerid][_:gindex][IgnoreClose] && count == 0) PlayerCancelSelectGUITextDraw(playerid);

	return 1;
}

// Update everything in a GUI menu
stock PlayerUpdateGUIMenu(playerid, PlayerGUIMenu:gindex, pindex)
{
    PlayerGUIValidIndex(playerid, gindex);
	// Hide all first
	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i]) PlayerTextDrawHide(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][i]);
	}
	// Now show all again
	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
		if(PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i]) PlayerTextDrawShow(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][i]);
	}
	return 1;
}

// Show the given menu element
stock PlayerShowGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
{
    PlayerGUIValid(playerid, gindex, pindex);
	PlayerTextDrawShow(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex]);
	return 1;
}

// Show the given menu element
stock PlayerHideGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
{
    PlayerGUIValid(playerid, gindex, pindex);
	PlayerTextDrawHide(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex]);
	return 1;
}

// Update GUI element
stock PlayerUpdateGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
{
    PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawHide(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex]);
    PlayerTextDrawShow(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex]);
	return 1;
}

// Create a new GUI menu
stock PlayerGUIMenu:PlayerCreateGUI(playerid, name[])
{
	for(new i = 0; i < MAX_PLAYER_GUI; i++)
	{
	    if(!PlayerGUIData[playerid][i][PlayerGUIActive])
		{
			#if defined GUI_DEBUG
				printf("PlayerGUIMenu::playerid: %i Tag Name: %s Index: %i", playerid, name, i);
			#endif

		    PlayerGUIData[playerid][i][PlayerGUIActive] = true;
			format(PlayerGUIData[playerid][i][PlayerGUICallFunc], FUNC_NAME_SIZE, "%s", name);
		    return PlayerGUIMenu:i;
		}
	}
	return INVALID_MENU_PLAYERGUI;
}

// Destroy a GUI menu
stock PlayerGUIDestroy(playerid, PlayerGUIMenu:gindex)
{
	PlayerGUIValidIndex(playerid, gindex);
	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
	    if(PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i])
		{
            PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i] = false;
            PlayerGUIData[playerid][_:gindex][PlayerGUIElementGroups][i] = 0;
            PlayerTextDrawDestroy(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][i]);
            PlayerGUIData[playerid][_:gindex][PlayerGUIOffsetX] = 0.0;
            PlayerGUIData[playerid][_:gindex][PlayerGUIOffsetY] = 0.0;
		}
	}
	PlayerGUIData[playerid][_:gindex][PlayerGUIActive] = false;
	return 1;
}

// Create a GUI element
stock PlayerCreateGUIElement(playerid, PlayerGUIMenu:gindex, GUIType[GUIDEF], Float:xoffset, Float:yoffset)
{
	PlayerGUIValidIndex(playerid, gindex);
	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
	    if(!PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i])
	    {
			PlayerGUIData[playerid][_:gindex][PlayerGUIid][i] = CreatePlayerTextDraw(playerid, GUI_X_OFFSET+GUIType[GUIOffX]+xoffset, GUI_Y_OFFSET+GUIType[GUIOffY]+yoffset, "_");
	        PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][i] = true;
			PlayerGUIData[playerid][_:gindex][PlayerGUIOffsetX][i] = GUI_X_OFFSET+GUIType[GUIOffX]+xoffset;
			PlayerGUIData[playerid][_:gindex][PlayerGUIOffsetY][i] = GUI_Y_OFFSET+GUIType[GUIOffY]+yoffset;


			#if defined GUI_DEBUG
			    printf("PlayerCreateGUIElement::playerid: %i gindex:%i Textdrawid: %i", playerid, _:gindex, _:PlayerGUIData[playerid][_:gindex][PlayerGUIid][i]);
			#endif

			return i;
	    }
	}
	printf("ERROR: Tried to created too many elements");
	return 0;
}


stock PlayerLoadGUIMenu(playerid, PlayerGUIMenu:gindex, const LoadArray[][GUIDEF], Float:xoffset, Float:yoffset, group, EPI[MAX_PLAYER_ELEMENTS+1], size = sizeof(LoadArray))
{
    for(new i = 0; i < size; i++)
	{
        EPI[i] = PlayerCreateGUIElement(playerid,gindex,LoadArray[i],xoffset, yoffset);
        PlayerSetGUIElementGroup(playerid,gindex,EPI[i],group);
        PlayerApplyGUIArray(playerid,gindex,EPI[i],LoadArray[i]);
	}
	return 1;
}


// Destroy a GUI element
stock PlayerDeleteGUIElement(playerid, PlayerGUIMenu:gindex, pindex)
{
    PlayerGUIValid(playerid, gindex, pindex);
    DestroyPlayerTextDraw(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex]);
	PlayerGUIData[playerid][_:gindex][PlayerGUIUsed][pindex] = false;
	return 1;
}

// Set GUI Element group
stock PlayerSetGUIElementGroup(playerid, PlayerGUIMenu:gindex, pindex, gval)
{
    PlayerGUIData[playerid][_:gindex][PlayerGUIElementGroups][pindex] = gval;
	return 1;
}


static ResetPlayerGUIData(playerid, gindex)
{
	for(new i = 0; i < MAX_PLAYER_ELEMENTS; i++)
	{
	    if(PlayerGUIData[playerid][gindex][PlayerGUIUsed][i])
		{
	        PlayerGUIData[playerid][gindex][PlayerGUIUsed][i] = false;
			PlayerGUIData[playerid][gindex][PlayerGUIElementGroups][i] = -1;
			PlayerGUIData[playerid][gindex][PlayerGUIOffsetX][i] = 0.0;
			PlayerGUIData[playerid][gindex][PlayerGUIOffsetY][i] = 0.0;
		}
	}

    PlayerGUIData[playerid][_:gindex][IgnoreClose] = false;
    PlayerGUIData[playerid][_:gindex][PlayerGUIActive] = false;
	return 1;
}

// Player textdraw functions
stock PlayerGUISetPlayerText(playerid, PlayerGUIMenu:gindex, pindex, text[])
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetString(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], text);
	return 1;
}

// Set a previewmodel
stock PlayerGUISetPreviewModel(playerid, PlayerGUIMenu:gindex, pindex, value)
{
   	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetPreviewModel(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

// Set a previewmodel
stock PlayerGUISetPreviewModelRot(playerid, PlayerGUIMenu:gindex, pindex, Float:rx, Float:ry, Float:rz, Float:zoom)
{
   	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetPreviewRot(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], rx, ry, rz, zoom);
	return 1;
}

stock PlayerGUISetBackColor(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawBackgroundColor(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetFont(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawFont(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetLetterSize(playerid, PlayerGUIMenu:gindex, pindex, Float:x, Float:y)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawLetterSize(playerid, PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], x, y);
	return 1;
}

stock PlayerGUISetColor(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, PlayerGUIMenu:gindex, pindex);
    PlayerTextDrawColor(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetOutline(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetOutline(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetProportional(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetProportional(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetAlignment(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawAlignment(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}


stock PlayerGUISetShadow(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetShadow(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetBox(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawUseBox(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetBoxColor(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawBoxColor(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}

stock PlayerGUISetTextSize(playerid, PlayerGUIMenu:gindex, pindex, Float:x, Float:y)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawTextSize(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], x, y);
	return 1;
}

stock PlayerGUISetSelectable(playerid, PlayerGUIMenu:gindex, pindex, value)
{
	PlayerGUIValid(playerid, gindex, pindex);
    PlayerTextDrawSetSelectable(playerid,PlayerGUIData[playerid][_:gindex][PlayerGUIid][pindex], value);
	return 1;
}
