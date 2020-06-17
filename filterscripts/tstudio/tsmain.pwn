////////////////////////////////////////////////////////////////////////////////
/// Standard Callbacks /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

public OnFilterScriptInit()
{
	print("----------------------------------------------");
	print("----Texture Studio By [uL]Pottus and Crayder--");
	print("------------------------------------Loaded----");

	SystemDB = db_open_persistent("tstudio/system.db");
	ThemeDataDB = db_open_persistent("tstudio/themedata.db");
    
	sqlite_ThemeSetup();
	sqlite_LoadBindString();
	
	ResetSettings();

	Streamer_ToggleErrorCallback(1); // Enable Streammer Error Callback
	
	#if defined AddSimpleModel // DL-SUPPORT
	Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 1500);
	#endif
	
	return 1;
}

public OnFilterScriptExit()
{
	print("----------------------------------------------");
	print("----Texture Studio By [uL]Pottus and Crayder--");
	print("------------------------------------Unloaded--");

	// Delete all map objects
	DeleteMapObjects(false);

	// Clear all removed buildings
	ClearRemoveBuildings();

	foreach(new i : Player)
	{
 		ClearCopyBuffer(i);
	}
    
	// Always close map
	if(MapOpen)
    {
		db_free_persistent(EditMap);
		sqlite_UpdateSettings();
	}
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
    
    SendClientMessage(playerid, STEALTH_GREEN, "Welcome to Texture Studio!");
    SendClientMessage(playerid, STEALTH_GREEN, sprintf("There are currently %i commands registered, check \"/thelp\" to see them!", Command_GetPlayerCommandCount(playerid)));
	
	new bool:found, bool:warn, string[36];
	for (new i, j = Command_GetPlayerCommandCount(playerid); i < j; i++)
  	{
  	    format(string, 36, "%s", Command_GetNext(i, playerid));
		//foreach(new c : Command()) {
		
		for(new k; k < sizeof(Commands); k++) {
			if(!strcmp(Commands[k][cName], string)) {
				found = true;
				break;
			}
		}
		if(!found) {
			printf("    /thelp missing command: %s", string);
			warn = true;
		}
		else
			found = false;
	}
	if(warn)
		printf("Warning: There's something missing or extra in /thelp for player %i.\n    (Report to Crayder on SA-MP Discord if this message ever shows)", playerid);
	
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

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) return 0;

SetCurrObject(playerid, index)
{
    if(CanSelectObject(playerid, index))
    {
        CurrObject[playerid] = index;
        CallLocalFunction("OnPlayerObjectSelectChange", "ii", playerid, index);
        return 1;
    }
    return 0;
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

// player finished editing an object; Fix For new streamer version
public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ) return 0;

// player finished editing an object
public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	//printf("%i, %i, %i, %i", playerid, objectid, response, GetEditMode(playerid));
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

	#if defined MA_OnPlayerEditDynamicObject
		MA_OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
	#endif
	return 0;
}
#if defined _ALS_OnPlayerEditDynamicObject
	#undef OnPlayerEditDynamicObject
#else
	#define _ALS_OnPlayerEditDynamicObject
#endif
#define OnPlayerEditDynamicObject MA_OnPlayerEditDynamicObject
#if defined MA_OnPlayerEditDynamicObject
	forward MA_OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
#endif



// Player clicked a dynamic object; Fix For new streamer version
public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ) return 0;

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

			if(Keys & KEY_CTRL_BACK || (InFlyMode(playerid) && (Keys & KEY_SECONDARY_ATTACK)))
			//if(Keys & KEY_CTRL_BACK)
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

				if(SetCurrObject(playerid, index)) {
                    new line[128];
                    format(line, sizeof(line), "You have selected object index %i for editing", index);
                    SendClientMessage(playerid, STEALTH_GREEN, line);
                }
                else
                    SendClientMessage(playerid, STEALTH_YELLOW, "You can not select objects in this object's group");
			}
		}
	}
	return 0;
}

// Streamer Error Log
public Streamer_OnPluginError(const error[])
{
	printf("Streamer Plugin Error: %s", error);
}

// Player clicked textdraw
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	// Text editing mode
	if(GetCurrTextDraw(playerid) == TEXTDRAW_TEXTEDIT) if(ClickTextDrawEditText(playerid, Text:clickedid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_MATERIALS) if(ClickTextDrawEditMat(playerid, Text:clickedid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_LISTSEL) if(ClickTextDrawListSel(playerid, Text:clickedid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_OSEARCH) if(ClickTextDrawOSearch(playerid, Text:clickedid)) return 1;

	#if defined MA_OnPlayerClickTextDraw
		return MA_OnPlayerClickTextDraw(playerid, Text:clickedid);
	#endif
	return 0;
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw MA_OnPlayerClickTextDraw
#if defined MA_OnPlayerClickTextDraw
	forward MA_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif


// Player clicked player textdraw
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	// Text editing mode
    if(GetCurrTextDraw(playerid) == TEXTDRAW_TEXTEDIT) if(ClickPlayerTextDrawEditText(playerid, PlayerText:playertextid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_MATERIALS) if(ClickPlayerTextDrawEditMat(playerid, PlayerText:playertextid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_LISTSEL) if(ClickPlayerTextListSel(playerid, PlayerText:playertextid)) return 1;
    if(GetCurrTextDraw(playerid) == TEXTDRAW_OSEARCH) if(ClickPlayerTextDrawOSearch(playerid, PlayerText:playertextid)) return 1;

	#if defined MA_OnPlayerClickPlayerTextDraw
		return MA_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
	#endif
	return 0;
}
#if defined _ALS_OnPlayerClickPlayerTD
	#undef OnPlayerClickPlayerTextDraw
#else
	#define _ALS_OnPlayerClickPlayerTD
#endif
#define OnPlayerClickPlayerTextDraw MA_OnPlayerClickPlayerTextDraw
#if defined MA_OnPlayerClickPlayerTextDraw
	forward MA_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
#endif


public OnPlayerKeyStateChange(playerid,newkeys,oldkeys)
{
	if(OnPlayerKeyStateChangeOEdit(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateChange3DMenu(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateGroupChange(playerid, newkeys, oldkeys)) return 1;
    if(OnPlayerKeyStateMenuChange(playerid, newkeys, oldkeys)) return 1;
    if(OnPlayerKeyStateChangeTex(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateChangeLSel(playerid,newkeys,oldkeys)) return 1;
    if(OnPlayerKeyStateChangeCMD(playerid,newkeys,oldkeys)) return 1;
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
    stmt_bind_result_field(loadstmt, 20, DB::TYPE_STRING, tmpobject[oNote], 64);
    stmt_bind_result_field(loadstmt, 21, DB::TYPE_FLOAT, tmpobject[oDD]);

	// Execute query
    if(stmt_execute(loadstmt))
    {
		new count;
        while(stmt_fetch_row(loadstmt))
        {
			// Load object into database at specified index (Don't save to sqlite database)
			AddDynamicObject(tmpobject[oModel], tmpobject[oX], tmpobject[oY], tmpobject[oZ], tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ], currindex, false, .dd = tmpobject[oDD]);

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
			format(ObjectData[currindex][oNote], MAX_TEXT_LENGTH, "%s", tmpobject[oNote]);

			// We need to update textures and materials
			UpdateMaterial(currindex);

			// Update the object text
			UpdateObjectText(currindex);

			// Update 3d text
			UpdateObject3DText(currindex, true);
			
			count++;
        }
		stmt_close(loadstmt);
        return count;
    }
	stmt_close(loadstmt);
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
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
	}
	insertstmt = db_prepare(EditMap, InsertObjectString);

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
    stmt_bind_value(insertstmt, 20, DB::TYPE_STRING, ObjectData[index][oNote]);
    stmt_bind_value(insertstmt, 21, DB::TYPE_FLOAT, ObjectData[index][oDD]);

    stmt_execute(insertstmt);
	stmt_close(insertstmt);
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
    sqlite_CreateSettings();
	sqlite_InitSettings();
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
			"GroupID INTEGER,",
			"Note TEXT,",
			"DrawDistance REAL DEFAULT 300.0);"
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

new NewSettingsString[512];
sqlite_CreateSettings()
{
	if(!NewSettingsString[0])
	{
		strimplode(" ",
			NewSettingsString,
			sizeof(NewSettingsString),
			"CREATE TABLE IF NOT EXISTS `Settings`",
			"(Version INTEGER DEFAULT 0,",
			"LastTime INTEGER DEFAULT 0,",
			"Author TEXT DEFAULT 'Creator',",
			"SpawnX REAL DEFAULT 0.0,",
			"SpawnY REAL DEFAULT 0.0,",
			"SpawnZ REAL DEFAULT 0.0,",
			"Interior INTEGER DEFAULT -1,",
			"VirtualWorld INTEGER DEFAULT -1);"
		);
	}
	db_exec(EditMap, NewSettingsString);
}

new DBStatement:insertsettingstmt;
new InitSettingsString[512];
sqlite_InitSettings()
{
	// Insert the initial values
	if(!InitSettingsString[0])
	{
		// Prepare query
		strimplode(" ",
			InitSettingsString,
			sizeof(InitSettingsString),
			"INSERT INTO `Settings`",
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
	}
	insertsettingstmt = db_prepare(EditMap, InitSettingsString);
    
	// Bind our results
    stmt_bind_value(insertsettingstmt, 0, DB::TYPE_INT, MapSetting[mVersion]);
    stmt_bind_value(insertsettingstmt, 1, DB::TYPE_INT, MapSetting[mLastEdit]);
    stmt_bind_value(insertsettingstmt, 2, DB::TYPE_STRING, MapSetting[mAuthor]);
    stmt_bind_value(insertsettingstmt, 3, DB::TYPE_FLOAT, MapSetting[mSpawn][xPos]);
    stmt_bind_value(insertsettingstmt, 4, DB::TYPE_FLOAT, MapSetting[mSpawn][yPos]);
    stmt_bind_value(insertsettingstmt, 5, DB::TYPE_FLOAT, MapSetting[mSpawn][zPos]);
    stmt_bind_value(insertsettingstmt, 6, DB::TYPE_INT, MapSetting[mInterior]);
    stmt_bind_value(insertsettingstmt, 7, DB::TYPE_INT, MapSetting[mVirtualWorld]);

    stmt_execute(insertsettingstmt);
	stmt_close(insertsettingstmt);
}

// Makes any version updates
sqlite_UpdateDB()
{
	sqlite_CreateRBDB();
	sqlite_CreateVehicle();
	
	new dbver = db_query_int(EditMap, "SELECT Version FROM Settings");
	new major = (dbver >> 16) & 0xFF, minor = (dbver >> 8) & 0xFF, patch = (dbver & 0xFF) + 96;
	
	#pragma unused major, minor, patch
	
	if(minor < 9)
	{
		ResetSettings();
		sqlite_CreateSettings();
		sqlite_InitSettings();

		// Version 1.3
		if(!ColumnExists(EditMap, "Objects", "GroupID")) db_exec(EditMap, "ALTER TABLE `Objects` ADD COLUMN `GroupID` INTEGER DEFAULT 0");
		
		// Version 1.9
		if(!ColumnExists(EditMap, "Objects", "Note"))
		{
			db_exec(EditMap, "ALTER TABLE `Objects` ADD COLUMN `Note` TEXT DEFAULT ''");
			db_exec(EditMap, "ALTER TABLE `Objects` ADD COLUMN `DrawDistance` REAL DEFAULT 300.0");
			db_exec(EditMap, "ALTER TABLE `Vehicles` ADD COLUMN `CarSiren` INTEGER DEFAULT 0");
		}
    }
	
	/* example: Less than 1.9b
	if(major <= 1 && minor <= 9 && patch <= 'b'))
	{
		print("worked");
		sqlite_CreateRangeRemoved();
		sqlite_InitSettings();
    }*/
	
	
    /*new dbver = db_query_int(EditMap, "SELECT Version FROM Settings");
    if(dbver != TS_VERSION)
    {
        printf("Map version (%i.%i%c) does not match TS version (%i.%i%c)",
            (dbver & 0x00FF0000), (dbver & 0x0000FF00), (dbver & 0x000000FF) + 96,
            (TS_VERSION & 0x00FF0000), (TS_VERSION & 0x0000FF00), (TS_VERSION & 0x000000FF) + 96);
    
        if((dbver & 0x00FF0000) > (TS_VERSION & 0x00FF0000)) // Major version, changes were made that are needed to edit this map
            printf("Map major version is higher than TS version, update TS to edit this map.");
        else if((dbver & 0x0000FF00) > (TS_VERSION & 0x0000FF00)) // Minor version, changes were made that affect this map
            printf("Map minor version is higher than TS version, update TS to edit this map correctly.");
        else if((dbver & 0x000000FF) > (TS_VERSION & 0x000000FF)) // Patch, backwards compatible
            printf("Your version of TS is old, consider updating.");
        
        if((dbver & 0x00FF0000) < (TS_VERSION & 0x00FF0000)) // Major version, making updates
            printf("Map major version is lower than TS version, updating map.");
        else if((dbver & 0x0000FF00) < (TS_VERSION & 0x0000FF00)) // Minor version, making updates
            printf("Map minor version is lower than TS version, updating map.");
        else if((dbver & 0x000000FF) < (TS_VERSION & 0x000000FF)) // Patch, backwards compatible
            printf("Map version is compatible with TS version.");
    }*/
	
    sqlite_UpdateSettings();
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
	}
    texturestmt = db_prepare(EditMap, TextureUpdateString);

	// Bind values
	stmt_bind_value(texturestmt, 0, DB::TYPE_ARRAY, ObjectData[index][oTexIndex], MAX_MATERIALS);
	stmt_bind_value(texturestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(texturestmt);
	stmt_close(texturestmt);

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
	}

    colorstmt = db_prepare(EditMap, ColorUpdateString);

	// Bind values
	stmt_bind_value(colorstmt, 0, DB::TYPE_ARRAY, ObjectData[index][oColorIndex], MAX_MATERIALS);
	stmt_bind_value(colorstmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(colorstmt);
	stmt_close(colorstmt);

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
	}
    posupdatestmt = db_prepare(EditMap, PosUpdateString);

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
	stmt_close(posupdatestmt);

	foreach(new i : Player)
	{
		if(CurrObject[i] == index) OnObjectUpdatePos(i, index);
	}

    return 1;
}

new DBStatement:ddupdatestmt;
new DDUpdateString[512];

sqlite_UpdateObjectDD(index)
{
	// Inserts a new index
	if(!DDUpdateString[0])
	{
		// Prepare query
		strimplode(" ",
			DDUpdateString,
			sizeof(DDUpdateString),
			"UPDATE `Objects` SET",
			"`DrawDistance` = ?",
			"WHERE `IndexID` = ?"
		);
	}
    ddupdatestmt = db_prepare(EditMap, DDUpdateString);

	// Bind values
	stmt_bind_value(ddupdatestmt, 0, DB::TYPE_FLOAT, ObjectData[index][oDD]);
	stmt_bind_value(ddupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(ddupdatestmt);
	stmt_close(ddupdatestmt);

    return 1;
}


// Update sql object text
new DBStatement:objecttextallsave;
new ObjectTextSave[512];

sqlite_SaveAllObjectText(index)
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
	}

	objecttextallsave = db_prepare(EditMap, ObjectTextSave);

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
	stmt_close(objecttextallsave);
}



// Update sql use text
new DBStatement:usetextupdatestmt;
new UseTextString[512];

sqlite_ObjUseText(index)
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
	}

	usetextupdatestmt = db_prepare(EditMap, UseTextString);

	// Bind values
	stmt_bind_value(usetextupdatestmt, 0, DB::TYPE_INT, ObjectData[index][ousetext]);
	stmt_bind_value(usetextupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(usetextupdatestmt);
	stmt_close(usetextupdatestmt);
	return 1;
}

// Update sql fontface
new DBStatement:fontfaceupdatestmt;
new FontFaceString[512];

sqlite_ObjFontFace(index)
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
	}

	fontfaceupdatestmt = db_prepare(EditMap, FontFaceString);

	// Bind values
	stmt_bind_value(fontfaceupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontFace]);
	stmt_bind_value(fontfaceupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontfaceupdatestmt);
	stmt_close(fontfaceupdatestmt);
	return 1;
}

// Update sql fontsize
new DBStatement:fontsizeupdatestmt;
new FontSizeString[512];

sqlite_ObjFontSize(index)
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
	}
	fontsizeupdatestmt = db_prepare(EditMap, FontSizeString);

	// Bind values
	stmt_bind_value(fontsizeupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontSize]);
	stmt_bind_value(fontsizeupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontsizeupdatestmt);
	stmt_close(fontsizeupdatestmt);
	return 1;
}



// Update sql fontbold
new DBStatement:fontboldupdatestmt;
new FontBoldString[512];

sqlite_ObjFontBold(index)
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
	}

	fontboldupdatestmt = db_prepare(EditMap, FontBoldString);

	// Bind values
	stmt_bind_value(fontboldupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontBold]);
	stmt_bind_value(fontboldupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontboldupdatestmt);
	stmt_close(fontboldupdatestmt);
	return 1;
}

// Update sql fontcolor
new DBStatement:fontcolorupdatestmt;
new FontColorString[512];

sqlite_ObjFontColor(index)
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
	}

	fontcolorupdatestmt = db_prepare(EditMap, FontColorString);

	// Bind values
	stmt_bind_value(fontcolorupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oFontColor]);
	stmt_bind_value(fontcolorupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(fontcolorupdatestmt);
	stmt_close(fontcolorupdatestmt);
	return 1;
}

// Update sql backcolor
new DBStatement:backcolorupdatestmt;
new BackColorString[512];

sqlite_ObjBackColor(index)
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
	}

	backcolorupdatestmt = db_prepare(EditMap, BackColorString);

	// Bind values
	stmt_bind_value(backcolorupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oBackColor]);
	stmt_bind_value(backcolorupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(backcolorupdatestmt);
	stmt_close(backcolorupdatestmt);
	return 1;
}

// Update sql alignment
new DBStatement:alignmentupdatestmt;
new AlignmentString[512];


sqlite_ObjAlignment(index)
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
	}

	alignmentupdatestmt = db_prepare(EditMap, AlignmentString);

	// Bind values
	stmt_bind_value(alignmentupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oAlignment]);
	stmt_bind_value(alignmentupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(alignmentupdatestmt);
	stmt_close(alignmentupdatestmt);
	return 1;
}

// Update sql textsize
new DBStatement:textsizeupdatestmt;
new TextSizeString[512];

sqlite_ObjFontTextSize(index)
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
	}

	textsizeupdatestmt = db_prepare(EditMap, TextSizeString);

	// Bind values
	stmt_bind_value(textsizeupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oTextFontSize]);
	stmt_bind_value(textsizeupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(textsizeupdatestmt);
	stmt_close(textsizeupdatestmt);
	return 1;
}

// Update sql object text
new DBStatement:objecttextupdatestmt;
new ObjectTextString[512];

sqlite_ObjObjectText(index)
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
	}

	objecttextupdatestmt = db_prepare(EditMap, ObjectTextString);

	// Bind values
	stmt_bind_value(objecttextupdatestmt, 0, DB::TYPE_STRING, ObjectData[index][oObjectText]);
	stmt_bind_value(objecttextupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objecttextupdatestmt);
	stmt_close(objecttextupdatestmt);
	return 1;
}

// Update sql object group
new DBStatement:objectgroupupdatestmt;
new ObjectGroupString[512];

sqlite_ObjGroup(index)
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
	}

	objectgroupupdatestmt = db_prepare(EditMap, ObjectGroupString);

	// Bind values
	stmt_bind_value(objectgroupupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oGroup]);
	stmt_bind_value(objectgroupupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objectgroupupdatestmt);
	stmt_close(objectgroupupdatestmt);
	return 1;
}


// Update sql object model
new DBStatement:objectmodelupdatestmt;
new ObjectModelString[512];

sqlite_ObjModel(index)
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
	}
	objectmodelupdatestmt = db_prepare(EditMap, ObjectModelString);

	// Bind values
	stmt_bind_value(objectmodelupdatestmt, 0, DB::TYPE_INT, ObjectData[index][oModel]);
	stmt_bind_value(objectmodelupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objectmodelupdatestmt);
	stmt_close(objectmodelupdatestmt);
	return 1;
}

// Update sql object note
new DBStatement:objectnoteupdatestmt;
new ObjectNoteString[512];

sqlite_ObjNote(index)
{
	if(!ObjectNoteString[0])
	{
		strimplode(" ",
			ObjectNoteString,
			sizeof(ObjectNoteString),
			"UPDATE `Objects` SET",
			"`Note` = ?",
			"WHERE `IndexID` = ?"
		);
	}
	objectnoteupdatestmt = db_prepare(EditMap, ObjectNoteString);

	// Bind values
	stmt_bind_value(objectnoteupdatestmt, 0, DB::TYPE_STRING, ObjectData[index][oNote]);
	stmt_bind_value(objectnoteupdatestmt, 1, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(objectnoteupdatestmt);
	stmt_close(objectnoteupdatestmt);
	return 1;
}


// Insert a remove building to DB
new DBStatement:insertremovebuldingstmt;
new InsertRemoveBuildingString[256];

sqlite_InsertRemoveBuilding(index)
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
	}
	insertremovebuldingstmt = db_prepare(EditMap, InsertRemoveBuildingString);

	// Bind our results
    stmt_bind_value(insertremovebuldingstmt, 0, DB::TYPE_INT, RemoveData[index][rModel]);
    stmt_bind_value(insertremovebuldingstmt, 1, DB::TYPE_FLOAT, RemoveData[index][rX]);
    stmt_bind_value(insertremovebuldingstmt, 2, DB::TYPE_FLOAT, RemoveData[index][rY]);
    stmt_bind_value(insertremovebuldingstmt, 3, DB::TYPE_FLOAT, RemoveData[index][rZ]);
    stmt_bind_value(insertremovebuldingstmt, 4, DB::TYPE_FLOAT, RemoveData[index][rRange]);

    stmt_execute(insertremovebuldingstmt);
	stmt_close(insertremovebuldingstmt);
}

// Update settings in DB
new DBStatement:updatesettingstmt;
new InsertSettingsString[256];

sqlite_UpdateSettings()
{
	if(!InsertSettingsString[0])
	{
		strimplode(" ",
			InsertSettingsString,
			sizeof(InsertSettingsString),
			"UPDATE `Settings` SET",
			"`Version` = ?,",
			"`LastTime` = ?,",
			"`Author` = ?,",
			"`SpawnX` = ?,",
			"`SpawnY` = ?,",
			"`SpawnZ` = ?,",
			"`Interior` = ?,",
			"`VirtualWorld` = ?",
            // Hacky way to change all of the data without a unique, pointless column
			"WHERE `Version` in (SELECT `Version` FROM Settings LIMIT 1)"
		);
	}
	updatesettingstmt = db_prepare(EditMap, InsertSettingsString);
    
	// Bind our results
    stmt_bind_value(updatesettingstmt, 0, DB::TYPE_INT, TS_VERSION);
    stmt_bind_value(updatesettingstmt, 1, DB::TYPE_INT, gettime());
    stmt_bind_value(updatesettingstmt, 2, DB::TYPE_STRING, MapSetting[mAuthor]);
    stmt_bind_value(updatesettingstmt, 3, DB::TYPE_FLOAT, MapSetting[mSpawn][xPos]);
    stmt_bind_value(updatesettingstmt, 4, DB::TYPE_FLOAT, MapSetting[mSpawn][yPos]);
    stmt_bind_value(updatesettingstmt, 5, DB::TYPE_FLOAT, MapSetting[mSpawn][zPos]);
    stmt_bind_value(updatesettingstmt, 6, DB::TYPE_INT, MapSetting[mInterior]);
    stmt_bind_value(updatesettingstmt, 7, DB::TYPE_INT, MapSetting[mVirtualWorld]);

    // Execute statement
    stmt_execute(updatesettingstmt);
	stmt_close(updatesettingstmt);
}

// Load any remove buildings
new DBStatement:loadremovebuldingstmt;

sqlite_LoadRemoveBuildings()
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
		new count;
        while(stmt_fetch_row(loadremovebuldingstmt))
        {
			// Add the removed building
			AddRemoveBuilding(tmpremove[rModel], tmpremove[rX], tmpremove[rY], tmpremove[rZ], tmpremove[rRange], false);
			count++;
        }
		stmt_close(loadremovebuldingstmt);
        return count;
    }
	stmt_close(loadremovebuldingstmt);
    return 0;
}

// Load settings
new DBStatement:loadsettingstmt;

sqlite_LoadSettings()
{
    new tmpsetting[MAPOPTIONS];

	loadsettingstmt = db_prepare(EditMap, "SELECT * FROM `Settings`");

	// Bind our results
    stmt_bind_result_field(loadsettingstmt, 0, DB::TYPE_INT, tmpsetting[mVersion]);
    stmt_bind_result_field(loadsettingstmt, 1, DB::TYPE_INT, tmpsetting[mLastEdit]);
    stmt_bind_result_field(loadsettingstmt, 2, DB::TYPE_STRING, tmpsetting[mAuthor], MAX_PLAYER_NAME);
    stmt_bind_result_field(loadsettingstmt, 3, DB::TYPE_FLOAT, tmpsetting[mSpawn][xPos]);
    stmt_bind_result_field(loadsettingstmt, 4, DB::TYPE_FLOAT, tmpsetting[mSpawn][yPos]);
    stmt_bind_result_field(loadsettingstmt, 5, DB::TYPE_FLOAT, tmpsetting[mSpawn][zPos]);
    stmt_bind_result_field(loadsettingstmt, 6, DB::TYPE_INT, tmpsetting[mInterior]);
    stmt_bind_result_field(loadsettingstmt, 7, DB::TYPE_INT, tmpsetting[mVirtualWorld]);
    
    // Set to default
    //ResetSettings();

	// Execute query
    if(stmt_execute(loadsettingstmt))
    {
        if(stmt_fetch_row(loadsettingstmt))
        {
            // Set to loaded data
            MapSetting = tmpsetting;
			return 1;
        }
    }
	stmt_close(loadsettingstmt);
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

    SaveUndoInfo(index, UNDO_TYPE_EDIT);

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

    if(!TextOption[tShowText] && !TextOption[tAlwaysShowNew] && newobject)
        return 1;
    
	// 3D Text Label (To identify objects)
	new line[128];
	format(line, sizeof(line), "Ind: {33DD11}%i%s", index,
        (TextOption[tShowGroup] ? sprintf(" {FF8800}Grp:{33DD11} %i", ObjectData[index][oGroup]) : ("")));
    
    // Append note
    if(TextOption[tShowModel])
    {
        strcat(line, sprintf("\n{FF8800}Model: {33DD11}%i\n{FF8800}Name: {33DD11}%s", ObjectData[index][oModel], GetModelName(ObjectData[index][oModel])));
    }
    
    // Append note
    if(TextOption[tShowNote] && strlen(ObjectData[index][oNote]))
    {
        strcat(line, sprintf("\n{FF8800}Note: {33DD11}%s", ObjectData[index][oNote]));
    }

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
tsfunc AttachObjectToPoint(objectid, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, &Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1)
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

tsfunc AttachObjectToPoint_GroupEdit(objectid, Float:offx, Float:offy, Float:offz, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, &Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1)
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


tsfunc AttachPoint(Float:offx, Float:offy, Float:offz, Float:offrx, Float:offry, Float:offrz, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, &Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1)
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





tsfunc EDIT_FloatConvertValue(Float:rot_x, Float:rot_y, Float:rot_z, Float:sin[3], Float:cos[3])
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
tsfunc EDIT_FloatEulerFix(&Float:rot_x, &Float:rot_y, &Float:rot_z)
{
    EDIT_FloatGetRemainder(rot_x, rot_y, rot_z);
    if((!floatcmp(rot_x, 0.0) || !floatcmp(rot_x, 360.0))
    && (!floatcmp(rot_y, 0.0) || !floatcmp(rot_y, 360.0)))
    {
        rot_y = 0.00000002;
    }
    return 1;
}

tsfunc EDIT_FloatGetRemainder(&Float:rot_x, &Float:rot_y, &Float:rot_z)
{
    EDIT_FloatRemainder(rot_x, 360.0);
    EDIT_FloatRemainder(rot_y, 360.0);
    EDIT_FloatRemainder(rot_z, 360.0);
    return 1;
}

tsfunc EDIT_FloatRemainder(&Float:remainder, Float:value)
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

AddDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, index = -1, bool:sqlsave = true, Float:dd = 300.0)
{
	// Index was not specified get a free index
	if(index == -1) index = Iter_Free(Objects);

	//Found free index
	if(index != -1)
	{
		// Add iterator
		Iter_Add(Objects, index);

		// Create object and set data
		ObjectData[index][oID] = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, MapSetting[mVirtualWorld], MapSetting[mInterior], -1, dd);
		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, dd);
		
		#if defined COMPILE_MANGLE
			ObjectData[index][oCAID] = CA_CreateObject(modelid, x, y, z, rx, ry, rz, true);
		#endif
		
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
		ObjectData[index][oDD] = dd;

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

DeleteDynamicObject(index, bool:sqlsave = true)
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
		
		#if defined COMPILE_MANGLE
			CA_DestroyObject(ObjectData[index][oCAID]);
		#endif

		if(sqlsave) sqlite_RemoveObject(index);

		return next;
	}
	print("Error: Tried to delete a object which does not exist");
	return -1;
}

CloneObject(index, grouptask=0)
{
	if(Iter_Contains(Objects, index))
	{
    	new cindex = AddDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], .dd = ObjectData[index][oDD]);

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

	   	format(ObjectData[cindex][oNote], 64, "%s", ObjectData[index][oNote]);
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

		if(grouptask > 0) SaveUndoInfo(cindex, UNDO_TYPE_CREATED, grouptask);
		else SaveUndoInfo(cindex, UNDO_TYPE_CREATED);

		return cindex;
  	}
	printf("ERROR: Tried to clone a non-existant object");
	return -1;
}


// Deletes all map objects
DeleteMapObjects(bool:sqlsave)
{
	if(sqlsave)
	{
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			i = DeleteDynamicObject(i, true);
		}
		db_end_transaction(EditMap);
	}
	else
	{
		foreach(new i : Objects)
		{
			i = DeleteDynamicObject(i, false);
		}
	}
	
	// Reset any player variables
	foreach(new i : Player)
	{
		SetCurrObject(i, -1);
	}
	return 1;
}

// Add a remove building
AddRemoveBuilding(model, Float:x, Float:y, Float:z, Float:range, savesql = true)
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

ClearRemoveBuildings()
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

		ResetGTADeletedObjects();
	}
	return 1;
}

RemoveAllBuildings(playerid)
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
IsHexValue(hstring[])
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
GetPosFaInFrontOfPlayer(playerid, Float:OffDist, &Float:Pxx, &Float:Pyy, &Float:Pzz, &Float:Fa, Float:rotoff = 0.0)
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
/// Support functions end///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
/// Commands  //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Echo text to player useful for keybind (Autohotkey)
YCMD:echo(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Echo text in the chat. Useful for binds and external keybinds.");
		return 1;
	}

	SendClientMessage(playerid, -1, arg);
	return 1;
}


// Pick a map to load
YCMD:loadmap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Load a saved map.");
		return 1;
	}

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
                // Update map settings
                sqlite_UpdateSettings();
                
                // Close map
				db_free_persistent(EditMap);

				// Delete all map objects
                DeleteMapObjects(false);

				// Clear all removed buildings
				ClearRemoveBuildings();
                
                // Reset settings
                ResetSettings();

				// Clean up vehicles
				ClearVehicles();

				// Clear copy buffer
	            foreach(new i : Player)
				{
					ClearCopyBuffer(i);
				}

				// Load map
				LoadMap(playerid);
			}
		}
		Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_MSGBOX, "Texture Studio", "You have a map open are you sure you want to load another map?\n(Note: Your map is already saved)", "Ok", "Cancel");
	}
	else LoadMap(playerid);
	return 1;
}

// Resets settings array
ResetSettings()
{
    MapSetting[mVersion] = 0;
    format(MapSetting[mAuthor], MAX_PLAYER_NAME, "Creator");
    MapSetting[mLastEdit] = 0;
    MapSetting[mInterior] = -1;
    MapSetting[mVirtualWorld] = -1;
    MapSetting[mSpawn][xPos] = 0.0;
    MapSetting[mSpawn][yPos] = 0.0;
    MapSetting[mSpawn][zPos] = 0.0;
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
				ClearAllUndoInfo();

				format(MapName, sizeof(MapName), "tstudio/SavedMaps/%s", stext);

				// Map is now open
                EditMap = db_open_persistent(MapName);

                // Load the maps settings
                sqlite_LoadSettings();
                
				// Perform any version updates
				sqlite_UpdateDB();

				// Load the maps remove buildings
			    new rmcount = sqlite_LoadRemoveBuildings();

                // Load the maps objects
                new ocount = sqlite_LoadMapObjects();

				// Load any vehicles
			    sqlite_LoadCars();

				// Map is now open
                MapOpen = true;

				// Default editing mode
   				EditingMode[playerid] = false;
				SetEditMode(playerid,EDIT_MODE_NONE);

				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, sprintf("You have loaded a map with %i objects and %i removed buildings.", ocount, rmcount));
                
                new DBResult:timeResult = db_query(EditMap, sprintf("SELECT datetime(%i, 'unixepoch', 'localtime')", MapSetting[mLastEdit]));
                new timestr[64];
                db_get_field(timeResult, 0, timestr, 64);
                db_free_result(timeResult);
                
                if(MapSetting[mLastEdit])
				{
                    SendClientMessage(playerid, STEALTH_GREEN, sprintf("This map was created by %s.", MapSetting[mAuthor]));
                    SendClientMessage(playerid, STEALTH_GREEN, sprintf("This map was last edited on %s.", timestr)); // by %s
                }
				
                // Update the maps settings, so the last edit time updates
                sqlite_UpdateSettings();
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

// Rename a map
YCMD:renamemap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rename a saved map.");
		return 1;
	}

	MapOpenCheck();

	// Confirm rename map
	inline Confirm(cpid, cdialogid, cresponse, clistitem, string:ctext[])
	{
		#pragma unused clistitem, cdialogid, cpid

		// Rename a map
		if(cresponse)
		{
			if(!isnull(ctext))
			{
				new newname[128];
				format(newname, 128, "tstudio/SavedMaps/%s.db", ctext);
				
				if(!fexist(newname))
				{
					// Close the old map
					db_free_persistent(EditMap);
					
					// Rename the old map
					file_copy(sprintf("./scriptfiles/%s", MapName), sprintf("./scriptfiles/%s", newname));
					file_delete(sprintf("./scriptfiles/%s", MapName));
					MapName = newname;
					
					// Open the new map
					EditMap = db_open_persistent(MapName);

					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_GREEN, "You have renamed a map");
				}
				else
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "A map with that name already exists");
					Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_INPUT, "Texture Studio", "Enter a new name for the current map below.", "Ok", "Cancel");
				}
			}
			else
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "You must give your map a filename");
				Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_INPUT, "Texture Studio", "Enter a new name for the current map below.", "Ok", "Cancel");
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_INPUT, "Texture Studio", "Enter a new name for the current map below.", "Ok", "Cancel");
	return 1;
}

// Delete a map
YCMD:deletemap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Delete a saved map. (Use with caution!)");
		return 1;
	}

	MapOpenCheck();

	// Confirm delete map
	inline Confirm(cpid, cdialogid, cresponse, clistitem, string:ctext[])
	{
		#pragma unused clistitem, cdialogid, cpid, ctext

		// Delete a map
		if(cresponse)
		{
			// Close and delete map
			db_free_persistent(EditMap);
			fremove(MapName);

			ClearAllUndoInfo();

			// Delete all map objects
			DeleteMapObjects(false);

			// Clear all removed buildings
			ClearRemoveBuildings();

			// Clean up vehicles
			ClearVehicles();

			// No map open
			MapOpen = false;

			// Reset player variables
			foreach(new i : Player)
			{
				CancelEdit(i);
				EditingMode[i] = false;
				SetCurrObject(playerid, -1);
				ClearCopyBuffer(i);
			}

			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "You have deleted a map");
		}
	}
	Dialog_ShowCallback(playerid, using inline Confirm, DIALOG_STYLE_MSGBOX, "Texture Studio", "Are you sure you want to delete this map?\n(Note: Once deleted, there is no going back)", "Ok", "Cancel");
	return 1;
}

// Create a new map
YCMD:newmap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Open a new map.");
		return 1;
	}

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

				ClearAllUndoInfo();

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
				format(MapName, sizeof(MapName), "tstudio/SavedMaps/%s.db", ctext);

				if(!fexist(MapName))
				{
					// Open the map for editing
		            EditMap = db_open_persistent(MapName);

					// Create new table for map
		            sqlite_CreateNewMap();
                    
					// Map is now open
		            MapOpen = true;

                    // Set map default settings
                    MapSetting[mVersion] = TS_VERSION;
                    MapSetting[mLastEdit] = gettime();
					GetPlayerName(playerid, MapSetting[mAuthor], MAX_PLAYER_NAME);
                    MapSetting[mSpawn][xPos] = 0.0;
                    MapSetting[mSpawn][yPos] = 0.0;
                    MapSetting[mSpawn][zPos] = 0.0;
                    MapSetting[mInterior] = -1;
                    MapSetting[mVirtualWorld] = -1;
    
                    // Update the map settings, to set the last edit time and insert the player name
                    sqlite_UpdateSettings();

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
YCMD:importmap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Import a map from a text file.");
		return 1;
	}

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
	new templast, templastid[32];
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
				db_begin_transaction(EditMap);
				while(fread(f,templine,sizeof(templine),false))
				{
					strtrim(templine);
				
					new type;
			  		if(strfind(templine, "CreateObject(", true) != -1) type = 1;
			        else if(strfind(templine, "CreateDynamicObject(", true) != -1) type = 1;
			        else if(strfind(templine, "RemoveBuildingForPlayer(", true) != -1) type = 2;
			        else if(strfind(templine, "SetObjectMaterial(", true) != -1) type = 3;
			        else if(strfind(templine, "SetDynamicObjectMaterial(", true) != -1) type = 3;
			        else if(strfind(templine, "SetObjectMaterialText(", true) != -1) type = 4;
			        else if(strfind(templine, "SetDynamicObjectMaterialText(", true) != -1) type = 4;
					else continue;
					
					new assignment = strfind(templine, "="); 
					if(assignment != -1) {
						strmid(templastid, templine, 0, assignment);
						strtrim(templastid);
					}
					
					strmid(templine, templine, strfind(templine, "(") + 1, strfind(templine, ");"), sizeof(templine));

					if(type == 1)
					{
						if(sscanf(templine, "p<,>iffffff", tmpobject[oModel], tmpobject[oX], tmpobject[oY], tmpobject[oZ], tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ]))
							continue;
						
						// Create the new object
				        templast = AddDynamicObject(tmpobject[oModel], tmpobject[oX], tmpobject[oY], tmpobject[oZ], tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ]);
	                    icount++;
					}
					else if(type == 2)
					{
						if(sscanf(templine, "p<,>s[16]iffff", tmp, tmpremove[rModel], tmpremove[rX], tmpremove[rY], tmpremove[rZ], tmpremove[rRange]))
							continue;

						// Delete building
						AddRemoveBuilding(tmpremove[rModel], tmpremove[rX], tmpremove[rY], tmpremove[rZ], tmpremove[rRange], true);

					    rcount++;
					}
					else if(type == 3)
					{
						strreplace(templine, "\"", "");//"
						
						new tempindex, tempmodel, temptxd[32], temptexture[32], tempcolor;
						if(sscanf(templine, "p<,>s[16]iis[32]s[32]h", tmp, tempindex, tempmodel, temptxd, temptexture, tempcolor))
							continue;
						
						if(strcmp(tmp, templastid)) // Stuff before '=' doesn't equal stuff in first param
							continue;
						
						ObjectData[templast][oColorIndex][tempindex] = tempcolor;
						for(new i = 0; i < sizeof(ObjectTextures); i++)
						{
							if(!strcmp(ObjectTextures[i][TextureName], temptexture))
							{
								ObjectData[templast][oTexIndex][tempindex] = i;
								break;
							}
						}
                        
                        sqlite_SaveMaterialIndex(templast);
                        sqlite_SaveColorIndex(templast);
			
                        UpdateMaterial(templast);
					}
					else if(type == 4)
					{
						//SetObjectMaterialText(tmp, text[], index, mat_size, fontface[], fontsize, bold, color, backcolor, alignment)
                        
                        // start by extracting text[], removing it from the parameters
                        // then sscanf all other params separate
					}
                    
                    UpdateObject3DText(templast, true);
				}
				db_end_transaction(EditMap);

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


YCMD:export(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Export current map.");
		return 1;
	}

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
YCMD:exportmap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Export current map to a text file.");
		return 1;
	}

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
                        /*else foreach(new i : Objects)
                        {
                            if(ObjectData[i][oDD] == 300.0) // Default oDD
                                ObjectData[i][oDD] = dist;
                        }*/
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
			fwrite(f,"//////////////////////////////////////////////and Crayder////////////////////////////////////////////////////////\r\n");
			fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

			fwrite(f,"\r\n//Map Information////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
            
            new DBResult:timeResult = db_query(EditMap, sprintf("SELECT datetime(%i, 'unixepoch', 'localtime')", gettime()));
            new timestr[64];
            db_get_field(timeResult, 0, timestr, 64);
            db_free_result(timeResult);
            
            fwrite(f,"/*\r\n");
            fwrite(f,sprintf("\tExported on \"%s\" by \"%s\"\r\n", timestr, ReturnPlayerName(playerid)));
            fwrite(f,sprintf("\tCreated by \"%s\"\r\n", MapSetting[mAuthor]));
            if(MapSetting[mSpawn][xPos])
                fwrite(f,sprintf("\tSpawn Position: %f, %f, %f\r\n", MapSetting[mSpawn][xPos], MapSetting[mSpawn][yPos], MapSetting[mSpawn][zPos]));
            fwrite(f,"*/");
			
            fwrite(f,"\r\n/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

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

				new bool:writeobject, Float:odd = (ObjectData[i][oDD] != 300.0 ? ObjectData[i][oDD] : drawdist);

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
				        format(templine,sizeof(templine),"tmpobjid = CreateObject(%i, %f, %f, %f, %f, %f, %f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,
                            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
				        fwrite(f,templine);
					}

					// Write the create dynamic object line
					else if(elistitem == 1)
					{
						format(templine,sizeof(templine),"tmpobjid = CreateDynamicObjectEx(%i, %f, %f, %f, %f, %f, %f, %.2f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,odd,
                            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
				        fwrite(f,templine);
					}
					else if(elistitem  == 2)
					{
						format(templine,sizeof(templine),"tmpobjid = CreateDynamicObject(%i, %f, %f, %f, %f, %f, %f, -1, -1, -1, %.2f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,odd,
                            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
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
								format(templine,sizeof(templine),"SetObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, 0x%X);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
							else if(elistitem == 1 || elistitem == 2)
							{
								format(templine,sizeof(templine),"SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, 0x%X);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
			            }
			            // No texture how about a color?
			            else if(ObjectData[i][oColorIndex][j] != 0)
			            {
							if(elistitem == 0)
							{
								format(templine,sizeof(templine),"SetObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, 0x%X);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
							else if(elistitem == 1 || elistitem == 2)
							{
								format(templine,sizeof(templine),"SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, 0x%X);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
								fwrite(f,templine);
							}
						}
					}

					// Write any text
					if(ObjectData[i][ousetext])
					{
						if(elistitem == 0)
						{
							format(templine,sizeof(templine),"SetObjectMaterialText(tmpobjid, %c%s%c, 0, %i, %c%s%c, %i, %i, 0x%X, 0x%X, %i);\r\n",
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
							format(templine,sizeof(templine),"SetDynamicObjectMaterialText(tmpobjid, 0, %c%s%c, %i, %c%s%c, %i, %i, 0x%X, 0x%X, %i);\r\n",
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

				new bool:writeobject = true, Float:odd = (ObjectData[i][oDD] != 300.0 ? ObjectData[i][oDD] : drawdist);

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
				        format(templine,sizeof(templine),"tmpobjid = CreateObject(%i, %f, %f, %f, %f, %f, %f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,
				            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
				        fwrite(f,templine);
					}
					else if(elistitem == 1)
					{
				        format(templine,sizeof(templine),"tmpobjid = CreateDynamicObjectEx(%i, %f, %f, %f, %f, %f, %f, %.2f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,odd,
				            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
				        fwrite(f,templine);
					}
					else if(elistitem == 2)
					{
						format(templine,sizeof(templine),"tmpobjid = CreateDynamicObject(%i, %f, %f, %f, %f, %f, %f, -1, -1, -1, %.2f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,odd,
				            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
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
    Dialog_ShowCallback(playerid, using inline ExportType, DIALOG_STYLE_LIST, "Texture Studio (Export Map)", "Type 1 - CreateObject()\nType 2 - CreateDynamicObjectEx()\nType 3 - CreateDynamicObject", "Ok", "Cancel");

	return 1;
}

// Export map to create object
YCMD:exportallmap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Export current map to a filterscript.");
		return 1;
	}

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
	fwrite(f,"///////////////////////////////////////////////////////////and Crayder///////////////////////////////////////////\r\n");
	fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

    fwrite(f,"\r\n//Map Information////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
    
    new DBResult:timeResult = db_query(EditMap, sprintf("SELECT datetime(%i, 'unixepoch', 'localtime')", gettime()));
    new timestr[64];
    db_get_field(timeResult, 0, timestr, 64);
    db_free_result(timeResult);
    fwrite(f,"/*\r\n");
    fwrite(f,sprintf("\tExported on \"%s\" by \"%s\"\r\n", timestr, ReturnPlayerName(playerid)));
    fwrite(f,sprintf("\tCreated by \"%s\"\r\n", MapSetting[mAuthor]));
    if(MapSetting[mSpawn][xPos])
        fwrite(f,sprintf("\tSpawn Position: %f, %f, %f\r\n", MapSetting[mSpawn][xPos], MapSetting[mSpawn][yPos], MapSetting[mSpawn][zPos]));
    fwrite(f,"*/");
    
    fwrite(f,"\r\n/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n\r\n");
    
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
			format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0); %s\r\n",ObjectData[oindex][oModel],
	            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
            fwrite(f,templine);


			// Write all materials and colors
			for(new k = 0; k < MAX_MATERIALS; k++)
	    	{
				// Does object have a texture set?
	            if(ObjectData[oindex][oTexIndex][k] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, 0x%X);\r\n",
						k, GetTModel(ObjectData[oindex][oTexIndex][k]), 34, GetTXDName(ObjectData[oindex][oTexIndex][k]), 34, 34,GetTextureName(ObjectData[oindex][oTexIndex][k]), 34, ObjectData[oindex][oColorIndex][k]
					);

					fwrite(f,templine);
	            }

	            // No texture how about a color?
	            else if(ObjectData[oindex][oColorIndex][k] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, 0x%X);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[oindex][oColorIndex][k]);
					fwrite(f,templine);
				}
			}

			// Write any text
			if(ObjectData[oindex][ousetext])
			{
				format(templine,sizeof(templine),"    SetDynamicObjectMaterialText(tmpobjid, 0, %c%s%c, %i, %c%s%c, %i, %i, 0x%X, 0x%X, %i);\r\n",
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

        new bool:writeobject, Float:odd = (ObjectData[i][oDD] != 300.0 ? ObjectData[i][oDD] : drawdist);

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

			format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i, %f, %f, %f, %f, %f, %f, -1, -1, -1, %.2f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,odd,
	            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
			fwrite(f,templine);

			// Write all materials and colors
  			for(new j = 0; j < MAX_MATERIALS; j++)
        	{
				// Does object have a texture set?
	            if(ObjectData[i][oTexIndex][j] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, 0x%X);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
					fwrite(f,templine);
	            }
	            // No texture how about a color?
	            else if(ObjectData[i][oColorIndex][j] != 0)
	            {
					format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, 0x%X);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
					fwrite(f,templine);
				}
			}

			// Write any text
			if(ObjectData[i][ousetext])
			{
				format(templine,sizeof(templine),"    SetDynamicObjectMaterialText(tmpobjid, 0, %c%s%c, %i, %c%s%c, %i, %i, 0x%X, 0x%X, %i);\r\n",
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

        new bool:writeobject = true, Float:odd = (ObjectData[i][oDD] != 300.0 ? ObjectData[i][oDD] : drawdist);

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
			format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i, %f, %f, %f, %f, %f, %f, -1, -1, -1, %.2f, %.2f); %s\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],odd,odd,
	            strlen(ObjectData[i][oNote]) ? sprintf("// %s", ObjectData[i][oNote]) : (""));
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
YCMD:sel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Select an object by index.");
		return 1;
	}

	NoEditingMode(playerid);

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /sel <index> selects a object to edit");
	new index = strval(arg);
	if(index < 0) return SendClientMessage(playerid, STEALTH_YELLOW, "The index can not be negative numbers");

	if(Iter_Contains(Objects, index))
	{
		if(SetCurrObject(playerid, index)) {
            new line[128];
            format(line, sizeof(line), "You have selected object index %i for editing", index);
            SendClientMessage(playerid, STEALTH_GREEN, line);
        }
        else
            SendClientMessage(playerid, STEALTH_YELLOW, "You can not select objects in this object's group");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "That object does not exist!");
	return 1;
}

YCMD:dsel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Deselect current object.");
		return 1;
	}

    MapOpenCheck();
	EditCheck(playerid);
	NoEditingMode(playerid);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Selection has been deselected");

    SetCurrObject(playerid, -1);

	return 1;
}

// Selects the closest object to player
YCMD:scsel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Selects closest object.");
		return 1;
	}

	NoEditingMode(playerid);
    MapOpenCheck();

	new Float:dist = 9999999.0, Float:tmpdist, index = -1;

	foreach(new i : Objects)
	{
        if(!CanSelectObject(playerid, i))
            continue;
        
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
YCMD:dcsel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destroy closest object.");
		return 1;
	}

	NoEditingMode(playerid);
    MapOpenCheck();

	new Float:dist = 9999999.0, Float:tmpdist, index = -1;

	foreach(new i : Objects)
	{
		if(!CanSelectObject(playerid, i))
            continue;
        
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
		SaveUndoInfo(index, UNDO_TYPE_DELETED);

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


YCMD:csel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Select an object using cursor.");
		SendClientMessage(playerid, STEALTH_YELLOW, "Holding 'H' ('Enter' in /flymode) while clicking an object will copy properties to buffer.");
		SendClientMessage(playerid, STEALTH_YELLOW, "Holding 'Walk Key' while clicking an object will paste properties from buffer.");
		return 1;
	}

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
YCMD:mtset(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set the material of an object.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	if(GetEditMode(playerid) != EDIT_MODE_TEXTURING) NoEditingMode(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];
	new mindex;
	new tref;

	if(GetMaterials(playerid, arg, mindex, tref))
	{
		SaveUndoInfo(index, UNDO_TYPE_EDIT);

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
YCMD:mtsetall(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set the material of all objects of the same model.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];
	new mindex;
	new tref;
	new time = GetTickCount();

	if(GetMaterials(playerid, arg, mindex, tref))
	{
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(ObjectData[i][oModel] == ObjectData[CurrObject[playerid]][oModel])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				SetMaterials(i, mindex, tref);
				UpdateObjectText(i);

	        	if(ObjectData[i][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[i][oAttachedVehicle], i, VEHICLE_REATTACH_UPDATE);
			}
		}
		db_end_transaction(EditMap);

        SendClientMessage(playerid, STEALTH_GREEN, "Changed All Materials");

		foreach(new i : Player)
		{
  			if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
		}
		UpdateTextureSlot(playerid, mindex);
	}
	return 1;
}

YCMD:ogroup(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set the group ID of current object.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	if (!(0 <= strval(arg) < MAX_GROUPS))
		return SendClientMessage(playerid, STEALTH_YELLOW, sprintf("The group id must be from 0 to %d", MAX_GROUPS - 1));

    new index = CurrObject[playerid];

	SaveUndoInfo(index, UNDO_TYPE_EDIT);

    ObjectData[index][oGroup] = strval(arg);

    sqlite_ObjGroup(index);

    UpdateObject3DText(index);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	new line[128];
    format(line, sizeof(line), "You have changed the group ID of this object to: %i", ObjectData[index][oGroup]);
    SendClientMessage(playerid, STEALTH_GREEN, line);

	return 1;
}



tsfunc ColumnExists(DB:database, table[], columnname[])
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


YCMD:clone(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Clone current object with all properties.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	SetCurrObject(playerid, CloneObject(CurrObject[playerid]));

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Cloned your selected object the new object is now your selection");

	return 1;
}

YCMD:copy(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Copy an objects properties to the clipboard.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

    CopyCopyBuffer(playerid, CurrObject[playerid]);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Copied object textures/color/text to buffer");


    return 1;

}

CopyCopyBuffer(playerid, index)
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
		strcat((CopyBuffer[playerid][cObjectText][0] = '\0', CopyBuffer[playerid][cObjectText]), ObjectData[index][oObjectText], MAX_TEXT_LENGTH);
    }
    return 1;
}

YCMD:clear(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Clears current clipboard.");
		return 1;
	}

    ClearCopyBuffer(playerid);
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Cleared your copy buffer");
	return 1;
}

YCMD:paste(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Paste copied propeties to current object.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	PasteCopyBuffer(playerid, CurrObject[playerid]);
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Pasted your copy buffer to object");

	return 1;
}

PasteCopyBuffer(playerid, index)
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
	strcat((ObjectData[index][oObjectText][0] = '\0', ObjectData[index][oObjectText]), CopyBuffer[playerid][cObjectText], MAX_TEXT_LENGTH);

    // Destroy the object
    DestroyDynamicObject(ObjectData[index][oID]);

	// Re-create object
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
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

ClearCopyBuffer(playerid)
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
GetMaterials(playerid, arg[], &mindex, &tref)
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
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

	// Update streamer for all
	foreach(new i : Player) Streamer_UpdateEx(i, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ]);

	// Update the materials
	UpdateMaterial(index);

	// Save this material index to the data base
	sqlite_SaveMaterialIndex(index);
}


YCMD:ogoto(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Moves camera to the current object's position.");
		return 1;
	}

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
YCMD:mtcolor(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set the color of an object.");
		return 1;
	}

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
		SaveUndoInfo(index, UNDO_TYPE_EDIT);

		// Set the color
        sscanf(HexColor, "h", ObjectData[index][oColorIndex][mindex]);

		// Destroy the object
	    DestroyDynamicObject(ObjectData[index][oID]);

		// Re-create object
		ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
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
YCMD:mtcolorall(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set the color of all objects of the same model.");
		return 1;
	}

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

		new time = GetTickCount();

		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
		    if(ObjectData[i][oModel] == ObjectData[CurrObject[playerid]][oModel])
		    {
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

		        ObjectData[i][oColorIndex][mindex] = hcolor;

				// Destroy the object
			    DestroyDynamicObject(ObjectData[i][oID]);

				// Re-create object
				ObjectData[i][oID] = CreateDynamicObject(ObjectData[i][oModel], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
				Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[i][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

				// Update the materials
				UpdateMaterial(i);

				UpdateObjectText(i);

	        	if(ObjectData[i][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[i][oAttachedVehicle], i, VEHICLE_REATTACH_UPDATE);

				// Save this material index to the data base
				sqlite_SaveColorIndex(i);
		    }

		}
		db_end_transaction(EditMap);
		
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

YCMD:oswap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Change the model of current object.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new id = strval(arg);
	if(id > 0 && id < 20000)
	{
		new index = CurrObject[playerid];
        ObjectData[index][oModel] = id;

        SaveUndoInfo(index, UNDO_TYPE_EDIT);

		// Destroy the object
	    DestroyDynamicObject(ObjectData[index][oID]);

		// Re-create object
		ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

		// Update streamer for all
		foreach(new i : Player) Streamer_UpdateEx(i, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ]);

		// Update the materials
		UpdateMaterial(index);

		// Update the text
		UpdateObjectText(index);

		// Save changes to database
		sqlite_ObjModel(index);
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Invalid Model");
	return 1;
}

// Reset all materials
YCMD:mtreset(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Reset all materials and colors of current object.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index = CurrObject[playerid];

	SaveUndoInfo(index, UNDO_TYPE_EDIT);

   	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		ObjectData[index][oTexIndex][i] = 0;
		ObjectData[index][oColorIndex][i] = 0;
	    UpdateTextureSlot(playerid, i);
	}
    UpdateMaterial(index);

  	sqlite_SaveMaterialIndex(index);
    sqlite_SaveColorIndex(index);

	return 1;
}


// Enter edit mode
YCMD:editobject(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Edit current object.");
		return 1;
	}

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
YCMD:cobject(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Creates an object and selects it.");
		return 1;
	}

    MapOpenCheck();
	NoEditingMode(playerid);

 	new modelid;
	if(sscanf(arg, "i", modelid))
	{
	    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
        SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /cobject <modelid>");
		return 1;
	}

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

		SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_CREATED);

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

YCMD:dobject(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destroys current object and deselects it.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_DELETED);

    DeleteDynamicObject(CurrObject[playerid]);

	foreach(new i : Player)
	{
		if(CurrObject[playerid] == CurrObject[i]) SetCurrObject(i, -1);
	}

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Your object has been destroyed");

	return 1;
}

YCMD:rotreset(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Reset all rotation axes of current object.");
		return 1;
	}

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
YCMD:robject(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Reset all materials, colors, and text of current object.");
		return 1;
	}

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

	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
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
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF000000, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF800000, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF008000, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF000080, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFFC0C0C0, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFFFF0000, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF00FF00, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF0000FF, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF808080, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF800080, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF808000, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFF008080, 0xFFFFFFFF },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFFFFFFFF, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFFFF00FF, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }, // { 0xFFFFFF00, 0xFF000000 },
	{ 0xFFFFFF66, 0xFF00FF33 }  // { 0xFF00FFFF, 0xFF000000 }
};

YCMD:sindex(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Display texture slots of current object.");
		return 1;
	}

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
YCMD:rindex(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Restore objects textures after displaying texture slots.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
//    NoEditingMode(playerid);

	new index = CurrObject[playerid];

	// Destroy the object
    DestroyDynamicObject(ObjectData[index][oID]);

	// Re-create object
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
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

// Get information on a model
YCMD:minfo(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "See information on the provided model ID.");
		return 1;
	}

	
	new model = strval(arg);
	if(isnull(arg) || !(0 <= model <= 19999)) {
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /minfo <ID [0-19999]>");
		return 1;
	}
	
	new Float:r = Float:GetColSphereRadius(model),
		Float:rOff[3], Float:Min[3], Float:Max[3];
	
	GetColSphereOffset(model, rOff[0], rOff[1], rOff[2]);
	GetModelBoundingBox(model, Min[0], Min[1], Min[2], Max[0], Max[1], Max[2]);
	
	new buffer[1024];
	strcat(buffer, sprintf("Bounding Sphere\n\tRadius: %f\n\tRadius Offset: %f, %f, %f\n\n",
		r, rOff[0], rOff[1], rOff[2]));
	strcat(buffer, sprintf("Axis Alligned Bounding Box\n\tMinimum: %f, %f, %f\n\t",
		Min[0], Min[1], Min[2]));
	strcat(buffer, sprintf("Maximun: %f, %f, %f\n\t",
		Max[0], Max[1], Max[2]));
	strcat(buffer, sprintf("Dimensions: %f, %f, %f",
		floatabs(Min[0] - Max[0]), floatabs(Min[1] - Max[1]), floatabs(Min[2] - Max[2])));
	
	Dialog_Show(
		playerid, DIALOG_STYLE_MSGBOX, 
		sprintf("Model Information: %i", model), 
		buffer, 
		"Okay"
	);

	return 1;
}

// Set a pivot point
YCMD:pivot(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set the desired pivot to rotate around.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:x, Float:y, Float:z, Float:fa;
	GetPosFaInFrontOfPlayer(playerid, 2.0, x, y, z, fa);

	PivotObject[playerid] = CreateDynamicObject(1974, x, y, z, 0.0, 0.0, 0.0, -1, -1, playerid);

	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, PivotObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

	SetDynamicObjectMaterial(PivotObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

	Streamer_Update(playerid);

	EditingMode[playerid] = true;
	SetEditMode(playerid, EDIT_MODE_PIVOT);

	EditDynamicObject(playerid, PivotObject[playerid]);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, "Editing your pivot point");

	return 1;
}

YCMD:togpivot(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Toggle pivot rotation.");
		return 1;
	}

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
YCMD:ox(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move current object along the X axis.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

    ObjectData[CurrObject[playerid]][oX] += dist;

    SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);

	UpdateObject3DText(CurrObject[playerid]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on Y axis
YCMD:oy(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move current object along the Y axis.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

    ObjectData[CurrObject[playerid]][oY] += dist;

    SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);

	UpdateObject3DText(CurrObject[playerid]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on Z axis
YCMD:oz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move current object along the Z axis.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:dist;

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

    ObjectData[CurrObject[playerid]][oZ] += dist;

    SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);

	UpdateObject3DText(CurrObject[playerid]);

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}

// Move object on RX rot
YCMD:rx(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate currently object around the X axis.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:rot;

	rot = floatstr(arg);
	if(rot == 0) rot = 5.0;

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

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
YCMD:ry(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate currently object around the Y axis.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:rot;

	rot = floatstr(arg);
	if(rot == 0) rot = 5.0;

	SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

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
YCMD:rz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate currently object around the Z axis.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:rot;

	rot = floatstr(arg);
	if(rot == 0) rot = 5.0;

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

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
YCMD:dox(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move all loaded objects along the X axis.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:dist, time;
	time = GetTickCount();

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	db_begin_transaction(EditMap);
	foreach(new i : Objects)
	{
		SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

	    ObjectData[i][oX] += dist;

	    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		UpdateObject3DText(i);

	    sqlite_UpdateObjectPos(i);
	}
	db_end_transaction(EditMap);

	return 1;
}

// Move all objects on Y axis
YCMD:doy(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move all loaded objects along the Y axis.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:dist, time;
	time = GetTickCount();

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	db_begin_transaction(EditMap);
	foreach(new i : Objects)
	{
		SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

	    ObjectData[i][oY] += dist;

	    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		UpdateObject3DText(i);

	    sqlite_UpdateObjectPos(i);
	}
	db_end_transaction(EditMap);

	return 1;
}

// Move all objects on Z axis
YCMD:doz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move all loaded objects along the Z axis.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

	new Float:dist, time;
	time = GetTickCount();

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	db_begin_transaction(EditMap);
	foreach(new i : Objects)
	{
		SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

	    ObjectData[i][oZ] += dist;

	    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		UpdateObject3DText(i);

	    sqlite_UpdateObjectPos(i);
	}
	db_end_transaction(EditMap);

	return 1;
}

// Rotate map on RX
YCMD:drx(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate all loaded objects around the X axis.");
		return 1;
	}

	MapOpenCheck();

	new Float:Delta, time;
	time = GetTickCount();

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
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

			AttachObjectToPoint(i, mCenterX, mCenterY, mCenterZ, Delta, 0.0, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
			SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			UpdateObject3DText(i);

			sqlite_UpdateObjectPos(i);
		}
		db_end_transaction(EditMap);

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
YCMD:dry(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate all loaded objects around the Y axis.");
		return 1;
	}

	MapOpenCheck();

	new Float:Delta, time;
	time = GetTickCount();

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
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

			AttachObjectToPoint(i, mCenterX, mCenterY, mCenterZ, 0.0, Delta, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
			SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			UpdateObject3DText(i);

			sqlite_UpdateObjectPos(i);
		}
		db_end_transaction(EditMap);

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
YCMD:drz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate all loaded objects around the Z axis.");
		return 1;
	}

	MapOpenCheck();

	new Float:Delta, time;
	time = GetTickCount();

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
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

			AttachObjectToPoint(i, mCenterX, mCenterY, mCenterZ, 0.0, 0.0, Delta, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
			SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			UpdateObject3DText(i);

			sqlite_UpdateObjectPos(i);
		}
		db_end_transaction(EditMap);

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

YCMD:odd(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set a specific object's draw distance.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

	new Float:dd;
	dd = floatstr(arg);
	if(dd == 0.0) dd = 300.0;

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

    ObjectData[CurrObject[playerid]][oDD] = dd;
    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CurrObject[playerid]][oID], E_STREAMER_DRAW_DISTANCE, dd);
    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CurrObject[playerid]][oID], E_STREAMER_STREAM_DISTANCE, dd);

    sqlite_UpdateObjectDD(CurrObject[playerid]);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, sprintf("Objects draw distance set to %.2f", dd));
    
	return 1;
}

// Extras
YCMD:hidetext3d(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Hide all 3D text labels.");
		return 1;
	}

    TextOption[tShowText] = false;
    
	HideGroupLabels(playerid);
	HideObjectText();
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "All 3D Text labels hidden");
	return 1;
}

YCMD:showtext3d(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Show all 3D text labels.");
		return 1;
	}
	
	/*/Experimental Multiplier
	new Float:mult = floatstr(arg);
	if(0.0 < mult <= 1.0)
		Streamer_SetRadiusMultiplier(STREAMER_TYPE_3D_TEXT_LABEL, mult, playerid);
	else if(mult) {
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Invalid multiplier specified, must be between 0.0 and 1.0");
		return 1;
	}
	else
		Streamer_SetRadiusMultiplier(STREAMER_TYPE_3D_TEXT_LABEL, 1.0, playerid);*/
    
    TextOption[tShowText] = true;
    
    ShowGroupLabels(playerid);
	ShowObjectText();
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "All 3D Text labels shown");
	return 1;
}

YCMD:edittext3d(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Shows you a dialog with 3D text options.");
		return 1;
	}
    
    new optline[256];
    
    // Init the text menu
    inline SelectOption(spid, sdialogid, sresponse, slistitem, string:stext[])
	{
		#pragma unused slistitem, sdialogid, spid, stext
		if(sresponse)
		{
            // Toggle the selected option
            TextOption[TEXTOPTIONS:slistitem] = !TextOption[TEXTOPTIONS:slistitem];
            
            // Toggled text?
            if(slistitem == 0)
            {
                if(TextOption[tShowText])
                {
                    ShowGroupLabels(playerid);
                    ShowObjectText();
                }
                else
                {
                    HideGroupLabels(playerid);
                    HideObjectText();
                }
            }
	
            // Show it again
            format(optline, sizeof(optline), "{FFFF00}Text: %s\n{FFFF00}Object Note: %s\n{FFFF00}Model Info: %s\n{FFFF00}Group ID: %s\n{FFFF00}Grouped Text: %s\n{FFFF00}Always Show New Objects: %s\n",
                (TextOption[tShowText] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
                (TextOption[tShowNote] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
                (TextOption[tShowModel] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
                (TextOption[tShowGroup] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
                (TextOption[tShowGrouped] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
                (TextOption[tAlwaysShowNew] ? ("{00AA00}Enabled") : ("{FF3000}Disabled"))
            );
            
            Dialog_ShowCallback(playerid, using inline SelectOption, DIALOG_STYLE_LIST, "Texture Studio - 3D Text Editor", optline, "Ok", "Cancel");
		}
	}
	
    // Show the dialog
    format(optline, sizeof(optline), "{FFFF00}Text: %s\n{FFFF00}Object Note: %s\n{FFFF00}Model Info: %s\n{FFFF00}Group ID: %s\n{FFFF00}Grouped Text: %s\n{FFFF00}Always Show New Objects: %s\n",
        (TextOption[tShowText] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
        (TextOption[tShowNote] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
        (TextOption[tShowModel] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
        (TextOption[tShowGroup] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
        (TextOption[tShowGrouped] ? ("{00AA00}Enabled") : ("{FF3000}Disabled")),
                (TextOption[tAlwaysShowNew] ? ("{00AA00}Enabled") : ("{FF3000}Disabled"))
    );

	Dialog_ShowCallback(playerid, using inline SelectOption, DIALOG_STYLE_LIST, "Texture Studio - 3D Text Editor", optline, "Ok", "Cancel");
	return 1;
}

YCMD:note(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Show or change an object's note.");
		return 1;
	}
    
    MapOpenCheck();
	
 	new index, note[64];
	if(sscanf(arg, "iS()[64]", index, note))
	{
	    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
        SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /note <Index> <Optional: New Note>");
		return 1;
	}
    
    if(isnull(note) || !strlen(note))
    {
        SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
        SendClientMessage(playerid, STEALTH_GREEN, sprintf("Object's note: %s", ObjectData[index][oNote]));
    }
    else
    {
        SaveUndoInfo(index, UNDO_TYPE_EDIT);
        format(ObjectData[index][oNote], 64, "%s", note);
        sqlite_ObjNote(index);
        UpdateObject3DText(index);
        SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
        SendClientMessage(playerid, STEALTH_YELLOW, "Note changed");
    }
	return 1;
}

YCMD:setspawn(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set this map's spawn position to your current position.");
		return 1;
	}
    
    MapOpenCheck();
    
    GetPlayerPos(playerid, MapSetting[mSpawn][xPos], MapSetting[mSpawn][yPos], MapSetting[mSpawn][zPos]);
    sqlite_UpdateSettings();
    
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_YELLOW, sprintf("You have set the map's spawn position to (%0.2f, %0.2f, %0.2f)", MapSetting[mSpawn][xPos], MapSetting[mSpawn][yPos], MapSetting[mSpawn][zPos]));
	return 1;
}

YCMD:gotomap(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Sends you to this map's spawn position.");
		return 1;
	}
    
    if(MapSetting[mSpawn][xPos] == 0.0)
        return SendClientMessage(playerid, STEALTH_YELLOW, "This map doesn't have a spawn position, set one with \"/setspawn\"");
    
    SetPlayerPos(playerid, MapSetting[mSpawn][xPos], MapSetting[mSpawn][yPos], MapSetting[mSpawn][zPos]);
    
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_YELLOW, "You've been teleported to the map's spawn position");
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

YCMD:stopedit(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Reset editing mode.");
		return 1;
	}

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(EditingMode[playerid])
	{
		EditingMode[playerid] = false;
        CancelEdit(playerid);
        SendClientMessage(playerid, STEALTH_GREEN, "Editing mode reset.");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "You're not editing.");

	return 1;
}
