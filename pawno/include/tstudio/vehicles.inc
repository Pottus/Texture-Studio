#include <YSI\y_hooks>

#define         MAX_EDIT_CARS                   10
#define         MAX_CAR_OBJECTS         		30
#define         MAX_CAR_EDIT_OBJECTS            300

enum CARINFO
{
	CarModel,
	CarColor1,
	CarColor2,
	CarPaintJob,
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
	for(new i = 0; i < 212; i++) format(VehicleList, sizeof(VehicleList), "%s%s\n", VehicleList, VehicleNames[i]);
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
			    Iter_Add(Cars, index);
			    
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
			"ModelID INTEGER,",
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
/*
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
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);
		// Prepare data base for writing
		insertcarstmt = db_prepare(EditMap, InsertCarString);
	}

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

    stmt_execute(insertcarstmt);
}
*/





CMD:editcar(playerid, arg[])
{
    MapOpenCheck();

	NoEditingMode(playerid);
	

	return 1;
}
