#include <YSI\y_hooks>

#define         MAX_EDIT_CARS                   10
#define         MAX_CAR_OBJECTS         		30
#define         MAX_CAR_EDIT_OBJECTS            300

enum CARINFO
{
	CarID,
	CarModel,
	Text3D:CarText,
	CarColor1,
	CarColor2,
	CarPaintJob,
	Float:CarSpawnX,
	Float:CarSpawnY,
	Float:CarSpawnZ,
	Float:CarSpawnFA,
	CarComponents[14],
	CarObjectRef[MAX_CAR_OBJECTS],
	Float:COX[MAX_CAR_OBJECTS],
	Float:COY[MAX_CAR_OBJECTS],
	Float:COZ[MAX_CAR_OBJECTS],
	Float:CORX[MAX_CAR_OBJECTS],
	Float:CORY[MAX_CAR_OBJECTS],
	Float:CORZ[MAX_CAR_OBJECTS],
}

static Iterator:Cars<MAX_EDIT_CARS>;
static CarData[MAX_EDIT_CARS][CARINFO];

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

static VehicleList[4096];

hook OnFilterScriptInit()
{
	for(new i = 0; i < 212; i++) format(VehicleList, sizeof(VehicleList), "(%i)%s%s\n", i+212, VehicleList, VehicleNames[i]);
	return 1;
}

hook OnFilterScriptExit()
{
	DeleteAllCars();
	return 1;
}

CMD:newcar(playerid, arg[])
{
    MapOpenCheck();

	NoEditingMode(playerid);

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
				GetPlayerFacingAngle(playerid, CarData[index][CarSpawnX], CarData[index][CarSpawnFA]);
				AddNewCar(listitem+212, index, true);
			}
			SendClientMessage(playerid, STEALTH_YELLOW, "Too many cars");
		}
    }
    Dialog_ShowCallback(playerid, using inline SelectModel, DIALOG_STYLE_LIST, "Texture Studio", VehicleList, "Ok", "Cancel");

	return 1;
}

static AddNewCar(modelid, index = -1, bool:sqlsave = true)
{
	if(index == -1) index = Iter_Free(Cars);
	
	if(index > -1)
	{
	    Iter_Add(Cars, index);
	    CarData[index][CarID] = CreateVehicle(listitem+212, CarData[index][CarSpawnX], CarData[index][CarSpawnY], CarData[index][CarSpawnZ], CarData[index][CarSpawnFA], CarData[index][CarColor1], CarData[index][CarColor2], -1);
		if(sqlsave) sqlite_InsertCar(index);
	}
	SendClientMessage(playerid, STEALTH_YELLOW, "Too many cars");
	return 1;
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
			"CORZ TEXT);"
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
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
		insertcarstmt = db_prepare(EditMap, InsertCarString);
	}

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
    stmt_bind_value(insertcarstmt, 9, DB::TYPE_ARRAY, CarData[index][CarComponents], 14);
    stmt_bind_value(insertcarstmt, 10, DB::TYPE_ARRAY, CarData[index][CarObjectRef], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 11, DB::TYPE_ARRAY, CarData[index][COX], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 12, DB::TYPE_ARRAY, CarData[index][COY], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 13, DB::TYPE_ARRAY, CarData[index][COZ], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 14, DB::TYPE_ARRAY, CarData[index][CORX], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 15, DB::TYPE_ARRAY, CarData[index][CORY], MAX_CAR_OBJECTS);
    stmt_bind_value(insertcarstmt, 16, DB::TYPE_ARRAY, CarData[index][CORZ], MAX_CAR_OBJECTS);

    stmt_execute(insertcarstmt);
}

DeleteAllCars()
{
	foreach(new i : Cars)
	{
		DestoryEditCar(i, false);
	}
	return 1;
}

DestroyEditCar(index, bool:sqldelete=true)
{
    DestroyVehicle(CarData[index][CarID]);
    CarData[index][CarModel] = -1;
    CarData[index][CarColor1]);
    CarData[index][CarColor2]);
    CarData[index][CarPaintJob]);
    CarData[index][CarSpawnX]);
    CarData[index][CarSpawnY]);
    CarData[index][CarSpawnZ]);
    CarData[index][CarSpawnFA]);
    
    for(new i = 0; i < 14; i++) CarData[index][CarComponents][i] = 0;
	for(new i = 0; i < MAX_CAR_OBJECTS; i++)
	{
	    CarData[index][CarObjectRef][i] = -1;
	    CarData[index][COX][i] = -1;
	    CarData[index][COY][i] = -1;
	    CarData[index][COZ][i] = -1;
	    CarData[index][CORX][i] = -1;
	    CarData[index][CORY][i] = -1;
	    CarData[index][CORZ][i] = -1;
	}
	if(sqldelete)
	{
	    new q[128];
	    format(q, sizeof(q), "DELETE FROM `Vehicles` WHERE `IndexID` = %i", index);
	    db_query(EditMap, q);
	}
	return 1;
}


CMD:editcar(playerid, arg[])
{
    MapOpenCheck();

	NoEditingMode(playerid);
	

	return 1;
}
