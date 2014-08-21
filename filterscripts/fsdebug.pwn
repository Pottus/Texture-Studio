/* SA:MP PAWN Debug -
 *  Debugging filterscript used
 *  for creation of gamemode.
 *
 *  Simon Campbell
 *  10/03/2007, 6:31pm
 *
 *  17/11/2011
 *    Updated to 0.5d which supports SA:MP 0.3d
*/

//==============================================================================

#include <a_samp>

#undef KEY_UP
#undef KEY_DOWN
#undef KEY_LEFT
#undef KEY_RIGHT

#define KEY_UP  	65408
#define KEY_DOWN	128
#define KEY_LEFT    65408
#define KEY_RIGHT   128

#define DEBUG_VERSION   "0.5d"

#define SKIN_SELECT   	true
#define	VEHI_SELECT   	true
#define WORL_SELECT     true
#define CAME_SELECT     true
#define OBJE_SELECT		true

#define MISCEL_CMDS     true
#define ADMINS_ONLY     false

#define SKIN_SEL_STAT   1
#define VEHI_SEL_STAT   2
#define WORL_SEL_STAT   3
#define CAME_SEL_STAT   4
#define OBJE_SEL_STAT	5

#define COLOR_RED   	0xFF4040FF
#define COLOR_GREEN 	0x40FF40FF
#define COLOR_BLUE  	0x4040FFFF

#define COLOR_CYAN  	0x40FFFFFF
#define COLOR_PINK  	0xFF40FFFF
#define COLOR_YELLOW    0xFFFF40FF

#define COLOR_WHITE		0xFFFFFFFF
#define COLOR_BLACK		0x000000FF
#define COLOR_NONE      0x00000000

#define MIN_SKIN_ID		0
#define MAX_SKIN_ID		299

#define MIN_VEHI_ID		400
#define MAX_VEHI_ID		611

#define MIN_TIME_ID		0
#define MAX_TIME_ID		23

#define MIN_WEAT_ID     0
#define MAX_WEAT_ID		45

#define MIN_OBJE_ID		615
#define MAX_OBJE_ID		13563

#define DEFAULT_GRA     0.008

#define VEHI_DIS        5.0
#define OBJE_DIS		10.0

#define CMODE_A			0
#define CMODE_B			1

#define O_MODE_SELECTOR	0
#define O_MODE_MOVER	1
#define O_MODE_ROTATOR	2

#define PI				3.14159265

#define CAMERA_TIME     40

#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

//==============================================================================

new gPlayerStatus[MAX_PLAYERS]; // Player Status
new gPlayerTimers[MAX_PLAYERS]; // Player TimerID's for keypresses
new gWorldStatus[3] =  {12, 4}; // Time, Weather

new curPlayerSkin[MAX_PLAYERS]				= {MIN_SKIN_ID, ...}; // Current Player Skin ID
new curPlayerVehM[MAX_PLAYERS]				= {MIN_VEHI_ID, ...}; // Current Player Vehicle ID
new curPlayerVehI[MAX_PLAYERS]				= {-1, ...};

enum E_OBJECT
{
	OBJ_MOD,
	OBJ_MDL,
	Float:OBJ_X,
	Float:OBJ_Y,
	Float:OBJ_Z,
	Float:OBJ_RX,
	Float:OBJ_RY,
	Float:OBJ_RZ
}

enum E_OBJ_RATE
{
	Float:OBJ_RATE_ROT,
	Float:OBJ_RATE_MOVE
}

new pObjectRate[ MAX_PLAYERS ][ E_OBJ_RATE ];
new curPlayerObjM[ MAX_PLAYERS ][ E_OBJECT ];
new curPlayerObjI[ MAX_PLAYERS ]				= {-1, ...};

enum P_CAMERA_D {
	CMODE,
	Float:RATE,
	Float:CPOS_X,
	Float:CPOS_Y,
	Float:CPOS_Z,
	Float:CLOO_X,
	Float:CLOO_Y,
	Float:CLOO_Z
};

new curPlayerCamD[MAX_PLAYERS][P_CAMERA_D];

enum CURVEHICLE {
	bool:spawn,
	vmodel,
	vInt
};

new curServerVehP[MAX_VEHICLES][CURVEHICLE];

new aSelNames[5][] = {			// Menu selection names
	{"SkinSelect"},
	{"VehicleSelect"},
	{"WeatherSelect"},
	{"CameraSelect"},
	{"ObjectSelect"}
};

new aWeaponNames[][32] = {
	{"Unarmed (Fist)"}, // 0
	{"Brass Knuckles"}, // 1
	{"Golf Club"}, // 2
	{"Night Stick"}, // 3
	{"Knife"}, // 4
	{"Baseball Bat"}, // 5
	{"Shovel"}, // 6
	{"Pool Cue"}, // 7
	{"Katana"}, // 8
	{"Chainsaw"}, // 9
	{"Purple Dildo"}, // 10
	{"Big White Vibrator"}, // 11
	{"Medium White Vibrator"}, // 12
	{"Small White Vibrator"}, // 13
	{"Flowers"}, // 14
	{"Cane"}, // 15
	{"Grenade"}, // 16
	{"Teargas"}, // 17
	{"Molotov"}, // 18
	{" "}, // 19
	{" "}, // 20
	{" "}, // 21
	{"Colt 45"}, // 22
	{"Colt 45 (Silenced)"}, // 23
	{"Desert Eagle"}, // 24
	{"Normal Shotgun"}, // 25
	{"Sawnoff Shotgun"}, // 26
	{"Combat Shotgun"}, // 27
	{"Micro Uzi (Mac 10)"}, // 28
	{"MP5"}, // 29
	{"AK47"}, // 30
	{"M4"}, // 31
	{"Tec9"}, // 32
	{"Country Rifle"}, // 33
	{"Sniper Rifle"}, // 34
	{"Rocket Launcher"}, // 35
	{"Heat-Seeking Rocket Launcher"}, // 36
	{"Flamethrower"}, // 37
	{"Minigun"}, // 38
	{"Satchel Charge"}, // 39
	{"Detonator"}, // 40
	{"Spray Can"}, // 41
	{"Fire Extinguisher"}, // 42
	{"Camera"}, // 43
	{"Night Vision Goggles"}, // 44
	{"Infrared Vision Goggles"}, // 45
	{"Parachute"}, // 46
	{"Fake Pistol"} // 47
};


new aVehicleNames[212][] = {	// Vehicle Names - Betamaster
	{"Landstalker"},
	{"Bravura"},
	{"Buffalo"},
	{"Linerunner"},
	{"Perrenial"},
	{"Sentinel"},
	{"Dumper"},
	{"Firetruck"},
	{"Trashmaster"},
	{"Stretch"},
	{"Manana"},
	{"Infernus"},
	{"Voodoo"},
	{"Pony"},
	{"Mule"},
	{"Cheetah"},
	{"Ambulance"},
	{"Leviathan"},
	{"Moonbeam"},
	{"Esperanto"},
	{"Taxi"},
	{"Washington"},
	{"Bobcat"},
	{"Mr Whoopee"},
	{"BF Injection"},
	{"Hunter"},
	{"Premier"},
	{"Enforcer"},
	{"Securicar"},
	{"Banshee"},
	{"Predator"},
	{"Bus"},
	{"Rhino"},
	{"Barracks"},
	{"Hotknife"},
	{"Trailer 1"}, //artict1
	{"Previon"},
	{"Coach"},
	{"Cabbie"},
	{"Stallion"},
	{"Rumpo"},
	{"RC Bandit"},
	{"Romero"},
	{"Packer"},
	{"Monster"},
	{"Admiral"},
	{"Squalo"},
	{"Seasparrow"},
	{"Pizzaboy"},
	{"Tram"},
	{"Trailer 2"}, //artict2
	{"Turismo"},
	{"Speeder"},
	{"Reefer"},
	{"Tropic"},
	{"Flatbed"},
	{"Yankee"},
	{"Caddy"},
	{"Solair"},
	{"Berkley's RC Van"},
	{"Skimmer"},
	{"PCJ-600"},
	{"Faggio"},
	{"Freeway"},
	{"RC Baron"},
	{"RC Raider"},
	{"Glendale"},
	{"Oceanic"},
	{"Sanchez"},
	{"Sparrow"},
	{"Patriot"},
	{"Quad"},
	{"Coastguard"},
	{"Dinghy"},
	{"Hermes"},
	{"Sabre"},
	{"Rustler"},
	{"ZR-350"},
	{"Walton"},
	{"Regina"},
	{"Comet"},
	{"BMX"},
	{"Burrito"},
	{"Camper"},
	{"Marquis"},
	{"Baggage"},
	{"Dozer"},
	{"Maverick"},
	{"News Chopper"},
	{"Rancher"},
	{"FBI Rancher"},
	{"Virgo"},
	{"Greenwood"},
	{"Jetmax"},
	{"Hotring"},
	{"Sandking"},
	{"Blista Compact"},
	{"Police Maverick"},
	{"Boxville"},
	{"Benson"},
	{"Mesa"},
	{"RC Goblin"},
	{"Hotring Racer A"}, //hotrina
	{"Hotring Racer B"}, //hotrinb
	{"Bloodring Banger"},
	{"Rancher"},
	{"Super GT"},
	{"Elegant"},
	{"Journey"},
	{"Bike"},
	{"Mountain Bike"},
	{"Beagle"},
	{"Cropdust"},
	{"Stunt"},
	{"Tanker"}, //petro
	{"Roadtrain"},
	{"Nebula"},
	{"Majestic"},
	{"Buccaneer"},
	{"Shamal"},
	{"Hydra"},
	{"FCR-900"},
	{"NRG-500"},
	{"HPV1000"},
	{"Cement Truck"},
	{"Tow Truck"},
	{"Fortune"},
	{"Cadrona"},
	{"FBI Truck"},
	{"Willard"},
	{"Forklift"},
	{"Tractor"},
	{"Combine"},
	{"Feltzer"},
	{"Remington"},
	{"Slamvan"},
	{"Blade"},
	{"Freight"},
	{"Streak"},
	{"Vortex"},
	{"Vincent"},
	{"Bullet"},
	{"Clover"},
	{"Sadler"},
	{"Firetruck LA"}, //firela
	{"Hustler"},
	{"Intruder"},
	{"Primo"},
	{"Cargobob"},
	{"Tampa"},
	{"Sunrise"},
	{"Merit"},
	{"Utility"},
	{"Nevada"},
	{"Yosemite"},
	{"Windsor"},
	{"Monster A"}, //monstera
	{"Monster B"}, //monsterb
	{"Uranus"},
	{"Jester"},
	{"Sultan"},
	{"Stratum"},
	{"Elegy"},
	{"Raindance"},
	{"RC Tiger"},
	{"Flash"},
	{"Tahoma"},
	{"Savanna"},
	{"Bandito"},
	{"Freight Flat"}, //freiflat
	{"Streak Carriage"}, //streakc
	{"Kart"},
	{"Mower"},
	{"Duneride"},
	{"Sweeper"},
	{"Broadway"},
	{"Tornado"},
	{"AT-400"},
	{"DFT-30"},
	{"Huntley"},
	{"Stafford"},
	{"BF-400"},
	{"Newsvan"},
	{"Tug"},
	{"Trailer 3"}, //petrotr
	{"Emperor"},
	{"Wayfarer"},
	{"Euros"},
	{"Hotdog"},
	{"Club"},
	{"Freight Carriage"}, //freibox
	{"Trailer 3"}, //artict3
	{"Andromada"},
	{"Dodo"},
	{"RC Cam"},
	{"Launch"},
	{"Police Car (LSPD)"},
	{"Police Car (SFPD)"},
	{"Police Car (LVPD)"},
	{"Police Ranger"},
	{"Picador"},
	{"S.W.A.T. Van"},
	{"Alpha"},
	{"Phoenix"},
	{"Glendale"},
	{"Sadler"},
	{"Luggage Trailer A"}, //bagboxa
	{"Luggage Trailer B"}, //bagboxb
	{"Stair Trailer"}, //tugstair
	{"Boxville"},
	{"Farm Plow"}, //farmtr1
	{"Utility Trailer"} //utiltr1
};

//==============================================================================

forward SkinSelect(playerid);
forward VehicleSelect(playerid);
forward WorldSelect(playerid);
forward CameraSelect(playerid);
forward ObjectSelect( playerid );

//==============================================================================

dcmd_debug(playerid, params[]) {
	if(strcmp(params, "help", true, 4) == 0) {
		SendClientMessage(playerid, COLOR_BLUE, "[DEBUG]: Debug Mode 0.2 - HELP");
		SendClientMessage(playerid, COLOR_CYAN, "[DEBUG]: Debug Mode 0.2 is a filterscript which allows scripters");
		SendClientMessage(playerid, COLOR_CYAN, "[DEBUG]: or people who wish to explore SA:MP 0.2\'s features to have access");
		SendClientMessage(playerid, COLOR_CYAN, "[DEBUG]: to many commands and \"menu\'s\".");
		SendClientMessage(playerid, COLOR_YELLOW, "[DEBUG]: This filterscript was designed for SA:MP version 0.2");
		SendClientMessage(playerid, COLOR_PINK, "[DEBUG]: For the command list type \"/debug commands\"");

		return true;
	}
	if(strcmp(params, "commands", true, 8) == 0) {
	    SendClientMessage(playerid, COLOR_BLUE, "[DEBUG]: Debug Mode 0.2 - COMMANDS");
	    SendClientMessage(playerid, COLOR_CYAN, "[WORLD]: /w, /weather, /t, /time, /wsel, /g, /gravity");
	    SendClientMessage(playerid, COLOR_CYAN, "[VEHICLES]: /v, /vehicle, /vsel");
	    SendClientMessage(playerid, COLOR_CYAN, "[PLAYER]: /s, /skin, /ssel, /weapon, /w2");
	    SendClientMessage(playerid, COLOR_CYAN, "[PLAYER]: /goto, /warpto, /bring, /setloc");
	    SendClientMessage(playerid, COLOR_CYAN, "[CAMERA]: /camera, /csel");

	    return true;
	}

	if(strcmp(params, "dump", true, 4) == 0) {
	    SendClientMessage(playerid, COLOR_GREEN, "[SUCCESS]: All current server data dumped to a file.");
	    new File:F_DUMP = fopen("DEBUG-DUMP.txt", io_append);
	    if(F_DUMP) {
	        new h, m, s, Y, M, D, cString[256];

			getdate(Y, M, D);
			gettime(h, m, s);

	        format(cString, 256, "// %d-%d-%d @ %d:%d:%d\r\n", D, M, Y, h, m, s);
	        fwrite(F_DUMP, cString);

	    	for(new i = 0; i < MAX_VEHICLES; i++) {
				if(curServerVehP[i][spawn] 	== true) {
				    new Float:vx, Float:vy, Float:vz, Float:va;
				    GetVehiclePos(i, vx, vy, vz);
				    GetVehicleZAngle(i, va);
					format(cString, 256, "CreateVehicle(%d, %f, %f, %f, %f, -1, -1, 5000); // Interior(%d), %s\r\n", curServerVehP[i][vmodel], vx, vy, vz, va, curServerVehP[i][vInt], aVehicleNames[curServerVehP[i][vmodel] - MIN_VEHI_ID]);
					fwrite(F_DUMP, cString);
	        	}
	    	}
	    	print("** Dumped current server information.");
	    	fclose(F_DUMP);
	    }
	    else {
			print("** Failed to create the file \"DEBUG-DUMP.txt\".\n");
	    }
	    return true;
	}
	return false;
}

#if CAME_SELECT == true

dcmd_object(playerid, params[])
{
	new cString[ 128 ], idx;
	cString = strtok( params, idx );

	if ( !strlen( cString ) || !strlen( params[ idx + 1 ] ) )
	{
	    SendClientMessage( playerid, COLOR_WHITE, "[USAGE]: /object [RRATE/MRATE/CAMERA] [RATE/ID]");

	    return 1;
	}

	if ( strcmp( cString, "rrate", true ) == 0 )
	{
	    pObjectRate[ playerid ][ OBJ_RATE_ROT ] = floatstr( params[ idx + 1 ] );

	    format( cString, 128, "[SUCCESS]: Object rotation rate changed to %f.", pObjectRate[ playerid ][ OBJ_RATE_ROT ] );
		SendClientMessage( playerid, COLOR_GREEN, cString );

		return 1;
	}

	if ( strcmp( cString, "mrate", true ) == 0 )
	{
	    pObjectRate[ playerid ][ OBJ_RATE_MOVE ] = floatstr( params[ idx + 1 ] );

	    format( cString, 128, "[SUCCESS]: Object movement rate changed to %f.", pObjectRate[ playerid ][ OBJ_RATE_MOVE ] );
	    SendClientMessage( playerid, COLOR_GREEN, cString );

	    return 1;
	}

	if ( strcmp( cString, "mode", true ) == 0 )
	{
	    new fuck = strval( params[ idx + 1 ] );

	    if ( fuck >= O_MODE_SELECTOR || fuck <= O_MODE_ROTATOR )
	    {
		    curPlayerObjM[ playerid ][ OBJ_MOD ] = fuck;

		    switch ( fuck )
		    {
		    	case O_MODE_SELECTOR: SendClientMessage( playerid, COLOR_GREEN, "[SUCCESS]: Object mode changed to Object Selection." );
		    	case O_MODE_MOVER: SendClientMessage( playerid, COLOR_GREEN, "[SUCCESS]: Object mode changed to Object Mover." );
		    	case O_MODE_ROTATOR: SendClientMessage( playerid, COLOR_GREEN, "[SUCCESS]: Object mode changed to Object Rotator." );
			}

			return 1;
		}
		else
		{
		    SendClientMessage( playerid, COLOR_RED, "[ERROR]: Invalid modeid." );

		    return 1;
		}
	}

	if ( strcmp( cString, "focus", true ) == 0 )
	{
		new objectid = strval( params[ idx + 1 ] );

		if ( !IsValidObject( objectid ) )
		{
			SendClientMessage( playerid, COLOR_RED, "[ERROR]: Enter a valid objectid." );

			return 1;
		}

		else
		{
			curPlayerObjI[ playerid ] = objectid;

			GetObjectPos( objectid, curPlayerObjM[ playerid ][ OBJ_X ], curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ] );
			GetObjectRot( objectid, curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ] );

		   	curPlayerCamD[playerid][CPOS_X] = curPlayerObjM[ playerid ][ OBJ_X ] + 5.0;
			curPlayerCamD[playerid][CPOS_Y] = curPlayerObjM[ playerid ][ OBJ_Y ] - 20.0;
			curPlayerCamD[playerid][CPOS_Z] = curPlayerObjM[ playerid ][ OBJ_Z ] + 30.0;

			curPlayerCamD[playerid][CLOO_X] = curPlayerObjM[ playerid ][ OBJ_X ];
			curPlayerCamD[playerid][CLOO_Y] = curPlayerObjM[ playerid ][ OBJ_Y ];
			curPlayerCamD[playerid][CLOO_Z] = curPlayerObjM[ playerid ][ OBJ_Z ];

			if ( gPlayerStatus[ playerid ] == OBJE_SEL_STAT )
			{
				SetPlayerCameraPos( playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z] );
            	SetPlayerCameraLookAt( playerid, curPlayerObjM[ playerid ][ OBJ_X ], curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ] );
			}

			return 1;
		}
	}

	if ( strcmp( cString, "camera", true ) == 0 )
	{
	    new cameraid = strval( params[ idx + 1 ] );

		if ( cameraid >= 0 && cameraid < 4 )
		{
		    switch ( cameraid )
		    {
		        case 0:
		        {
		            curPlayerCamD[playerid][CPOS_X] = curPlayerObjM[ playerid ][ OBJ_X ] + 7.0;
					curPlayerCamD[playerid][CPOS_Y] = curPlayerObjM[ playerid ][ OBJ_Y ] - 20.0;
					curPlayerCamD[playerid][CPOS_Z] = curPlayerObjM[ playerid ][ OBJ_Z ] + 30.0;
		        }

		        case 1:
		        {
		            curPlayerCamD[playerid][CPOS_X] = curPlayerObjM[ playerid ][ OBJ_X ] + 7.0;
					curPlayerCamD[playerid][CPOS_Y] = curPlayerObjM[ playerid ][ OBJ_Y ] + 15.0;
					curPlayerCamD[playerid][CPOS_Z] = curPlayerObjM[ playerid ][ OBJ_X ] + 15.0;
		        }

		        case 2:
		        {
		            curPlayerCamD[playerid][CPOS_X] = curPlayerObjM[ playerid ][ OBJ_X ] - 20.0;
					curPlayerCamD[playerid][CPOS_Y] = curPlayerObjM[ playerid ][ OBJ_Y ] + 20.0;
					curPlayerCamD[playerid][CPOS_Z] = curPlayerObjM[ playerid ][ OBJ_X ] + 20.0;
		        }

		        case 3:
		        {
		            curPlayerCamD[playerid][CPOS_X] = curPlayerObjM[ playerid ][ OBJ_X ] - 10.0;
					curPlayerCamD[playerid][CPOS_Y] = curPlayerObjM[ playerid ][ OBJ_Y ] + 25.0;
					curPlayerCamD[playerid][CPOS_Z] = curPlayerObjM[ playerid ][ OBJ_X ] + 15.0;
		        }
		    }

		    SetPlayerCameraPos( playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z] );
            SetPlayerCameraLookAt( playerid, curPlayerObjM[ playerid ][ OBJ_X ], curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ] );

			return 1;
		}
		else
		{
		    SendClientMessage( playerid, COLOR_RED, "[ERROR]: Invalid object camera id.");

		    return 1;
		}
	}
	return 0;
}

dcmd_osel(playerid, params[])
{
	#pragma unused params

	new cString[ 128 ];

	if ( gPlayerStatus[ playerid ] != 0 )
	{
		format( cString, 128, "[ERROR]: You are already using \"%s\".", aSelNames[ gPlayerStatus[ playerid ] - 1 ] );
		SendClientMessage(playerid, COLOR_RED, cString);

		return 1;
	}

	new Float:a;

	gPlayerStatus[playerid] = OBJE_SEL_STAT;

	GetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	curPlayerCamD[playerid][CPOS_Z] += 5.0;
	SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	GetXYInFrontOfPlayer(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], OBJE_DIS);

	curPlayerCamD[playerid][CLOO_Z] = curPlayerCamD[playerid][CPOS_Z] - 5.0;

	SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);

	TogglePlayerControllable(playerid, 0);

	GetPlayerFacingAngle(playerid, a);

	curPlayerObjM[ playerid ][ OBJ_X ] = curPlayerCamD[playerid][CLOO_X];
	curPlayerObjM[ playerid ][ OBJ_Y ] = curPlayerCamD[playerid][CLOO_Y];
	curPlayerObjM[ playerid ][ OBJ_Z ] = curPlayerCamD[playerid][CLOO_Z];
	curPlayerObjM[ playerid ][ OBJ_RX ] = 0.0;
	curPlayerObjM[ playerid ][ OBJ_RY ] = 0.0;
	curPlayerObjM[ playerid ][ OBJ_RZ ] = 0.0;

	curPlayerObjI[ playerid ] = CreateObject( curPlayerObjM[ playerid ][ OBJ_MDL ], curPlayerObjM[ playerid ][ OBJ_X ],
		curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ],
		curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ]
	);

	gPlayerTimers[ playerid ] = SetTimerEx("ObjectSelect", 200, 1, "i", playerid);

	return 1;
}

dcmd_camera(playerid, params[]) {
	new idx; new cString[128];

	cString = strtok(params, idx);

	if (!strlen(cString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /camera [RATE/MODE] [RATE/MODEID]");

	    return true;
	}

	if (strcmp(cString, "rate", true, 4) == 0) {
	    curPlayerCamD[playerid][RATE] = floatstr(params[idx+1]);

	    return true;
	}

	if (strcmp(cString, "mode", true, 4) == 0) {
	    curPlayerCamD[playerid][CMODE] = strval(params[idx+1]);

	    return true;
	}

	return true;
}

dcmd_csel(playerid, params[]) {
	#pragma unused params

	new cString[128];

	if (gPlayerStatus[playerid] != 0) {
		format(cString, 128, "[ERROR]: You are already using \"%s\".", aSelNames[gPlayerStatus[playerid] - 1]);
		SendClientMessage(playerid, COLOR_RED, cString);

		return true;
	}

	gPlayerStatus[playerid] = CAME_SEL_STAT;

    TogglePlayerControllable(playerid, 0);

	GetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	GetXYInFrontOfPlayer(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], 5.0);

	curPlayerCamD[playerid][CLOO_Z] = curPlayerCamD[playerid][CPOS_Z];

	gPlayerTimers[playerid] = SetTimerEx("CameraSelect", 200, 1, "i", playerid);

	return true;
}

#endif

#if WORL_SELECT == true
dcmd_g(playerid, params[]) {
	new cString[128];

	if (!strlen(params[0]))
	{
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /g GRAVITY or /gravity GRAVITY");
	    return true;
	}

	new Float:grav = floatstr(params[0]);

	SetGravity(grav);

	format(cString, 128, "[SUCCESS]: World gravity changed to %f", grav);
	SendClientMessage(playerid, COLOR_GREEN, cString);

	return true;
}

dcmd_gravity(playerid, params[])
	return dcmd_g(playerid, params);

dcmd_w(playerid, params[]) {
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /w WEATHERID or /weather WEATHERID");
	    return true;
	}

	idx = strval(iString);

	if (idx < MIN_WEAT_ID || idx > MAX_WEAT_ID) {
	    SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid WEATHERID");
	    return true;
	}

	gWorldStatus[1] = idx;

	SetWeather(idx);

	format(iString, 128, "[SUCCESS]: Weather has changed to WEATHERID %d", idx);
	SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}

dcmd_weather(playerid, params[])
	return dcmd_w(playerid, params);

dcmd_t(playerid, params[]) {
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /t HOUR or /time HOUR");
	    return true;
	}

	idx = strval(iString);

	if (idx < MIN_TIME_ID || idx > MAX_TIME_ID) {
	    SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid HOUR");
	    return true;
	}

	gWorldStatus[0] = idx;

	SetWorldTime(idx);

	format(iString, 128, "[SUCCESS]: Time has changed to HOUR %d", idx);
	SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}

dcmd_time(playerid, params[])
	return dcmd_t(playerid, params);

dcmd_wsel(playerid, params[]) {
	#pragma unused params

	new cString[128];

	if (gPlayerStatus[playerid] != 0) {
		format(cString, 128, "[ERROR]: You are already using \"%s\".", aSelNames[gPlayerStatus[playerid] - 1]);
		SendClientMessage(playerid, COLOR_RED, cString);
		return true;
	}

	new Float:x, Float:y, Float:z;

	gPlayerStatus[playerid] = WORL_SEL_STAT;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerCameraPos(playerid, x, y, z + 40.0);

	GetXYInFrontOfPlayer(playerid, x, y, 100.0);

	SetPlayerCameraLookAt(playerid, x, y, z + 5.0);

	TogglePlayerControllable(playerid, 0);

	gPlayerTimers[playerid] = SetTimerEx("WorldSelect", 200, 1, "i", playerid);

	GameTextForPlayer(playerid, "WorldSelect", 1500, 3);

	return true;
}
#endif

#if VEHI_SELECT == true

dcmd_v(playerid, params[])
{
	new
		idx,
		iString[ 128 ];

	if ( gPlayerStatus[ playerid ] != 0 )
	{
		format				( iString, 128, "[ERROR]: You are already using \"%s\".", aSelNames[ gPlayerStatus[ playerid ] - 1 ] );
		SendClientMessage	( playerid, COLOR_RED, iString );

		return true;
	}

	if ( params[ 0 ] == '\0' )	// Same effect as a !strlen check.
		return SendClientMessage( playerid, COLOR_RED, "[USAGE]: /v MODELID/NAME or /vehicle MODELID/NAME" );

	//***************
	// Fix by Mike! *
	//***************

	idx = GetVehicleModelIDFromName( params );

	if( idx == -1 )
	{
		idx = strval(iString);

		if ( idx < MIN_VEHI_ID || idx > MAX_VEHI_ID )
			return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid MODELID/NAME");
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:a;

	GetPlayerPos(playerid, x, y, z);
	GetXYInFrontOfPlayer(playerid, x, y, VEHI_DIS);
	GetPlayerFacingAngle(playerid, a);

	curPlayerVehM[playerid] = idx;

	curPlayerVehI[playerid] = CreateVehicle(idx, x, y, z + 2.0, a + 90.0, -1, -1, 5000);
	LinkVehicleToInterior(curPlayerVehI[playerid], GetPlayerInterior(playerid));

 	curServerVehP[curPlayerVehI[playerid]][spawn] 	= true;
	curServerVehP[curPlayerVehI[playerid]][vmodel]	= idx;
	curServerVehP[curPlayerVehI[playerid]][vInt]    = GetPlayerInterior(playerid);

	format(iString, 128, "[SUCCESS]: Spawned a \"%s\" (MODELID: %d, VEHICLEID: %d)", aVehicleNames[idx - MIN_VEHI_ID], idx, curPlayerVehI[playerid]);

	SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}

dcmd_vehicle(playerid, params[])
	return dcmd_v(playerid, params);

dcmd_vsel(playerid, params[])
{
	// /vsel allows players to select a vehicle using playerkeys.
	#pragma unused params

	new cString[128];

	if (gPlayerStatus[playerid] != 0) {
		format(cString, 128, "[ERROR]: You are already using \"%s\".", aSelNames[gPlayerStatus[playerid] - 1]);
		SendClientMessage(playerid, COLOR_RED, cString);
		return true;
	}

	new Float:x, Float:y, Float:z, Float:a;

	gPlayerStatus[playerid] = VEHI_SEL_STAT;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerCameraPos(playerid, x, y, z + 3.0);

	GetXYInFrontOfPlayer(playerid, x, y, VEHI_DIS);
	SetPlayerCameraLookAt(playerid, x, y, z);

	TogglePlayerControllable(playerid, 0);

	GetPlayerFacingAngle(playerid, a);

	curPlayerVehI[playerid] = CreateVehicle(curPlayerVehM[playerid], x, y, z + 2.0, a + 90.0, -1, -1, 5000);
	printf( "vsel vehicle start id = %d", curPlayerVehI[playerid] );

	LinkVehicleToInterior(curPlayerVehI[playerid], GetPlayerInterior(playerid));

 	curServerVehP[curPlayerVehI[playerid]][spawn] 	= true;
	curServerVehP[curPlayerVehI[playerid]][vmodel]	= curPlayerVehM[playerid];
	curServerVehP[curPlayerVehI[playerid]][vInt]    = GetPlayerInterior(playerid);

	gPlayerTimers[playerid] = SetTimerEx("VehicleSelect", 200, 1, "i", playerid);

	return true;
}

#endif

#if SKIN_SELECT == true

dcmd_ssel(playerid, params[])
{
	// /ssel allows players to select a skin using playerkeys.
	#pragma unused params

	new cString[128];

	if (gPlayerStatus[playerid] != 0) {
		format(cString, 128, "[ERROR]: You are already using \"%s\".", aSelNames[gPlayerStatus[playerid] - 1]);
		SendClientMessage(playerid, COLOR_RED, cString);
		return true;
	}

	new Float:x, Float:y, Float:z;

	gPlayerStatus[playerid] = SKIN_SEL_STAT;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerCameraLookAt(playerid, x, y, z);

	GetXYInFrontOfPlayer(playerid, x, y, 3.5);
	SetPlayerCameraPos(playerid, x, y, z);

	TogglePlayerControllable(playerid, 0);

	gPlayerTimers[playerid] = SetTimerEx("SkinSelect", 200, 1, "i", playerid);

	return true;
}

dcmd_s(playerid, params[])
{
    // /s SKINID allows players to directly select a skin using it's ID.
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /s SKINID");
	    return true;
	}

	idx = strval(iString);

	if (IsInvalidSkin(idx) || idx < MIN_SKIN_ID || idx > MAX_SKIN_ID) {
	    SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid SKINID");
	    return true;
	}

	SetPlayerSkin(playerid, idx);
	curPlayerSkin[playerid] = idx;
	format(iString, 128, "[SUCCESS]: Changed skin to SKINID %d", idx);

	SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}

dcmd_skin(playerid, params[])
{
	dcmd_s(playerid, params);

	return true;
}

#endif

#if MISCEL_CMDS == true
dcmd_goto(playerid, params[])
{
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /goto PLAYERID (X_OFFSET Y_OFFSET Z_OFFSET)");
	    return true;
	}

	new ID = strval(iString);

	if (!IsPlayerConnected(ID)) {
	    SendClientMessage(playerid, COLOR_RED, "[ERROR]: Not connected PLAYERID.");
	    return true;
	}

	new Float:X, Float:Y, Float:Z;
	new Interior = GetPlayerInterior(ID);

	GetPlayerPos(ID, X, Y, Z);

	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    GetXYInFrontOfPlayer(ID, X, Y, 1.5);
	    SetPlayerInterior(playerid, Interior);
		SetPlayerPos(playerid, X, Y, Z);

		GetPlayerName(ID, iString, 128);
		format(iString, 128, "[SUCCESS]: You have warped to %s (ID: %d).", iString, ID);
		SendClientMessage(playerid, COLOR_GREEN, iString);

	    return true;
	}

	X += floatstr(iString);
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    goto fwarpto;
	}

	Y += floatstr(iString);
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    goto fwarpto;
	}

	Z += floatstr(iString);

	fwarpto:

	new pVID = GetPlayerVehicleID( playerid );

	if ( pVID )
	{
	    SetVehiclePos( pVID, X, Y, Z );
	    LinkVehicleToInterior( pVID, Interior );
	}
	else
	{
		SetPlayerPos( playerid, X, Y, Z);
	}

	SetPlayerInterior( playerid, Interior);

	GetPlayerName(ID, iString, 128);
	format(iString, 128, "[SUCCESS]: You have warped to %s (ID: %d).", iString, ID);
	SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}

dcmd_warpto(playerid, params[])
{
	dcmd_goto(playerid, params);

	return true;
}

dcmd_setloc(playerid, params[])
{
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /setloc X Y Z INTERIOR");
	    return true;
	}

	new Float:X, Float:Y, Float:Z;
	new Interior;

	X = floatstr(iString);
	Y = floatstr(strtok(params,idx));
	Z = floatstr(strtok(params,idx));
	Interior = strval(strtok(params,idx));

    new pVID = GetPlayerVehicleID( playerid );

	if ( pVID )
	{
	    SetVehiclePos( pVID, X, Y, Z );
	    LinkVehicleToInterior( pVID, Interior );
	}
	else
	{
		SetPlayerPos( playerid, X, Y, Z );
	}

	SetPlayerInterior(playerid, Interior);

	return true;


}

dcmd_bring(playerid, params[])
{
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /bring PLAYERID (X_OFFSET Y_OFFSET Z_OFFSET)");
	    return true;
	}

	new ID = strval(iString);

	if (!IsPlayerConnected(ID)) {
	    SendClientMessage(playerid, COLOR_RED, "[ERROR]: Not connected PLAYERID.");
	    return true;
	}

	new Float:X, Float:Y, Float:Z;
	new Interior = GetPlayerInterior(playerid);

	GetPlayerPos(playerid, X, Y, Z);

	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    GetXYInFrontOfPlayer(playerid, X, Y, 1.5);
	    SetPlayerInterior(ID, Interior);
		SetPlayerPos(ID, X, Y, Z);

		GetPlayerName(ID, iString, 128);
		format(iString, 128, "[SUCCESS]: You have brought %s (ID: %d) to you.", iString, ID);
		SendClientMessage(playerid, COLOR_GREEN, iString);

	    return true;
	}

	X += floatstr(iString);
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    goto fbring;
	}

	Y += floatstr(iString);
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    goto fbring;
	}

	Z += floatstr(iString);

	fbring:

	new pVID = GetPlayerVehicleID( ID );

	if ( pVID )
	{
	    SetVehiclePos( pVID, X, Y, Z );
	    LinkVehicleToInterior( pVID, Interior );
	}
	else
	{
		SetPlayerPos( ID, X, Y, Z );
	}

	SetPlayerInterior(ID, Interior);

	GetPlayerName(ID, iString, 128);
	format(iString, 128, "[SUCCESS]: You have brought %s (ID: %d) to you.", iString, ID);
	SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}

dcmd_weapon(playerid, params[])
{
	dcmd_w2(playerid, params);

	return true;
}

dcmd_w2(playerid, params[])
{
	new idx, iString[128];
	iString = strtok(params, idx);

	if (!strlen(iString)) {
	    SendClientMessage(playerid, COLOR_RED, "[USAGE]: /w2 WEAPONID/NAME (AMMO) or /weapon WEAPONID/NAME (AMMO)");
	    return true;
	}

	new weaponid = GetWeaponModelIDFromName(iString);

	if (weaponid == -1) {
		weaponid = strval(iString);
		if (weaponid < 0 || weaponid > 47) {
	    	SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid WEAPONID/NAME");
	    	return true;
		}
	}

	if (!strlen(params[idx+1])) {
	    GivePlayerWeapon(playerid, weaponid, 500);

	    format(iString, 128, "[SUCCESS]: You were given weapon %s (ID: %d) with 500 ammo.", aWeaponNames[weaponid], weaponid);
	    SendClientMessage(playerid, COLOR_GREEN, iString);

	    return true;
	}

	idx = strval(params[idx+1]);

    GivePlayerWeapon(playerid, weaponid, idx);

    format(iString, 128, "[SUCCESS]: You were given weapon %s (ID: %d) with %d ammo.", aWeaponNames[weaponid], weaponid, idx);
    SendClientMessage(playerid, COLOR_GREEN, iString);

	return true;
}
#endif

public OnFilterScriptInit()
{
	print("\n  *********************\n  * SA:MP DEBUG 0.2   *");
	print("  * By Simon Campbell *\n  *********************");
	printf("  * Version: %s      *\n  *********************", DEBUG_VERSION);
	print("  * -- LOADED         *\n  *********************\n");

	for ( new i = 0; i < MAX_PLAYERS; i++ )
	{
		curPlayerObjM[ i ][ OBJ_MDL ] = MIN_OBJE_ID;
		pObjectRate[ i ][ OBJ_RATE_ROT ] = 1.0;
		pObjectRate[ i ][ OBJ_RATE_MOVE ] = 1.0;
	}

}

public OnFilterScriptExit()
{
	print("\n  *********************\n  * SA:MP DEBUG 0.2   *");
	print("  * -- SHUTDOWN       *\n  *********************\n");
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	#if ADMINS_ONLY == true
	if(IsPlayerAdmin(playerid)) {
	#endif

	#if SKIN_SELECT == true
	dcmd(s, 1, cmdtext);
	dcmd(ssel, 4, cmdtext);
	dcmd(skin, 4, cmdtext);
	#endif

	#if VEHI_SELECT == true
	dcmd(v, 1, cmdtext);
	dcmd(vsel, 4, cmdtext);
	dcmd(vehicle, 7, cmdtext);
	#endif

	#if WORL_SELECT == true
	dcmd(w, 1, cmdtext);
	dcmd(t, 1, cmdtext);
	dcmd(g, 1, cmdtext);
	dcmd(wsel, 4, cmdtext);
	dcmd(time, 4, cmdtext);
	dcmd(weather, 7, cmdtext);
	dcmd(gravity, 7, cmdtext);
	#endif

	#if MISCEL_CMDS == true
	dcmd(w2, 2, cmdtext);
	dcmd(goto, 4, cmdtext);
	dcmd(bring, 5, cmdtext);
	dcmd(warpto, 6, cmdtext);
	dcmd(weapon, 6, cmdtext);
	dcmd(setloc, 6, cmdtext);
	#endif

	#if CAME_SELECT == true
	dcmd(csel, 4, cmdtext);
	dcmd(camera, 6, cmdtext);
	#endif

	dcmd(osel, 4, cmdtext);
	dcmd(object, 6, cmdtext);
	dcmd(debug, 5, cmdtext);

	#if ADMINS_ONLY == true
	}
	#endif

	return 0;
}

public OnPlayerDisconnect(playerid,reason)
{
	KillTimer(gPlayerTimers[playerid]);

	gPlayerStatus[playerid] = 0;
	gPlayerTimers[playerid] = 0;

	curPlayerSkin[playerid] = MIN_SKIN_ID; // Current Player Skin ID
	curPlayerVehM[playerid] = MIN_VEHI_ID; // Current Player Vehicle ID
	curPlayerVehI[playerid] = -1;

	return 0;
}

public OnPlayerConnect(playerid)
{
    curPlayerCamD[playerid][CMODE] = CMODE_A;
    curPlayerCamD[playerid][RATE]  = 2.0;

	return 0;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
	#if ADMINS_ONLY == true
	if (IsPlayerAdmin(playerid)) {
	#endif
	SetPlayerPosFindZ(playerid, fX, fY, fZ);
	#if ADMINS_ONLY == true
	}
	#endif
}


//==============================================================================

#if WORL_SELECT == true
public WorldSelect(playerid)
{   // Created by Simon
	/*
	// Make sure the player is not in world selection before continuing
	if (gPlayerStatus[playerid] != WORL_SEL_STAT) {
		KillTimer(skinTimerID[playerid]);
        return;
	}
	*/

	new keys, updown, leftright;

    GetPlayerKeys(playerid, keys, updown, leftright);

	new cString[128];

	// Right key increases World Time
	if (leftright == KEY_RIGHT) {
		if(gWorldStatus[0] == MAX_TIME_ID) {
			gWorldStatus[0] = MIN_TIME_ID;
		}
		else {
			gWorldStatus[0]++;
		}
		format(cString, 128, "World Time: %d~n~Weather ID: %d", gWorldStatus[0], gWorldStatus[1]);
    	GameTextForPlayer(playerid, cString, 1500, 3);
		SetWorldTime(gWorldStatus[0]);
	}

	// Left key decreases World Time
	if (leftright == KEY_LEFT) {
	    if(gWorldStatus[0] == MIN_TIME_ID) {
	        gWorldStatus[0] = MAX_TIME_ID;
	    }
	    else {
	        gWorldStatus[0]--;
	    }
		format(cString, 128, "World Time: %d~n~Weather ID: %d", gWorldStatus[0], gWorldStatus[1]);
    	GameTextForPlayer(playerid, cString, 1500, 3);
		SetWorldTime(gWorldStatus[0]);
	}

	// Up key increases Weather ID
	if(updown == KEY_UP) {
		if(gWorldStatus[1] == MAX_WEAT_ID) {
			gWorldStatus[1] = MIN_WEAT_ID;
		}
		else {
		        gWorldStatus[1]++;
		}
		format(cString, 128, "World Time: %d~n~Weather ID: %d", gWorldStatus[0], gWorldStatus[1]);
    	GameTextForPlayer(playerid, cString, 1500, 3);
		SetWeather(gWorldStatus[1]);
	}

	// Down key decreases Weather ID
	if(updown == KEY_DOWN) {
		if(gWorldStatus[1] == MIN_WEAT_ID) {
			gWorldStatus[1] = MAX_WEAT_ID;
		}
		else {
		        gWorldStatus[1]--;
		}
		format(cString, 128, "World Time: %d~n~Weather ID: %d", gWorldStatus[0], gWorldStatus[1]);
    	GameTextForPlayer(playerid, cString, 1500, 3);
		SetWeather(gWorldStatus[1]);
	}

	// Action key exits WorldSelection
	if(keys & KEY_ACTION) {
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, 1);

		format(cString, 128, "[SUCCESS]: Time changed to %d hours and weather changed to WEATHERID %d", gWorldStatus[0], gWorldStatus[1]);
		SendClientMessage(playerid, COLOR_GREEN, cString);

		new File:F_WORLD = fopen("TIME-WEATHER.txt", io_append);

		if(F_WORLD) {
		    new h, m, s, Y, M, D;

			getdate(Y, M, D);
			gettime(h, m, s);

			format(cString, 128, "// %d-%d-%d @ %d:%d:%d\r\nSetWeather(%d);\r\nSetWorldTime(%d);\r\n", D, M, Y, h, m, s);

			fwrite(F_WORLD, cString);
			fclose(F_WORLD);
			printf("\n%s\n",cString);
		}
		else {
			print("Failed to create the file \"TIME-WEATHER.txt\".\n");
		}

		gPlayerStatus[playerid] = 0;
		KillTimer(gPlayerTimers[playerid]);

		return;
	}
}

#endif

#if SKIN_SELECT == true
public SkinSelect(playerid)
{   // Created by Simon
	/*
	// Make sure the player is not in skin selection before continuing
	if (gPlayerStatus[playerid] != SKIN_SEL_STAT) {
		KillTimer(skinTimerID[playerid]);
        return;
	}
	*/

	new keys, updown, leftright;

    GetPlayerKeys(playerid, keys, updown, leftright);

	new cString[128];

	// Right key increases Skin ID
	if (leftright == KEY_RIGHT) {
		if(curPlayerSkin[playerid] == MAX_SKIN_ID) {
			curPlayerSkin[playerid] = MIN_SKIN_ID;
		}
		else {
  			curPlayerSkin[playerid]++;
	    }
		while(IsInvalidSkin(curPlayerSkin[playerid])) {
			curPlayerSkin[playerid]++;
		}

  		format(cString, 128, "Skin ID: %d", curPlayerSkin[playerid]);
    	GameTextForPlayer(playerid, cString, 1500, 3);
	    SetPlayerSkin(playerid, curPlayerSkin[playerid]);
	}

	// Left key decreases Skin ID
	if(leftright == KEY_LEFT) {
 		if(curPlayerSkin[playerid] == MIN_SKIN_ID) {
			curPlayerSkin[playerid] = MAX_SKIN_ID;
		}
		else {
			curPlayerSkin[playerid]--;
		}
		while(IsInvalidSkin(curPlayerSkin[playerid])) {
			curPlayerSkin[playerid]--;
		}

		format(cString, 128, "Skin ID: %d", curPlayerSkin[playerid]);
  		GameTextForPlayer(playerid, cString, 1500, 3);
  		SetPlayerSkin(playerid, curPlayerSkin[playerid]);
	}

	// Action key exits skin selection
	if(keys & KEY_ACTION)
	{
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, 1);

		format(cString, 128, "[SUCCESS]: You have changed to SKINID %d", curPlayerSkin[playerid]);
		SendClientMessage(playerid, COLOR_GREEN, cString);

		gPlayerStatus[playerid] = 0;
		KillTimer(gPlayerTimers[playerid]);
	}
}
#endif

#if CAME_SELECT == true
public CameraSelect(playerid)
{
	// CMODE_A 0	Up/Down = IncreaseZ/DecreaseZ; Left/Right = IncreaseX/DecreaseX; Num4/Num6 = IncreaseY/DecreaseY
	// CMODE_B 1	Up/Down = Rotate Up/Down; Left/Right = Rotate Left/Right; Num4/Num6 = Move Left/Right

	new keys, updown, leftright;

	GetPlayerKeys(playerid, keys, updown, leftright);

	printf("Player (%d) keys = %d, updown = %d, leftright = %d", playerid, keys, updown, leftright);

	if (curPlayerCamD[playerid][CMODE] == CMODE_A)
	{
	    if (leftright == KEY_RIGHT) {
	        curPlayerCamD[playerid][CPOS_X] += curPlayerCamD[playerid][RATE];
	        curPlayerCamD[playerid][CLOO_X] += curPlayerCamD[playerid][RATE];

	        SetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	        SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
	 	}

		if (leftright == KEY_LEFT) {
	        curPlayerCamD[playerid][CPOS_X] -= curPlayerCamD[playerid][RATE];
	        curPlayerCamD[playerid][CLOO_X] -= curPlayerCamD[playerid][RATE];

	        SetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	        SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
		}

		if (updown == KEY_UP) {
			curPlayerCamD[playerid][CPOS_Z] += curPlayerCamD[playerid][RATE];
	        curPlayerCamD[playerid][CLOO_Z] += curPlayerCamD[playerid][RATE];

	        SetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	        SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
		}

		if (updown == KEY_DOWN) {
  			curPlayerCamD[playerid][CPOS_Z] -= curPlayerCamD[playerid][RATE];
	        curPlayerCamD[playerid][CLOO_Z] -= curPlayerCamD[playerid][RATE];

	        SetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	        SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
		}

		if (keys & KEY_ANALOG_RIGHT) {
		    curPlayerCamD[playerid][CPOS_Y] += curPlayerCamD[playerid][RATE];
	        curPlayerCamD[playerid][CLOO_Y] += curPlayerCamD[playerid][RATE];

	        SetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	        SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
		}


		if (keys & KEY_ANALOG_LEFT) {
		    curPlayerCamD[playerid][CPOS_Y] -= curPlayerCamD[playerid][RATE];
	        curPlayerCamD[playerid][CLOO_Y] -= curPlayerCamD[playerid][RATE];

	        SetPlayerPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);

	        SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
		}
	}


	if(curPlayerCamD[playerid][CMODE] == CMODE_B)
	{
	    if (leftright == KEY_RIGHT) {
	        // Rotate Y +
   		}

   		if (leftright == KEY_LEFT) {
   		    // Rotate Y -
   		}

   		if (updown == KEY_UP) {
   		    // Rotate X +
   		}

   		if (updown == KEY_DOWN) {
   		    // Rotate X -
   		}

   		if (keys & KEY_ANALOG_RIGHT) {
   		    // Rotate Z +
   		}

   		if (keys & KEY_ANALOG_LEFT) {
   		    // Rotate Z -
   		}
	}

	if (keys & KEY_ACTION)
	{
	    SetCameraBehindPlayer(playerid);

        new
			File:F_CAMERA = fopen("CAMERA.txt", io_append);

		if( F_CAMERA )
		{
 			new
				cString[512], h, m, s, Y, M, D;

			getdate(Y, M, D);
			gettime(h, m, s);

			format(cString, sizeof( cString ), "// %d-%d-%d @ %d:%d:%d\r\nSetPlayerCameraPos(playerid, %f, %f, %f);\r\nSetPlayerCameraLookAt(playerid, %f, %f, %f);\r\n", D, M, Y, h, m, s,curPlayerCamD[playerid][CPOS_X],curPlayerCamD[playerid][CPOS_Y],curPlayerCamD[playerid][CPOS_Z],curPlayerCamD[playerid][CLOO_X],curPlayerCamD[playerid][CLOO_Y],curPlayerCamD[playerid][CLOO_Z]);

			fwrite(F_CAMERA, cString);
			fclose(F_CAMERA);

			printf("\n%s\n",cString);

			SendClientMessage( playerid, COLOR_GREEN, "Current camera data saved to 'CAMERA.txt'" );
		}
		else
			print("Failed to create the file \"CAMERA.txt\".\n");

		TogglePlayerControllable(playerid, 1);

		KillTimer(gPlayerTimers[playerid]);

		gPlayerStatus[playerid] = 0;
	}
}

#endif

#if VEHI_SELECT == true
public VehicleSelect(playerid)
{
	/*
	// Make sure the player is not in skin selection before continuing
	if (gPlayerStatus[playerid] != VEHI_SEL_STAT) {
		KillTimer(skinTimerID[playerid]);
        return;
	}
	*/

	new keys, updown, leftright;

    GetPlayerKeys(playerid, keys, updown, leftright);

	new cString[128];

	// Right key increases Vehicle MODELID
	if (leftright == KEY_RIGHT) {
		if(curPlayerVehM[playerid] == MAX_VEHI_ID) {
			curPlayerVehM[playerid] = MIN_VEHI_ID;
		}
		else {
  			curPlayerVehM[playerid]++;
	    }

		format(cString, 128, "Model ID: %d~n~Vehicle Name: %s", curPlayerVehM, aVehicleNames[curPlayerVehM[playerid] - MIN_VEHI_ID]);
    	GameTextForPlayer(playerid, cString, 1500, 3);

    	new Float:x, Float:y, Float:z, Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetXYInFrontOfPlayer(playerid, x, y, VEHI_DIS);
		GetPlayerFacingAngle(playerid, a);

		DestroyVehicle(curPlayerVehI[playerid]);
		curServerVehP[curPlayerVehI[playerid]][spawn] 	= false;

		curPlayerVehI[playerid] = CreateVehicle(curPlayerVehM[playerid], x, y, z + 2.0, a + 90.0, -1, -1, 5000);
		printf( "vsel vehicle select id = %d", curPlayerVehI[playerid] );

        LinkVehicleToInterior(curPlayerVehI[playerid], GetPlayerInterior(playerid));

        curServerVehP[curPlayerVehI[playerid]][spawn] 	= true;
		curServerVehP[curPlayerVehI[playerid]][vmodel]	= curPlayerVehM[playerid];
		curServerVehP[curPlayerVehI[playerid]][vInt]    = GetPlayerInterior(playerid);
	}

	// Left key decreases Vehicle MODELID
	if(leftright == KEY_LEFT) {
 		if(curPlayerVehM[playerid] == MIN_VEHI_ID) {
			curPlayerVehM[playerid] = MAX_VEHI_ID;
		}
		else {
			curPlayerVehM[playerid]--;
		}

		format(cString, 128, "Model ID: %d~n~Vehicle Name: %s", curPlayerVehM, aVehicleNames[curPlayerVehM[playerid] - MIN_VEHI_ID]);
  		GameTextForPlayer(playerid, cString, 1500, 3);

   		new Float:x, Float:y, Float:z, Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetXYInFrontOfPlayer(playerid, x, y, VEHI_DIS);
		GetPlayerFacingAngle(playerid, a);

		DestroyVehicle(curPlayerVehI[playerid]);
		curServerVehP[curPlayerVehI[playerid]][spawn] 	= false;

		curPlayerVehI[playerid] = CreateVehicle(curPlayerVehM[playerid], x, y, z + 2.0, a + 90.0, -1, -1, 5000);
		printf( "vsel vehicle select id = %d", curPlayerVehI[playerid] );

		LinkVehicleToInterior(curPlayerVehI[playerid], GetPlayerInterior(playerid));

 		curServerVehP[curPlayerVehI[playerid]][spawn] 	= true;
		curServerVehP[curPlayerVehI[playerid]][vmodel]	= curPlayerVehM[playerid];
		curServerVehP[curPlayerVehI[playerid]][vInt]    = GetPlayerInterior(playerid);
	}

	// Action key exits vehicle selection
	if(keys & KEY_ACTION)
	{
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, 1);

		format(cString, 128, "[SUCCESS]: Spawned a \"%s\" (MODELID: %d, VEHICLEID: %d)", aVehicleNames[curPlayerVehM[playerid] - MIN_VEHI_ID], curPlayerVehM[playerid], curPlayerVehI[playerid]);
		SendClientMessage(playerid, COLOR_GREEN, cString);

		gPlayerStatus[playerid] = 0;
		KillTimer(gPlayerTimers[playerid]);
	}
}
#endif

#if OBJE_SELECT == true
public ObjectSelect( playerid )
{
	new keys, updown, leftright;

    GetPlayerKeys( playerid, keys, updown, leftright );

	new cString[ 128 ];

	switch ( curPlayerObjM[ playerid ][ OBJ_MOD ] )
	{
		case O_MODE_SELECTOR:
		{
			if ( updown == KEY_UP)
			{
				curPlayerObjM[ playerid ][ OBJ_MDL ] += 10;

				if ( curPlayerObjM[ playerid ][ OBJ_MDL ] >= MAX_OBJE_ID )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ] = MIN_OBJE_ID;
				}

				while ( !IsValidModel( curPlayerObjM[ playerid ][ OBJ_MDL ] ) )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ]++;
				}

				DestroyObject( curPlayerObjI[ playerid ] );
				curPlayerObjI[ playerid ] = CreateObject( curPlayerObjM[ playerid ][ OBJ_MDL ], curPlayerObjM[ playerid ][ OBJ_X ],
					curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ],
					curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ]
				);

				format( cString, 128, "Model ID: %d", curPlayerObjM[ playerid ][ OBJ_MDL ] );
  				GameTextForPlayer(playerid, cString, 1500, 3);
			}

			if ( updown == KEY_DOWN)
			{
				curPlayerObjM[ playerid ][ OBJ_MDL ] -= 10;

				if ( curPlayerObjM[ playerid ][ OBJ_MDL ] <= MIN_OBJE_ID )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ] = MAX_OBJE_ID;
				}

				while ( !IsValidModel( curPlayerObjM[ playerid ][ OBJ_MDL ] ) )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ]--;
				}

				DestroyObject( curPlayerObjI[ playerid ] );
				curPlayerObjI[ playerid ] = CreateObject( curPlayerObjM[ playerid ][ OBJ_MDL ], curPlayerObjM[ playerid ][ OBJ_X ],
					curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ],
					curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ]
				);

				format( cString, 128, "Model ID: %d", curPlayerObjM[ playerid ][ OBJ_MDL ] );
  				GameTextForPlayer(playerid, cString, 1500, 3);
			}

			if ( leftright == KEY_LEFT)
			{
				curPlayerObjM[ playerid ][ OBJ_MDL ]--;

				if ( curPlayerObjM[ playerid ][ OBJ_MDL ] <= MIN_OBJE_ID )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ] = MAX_OBJE_ID;
				}

				while ( !IsValidModel( curPlayerObjM[ playerid ][ OBJ_MDL ] ) )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ]--;
				}

				DestroyObject( curPlayerObjI[ playerid ] );
				curPlayerObjI[ playerid ] = CreateObject( curPlayerObjM[ playerid ][ OBJ_MDL ], curPlayerObjM[ playerid ][ OBJ_X ],
					curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ],
					curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ]
				);

				format( cString, 128, "Model ID: %d", curPlayerObjM[ playerid ][ OBJ_MDL ] );
  				GameTextForPlayer(playerid, cString, 1500, 3);
			}

			if ( leftright == KEY_RIGHT)
			{
				curPlayerObjM[ playerid ][ OBJ_MDL ]++;

				if ( curPlayerObjM[ playerid ][ OBJ_MDL ] >= MAX_OBJE_ID )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ] = MIN_OBJE_ID;
				}

				while ( !IsValidModel( curPlayerObjM[ playerid ][ OBJ_MDL ] ) )
				{
					curPlayerObjM[ playerid ][ OBJ_MDL ]++;
				}

				DestroyObject( curPlayerObjI[ playerid ] );
				curPlayerObjI[ playerid ] = CreateObject( curPlayerObjM[ playerid ][ OBJ_MDL ], curPlayerObjM[ playerid ][ OBJ_X ],
					curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ],
					curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ]
				);

				format( cString, 128, "Model ID: %d", curPlayerObjM[ playerid ][ OBJ_MDL ] );
  				GameTextForPlayer(playerid, cString, 1500, 3);
			}
		}

		case O_MODE_MOVER:
		{
			if ( updown == KEY_UP)
			{
				curPlayerObjM[ playerid ][ OBJ_Z ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
				curPlayerCamD[ playerid ][ CPOS_Z ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
	        	curPlayerCamD[ playerid ][ CLOO_Z ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
			}

			if ( updown == KEY_DOWN)
			{
				curPlayerObjM[ playerid ][ OBJ_Z ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
				curPlayerCamD[ playerid ][ CPOS_Z ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
	        	curPlayerCamD[ playerid ][ CLOO_Z ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
			}

			if ( leftright == KEY_LEFT)
			{
				curPlayerObjM[ playerid ][ OBJ_Y ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
				curPlayerCamD[ playerid ][ CPOS_Y ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
	        	curPlayerCamD[ playerid ][ CLOO_Y ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
			}

			if ( leftright == KEY_RIGHT)
			{
				curPlayerObjM[ playerid ][ OBJ_Y ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
				curPlayerCamD[ playerid ][ CPOS_Y ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
	        	curPlayerCamD[ playerid ][ CLOO_Y ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
			}

			if ( keys & KEY_ANALOG_LEFT )
			{
				curPlayerObjM[ playerid ][ OBJ_Y ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
				curPlayerCamD[ playerid ][ CPOS_Y ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
	        	curPlayerCamD[ playerid ][ CLOO_Y ] -= pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
			}

			if ( keys & KEY_ANALOG_LEFT )
			{
				curPlayerObjM[ playerid ][ OBJ_X ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
				curPlayerCamD[ playerid ][ CPOS_X ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
	        	curPlayerCamD[ playerid ][ CLOO_X ] += pObjectRate[ playerid ][ OBJ_RATE_MOVE ];
			}

			SetPlayerPos( playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z] );
			SetObjectPos( curPlayerObjI[ playerid ], curPlayerObjM[ playerid ][ OBJ_X ], curPlayerObjM[ playerid ][ OBJ_Y ], curPlayerObjM[ playerid ][ OBJ_Z ] );
			SetPlayerCameraPos(playerid, curPlayerCamD[playerid][CPOS_X], curPlayerCamD[playerid][CPOS_Y], curPlayerCamD[playerid][CPOS_Z]);
	        SetPlayerCameraLookAt(playerid, curPlayerCamD[playerid][CLOO_X], curPlayerCamD[playerid][CLOO_Y], curPlayerCamD[playerid][CLOO_Z]);
		}

		case O_MODE_ROTATOR:
		{
			if ( updown == KEY_UP)
			{
				curPlayerObjM[ playerid ][ OBJ_RZ ] += pObjectRate[ playerid ][ OBJ_RATE_ROT ];
			}

			if ( updown == KEY_DOWN)
			{
				curPlayerObjM[ playerid ][ OBJ_RZ ] -= pObjectRate[ playerid ][ OBJ_RATE_ROT ];

			}

			if ( leftright == KEY_LEFT)
			{
				curPlayerObjM[ playerid ][ OBJ_RY ] -= pObjectRate[ playerid ][ OBJ_RATE_ROT ];
			}

			if ( leftright == KEY_RIGHT)
			{
				curPlayerObjM[ playerid ][ OBJ_RY ] += pObjectRate[ playerid ][ OBJ_RATE_ROT ];
			}

			if ( keys & KEY_ANALOG_LEFT )
			{
				curPlayerObjM[ playerid ][ OBJ_RY ] -= pObjectRate[ playerid ][ OBJ_RATE_ROT ];
			}

			if ( keys & KEY_ANALOG_LEFT )
			{
				curPlayerObjM[ playerid ][ OBJ_RX ] += pObjectRate[ playerid ][ OBJ_RATE_ROT ];
			}

			SetObjectRot( curPlayerObjI[ playerid ], curPlayerObjM[ playerid ][ OBJ_RX ], curPlayerObjM[ playerid ][ OBJ_RY ], curPlayerObjM[ playerid ][ OBJ_RZ ] );
		}
	}

	if ( keys & KEY_ACTION )
	{
		gPlayerStatus[ playerid ] = 0;
		TogglePlayerControllable( playerid, 1 );
		SetCameraBehindPlayer( playerid );
		KillTimer( gPlayerTimers[playerid] );
	}

}
#endif

IsInvalidSkin(skinid)
{   // Created by Simon
	// Checks whether the skinid parsed is crashable or not.

	#define	MAX_BAD_SKINS   14

	new badSkins[MAX_BAD_SKINS] = {
		3, 4, 5, 6, 8, 42, 65, 74, 86,
		119, 149, 208, 273, 289
	};

	for (new i = 0; i < MAX_BAD_SKINS; i++) {
	    if (skinid == badSkins[i]) return true;
	}

	return false;
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

strtok(const string[], &index)
{   // Created by Compuphase

	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if ( strfind(aVehicleNames[i], vname, true) != -1 )
			return i + MIN_VEHI_ID;
	}
	return -1;
}

GetWeaponModelIDFromName(wname[])
{
    for(new i = 0; i < 48; i++) {
        if (i == 19 || i == 20 || i == 21) continue;
		if (strfind(aWeaponNames[i], wname, true) != -1) {
			return i;
		}
	}
	return -1;
}

IsValidModel(modelid)
{
	// Created by Y_Less.

	static modeldat[] =
	{
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -128,
		-515899393, -134217729, -1, -1, 33554431, -1, -1, -1, -14337, -1, -33,
		127, 0, 0, 0, 0, 0, -8388608, -1, -1, -1, -16385, -1, -1, -1, -1, -1,
		-1, -1, -33, -1, -771751937, -1, -9, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, 33554431, -25, -1, -1, -1, -1, -1, -1,
		-1073676289, -2147483648, 34079999, 2113536, -4825600, -5, -1, -3145729,
		-1, -16777217, -63, -1, -1, -1, -1, -201326593, -1, -1, -1, -1, -1,
		-257, -1, 1073741823, -133122, -1, -1, -65, -1, -1, -1, -1, -1, -1,
		-2146435073, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1073741823, -64, -1,
		-1, -1, -1, -2635777, 134086663, 0, -64, -1, -1, -1, -1, -1, -1, -1,
		-536870927, -131069, -1, -1, -1, -1, -1, -1, -1, -1, -16384, -1,
		-33554433, -1, -1, -1, -1, -1, -1610612737, 524285, -128, -1,
		2080309247, -1, -1, -1114113, -1, -1, -1, 66977343, -524288, -1, -1, -1,
		-1, -2031617, -1, 114687, -256, -1, -4097, -1, -4097, -1, -1,
		1010827263, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -32768, -1, -1, -1, -1, -1,
		2147483647, -33554434, -1, -1, -49153, -1148191169, 2147483647,
		-100781080, -262145, -57, 134217727, -8388608, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1048577, -1, -449, -1017, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1835009, -2049, -1, -1, -1, -1, -1, -1,
		-8193, -1, -536870913, -1, -1, -1, -1, -1, -87041, -1, -1, -1, -1, -1,
		-1, -209860, -1023, -8388609, -2096897, -1, -1048577, -1, -1, -1, -1,
		-1, -1, -897, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1610612737,
		-3073, -28673, -1, -1, -1, -1537, -1, -1, -13, -1, -1, -1, -1, -1985,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1056964609, -1, -1, -1,
		-1, -1, -1, -1, -2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-236716037, -1, -1, -1, -1, -1, -1, -1, -536870913, 3, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -2097153, -2109441, -1, 201326591, -4194304, -1, -1,
		-241, -1, -1, -1, -1, -1, -1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, -32768, -1, -1, -1, -2, -671096835, -1, -8388609, -66323585, -13,
		-1793, -32257, -247809, -1, -1, -513, 16252911, 0, 0, 0, -131072,
		33554383, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 8356095, 0, 0, 0, 0, 0,
		0, -256, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-268435449, -1, -1, -2049, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		92274627, -65536, -2097153, -268435457, 591191935, 1, 0, -16777216, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 127
	};
	if ((modelid >= 0) && ((modelid / 32) < sizeof (modeldat)) && (modeldat[modelid / 32] & (1 << (modelid % 32))))
	{
	    return 1;
	}
	return 0;
}
