
#define         MAX_SEARCH_OBJECT           200
#define         MAX_OS_PAGE                 20

#define         OS_MIN_ZOOM_CONSTRAINT      2.0
#define         OS_MAX_ZOOM_CONSTRAINT      0.5

static Text:RotXLeft;
static Text:RotYLeft;
static Text:RotZLeft;
static Text:ZoomLeft;
static Text:RotXRight;
static Text:RotYRight;
static Text:RotZRight;
static Text:ZoomRight;
static Text:PageLeft;
static Text:PageRight;
static Text:Click_OS_Create;
static Text:OS_Background_0;
static Text:OS_Background_1;
static Text:OS_Background_2;
static Text:OS_Background_3;
static Text:OSearch_HighLight[MAX_OS_PAGE];

static PlayerText:SearchDisplayModel[MAX_PLAYERS];
static PlayerText:OSearchIndex[MAX_PLAYERS][MAX_OS_PAGE];

enum SEARCHINFO
{
	SearchModel,
	SearchName[50],
}
static SearchObjects[MAX_PLAYERS][MAX_SEARCH_OBJECT][SEARCHINFO];
static TotalObjectFound[MAX_PLAYERS];
static CurrObjectPage[MAX_PLAYERS];
static CurrOSHighlight[MAX_PLAYERS];
static Float:CurrOSXRot[MAX_PLAYERS] = { -20.0, ... };
static Float:CurrOSYRot[MAX_PLAYERS] = { 0.0, ... };
static Float:CurrOSZRot[MAX_PLAYERS] = { -50.0, ... };
static Float:CurrOSZoom[MAX_PLAYERS] = { 1.0, ... };

enum {
	//==, !=, >, <, >=, <=
	OPER_EQUAL,
	OPER_NOT_EQUAL,
	OPER_MORE,
	OPER_LESS,
	OPER_MORE_EQUAL,
	OPER_LESS_EQUAL,
	
	//+, -, *, /, %
	OPER_PLUS,
	OPER_MINUS,
	OPER_MULT,
	OPER_DIV,
	OPER_MOD,

	//!, &&, ||
	OPER_NOT,
	OPER_AND,
	OPER_OR,

	//(, )
	OPER_OPEN,
	OPER_CLOSE,
	
	NUMERIC
}

static Operators[16][3] = {
	"==", "!=", ">", "<", ">=", "<=",
	"+", "-", "*", "/", "%",
	"!", "&&", "||",
	"(", ")"
};

public OnFilterScriptInit()
{
	CreateSearchDraws();
	foreach(new i : Player)
	{
		CreatePlayerSearchDraw(i);
	}

	#if defined OS_OnFilterScriptInit
		OS_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit OS_OnFilterScriptInit
#if defined OS_OnFilterScriptInit
	forward OS_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
	DestroySearchDraws();
	foreach(new i : Player)
	{
	    DestroyPlayerSearchDraw(i);
	}

	#if defined OS_OnFilterScriptExit
		OS_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit OS_OnFilterScriptExit
#if defined OS_OnFilterScriptExit
	forward OS_OnFilterScriptExit();
#endif


public OnPlayerConnect(playerid)
{
    CreatePlayerSearchDraw(playerid);
	CurrOSXRot[playerid] = -20.0;
	CurrOSYRot[playerid] = 0.0;
	CurrOSZRot[playerid] = -50.0;
	CurrOSZoom[playerid] = 1.0;

	#if defined OS_OnPlayerConnect
		OS_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect OS_OnPlayerConnect
#if defined OS_OnPlayerConnect
	forward OS_OnPlayerConnect(playerid);
#endif

// Search for object names
YCMD:osearch(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Search for an object model by keyword.");
		return 1;
	}

	if(GetEditMode(playerid) != EDIT_MODE_OSEARCH) NoEditingMode(playerid);

    MapOpenCheck();

	for(new i = 0; i < MAX_SEARCH_OBJECT; i++) SearchObjects[playerid][i][SearchModel] = -1;
	new line[128];
	new totalobjectsfound;
	for(new i; i < sizeof(ObjectList); i++)
	{
        if(strfind(ObjectList[i][oName],arg, true) != -1)
		{
			if(totalobjectsfound == 0) SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	        format(line, sizeof(line), "Object Name: %s Model ID: %i", ObjectList[i][oName],ObjectList[i][oID]);
	        SendClientMessage(playerid, STEALTH_GREEN, line);
	        SearchObjects[playerid][totalobjectsfound][SearchModel] = ObjectList[i][oID];
	        format(SearchObjects[playerid][totalobjectsfound][SearchName], 50, "%s", ObjectList[i][oName]);
	        totalobjectsfound++;
		}
        if(totalobjectsfound == MAX_SEARCH_OBJECT)
        {
            SendClientMessage(playerid, STEALTH_YELLOW, "Maximum amount of objects found!");
            break;
        }
	}

	if(!totalobjectsfound)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "No objects found try searching again");
	}
	else
	{
		format(line, sizeof(line), "Total Objects Found: %i", totalobjectsfound);
		TotalObjectFound[playerid] = totalobjectsfound;
		ShowObjectList(playerid);
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	return 1;
}

// Search for objects with expression
YCMD:osearchex(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Search for an object model by expression.");
		return 1;
	}

	if(GetEditMode(playerid) != EDIT_MODE_OSEARCH) NoEditingMode(playerid);

    MapOpenCheck();

	new out[64][24], type[64] = {-1, ...}, count = strexplode(out, arg, " ");
	for(new i = 0; i < MAX_SEARCH_OBJECT; i++) SearchObjects[playerid][i][SearchModel] = -1;
	new line[128];
	new totalobjectsfound, index;
	
	for(new c; c < count; c++) {
		if(!strcmp(out[c], "X", true)) {
			type[c] = NUMERIC;
			continue;
		}
		if(!strcmp(out[c], "Y", true)) {
			type[c] = NUMERIC;
			continue;
		}
		if(!strcmp(out[c], "Z", true)) {
			type[c] = NUMERIC;
			continue;
		}

		for(new i; i < sizeof Operators; i++) {
			if(!strcmp(out[c], Operators[i])) {
				type[c] = i;
				break;
			}
		}
		if(type[c] == -1 && isnumeric_f(out[c])) {
			type[c] = NUMERIC;
		}
	}

	new str[128];
	strcat(str, "SELECT `Model` FROM `AABB` WHERE (");
	for(new c; c < count; c++) {
		if(out[c][0] == 'X')
			format(out[c], sizeof out[], "(MaxX - MinX)");
		else if(out[c][0] == 'Y')
			format(out[c], sizeof out[], "(MaxY - MinY)");
		else if(out[c][0] == 'Z')
			format(out[c], sizeof out[], "(MaxZ - MinZ)");
		else switch(type[c]) {
			case OPER_AND:
				format(out[c], sizeof out[], " AND ");
			case OPER_OR:
				format(out[c], sizeof out[], " OR ");
			case OPER_NOT:
				format(out[c], sizeof out[], " NOT ");
		}
		
		strcat(str, out[c]);
	}
	strcat(str, ")");
	
	MS_RESULT = db_query(MS_DB, str);
	totalobjectsfound = db_num_rows(MS_RESULT);
	if(totalobjectsfound) {
		do
		{
			new model = db_get_field_int(MS_RESULT, 0), i = -1;
			
			for(new l; l < sizeof(ObjectList); l++) {
				if(ObjectList[l][oID] == model) {
					i = l;
					break;
				}
			}
			
			if(i == -1) // Invalid Model
				continue;

			if(index == 0) SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			format(line, sizeof(line), "Object Name: %s Model ID: %i", ObjectList[i][oName],ObjectList[i][oID]);
			SendClientMessage(playerid, STEALTH_GREEN, line);
			SearchObjects[playerid][index][SearchModel] = ObjectList[i][oID];
			format(SearchObjects[playerid][index][SearchName], 50, "%s", ObjectList[i][oName]);
			index++;

			if(index == MAX_SEARCH_OBJECT)
			{
				SendClientMessage(playerid, STEALTH_YELLOW, "Maximum amount of objects found!");
				break;
			}
		}
		while(db_next_row(MS_RESULT));
		
		format(line, sizeof(line), "Total Objects Found: %i", totalobjectsfound);
		TotalObjectFound[playerid] = totalobjectsfound;
		ShowObjectList(playerid);
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else {
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "No objects found try searching again");
	}
	db_free_result(MS_RESULT);

	return 1;
}

ClickTextDrawOSearch(playerid, Text:clickedid)
{
	if (Text:INVALID_TEXT_DRAW == clickedid)
	{
		// Textdraws are now closed
	    ToggleTextDrawOpen(playerid, false);

	    // Player is not in text editing mode anymore
    	SetCurrTextDraw(playerid, TEXTDRAW_NONE);

		// Hide the text editor
	    HidePlayerOSDraws(playerid);

		// Cancel textdraw select
		CancelSelectTextDraw(playerid);
		
		// Editing mode off
		EditingMode[playerid] = false;

		// Click finished processing
		SetEditMode(playerid, EDIT_MODE_NONE);
		
		// Unpause
		SetTimerEx("PlayerSetGUIPaused", 300, false, "ii", playerid, 0);

	    return 1;
	}

	// Rotate XLeft
	else if(RotXLeft == clickedid)
	{
        CurrOSXRot[playerid] -= 10.0;
        if(CurrOSXRot[playerid] < 0.0) CurrOSXRot[playerid] = 350.0;
        UpdateOSPreview(playerid);
	}

	else if(RotYLeft == clickedid)
	{
        CurrOSYRot[playerid] -= 10.0;
        if(CurrOSYRot[playerid] < 0.0) CurrOSYRot[playerid] = 350.0;
        UpdateOSPreview(playerid);
	}

	else if(RotZLeft == clickedid)
	{
        CurrOSZRot[playerid] -= 10.0;
        if(CurrOSZRot[playerid] < 0.0) CurrOSZRot[playerid] = 350.0;
        UpdateOSPreview(playerid);
	}

	else if(RotXRight == clickedid)
	{
        CurrOSXRot[playerid] += 10.0;
        if(CurrOSXRot[playerid] > 359.0) CurrOSXRot[playerid] = 0.0;
        UpdateOSPreview(playerid);
	}

	else if(RotYRight == clickedid)
	{
        CurrOSYRot[playerid] += 10.0;
        if(CurrOSYRot[playerid] > 359.0) CurrOSYRot[playerid] = 0.0;
        UpdateOSPreview(playerid);
	}

	else if(RotZRight == clickedid)
	{
        CurrOSZRot[playerid] += 10.0;
        if(CurrOSZRot[playerid] > 359.0) CurrOSZRot[playerid] = 0.0;
        UpdateOSPreview(playerid);
	}

	else if(ZoomLeft == clickedid)
	{
		if(CurrOSZoom[playerid] > OS_MIN_ZOOM_CONSTRAINT) return 1;
		CurrOSZoom[playerid] += 0.1;
		UpdateOSPreview(playerid);
	}

	else if(ZoomRight == clickedid)
	{
		if(CurrOSZoom[playerid] < OS_MAX_ZOOM_CONSTRAINT) return 1;
		CurrOSZoom[playerid] -= 0.1;
		UpdateOSPreview(playerid);
	}

	// Scroll object page left
	else if(PageLeft == clickedid)
	{
	    if(CurrObjectPage[playerid] == 0) CurrObjectPage[playerid] = (MAX_SEARCH_OBJECT / MAX_OS_PAGE) - 1;
		else CurrObjectPage[playerid]--;
		UpdateOSearchPage(playerid);
	}

	// Scroll object page right
	else if(PageRight == clickedid)
	{
		if(CurrObjectPage[playerid] == (MAX_SEARCH_OBJECT / MAX_OS_PAGE) - 1) CurrObjectPage[playerid] = 0;
        else CurrObjectPage[playerid]++;
		UpdateOSearchPage(playerid);
	}

	else if(Click_OS_Create == clickedid)
	{
		new index = (CurrObjectPage[playerid]*MAX_OS_PAGE) + CurrOSHighlight[playerid];
		if(SearchObjects[playerid][index][SearchModel] > -1)
		{
			new line[128];
			format(line, sizeof(line), "/cobject %i", SearchObjects[playerid][index][SearchModel]);
			EditingMode[playerid] = false;
		    BroadcastCommand(playerid,line);
			EditingMode[playerid] = true;
		}
	}

	return 0;
}

ClickPlayerTextDrawOSearch(playerid, PlayerText:clickedid)
{
	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
	    if(clickedid == OSearchIndex[playerid][i])
	    {
			CurrOSHighlight[playerid] = i;
		    UpdateOSHighLight(playerid);
		    UpdateOSPreview(playerid);
			return 1;
	    }
	}
	return 0;
}

static ShowObjectList(playerid)
{
	ShowPlayerOSDraws(playerid);
	UpdateOSearchPage(playerid);
	SetCurrTextDraw(playerid, TEXTDRAW_OSEARCH);
	ToggleTextDrawOpen(playerid, true);
	SetEditMode(playerid, EDIT_MODE_OSEARCH);
	EditingMode[playerid] = true;
	CurrObjectPage[playerid] = 0;
	CurrOSHighlight[playerid] = 0;
	UpdateOSHighLight(playerid);
	SelectTextDraw(playerid, 0xD9D919FF);
	return 1;
}

static UpdateOSHighLight(playerid)
{
	for(new i = 0; i < MAX_OS_PAGE; i++) TextDrawHideForPlayer(playerid, OSearch_HighLight[i]);
	TextDrawShowForPlayer(playerid, OSearch_HighLight[CurrOSHighlight[playerid]]);
	UpdateOSPreview(playerid);
	return 1;
}

static UpdateOSPreview(playerid)
{
    new offset = CurrObjectPage[playerid]*MAX_OS_PAGE;
    PlayerTextDrawHide(playerid, SearchDisplayModel[playerid]);
	PlayerTextDrawSetPreviewModel(playerid, SearchDisplayModel[playerid], SearchObjects[playerid][CurrOSHighlight[playerid]+offset][SearchModel]);
	PlayerTextDrawSetPreviewRot(playerid, SearchDisplayModel[playerid], CurrOSXRot[playerid], CurrOSYRot[playerid], CurrOSZRot[playerid], CurrOSZoom[playerid]);
    PlayerTextDrawShow(playerid, SearchDisplayModel[playerid]);
	return 1;
}

static UpdateOSearchPage(playerid)
{
	new line[128];
	new offset = CurrObjectPage[playerid]*MAX_OS_PAGE;
	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
		if(SearchObjects[playerid][i+offset][SearchModel] > -1)
		{
			format(line, sizeof(line), "~r~ID:~g~ %i ~r~Name:~g~ %s",
			    SearchObjects[playerid][i+offset][SearchModel],
			    SearchObjects[playerid][i+offset][SearchName]
			);
            PlayerTextDrawSetString(playerid, OSearchIndex[playerid][i], line);
		}
		else PlayerTextDrawSetString(playerid, OSearchIndex[playerid][i], "~r~ID:~g~ -1 ~r~Name:~g~ None");
	}
	UpdateOSPreview(playerid);
	return 1;
}


static CreateSearchDraws()
{
	RotXLeft = TextDrawCreate(150.000000, 320.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(RotXLeft, 255);
	TextDrawFont(RotXLeft, 4);
	TextDrawLetterSize(RotXLeft, 0.500000, 1.000000);
	TextDrawColor(RotXLeft, 16777215);
	TextDrawSetOutline(RotXLeft, 0);
	TextDrawSetProportional(RotXLeft, 1);
	TextDrawSetShadow(RotXLeft, 1);
	TextDrawUseBox(RotXLeft, 1);
	TextDrawBoxColor(RotXLeft, 16777215);
	TextDrawTextSize(RotXLeft, 20.000000, 20.000000);
	TextDrawSetSelectable(RotXLeft, 1);

	RotYLeft = TextDrawCreate(150.000000, 340.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(RotYLeft, 255);
	TextDrawFont(RotYLeft, 4);
	TextDrawLetterSize(RotYLeft, 0.500000, 1.000000);
	TextDrawColor(RotYLeft, 16777215);
	TextDrawSetOutline(RotYLeft, 0);
	TextDrawSetProportional(RotYLeft, 1);
	TextDrawSetShadow(RotYLeft, 1);
	TextDrawUseBox(RotYLeft, 1);
	TextDrawBoxColor(RotYLeft, 16777215);
	TextDrawTextSize(RotYLeft, 20.000000, 20.000000);
	TextDrawSetSelectable(RotYLeft, 1);

	RotZLeft = TextDrawCreate(150.000000, 360.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(RotZLeft, 255);
	TextDrawFont(RotZLeft, 4);
	TextDrawLetterSize(RotZLeft, 0.500000, 1.000000);
	TextDrawColor(RotZLeft, 16777215);
	TextDrawSetOutline(RotZLeft, 0);
	TextDrawSetProportional(RotZLeft, 1);
	TextDrawSetShadow(RotZLeft, 1);
	TextDrawUseBox(RotZLeft, 1);
	TextDrawBoxColor(RotZLeft, 16777215);
	TextDrawTextSize(RotZLeft, 20.000000, 20.000000);
	TextDrawSetSelectable(RotZLeft, 1);

	ZoomLeft = TextDrawCreate(150.000000, 380.000000, "LD_BEAT:left");
	TextDrawBackgroundColor(ZoomLeft, 255);
	TextDrawFont(ZoomLeft, 4);
	TextDrawLetterSize(ZoomLeft, 0.500000, 1.000000);
	TextDrawColor(ZoomLeft, 16777215);
	TextDrawSetOutline(ZoomLeft, 0);
	TextDrawSetProportional(ZoomLeft, 1);
	TextDrawSetShadow(ZoomLeft, 1);
	TextDrawUseBox(ZoomLeft, 1);
	TextDrawBoxColor(ZoomLeft, 16777215);
	TextDrawTextSize(ZoomLeft, 20.000000, 20.000000);
	TextDrawSetSelectable(ZoomLeft, 1);

	RotXRight = TextDrawCreate(190.000000, 320.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(RotXRight, 255);
	TextDrawFont(RotXRight, 4);
	TextDrawLetterSize(RotXRight, 0.500000, 1.000000);
	TextDrawColor(RotXRight, 16777215);
	TextDrawSetOutline(RotXRight, 0);
	TextDrawSetProportional(RotXRight, 1);
	TextDrawSetShadow(RotXRight, 1);
	TextDrawUseBox(RotXRight, 1);
	TextDrawBoxColor(RotXRight, 16777215);
	TextDrawTextSize(RotXRight, 20.000000, 20.000000);
	TextDrawSetSelectable(RotXRight, 1);

	RotYRight = TextDrawCreate(190.000000, 340.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(RotYRight, 255);
	TextDrawFont(RotYRight, 4);
	TextDrawLetterSize(RotYRight, 0.500000, 1.000000);
	TextDrawColor(RotYRight, 16777215);
	TextDrawSetOutline(RotYRight, 0);
	TextDrawSetProportional(RotYRight, 1);
	TextDrawSetShadow(RotYRight, 1);
	TextDrawUseBox(RotYRight, 1);
	TextDrawBoxColor(RotYRight, 16777215);
	TextDrawTextSize(RotYRight, 20.000000, 20.000000);
	TextDrawSetSelectable(RotYRight, 1);

	RotZRight = TextDrawCreate(190.000000, 360.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(RotZRight, 255);
	TextDrawFont(RotZRight, 4);
	TextDrawLetterSize(RotZRight, 0.500000, 1.000000);
	TextDrawColor(RotZRight, 16777215);
	TextDrawSetOutline(RotZRight, 0);
	TextDrawSetProportional(RotZRight, 1);
	TextDrawSetShadow(RotZRight, 1);
	TextDrawUseBox(RotZRight, 1);
	TextDrawBoxColor(RotZRight, 16777215);
	TextDrawTextSize(RotZRight, 20.000000, 20.000000);
	TextDrawSetSelectable(RotZRight, 1);

	ZoomRight = TextDrawCreate(190.000000, 380.000000, "LD_BEAT:right");
	TextDrawBackgroundColor(ZoomRight, 255);
	TextDrawFont(ZoomRight, 4);
	TextDrawLetterSize(ZoomRight, 0.500000, 1.000000);
	TextDrawColor(ZoomRight, 16777215);
	TextDrawSetOutline(ZoomRight, 0);
	TextDrawSetProportional(ZoomRight, 1);
	TextDrawSetShadow(ZoomRight, 1);
	TextDrawUseBox(ZoomRight, 1);
	TextDrawBoxColor(ZoomRight, 16777215);
	TextDrawTextSize(ZoomRight, 20.000000, 20.000000);
	TextDrawSetSelectable(ZoomRight, 1);
	

	new Float:pageoffset = 145.0 + (MAX_OS_PAGE * 10.0);

	PageLeft = TextDrawCreate(18.000000, pageoffset, "LD_BEAT:left");
	TextDrawBackgroundColor(PageLeft, 255);
	TextDrawFont(PageLeft, 4);
	TextDrawLetterSize(PageLeft, 0.500000, 1.000000);
	TextDrawColor(PageLeft, 16777215);
	TextDrawSetOutline(PageLeft, 0);
	TextDrawSetProportional(PageLeft, 1);
	TextDrawSetShadow(PageLeft, 1);
	TextDrawUseBox(PageLeft, 1);
	TextDrawBoxColor(PageLeft, 16777215);
	TextDrawTextSize(PageLeft, 20.000000, 20.000000);
	TextDrawSetSelectable(PageLeft, 1);

	PageRight = TextDrawCreate(68.000000, pageoffset, "LD_BEAT:right");
	TextDrawBackgroundColor(PageRight, 255);
	TextDrawFont(PageRight, 4);
	TextDrawLetterSize(PageRight, 0.500000, 1.000000);
	TextDrawColor(PageRight, 16777215);
	TextDrawSetOutline(PageRight, 0);
	TextDrawSetProportional(PageRight, 1);
	TextDrawSetShadow(PageRight, 1);
	TextDrawUseBox(PageRight, 1);
	TextDrawBoxColor(PageRight, 16777215);
	TextDrawTextSize(PageRight, 20.000000, 20.000000);
	TextDrawSetSelectable(PageRight, 1);

	OS_Background_0 = TextDrawCreate(172.000000, 324.000000, "RotX");
	TextDrawBackgroundColor(OS_Background_0, 255);
	TextDrawFont(OS_Background_0, 1);
	TextDrawLetterSize(OS_Background_0, 0.200000, 1.000000);
	TextDrawColor(OS_Background_0, -1);
	TextDrawSetOutline(OS_Background_0, 1);
	TextDrawSetProportional(OS_Background_0, 1);
	TextDrawSetSelectable(OS_Background_0, 0);

	OS_Background_1 = TextDrawCreate(172.000000, 344.000000, "RotY");
	TextDrawBackgroundColor(OS_Background_1, 255);
	TextDrawFont(OS_Background_1, 1);
	TextDrawLetterSize(OS_Background_1, 0.200000, 1.000000);
	TextDrawColor(OS_Background_1, -1);
	TextDrawSetOutline(OS_Background_1, 1);
	TextDrawSetProportional(OS_Background_1, 1);
	TextDrawSetSelectable(OS_Background_1, 0);

	OS_Background_2 = TextDrawCreate(172.000000, 364.000000, "RotZ");
	TextDrawBackgroundColor(OS_Background_2, 255);
	TextDrawFont(OS_Background_2, 1);
	TextDrawLetterSize(OS_Background_2, 0.200000, 1.000000);
	TextDrawColor(OS_Background_2, -1);
	TextDrawSetOutline(OS_Background_2, 1);
	TextDrawSetProportional(OS_Background_2, 1);
	TextDrawSetSelectable(OS_Background_2, 0);

	OS_Background_3 = TextDrawCreate(170.000000, 384.000000, "Zoom");
	TextDrawBackgroundColor(OS_Background_3, 255);
	TextDrawFont(OS_Background_3, 1);
	TextDrawLetterSize(OS_Background_3, 0.200000, 1.000000);
	TextDrawColor(OS_Background_3, -1);
	TextDrawSetOutline(OS_Background_3, 1);
	TextDrawSetProportional(OS_Background_3, 1);
	TextDrawSetSelectable(OS_Background_3, 0);

	Click_OS_Create = TextDrawCreate(158.000000, 400.000000, "Create");
	TextDrawBackgroundColor(Click_OS_Create, 255);
	TextDrawFont(Click_OS_Create, 1);
	TextDrawLetterSize(Click_OS_Create, 0.400000, 2.000000);
	TextDrawColor(Click_OS_Create, -65281);
	TextDrawSetOutline(Click_OS_Create, 1);
	TextDrawSetProportional(Click_OS_Create, 1);
	TextDrawUseBox(Click_OS_Create, 1);
	TextDrawBoxColor(Click_OS_Create, 0);
	TextDrawTextSize(Click_OS_Create, 200.000000, 12.000000);
	TextDrawSetSelectable(Click_OS_Create, 1);

	new Float:y = 130.0;
	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
		OSearch_HighLight[i] = TextDrawCreate(18.000000, y, "_");
		TextDrawBackgroundColor(OSearch_HighLight[i], 255);
		TextDrawFont(OSearch_HighLight[i], 1);
		TextDrawLetterSize(OSearch_HighLight[i], 0.500000, 1.000000);
		TextDrawColor(OSearch_HighLight[i], -1);
		TextDrawSetOutline(OSearch_HighLight[i], 0);
		TextDrawSetProportional(OSearch_HighLight[i], 1);
		TextDrawSetShadow(OSearch_HighLight[i], 1);
		TextDrawUseBox(OSearch_HighLight[i], 1);
		TextDrawBoxColor(OSearch_HighLight[i], 16711730);
		TextDrawTextSize(OSearch_HighLight[i], 150.000000, 0.000000);
		TextDrawSetSelectable(OSearch_HighLight[i], 0);
		y += 10.0;
	}

	return 1;
}

static DestroySearchDraws()
{
	TextDrawDestroy(RotXLeft);
	TextDrawDestroy(RotYLeft);
	TextDrawDestroy(RotZLeft);
	TextDrawDestroy(ZoomLeft);
	TextDrawDestroy(RotXRight);
	TextDrawDestroy(RotYRight);
	TextDrawDestroy(RotZRight);
	TextDrawDestroy(ZoomRight);
	TextDrawDestroy(PageLeft);
	TextDrawDestroy(PageRight);
	TextDrawDestroy(OS_Background_0);
	TextDrawDestroy(OS_Background_1);
	TextDrawDestroy(OS_Background_2);
	TextDrawDestroy(OS_Background_3);
	TextDrawDestroy(Click_OS_Create);

	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
		TextDrawDestroy(OSearch_HighLight[i]);
	}
	return 1;
}

static CreatePlayerSearchDraw(playerid)
{
	new Float:y = 130.0;
	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
		OSearchIndex[playerid][i] = CreatePlayerTextDraw(playerid,20.000000, y, "~r~ID:~g~ 1337 ~r~Name:~g~ sign_01");
		PlayerTextDrawBackgroundColor(playerid,OSearchIndex[playerid][i], 255);
		PlayerTextDrawFont(playerid,OSearchIndex[playerid][i], 1);
		PlayerTextDrawLetterSize(playerid,OSearchIndex[playerid][i], 0.200000, 1.000000);
		PlayerTextDrawColor(playerid,OSearchIndex[playerid][i], 16711935);
		PlayerTextDrawSetOutline(playerid,OSearchIndex[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid,OSearchIndex[playerid][i], 1);
		PlayerTextDrawUseBox(playerid,OSearchIndex[playerid][i], 1);
		PlayerTextDrawBoxColor(playerid,OSearchIndex[playerid][i], 0);
		PlayerTextDrawTextSize(playerid,OSearchIndex[playerid][i], 300.000000, 10.000000);
		PlayerTextDrawSetSelectable(playerid,OSearchIndex[playerid][i], 1);
		y += 10.0;
	}

	SearchDisplayModel[playerid] = CreatePlayerTextDraw(playerid,120.000000, 127.000000, "ModelDisplay");
	PlayerTextDrawBackgroundColor(playerid,SearchDisplayModel[playerid], 0);
	PlayerTextDrawFont(playerid,SearchDisplayModel[playerid], 5);
	PlayerTextDrawLetterSize(playerid,SearchDisplayModel[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid,SearchDisplayModel[playerid], -1);
	PlayerTextDrawSetOutline(playerid,SearchDisplayModel[playerid], 0);
	PlayerTextDrawSetProportional(playerid,SearchDisplayModel[playerid], 1);
	PlayerTextDrawSetShadow(playerid,SearchDisplayModel[playerid], 1);
	PlayerTextDrawUseBox(playerid,SearchDisplayModel[playerid], 1);
	PlayerTextDrawBoxColor(playerid,SearchDisplayModel[playerid], 0);
	PlayerTextDrawTextSize(playerid,SearchDisplayModel[playerid], 200.000000, 200.000000);
	PlayerTextDrawSetPreviewModel(playerid, SearchDisplayModel[playerid], 1337);
	PlayerTextDrawSetPreviewRot(playerid, SearchDisplayModel[playerid], -16.000000, 0.000000, -55.000000, 1.000000);
	PlayerTextDrawSetSelectable(playerid,SearchDisplayModel[playerid], 0);

	return 1;
}

static DestroyPlayerSearchDraw(playerid)
{
	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
        PlayerTextDrawDestroy(playerid, OSearchIndex[playerid][i]);
	}
	PlayerTextDrawDestroy(playerid, SearchDisplayModel[playerid]);
	return 1;
}

static ShowPlayerOSDraws(playerid)
{
	TextDrawShowForPlayer(playerid, RotXLeft);
	TextDrawShowForPlayer(playerid, RotYLeft);
	TextDrawShowForPlayer(playerid, RotZLeft);
	TextDrawShowForPlayer(playerid, ZoomLeft);
	TextDrawShowForPlayer(playerid, RotXRight);
	TextDrawShowForPlayer(playerid, RotYRight);
	TextDrawShowForPlayer(playerid, RotZRight);
	TextDrawShowForPlayer(playerid, ZoomRight);
	TextDrawShowForPlayer(playerid, PageRight);
	TextDrawShowForPlayer(playerid, PageLeft);
	TextDrawShowForPlayer(playerid, OS_Background_0);
	TextDrawShowForPlayer(playerid, OS_Background_1);
	TextDrawShowForPlayer(playerid, OS_Background_2);
	TextDrawShowForPlayer(playerid, OS_Background_3);
	TextDrawShowForPlayer(playerid, Click_OS_Create);

	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
        PlayerTextDrawShow(playerid, OSearchIndex[playerid][i]);
	}
	PlayerTextDrawShow(playerid, SearchDisplayModel[playerid]);

}

static HidePlayerOSDraws(playerid)
{
	TextDrawHideForPlayer(playerid, RotXLeft);
	TextDrawHideForPlayer(playerid, RotYLeft);
	TextDrawHideForPlayer(playerid, RotZLeft);
	TextDrawHideForPlayer(playerid, ZoomLeft);
	TextDrawHideForPlayer(playerid, RotXRight);
	TextDrawHideForPlayer(playerid, RotYRight);
	TextDrawHideForPlayer(playerid, RotZRight);
	TextDrawHideForPlayer(playerid, ZoomRight);
	TextDrawHideForPlayer(playerid, PageRight);
	TextDrawHideForPlayer(playerid, PageLeft);
	TextDrawHideForPlayer(playerid, OS_Background_0);
	TextDrawHideForPlayer(playerid, OS_Background_1);
	TextDrawHideForPlayer(playerid, OS_Background_2);
	TextDrawHideForPlayer(playerid, OS_Background_3);
	TextDrawHideForPlayer(playerid, Click_OS_Create);

	for(new i = 0; i < MAX_OS_PAGE; i++)
	{
        PlayerTextDrawHide(playerid, OSearchIndex[playerid][i]);
   	    TextDrawHideForPlayer(playerid, OSearch_HighLight[i]);
	}
	PlayerTextDrawHide(playerid, SearchDisplayModel[playerid]);

}

tsfunc isnumeric_f(str[])
{
	new i, ch;
	while ((ch = str[i++])) if (!('0' <= ch <= '9') && ch != '.') return 0;
	return !str[i];
}
