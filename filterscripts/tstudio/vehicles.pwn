
#define         MAX_EDIT_CARS                   1000
#define         MAX_CAR_OBJECTS         		30
#define         MAX_CAR_COMPONENTS              14

#define         NOMODSHOP			0
#define         TRANSFENDER         1
#define         LOCOLOWCO           2
#define         WHEELARCHANGELS     3


// Edit check makes sure the player is actually has a vehicle selected
#define VehicleCheck(%0); if(CurrVehicle[%0] == -1) { \
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________"); \
	return SendClientMessage(playerid, STEALTH_YELLOW, "You need to select an vehicle to use this command"); }

enum CARINFO
{
	CarID,
	CarModel,
	Text3D:CarText,
	CarColor1,
	CarColor2,
	CarPaintJob,
	CarSiren,
	Float:CarSpawnX,
	Float:CarSpawnY,
	Float:CarSpawnZ,
	Float:CarSpawnFA,
	CarComponents[MAX_CAR_COMPONENTS],
	CarObjectRef[MAX_CAR_OBJECTS],
	Float:COX[MAX_CAR_OBJECTS],
	Float:COY[MAX_CAR_OBJECTS],
	Float:COZ[MAX_CAR_OBJECTS],
	Float:CORX[MAX_CAR_OBJECTS],
	Float:CORY[MAX_CAR_OBJECTS],
	Float:CORZ[MAX_CAR_OBJECTS],
}

new Iterator:Cars<MAX_EDIT_CARS>;
new CarData[MAX_EDIT_CARS][CARINFO];

new CurrVehicle[MAX_PLAYERS] = { -1, ... };
static TempVehicle[MAX_PLAYERS] = { -1, ... };
static bool:IsTempVehicle[MAX_VEHICLES] = { false, ... };

static VehicleNames[212][] = {
	{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},
	{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},
	{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
	{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
	{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},
	{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
	{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},
	{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
	{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
	{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},
	{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},
	{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
	{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},
	{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},
	{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
	{"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},
	{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},
	{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
	{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
	{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
	{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
	{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
	{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
	{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
	{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
	{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},
	{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
	{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},
	{"Utility Trailer"}
};

static CarModShops[212] = {
	1,1,1,0,0,1,0,0,0,1,1,1,2,0,0,1,0,0,1,1,
	1,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,1,1,
	0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,
	0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,
	1,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,1,0,0,0,
	1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,0,
	0,0,0,0,0,0,1,1,0,1,0,0,0,1,2,2,2,0,0,0,
	1,1,1,0,0,1,1,1,0,1,1,1,0,0,0,1,0,0,3,3,
	3,3,3,0,0,3,2,2,0,0,0,0,0,0,0,2,2,0,0,1,
	1,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,
	1,0,1,1,0,0,0,0,0,0,0,0
};

static Float:ModCarPos[MAX_PLAYERS][4];

YCMD:avmodcar(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Modify car components using modshop.");
		return 1;
	}

	new vid = GetPlayerVehicleID(playerid);
	foreach(new i : Cars)
	{
	    if(CarData[i][CarID] == vid)
		{
            switch(CarModShops[GetVehicleModel(vid) - 400])
            {
	            case NOMODSHOP:
	            {
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "This model can not be modded.");
					return 1;
	            }
	            case TRANSFENDER:
	            {
					GetVehiclePos(vid, ModCarPos[playerid][0], ModCarPos[playerid][1], ModCarPos[playerid][2]);
					GetVehicleZAngle(vid, ModCarPos[playerid][3]);
					SetVehiclePos(vid, -1935.8020,247.0903,34.5477);
					EditingMode[playerid] = true;
					SetEditMode(playerid, EDIT_MODE_MODCAR);
	            }
	            case LOCOLOWCO:
	            {
					GetVehiclePos(vid, ModCarPos[playerid][0], ModCarPos[playerid][1], ModCarPos[playerid][2]);
					GetVehicleZAngle(vid, ModCarPos[playerid][3]);
					SetVehiclePos(vid, 2645.0527,-2044.9419,13.4548);
					EditingMode[playerid] = true;
					SetEditMode(playerid, EDIT_MODE_MODCAR);
	            }
	            case WHEELARCHANGELS:
	            {
					GetVehiclePos(vid, ModCarPos[playerid][0], ModCarPos[playerid][1], ModCarPos[playerid][2]);
					GetVehicleZAngle(vid, ModCarPos[playerid][3]);
					SetVehiclePos(vid, -2720.8887,217.4109,4.1550);
					EditingMode[playerid] = true;
					SetEditMode(playerid, EDIT_MODE_MODCAR);
	            }
			}
			ResetPlayerMoney(playerid);
			GivePlayerMoney(playerid, 50000);
			return 1;
		}
	}
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_YELLOW, "You must be in a car created by texture studio to mod a car.");

	return 1;
}

YCMD:avsetspawn(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set vehicle's spawn point to current position.");
		return 1;
	}

	new vid = GetPlayerVehicleID(playerid);
	foreach(new i : Cars)
	{
	    if(CarData[i][CarID] == vid)
		{
            GetVehiclePos(CarData[i][CarID], CarData[i][CarSpawnX], CarData[i][CarSpawnY], CarData[i][CarSpawnZ]);
            GetVehicleZAngle(CarData[i][CarID], CarData[i][CarSpawnFA]);
			sqlite_SaveVehicleData(i);
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "Vehicle spawn has been set (Note vehicle won't respawn here until reloading map!).");
			return 1;
		}
	}
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_YELLOW, "You must be in a car created by texture studio set a spawn position.");

	return 1;
}

YCMD:avdeletecar(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destroy current vehicle.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	VehicleCheck(playerid);
	
	inline DeleteVehicleObjects(pid, dialogid, response, listitem, string:text[])
    {
        #pragma unused listitem, dialogid, pid, text
		if(response) DestroyEditCar(CurrVehicle[playerid], true, true);
		else DestroyEditCar(CurrVehicle[playerid], true);
	    CurrVehicle[playerid] = -1;
    }
    Dialog_ShowCallback(playerid, using inline DeleteVehicleObjects, DIALOG_STYLE_LIST, "Texture Studio", "Delete Vehicles Objects?", "Yes", "No");
	
   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Vehicle has been deleted.");

	return 1;
}


static VehicleList[4096];
SSCANF:vehiclemodel(string[])
{
    if('0' <= string[0] <= '9')
    {
        new ret = strval(string);
        if (400 <= ret <= 611)
        {
            return ret;
        }
    }
	else for(new i; i < sizeof(VehicleNames); i++)
	{
		if(strfind(string, VehicleNames[i], true) != -1)
		{
			return i + 400;
		}
	}
    
    return -1;
}

public OnFilterScriptInit()
{
	for(new i = 0; i < 212; i++) format(VehicleList, sizeof(VehicleList), "%s(%i) %s\n", VehicleList, i+400, VehicleNames[i]);

	#if defined VH_OnFilterScriptInit
		VH_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit VH_OnFilterScriptInit
#if defined VH_OnFilterScriptInit
	forward VH_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
	DeleteAllCars();

	#if defined VH_OnFilterScriptExit
		VH_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit VH_OnFilterScriptExit
#if defined VH_OnFilterScriptExit
	forward VH_OnFilterScriptExit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
    CurrVehicle[playerid] = -1;

	#if defined VH_OnPlayerDisconnect
		VH_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect VH_OnPlayerDisconnect
#if defined VH_OnPlayerDisconnect
	forward VH_OnPlayerDisconnect(playerid, reason);
#endif

public OnEnterExitModShop(playerid,enterexit,interiorid)
{
    if(enterexit == 1) EditingMode[playerid] = true;
	if(enterexit == 0)
	{
		new vid = GetPlayerVehicleID(playerid);
		foreach(new i : Cars)
		{
		    if(CarData[i][CarID] == vid)
			{
				for(new j = 0; j < MAX_CAR_COMPONENTS; j++)
				{
					CarData[i][CarComponents][j] = GetVehicleComponentInSlot(vid, j);
				}
                sqlite_SaveVehicleData(i);
                
                if(GetEditMode(playerid) == EDIT_MODE_MODCAR)
                {
					SetVehiclePos(vid, ModCarPos[playerid][0], ModCarPos[playerid][1], ModCarPos[playerid][2]);
					SetVehicleZAngle(vid, ModCarPos[playerid][3]);
					SetEditMode(playerid, EDIT_MODE_NONE);
                }
                EditingMode[playerid] = false;
				return 1;
			}
		}
	}
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	foreach(new i : Cars)
	{
	    if(CarData[i][CarID] == vehicleid)
		{
            CarData[i][CarColor1] = color1;
			CarData[i][CarColor2] = color2;
			return 1;
		}
	}
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	foreach(new i : Cars)
	{
	    if(CarData[i][CarID] == vehicleid)
		{
            CarData[i][CarPaintJob] = paintjobid;
			return 1;
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if(IsTempVehicle[vehicleid])
	{
		foreach(new i: Player)
		{
			if(vehicleid == TempVehicle[i])
			{
				TempVehicle[i] = -1;
				break;
			}
		}
		IsTempVehicle[vehicleid] = false;
		
		DestroyVehicle(vehicleid);
	}

	foreach(new i : Cars)
	{
	    if(CarData[i][CarID] == vehicleid)
		{
		 	ChangeVehicleColor(CarData[i][CarID], CarData[i][CarColor1], CarData[i][CarColor2]);
		 	ChangeVehiclePaintjob(CarData[i][CarID], CarData[i][CarPaintJob]);
		 	for(new j = 0; j < MAX_CAR_COMPONENTS; j++)
		 	{
		 	    if(CarData[i][CarComponents][j] > 0) AddVehicleComponent(CarData[i][CarID], CarData[i][CarComponents][j]);
		 	}
			return 1;
		}
	}

	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER && TempVehicle[playerid] != -1)
	{
		IsTempVehicle[TempVehicle[playerid]] = false;
		DestroyVehicle(TempVehicle[playerid]);
		TempVehicle[playerid] = -1;
	}
	return 1;
}

YCMD:tcar(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Gives you a temporary vehicle.");
		return 1;
	}
	
	new model;
	sscanf(arg, "K<vehiclemodel>(0)", model);
	
    if(model)
    {
		if(model != -1)
		{
			new Float:X, Float:Y, Float:Z, Float:R;
			GetPlayerPos(playerid, X, Y, Z);
			GetPlayerFacingAngle(playerid, R);
			TempVehicle[playerid] = CreateVehicle(model, X + 5.0 * floatcos(R + 180.0, degrees), Y + 5.0 * floatsin(R + 180.0, degrees), Z, R, 0, 0, 1);
			IsTempVehicle[TempVehicle[playerid]] = true;
			PutPlayerInVehicle(playerid, TempVehicle[playerid], 0);
			return 1;
		}
		else
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "Invalid vehicle name/ID.");
		}
	}
	else
	{
		inline SelectModel(pid, dialogid, response, listitem, string:text[])
		{
			#pragma unused listitem, dialogid, pid, text
			if(response)
			{
				new Float:X, Float:Y, Float:Z, Float:R;
				GetPlayerPos(playerid, X, Y, Z);
				GetPlayerFacingAngle(playerid, R);
				TempVehicle[playerid] = CreateVehicle(listitem+400, X, Y, Z, R, 0, 0, 1);
				IsTempVehicle[TempVehicle[playerid]] = true;
				PutPlayerInVehicle(playerid, TempVehicle[playerid], 0);
				return 1;
			}
		}
		Dialog_ShowCallback(playerid, using inline SelectModel, DIALOG_STYLE_LIST, "Texture Studio", VehicleList, "Ok", "Cancel");
	}
	
	return 1;
}

YCMD:avselectcar(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Adds a vehicle to the loaded map.");
		return 1;
	}

    inline SelectID(pid, dialogid, response, listitem, string:text[])
    {
        #pragma unused listitem, dialogid, pid, text
		if(response)
		{
			new id = strval(text);
			foreach(new i : Cars)
			{
			    if(CarData[i][CarID] == id)
			    {
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "This vehicle is already in Texture Studio!");
					return 1;
			    }
			}
			new index = Iter_Free(Cars);
			if(index > -1)
			{
				Iter_Add(Cars, id);
			    GetVehiclePos(id, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ]);
			    GetVehicleZAngle(id, CarData[index][CarSpawnFA]);
	            CarData[index][CarID] = id;
			    CarData[index][CarModel] = GetVehicleModel(id);

				new line[32];
				format(line, sizeof(line), "Car Index: %i", index);
				CarData[index][CarText] = CreateDynamic3DTextLabel(line, -1, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ], 20.0, INVALID_PLAYER_ID, CarData[index][CarID]);
		        Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, CarData[index][CarText], E_STREAMER_ATTACH_OFFSET_Z, 2.0);

				for(new i = 0; i < MAX_CAR_OBJECTS; i++) CarData[index][CarObjectRef][i] = -1;
				CarData[index][CarPaintJob] = 3;

				sqlite_InsertCar(index);

				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Vehicle can now be edited!");
			}
		}
	}
    Dialog_ShowCallback(playerid, using inline SelectID, DIALOG_STYLE_INPUT, "Texture Studio", "Input vehicle ID to select", "Ok", "Cancel");
	return 1;
}


YCMD:avnewcar(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Add a vehicle to map.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	new model;
	sscanf(arg, "K<vehiclemodel>(0)", model);
	
    if(model)
    {
        new index = Iter_Free(Cars);
        if(index > -1)
        {
            if(model != -1)
            {
                GetPlayerPos(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ]);
                GetXYInFrontOfPlayer(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], 2.0);
                GetPlayerFacingAngle(playerid, CarData[index][CarSpawnFA]);
				
                CurrVehicle[playerid] = AddNewCar(model, index, true);
				
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Vehicle can now be edited!");
				
                return 1;
            }
            else
                SendClientMessage(playerid, STEALTH_YELLOW, "Invalid vehicle name or ID");
        }
        else
            SendClientMessage(playerid, STEALTH_YELLOW, "Too many cars");
    }
    else 
    {
        inline SelectModel(pid, dialogid, response, listitem, string:text[])
        {
            #pragma unused listitem, dialogid, pid, text
            if(response)
            {
                new index = Iter_Free(Cars);
                if(index > -1)
                {
                    GetPlayerPos(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ]);
                    GetXYInFrontOfPlayer(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], 2.0);
                    GetPlayerFacingAngle(playerid, CarData[index][CarSpawnFA]);
                    CurrVehicle[playerid] = AddNewCar(listitem+400, index, true);
                    return 1;
                }
                SendClientMessage(playerid, STEALTH_YELLOW, "Too many cars");
            }
        }
        Dialog_ShowCallback(playerid, using inline SelectModel, DIALOG_STYLE_LIST, "Texture Studio", VehicleList, "Ok", "Cancel");
    }
    
	return 1;
}

static AddNewCar(modelid, index = -1, bool:sqlsave = true, bool:clearref = true)
{
	if(index == -1) index = Iter_Free(Cars);
	
	if(index > -1)
	{
	    Iter_Add(Cars, index);
	    CarData[index][CarID] = CreateVehicle(modelid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ], CarData[index][CarSpawnFA], CarData[index][CarColor1], CarData[index][CarColor2], -1, CarData[index][CarSiren]);
		CarData[index][CarModel] = modelid;

		new line[32];
		format(line, sizeof(line), "Car Index: %i", index);
		CarData[index][CarText] = CreateDynamic3DTextLabel(line, -1, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ], 20.0, INVALID_PLAYER_ID, CarData[index][CarID]);
        Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, CarData[index][CarText], E_STREAMER_ATTACH_OFFSET_Z, 2.0);

        ChangeVehiclePaintjob(CarData[index][CarID], CarData[index][CarPaintJob]);
        for(new i; i < MAX_CAR_COMPONENTS; i++)
            if(CarData[index][CarComponents][i])
                AddVehicleComponent(CarData[index][CarID], CarData[index][CarComponents][i]);
        
		if(clearref)
		{
			for(new i = 0; i < MAX_CAR_OBJECTS; i++) CarData[index][CarObjectRef][i] = -1;
			CarData[index][CarPaintJob] = 3;
		}
		if(sqlsave) sqlite_InsertCar(index);
		return index;
	}
	return -1;
}

Update3DAttachCarPos(objindex, carindex)
{
	for(new i = 0; i < MAX_CAR_OBJECTS; i++)
	{
	    if(CarData[carindex][CarObjectRef][i] == objindex)
	    {
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, ObjectData[objindex][oTextID], E_STREAMER_ATTACH_OFFSET_X, CarData[carindex][COX][i]);
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, ObjectData[objindex][oTextID], E_STREAMER_ATTACH_OFFSET_Y, CarData[carindex][COY][i]);
            Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, ObjectData[objindex][oTextID], E_STREAMER_ATTACH_OFFSET_Z, CarData[carindex][COZ][i]);
	        return 1;
	    }
	}
	return 0;
}

static NewVehicleString[512];
sqlite_CreateVehicle()
{
	if(!NewVehicleString[0])
	{
		strimplode(" ",
			NewVehicleString,
			sizeof(NewVehicleString),
			"CREATE TABLE IF NOT EXISTS `Vehicles`",
			"(IndexID INTEGER,",
			"CarModel INTEGER,",
			"CarColor1 INTEGER,",
			"CarColor2 INTEGER,",
			"CarPaintJob INTEGER,",
			"CarSpawnX REAL,",
			"CarSpawnY REAL,",
			"CarSpawnZ REAL,",
			"CarSpawnFA REAL,",
			"CarComponents TEXT,",
			"CarObjectRef TEXT,",
			"COX TEXT,",
			"COY TEXT,",
			"COZ TEXT,",
			"CORX TEXT,",
			"CORY TEXT,",
			"CORZ TEXT,",
            "CarSiren INTEGER);"
		);
	}
	db_exec(EditMap, NewVehicleString);
}


// Insert stmt statement
new DBStatement:insertcarstmt;
new InsertCarString[512];

// Sqlite query functions
sqlite_InsertCar(index)
{
	// Inserts a new index
	if(!InsertCarString[0])
	{
		// Prepare query
		strimplode(" ",
			InsertCarString,
			sizeof(InsertCarString),
			"INSERT INTO `Vehicles`",
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
	}

	insertcarstmt = db_prepare(EditMap, InsertCarString);

	// Bind our results
    stmt_bind_value(insertcarstmt, 0, DB::TYPE_INT, index);
    stmt_bind_value(insertcarstmt, 1, DB::TYPE_INT, CarData[index][CarModel]);
    stmt_bind_value(insertcarstmt, 2, DB::TYPE_INT, CarData[index][CarColor1]);
    stmt_bind_value(insertcarstmt, 3, DB::TYPE_INT, CarData[index][CarColor2]);
    stmt_bind_value(insertcarstmt, 4, DB::TYPE_INT, CarData[index][CarPaintJob]);
    stmt_bind_value(insertcarstmt, 5, DB::TYPE_FLOAT, CarData[index][CarSpawnX]);
    stmt_bind_value(insertcarstmt, 6, DB::TYPE_FLOAT, CarData[index][CarSpawnY]);
    stmt_bind_value(insertcarstmt, 7, DB::TYPE_FLOAT, CarData[index][CarSpawnZ]);
    stmt_bind_value(insertcarstmt, 8, DB::TYPE_FLOAT, CarData[index][CarSpawnFA]);
    stmt_bind_value(insertcarstmt, 9, DB::TYPE_ARRAY, CarData[index][CarComponents], MAX_CAR_COMPONENTS);
    stmt_bind_value(insertcarstmt, 10, DB::TYPE_ARRAY, CarData[index][CarObjectRef], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 11, DB::TYPE_ARRAY, CarData[index][COX], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 12, DB::TYPE_ARRAY, CarData[index][COY], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 13, DB::TYPE_ARRAY, CarData[index][COZ], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 14, DB::TYPE_ARRAY, CarData[index][CORX], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 15, DB::TYPE_ARRAY, CarData[index][CORY], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 16, DB::TYPE_ARRAY, CarData[index][CORZ], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 17, DB::TYPE_INT, CarData[index][CarSiren]);

    stmt_execute(insertcarstmt);
	stmt_close(insertcarstmt);
}

new DBStatement:savevposstmt;
new VehiclePosUpdateString[4096];

// Saves all other data
sqlite_SaveVehicleData(index)
{
	// Inserts a new index
	if(!VehiclePosUpdateString[0])
	{
		// Prepare query
		strimplode(" ",
			VehiclePosUpdateString,
			sizeof(VehiclePosUpdateString),
			"UPDATE `Vehicles` SET",
			"`CarModel` = ?,",
			"`CarColor1` = ?,",
			"`CarColor2` = ?,",
			"`CarPaintJob` = ?,",
			"`CarSpawnX` = ?,",
			"`CarSpawnY` = ?,",
			"`CarSpawnZ` = ?,",
			"`CarSpawnFA` = ?,",
			"`CarComponents` = ?,",
			"`CarSiren` = ?",
			"WHERE `IndexID` = ?"
		);
	}

    savevposstmt = db_prepare(EditMap, VehiclePosUpdateString);

	// Bind values
	stmt_bind_value(savevposstmt, 0, DB::TYPE_INT, CarData[index][CarModel]);
	stmt_bind_value(savevposstmt, 1, DB::TYPE_INT, CarData[index][CarColor1]);
	stmt_bind_value(savevposstmt, 2, DB::TYPE_INT, CarData[index][CarColor2]);
	stmt_bind_value(savevposstmt, 3, DB::TYPE_INT, CarData[index][CarPaintJob]);
	stmt_bind_value(savevposstmt, 4, DB::TYPE_FLOAT, CarData[index][CarSpawnX]);
	stmt_bind_value(savevposstmt, 5, DB::TYPE_FLOAT, CarData[index][CarSpawnY]);
	stmt_bind_value(savevposstmt, 6, DB::TYPE_FLOAT, CarData[index][CarSpawnZ]);
	stmt_bind_value(savevposstmt, 7, DB::TYPE_FLOAT, CarData[index][CarSpawnFA]);
	stmt_bind_value(savevposstmt, 8, DB::TYPE_ARRAY, CarData[index][CarComponents], MAX_CAR_COMPONENTS);
	stmt_bind_value(savevposstmt, 9, DB::TYPE_INT, CarData[index][CarSiren]);
	stmt_bind_value(savevposstmt, 10, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(savevposstmt);
	stmt_close(savevposstmt);
	return 1;
}

// Save vehicle data
new DBStatement:savevdatastmt;
new VehicleDataUpdateString[4096];

// Saves a specific texture index to DB
sqlite_SaveVehicleObjectData(index)
{
	// Inserts a new index
	if(!VehicleDataUpdateString[0])
	{
		// Prepare query
		strimplode(" ",
			VehicleDataUpdateString,
			sizeof(VehicleDataUpdateString),
			"UPDATE `Vehicles` SET",
			"`CarObjectRef` = ?,",
			"`COX` = ?,",
			"`COY` = ?,",
			"`COZ` = ?,",
			"`CORX` = ?,",
			"`CORY` = ?,",
			"`CORZ` = ?",
			"WHERE `IndexID` = ?"
		);
	}

    savevdatastmt = db_prepare(EditMap, VehicleDataUpdateString);

	// Bind values
	stmt_bind_value(savevdatastmt, 0, DB::TYPE_ARRAY, CarData[index][CarObjectRef], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 1, DB::TYPE_ARRAY, CarData[index][COX], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 2, DB::TYPE_ARRAY, CarData[index][COY], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 3, DB::TYPE_ARRAY, CarData[index][COZ], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 4, DB::TYPE_ARRAY, CarData[index][CORX], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 5, DB::TYPE_ARRAY, CarData[index][CORY], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 6, DB::TYPE_ARRAY, CarData[index][CORZ], MAX_CAR_OBJECTS);
	stmt_bind_value(savevdatastmt, 7, DB::TYPE_INT, index);

	// Execute stmt
    stmt_execute(savevdatastmt);
	stmt_close(savevdatastmt);

	return 1;
}

// Load query stmt
static DBStatement:loadcarstmt;

// Load all cars
sqlite_LoadCars()
{
	new tmpcar[CARINFO];
	new currindex;

	loadcarstmt = db_prepare(EditMap, "SELECT * FROM `Vehicles`");
	
	// Bind our results
    stmt_bind_result_field(loadcarstmt, 0, DB::TYPE_INT, currindex);
    stmt_bind_result_field(loadcarstmt, 1, DB::TYPE_INT, tmpcar[CarModel]);
    stmt_bind_result_field(loadcarstmt, 2, DB::TYPE_INT, tmpcar[CarColor1]);
    stmt_bind_result_field(loadcarstmt, 3, DB::TYPE_INT, tmpcar[CarColor2]);
    stmt_bind_result_field(loadcarstmt, 4, DB::TYPE_INT, tmpcar[CarPaintJob]);
    stmt_bind_result_field(loadcarstmt, 5, DB::TYPE_FLOAT, tmpcar[CarSpawnX]);
    stmt_bind_result_field(loadcarstmt, 6, DB::TYPE_FLOAT, tmpcar[CarSpawnY]);
    stmt_bind_result_field(loadcarstmt, 7, DB::TYPE_FLOAT, tmpcar[CarSpawnZ]);
    stmt_bind_result_field(loadcarstmt, 8, DB::TYPE_FLOAT, tmpcar[CarSpawnFA]);
    stmt_bind_result_field(loadcarstmt, 9, DB::TYPE_ARRAY, tmpcar[CarComponents], MAX_CAR_COMPONENTS);
    stmt_bind_result_field(loadcarstmt, 10, DB::TYPE_ARRAY, tmpcar[CarObjectRef], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 11, DB::TYPE_ARRAY, tmpcar[COX], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 12, DB::TYPE_ARRAY, tmpcar[COY], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 13, DB::TYPE_ARRAY, tmpcar[COZ], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 14, DB::TYPE_ARRAY, tmpcar[CORX], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 15, DB::TYPE_ARRAY, tmpcar[CORY], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 16, DB::TYPE_ARRAY, tmpcar[CORZ], MAX_CAR_OBJECTS);
    stmt_bind_result_field(loadcarstmt, 17, DB::TYPE_INT, tmpcar[CarSiren]);

	// Execute query
    if(stmt_execute(loadcarstmt))
    {
        while(stmt_fetch_row(loadcarstmt))
        {
            CarData[currindex][CarModel] = tmpcar[CarModel];
            CarData[currindex][CarColor1] = tmpcar[CarColor1];
            CarData[currindex][CarColor2] = tmpcar[CarColor2];
            CarData[currindex][CarPaintJob] = tmpcar[CarPaintJob];
            CarData[currindex][CarSpawnX] = tmpcar[CarSpawnX];
            CarData[currindex][CarSpawnY] = tmpcar[CarSpawnY];
            CarData[currindex][CarSpawnZ] = tmpcar[CarSpawnZ];
            CarData[currindex][CarSpawnFA] = tmpcar[CarSpawnFA];
            CarData[currindex][CarSiren] = tmpcar[CarSiren];

			for(new i = 0; i < MAX_CAR_COMPONENTS; i++) CarData[currindex][CarComponents][i] = tmpcar[CarComponents][i];
			for(new i = 0; i < MAX_CAR_OBJECTS; i++)
			{
				CarData[currindex][CarObjectRef][i] = tmpcar[CarObjectRef][i];
				CarData[currindex][COX][i] = tmpcar[COX][i];
				CarData[currindex][COY][i] = tmpcar[COY][i];
				CarData[currindex][COZ][i] = tmpcar[COZ][i];
				CarData[currindex][CORX][i] = tmpcar[CORX][i];
				CarData[currindex][CORY][i] = tmpcar[CORY][i];
				CarData[currindex][CORZ][i] = tmpcar[CORZ][i];
			}
			
		 	AddNewCar(CarData[currindex][CarModel], currindex, false, false);
		 	ChangeVehicleColor(CarData[currindex][CarID], CarData[currindex][CarColor1], CarData[currindex][CarColor2]);
		 	ChangeVehiclePaintjob(CarData[currindex][CarID], CarData[currindex][CarPaintJob]);
		 	for(new i = 0; i < MAX_CAR_COMPONENTS; i++)
		 	{
		 	    if(CarData[currindex][CarComponents][i] > 0) AddVehicleComponent(CarData[currindex][CarID], CarData[currindex][CarComponents][i]);
		 	}
		 	
		 	for(new i = 0; i < MAX_CAR_OBJECTS; i++)
		 	{
		 	    if(tmpcar[CarObjectRef][i] > -1)
		 	    {
	                AttachDynamicObjectToVehicle(ObjectData[CarData[currindex][CarObjectRef][i]][oID], CarData[currindex][CarID],
						CarData[currindex][COX][i], CarData[currindex][COY][i], CarData[currindex][COZ][i], CarData[currindex][CORX][i], CarData[currindex][CORY][i], CarData[currindex][CORZ][i]);
					ObjectData[CarData[currindex][CarObjectRef][i]][oAttachedVehicle] = currindex;
	                UpdateObject3DText(CarData[currindex][CarObjectRef][i], false);
		 	    }
		 	}
	 	}
	}
	stmt_close(loadcarstmt);
}

ClearVehicles()
{
	foreach(new i : Player) CurrVehicle[i] = -1;
    DeleteAllCars();
    return 1;
}


DeleteAllCars()
{
	foreach(new i : Cars)
	{
		i = DestroyEditCar(i, false);
	}
	return 1;
}

DestroyEditCar(index, bool:sqldelete=true, deleteobjects=false)
{
    DestroyVehicle(CarData[index][CarID]);
    CarData[index][CarModel] = -1;
    CarData[index][CarColor1] = -1;
    CarData[index][CarColor2] = -1;
    CarData[index][CarPaintJob] = 0;
    CarData[index][CarSiren] = 0;
    CarData[index][CarSpawnX] = 0.0;
    CarData[index][CarSpawnY] = 0.0;
    CarData[index][CarSpawnZ] = 0.0;
    CarData[index][CarSpawnFA] = 0.0;
    
    DestroyDynamic3DTextLabel(CarData[index][CarText]);
    
    for(new i = 0; i < MAX_CAR_COMPONENTS; i++) CarData[index][CarComponents][i] = 0;
	for(new i = 0; i < MAX_CAR_OBJECTS; i++)
	{
		if(CarData[index][CarObjectRef][i] > -1)
		{
			new oindex = CarData[index][CarObjectRef][i];

			if(deleteobjects) DeleteDynamicObject(oindex);
			else
			{
				// Destroy the object
			    DestroyDynamicObject(ObjectData[oindex][oID]);

				// Re-create object
				ObjectData[index][oID] = CreateDynamicObject(ObjectData[oindex][oModel], ObjectData[oindex][oX], ObjectData[oindex][oY], ObjectData[oindex][oZ], ObjectData[oindex][oRX], ObjectData[oindex][oRY], ObjectData[oindex][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
				Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[oindex][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

				// We need to update textures and materials
				UpdateMaterial(oindex);

				// Update the object text
				UpdateObjectText(oindex);

				// Update 3d Text
				UpdateObject3DText(oindex, false);
			}
		}
	    CarData[index][CarObjectRef][i] = -1;
	    CarData[index][COX][i] = 0.0;
	    CarData[index][COY][i] = 0.0;
	    CarData[index][COZ][i] = 0.0;
	    CarData[index][CORX][i] = 0.0;
	    CarData[index][CORY][i] = 0.0;
	    CarData[index][CORZ][i] = 0.0;
	}
	if(sqldelete)
	{
	    new q[128];
	    format(q, sizeof(q), "DELETE FROM `Vehicles` WHERE `IndexID` = %i", index);
	    db_query(EditMap, q);
	}
	
	new next;
	Iter_SafeRemove(Cars, index, next);
	
	return next;
}

YCMD:avcarcolor(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set current vehicle's colors.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	VehicleCheck(playerid);

	inline Response(pid, dialogid, response, listitem, string:text[])
	{
		#pragma unused listitem, dialogid, pid, response, text
		if(response)
		{
			inline ChooseColor(cpid, cdialogid, cresponse, clistitem, string:ctext[])
			{
				#pragma unused clistitem, cdialogid, cpid, cresponse, ctext
				if(cresponse)
				{
					if(listitem == 0) CarData[CurrVehicle[playerid]][CarColor1] = clistitem;
					else if(listitem == 1) CarData[CurrVehicle[playerid]][CarColor2] = clistitem;
				    ChangeVehicleColor(CarData[CurrVehicle[playerid]][CarID], CarData[CurrVehicle[playerid]][CarColor1], CarData[CurrVehicle[playerid]][CarColor2]);
					sqlite_SaveVehicleData(CurrVehicle[playerid]);
				}
				Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Select car color", "Car Color 1\nCar Color 2", "Ok", "Cancel");
			}
		    Dialog_ShowCallback(playerid, using inline ChooseColor, DIALOG_STYLE_LIST, "Car Color List", VehicleColorList, "Ok", "Cancel");
			return 1;
		}
	}
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Select car color", "Car Color 1\nCar Color 2", "Ok", "Cancel");
	return 1;
}

YCMD:avpaint(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Set current vehicle's paintjob ID.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	VehicleCheck(playerid);

	inline Response(pid, dialogid, response, listitem, string:text[])
	{
		#pragma unused listitem, dialogid, pid, response, text
		if(response)
		{
			CarData[CurrVehicle[playerid]][CarPaintJob] = listitem;
		    ChangeVehiclePaintjob(CarData[CurrVehicle[playerid]][CarID], CarData[CurrVehicle[playerid]][CarPaintJob]);
			sqlite_SaveVehicleData(CurrVehicle[playerid]);
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Select Paint Job", "Paint Job 1\nPaint Job 2\nPaint Job 3\nNone", "Ok", "Cancel");
		}
	}
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Select Paint Job", "Paint Job 1\nPaint Job 2\nPaint Job 3\nNone", "Ok", "Cancel");
	return 1;
}

YCMD:avsiren(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Toggle current vehicle's siren.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	VehicleCheck(playerid);

	CarData[CurrVehicle[playerid]][CarSiren] = CarData[CurrVehicle[playerid]][CarSiren] ? 0 : 1;
    
    // TODO: Destroy and recreate vehicle to apply the siren
    
    sqlite_SaveVehicleData(CurrVehicle[playerid]);
    
    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, sprintf("Toggled vehicle's siren %s{33DD11}",
        (CarData[CurrVehicle[playerid]][CarSiren] ? ("{00AA00}On") : ("{AA0000}Off"))));
    return 1;
}

YCMD:avrespawn(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Respawn current vehicle.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	VehicleCheck(playerid);

	SetVehicleToRespawn(CarData[CurrVehicle[playerid]][CarID]);
    return 1;
}

YCMD:avattach(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Attach current object to current vehicle.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);
	
	EditCheck(playerid);
	
	VehicleCheck(playerid);
	
 	inline CloneVA(cpid, cdialogid, cresponse, clistitem, string:ctext[])
	{
    	#pragma unused clistitem, cdialogid, cpid, ctext
		new bool:clone;
 		if(cresponse) clone = true;
        for(new i = 0; i < MAX_CAR_OBJECTS; i++)
        {
            if(CarData[CurrVehicle[playerid]][CarObjectRef][i] == -1)
            {
            	if(clone) SetCurrObject(playerid, CloneObject(CurrObject[playerid]));
				else
				{
					if(IsObjectAttachedToVehicle(CurrObject[playerid]))
					{
						SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
						SendClientMessage(playerid, STEALTH_YELLOW, "That object is already attached to a vehicle.");
					}
				}

                AttachDynamicObjectToVehicle(ObjectData[CurrObject[playerid]][oID], CarData[CurrVehicle[playerid]][CarID], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
                CarData[CurrVehicle[playerid]][CarObjectRef][i] = CurrObject[playerid];
                ObjectData[CurrObject[playerid]][oAttachedVehicle] = CurrVehicle[playerid];
                
                CarData[CurrVehicle[playerid]][COX][i] = 0.0;
                CarData[CurrVehicle[playerid]][COY][i] = 0.0;
                CarData[CurrVehicle[playerid]][COZ][i] = 0.0;
                CarData[CurrVehicle[playerid]][CORX][i] = 0.0;
                CarData[CurrVehicle[playerid]][CORY][i] = 0.0;
                CarData[CurrVehicle[playerid]][CORZ][i] = 0.0;

                sqlite_SaveVehicleObjectData(CurrVehicle[playerid]);
                
                UpdateObject3DText(CurrObject[playerid], false);

				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Attached object to vehicle.");

				return 1;
			}
        }
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This vehicle has too many objects.");
   	}
	Dialog_ShowCallback(playerid, using inline CloneVA, DIALOG_STYLE_MSGBOX, "Texture Studio", "Would you like to clone this object\nbefore attaching to vehicle?", "Yes", "No");

	return 1;
}

YCMD:avmirror(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Mirror an attached object on the current vehicle.");
		return 1;
	}

	MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] < 0)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to any vehicles.");
	}
	
	inline Mirror(mxpid, mxdialogid, mxresponse, mxlistitem, string:mxtext[])
	{
		#pragma unused mxpid, mxdialogid, mxtext
		if(!mxresponse)
			return 1;
	
		new bool:mx, bool:my, bool:mz;
		switch(mxlistitem)
		{
			case 0: mx = true;
			case 1: my = true;
			case 2: mz = true;
		}
		
		for(new i = 0; i < MAX_CAR_OBJECTS; i++)
		{
			if(CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CarObjectRef][i] == -1)
			{
				new cloneindex = CurrObject[playerid];
				SetCurrObject(playerid, CloneObject(CurrObject[playerid]));
				new refindex = GetCarObjectRefIndex(ObjectData[cloneindex][oAttachedVehicle], cloneindex);
				
				if(mx) {
					CarData[ObjectData[cloneindex][oAttachedVehicle]][COX][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][COX][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORX][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][CORX][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORY][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][CORY][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORZ][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][CORZ][refindex];
				}
				else CarData[ObjectData[cloneindex][oAttachedVehicle]][COX][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][COX][refindex];

				if(my) {
					CarData[ObjectData[cloneindex][oAttachedVehicle]][COY][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][COY][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORX][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][CORX][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORY][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][CORY][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORZ][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][CORZ][refindex];
				}
				else CarData[ObjectData[cloneindex][oAttachedVehicle]][COY][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][COY][refindex];

				if(mz) {
					CarData[ObjectData[cloneindex][oAttachedVehicle]][COZ][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][COZ][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORX][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][CORX][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORY][i] = -CarData[ObjectData[cloneindex][oAttachedVehicle]][CORY][refindex];
					CarData[ObjectData[cloneindex][oAttachedVehicle]][CORZ][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][CORZ][refindex];
				}
				else CarData[ObjectData[cloneindex][oAttachedVehicle]][COZ][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][COZ][refindex];

				AttachDynamicObjectToVehicle(ObjectData[CurrObject[playerid]][oID], CarData[ObjectData[cloneindex][oAttachedVehicle]][CarID],
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0
				);

				CarData[ObjectData[cloneindex][oAttachedVehicle]][CarObjectRef][i] = CurrObject[playerid];
				ObjectData[CurrObject[playerid]][oAttachedVehicle] = ObjectData[cloneindex][oAttachedVehicle];

				UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], i, VEHICLE_ATTACH_UPDATE);

				sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_GREEN, "Mirror attached object to vehicle.");
				return 1;
			}
		}
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Too many attached objects.");
	}
	Dialog_ShowCallback(playerid, using inline Mirror, DIALOG_STYLE_LIST, "Texture Studio - Select Mirror Axis", "X\nY\nZ", "Select", "");
	return 1;
}

YCMD:avclone(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Clone an attached object on the current vehicle.");
		return 1;
	}

	MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] < 0)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to any vehicles.");
	}
	
	for(new i = 0; i < MAX_CAR_OBJECTS; i++)
	{
		if(CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CarObjectRef][i] == -1)
		{
			new cloneindex = CurrObject[playerid];
			SetCurrObject(playerid, CloneObject(CurrObject[playerid]));
			new refindex = GetCarObjectRefIndex(ObjectData[cloneindex][oAttachedVehicle], cloneindex);
			
			CarData[ObjectData[cloneindex][oAttachedVehicle]][COX][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][COX][refindex];
			CarData[ObjectData[cloneindex][oAttachedVehicle]][COY][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][COY][refindex];
			CarData[ObjectData[cloneindex][oAttachedVehicle]][COZ][i] = CarData[ObjectData[cloneindex][oAttachedVehicle]][COZ][refindex];

			AttachDynamicObjectToVehicle(ObjectData[CurrObject[playerid]][oID], CarData[ObjectData[cloneindex][oAttachedVehicle]][CarID],
				0.0, 0.0, 0.0, 0.0, 0.0, 0.0
			);

			CarData[ObjectData[cloneindex][oAttachedVehicle]][CarObjectRef][i] = CurrObject[playerid];
			ObjectData[CurrObject[playerid]][oAttachedVehicle] = ObjectData[cloneindex][oAttachedVehicle];

			UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], i, VEHICLE_ATTACH_UPDATE);

			sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_GREEN, "Cloned object attached object to vehicle.");
			return 1;
		}
	}
	
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_YELLOW, "Too many attached objects.");
	return 1;
}

YCMD:avdetach(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Detach the current object from a vehicle.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);
	
	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new index = CurrObject[playerid];
		if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedObjectRef(ObjectData[index][oAttachedVehicle], index);
		
	    ObjectData[CurrObject[playerid]][oAttachedVehicle] = -1;
	    
		// Destroy the object
	    DestroyDynamicObject(ObjectData[index][oID]);

		// Re-create object
		ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

		// We need to update textures and materials
		UpdateMaterial(index);

		// Update the object text
		UpdateObjectText(index);
		
		// Update 3d Text
		UpdateObject3DText(index, false);
	
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Detached object from vehicle.");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to any vehicles.");
	}
	return 1;


}

YCMD:avsel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Select a vehicle by index.");
		return 1;
	}

    MapOpenCheck();
    new index = strval(arg);
    if(Iter_Contains(Cars, index))
	{
		CurrVehicle[playerid] = index;
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		new line[128];
		format(line, sizeof(line), "Select vehicle index: %i", index);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "That vehicle does not exist.");
	}


	return 1;
}

YCMD:avclonecar(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Clone current vehicle with all properties and objects.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);
	VehicleCheck(playerid);
	
	new index = Iter_Free(Cars);
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(index > -1)
	{
		// Create clone car
		new CloneCar = CurrVehicle[playerid];
		GetPlayerPos(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ]);
		GetXYInFrontOfPlayer(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnY], 2.0);
		GetPlayerFacingAngle(playerid, CarData[index][CarSpawnFA]);
        
        CarData[index][CarColor1]     = CarData[CloneCar][CarColor1];
        CarData[index][CarColor2]     = CarData[CloneCar][CarColor2];
        CarData[index][CarPaintJob]   = CarData[CloneCar][CarPaintJob];
        CarData[index][CarSiren]      = CarData[CloneCar][CarSiren];
        CarData[index][CarComponents] = CarData[CloneCar][CarComponents];
        
		CurrVehicle[playerid] = AddNewCar(CarData[CloneCar][CarModel], index, true);

		// Clone and attach objects
		for(new i = 0; i < MAX_CAR_OBJECTS; i++)
		{
		    if(CarData[CloneCar][CarObjectRef][i] == -1) continue;

		    // Clone and attach
		    new CloneIndex = CloneObject(CarData[CloneCar][CarObjectRef][i]);

            AttachDynamicObjectToVehicle(ObjectData[CloneIndex][oID], CarData[CurrVehicle[playerid]][CarID],
				CarData[CloneCar][COX][i], CarData[CloneCar][COY][i], CarData[CloneCar][COZ][i], CarData[CloneCar][CORX][i], CarData[CloneCar][CORY][i], CarData[CloneCar][CORZ][i]);
            CarData[CurrVehicle[playerid]][CarObjectRef][i] = CloneIndex;
            ObjectData[CloneIndex][oAttachedVehicle] = CurrVehicle[playerid];
            
            CarData[CurrVehicle[playerid]][COX][i] = CarData[CloneCar][COX][i];
            CarData[CurrVehicle[playerid]][COY][i] = CarData[CloneCar][COY][i];
            CarData[CurrVehicle[playerid]][COZ][i] = CarData[CloneCar][COZ][i];
            CarData[CurrVehicle[playerid]][CORX][i] = CarData[CloneCar][CORX][i];
            CarData[CurrVehicle[playerid]][CORY][i] = CarData[CloneCar][CORY][i];
            CarData[CurrVehicle[playerid]][CORZ][i] = CarData[CloneCar][CORZ][i];

            sqlite_SaveVehicleObjectData(CurrVehicle[playerid]);

            UpdateObject3DText(CloneIndex, false);
		}
        SendClientMessage(playerid, STEALTH_GREEN, "You have cloned this vehicle.");
		return 1;
	}
	SendClientMessage(playerid, STEALTH_YELLOW, "Too many cars");

	return 1;
}


YCMD:avox(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move a vehicle's attached object along the X axis.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new Float:dist;
		dist = floatstr(arg);
		if(dist == 0) dist = 1.0;
		
		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COX][refindex] += dist;
	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		UpdatePlayerOSelText(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to a vehicle");
	}

	return 1;
}

YCMD:avoy(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move a vehicle's attached object along the Y axis.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new Float:dist;
		dist = floatstr(arg);
		if(dist == 0) dist = 1.0;

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COY][refindex] += dist;
	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		UpdatePlayerOSelText(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to a vehicle");
	}

	return 1;
}

YCMD:avoz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Move a vehicle's attached object along the Z axis.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new Float:dist;
		dist = floatstr(arg);
		if(dist == 0) dist = 1.0;

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COZ][refindex] += dist;
	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		UpdatePlayerOSelText(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to a vehicle");
	}

	return 1;
}

YCMD:avrx(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate a vehicle's attached object along the X axis.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new Float:dist;
		dist = floatstr(arg);
		if(dist == 0) dist = 5.0;

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORX][refindex] += dist;
	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		UpdatePlayerOSelText(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to a vehicle");
	}

	return 1;
}

YCMD:avry(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate a vehicle's attached object along the Y axis.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new Float:dist;
		dist = floatstr(arg);
		if(dist == 0) dist = 5.0;

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORY][refindex] += dist;
	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		UpdatePlayerOSelText(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to a vehicle");
	}

	return 1;
}

YCMD:avrz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotate a vehicle's attached object along the Z axis.");
		return 1;
	}

    MapOpenCheck();

	NoEditingMode(playerid);

	EditCheck(playerid);

	if(ObjectData[CurrObject[playerid]][oAttachedVehicle] > -1)
	{
		new Float:dist;
		dist = floatstr(arg);
		if(dist == 0) dist = 5.0;

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORZ][refindex] += dist;
	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		UpdatePlayerOSelText(playerid);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "This object is not attached to a vehicle");
	}

	return 1;
}

static Float:AVEditPos[MAX_PLAYERS][3];
static Float:AVEditObjPos[MAX_PLAYERS][6];

EditVehicleObject(playerid)
{
    MapOpenCheck();

	EditCheck(playerid);

   	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

   	if(!EditingMode[playerid])
	{
		new carindex = ObjectData[CurrObject[playerid]][oAttachedVehicle];
		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);
		
		GetVehiclePos(CarData[carindex][CarID], AVEditPos[playerid][0], AVEditPos[playerid][1], AVEditPos[playerid][2]);

		PivotObject[playerid] = CreateDynamicObject(1974,
			AVEditPos[playerid][0]+CarData[carindex][COX][refindex],
			AVEditPos[playerid][1]+CarData[carindex][COY][refindex],
			AVEditPos[playerid][2]+CarData[carindex][COZ][refindex],
			CarData[carindex][CORX][refindex],
			CarData[carindex][CORY][refindex],
			CarData[carindex][CORZ][refindex],
			-1, -1, playerid);

        AVEditObjPos[playerid][0] = CarData[carindex][COX][refindex];
        AVEditObjPos[playerid][1] = CarData[carindex][COY][refindex];
        AVEditObjPos[playerid][2] = CarData[carindex][COZ][refindex];
        AVEditObjPos[playerid][3] = CarData[carindex][CORX][refindex];
        AVEditObjPos[playerid][4] = CarData[carindex][CORY][refindex];
        AVEditObjPos[playerid][5] = CarData[carindex][CORZ][refindex];

		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, PivotObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

		SetDynamicObjectMaterial(PivotObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

		Streamer_Update(playerid);

		EditingMode[playerid] = true;
		SetEditMode(playerid, EDIT_MODE_VOBJECT);

		SetVehicleZAngle(CarData[carindex][CarID], 0.0);

		EditDynamicObject(playerid, PivotObject[playerid]);

		SendClientMessage(playerid, STEALTH_GREEN, "Entered Vehicle Edit Object Mode");

	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "You are in editing mode already");
	return 1;
}

OnPlayerEditVObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	#pragma unused objectid
	if(response == EDIT_RESPONSE_FINAL)
	{
		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);

	    AVEditPos[playerid][0] = x - AVEditPos[playerid][0];
	    AVEditPos[playerid][1] = y - AVEditPos[playerid][1];
	    AVEditPos[playerid][2] = z - AVEditPos[playerid][2];

        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COX][refindex] = AVEditPos[playerid][0];
	    CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COY][refindex] = AVEditPos[playerid][1];
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COZ][refindex] = AVEditPos[playerid][2];

        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORX][refindex] = rx;
	    CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORY][refindex] = ry;
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORZ][refindex] = rz;

	    UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);
	    sqlite_SaveVehicleObjectData(ObjectData[CurrObject[playerid]][oAttachedVehicle]);

		DestroyDynamicObject(PivotObject[playerid]);

		EditingMode[playerid] = false;
		SetEditMode(playerid, EDIT_MODE_NONE);
		
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Saved new attached object position");
	}
	else if(response == EDIT_RESPONSE_UPDATE)
	{
		new Float:tmpx, Float:tmpy, Float:tmpz;

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);

	    tmpx = x - AVEditPos[playerid][0];
	    tmpy = y - AVEditPos[playerid][1];
	    tmpz = z - AVEditPos[playerid][2];

        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COX][refindex] = tmpx;
	    CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COY][refindex] = tmpy;
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COZ][refindex] = tmpz;
        
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORX][refindex] = rx;
	    CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORY][refindex] = ry;
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORZ][refindex] = rz;
        
        SetVehicleZAngle(CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CarID], 0.0);

        UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);
	
	}
	else if(response == EDIT_RESPONSE_CANCEL)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Cancelled vehicle object editing");

		DestroyDynamicObject(PivotObject[playerid]);

		new refindex = GetCarObjectRefIndex(ObjectData[CurrObject[playerid]][oAttachedVehicle], CurrObject[playerid]);

        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COX][refindex] = AVEditObjPos[playerid][0];
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COY][refindex] = AVEditObjPos[playerid][1];
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][COZ][refindex] = AVEditObjPos[playerid][2];
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORX][refindex] = AVEditObjPos[playerid][3];
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORY][refindex] = AVEditObjPos[playerid][4];
        CarData[ObjectData[CurrObject[playerid]][oAttachedVehicle]][CORZ][refindex] = AVEditObjPos[playerid][5];

        UpdateAttachedVehicleObject(ObjectData[CurrObject[playerid]][oAttachedVehicle], refindex, VEHICLE_ATTACH_UPDATE);

		EditingMode[playerid] = false;
		SetEditMode(playerid, EDIT_MODE_NONE);
	}
	return 1;
}


UpdateAttachedVehicleObject(carindex, refindex, type)
{
	if(type == VEHICLE_ATTACH_UPDATE)
	{
	    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], E_STREAMER_ATTACH_OFFSET_X, CarData[carindex][COX][refindex]);
	    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], E_STREAMER_ATTACH_OFFSET_Y, CarData[carindex][COY][refindex]);
	    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], E_STREAMER_ATTACH_OFFSET_Z, CarData[carindex][COZ][refindex]);
	    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], E_STREAMER_ATTACH_R_X, CarData[carindex][CORX][refindex]);
	    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], E_STREAMER_ATTACH_R_Y, CarData[carindex][CORY][refindex]);
	    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], E_STREAMER_ATTACH_R_Z, CarData[carindex][CORZ][refindex]);

	}
	else if(type == VEHICLE_REATTACH_UPDATE)
	{
		refindex = GetCarObjectRefIndex(carindex, refindex);
		
	    AttachDynamicObjectToVehicle(ObjectData[CarData[carindex][CarObjectRef][refindex]][oID], CarData[carindex][CarID],
			CarData[carindex][COX][refindex], CarData[carindex][COY][refindex], CarData[carindex][COZ][refindex],
			CarData[carindex][CORX][refindex], CarData[carindex][CORY][refindex], CarData[carindex][CORZ][refindex]
		);
	}

	UpdateObject3DText(CarData[carindex][CarObjectRef][refindex], false);

	return 1;
}


UpdateAttachedObjectRef(carindex, objindex)
{
	new refindex = GetCarObjectRefIndex(carindex, objindex);
	if(refindex > -1)
	{
		CarData[carindex][CarObjectRef][refindex] = -1;
		sqlite_SaveVehicleObjectData(carindex);
	    return 1;
	}
    return 0;
}

GetCarObjectRefIndex(carindex, objindex)
{
	for(new i = 0; i < MAX_CAR_OBJECTS; i++)
	{
		if(CarData[carindex][CarObjectRef][i] == objindex) return i;
	}
	return -1;
}

static IsObjectAttachedToVehicle(index)
{
	foreach(new i : Cars)
	{
	    for(new j = 0; j < MAX_CAR_OBJECTS; j++) if(CarData[i][CarObjectRef][j] == index) return 1;
	}
	return 0;
}

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

static ExportCar(playerid, index, name[])
{
	new File:f = fopen(name, io_write);
	new templine[256];
	
	// Header
	fwrite(f,"//Vehicle Exported with Texture Studio By: [uL]Pottus/////////////////////////////////////////////////////////////\r\n");
	fwrite(f,"//////////////////////////////////////////////////and Crayder/////////////////////////////////////////////////////\r\n");
	fwrite(f,"//////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

	// Includes
	fwrite(f, "#include <a_samp>\r\n");
	fwrite(f, "#include <streamer>\r\n\n");

	// Car id
	fwrite(f, "new carvid;\r\n\n");
	
	// Init script
    fwrite(f, "public OnFilterScriptInit()\r\n");
    fwrite(f, "{ \r\n");
    fwrite(f,"    new tmpobjid;\r\n\n");
    
	format(templine, sizeof(templine), "    carvid = CreateVehicle(%i,%.3f,%.3f,%.3f,%.3f,%i,%i,-1,%i);\r\n\n",
        CarData[index][CarModel], CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ], CarData[index][CarSpawnFA], CarData[index][CarColor1], CarData[index][CarColor2], CarData[index][CarSiren] ? 1 : 0
	);
	
 	fwrite(f, templine);


	// Mod components
	for(new i = 0; i < MAX_CAR_COMPONENTS; i++)
	{
	    if(CarData[index][CarComponents][i] > 0)
	    {
	        format(templine, sizeof(templine), "    AddVehicleComponent(carvid, %i);\r\n", CarData[index][CarComponents][i]);
			fwrite(f, templine);
	    }
	}
	
	// Paintjob
	if(CarData[index][CarPaintJob] < 3)
	{
        format(templine, sizeof(templine), "    ChangeVehiclePaintjob(carvid, %i);\r\n\n", CarData[index][CarPaintJob]);
		fwrite(f, templine);
	}


	// Objects
    for(new i = 0; i < MAX_CAR_OBJECTS; i++)
    {
		// No object
        if(CarData[index][CarObjectRef][i] == -1) continue;
        new oindex = CarData[index][CarObjectRef][i];

		// Create object
		format(templine,sizeof(templine),"    tmpobjid = CreateDynamicObject(%i,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);\r\n",ObjectData[oindex][oModel]);
        fwrite(f,templine);


		// Write all materials and colors
		for(new j = 0; j < MAX_MATERIALS; j++)
    	{
			// Does object have a texture set?
            if(ObjectData[oindex][oTexIndex][j] != 0)
            {
				format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, %i);\r\n",
					j, GetTModel(ObjectData[oindex][oTexIndex][j]), 34, GetTXDName(ObjectData[oindex][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[oindex][oTexIndex][j]), 34, ObjectData[oindex][oColorIndex][j]
				);

				fwrite(f,templine);
            }

            // No texture how about a color?
            else if(ObjectData[oindex][oColorIndex][j] != 0)
            {
				format(templine,sizeof(templine),"    SetDynamicObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, %i);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[oindex][oColorIndex][j]);
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
		format(templine, sizeof(templine), "    AttachDynamicObjectToVehicle(tmpobjid, carvid, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f);\r\n",
			CarData[index][COX][i], CarData[index][COY][i], CarData[index][COZ][i], CarData[index][CORX][i], CarData[index][CORY][i], CarData[index][CORZ][i]
		);
		
		fwrite(f,templine);
	}

    fwrite(f, "} \r\n\n");

	// Exit script
    fwrite(f, "public OnFilterScriptExit()\r\n");
    fwrite(f, "{ \r\n");
    fwrite(f,"    DestroyVehicle(carvid);\r\n");
    fwrite(f, "} \r\n\n");
    
	// Vehicle respawn
    fwrite(f, "public OnVehicleSpawn(vehicleid)\r\n");

    fwrite(f, "{ \r\n");
    fwrite(f, "    if(vehicleid == carvid)\r\n");
    fwrite(f, "    { \r\n");

	// Mod components
	for(new i = 0; i < MAX_CAR_COMPONENTS; i++)
	{
	    if(CarData[index][CarComponents][i] > 0)
	    {
	        format(templine, sizeof(templine), "        AddVehicleComponent(carvid, %i);\r\n", CarData[index][CarComponents][i]);
			fwrite(f, templine);
	    }
	}



	// Paintjob
	if(CarData[index][CarPaintJob] < 3)
	{
        format(templine, sizeof(templine), "        ChangeVehiclePaintjob(carvid, %i);\r\n", CarData[index][CarPaintJob]);
		fwrite(f, templine);
	}

    fwrite(f, "    } \r\n");


    fwrite(f, "} \r\n");

    fclose(f);

	format(templine, sizeof(templine), "Exported vehicle to filterscript %s", name);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, templine);

	return 1;
}

static ExportAllCars(playerid, name[])
{
	new File:f = fopen(name, io_write);
	new templine[256];

	// Header
	fwrite(f,"//Vehicle Exported with Texture Studio By: [uL]Pottus/////////////////////////////////////////////////////////////\r\n");
	fwrite(f,"//////////////////////////////////////////////////and Crayder/////////////////////////////////////////////////////\r\n");
	fwrite(f,"//////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

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
		format(templine, sizeof(templine), "    carvid_%i = CreateVehicle(%i,%.3f,%.3f,%.3f,%.3f,%i,%i,-1,%i);\r\n",
	        CurrCar++, CarData[i][CarModel], CarData[i][CarSpawnX], CarData[i][CarSpawnY], CarData[i][CarSpawnZ], CarData[i][CarSpawnFA], CarData[i][CarColor1], CarData[i][CarColor2], CarData[i][CarSiren] ? 1 : 0
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
				CurrCar, CarData[i][COX][j], CarData[i][COY][j], CarData[i][COZ][j], CarData[i][CORX][j], CarData[i][CORY][j], CarData[i][CORZ][j]
			);

			fwrite(f,templine);
		}
		CurrCar++;
		
		fwrite(f, "\n");
	}
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


YCMD:avexport(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Export all vehicles to a text file.");
		return 1;
	}

	MapOpenCheck();

	VehicleCheck(playerid);

	// Ask for a map name
	inline ExportVehicle(epid, edialogid, eresponse, elistitem, string:etext[])
	{
	    #pragma unused elistitem, edialogid, epid
	    if(eresponse)
	    {
			// Was a map name supplied ?
			if(!isnull(etext))
			{
				new exportmap[256];
				
				// Check map name length
				if(strlen(etext) >= 20)
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "Choose a shorter vehicle name to export to...");
					return 1;
				}

				// Format the output name
				format(exportmap, sizeof(exportmap), "tstudio/ExportCars/%s.pwn", etext);

				// Map exists ask to remove
			    if(fexist(exportmap))
				{
					inline RemoveVehicle(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
					{
				        #pragma unused rlistitem, rdialogid, rpid, rtext

						// Remove map and export
				        if(rresponse)
				        {
				            fremove(exportmap);
				            ExportCar(playerid, CurrVehicle[playerid], exportmap);
				        }
					}
					Dialog_ShowCallback(playerid, using inline RemoveVehicle, DIALOG_STYLE_MSGBOX, "Texture Studio (Vehicle Export)", "A export exists with this name replace?", "Ok", "Cancel");
				}
				// We can start the export
				else ExportCar(playerid, CurrVehicle[playerid], exportmap);
			}
		}
		else
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "You can't export a vehicle with no name");
			Dialog_ShowCallback(playerid, using inline ExportVehicle, DIALOG_STYLE_INPUT, "Texture Studio (Vehicle Export)", "Enter a export vehicle name", "Ok", "Cancel");
		}
	}
	Dialog_ShowCallback(playerid, using inline ExportVehicle, DIALOG_STYLE_INPUT, "Texture Studio (Vehicle Export)", "Enter a export vehicle name", "Ok", "Cancel");
	
	return 1;

}

YCMD:avexportall(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Export all vehicles to a filterscript.");
		return 1;
	}

	MapOpenCheck();

	if(Iter_Count(Cars) == 0)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "There are no cars to export.");
		return 1;
	}

	// Ask for a map name
	inline ExportVehicles(epid, edialogid, eresponse, elistitem, string:etext[])
	{
	    #pragma unused elistitem, edialogid, epid
	    if(eresponse)
	    {
			// Was a map name supplied ?
			if(!isnull(etext))
			{
				new exportmap[256];

				// Check map name length
				if(strlen(etext) >= 20)
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "Choose a shorter vehicles name to export to...");
					return 1;
				}

				// Format the output name
				format(exportmap, sizeof(exportmap), "tstudio/ExportCars/%s.pwn", etext);

				// Map exists ask to remove
			    if(fexist(exportmap))
				{
					inline RemoveVehicles(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
					{
				        #pragma unused rlistitem, rdialogid, rpid, rtext

						// Remove map and export
				        if(rresponse)
				        {
				            fremove(exportmap);
				            ExportAllCars(playerid, exportmap);
				        }
					}
					Dialog_ShowCallback(playerid, using inline RemoveVehicles, DIALOG_STYLE_MSGBOX, "Texture Studio (Export Vehicles)", "A export exists with this name replace?", "Ok", "Cancel");
				}
				// We can start the export
				else ExportAllCars(playerid, exportmap);
			}
		}
		else
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "You can't export a vehicle with no name");
			Dialog_ShowCallback(playerid, using inline ExportVehicles, DIALOG_STYLE_INPUT, "Texture Studio (Export Vehicles)", "Enter a export vehicle name", "Ok", "Cancel");
		}
	}
	Dialog_ShowCallback(playerid, using inline ExportVehicles, DIALOG_STYLE_INPUT, "Texture Studio (Export Vehicles)", "Enter a export vehicle name", "Ok", "Cancel");

	return 1;
}

