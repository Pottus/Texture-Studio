
#undef MAX_PLAYERS
#define MAX_PLAYERS 10

// 420 Colors
#define         STEALTH_GREEN          0x33DD1100
#define         STEALTH_ORANGE         0xFF880000
#define         STEALTH_YELLOW         0xFFFF00AA

// Define preview states
#define         PREVIEW_STATE_NONE              0
#define         PREVIEW_STATE_ALLTEXTURES       1
#define         PREVIEW_STATE_THEME             2
#define         PREVIEW_STATE_SEARCH            3

// Default player texture when slot is empty
#define         DEFAULT_TEXTURE                 6375

// enum for menu data
enum MENU3DINFO
{
    TPreviewState,
	CurrTexturePage,
    Menus3D,
    CurrThemePage,
    CurrSearchPage,
    PlayerText:Menu3D_Model_Info,
}

// Menu Data
new Menu3DData[MAX_PLAYERS][MENU3DINFO];

static PlayerThemeIndex[MAX_PLAYERS][sizeof(ObjectTextures)];
static PlayerThemeCount[MAX_PLAYERS];
static PlayerSearchIndex[MAX_PLAYERS][sizeof(ObjectTextures)];
static PlayerSearchResults[MAX_PLAYERS];


static Text:Click_SetTexture[16];
static Text:Click_ClearTexture[16];
static Text:Click_SetColor[16];
static Text:Click_CloseTexture;

static PlayerText:Player_TextureInfo[MAX_PLAYERS][MAX_MATERIALS];
static PlayerText:Click_TextureAll[MAX_PLAYERS];

static bool:SelectingTexture[MAX_PLAYERS];
static bool:TextureAll[MAX_PLAYERS];

static CurrTexturingIndex[MAX_PLAYERS];


Float: GetPlayerCameraFacingAngle(playerid)
{
    new Float: vX, Float: vY;
    if(GetPlayerCameraFrontVector(playerid, vX, vY, Float: playerid))
	{
        if((vX = -atan2(vX, vY)) < 0.0) return vX + 360.0;
        return vX;
    }
    return 0.0;
}

sqlite_ThemeSetup()
{
	new DBResult:r = db_query(ThemeDataDB, "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'default_theme'");

	if(!db_num_rows(r))
	{
		db_query(ThemeDataDB, "CREATE TABLE IF NOT EXISTS `default_theme` (TIndex INTEGER)");
		db_query(ThemeDataDB, "INSERT INTO `default_theme` (`TIndex`) VALUES(455)");
		db_query(ThemeDataDB, "INSERT INTO `default_theme` (`TIndex`) VALUES(463)");
	}
	db_free_result(r);
	
	foreach(new i : Player)
	{
        PlayerThemeCount[i] = 0;
	    LoadPlayerTheme(i, "default_theme");
	}
	
	return 1;
}

// Delete for include
public OnFilterScriptInit()
{
	foreach(new i : Player)
	{
	    InitText3DDraw(i);
		InitPlayerTextureInfo(i);
	}

	new Float:ypos = 100.0;

	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		// Will set the currently selected texture
		Click_SetTexture[i] = TextDrawCreate(40.000000, ypos, "LD_BEAT:square");
		TextDrawBackgroundColor(Click_SetTexture[i], 255);
		TextDrawFont(Click_SetTexture[i], 4);
		TextDrawLetterSize(Click_SetTexture[i], 0.500000, 1.000000);
		TextDrawColor(Click_SetTexture[i], 16711935);
		TextDrawSetOutline(Click_SetTexture[i], 0);
		TextDrawSetProportional(Click_SetTexture[i], 1);
		TextDrawSetShadow(Click_SetTexture[i], 1);
		TextDrawUseBox(Click_SetTexture[i], 1);
		TextDrawBoxColor(Click_SetTexture[i], 255);
		TextDrawTextSize(Click_SetTexture[i], 10.000000, 10.000000);

		TextDrawSetSelectable(Click_SetTexture[i], 1);

		// Will set the currently selected color
		Click_SetColor[i] = TextDrawCreate(25.000000, ypos, "LD_BEAT:square");
		TextDrawBackgroundColor(Click_SetColor[i], 255);
		TextDrawFont(Click_SetColor[i], 4);
		TextDrawLetterSize(Click_SetColor[i], 0.500000, 1.000000);
		TextDrawColor(Click_SetColor[i], 0x33CCFFFF);
		TextDrawSetOutline(Click_SetColor[i], 0);
		TextDrawSetProportional(Click_SetColor[i], 1);
		TextDrawSetShadow(Click_SetColor[i], 1);
		TextDrawUseBox(Click_SetColor[i], 1);
		TextDrawBoxColor(Click_SetColor[i], 255);
		TextDrawTextSize(Click_SetColor[i], 10.000000, 10.000000);

		TextDrawSetSelectable(Click_SetColor[i], 1);

		// Will set the currently selected color
		Click_ClearTexture[i] = TextDrawCreate(10.000000, ypos, "LD_BEAT:square");
		TextDrawBackgroundColor(Click_ClearTexture[i], 255);
		TextDrawFont(Click_ClearTexture[i], 4);
		TextDrawLetterSize(Click_ClearTexture[i], 0.500000, 1.000000);
		TextDrawColor(Click_ClearTexture[i], 0xFF0000FF);
		TextDrawSetOutline(Click_ClearTexture[i], 0);
		TextDrawSetProportional(Click_ClearTexture[i], 1);
		TextDrawSetShadow(Click_ClearTexture[i], 1);
		TextDrawUseBox(Click_ClearTexture[i], 1);
		TextDrawBoxColor(Click_ClearTexture[i], 255);
		TextDrawTextSize(Click_ClearTexture[i], 10.000000, 10.000000);

		TextDrawSetSelectable(Click_ClearTexture[i], 1);

		ypos += 15.0;
	}
	
	
	Click_CloseTexture = TextDrawCreate(57.000000, ypos, "Close");
	TextDrawBackgroundColor(Click_CloseTexture, 255);
	TextDrawFont(Click_CloseTexture, 2);
	TextDrawLetterSize(Click_CloseTexture, 0.200000, 1.000000);
	TextDrawColor(Click_CloseTexture, -1);
	TextDrawSetOutline(Click_CloseTexture, 1);
	TextDrawSetProportional(Click_CloseTexture, 1);
	TextDrawUseBox(Click_CloseTexture, 1);
	TextDrawBoxColor(Click_CloseTexture, 0);
	TextDrawTextSize(Click_CloseTexture, 80.000000, 10.000000);
	TextDrawSetSelectable(Click_CloseTexture, 1);

	#if defined TV_OnFilterScriptInit
		TV_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit TV_OnFilterScriptInit
#if defined TV_OnFilterScriptInit
	forward TV_OnFilterScriptInit();
#endif


public OnFilterScriptExit()
{
	foreach(new i : Player)
	{
    	// Close tool if it's open
		if(Menu3DData[i][TPreviewState] == PREVIEW_STATE_ALLTEXTURES)
		{
			CancelSelect3DMenu(i);
			Destroy3DMenu(Menu3DData[i][Menus3D]);
			Menu3DData[i][TPreviewState] = PREVIEW_STATE_NONE;
	    }
	    
		for(new j = 0; j < MAX_MATERIALS; j++)
		{
			PlayerTextDrawDestroy(i, Player_TextureInfo[i][j]);
			PlayerTextDrawDestroy(i, Click_TextureAll[i]);
		}

		PlayerTextDrawDestroy(i, Menu3DData[i][Menu3D_Model_Info]);
	}
	
	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		TextDrawDestroy(Click_SetTexture[i]);
		TextDrawDestroy(Click_ClearTexture[i]);
		TextDrawDestroy(Click_SetColor[i]);
	}
	
	TextDrawDestroy(Click_CloseTexture);

	#if defined TV_OnFilterScriptExit
		TV_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit TV_OnFilterScriptExit
#if defined TV_OnFilterScriptExit
	forward TV_OnFilterScriptExit();
#endif


// Hook for include
public OnPlayerConnect(playerid)
{
	InitText3DDraw(playerid);
	InitPlayerTextureInfo(playerid);
	PlayerThemeCount[playerid] = 0;
	LoadPlayerTheme(playerid, "default_theme");
	// Create texture editor

	#if defined TV_OnPlayerConnect
		TV_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect TV_OnPlayerConnect
#if defined TV_OnPlayerConnect
	forward TV_OnPlayerConnect(playerid);
#endif

InitText3DDraw(playerid)
{
	Menu3DData[playerid][Menu3D_Model_Info] = CreatePlayerTextDraw(playerid,630.000000, 400.000000, "Model: TXD: Texture:");
	PlayerTextDrawAlignment(playerid,Menu3DData[playerid][Menu3D_Model_Info], 3);
	PlayerTextDrawBackgroundColor(playerid,Menu3DData[playerid][Menu3D_Model_Info], 255);
	PlayerTextDrawFont(playerid,Menu3DData[playerid][Menu3D_Model_Info], 2);
	PlayerTextDrawLetterSize(playerid,Menu3DData[playerid][Menu3D_Model_Info], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Menu3DData[playerid][Menu3D_Model_Info], 16711935);
	PlayerTextDrawSetOutline(playerid,Menu3DData[playerid][Menu3D_Model_Info], 1);
	PlayerTextDrawSetProportional(playerid,Menu3DData[playerid][Menu3D_Model_Info], 1);
	PlayerTextDrawSetSelectable(playerid,Menu3DData[playerid][Menu3D_Model_Info], 0);
	return 1;
}

// Player disconnected
public OnPlayerDisconnect(playerid, reason)
{
	// Out of preview state
    Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_NONE;
	CancelSelect3DMenu(playerid);
	
	// Did the player have a menu?
	if(Menu3DData[playerid][Menus3D] != INVALID_3DMENU)
	{
		// Destroy it
        Destroy3DMenu(Menu3DData[playerid][Menus3D]);
        Menu3DData[playerid][Menus3D] = INVALID_3DMENU;
	}
	
	SelectingTexture[playerid] = false;
	TextureAll[playerid] = false;
    CurrTexturingIndex[playerid] = 0;

	#if defined TV_OnPlayerDisconnect
		TV_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect TV_OnPlayerDisconnect
#if defined TV_OnPlayerDisconnect
	forward TV_OnPlayerDisconnect(playerid, reason);
#endif

static BitArray:FoundTextures<(sizeof(ObjectTextures) + 1)>, sFoundTextures[4096];
YCMD:tsearch(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Search for texture indexes by keyword.");
		return 1;
	}

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a texture search string");

    new line[128];
	new numfound, lastpage, page;

	inline TexSearch(pid, dialogid, response, listitem, string:text[])
	{
        #pragma unused listitem, dialogid, pid, text
		if(response)
		{
			if(!strcmp(text, "Next Page ->"))
				page++;
			else if(!strcmp(text, "Previous Page <-"))
				page--;
			
			if(page != lastpage)
			{
				sFoundTextures[0] = '\0';
				
				if(page)
					strcat(sFoundTextures, "{00CC00}Previous Page <-{FFFFFF}\n");
				
				for(new i, j; i < sizeof(ObjectTextures); i++)
				{
					if(Bit_Get(FoundTextures, i))
					{
						if((page * 100) < j < ((page + 1) * 100) + 1)
						{
							strcat(sFoundTextures, sprintf("%i:%s\n", i, ObjectTextures[i][TextureName]));
							
							if(j == ((page + 1) * 100))
							{
								strcat(sFoundTextures, "{00CC00}Next Page ->");
								break;
							}
						}
						j++;
					}
				}
				
				lastpage = page;
				Dialog_ShowCallback(playerid, using inline TexSearch, DIALOG_STYLE_LIST, "Texture Studio - Texture Search", sFoundTextures, "Ok", "Cancel");
			}
			else
			{
				new index;
				sscanf(text, "p<:>i", index);
				format(line, sizeof(line), "/mtextures %i", index);
				BroadcastCommand(playerid, line);
			}
		}
	}


    Bit_SetAll(FoundTextures, false);
	sFoundTextures[0] = '\0';
	for(new i = 0; i < sizeof(ObjectTextures); i++)
	{
	    if(strfind(ObjectTextures[i][TextureName], arg, true) > -1)
 	    {
			//strcat(sFoundTextures, sprintf("%i:%s\n", i, ObjectTextures[i][TextureName]));
	        Bit_Let(FoundTextures, i);
			numfound++;
	        //if(numfound == 100) break;
	    }
	}
	if(numfound)
	{
		format(line, sizeof(line), "Found %i textures", numfound);
		SendClientMessage(playerid, STEALTH_GREEN, line);
		
		for(new i, j; i < sizeof(ObjectTextures); i++)
		{
			if(Bit_Get(FoundTextures, i))
			{
				strcat(sFoundTextures, sprintf("%i:%s\n", i, ObjectTextures[i][TextureName]));
				
				j++;
				if(j == 100)
				{
					strcat(sFoundTextures, "Next Page ->");
					break;
				}
			}
		}
		
		Dialog_ShowCallback(playerid, using inline TexSearch, DIALOG_STYLE_LIST, "Texture Studio - Texture Search", sFoundTextures, "Ok", "Cancel");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "No textures found with that string");
	return 1;
}

// All texture mode
YCMD:mtextures(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Open 3D texture viewer.");
		SendClientMessage(playerid, STEALTH_YELLOW, "Controls on-foot:");
		SendClientMessage(playerid, STEALTH_GREEN, "    Y - Last Texture, H - Next Texture");
		SendClientMessage(playerid, STEALTH_GREEN, "    Num 4 - Last Page, Num 6 - Next Page");
		SendClientMessage(playerid, STEALTH_YELLOW, "Controls in flymode:");
		SendClientMessage(playerid, STEALTH_GREEN, "    Enter + Num 4 - Last Texture, Enter + Num 6 - Next Texture");
		SendClientMessage(playerid, STEALTH_GREEN, "    Num 4 - Last Page, Num 6 - Next Page");
		return 1;
	}

	new index = strval(arg);
	if(index < 1 || index > sizeof(ObjectTextures) - 1) Menu3DData[playerid][CurrTexturePage] = 0;
	else
	{
		Menu3DData[playerid][CurrTexturePage] = (index - 1) / 16;
		Select3DMenuBox(playerid, Menu3DData[playerid][Menus3D], (index - 1) % 16);
	}
	
	// No menu created yet
	if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_NONE)
	{
	    CreateTexViewer(playerid);
        Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_ALLTEXTURES;
		
		// Update textures
		for(new i = 0; i < 16; i++)
		{
		    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TModel],ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TXDName],ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TextureName], 0xFFFFFFFF, 0xFF999999);
		}

		// Update the info texdraw
		UpdateTextureInfo(playerid, SelectedBox[playerid]);

   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Texture selection tool opened - All Textures");
		SendClientMessage(playerid, STEALTH_GREEN, "View /thelp for texture selection controls");

	}
	
	// Menu was open update to next slot
	else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_ALLTEXTURES)
	{
		if(index == 0) DestroyTexViewer(playerid);
		else
		{
			for(new i = 0; i < 16; i++)
			{
			    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TModel],ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TXDName],ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TextureName], 0xFFFFFFFF, 0xFF999999);
			}

			UpdateTextureInfo(playerid, SelectedBox[playerid]);

	   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "Texture selection slot changed - All Textures");
		}
	}
	else if(Menu3DData[playerid][TPreviewState] !=  PREVIEW_STATE_ALLTEXTURES)
	{
        Menu3DData[playerid][CurrTexturePage] = 0;
		Select3DMenu(playerid, Menu3DData[playerid][Menus3D]);
		
		for(new i = 0; i < 16; i++)
		{
		    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TModel],ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TXDName],ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TextureName], 0xFFFFFFFF, 0xFF999999);
		}

		Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_ALLTEXTURES;

		UpdateTextureInfo(playerid, SelectedBox[playerid]);

   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Switched to viewing all textures");
	}

	return 1;
}


YCMD:ttextures(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "View a saved set of textures in the 3D texture viewer.");
		SendClientMessage(playerid, STEALTH_YELLOW, "Controls on-foot:");
		SendClientMessage(playerid, STEALTH_GREEN, "    Y - Last Texture, H - Next Texture");
		SendClientMessage(playerid, STEALTH_GREEN, "    Num 4 - Last Page, Num 6 - Next Page");
		SendClientMessage(playerid, STEALTH_YELLOW, "Controls in flymode:");
		SendClientMessage(playerid, STEALTH_GREEN, "    Enter + Num 4 - Last Texture, Enter + Num 6 - Next Texture");
		SendClientMessage(playerid, STEALTH_GREEN, "    Num 4 - Last Page, Num 6 - Next Page");
		return 1;
	}

	new index = strval(arg);
	if(!strlen(arg) || index <= 15 || index >= PlayerThemeCount[playerid]) Menu3DData[playerid][CurrThemePage] = 0;
	else
	{
		Menu3DData[playerid][CurrThemePage] = (index - 1) / 16;
		Select3DMenuBox(playerid, Menu3DData[playerid][Menus3D], (index - 1) % 16);
	}

	// No menu created yet
	if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_NONE)
	{
	    CreateTexViewer(playerid);
        Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_THEME;

        UpdateThemeTextures(playerid);

		// Update the info texdraw
		UpdateTextureInfo(playerid, SelectedBox[playerid]);

   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Texture selection tool opened - Theme Textures");
		SendClientMessage(playerid, STEALTH_GREEN, "View /thelp for texture selection controls");
	}
   	else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_THEME)
	{
		if(index == 0) DestroyTexViewer(playerid);
		else
		{
            UpdateThemeTextures(playerid);
			UpdateTextureInfo(playerid, SelectedBox[playerid]);

	   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "Texture selection slot changed - All Textures");
		}
	}
	else if(Menu3DData[playerid][TPreviewState] != PREVIEW_STATE_THEME)
	{
        Menu3DData[playerid][CurrTexturePage] = 0;
		Select3DMenu(playerid, Menu3DData[playerid][Menus3D]);
        
		Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_THEME;

        UpdateThemeTextures(playerid);
   		UpdateTextureInfo(playerid, SelectedBox[playerid]);

   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Switched to viewing theme textures");
	}

	return 1;
}

YCMD:mtsearch(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Same as /tsearch, but in the 3D texture viewer.");
		SendClientMessage(playerid, STEALTH_YELLOW, "Controls on-foot:");
		SendClientMessage(playerid, STEALTH_GREEN, "    Y - Last Texture, H - Next Texture");
		SendClientMessage(playerid, STEALTH_GREEN, "    Num 4 - Last Page, Num 6 - Next Page");
		SendClientMessage(playerid, STEALTH_YELLOW, "Controls in flymode:");
		SendClientMessage(playerid, STEALTH_GREEN, "    Enter + Num 4 - Last Texture, Enter + Num 6 - Next Texture");
		SendClientMessage(playerid, STEALTH_GREEN, "    Num 4 - Last Page, Num 6 - Next Page");
		return 1;
	}

	if(isnull(arg)) DestroyTexViewer(playerid);

	PlayerSearchResults[playerid] = 0;
	for(new i = 0; i < sizeof(ObjectTextures); i++)
	{
	    if(strfind(ObjectTextures[i][TextureName], arg, true) > -1)
 	    {
			PlayerSearchIndex[playerid][PlayerSearchResults[playerid]] = i;
			PlayerSearchResults[playerid]++;
	    }
		else PlayerSearchIndex[playerid][i] = -1;
	}
	
	if(PlayerSearchResults[playerid])
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, sprintf("Found %i textures", PlayerSearchResults[playerid]));
		
		if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_NONE)
		{
			CreateTexViewer(playerid);
			Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_SEARCH;

			UpdateSearchTextures(playerid);
			UpdateTextureInfo(playerid, SelectedBox[playerid]);

			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "Texture selection tool opened - Search Results");
			SendClientMessage(playerid, STEALTH_GREEN, "View /thelp for texture selection controls");
		}
		else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_SEARCH)
		{
			Menu3DData[playerid][CurrTexturePage] = 0;
			Select3DMenu(playerid, Menu3DData[playerid][Menus3D]);
			
			UpdateSearchTextures(playerid);
			UpdateTextureInfo(playerid, SelectedBox[playerid]);

			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "Texture search results updated - Search Results");
		}
		else if(Menu3DData[playerid][TPreviewState] != PREVIEW_STATE_SEARCH)
		{
			Menu3DData[playerid][CurrTexturePage] = 0;
			Select3DMenu(playerid, Menu3DData[playerid][Menus3D]);
			
			Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_SEARCH;

			UpdateSearchTextures(playerid);
			UpdateTextureInfo(playerid, SelectedBox[playerid]);

			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "Switched to viewing search /mtsearch results");
		}
	}
	else 
	{
		DestroyTexViewer(playerid);
		
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "No textures found with that string");
	}
	return 1;
}


static UpdateThemeTextures(playerid)
{
	for(new i = 0; i < 16; i++)
	{
		if(PlayerThemeIndex[playerid][i + 16 * Menu3DData[playerid][CurrThemePage]] == -1)
		//if(PlayerThemeIndex[playerid][i + 16 * Menu3DData[playerid][CurrThemePage]] >= PlayerThemeCount[playerid])
		{
	    	SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
				ObjectTextures[DEFAULT_TEXTURE][TModel],
				ObjectTextures[DEFAULT_TEXTURE][TXDName],
			   	ObjectTextures[DEFAULT_TEXTURE][TextureName],
			   	0x80FF0000, 0x80990000);
		}
		else
		{
	    	SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
				ObjectTextures[PlayerThemeIndex[playerid][i + 16 * Menu3DData[playerid][CurrThemePage]]][TModel],
				ObjectTextures[PlayerThemeIndex[playerid][i + 16 * Menu3DData[playerid][CurrThemePage]]][TXDName],
				ObjectTextures[PlayerThemeIndex[playerid][i + 16 * Menu3DData[playerid][CurrThemePage]]][TextureName],
			   	0xFFFFFFFF, 0xFF999999);
		}
	}
}

static UpdateSearchTextures(playerid)
{
	for(new i = 0; i < 16; i++)
	{
	   	if(PlayerSearchIndex[playerid][i + 16 * Menu3DData[playerid][CurrSearchPage]] == -1)
	   	//if(PlayerThemeIndex[playerid][i + 16 * Menu3DData[playerid][CurrSearchPage]] >= PlayerSearchResults[playerid])
		{
	    	SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
				ObjectTextures[DEFAULT_TEXTURE][TModel],
				ObjectTextures[DEFAULT_TEXTURE][TXDName],
			   	ObjectTextures[DEFAULT_TEXTURE][TextureName],
			   	0x80FF0000, 0x80990000);
		}
		else
		{
	    	SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
				ObjectTextures[PlayerSearchIndex[playerid][i + 16 * Menu3DData[playerid][CurrSearchPage]]][TModel],
				ObjectTextures[PlayerSearchIndex[playerid][i + 16 * Menu3DData[playerid][CurrSearchPage]]][TXDName],
				ObjectTextures[PlayerSearchIndex[playerid][i + 16 * Menu3DData[playerid][CurrSearchPage]]][TextureName],
			   	0xFFFFFFFF, 0xFF999999);
		}
	}
}


OnPlayerKeyStateChangeMenu(playerid,newkeys,oldkeys)
{
	#pragma unused oldkeys
	
	new line[128];
	
	if(newkeys & 16 || oldkeys & 16) return 0;
	if(EditingMode[playerid] && GetEditMode(playerid) != EDIT_MODE_TEXTURING) return 0;

	// Scroll right
	if(newkeys & KEY_ANALOG_RIGHT || (((newkeys & (KEY_CROUCH | KEY_CTRL_BACK)) == (KEY_CROUCH | KEY_CTRL_BACK)) && ((oldkeys & (KEY_CROUCH | KEY_CTRL_BACK)) != (KEY_CROUCH | KEY_CTRL_BACK))))
	{
		if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_ALLTEXTURES)
		{
			Menu3DData[playerid][CurrTexturePage]++;

            if(Menu3DData[playerid][CurrTexturePage] > (sizeof(ObjectTextures) / 16))
				Menu3DData[playerid][CurrTexturePage] = 0;
			else if((sizeof(ObjectTextures) / 16) - (Menu3DData[playerid][CurrTexturePage] - 1) < 0)
				Menu3DData[playerid][CurrTexturePage] = (sizeof(ObjectTextures) / 16);

			for(new i = 0; i < 16; i++)
			{
                if(Menu3DData[playerid][CurrTexturePage] * 16 + i + 1 >= sizeof(ObjectTextures))
                {
                    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
                        ObjectTextures[DEFAULT_TEXTURE][TModel],
                        ObjectTextures[DEFAULT_TEXTURE][TXDName],
                        ObjectTextures[DEFAULT_TEXTURE][TextureName],
                        0x80FF0000, 0x80990000);
                }
                else
                {
                    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
                        ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TModel],
                        ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TXDName],
                        ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TextureName],
                        0xFFFFFFFF, 0xFF999999);
                }
            }
		}
		else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_THEME)
		{
			if(PlayerThemeCount[playerid] <= 16) Menu3DData[playerid][CurrThemePage] = 0;
			else
			{
				Menu3DData[playerid][CurrThemePage]++;

				if(Menu3DData[playerid][CurrThemePage] > (PlayerThemeCount[playerid] / 16))
					Menu3DData[playerid][CurrThemePage] = 0;
				else if((PlayerThemeCount[playerid] / 16) - (Menu3DData[playerid][CurrThemePage] - 1) < 0)
					Menu3DData[playerid][CurrThemePage] = (PlayerThemeCount[playerid] / 16);
				
				UpdateThemeTextures(playerid);
			}
		}
		else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_SEARCH)
		{
			if(PlayerSearchResults[playerid] <= 16) Menu3DData[playerid][CurrSearchPage] = 0;
			else
			{
				Menu3DData[playerid][CurrSearchPage]++;

				if(Menu3DData[playerid][CurrSearchPage] > (PlayerSearchResults[playerid] / 16))
					Menu3DData[playerid][CurrSearchPage] = 0;
				else if((PlayerSearchResults[playerid] / 16) - (Menu3DData[playerid][CurrSearchPage] - 1) < 0)
					Menu3DData[playerid][CurrSearchPage] = (PlayerSearchResults[playerid] / 16);
				
				UpdateSearchTextures(playerid);
			}
		}
		// Update the info
		UpdateTextureInfo(playerid, SelectedBox[playerid]);

		return 1;
	}

	// Pressed left (Same as right almost)
	else if(newkeys & KEY_ANALOG_LEFT || (((newkeys & (KEY_CROUCH | KEY_YES)) == (KEY_CROUCH | KEY_YES)) && ((oldkeys & (KEY_CROUCH | KEY_YES)) != (KEY_CROUCH | KEY_YES))))
	{
		if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_ALLTEXTURES)
		{
	        // Last 16 entries
			Menu3DData[playerid][CurrTexturePage]--;

			// Too high of entries set default
			if(Menu3DData[playerid][CurrTexturePage] < 0)
				Menu3DData[playerid][CurrTexturePage] = (sizeof(ObjectTextures) / 16);
			else if(Menu3DData[playerid][CurrTexturePage] >= (sizeof(ObjectTextures) / 16))
				Menu3DData[playerid][CurrTexturePage] = 0;
            
			for(new i = 0; i < 16; i++)
			{
                if(Menu3DData[playerid][CurrTexturePage] * 16 + i + 1 >= sizeof(ObjectTextures))
                {
                    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
                        ObjectTextures[DEFAULT_TEXTURE][TModel],
                        ObjectTextures[DEFAULT_TEXTURE][TXDName],
                        ObjectTextures[DEFAULT_TEXTURE][TextureName],
                        0x80FF0000, 0x80990000);
                }
                else
                {
                    SetBoxMaterial(Menu3DData[playerid][Menus3D],i,0,
                        ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TModel],
                        ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TXDName],
                        ObjectTextures[i+Menu3DData[playerid][CurrTexturePage] * 16 + 1][TextureName],
                        0xFFFFFFFF, 0xFF999999);
                }
            }
		}
		else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_THEME)
		{
			if(PlayerThemeCount[playerid] <= 16) Menu3DData[playerid][CurrThemePage] = 0;
			else
			{
				Menu3DData[playerid][CurrThemePage]--;

				if(Menu3DData[playerid][CurrThemePage] < 0)
					Menu3DData[playerid][CurrThemePage] = (PlayerThemeCount[playerid] / 16);
				else if(Menu3DData[playerid][CurrThemePage] >= (PlayerThemeCount[playerid] / 16))
					Menu3DData[playerid][CurrThemePage] = 0;
					
				//Menu3DData[playerid][CurrThemePage] -= 16;
                //
				//if(Menu3DData[playerid][CurrThemePage] < 1) Menu3DData[playerid][CurrThemePage] = PlayerThemeCount[playerid] - 16 - 1;
				//if(Menu3DData[playerid][CurrThemePage] >= PlayerThemeCount[playerid] - 1) Menu3DData[playerid][CurrThemePage] = PlayerThemeCount[playerid] - 1;

				UpdateThemeTextures(playerid);
			}
		}
		else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_SEARCH)
		{
			if(PlayerSearchResults[playerid] <= 16) Menu3DData[playerid][CurrSearchPage] = 0;
			else
			{
				Menu3DData[playerid][CurrSearchPage]--;

				if(Menu3DData[playerid][CurrSearchPage] < 0)
					Menu3DData[playerid][CurrSearchPage] = (PlayerSearchResults[playerid] / 16);
				else if(Menu3DData[playerid][CurrSearchPage] >= (PlayerSearchResults[playerid] / 16))
					Menu3DData[playerid][CurrSearchPage] = 0;

				UpdateSearchTextures(playerid);
			}
		}
			
		// Update the info
        UpdateTextureInfo(playerid, SelectedBox[playerid]);

		return 1;
	}

	//
	else if(newkeys & KEY_SPRINT && (FlyMode[playerid] || newkeys & KEY_HANDBRAKE))
	{
		// Add to your theme
	    if(Menu3DData[playerid][TPreviewState] != PREVIEW_STATE_THEME)
	    {
			new addt = AddTextureToTheme(playerid, 1 + 16 * Menu3DData[playerid][CurrTexturePage] + SelectedBox[playerid]);
			if(addt >= 0)
			{
		   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Texture added to theme selection");
			}
			else if(addt == -1)
			{
		   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "This texture is already added");
			}
			else if(addt == -2)
			{
		   		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Tried to add too many textures to your theme");
			}
			return 1;
		}
	}

	// Set current select material to object
	else if(newkeys & KEY_WALK)
	{
	    if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_ALLTEXTURES)
	    {
			if(TextureAll[playerid])
			{
				format(line, sizeof(line), "/mtsetall %i %i", CurrTexturingIndex[playerid], 1 + 16 * Menu3DData[playerid][CurrTexturePage] + SelectedBox[playerid]);
				BroadcastCommand(playerid, line);
			}
			else
			{
				format(line, sizeof(line), "/mtset %i %i", CurrTexturingIndex[playerid], 1 + 16 * Menu3DData[playerid][CurrTexturePage] + SelectedBox[playerid]);
				BroadcastCommand(playerid, line);
			}
			return 1;
	    }
        else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_THEME)
        {
			if(TextureAll[playerid])
			{
				format(line, sizeof(line), "/mtsetall %i %i", CurrTexturingIndex[playerid], 16 * Menu3DData[playerid][CurrThemePage] + SelectedBox[playerid]);
				BroadcastCommand(playerid, line);
			}
			else
			{
				format(line, sizeof(line), "/mtset %i %i", CurrTexturingIndex[playerid], 16 * Menu3DData[playerid][CurrThemePage] + SelectedBox[playerid]);
				BroadcastCommand(playerid, line);
			}
			return 1;
        }
        else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_SEARCH)
        {
			if(TextureAll[playerid])
			{
				format(line, sizeof(line), "/mtsetall %i %i", CurrTexturingIndex[playerid], 16 * Menu3DData[playerid][CurrSearchPage] + SelectedBox[playerid]);
				BroadcastCommand(playerid, line);
			}
			else
			{
				format(line, sizeof(line), "/mtset %i %i", CurrTexturingIndex[playerid], 16 * Menu3DData[playerid][CurrSearchPage] + SelectedBox[playerid]);
				BroadcastCommand(playerid, line);
			}
			return 1;
        }
	}
	
	return 0;
}


OnPlayerKeyStateChangeTex(playerid,newkeys,oldkeys)
{
	#pragma unused oldkeys
	if( newkeys & KEY_NO || (IsFlyMode(playerid) && newkeys & KEY_JUMP) )
	{
	    if(GetEditMode(playerid) == EDIT_MODE_TEXTURING)
		{
			SelectTextDraw(playerid, 0xD9D919FF);
			return 1;
		}
	}
	return 0;
}


static AddTextureToTheme(playerid, index)
{
    for(new i = 1; i < sizeof(ObjectTextures); i++)
	{
		if(index == PlayerThemeIndex[playerid][i])
			return -1;
		else if(PlayerThemeIndex[playerid][i] == -1)
		{
			PlayerThemeIndex[playerid][i] = index;
			PlayerThemeCount[playerid]++;
			return i;
		}
	}
	return -2;
}

// To menu change effects when changing selection
public OnPlayerChange3DMenuBox(playerid,MenuID,boxid)
{
	UpdateTextureInfo(playerid, boxid);
	return 1;
}

// Update selection info text
static UpdateTextureInfo(playerid, boxid)
{
	// Standard texture viewer
	new line[128];
	if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_ALLTEXTURES)
	{
		if((boxid + 16 * Menu3DData[playerid][CurrTexturePage] + 1) < sizeof(ObjectTextures))
		{
			format(line, sizeof(line), "~n~~n~Model: %i TXD: %s Texture: %s~n~~r~Index: %i/%i", ObjectTextures[boxid + 16 * Menu3DData[playerid][CurrTexturePage]][TModel],
				ObjectTextures[boxid + 16 * Menu3DData[playerid][CurrTexturePage]][TXDName],
				ObjectTextures[boxid + 16 * Menu3DData[playerid][CurrTexturePage]][TextureName],
				Menu3DData[playerid][CurrTexturePage] * 16 + boxid + 1, sizeof(ObjectTextures) - 1);
		}
		else
		{
			format(line, sizeof(line), "~n~~n~Model: %i TXD: %s Texture: %s~n~~r~Index: %i/%i", ObjectTextures[0][TModel],
				ObjectTextures[0][TXDName],
				ObjectTextures[0][TextureName],
				Menu3DData[playerid][CurrTexturePage] * 16 + boxid + 1, sizeof(ObjectTextures) - 1);
		}
	}
	else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_THEME)
	{
		if(PlayerThemeIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrThemePage]] != -1)
		//if((boxid + 16 * Menu3DData[playerid][CurrThemePage]) < sizeof(ObjectTextures))
		{
			format(line, sizeof(line), "~n~~n~Model: %i TXD: %s Texture: %s~n~~r~Index: %i/%i~n~Theme Index: %i/%i",
				ObjectTextures[PlayerThemeIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrThemePage]]][TModel],
				ObjectTextures[PlayerThemeIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrThemePage]]][TXDName],
				ObjectTextures[PlayerThemeIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrThemePage]]][TextureName],
				PlayerThemeIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrThemePage]], sizeof(ObjectTextures) - 1,
				boxid + 16 * Menu3DData[playerid][CurrThemePage] + 1, PlayerThemeCount[playerid]);
		}
		else
		{
			format(line, sizeof(line), "~n~~n~Model: %i TXD: %s Texture: %s~n~~r~Index: %i/%i~n~Theme Index: %i/%i",
				ObjectTextures[0][TModel],
				ObjectTextures[0][TXDName],
				ObjectTextures[0][TextureName],
				PlayerThemeIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrThemePage]], sizeof(ObjectTextures) - 1,
				boxid + 16 * Menu3DData[playerid][CurrThemePage] + 1, PlayerThemeCount[playerid]);
		}
	}
	else if(Menu3DData[playerid][TPreviewState] == PREVIEW_STATE_SEARCH)
	{
		if(PlayerSearchIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrSearchPage]] != -1)
		//if((boxid + 16 * Menu3DData[playerid][CurrSearchPage]) < sizeof(ObjectTextures))
		{
			format(line, sizeof(line), "~n~~n~Model: %i TXD: %s Texture: %s~n~~r~Index: %i/%i~n~Search Index: %i/%i",
				ObjectTextures[PlayerSearchIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrSearchPage]]][TModel],
				ObjectTextures[PlayerSearchIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrSearchPage]]][TXDName],
				ObjectTextures[PlayerSearchIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrSearchPage]]][TextureName],
				PlayerSearchIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrSearchPage]], sizeof(ObjectTextures) - 1,
				boxid + 16 * Menu3DData[playerid][CurrSearchPage] + 1, PlayerSearchResults[playerid]);
		}
		else
		{
			format(line, sizeof(line), "~n~~n~Model: %i TXD: %s Texture: %s~n~~r~Index: %i/%i~n~Search Index: %i/%i",
				ObjectTextures[0][TModel],
				ObjectTextures[0][TXDName],
				ObjectTextures[0][TextureName],
				PlayerSearchIndex[playerid][boxid + 16 * Menu3DData[playerid][CurrSearchPage]], sizeof(ObjectTextures) - 1,
				boxid + 16 * Menu3DData[playerid][CurrSearchPage] + 1, PlayerSearchResults[playerid]);
		}
	}
	PlayerTextDrawSetString(playerid, Menu3DData[playerid][Menu3D_Model_Info], line);
	
	return 1;
}

static CreateTexViewer(playerid)
{
	// Get position
	new Float:x, Float: y, Float:z, Float:fa;
	GetPlayerPos(playerid, x, y, z);

	if(FlyMode[playerid])
	{
		fa = GetPlayerCameraFacingAngle(playerid);
		z -= 1.0;
	}
	else GetPlayerFacingAngle(playerid, fa);
	
	// Calculate position to left of player
	x = (x + 1.75 * floatsin(-fa + -90,degrees));
	y = (y + 1.75 * floatcos(-fa + -90,degrees));

	// Calculate create offset
	if(FlyMode[playerid])
	{
		x = (x + 4.0 * floatsin(-fa,degrees));
		y = (y + 4.0 * floatcos(-fa,degrees));
	}
	else
	{
		x = (x + 2.0 * floatsin(-fa,degrees));
		y = (y + 2.0 * floatcos(-fa,degrees));
	}

    Menu3DData[playerid][Menus3D] = Create3DMenu(playerid, x, y, z, fa, 16);
	Select3DMenu(playerid, Menu3DData[playerid][Menus3D]);
    PlayerTextDrawShow(playerid, Menu3DData[playerid][Menu3D_Model_Info]);

	return 1;
}

static DestroyTexViewer(playerid)
{
	CancelSelect3DMenu(playerid);
	Destroy3DMenu(Menu3DData[playerid][Menus3D]);
	Menu3DData[playerid][TPreviewState] = PREVIEW_STATE_NONE;
	PlayerTextDrawHide(playerid, Menu3DData[playerid][Menu3D_Model_Info]);

	return 1;
}

YCMD:savetheme(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Save a few textures as a theme to be used later.");
		return 1;
	}

	new count;
	new DBResult:r;

	// Any theme to save?
	for(new i = 0; i < sizeof(ObjectTextures); i++)
	{
		if(PlayerThemeIndex[playerid][i] != -1)
		{
			count++;
			break;
	    }
	}
	if(count == 0)
	{
  		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "You have no textures to save to theme!");
	}
	else
	{
	    inline SaveTheme(tpid, tdialogid, tresponse, tlistitem, string:ttext[])
		{
			#pragma unused tlistitem, tdialogid, tpid, ttext

			if(tresponse)
			{
				if(isnull(ttext))
				{
			  		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a theme name to save!");
				}

				r = db_query(ThemeDataDB, "SELECT * FROM sqlite_master");

				if(db_num_rows(r) > 0)
				{
				    for(new i = 0; i < db_num_rows(r); i++)
				    {
						new Field[32];
						
						db_get_field_assoc(r, "name", Field, 64);

				        if(!strcmp(Field, ttext))
						{
						    inline ReplaceTheme(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
							{
							    #pragma unused rlistitem, rdialogid, rpid, rtext
							    if(rresponse)
								{
									SavePlayerTheme(playerid, ttext,true);
							  		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
									SendClientMessage(playerid, STEALTH_GREEN, "Theme has been saved!");
								}
						    }
						    Dialog_ShowCallback(playerid, using inline ReplaceTheme, DIALOG_STYLE_MSGBOX, "Texture Studio", "There is a theme with this name aready replace?", "Ok", "Cancel");
							return 1;
						}
						db_next_row(r);
				    }
				    
   					SavePlayerTheme(playerid, ttext);
			  		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_GREEN, "Theme has been saved!");
				    
				}
	   			db_free_result(r);
			}
		}
		Dialog_ShowCallback(playerid, using inline SaveTheme, DIALOG_STYLE_INPUT, "Texture Studio", "Choose a theme name to save to", "Ok", "Cancel");

	}
	return 1;
}


YCMD:deletetheme(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Delete a saved texture theme.");
		return 1;
	}

	new DBResult:r = db_query(ThemeDataDB, "SELECT * FROM sqlite_master");

	if(db_num_rows(r))
	{
		new Field[64];
		new line[1024];
		for(new i = 0; i < db_num_rows(r); i++)
		{
			db_get_field_assoc(r, "name", Field, 64);
			format(line, sizeof(line), "%s%s\n", line, Field);
			db_next_row(r);
		}

		inline DeleteTheme(lpid, ldialogid, lresponse, llistitem, string:ltext[])
		{
			#pragma unused llistitem, ldialogid, lpid, ltext
			if(lresponse)
			{
			    inline ClearTheme(cpid, cdialogid, cresponse, clistitem, string:ctext[])
			    {
					#pragma unused clistitem, cdialogid, cpid, ctext
					if(cresponse)
					{
						if(strcmp("default_theme", ltext))
						{
							new q[128];
							format(q, sizeof(q), "DROP TABLE `%s`", ltext);
							db_free_result(db_query(ThemeDataDB, q));

							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_GREEN, "Theme deleted!");
						}
						else
						{
							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_YELLOW, "You can not delete the default theme!");
						}
					}
			    }
                Dialog_ShowCallback(playerid, using inline ClearTheme, DIALOG_STYLE_MSGBOX, "Texture Studio", "Delete theme?", "Ok", "Cancel");
			}
		}
        Dialog_ShowCallback(playerid, using inline DeleteTheme, DIALOG_STYLE_LIST, "Delete a theme", line, "Ok", "Cancel");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There are no themes to delete!");
	}

	db_free_result(r);

	return 1;
}


YCMD:loadtheme(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Load a saved texture theme.");
		return 1;
	}

	new DBResult:r = db_query(ThemeDataDB, "SELECT * FROM sqlite_master");
	
	if(db_num_rows(r))
	{
		new Field[64];
		new line[1024];
		for(new i = 0; i < db_num_rows(r); i++)
		{
			db_get_field_assoc(r, "name", Field, 64);
			format(line, sizeof(line), "%s%s\n", line, Field);
			db_next_row(r);
		}

		inline LoadTheme(lpid, ldialogid, lresponse, llistitem, string:ltext[])
		{
			#pragma unused llistitem, ldialogid, lpid, ltext
			if(lresponse)
			{
			    inline ClearTheme(cpid, cdialogid, cresponse, clistitem, string:ctext[])
			    {
			        #pragma unused clistitem, cdialogid, cpid, ctext
			        if(cresponse) LoadPlayerTheme(playerid, ltext, true);
			        else LoadPlayerTheme(playerid, ltext, false);

			  		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_GREEN, "Theme has been loaded!");
			    }
                Dialog_ShowCallback(playerid, using inline ClearTheme, DIALOG_STYLE_MSGBOX, "Texture Studio", "Clear existing theme?", "Ok", "Cancel");
			}
		}
        Dialog_ShowCallback(playerid, using inline LoadTheme, DIALOG_STYLE_LIST, "Texture Studio - Load a theme", line, "Ok", "Cancel");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There are no themes to load!");
	}
	
	db_free_result(r);
	
	return 1;
}

static SavePlayerTheme(playerid, name[], bool:deletedb=false)
{
	new q[128];

	if(deletedb) format(q, sizeof(q), "DELETE FROM `%s`", name);
	else format(q, sizeof(q), "CREATE TABLE IF NOT EXISTS `%s` (TIndex INTEGER)", name);
	db_free_result(db_query(ThemeDataDB, q));
	
	for(new i = 0; i < sizeof(ObjectTextures); i++)
	{
		if(PlayerThemeIndex[playerid][i] != -1)
		{
		    format(q, sizeof(q), "INSERT INTO `%s` (`TIndex`) VALUES(%i)", name, PlayerThemeIndex[playerid][i]);
		    db_free_result(db_query(ThemeDataDB, q));
		}
		else break;
	}
	
	return 1;
}

static LoadPlayerTheme(playerid, name[], bool:cleararray=true)
{
	new q[128];
	new DBResult:r;
	format(q, sizeof(q), "SELECT * FROM `%s`", name);
	r = db_query(ThemeDataDB, q);
	
	if(db_num_rows(r))
	{
		if(cleararray)
		{
			for(new i = 0; i < sizeof(ObjectTextures); i++) PlayerThemeIndex[playerid][i] = -1;
			PlayerThemeCount[playerid] = 0;
		}
		
	    for(new i = 0; i < db_num_rows(r); i++)
	    {
			for(new j, currpos; j < sizeof(ObjectTextures); j++)
			{
			    if(PlayerThemeIndex[playerid][j] == -1)
			    {
					currpos = j;
					new Field[8];
					db_get_field_assoc(r, "TIndex", Field, 8);
					PlayerThemeIndex[playerid][currpos] = strval(Field);
					PlayerThemeCount[playerid]++;
					break;
			    }
			}
			db_next_row(r);
		}
		db_free_result(r);
	}
	return 1;
}



YCMD:settindex(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set currently selected texturing index.");
		return 1;
	}

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = strval(arg);
	if(index < 0 || index > 15) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /settindex <index> (0-15)");

	CurrTexturingIndex[playerid] = index;
	new line[128];
	format(line, sizeof(line), "Current texturing index set to %i", index);
	SendClientMessage(playerid, STEALTH_GREEN, line);

	return 1;
}


YCMD:stexture(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Texture editor.");
		return 1;
	}

    MapOpenCheck();
	EditCheck(playerid);

	if(GetEditMode(playerid) == EDIT_MODE_TEXTURING)
	{
	    SetCurrTextDraw(playerid, TEXTDRAW_NONE);
		SetEditMode(playerid, EDIT_MODE_NONE);
		EditingMode[playerid] = false;

		for(new i = 0; i < MAX_MATERIALS; i++)
		{
			TextDrawHideForPlayer(playerid, Click_SetTexture[i]);
			TextDrawHideForPlayer(playerid, Click_ClearTexture[i]);
			TextDrawHideForPlayer(playerid, Click_SetColor[i]);
			TextDrawHideForPlayer(playerid, Click_CloseTexture);
			PlayerTextDrawHide(playerid, Player_TextureInfo[playerid][i]);
			PlayerTextDrawHide(playerid, Click_TextureAll[playerid]);
		}
        SetTimerEx("PlayerSetGUIPaused", 300, false, "ii", playerid, 0);
	    CancelSelectTextDraw(playerid);
	}
	else
	{
		SetEditMode(playerid, EDIT_MODE_TEXTURING);
		SetCurrTextDraw(playerid, TEXTDRAW_MATERIALS);
        EditingMode[playerid] = true;
		SelectTextDraw(playerid, 0xD9D919FF);
		PlayerSetGUIPaused(playerid, true);

		for(new i = 0; i < MAX_MATERIALS; i++)
		{
			TextDrawShowForPlayer(playerid, Click_SetTexture[i]);
			TextDrawShowForPlayer(playerid, Click_ClearTexture[i]);
			TextDrawShowForPlayer(playerid, Click_SetColor[i]);
			TextDrawShowForPlayer(playerid, Click_CloseTexture);
			UpdateTextureSlot(playerid, i);
			PlayerTextDrawShow(playerid, Player_TextureInfo[playerid][i]);
			PlayerTextDrawShow(playerid, Click_TextureAll[playerid]);
		}
	}
	return 1;
}

static InitPlayerTextureInfo(playerid)
{
	new Float:ypos = 100.0;

	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		Player_TextureInfo[playerid][i] = CreatePlayerTextDraw(playerid,57.000000, ypos, "(0) None");
		PlayerTextDrawBackgroundColor(playerid,Player_TextureInfo[playerid][i], 255);
		PlayerTextDrawFont(playerid,Player_TextureInfo[playerid][i], 2);
		PlayerTextDrawLetterSize(playerid,Player_TextureInfo[playerid][i], 0.200000, 1.000000);
		PlayerTextDrawColor(playerid,Player_TextureInfo[playerid][i], -1);
		PlayerTextDrawSetOutline(playerid,Player_TextureInfo[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid,Player_TextureInfo[playerid][i], 1);
		PlayerTextDrawSetSelectable(playerid,Player_TextureInfo[playerid][i], 0);
		ypos += 15.0;
	}
	
	Click_TextureAll[playerid] = CreatePlayerTextDraw(playerid, 10.000000, ypos, "All");
	PlayerTextDrawBackgroundColor(playerid, Click_TextureAll[playerid], 255);
	PlayerTextDrawFont(playerid, Click_TextureAll[playerid], 2);
	PlayerTextDrawLetterSize(playerid, Click_TextureAll[playerid], 0.200000, 1.000000);
	PlayerTextDrawColor(playerid, Click_TextureAll[playerid], 0xFF0000FF);
	PlayerTextDrawSetOutline(playerid, Click_TextureAll[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Click_TextureAll[playerid], 1);
	PlayerTextDrawUseBox(playerid, Click_TextureAll[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Click_TextureAll[playerid], 0);
	PlayerTextDrawTextSize(playerid, Click_TextureAll[playerid], 30.000000, 10.000000);
	PlayerTextDrawSetSelectable(playerid, Click_TextureAll[playerid], 1);
	
	return 1;
}

ClickTextDrawEditMat(playerid, Text:clickedid)
{
	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		// Player clicked set texture
	    if(Click_SetTexture[i] == clickedid)
	    {
	        SelectingTexture[playerid] = true;
			CurrTexturingIndex[playerid] = i;
	        CancelSelectTextDraw(playerid);

			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			new line[128];
			format(line, sizeof(line), "Editing texture index %i use /mtextures - /ttextures to select a texture");
			SendClientMessage(playerid, STEALTH_GREEN, line);

	        return 1;
	    }
		// Player clicked set color
	    else if(Click_SetColor[i] == clickedid)
	    {
	    	inline SelectColorMet(spid, sdialogid, sresponse, slistitem, string:stext[])
			{
				#pragma unused slistitem, sdialogid, spid, stext
				if(sresponse)
				{
					new line[128];
				    switch(slistitem)
				    {
				        case 0:
						{
                            inline SelectHexColor(hpid, hdialogid, hresponse, hlistitem, string:htext[])
                            {
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									if(TextureAll[playerid])
									{
										format(line, sizeof(line), "/mtcolorall %i %s", i, htext);
										BroadcastCommand(playerid, line);
									}
									else
									{
										format(line, sizeof(line), "/mtcolor %i %s", i, htext);
										BroadcastCommand(playerid, line);
									}
								}
                            }
                            Dialog_ShowCallback(playerid, using inline SelectHexColor, DIALOG_STYLE_INPUT, "Texture Studio - Input Hex Color", "Hex color ( 0x00000000 ) ARGB", "Ok", "Cancel");
						}
				        case 1:
						{
							new red, green, blue, alpha;
                            inline SelectRed(redpid, reddialogid, redresponse, redlistitem, string:redtext[])
                            {
                                #pragma unused redlistitem, reddialogid, redpid, redtext
								if(redresponse)
								{
									red = strval(redtext);
									if(red < 0 || red > 255) Dialog_ShowCallback(playerid, using inline SelectRed, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Red Value <0 - 255>", "Ok", "Cancel");
									else
									{
									    inline SelectGreen(greenpid, greendialogid, greenresponse, greenlistitem, string:greentext[])
									    {
									        #pragma unused greenlistitem, greendialogid, greenpid, greentext
											if(greenresponse)
											{
												green = strval(greentext);
												if(green < 0 || green > 255) Dialog_ShowCallback(playerid, using inline SelectGreen, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Green Value <0 - 255>", "Ok", "Cancel");
												else
												{
												    inline SelectBlue(bluepid, bluedialogid, blueresponse, bluelistitem, string:bluetext[])
												    {
												        #pragma unused bluelistitem, bluedialogid, bluepid, bluetext
														if(blueresponse)
														{
															blue = strval(bluetext);
															if(blue < 0 || blue > 255) Dialog_ShowCallback(playerid, using inline SelectBlue, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Blue Value <0 - 255>", "Ok", "Cancel");
															else
															{
															    inline SelectAlpha(alphapid, alphadialogid, alpharesponse, alphalistitem, string:alphatext[])
															    {
															        #pragma unused alphalistitem, alphadialogid, alphapid, alphatext
																	if(alpharesponse)
																	{
																		if(isnull(alphatext)) alpha = 255;
																		else alpha = strval(alphatext);
																		if(alpha < 0 || alpha > 255) Dialog_ShowCallback(playerid, using inline SelectAlpha, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Alpha Value <0 - 255>\nNote: Leaving this empty is full alpha 255", "Ok", "Cancel");
																		else
																		{
																		   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
                                                                            new index = CurrObject[playerid];

                                                                            if(TextureAll[playerid])
																			{
																				foreach(new j : Objects)
																				{
																				    if(ObjectData[j][oModel] == ObjectData[CurrObject[playerid]][oModel])
																				    {
																				        ObjectData[j][oColorIndex][i] = ARGB(alpha, red, green, blue);

																						// Destroy the object
																					    DestroyDynamicObject(ObjectData[j][oID]);

																						// Re-create object
																						ObjectData[j][oID] = CreateDynamicObject(ObjectData[j][oModel], ObjectData[j][oX], ObjectData[j][oY], ObjectData[j][oZ], ObjectData[j][oRX], ObjectData[j][oRY], ObjectData[j][oRZ], -1, -1, -1, 300.0);
																						Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[j][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

																						// Update the materials
																						UpdateMaterial(j);

																						// Save this material index to the data base
																						sqlite_SaveColorIndex(j);
																				    }

																				}
																				// Update the streamer
																				foreach(new j : Player)
																				{
																				    if(IsPlayerInRangeOfPoint(j, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(j);
																				}

																				SendClientMessage(playerid, STEALTH_GREEN, "Changed All Color");

																			}
																			else
																			{
																				// Set the color
																		        ObjectData[index][oColorIndex][i] = ARGB(alpha, red, green, blue);

																				// Destroy the object
																			    DestroyDynamicObject(ObjectData[index][oID]);

																				// Re-create object
																				ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], -1, -1, -1, 300.0);
																				Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

																				// Update the materials
																				UpdateMaterial(index);

																				// Save this material index to the data base
																				sqlite_SaveColorIndex(index);

																				// Update texture tool
																		        UpdateTextureSlot(playerid, i);

																				// Update the streamer
																				foreach(new j : Player)
																				{
																				    if(IsPlayerInRangeOfPoint(j, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(j);
																				}

																				SendClientMessage(playerid, STEALTH_GREEN, "Changed Color");
																			}
																		}
																	}
																}
																Dialog_ShowCallback(playerid, using inline SelectAlpha, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Alpha Value <0 - 255>\nNote: Leaving this empty is full alpha 255", "Ok", "Cancel");
															}
														}
													}
													Dialog_ShowCallback(playerid, using inline SelectBlue, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Blue Value <0 - 255>", "Ok", "Cancel");
												}
											}
									    }
									    Dialog_ShowCallback(playerid, using inline SelectGreen, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Green Value <0 - 255>", "Ok", "Cancel");
									}
								}
                            }
                            Dialog_ShowCallback(playerid, using inline SelectRed, DIALOG_STYLE_INPUT, "Texture Studio - Color Combinator", "Enter Red Value <0 - 255>", "Ok", "Cancel");
						}
				        case 2:
						{
                            inline SelectWebColor(wpid, wdialogid, wresponse, wlistitem, string:wtext[])
							{
							    #pragma unused wlistitem, wdialogid, wpid, wtext
								if(wresponse)
							    {
									if(TextureAll[playerid])
									{
								        format(line, sizeof(line), "/mtcolorall %i %s", i, WebColorsARGB[wlistitem]);
								        BroadcastCommand(playerid, line);
									}
									else
									{
								        format(line, sizeof(line), "/mtcolor %i %s", i, WebColorsARGB[wlistitem]);
								        BroadcastCommand(playerid, line);
									}
							    }
							}
                            Dialog_ShowCallback(playerid, using inline SelectWebColor, DIALOG_STYLE_LIST, "Texture Studio - Select Web Color", webcolors, "Ok", "Cancel");
						}
						case 3:
						{
                            if(TextureAll[playerid])
                            {
	      						format(line, sizeof(line), "/mtcolorall %i 0x00000000", i);
								BroadcastCommand(playerid, line);
							}
							else
							{
	      						format(line, sizeof(line), "/mtcolor %i 0x00000000", i);
								BroadcastCommand(playerid, line);
							}
						}
				    }
				}
			}
			Dialog_ShowCallback(playerid, using inline SelectColorMet, DIALOG_STYLE_LIST, "Texture Studio - Select Color Method", "Hex Value\nCombinator\nWeb Colors\nReset Color", "Ok", "Cancel");
			return 1;
	    }
    	// Player clicked clear texture/color
	    else if(Click_ClearTexture[i] == clickedid)
	    {
			if(TextureAll[playerid])
			{
				new line[128];
				format(line, sizeof(line), "/mtsetall %i 0", i);
				BroadcastCommand(playerid, line);
				format(line, sizeof(line), "/mtcolorall %i 0x00000000", i);
				BroadcastCommand(playerid, line);
				format(line, sizeof(line), "Cleared texture and color on slot %i for all objects", i);
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, line);
			}
			else
			{
				new line[128];
				format(line, sizeof(line), "/mtset %i 0", i);
				BroadcastCommand(playerid, line);
				format(line, sizeof(line), "/mtcolor %i 0x00000000", i);
				BroadcastCommand(playerid, line);
				format(line, sizeof(line), "Cleared texture and color on slot %i", i);
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, line);
			}
			return 1;
	    }
	}

	if(clickedid == Click_CloseTexture) BroadcastCommand(playerid, "/stexture");
	return 0;
}


ClickPlayerTextDrawEditMat(playerid, PlayerText:playertextid)
{
	if(Click_TextureAll[playerid] == playertextid)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		if(TextureAll[playerid])
		{
		    TextureAll[playerid] = false;
		    PlayerTextDrawHide(playerid, Click_TextureAll[playerid]);
		    PlayerTextDrawColor(playerid, Click_TextureAll[playerid], 0xFF0000FF);
		    PlayerTextDrawShow(playerid, Click_TextureAll[playerid]);
		    SendClientMessage(playerid, STEALTH_GREEN, "Only the object you are currently editing will be textured");
		}
		else
		{
		    TextureAll[playerid] = true;
		    PlayerTextDrawHide(playerid, Click_TextureAll[playerid]);
		    PlayerTextDrawColor(playerid, Click_TextureAll[playerid], 0x00FF00FF);
		    PlayerTextDrawShow(playerid, Click_TextureAll[playerid]);
		    SendClientMessage(playerid, STEALTH_GREEN, "All like objects will now be textured");
		}
		return 1;
    }
	return 0;
}

UpdateTextureSlot(playerid, index)
{
	new line[128];
	
	if(ObjectData[CurrObject[playerid]][oTexIndex][index] != 0)
	{
		format(line, sizeof(line), "~g~Texture: %s ~r~Index: %i",
			ObjectTextures[ObjectData[CurrObject[playerid]][oTexIndex][index]][TextureName],
			ObjectData[CurrObject[playerid]][oTexIndex][index]);
        PlayerTextDrawSetString(playerid, Player_TextureInfo[playerid][index], line);
	}
	else PlayerTextDrawSetString(playerid, Player_TextureInfo[playerid][index], "~g~None");

}
