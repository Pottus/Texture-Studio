/*
ApplyGUIArray(GUIMenu:gindex, pindex, GUIType, useoffset = 0, Float:xoffset = 0.0, Float:yoffset = 0.0)
LoadGUIMenu(MenuArray,GUIMenu:gindex,xoffset, yoffset, textsizeoffsetx, textsizeoffsety);
ShowGUIMenu(GUIMenu:gindex)
HideGUIMenu(GUIMenu:gindex)
ShowGUIElement(GUIMenu:gindex, pindex)
HideGUIElement(GUIMenu:gindex, pindex)
GUIMenu:CreateGUI(id)
GUIDestroy(GUIMenu:gindex)
CreateGUIElement(GUIMenu:gindex, GUIType[GUIDEF], Float:xoffset, Float:yoffset)
DeleteGUIElement(GUIMenu:gindex, pindex)
UpdateGUIMenu(GUIMenu:gindex, pindex)
UpdateGUIElement(GUIMenu:gindex, pindex)

// Setter functions
GUISetPlayerText(GUIMenu:gindex, pindex, GUIType[GUIText])
GUISetBackColor(GUIMenu:gindex, pindex, GUIType[GUIBackColor])
GUISetFont(GUIMenu:gindex, pindex, GUIType[GUIFont])
GUISetLetterSize(GUIMenu:gindex, pindex, GUIType[GUILSizeX], GUIType[GUILSizeY])
GUISetColor(GUIMenu:gindex, pindex, GUIType[GUIColor])
GUISetOutline(GUIMenu:gindex, pindex, GUIType[GUIOutline])
GUISetProportional(GUIMenu:gindex, pindex, GUIType[GUIProportional])
GUISetShadow(GUIMenu:gindex, pindex, GUIType[GUIShawdow])
GUISetBox(GUIMenu:gindex, pindex, GUIType[GUIBox])
GUISetBoxColor(GUIMenu:gindex, pindex, GUIType[GUIBoxColor])
GUISetTextSize(GUIMenu:gindex, pindex, xoffset, yoffset)
GUISetSelectable(GUIMenu:gindex, pindex, GUIType[GUISelect])
GUISetPreviewModel(GUIMenu:gindex, pindex, value)
GUISetPreviewModelRot(gindex, pindex, GUIType[GUIPModelRX], GUIType[GUIPModelRY], GUIType[GUIPModelRZ], GUIType[GUIPModelZoom]);
*/

// Slices fix pasing const to TextDrawSetString
native TextDrawSetStringC(Text:text, const string[]) = TextDrawSetString;

// Valid check
#define GUIValid(%0,%1) if(!GUIData[_:%0][GUIActive]) return 0;\
	if(!GUIData[_:%0][GUIUsed][%1]) return 0
#define GUIValidIndex(%0) if(!GUIData[_:%0][GUIActive]) return 0
#define GUIValidElement(%0,%1) if(!GUIData[_:%0][GUIUsed][%1]) return 0

// Called when a player clicks a textdraw
#define OnGUIClick:%1(%2,%3,%4,%5) \
	forward ONGUI_%1(%2,%3,%4,%5); \
	public ONGUI_%1(%2,%3,%4,%5)

enum GUIMENUINFO {
	bool:GUIActive,
	GUICallFunc[20],
	bool:GUIUsed[MAX_ELEMENTS],
	GUIElementGroups[MAX_ELEMENTS],
	Text:GUIid[MAX_ELEMENTS],
	Float:GUIOffsetX[MAX_ELEMENTS],
	Float:GUIOffsetY[MAX_ELEMENTS],
}

static GUIData[MAX_GUI][GUIMENUINFO];

public OnFilterScriptExit()
{
    for(new i = 0; i < MAX_GUI; i++)
	{
		if(GUIData[i][GUIActive])
		{
			DestroyGUI(GUIMenu:i);
		}
	}

	#if defined GI_OnFilterScriptExit
		GI_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit GI_OnFilterScriptExit
#if defined GI_OnFilterScriptExit
	forward GI_OnFilterScriptExit();
#endif

////////////////////////////////////////////////////////////////////////////////
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(!GUIPaused[playerid])
	{
		if(clickedid != Text:INVALID_TEXT_DRAW)
		{
			for(new i = 0; i < MAX_GUI; i++)
			{
		        if(GUIData[i][GUIActive])
		        {
					for(new j = 0; j < MAX_ELEMENTS; j++)
					{
					    if(GUIData[i][GUIUsed][j])
					    {
					        if(GUIData[i][GUIid][j] == clickedid)
					        {
								#if defined GUI_DEBUG
									printf("Playerid:%i ElementGroup:%i  gindex:%i pindex:%i", playerid, GUIData[i][GUIElementGroups][j], i, j);
								#endif
								
					            new CallFunc[32];
					            format(CallFunc, sizeof(CallFunc), "ONGUI_%s", GUIData[i][GUICallFunc]);

								#if defined GUI_DEBUG
									printf(CallFunc);
								#endif
					            CallLocalFunction(CallFunc, "iiii", playerid, GUIData[i][GUIElementGroups][j], i, j);
					        }
					    }
					}
		        }
			}
		}
	}

	#if defined GI_OnPlayerClickTextDraw
		GI_OnPlayerClickTextDraw(playerid, Text:clickedid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw GI_OnPlayerClickTextDraw
#if defined GI_OnPlayerClickTextDraw
	forward GI_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

////////////////////////////////////////////////////////////////////////////////

// Apply a template array to a GUI
stock ApplyGUIArray(GUIMenu:gindex, pindex, const GUIType[GUIDEF], Float:xoffset = 0.0, Float:yoffset = 0.0)
{
	GUIValid(gindex, pindex);

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

  	GUISetPlayerText(gindex, pindex, GUIType[GUIText]);
  	GUISetBackColor(gindex, pindex, GUIType[GUIBackColor]);
    GUISetFont(gindex, pindex, GUIType[GUIFont]);
	GUISetLetterSize(gindex, pindex, GUIType[GUILSizeX], GUIType[GUILSizeY]);
	GUISetColor(gindex, pindex, GUIType[GUIColor]);
	GUISetOutline(gindex, pindex, GUIType[GUIOutline]);
	GUISetProportional(gindex, pindex, GUIType[GUIProportional]);
	GUISetAlignment(gindex, pindex, GUIType[GUIAlignment]);
	GUISetShadow(gindex, pindex, GUIType[GUIShawdow]);

	if(GUIType[GUIBox])
	{
		GUISetBox(gindex, pindex, GUIType[GUIBox]);
		GUISetBoxColor(gindex, pindex, GUIType[GUIBoxColor]);
		GUISetTextSize(gindex, pindex, xoffset, yoffset);
	}

	if(GUIType[GUIPModel] > -1)
	{
		GUISetPreviewModel(gindex, pindex, GUIType[GUIPModel]);
		GUISetPreviewModelRot(gindex, pindex, GUIType[GUIPModelRX], GUIType[GUIPModelRY], GUIType[GUIPModelRZ], GUIType[GUIPModelZoom]);
	}
	
	GUISetSelectable(gindex, pindex, GUIType[GUISelect]);

	return 1;
}

// Show the given menu
stock ShowGUIMenu(playerid, GUIMenu:gindex)
{
    GUIValidIndex(gindex);
	for(new i = 0; i < MAX_ELEMENTS; i++)
	{
		if(GUIData[_:gindex][GUIUsed][i]) TextDrawShowForPlayer(playerid, GUIData[_:gindex][GUIid][i]);
	}
	return 1;

}

// Hide the given menu
stock HideGUIMenu(playerid, GUIMenu:gindex)
{
    GUIValidIndex(gindex);
	for(new i = 0; i < MAX_ELEMENTS; i++)
	{
		if(GUIData[_:gindex][GUIUsed][i]) TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][i]);
	}
	return 1;
}

// Update everything in a GUI menu
stock UpdateGUIMenu(playerid, GUIMenu:gindex, pindex)
{
    GUIValidIndex(gindex);
	// Hide all first
	for(new i = 0; i < MAX_ELEMENTS; i++)
	{
		if(GUIData[_:gindex][GUIUsed][i]) TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][i]);
	}
	// Now show all again
	for(new i = 0; i < MAX_ELEMENTS; i++)
	{
		if(GUIData[_:gindex][GUIUsed][i]) TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][i]);
	}
	return 1;
}

stock LoadGUIMenu(GUIMenu:gindex, const LoadArray[][GUIDEF], Float:xoffset, Float:yoffset, group, EPI[MAX_ELEMENTS+1], size = sizeof(LoadArray))
{
    for(new i = 0; i < size; i++)
	{
        EPI[i] = CreateGUIElement(gindex,LoadArray[i],xoffset, yoffset);
        SetGUIElementGroup(gindex,EPI[i],group);
        ApplyGUIArray(gindex,EPI[i],LoadArray[i], xoffset, yoffset);
	}
	return 1;
}

stock LoadGUIElement(GUIMenu:gindex, const LoadArray[GUIDEF], Float:xoffset, Float:yoffset)
{
	new element = CreateGUIElement(gindex, LoadArray, xoffset, yoffset);
	ApplyGUIArray(gindex,element,LoadArray,xoffset,yoffset);
	return element;
}

// Show the given menu element
stock ShowGUIElement(playerid, GUIMenu:gindex, pindex)
{
    GUIValid(gindex, pindex);
	TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][pindex]);
	return 1;
}

// Hide the given menu element
stock HideGUIElement(playerid, GUIMenu:gindex, pindex)
{
    GUIValid(gindex, pindex);
	TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][pindex]);
	return 1;
}

// Update GUI element
stock UpdateGUIElement(playerid, GUIMenu:gindex, pindex)
{
    GUIValid(gindex, pindex);
    TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][pindex]);
    TextDrawHideForPlayer(playerid, GUIData[_:gindex][GUIid][pindex]);
	return 1;
}

// Set GUI Element group
stock SetGUIElementGroup(GUIMenu:gindex, pindex, gval)
{
    GUIData[_:gindex][GUIElementGroups][pindex] = gval;
	return 1;
}

// Create a new GUI menu
stock GUIMenu:CreateGUI(name[])
{
	for(new i = 0; i < MAX_GUI; i++)
	{
	    if(!GUIData[i][GUIActive])
		{
		    GUIData[i][GUIActive] = true;
			format(GUIData[i][GUICallFunc], FUNC_NAME_SIZE, "%s", name);
		    return GUIMenu:i;
		}
	}
	return INVALID_MENU_GUI;
}

// Destroy a GUI menu
stock DestroyGUI(GUIMenu:gindex)
{
	GUIValidIndex(gindex);
	
	for(new i = 0; i < MAX_ELEMENTS; i++)
	{
	    if(GUIData[_:gindex][GUIUsed][i])
		{
			foreach(new j : Player) TextDrawHideForPlayer(j, GUIData[_:gindex][GUIid][i]);
            GUIData[_:gindex][GUIUsed][i] = false;
            GUIData[_:gindex][GUIElementGroups][i] = 0;
            TextDrawDestroy(GUIData[_:gindex][GUIid][i]);
            GUIData[_:gindex][GUIOffsetX] = 0.0;
            GUIData[_:gindex][GUIOffsetY] = 0.0;
	}
	}
	GUIData[_:gindex][GUIActive] = false;
	return 1;
}

// Create a GUI element
stock CreateGUIElement(GUIMenu:gindex, const GUIType[GUIDEF], Float:xoffset = 0.0, Float:yoffset = 0.0)
{
	GUIValidIndex(gindex);
	for(new i = 0; i < MAX_ELEMENTS; i++)
	{
	    if(!GUIData[_:gindex][GUIUsed][i])
	    {
	        GUIData[_:gindex][GUIid][i] = TextDrawCreate(GUI_X_OFFSET+GUIType[GUIOffX]+xoffset, GUI_Y_OFFSET+GUIType[GUIOffY]+yoffset, "_");
	        GUIData[_:gindex][GUIUsed][i] = true;
			GUIData[_:gindex][GUIOffsetX][i] = GUI_X_OFFSET+GUIType[GUIOffX]+xoffset;
			GUIData[_:gindex][GUIOffsetY][i] = GUI_Y_OFFSET+GUIType[GUIOffY]+yoffset;
			return i;
	    }
	}
	printf("ERROR: Tried to created too many elements");
	return 0;
}

// Destroy a GUI element
stock DeleteMenuElement(GUIMenu:gindex, pindex)
{
    GUIValid(gindex, pindex);
    DestroyTextDraw(playerid, GUIData[_:gindex][GUIid][pindex]);
	GUIData[_:gindex][GUIUsed][pindex] = false;
	return 1;
}

// Player textdraw functions
stock GUISetPlayerText(GUIMenu:gindex, pindex, const text[])
{
 	GUIValid(gindex, pindex);
    TextDrawSetStringC(GUIData[_:gindex][GUIid][pindex], text);
	return 1;
}

// Set a previewmodel
stock GUISetPreviewModel(GUIMenu:gindex, pindex, value)
{
   	GUIValid(gindex, pindex);
    TextDrawSetPreviewModel(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

// Set a previewmodel
stock GUISetPreviewModelRot(GUIMenu:gindex, pindex, Float:rx, Float:ry, Float:rz, Float:zoom)
{
   	GUIValid(gindex, pindex);
    TextDrawSetPreviewRot(GUIData[_:gindex][GUIid][pindex], rx, ry, rz, zoom);
	return 1;
}

stock GUISetBackColor(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawBackgroundColor(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetFont(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawFont(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetLetterSize(GUIMenu:gindex, pindex, Float:x, Float:y)
{
	GUIValid(gindex, pindex);
    TextDrawLetterSize(GUIData[_:gindex][GUIid][pindex], x, y);
	return 1;
}

stock GUISetColor(GUIMenu:gindex, pindex, value)
{
	GUIValid(GUIMenu:gindex, pindex);
    TextDrawColor(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetOutline(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawSetOutline(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetProportional(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawSetProportional(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetAlignment(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawAlignment(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}


stock GUISetShadow(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawSetShadow(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetBox(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawUseBox(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetBoxColor(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawBoxColor(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}

stock GUISetTextSize(GUIMenu:gindex, pindex, Float:x, Float:y)
{
	GUIValid(gindex, pindex);
    TextDrawTextSize(GUIData[_:gindex][GUIid][pindex], x, y);
	return 1;
}

stock GUISetSelectable(GUIMenu:gindex, pindex, value)
{
	GUIValid(gindex, pindex);
    TextDrawSetSelectable(GUIData[_:gindex][GUIid][pindex], value);
	return 1;
}
