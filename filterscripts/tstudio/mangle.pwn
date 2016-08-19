#tryinclude <colandreas>
#if !defined COLANDREAS
	#endinput
#endif

#define MANGLE

public OnFilterScriptInit()
{
	CA_Init();

	#if defined MA_OnFilterScriptInit
		MA_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit MA_OnFilterScriptInit
#if defined MA_OnFilterScriptInit
	forward MA_OnFilterScriptInit();
#endif

new Float:GroupSlopeRX[MAX_PLAYERS], Float:GroupSlopeRY[MAX_PLAYERS];

/* Debug Command
YCMD:gs(playerid, arg[], help)
{
	new Float:x, Float:y, Float:z, line[128];
	GetPlayerPos(playerid, x, y, z);
    CalcSlopeAtPoint(x, y, x, y);
	format(line, sizeof(line), "Slope X:%3.4f | Slope Y:%3.4f", x, y);
    SendClientMessage(playerid, -1, line);
	return 1;
}*/


// Load a prefab specify a filename
YCMD:prefabsets(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Load a prefabricated group of objects rotated according to the ground slope.");
		return 1;
	}

	MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) ShowPrefabs(playerid);
	else
	{
		new mapname[128];
		format(mapname, sizeof(mapname), "tstudio/PreFabs/%s.db", arg);
		if(fexist(mapname))
		{
		    PrefabDB = db_open_persistent(mapname);
		    sqlite_LoadPrefab(playerid);
		    db_free_persistent(PrefabDB);

			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			//CalcSlopeAtPoint(x, y, GroupSlopeRX[playerid], GroupSlopeRY[playerid]);
			CA_RayCastLineAngle(x, y, 1200.0, x, y, -100.0, z, z, z, GroupSlopeRX[playerid], GroupSlopeRY[playerid], z);
   			GroupRotate(playerid, GroupSlopeRX[playerid], GroupSlopeRY[playerid], 0.0);
			
			SendClientMessage(playerid, STEALTH_GREEN, "Prefab loaded and set to your group selection");
		}
		else SendClientMessage(playerid, STEALTH_YELLOW, "That prefab does not exist!");
	}

	return 1;
}

// Rotate group on ground slope
YCMD:gsets(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate all currently selected objects accordingly to ground slope.");
		return 1;
	}

    MapOpenCheck();
	new time = GetTickCount();

	// We need to get the map center as the rotation node
	new bool:value, Float:gCenterX, Float:gCenterY, Float:gCenterZ;

	if(PivotPointOn[playerid])
	{
		new bool:hasgroup;
		foreach(new i : Objects)
		{
		    if(GroupedObjects[playerid][i])
		    {
			    gCenterX = PivotPoint[playerid][xPos];
			    gCenterY = PivotPoint[playerid][yPos];
			    gCenterZ = PivotPoint[playerid][zPos];
				value = true;
                hasgroup = true;
				break;
			}
		}
		if(!hasgroup)
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "There is not enough objects for this command to work");
		}
	}
	else if(GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ)) value = true;

	if(value)
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		//CalcSlopeAtPoint(x, y, GroupSlopeRX[playerid], GroupSlopeRY[playerid]);
		CA_RayCastLineAngle(x, y, 1200.0, x, y, -100.0, z, z, z, GroupSlopeRX[playerid], GroupSlopeRY[playerid], z);

		// Loop through all objects and perform rotation calculations
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				
				AttachObjectToPoint(i, gCenterX, gCenterY, gCenterZ, GroupSlopeRX[playerid], GroupSlopeRY[playerid], 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

				UpdateObject3DText(i);

				sqlite_UpdateObjectPos(i);
			}
		}
		db_end_transaction(EditMap);

   		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Group RZ rotation complete ");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There is not enough objects for this command to work");
	}

	return 1;
}

// Edit a group
YCMD:editgroups(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Edit currently edited objects simultaneously.");
		SendClientMessage(playerid, STEALTH_GREEN, "Hold 'Walk Key' to set the group rotation pivot, you can only do this once per edit.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(PlayerHasGroup(playerid))
	{
		GetGroupCenter(playerid, LastPivot[playerid][xPos], LastPivot[playerid][yPos], LastPivot[playerid][zPos]);

		LastGroupPosition[playerid][xPos] = LastPivot[playerid][xPos];
		LastGroupPosition[playerid][yPos] = LastPivot[playerid][yPos];
		LastGroupPosition[playerid][zPos] = LastPivot[playerid][zPos];

		PivotOffset[playerid][xPos] = 0.0;
		PivotOffset[playerid][yPos] = 0.0;
		PivotOffset[playerid][zPos] = 0.0;
		
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		CA_RayCastLineAngle(x, y, 1200.0, x, y, -100.0, z, z, z, GroupSlopeRX[playerid], GroupSlopeRY[playerid], z);

		PivotObject[playerid] = CreateDynamicObject(1974, LastPivot[playerid][xPos], LastPivot[playerid][yPos], LastPivot[playerid][zPos], GroupSlopeRX[playerid], GroupSlopeRY[playerid], z, -1, -1, playerid);

		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, PivotObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

		SetDynamicObjectMaterial(PivotObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

		Streamer_Update(playerid);

		EditingMode[playerid] = true;
		PivotReset[playerid] = true;
		SetEditMode(playerid, EDIT_MODE_OBJECTGROUP);
	    EditDynamicObject(playerid, PivotObject[playerid]);

	    SendClientMessage(playerid, STEALTH_GREEN, "Editing your group");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "You must have at least one object grouped");

	return 1;
}

// Rotate object on ground slope
YCMD:osets(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate currently selected object according to ground slope.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	CA_RayCastLineAngle(x, y, 1200.0, x, y, -100.0, z, z, z, GroupSlopeRX[playerid], GroupSlopeRY[playerid], z);
	
	if(PivotPointOn[playerid])
	{
		new i = CurrObject[playerid];
		AttachObjectToPoint(i, PivotPoint[playerid][xPos], PivotPoint[playerid][yPos], PivotPoint[playerid][zPos], GroupSlopeRX[playerid], GroupSlopeRY[playerid], 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
		SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
		UpdateObject3DText(CurrObject[playerid]);
	}
	else
	{
	    ObjectData[CurrObject[playerid]][oRX] += GroupSlopeRX[playerid];
	    ObjectData[CurrObject[playerid]][oRY] += GroupSlopeRY[playerid];
	    SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
	}

    sqlite_UpdateObjectPos(CurrObject[playerid]);

	return 1;
}


/*
// Load a prefab specify a filename adjust to facing angle
YCMD:pmaf(playerid, arg[], help)
{
	MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) ShowPrefabs(playerid);
	else
	{
		new Float:zrot, mapname[128];
		if(sscanf(arg, "s[128]f", mapname, zrot)) return SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /pmaf <prefab> <zrot>");
		
		format(mapname, sizeof(mapname), "tstudio/PreFabs/%s.db", mapname);
		if(fexist(mapname))
		{
		    PrefabDB = db_open_persistent(mapname);
		    sqlite_LoadPrefab(playerid, false);
		    db_free_persistent(PrefabDB);

			new Float:x, Float:y, Float:z, Float:rx, Float:ry;

			// Find the slope
			GetPlayerPos(playerid, x, y, z);
			CalcSlopeAtPoint(x, y, rx, ry);

			// Translate new rotation offsets
   			GroupRotate(playerid, 0.0, 0.0, zrot);

			// Translate new rotation to slope
   			GroupRotate(playerid, rx, ry, 0.0);

			SendClientMessage(playerid, STEALTH_GREEN, "Prefab loaded and set to your group selection");
		}
		else SendClientMessage(playerid, STEALTH_YELLOW, "That prefab does not exist!");
	}

	return 1;
}
*/

YCMD:cobjectsets(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Creates a rotated object according to the map slope and selects it.");
		return 1;
	}

    MapOpenCheck();
	NoEditingMode(playerid);

 	new modelid, Float:RZAngle;
	if(sscanf(arg, "iF(0.0)", modelid, RZAngle))
	{
	    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
        SendClientMessage(playerid, STEALTH_YELLOW, "Usage: /csobject <modelid>");
		return 1;
	}

	// Set the initial object position
	new Float:px, Float:py, Float:pz, Float:fa, Float:RXAngle, Float:RYAngle;
	new Float:colradius = GetColSphereRadius(modelid);
	GetPosFaInFrontOfPlayer(playerid, colradius + 1.0, px, py, pz, fa);
	pz -= 1.0;

	// Calculate rotation
	//CalcSlopeAtPoint(px, py, RXAngle, RYAngle);
	CA_RayCastLineAngle(px, py, 1200.0, px, py, -100.0, fa, fa, fa, RXAngle, RYAngle, RZAngle);
	//new Float:angle = float(random(360));
	//ObjectRotateZ(RXAngle, RYAngle, RZAngle, angle, RXAngle, RYAngle, RZAngle);

	// Create the object
	SetCurrObject(playerid, AddDynamicObject(modelid, px, py, pz, RXAngle, RYAngle, RZAngle));

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



tsfunc CalcSlopeAtPoint(Float:x, Float:y, &Float:RXAngle, &Float:RYAngle)
{
	new Float:North[3], Float:South[3], Float:East[3], Float:West[3], Float:opposite, Float:hypotenuse;

	// Set slope positions
	North[0] = x;
	North[1] = y + 1;

	South[0] = x;
	South[1] = y - 1;

	East[0] = x + 1;
	East[1] = y;

	West[0] = x - 1;
	West[1] = y;

	// Use ColAndreas to get Z Values
	CA_FindZ_For2DCoord(North[0], North[1], North[2]);
	CA_FindZ_For2DCoord(South[0], South[1], South[2]);
	CA_FindZ_For2DCoord(East[0], East[1], East[2]);
	CA_FindZ_For2DCoord(West[0], West[1], West[2]);

	// Calculate Slope angles
	// North South RX
	hypotenuse = getdist3d(North[0], North[1], North[2], South[0], South[1], South[2]);
	opposite = getdist3d(North[0], North[1], North[2], North[0], North[1], South[2]);

	RXAngle = asin(floatdiv(opposite, hypotenuse));
	if(South[2] > North[2]) RXAngle *= -1;

	// West East RY
	hypotenuse = getdist3d(West[0], West[1], West[2], East[0], East[1], East[2]);
	opposite = getdist3d(West[0], West[1], West[2], West[0], West[1], East[2]);

	RYAngle = asin(floatdiv(opposite, hypotenuse));
	if(East[2] > West[2]) RYAngle *= -1;

	return 1;
}


tsfunc ObjectRotateZ(Float:RX, Float:RY, Float:RZ, Float:rot_z, &Float:NewRX, &Float:NewRY, &Float:NewRZ)
{
	new
		Float:sinx,
		Float:siny,
		Float:sinz,
		Float:cosx,
		Float:cosy,
		Float:cosz;

    FloatConvertValue(RX, RY, RZ, sinx, siny, sinz, cosx, cosy, cosz);
    // Convert from one euler angle sequence (ZXY) to another and add the rotation
    FloatConvertValue(asin(cosx * cosy), atan2(sinx, cosx * siny) + rot_z, atan2(cosy * cosz * sinx - siny * sinz, cosz * siny - cosy * sinx * -sinz),
		sinx, siny, sinz, cosx, cosy, cosz);

    // Convert back to the original euler angle sequence and apply the new rotation to the object
    NewRX = asin(cosx * siny),
	NewRY = atan2(cosx * cosy, sinx),
	NewRZ = atan2(cosz * sinx * siny - cosy * sinz, cosy * cosz + sinx * siny * sinz);
    return 1;
}

tsfunc FloatConvertValue(Float:rot_x, Float:rot_y, Float:rot_z, &Float:sinx, &Float:siny, &Float:sinz, &Float:cosx, &Float:cosy, &Float:cosz)
{
    sinx = floatsin(rot_x, degrees);
    siny = floatsin(rot_y, degrees);
    sinz = floatsin(rot_z, degrees);
    cosx = floatcos(rot_x, degrees);
    cosy = floatcos(rot_y, degrees);
    cosz = floatcos(rot_z, degrees);
    return 1;
}


/* MEDIT Prefab import

// Import function
// Load prefab

#define     MAX_MATERIAL_INDEX      16

YCMD:cpf(playerid, arg[], help)
{
	new dir:dHandle = dir_open("./scriptfiles/tstudio/medit/importpf/");
	new item[40], type;
	new extension[6];

	// Create a load list
	while(dir_list(dHandle, item, type))
	{
	 	if(type != FM_DIR)
	    {
			// We need to check extension
			if(strlen(item) > 3)
			{
				format(extension, sizeof(extension), "%s%s%s%s%s", item[strlen(item) - 5], item[strlen(item) - 4], item[strlen(item) - 3], item[strlen(item) - 2],item[strlen(item) - 1]);

				// File is apparently a prefab

				new tempmap[64];
				strmid(tempmap, item, 0, strlen(item) - 6, 64);
				
				printf(tempmap);
				
				
				if(!strcmp(extension, "mpfab")) ConvertMeditPrefab(tempmap);
			}
		}
	}

	return 1;
}


// Old medit enum

enum object_info {
	object_id,
	medit_modelid,
	Text3D:medit_Text3D[MAX_OBJECTS],
	Float:pfox,
	Float:pfoy,
	Float:pfoz,
	Float:pfrx,
	Float:pfry,
	Float:pfrz,
	Material_Index[MAX_MATERIAL_INDEX],
	Material_Color[MAX_MATERIAL_INDEX],
	usetext[MAX_MATERIAL_INDEX],
	Material_FontFace[MAX_MATERIAL_INDEX],
	Material_FontSize[MAX_MATERIAL_INDEX],
	Material_FontBold[MAX_MATERIAL_INDEX],
	Material_FontColor[MAX_MATERIAL_INDEX],
	Material_BackColor[MAX_MATERIAL_INDEX],
	Material_Alignment[MAX_MATERIAL_INDEX],
	Material_TextFontSize[MAX_MATERIAL_INDEX]
}


new DB: PrefabImportDB;
new DBStatement:insertprefabimpstmt;
new tempobject[object_info];
new temp_Material_Object_Text[MAX_MATERIAL_INDEX][64];


ConvertMeditPrefab(tempmap[64])
{
	new templine[256];
	new Float:ZOffSet;
	new openmap[64];
	new opendb[64];

	// Create import database

	format(opendb, 64, "tstudio/medit/convertpf/%s.db", tempmap);
	PrefabImportDB = db_open_persistent(opendb);

	new NewImportString[512];
	strimplode(" ",
		NewImportString,
		sizeof(NewImportString),
		"CREATE TABLE IF NOT EXISTS `Objects`",
		"(ModelID INTEGER,",
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
		"ObjectText TEXT);"
	);

	db_exec(PrefabImportDB, NewImportString);

	// Prefab extra info
	db_exec(PrefabImportDB, "CREATE TABLE IF NOT EXISTS `PrefabInfo` (zOFF REAL);");
	db_exec(PrefabImportDB, "INSERT INTO `PrefabInfo` VALUES(0.0);");


	// Prepare query
	new ImportPrefabInsert[1024];
	
	strimplode(" ",
		ImportPrefabInsert,
		sizeof(ImportPrefabInsert),
		"INSERT INTO `Objects`",
        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
	);
	
	// Prepare data base for writing
	insertprefabimpstmt = db_prepare(PrefabImportDB, ImportPrefabInsert);


	



	// Read in map info new style format and get the prefab center for correcting
	format(openmap, 64, "tstudio/medit/importpf/%s.mpfab", tempmap);


	new Float:pfx, Float:pfy, Float:pfz;
	GetPrefabCenter(openmap, pfx, pfy, pfz);


	new File:f;
	f = fopen(openmap,io_read);

	// Check Version
	fread(f,templine,sizeof(templine),false);

	// This is a new medit version use new load routine
	new index;

	// new version load
	if(!strcmp(strtok(templine,index), "420medit-Version:"))
	{
		ZOffSet = floatstr(strtok(templine,index));
		ZOffSet = floatstr(strtok(templine,index));
		format(templine, sizeof(templine), "ZOffSet: %f", ZOffSet);

		while(fread(f,templine,sizeof(templine),false)) {
			index = 0;
			tempobject[object_id] = INVALID_OBJECT_ID;
			tempobject[medit_modelid] = strval(strtok(templine,index));
			tempobject[pfox] = floatstr(strtok(templine,index))-pfx;
			tempobject[pfoy] = floatstr(strtok(templine,index))-pfy;
			tempobject[pfoz] = floatstr(strtok(templine,index))-pfz;
			tempobject[pfrx] = floatstr(strtok(templine,index));
			tempobject[pfry] = floatstr(strtok(templine,index));
			tempobject[pfrz] = floatstr(strtok(templine,index));

			for(new i = 0; i < MAX_MATERIAL_INDEX; i++)
			{
				tempobject[Material_Index][i] = strval(strtok(templine,index));
				tempobject[Material_Color][i] = strval(strtok(templine,index));
			}

			// Load Text Data // Only only use first slot anyways
			for(new i = 0; i < MAX_MATERIAL_INDEX; i++)
			{
				index = 0;
				fread(f,templine,sizeof(templine),false);
				tempobject[usetext][i] = strval(strtok(templine,index));
				tempobject[Material_FontFace][i] = strval(strtok(templine,index));
				tempobject[Material_FontSize][i] = strval(strtok(templine,index));
				tempobject[Material_FontBold][i] = strval(strtok(templine,index));
				tempobject[Material_FontColor][i] = strval(strtok(templine,index));
				tempobject[Material_BackColor][i] = strval(strtok(templine,index));
				tempobject[Material_Alignment][i] = strval(strtok(templine,index));
				tempobject[Material_TextFontSize][i] = strval(strtok(templine,index));

				new bool:done;
				temp_Material_Object_Text[i] = "";
				while(done == false)
				{
					new tmptext[64];
                    tmptext = strtok(templine,index);
                    if(!strcmp(tmptext, "E\r\n")) done = true;
                    else format(temp_Material_Object_Text[i], 64, "%s%s ",temp_Material_Object_Text[i], tmptext);
				}
			}
			// Object read save object to new prefab format
			stmt_bind_value(insertprefabimpstmt, 0, DB::TYPE_INT, tempobject[medit_modelid]);
			stmt_bind_value(insertprefabimpstmt, 1, DB::TYPE_FLOAT, tempobject[pfox]);
			stmt_bind_value(insertprefabimpstmt, 2, DB::TYPE_FLOAT, tempobject[pfoy]);
		    stmt_bind_value(insertprefabimpstmt, 3, DB::TYPE_FLOAT, tempobject[pfoz]);
		    stmt_bind_value(insertprefabimpstmt, 4, DB::TYPE_FLOAT, tempobject[pfrx]);
		    stmt_bind_value(insertprefabimpstmt, 5, DB::TYPE_FLOAT, tempobject[pfry]);
		    stmt_bind_value(insertprefabimpstmt, 6, DB::TYPE_FLOAT, tempobject[pfrz]);
		    stmt_bind_value(insertprefabimpstmt, 7, DB::TYPE_ARRAY, tempobject[Material_Index], MAX_MATERIALS);
		    stmt_bind_value(insertprefabimpstmt, 8, DB::TYPE_ARRAY, tempobject[Material_Color], MAX_MATERIALS);
		    stmt_bind_value(insertprefabimpstmt, 9, DB::TYPE_INT, tempobject[usetext][0]);
		    stmt_bind_value(insertprefabimpstmt, 10, DB::TYPE_INT, tempobject[Material_FontFace][0]);
		    stmt_bind_value(insertprefabimpstmt, 11, DB::TYPE_INT, tempobject[Material_FontSize][0]);
		    stmt_bind_value(insertprefabimpstmt, 12, DB::TYPE_INT, tempobject[Material_FontBold][0]);
		    stmt_bind_value(insertprefabimpstmt, 13, DB::TYPE_INT, tempobject[Material_FontColor][0]);
		 	stmt_bind_value(insertprefabimpstmt, 14, DB::TYPE_INT, tempobject[Material_BackColor][0]);
		    stmt_bind_value(insertprefabimpstmt, 15, DB::TYPE_INT, tempobject[Material_Alignment][0]);
		    stmt_bind_value(insertprefabimpstmt, 16, DB::TYPE_INT, tempobject[Material_TextFontSize][0]);
		    stmt_bind_value(insertprefabimpstmt, 17, DB::TYPE_STRING, temp_Material_Object_Text[0], MAX_TEXT_LENGTH);

            stmt_execute(insertprefabimpstmt);
		}

	}
	// Old version load
	else
	{
		fclose(f);
		f = fopen(openmap,io_read);

		while(fread(f,templine,sizeof(templine),false)) {
			index = 0;
			tempobject[object_id] = INVALID_OBJECT_ID;
			tempobject[medit_modelid] = strval(strtok(templine,index));
			tempobject[pfox] = floatstr(strtok(templine,index))-pfx;
			tempobject[pfoy] = floatstr(strtok(templine,index))-pfy;
			tempobject[pfoz] = floatstr(strtok(templine,index))-pfz;
			tempobject[pfrx] = floatstr(strtok(templine,index));
			tempobject[pfry] = floatstr(strtok(templine,index));
			tempobject[pfrz] = floatstr(strtok(templine,index));

			for(new i = 0; i < MAX_MATERIAL_INDEX; i++) { tempobject[Material_Index][i] = strval(strtok(templine,index)); }

			// Bind our reults
			stmt_bind_value(insertprefabimpstmt, 0, DB::TYPE_INT, tempobject[medit_modelid]);
		  	stmt_bind_value(insertprefabimpstmt, 1, DB::TYPE_FLOAT, tempobject[pfox]);
		   	stmt_bind_value(insertprefabimpstmt, 2, DB::TYPE_FLOAT, tempobject[pfoy]);
		   	stmt_bind_value(insertprefabimpstmt, 3, DB::TYPE_FLOAT, tempobject[pfoz]);
			stmt_bind_value(insertprefabimpstmt, 4, DB::TYPE_FLOAT, tempobject[pfrx]);
			stmt_bind_value(insertprefabimpstmt, 5, DB::TYPE_FLOAT, tempobject[pfry]);
			stmt_bind_value(insertprefabimpstmt, 6, DB::TYPE_FLOAT, tempobject[pfrz]);
			stmt_bind_value(insertprefabimpstmt, 7, DB::TYPE_ARRAY, tempobject[Material_Index], MAX_MATERIALS);
			stmt_bind_value(insertprefabimpstmt, 8, DB::TYPE_ARRAY, tempobject[Material_Color], MAX_MATERIALS);
			stmt_bind_value(insertprefabimpstmt, 9, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 10, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 11, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 12, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 13, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 14, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 15, DB::TYPE_INT, 0);
			stmt_bind_value(insertprefabimpstmt, 16, DB::TYPE_INT, 20);
			stmt_bind_value(insertprefabimpstmt, 17, DB::TYPE_STRING, "None", MAX_TEXT_LENGTH);


            stmt_execute(insertprefabimpstmt);
		}
	}

	fclose(f);
	db_free_persistent(PrefabImportDB);

	return 1;


}


tsfunc GetPrefabCenter(openmap[64], &Float:pfx, &Float:pfy, &Float:pfz)
{
	new File:f;
	f = fopen(openmap,io_read);
	new templine[256];
	new Float:ZOffSet;

	new Float:highX = -9999999.0;
	new Float:highY = -9999999.0;
	new Float:highZ = -9999999.0;

	new Float:lowX  = 9999999.0;
	new Float:lowY  = 9999999.0;
	new Float:lowZ  = 9999999.0;

	// Check Version
	fread(f,templine,sizeof(templine),false);

	// This is a new medit version use new load routine
	new index;

	// new version load
	if(!strcmp(strtok(templine,index), "420medit-Version:"))
	{
		ZOffSet = floatstr(strtok(templine,index));
		ZOffSet = floatstr(strtok(templine,index));
		format(templine, sizeof(templine), "ZOffSet: %f", ZOffSet);

		while(fread(f,templine,sizeof(templine),false)) {
			index = 0;
			tempobject[object_id] = INVALID_OBJECT_ID;
			tempobject[medit_modelid] = strval(strtok(templine,index));
			tempobject[pfox] = floatstr(strtok(templine,index));
			tempobject[pfoy] = floatstr(strtok(templine,index));
			tempobject[pfoz] = floatstr(strtok(templine,index));
			tempobject[pfrx] = floatstr(strtok(templine,index));
			tempobject[pfry] = floatstr(strtok(templine,index));
			tempobject[pfrz] = floatstr(strtok(templine,index));

			for(new i = 0; i < MAX_MATERIAL_INDEX; i++)
			{
				tempobject[Material_Index][i] = strval(strtok(templine,index));
				tempobject[Material_Color][i] = strval(strtok(templine,index));
			}

			// Load Text Data // Only only use first slot anyways
			for(new i = 0; i < MAX_MATERIAL_INDEX; i++)
			{
				index = 0;
				fread(f,templine,sizeof(templine),false);
				tempobject[usetext][i] = strval(strtok(templine,index));
				tempobject[Material_FontFace][i] = strval(strtok(templine,index));
				tempobject[Material_FontSize][i] = strval(strtok(templine,index));
				tempobject[Material_FontBold][i] = strval(strtok(templine,index));
				tempobject[Material_FontColor][i] = strval(strtok(templine,index));
				tempobject[Material_BackColor][i] = strval(strtok(templine,index));
				tempobject[Material_Alignment][i] = strval(strtok(templine,index));
				tempobject[Material_TextFontSize][i] = strval(strtok(templine,index));

				new bool:done;
				temp_Material_Object_Text[i] = "";
				while(done == false)
				{
					new tmptext[64];
                    tmptext = strtok(templine,index);
                    if(!strcmp(tmptext, "E\r\n")) done = true;
                    else format(temp_Material_Object_Text[i], 64, "%s%s ",temp_Material_Object_Text[i], tmptext);
				}
			}
			// Calculate group center
			if(tempobject[pfox] > highX) highX = tempobject[pfox];
			if(tempobject[pfoy] > highY) highY = tempobject[pfoy];
			if(tempobject[pfoz] > highZ) highZ = tempobject[pfoz];
			if(tempobject[pfox] < lowX) lowX = tempobject[pfox];
			if(tempobject[pfoy] < lowY) lowY = tempobject[pfoy];
			if(tempobject[pfoz] < lowZ) lowZ = tempobject[pfoz];
		}

	}
	// Old version load
	else
	{
		fclose(f);
		f = fopen(openmap,io_read);

		while(fread(f,templine,sizeof(templine),false)) {
			index = 0;
			tempobject[object_id] = INVALID_OBJECT_ID;
			tempobject[medit_modelid] = strval(strtok(templine,index));
			tempobject[pfox] = floatstr(strtok(templine,index));
			tempobject[pfoy] = floatstr(strtok(templine,index));
			tempobject[pfoz] = floatstr(strtok(templine,index));
			tempobject[pfrx] = floatstr(strtok(templine,index));
			tempobject[pfry] = floatstr(strtok(templine,index));
			tempobject[pfrz] = floatstr(strtok(templine,index));

			for(new i = 0; i < MAX_MATERIAL_INDEX; i++) { tempobject[Material_Index][i] = strval(strtok(templine,index)); }

			// Calculate group center
			if(tempobject[pfox] > highX) highX = tempobject[pfox];
			if(tempobject[pfoy] > highY) highY = tempobject[pfoy];
			if(tempobject[pfoz] > highZ) highZ = tempobject[pfoz];
			if(tempobject[pfox] < lowX) lowX = tempobject[pfox];
			if(tempobject[pfoy] < lowY) lowY = tempobject[pfoy];
			if(tempobject[pfoz] < lowZ) lowZ = tempobject[pfoz];

		}
	}

	pfx = (highX + lowX) / 2;
	pfy = (highY + lowY) / 2;
	pfz = (highZ + lowZ) / 2;

	fclose(f);


	return 1;
}
*/
