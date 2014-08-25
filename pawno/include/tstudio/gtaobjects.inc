#include <tstudio\allobjects>

#define         MIN_GTAOBJECT_LABEL_DIST            5.0

static bool:ObjectsShown;
static Text3D:GTAObjectText[SEARCH_DATA_SIZE];
static bool:GTAObjectDeleted[SEARCH_DATA_SIZE];
static bool:GTAObjectSwapped[SEARCH_DATA_SIZE];

ResetGTADeletedObjects()
{
	for(new i = 0; i < SEARCH_DATA_SIZE; i++) GTAObjectDeleted[i] = false;
	return 1;
}


CMD:gtaobjects(playerid, arg[])
{
	if(ObjectsShown)
	{
		for(new i = 0; i < SEARCH_DATA_SIZE; i++) DestroyDynamic3DTextLabel(GTAObjectText[i]);
        ObjectsShown = false;
		SendClientMessage(playerid, STEALTH_GREEN, "Hiding GTA Objects");
	}
	else
	{
		new text[64], Float:colradius;
		
	    for(new i = 0; i < SEARCH_DATA_SIZE; i++)
		{
 			colradius = GetColSphereRadius(SearchData[i][Search_Model]);
 			if(colradius < MIN_GTAOBJECT_LABEL_DIST) colradius = MIN_GTAOBJECT_LABEL_DIST;
		    format(text, sizeof(text), "Index: %i\nName: %s", i, SearchData[i][Search_Model_Name]);
            GTAObjectText[i] = CreateDynamic3DTextLabel(text, 0xFF69B4FF, SearchData[i][SearchX], SearchData[i][SearchY], SearchData[i][SearchZ], colradius*2.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, colradius*2.0);
		}
	    ObjectsShown = true;
	    SendClientMessage(playerid, STEALTH_GREEN, "Showing GTA Objects");
	}

	return 1;
}

CMD:remobject(playerid, arg[])
{
    MapOpenCheck();

	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must provide an index to delete!");
	new line[128], index = strval(arg);

	if(index < 0 || index >= SEARCH_DATA_SIZE)
	{
		format(line, sizeof(line), "Index must be between 0 and %i", SEARCH_DATA_SIZE-1);
	    return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}

	if(GTAObjectDeleted[index] == true) return SendClientMessage(playerid, STEALTH_YELLOW, "That object is already deleted!");

    GTAObjectDeleted[index] = true;
    
	AddRemoveBuilding(SearchData[index][Search_Model], SearchData[index][SearchX], SearchData[index][SearchY], SearchData[index][SearchZ], 0.25, true);
	if(SearchData[index][Search_LODModel] != INVALID_OBJECT_ID) AddRemoveBuilding(SearchData[index][Search_LODModel], SearchData[index][SearchX], SearchData[index][SearchY], SearchData[index][SearchZ], 0.25, true);
	
	SendClientMessage(playerid, STEALTH_YELLOW, "Object has been removed!");
	
	return 1;
}

CMD:swapbuilding(playerid, arg[])
{
    MapOpenCheck();


	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "You must provide an index to swap!");
	new line[128], index = strval(arg);

	if(index < 0 || index >= SEARCH_DATA_SIZE)
	{
		format(line, sizeof(line), "Index must be between 0 and %i", SEARCH_DATA_SIZE-1);
	    return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}

	if(GTAObjectSwapped[index] == true) return SendClientMessage(playerid, STEALTH_YELLOW, "That object is already swapped!");

	if(GTAObjectDeleted[index] == false)
	{
		AddRemoveBuilding(SearchData[index][Search_Model], SearchData[index][SearchX], SearchData[index][SearchY], SearchData[index][SearchZ], 0.25, true);
		if(SearchData[index][Search_LODModel] != INVALID_OBJECT_ID) AddRemoveBuilding(SearchData[index][Search_LODModel], SearchData[index][SearchX], SearchData[index][SearchY], SearchData[index][SearchZ], 0.25, true);
	    GTAObjectDeleted[index] = true;
	}

	// Swap object
	UpdateObject3DText(AddDynamicObject(SearchData[index][Search_Model], SearchData[index][SearchX], SearchData[index][SearchY], SearchData[index][SearchZ], SearchData[index][SearchRX], SearchData[index][SearchRY], SearchData[index][SearchRZ]), true);
    GTAObjectSwapped[index] = true;

	
	SendClientMessage(playerid, STEALTH_YELLOW, "Object has been swapped!");
	return 1;
}
