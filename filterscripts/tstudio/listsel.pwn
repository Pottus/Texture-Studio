
#define         MAX_LIST_OBJECTS            20

#define         NO_OBJECT_IN_SLOT_MODEL     18631

// Background
static Text:ListSelBackGround_0;
static Text:ListSelBackGround_1;
static Text:ListSelBackGround_2;
static Text:ListSelBackGround_3;


// Clickables
static Text:ListSelRXLeft;
static Text:ListSelRYLeft;
static Text:ListSelRZLeft;
static Text:ListSelRXRight;
static Text:ListSelRYRight;
static Text:ListSelRZRight;

static Text:ListSelZoomLeft;
static Text:ListSelZoomRight;

static Text:ListSelReset;

static Text:ListSelExit;

static Text:ListSelHighLight[MAX_LIST_OBJECTS];

static Text:ListSelClickLeft;
static Text:ListSelClickRight;

static Text:ListSelSelectObject;

static PlayerText:ListObjects[MAX_PLAYERS][MAX_LIST_OBJECTS];
static PlayerText:ListModel[MAX_PLAYERS];

static CurrListOffset[MAX_PLAYERS];
static CurrListHighlight[MAX_PLAYERS];

static CurrListHighlightObject[MAX_PLAYERS] = { -1, ... };

enum LISTSELINFO { Float:LRX, Float:LRY, Float:LRZ, Float:LZoom }
static ListSelData[MAX_PLAYERS][LISTSELINFO];

public OnFilterScriptInit()
{
	// Background
	ListSelBackGround_0 = TextDrawCreate(539.000000, 159.000000, "RX");
	TextDrawAlignment(ListSelBackGround_0, 2);
	TextDrawBackgroundColor(ListSelBackGround_0, 255);
	TextDrawFont(ListSelBackGround_0, 1);
	TextDrawLetterSize(ListSelBackGround_0, 0.309999, 2.000000);
	TextDrawColor(ListSelBackGround_0, -65281);
	TextDrawSetOutline(ListSelBackGround_0, 1);
	TextDrawSetProportional(ListSelBackGround_0, 1);
	TextDrawSetSelectable(ListSelBackGround_0, 0);

	ListSelBackGround_1 = TextDrawCreate(539.000000, 199.000000, "RY");
	TextDrawAlignment(ListSelBackGround_1, 2);
	TextDrawBackgroundColor(ListSelBackGround_1, 255);
	TextDrawFont(ListSelBackGround_1, 1);
	TextDrawLetterSize(ListSelBackGround_1, 0.309999, 2.000000);
	TextDrawColor(ListSelBackGround_1, -65281);
	TextDrawSetOutline(ListSelBackGround_1, 1);
	TextDrawSetProportional(ListSelBackGround_1, 1);
	TextDrawSetSelectable(ListSelBackGround_1, 0);

	ListSelBackGround_2 = TextDrawCreate(539.000000, 239.000000, "RZ");
	TextDrawAlignment(ListSelBackGround_2, 2);
	TextDrawBackgroundColor(ListSelBackGround_2, 255);
	TextDrawFont(ListSelBackGround_2, 1);
	TextDrawLetterSize(ListSelBackGround_2, 0.309999, 2.000000);
	TextDrawColor(ListSelBackGround_2, -65281);
	TextDrawSetOutline(ListSelBackGround_2, 1);
	TextDrawSetProportional(ListSelBackGround_2, 1);
	TextDrawSetSelectable(ListSelBackGround_2, 0);

	ListSelBackGround_3 = TextDrawCreate(539.000000, 279.000000, "Zoom");
	TextDrawAlignment(ListSelBackGround_3, 2);
	TextDrawBackgroundColor(ListSelBackGround_3, 255);
	TextDrawFont(ListSelBackGround_3, 1);
	TextDrawLetterSize(ListSelBackGround_3, 0.309999, 2.000000);
	TextDrawColor(ListSelBackGround_3, -65281);
	TextDrawSetOutline(ListSelBackGround_3, 1);
	TextDrawSetProportional(ListSelBackGround_3, 1);
	TextDrawSetSelectable(ListSelBackGround_3, 0);


	// Clickables
	ListSelRXLeft = TextDrawCreate(480.000000, 150.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(ListSelRXLeft, 255);
	TextDrawFont(ListSelRXLeft, 4);
	TextDrawLetterSize(ListSelRXLeft, 0.500000, 1.000000);
	TextDrawColor(ListSelRXLeft, 16777215);
	TextDrawSetOutline(ListSelRXLeft, 0);
	TextDrawSetProportional(ListSelRXLeft, 1);
	TextDrawSetShadow(ListSelRXLeft, 1);
	TextDrawUseBox(ListSelRXLeft, 1);
	TextDrawBoxColor(ListSelRXLeft, 255);
	TextDrawTextSize(ListSelRXLeft, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelRXLeft, 1);

	ListSelRYLeft = TextDrawCreate(480.000000, 190.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(ListSelRYLeft, 255);
	TextDrawFont(ListSelRYLeft, 4);
	TextDrawLetterSize(ListSelRYLeft, 0.500000, 1.000000);
	TextDrawColor(ListSelRYLeft, 16777215);
	TextDrawSetOutline(ListSelRYLeft, 0);
	TextDrawSetProportional(ListSelRYLeft, 1);
	TextDrawSetShadow(ListSelRYLeft, 1);
	TextDrawUseBox(ListSelRYLeft, 1);
	TextDrawBoxColor(ListSelRYLeft, 255);
	TextDrawTextSize(ListSelRYLeft, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelRYLeft, 1);

	ListSelRZLeft = TextDrawCreate(480.000000, 230.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(ListSelRZLeft, 255);
	TextDrawFont(ListSelRZLeft, 4);
	TextDrawLetterSize(ListSelRZLeft, 0.500000, 1.000000);
	TextDrawColor(ListSelRZLeft, 16777215);
	TextDrawSetOutline(ListSelRZLeft, 0);
	TextDrawSetProportional(ListSelRZLeft, 1);
	TextDrawSetShadow(ListSelRZLeft, 1);
	TextDrawUseBox(ListSelRZLeft, 1);
	TextDrawBoxColor(ListSelRZLeft, 255);
	TextDrawTextSize(ListSelRZLeft, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelRZLeft, 1);


	ListSelRXRight = TextDrawCreate(560.000000, 150.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(ListSelRXRight, 255);
	TextDrawFont(ListSelRXRight, 4);
	TextDrawLetterSize(ListSelRXRight, 0.500000, 1.000000);
	TextDrawColor(ListSelRXRight, 16777215);
	TextDrawSetOutline(ListSelRXRight, 0);
	TextDrawSetProportional(ListSelRXRight, 1);
	TextDrawSetShadow(ListSelRXRight, 1);
	TextDrawUseBox(ListSelRXRight, 1);
	TextDrawBoxColor(ListSelRXRight, 255);
	TextDrawTextSize(ListSelRXRight, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelRXRight, 1);

	ListSelRYRight = TextDrawCreate(560.000000, 190.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(ListSelRYRight, 255);
	TextDrawFont(ListSelRYRight, 4);
	TextDrawLetterSize(ListSelRYRight, 0.500000, 1.000000);
	TextDrawColor(ListSelRYRight, 16777215);
	TextDrawSetOutline(ListSelRYRight, 0);
	TextDrawSetProportional(ListSelRYRight, 1);
	TextDrawSetShadow(ListSelRYRight, 1);
	TextDrawUseBox(ListSelRYRight, 1);
	TextDrawBoxColor(ListSelRYRight, 255);
	TextDrawTextSize(ListSelRYRight, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelRYRight, 1);

	ListSelRZRight = TextDrawCreate(560.000000, 230.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(ListSelRZRight, 255);
	TextDrawFont(ListSelRZRight, 4);
	TextDrawLetterSize(ListSelRZRight, 0.500000, 1.000000);
	TextDrawColor(ListSelRZRight, 16777215);
	TextDrawSetOutline(ListSelRZRight, 0);
	TextDrawSetProportional(ListSelRZRight, 1);
	TextDrawSetShadow(ListSelRZRight, 1);
	TextDrawUseBox(ListSelRZRight, 1);
	TextDrawBoxColor(ListSelRZRight, 255);
	TextDrawTextSize(ListSelRZRight, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelRZRight, 1);


	ListSelZoomLeft = TextDrawCreate(480.000000, 270.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(ListSelZoomLeft, 255);
	TextDrawFont(ListSelZoomLeft, 4);
	TextDrawLetterSize(ListSelZoomLeft, 0.500000, 1.000000);
	TextDrawColor(ListSelZoomLeft, 16777215);
	TextDrawSetOutline(ListSelZoomLeft, 0);
	TextDrawSetProportional(ListSelZoomLeft, 1);
	TextDrawSetShadow(ListSelZoomLeft, 1);
	TextDrawUseBox(ListSelZoomLeft, 1);
	TextDrawBoxColor(ListSelZoomLeft, 255);
	TextDrawTextSize(ListSelZoomLeft, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelZoomLeft, 1);

	ListSelZoomRight = TextDrawCreate(560.000000, 270.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(ListSelZoomRight, 255);
	TextDrawFont(ListSelZoomRight, 4);
	TextDrawLetterSize(ListSelZoomRight, 0.500000, 1.000000);
	TextDrawColor(ListSelZoomRight, 16777215);
	TextDrawSetOutline(ListSelZoomRight, 0);
	TextDrawSetProportional(ListSelZoomRight, 1);
	TextDrawSetShadow(ListSelZoomRight, 1);
	TextDrawUseBox(ListSelZoomRight, 1);
	TextDrawBoxColor(ListSelZoomRight, 255);
	TextDrawTextSize(ListSelZoomRight, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelZoomRight, 1);

	ListSelReset = TextDrawCreate(520.000000, 320.000000, "LD_BEAT:square");
	TextDrawBackgroundColor(ListSelReset, 255);
	TextDrawFont(ListSelReset, 4);
	TextDrawLetterSize(ListSelReset, 0.500000, 1.000000);
	TextDrawColor(ListSelReset, 16777215);
	TextDrawSetOutline(ListSelReset, 0);
	TextDrawSetProportional(ListSelReset, 1);
	TextDrawSetShadow(ListSelReset, 1);
	TextDrawUseBox(ListSelReset, 1);
	TextDrawBoxColor(ListSelReset, 255);
	TextDrawTextSize(ListSelReset, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelReset, 1);


	ListSelExit = TextDrawCreate(590.000000, 390.000000, "LD_BEAT:cross");
	TextDrawBackgroundColor(ListSelExit, 255);
	TextDrawFont(ListSelExit, 4);
	TextDrawLetterSize(ListSelExit, 0.500000, 1.000000);
	TextDrawColor(ListSelExit, 16777215);
	TextDrawSetOutline(ListSelExit, 0);
	TextDrawSetProportional(ListSelExit, 1);
	TextDrawSetShadow(ListSelExit, 1);
	TextDrawUseBox(ListSelExit, 1);
	TextDrawBoxColor(ListSelExit, 255);
	TextDrawTextSize(ListSelExit, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelExit, 1);


	ListSelClickLeft = TextDrawCreate(10.000000, 320.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(ListSelClickLeft, 255);
	TextDrawFont(ListSelClickLeft, 4);
	TextDrawLetterSize(ListSelClickLeft, 0.500000, 1.000000);
	TextDrawColor(ListSelClickLeft, 16777215);
	TextDrawSetOutline(ListSelClickLeft, 0);
	TextDrawSetProportional(ListSelClickLeft, 1);
	TextDrawSetShadow(ListSelClickLeft, 1);
	TextDrawUseBox(ListSelClickLeft, 1);
	TextDrawBoxColor(ListSelClickLeft, 255);
	TextDrawTextSize(ListSelClickLeft, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelClickLeft, 1);

	ListSelClickRight = TextDrawCreate(90.000000, 320.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(ListSelClickRight, 255);
	TextDrawFont(ListSelClickRight, 4);
	TextDrawLetterSize(ListSelClickRight, 0.500000, 1.000000);
	TextDrawColor(ListSelClickRight, 16777215);
	TextDrawSetOutline(ListSelClickRight, 0);
	TextDrawSetProportional(ListSelClickRight, 1);
	TextDrawSetShadow(ListSelClickRight, 1);
	TextDrawUseBox(ListSelClickRight, 1);
	TextDrawBoxColor(ListSelClickRight, 255);
	TextDrawTextSize(ListSelClickRight, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelClickRight, 1);

	ListSelSelectObject = TextDrawCreate(50.000000, 320.000000, "LD_BEAT:square");
	TextDrawBackgroundColor(ListSelSelectObject, 255);
	TextDrawFont(ListSelSelectObject, 4);
	TextDrawLetterSize(ListSelSelectObject, 0.500000, 1.000000);
	TextDrawColor(ListSelSelectObject, 0x00FF00FF);
	TextDrawSetOutline(ListSelSelectObject, 0);
	TextDrawSetProportional(ListSelSelectObject, 1);
	TextDrawSetShadow(ListSelSelectObject, 1);
	TextDrawUseBox(ListSelSelectObject, 1);
	TextDrawBoxColor(ListSelSelectObject, 255);
	TextDrawTextSize(ListSelSelectObject, 40.000000, 40.000000);
	TextDrawSetSelectable(ListSelSelectObject, 1);


	new Float:offx = 10.0, Float:offy = 110.0;
	for(new i = 0; i < MAX_LIST_OBJECTS; i++)
	{
		ListSelHighLight[i] = TextDrawCreate(offx, offy, "_");
		TextDrawLetterSize(ListSelHighLight[i], 0.200000, 1.000000);
		TextDrawUseBox(ListSelHighLight[i], 1);
		TextDrawBoxColor(ListSelHighLight[i], 150);
		TextDrawTextSize(ListSelHighLight[i], 200.000000, 8.000000);
	    offy += 10.0;

	}

	foreach(new i : Player) CreatePlayerListDraws(i);

	#if defined LS_OnFilterScriptInit
		LS_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit LS_OnFilterScriptInit
#if defined LS_OnFilterScriptInit
	forward LS_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
	TextDrawDestroy(ListSelBackGround_0);
	TextDrawDestroy(ListSelBackGround_1);
	TextDrawDestroy(ListSelBackGround_2);
	TextDrawDestroy(ListSelBackGround_3);

	TextDrawDestroy(ListSelRXLeft);
	TextDrawDestroy(ListSelRYLeft);
	TextDrawDestroy(ListSelRZLeft);
	TextDrawDestroy(ListSelRXRight);
	TextDrawDestroy(ListSelRYRight);
	TextDrawDestroy(ListSelRZRight);

	TextDrawDestroy(ListSelZoomLeft);
	TextDrawDestroy(ListSelZoomRight);

	TextDrawDestroy(ListSelReset);

	TextDrawDestroy(ListSelClickLeft);
	TextDrawDestroy(ListSelClickRight);

	TextDrawDestroy(ListSelSelectObject);

	TextDrawDestroy(ListSelExit);
	
	for(new i = 0; i < MAX_LIST_OBJECTS; i++) TextDrawDestroy(ListSelHighLight[i]);

	foreach(new i : Player)
	{
		for(new j = 0; j < MAX_LIST_OBJECTS; j++) PlayerTextDrawDestroy(i, ListObjects[i][j]);
		PlayerTextDrawDestroy(i, ListModel[i]);
		DisablePlayerCheckpoint(i);
	}

	#if defined LS_OnFilterScriptExit
		LS_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit LS_OnFilterScriptExit
#if defined LS_OnFilterScriptExit
	forward LS_OnFilterScriptExit();
#endif

public OnPlayerConnect(playerid)
{
	CreatePlayerListDraws(playerid);
	CurrListOffset[playerid] = 0;
	CurrListHighlight[playerid] = 0;
	CurrListHighlightObject[playerid] = -1;

	#if defined LS_OnPlayerConnect
		LS_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect LS_OnPlayerConnect
#if defined LS_OnPlayerConnect
	forward LS_OnPlayerConnect(playerid);
#endif

static CreatePlayerListDraws(playerid)
{
	new Float:offx = 10.0, Float:offy = 110.0;
	
	// Create all textdraws
	for(new i = 0; i < MAX_LIST_OBJECTS; i++)
	{
		ListObjects[playerid][i] = CreatePlayerTextDraw(playerid,offx, offy, "Empty");
		PlayerTextDrawBackgroundColor(playerid,ListObjects[playerid][i], 255);
		PlayerTextDrawFont(playerid,ListObjects[playerid][i], 1);
		PlayerTextDrawLetterSize(playerid,ListObjects[playerid][i], 0.200000, 1.000000);
		PlayerTextDrawColor(playerid,ListObjects[playerid][i], 16711935);
		PlayerTextDrawSetOutline(playerid,ListObjects[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid,ListObjects[playerid][i], 1);
		PlayerTextDrawUseBox(playerid,ListObjects[playerid][i], 1);
		PlayerTextDrawBoxColor(playerid,ListObjects[playerid][i], 0);
		PlayerTextDrawTextSize(playerid,ListObjects[playerid][i], 200.000000, 8.000000);
		PlayerTextDrawSetSelectable(playerid,ListObjects[playerid][i], 1);
	    offy += 10.0;
	}
	
	ListModel[playerid] = CreatePlayerTextDraw(playerid,170.000000, 110.000000, "Preview");
	PlayerTextDrawBackgroundColor(playerid,ListModel[playerid], 0);
	PlayerTextDrawFont(playerid,ListModel[playerid], 5);
	PlayerTextDrawLetterSize(playerid,ListModel[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid,ListModel[playerid], -1);
	PlayerTextDrawSetOutline(playerid,ListModel[playerid], 0);
	PlayerTextDrawSetProportional(playerid,ListModel[playerid], 1);
	PlayerTextDrawSetShadow(playerid,ListModel[playerid], 1);
	PlayerTextDrawUseBox(playerid,ListModel[playerid], 1);
	PlayerTextDrawBoxColor(playerid,ListModel[playerid], 0);
	PlayerTextDrawTextSize(playerid,ListModel[playerid], 300.000000, 300.000000);
	
	return 1;
}

ClickTextDrawListSel(playerid, Text:clickedid)
{
	if(clickedid == Text:INVALID_TEXT_DRAW)
	{
	    return 1;
	}
	
	else if(clickedid == ListSelExit)
	{
		TextDrawHideForPlayer(playerid, ListSelBackGround_0);
		TextDrawHideForPlayer(playerid, ListSelBackGround_1);
		TextDrawHideForPlayer(playerid, ListSelBackGround_2);
		TextDrawHideForPlayer(playerid, ListSelBackGround_3);

		TextDrawHideForPlayer(playerid, ListSelRXLeft);
		TextDrawHideForPlayer(playerid, ListSelRYLeft);
		TextDrawHideForPlayer(playerid, ListSelRZLeft);
		TextDrawHideForPlayer(playerid, ListSelRXRight);
		TextDrawHideForPlayer(playerid, ListSelRYRight);
		TextDrawHideForPlayer(playerid, ListSelRZRight);

		TextDrawHideForPlayer(playerid, ListSelZoomLeft);
		TextDrawHideForPlayer(playerid, ListSelZoomRight);

		TextDrawHideForPlayer(playerid, ListSelReset);

		TextDrawHideForPlayer(playerid, ListSelClickLeft);
		TextDrawHideForPlayer(playerid, ListSelClickRight);

		TextDrawHideForPlayer(playerid, ListSelSelectObject);

		TextDrawHideForPlayer(playerid, ListSelExit);

		foreach(new i : Player)
		{
			for(new j = 0; j < MAX_LIST_OBJECTS; j++) PlayerTextDrawHide(i, ListObjects[i][j]);
			PlayerTextDrawHide(i, ListModel[i]);
		}

		HideListSelHighLights(playerid);
		
		if(CurrListHighlightObject[playerid] > -1)
		{
			new i = CurrListHighlightObject[playerid];
			DestroyDynamicObject(ObjectData[i][oID]);
			ObjectData[i][oID] = CreateDynamicObject(ObjectData[i][oModel], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);

		    UpdateMaterial(CurrListHighlightObject[playerid]);
            UpdateObjectText(CurrListHighlightObject[playerid]);
			CurrListHighlightObject[playerid] = -1;

			// Update the streamer
			foreach(new j : Player)
			{
			    if(IsPlayerInRangeOfPoint(j, 300.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ])) Streamer_Update(j);
			}
		}

	    SetEditMode(playerid, EDIT_MODE_NONE);
	    SetCurrTextDraw(playerid, TEXTDRAW_NONE);
		EditingMode[playerid] = false;
		DisablePlayerCheckpoint(playerid);
		CancelSelectTextDraw(playerid);
	}
	
	// Clicked left
    else if(clickedid == ListSelRXLeft)
    {
        ListSelData[playerid][LRX] -= 45.0;
        if(ListSelData[playerid][LRX] < 0.0) ListSelData[playerid][LRX] = 315.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelRYLeft)
    {
        ListSelData[playerid][LRY] -= 45.0;
        if(ListSelData[playerid][LRY] < 0.0) ListSelData[playerid][LRY] = 315.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelRZLeft)
    {
        ListSelData[playerid][LRZ] -= 45.0;
        if(ListSelData[playerid][LRZ] < 0.0) ListSelData[playerid][LRZ] = 315.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelRXRight)
    {
        ListSelData[playerid][LRX] += 45.0;
        if(ListSelData[playerid][LRX] > 359.9) ListSelData[playerid][LRX] = 0.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelRYRight)
    {
        ListSelData[playerid][LRY] += 45.0;
        if(ListSelData[playerid][LRY] > 359.9) ListSelData[playerid][LRY] = 0.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelRZRight)
    {
        ListSelData[playerid][LRZ] += 45.0;
        if(ListSelData[playerid][LRZ] > 359.9) ListSelData[playerid][LRZ] = 0.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelZoomLeft)
    {
        if(ListSelData[playerid][LZoom] < 1.5) ListSelData[playerid][LZoom] += 0.1;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelZoomRight)
    {
        if(ListSelData[playerid][LZoom] > 0.5) ListSelData[playerid][LZoom] -= 0.1;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }

    else if(clickedid == ListSelReset)
    {
		ListSelData[playerid][LRX] = 0.0;
		ListSelData[playerid][LRY] = 0.0;
		ListSelData[playerid][LRZ] = 0.0;
        ListSelData[playerid][LZoom] = 1.0;
        UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid], false);
    }


	else if(clickedid == ListSelClickLeft)
	{
		CurrListOffset[playerid] -= MAX_LIST_OBJECTS;
		if(CurrListOffset[playerid] < 0) CurrListOffset[playerid] = MAX_TEXTURE_OBJECTS - MAX_LIST_OBJECTS;
        UpdateObjectList(playerid, CurrListOffset[playerid]);
		UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid]);
	}

	else if(clickedid == ListSelClickRight)
	{
		CurrListOffset[playerid] += MAX_LIST_OBJECTS;
		if(CurrListOffset[playerid] == MAX_TEXTURE_OBJECTS) CurrListOffset[playerid] = 0;
        UpdateObjectList(playerid, CurrListOffset[playerid]);
		UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid]);
	}

    else if(clickedid == ListSelSelectObject)
	{
		if(Iter_Contains(Objects, CurrListOffset[playerid]+CurrListHighlight[playerid]))
		{
            if(SetCurrObject(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid])) {
                new line[128];
                format(line, sizeof(line), "You have selected object index %i for editing", CurrListOffset[playerid]+CurrListHighlight[playerid]);
                SendClientMessage(playerid, STEALTH_GREEN, line);
            }
            else
                SendClientMessage(playerid, STEALTH_YELLOW, "You can not select objects in this object's group");
		}
		else
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "That object does not exist!");
		}
	}


	return 1;
}

ClickPlayerTextListSel(playerid, PlayerText:playertextid)
{
	for(new i = 0; i < MAX_LIST_OBJECTS; i++)
	{
        if(playertextid == ListObjects[playerid][i])
		{
			UpdateListPreview(playerid, CurrListOffset[playerid]+i);
			HideListSelHighLights(playerid);
			TextDrawShowForPlayer(playerid, ListSelHighLight[i]);
			CurrListHighlight[playerid] = i;
			return 1;
		}
	}

	return 1;
}

static HideListSelHighLights(playerid)
{
	for(new i = 0; i < MAX_LIST_OBJECTS; i++) TextDrawHideForPlayer(playerid, ListSelHighLight[i]);
	return 1;
}


OnPlayerKeyStateChangeLSel(playerid,newkeys,oldkeys)
{
	#pragma unused oldkeys
	if(GetEditMode(playerid) == EDIT_MODE_LISTSEL)
	{
		if( (newkeys & KEY_NO) || (FlyMode[playerid] && newkeys & KEY_JUMP) ) SelectTextDraw(playerid, 0xD9D919FF);
		return 1;
	}
	return 0;
}


YCMD:lsel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Display a list of all objects currently loaded to select from.");
		return 1;
	}

	NoEditingMode(playerid);
    MapOpenCheck();
    
    if(!isnull(arg))
	{
		CurrListOffset[playerid] = (strval(arg) / MAX_LIST_OBJECTS) * MAX_LIST_OBJECTS;
        CurrListHighlight[playerid] = strval(arg) % MAX_LIST_OBJECTS;
	}
    else if(CurrObject[playerid] > -1)
	{
		CurrListOffset[playerid] = (CurrObject[playerid] / MAX_LIST_OBJECTS) * MAX_LIST_OBJECTS;
		CurrListHighlight[playerid] = (CurrObject[playerid] % MAX_LIST_OBJECTS);
	}
    else
	{
		CurrListOffset[playerid] = 0;
        CurrListHighlight[playerid] = 0;
	}

	//printf("Offset: %i, Highlight: %i", CurrListOffset[playerid], CurrListHighlight[playerid]);


    HideGUIInterface(playerid);

    SetEditMode(playerid, EDIT_MODE_LISTSEL);
    SetCurrTextDraw(playerid, TEXTDRAW_LISTSEL);
	EditingMode[playerid] = true;
//	CurrListOffset[playerid] = 0;
	ShowObjectList(playerid);
	ListSelData[playerid][LRX] = 0.0;
	ListSelData[playerid][LRY] = 0.0;
	ListSelData[playerid][LRZ] = 0.0;
	ListSelData[playerid][LZoom] = 1.0;

	UpdateObjectList(playerid, CurrListOffset[playerid]);
	UpdateListPreview(playerid, CurrListOffset[playerid]+CurrListHighlight[playerid]);
	TextDrawShowForPlayer(playerid, ListSelHighLight[CurrListHighlight[playerid]]);

	// Select textdraw mode
	SelectTextDraw(playerid, 0xD9D919FF);
	return 1;
}

static ShowObjectList(playerid)
{
	TextDrawShowForPlayer(playerid, ListSelBackGround_0);
	TextDrawShowForPlayer(playerid, ListSelBackGround_1);
	TextDrawShowForPlayer(playerid, ListSelBackGround_2);
	TextDrawShowForPlayer(playerid, ListSelBackGround_3);

	TextDrawShowForPlayer(playerid, ListSelRXLeft);
	TextDrawShowForPlayer(playerid, ListSelRYLeft);
	TextDrawShowForPlayer(playerid, ListSelRZLeft);
	TextDrawShowForPlayer(playerid, ListSelRXRight);
	TextDrawShowForPlayer(playerid, ListSelRYRight);
	TextDrawShowForPlayer(playerid, ListSelRZRight);

	TextDrawShowForPlayer(playerid, ListSelZoomLeft);
	TextDrawShowForPlayer(playerid, ListSelZoomRight);
	
	TextDrawShowForPlayer(playerid, ListSelReset);

	TextDrawShowForPlayer(playerid, ListSelClickLeft);
	TextDrawShowForPlayer(playerid, ListSelClickRight);
	TextDrawShowForPlayer(playerid, ListSelSelectObject);

	TextDrawShowForPlayer(playerid, ListSelExit);

	for(new i = 0; i < MAX_LIST_OBJECTS; i++) PlayerTextDrawShow(playerid, ListObjects[playerid][i]);
    PlayerTextDrawShow(playerid, ListModel[playerid]);

	return 1;
}

static UpdateObjectList(playerid, offset)
{
    new line[64], modelarray;

	for(new i = 0; i < MAX_LIST_OBJECTS; i++)
	{
		if(Iter_Contains(Objects, offset+i))
		{
			modelarray = GetModelArray(ObjectData[offset+i][oModel]);
			if(modelarray > -1) format(line, sizeof(line), "%i) %s - Model: %i", offset+i, GetModelName(ObjectData[offset+i][oModel]), ObjectData[offset+i][oModel]);
			else format(line, sizeof(line), "%i) Unknown - Model: %i", offset+i, ObjectData[offset+i][oModel]);
            PlayerTextDrawSetString(playerid, ListObjects[playerid][i], line);
            
		}
		else
		{
			format(line, sizeof(line), "%i) Empty", offset+i);
			PlayerTextDrawSetString(playerid, ListObjects[playerid][i], line);
		}
	}
	return 1;
}

static UpdateListPreview(playerid, index, bool:update = true)
{
	if(Iter_Contains(Objects, index))
	{
		PlayerTextDrawSetPreviewModel(playerid, ListModel[playerid], ObjectData[index][oModel]);
		PlayerTextDrawSetPreviewRot(playerid, ListModel[playerid], ListSelData[playerid][LRX], ListSelData[playerid][LRY], ListSelData[playerid][LRZ], ListSelData[playerid][LZoom]);
		PlayerTextDrawShow(playerid, ListModel[playerid]);

		if(update)
		{
			new i = CurrListHighlightObject[playerid];
			if(i > -1)
			{
				DestroyDynamicObject(ObjectData[i][oID]);
				ObjectData[i][oID] = CreateDynamicObject(ObjectData[i][oModel], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);

			    UpdateMaterial(CurrListHighlightObject[playerid]);
	            UpdateObjectText(CurrListHighlightObject[playerid]);

				// Update the streamer
				foreach(new j : Player)
				{
				    if(IsPlayerInRangeOfPoint(j, 300.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ])) Streamer_Update(j);
				}
			}
			HighlightObject(index);
			CurrListHighlightObject[playerid] = index;

			new Float:colradius = GetColSphereRadius(ObjectData[index][oModel]);
	        SetPlayerCheckpoint(playerid, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], colradius);
		}
	}
	else
	{
		PlayerTextDrawSetPreviewModel(playerid, ListModel[playerid], NO_OBJECT_IN_SLOT_MODEL);
		PlayerTextDrawSetPreviewRot(playerid, ListModel[playerid], 0.0, 0.0, 0.0, 1.0);
		PlayerTextDrawShow(playerid, ListModel[playerid]);

		if(CurrListHighlightObject[playerid] > -1)
		{
			new i = CurrListHighlightObject[playerid];
			DestroyDynamicObject(ObjectData[i][oID]);
			ObjectData[i][oID] = CreateDynamicObject(ObjectData[i][oModel], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);

		    UpdateMaterial(CurrListHighlightObject[playerid]);
            UpdateObjectText(CurrListHighlightObject[playerid]);
			CurrListHighlightObject[playerid] = -1;
			DisablePlayerCheckpoint(playerid);

			// Update the streamer
			foreach(new j : Player)
			{
			    if(IsPlayerInRangeOfPoint(j, 300.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ])) Streamer_Update(j);
			}
		}
	}
	return 1;
}
