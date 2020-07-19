//-------------------------------------------------
//
// This is an example of using the AttachCameraToObject function
// to create a no-clip flying camera.
//
// h02 2012
//
// SA-MP 0.3e and above
//
//-------------------------------------------------


// Default Move Speed
#define MOVE_SPEED              100.0
#define ACCEL_RATE              0.03
#define ACCEL_MODE              true

// Players Mode
#define CAMERA_MODE_NONE    	0
#define CAMERA_MODE_FLY     	1

// Key state definitions
#define MOVE_FORWARD    		1
#define MOVE_BACK       		2
#define MOVE_LEFT       		3
#define MOVE_RIGHT      		4
#define MOVE_FORWARD_LEFT       5
#define MOVE_FORWARD_RIGHT      6
#define MOVE_BACK_LEFT          7
#define MOVE_BACK_RIGHT         8

// Enumeration for storing data about the player
enum noclipenum
{
	cameramode,
	flyobject,
	mode,
	lrold,
	udold,
	lastmove,
	Float:accelmul,
    
    Float:accelrate,
    Float:maxspeed,
    bool:accel
}
new noclipdata[MAX_PLAYERS][noclipenum];

new bool:FlyMode[MAX_PLAYERS];

#define InFlyMode(%0) FlyMode[%0]

//--------------------------------------------------

tsfunc IsFlyMode(playerid) { return noclipdata[playerid][cameramode]; }


public OnFilterScriptExit()
{
	// If any players are still in edit mode, boot them out before the filterscript unloads
	for(new x; x<MAX_PLAYERS; x++)
	{
		if(noclipdata[x][cameramode] == CAMERA_MODE_FLY) CancelFlyMode(x);
	}

	#if defined FM_OnFilterScriptExit
		FM_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit FM_OnFilterScriptExit
#if defined FM_OnFilterScriptExit
	forward FM_OnFilterScriptExit();
#endif

//--------------------------------------------------

public OnPlayerConnect(playerid)
{
	// Reset the data belonging to this player slot
	noclipdata[playerid][cameramode] 	= CAMERA_MODE_NONE;
	noclipdata[playerid][lrold]	   	 	= 0;
	noclipdata[playerid][udold]   		= 0;
	noclipdata[playerid][mode]   		= 0;
	noclipdata[playerid][lastmove]   	= 0;
	noclipdata[playerid][accelmul]   	= 0.0;
	noclipdata[playerid][accel]   	    = ACCEL_MODE;
	noclipdata[playerid][accelrate]   	= ACCEL_RATE;
	noclipdata[playerid][maxspeed]   	= MOVE_SPEED;
	FlyMode[playerid] = false;

	#if defined FM_OnPlayerConnect
		FM_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect FM_OnPlayerConnect
#if defined FM_OnPlayerConnect
	forward FM_OnPlayerConnect(playerid);
#endif

//--------------------------------------------------

public OnPlayerDisconnect(playerid, reason)
{
	if(noclipdata[playerid][cameramode] == CAMERA_MODE_FLY) CancelFlyMode(playerid);

	#if defined FM_OnPlayerDisconnect
		FM_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect FM_OnPlayerDisconnect
#if defined FM_OnPlayerDisconnect
	forward FM_OnPlayerDisconnect(playerid, reason);
#endif

//--------------------------------------------------

YCMD:flymode(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Toggle flymode.");
		return 1;
	}

    // Place the player in and out of edit mode
	if(FlyMode[playerid]) CancelFlyMode(playerid);
	else StartFlyMode(playerid);
	return 1;
}

YCMD:fmspeed(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Change flymode speed, must be 5-200.");
		return 1;
	}

    new Float:newspeed;
    sscanf(arg, "F(-1.0)", newspeed);
    
    if(newspeed == -1.0)
        newspeed = MOVE_SPEED;
    else if(newspeed < 5.0)
        newspeed = 5.0;
    else if(newspeed > 200.0)
        newspeed = 200.0;
	
	noclipdata[playerid][maxspeed] = newspeed;
    SendClientMessage(playerid, STEALTH_GREEN, sprintf("Flymode max speed set to %0.2f", newspeed));
	return 1;
}

YCMD:fmaccel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Change flymode acceleration rate, must be 0.005 - 0.05");
		return 1;
	}

    new Float:newacc;
    sscanf(arg, "F(-1.0)", newacc);
    
    if(newacc == -1.0)
        newacc = ACCEL_RATE;
    else if(newacc < 0.005)
        newacc = 0.005;
    else if(newacc > 0.05)
        newacc = 0.05;
	
	noclipdata[playerid][accelrate] = newacc;
    SendClientMessage(playerid, STEALTH_GREEN, sprintf("Flymode max speed set to %0.3f", newacc));
	return 1;
}

YCMD:fmtoggle(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Toggle flymode acceleration.");
		return 1;
	}

	noclipdata[playerid][accel] = !noclipdata[playerid][accel];
	SendClientMessage(playerid, STEALTH_GREEN, sprintf("Flymode acceleration toggled %s", noclipdata[playerid][accel] ? ("on") : ("off")));
	return 1;
}

//--------------------------------------------------

public OnPlayerUpdate(playerid)
{
	if(noclipdata[playerid][cameramode] == CAMERA_MODE_FLY)
	{
		new keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);
		

		if(noclipdata[playerid][mode] && (GetTickCount() - noclipdata[playerid][lastmove] > 100))
		{
		    // If the last move was > 100ms ago, process moving the object the players camera is attached to
		    MoveCamera(playerid);
		}

		// Is the players current key state different than their last keystate?
		if(noclipdata[playerid][udold] != ud || noclipdata[playerid][lrold] != lr)
		{
			if((noclipdata[playerid][udold] != 0 || noclipdata[playerid][lrold] != 0) && ud == 0 && lr == 0)
			{   // All keys have been released, stop the object the camera is attached to and reset the acceleration multiplier
				StopDynamicObject(noclipdata[playerid][flyobject]);
				noclipdata[playerid][mode]      = 0;
				noclipdata[playerid][accelmul]  = 0.0;
			}
			else
			{   // Indicates a new key has been pressed

			    // Get the direction the player wants to move as indicated by the keys
				noclipdata[playerid][mode] = GetMoveDirectionFromKeys(ud, lr);

				// Process moving the object the players camera is attached to
				MoveCamera(playerid);
			}
		}
		noclipdata[playerid][udold] = ud; noclipdata[playerid][lrold] = lr; // Store current keys pressed for comparison next update

		#if defined FM_OnPlayerUpdate
			FM_OnPlayerUpdate(playerid);
		#endif
		return 0;
	}

	#if defined FM_OnPlayerUpdate
		FM_OnPlayerUpdate(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate FM_OnPlayerUpdate
#if defined FM_OnPlayerUpdate
	forward FM_OnPlayerUpdate(playerid);
#endif

//--------------------------------------------------

tsfunc GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;
	
    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT; 	// Up & Left key pressed
		else if(ud > 0) direction = MOVE_BACK_LEFT; 	// Back & Left key pressed
		else            direction = MOVE_LEFT;          // Left key pressed
	}
	else if(lr > 0) 	// Right pressed
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;  // Up & Right key pressed
		else if(ud > 0) direction = MOVE_BACK_RIGHT;     // Back & Right key pressed
		else			direction = MOVE_RIGHT;          // Right key pressed
	}
	else if(ud < 0) 	direction = MOVE_FORWARD; 	// Up key pressed
	else if(ud > 0) 	direction = MOVE_BACK;		// Down key pressed
	
	return direction;
}

//--------------------------------------------------

tsfunc MoveCamera(playerid)
{
	new Float:FV[3], Float:CP[3];
	//GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);          // 	Cameras position in space
	GetDynamicObjectPos(noclipdata[playerid][flyobject], CP[0], CP[1], CP[2]);          // 	Cameras position in space
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);  //  Where the camera is looking at

	// Increases the acceleration multiplier the longer the key is held
	if(noclipdata[playerid][accelmul] <= 1.0) noclipdata[playerid][accelmul] += noclipdata[playerid][accelrate];

	// Determine the speed to move the camera based on the acceleration multiplier
	new Float:speed = noclipdata[playerid][maxspeed] * (noclipdata[playerid][accel] ? noclipdata[playerid][accelmul] : 1.0);

	// Calculate the cameras next position based on their current position and the direction their camera is facing
	new Float:X, Float:Y, Float:Z;
	GetNextCameraPosition(noclipdata[playerid][mode], CP, FV, X, Y, Z);
	MoveDynamicObject(noclipdata[playerid][flyobject], X, Y, Z, speed, 0.0, 0.0, 0.0);

    //SendClientMessage(playerid, -1, sprintf("(%0.1f, %0.1f, %0.1f) - (%0.1f, %0.1f, %0.1f) - (%0.1f, %0.1f, %0.1f)", CP[0], CP[1], CP[2], FV[0], FV[1], FV[2], X, Y, Z));
    
	// Store the last time the camera was moved as now
	noclipdata[playerid][lastmove] = GetTickCount();
	return 1;
}

tsfunc SetFlyModePos(playerid, Float:x, Float:y, Float:z)
{
	if(FlyMode[playerid])
	{
		SetDynamicObjectPos(noclipdata[playerid][flyobject], x, y, z);
		noclipdata[playerid][lastmove] = GetTickCount();
		return 1;
	}
	return 0;
}
tsfunc GetFlyModePos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(FlyMode[playerid])
	{
		GetDynamicObjectPos(noclipdata[playerid][flyobject], x, y, z);
		return 1;
	}
	return 0;
}


//--------------------------------------------------

tsfunc GetNextCameraPosition(move_mode, Float:CP[3], Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    // Calculate the cameras next position based on their current position and the direction their camera is facing
    #define OFFSET_X (FV[0]*6000.0)
	#define OFFSET_Y (FV[1]*6000.0)
	#define OFFSET_Z (FV[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = CP[0]+OFFSET_X;
			Y = CP[1]+OFFSET_Y;
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = CP[0]-OFFSET_X;
			Y = CP[1]-OFFSET_Y;
			Z = CP[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = CP[0]-OFFSET_Y;
			Y = CP[1]+OFFSET_X;
			Z = CP[2];
		}
		case MOVE_RIGHT:
		{
			X = CP[0]+OFFSET_Y;
			Y = CP[1]-OFFSET_X;
			Z = CP[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = CP[0]+(-OFFSET_X - OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = CP[0]+(-OFFSET_X + OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = CP[0]+(OFFSET_X  - OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  + OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = CP[0]+(OFFSET_X  + OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  - OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
	}
}
//--------------------------------------------------

tsfunc CancelFlyMode(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerCameraPos(playerid, x, y, z);

	SetTimerEx("DelaySetPos", 2000, false, "ifff", playerid, x, y, z);

	FlyMode[playerid] = false;
	CancelEdit(playerid);
	TogglePlayerSpectating(playerid, false);

	DestroyDynamicObject(noclipdata[playerid][flyobject]);
	noclipdata[playerid][cameramode] = CAMERA_MODE_NONE;
	return 1;
}

forward DelaySetPos(playerid, Float:x, Float:y, Float:z);
public DelaySetPos(playerid, Float:x, Float:y, Float:z) { SetPlayerPos(playerid, x, y, z); }

//--------------------------------------------------

tsfunc StartFlyMode(playerid)
{
	// Create an invisible object for the players camera to be attached to
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	noclipdata[playerid][flyobject] = CreateDynamicObject(19300, X, Y, Z, 0.0, 0.0, 0.0, .playerid = playerid, .streamdistance = 300.0, .drawdistance = 300.0);

	// Place the player in spectating mode so objects will be streamed based on camera location
	TogglePlayerSpectating(playerid, true);
	// Attach the players camera to the created object
	AttachCameraToDynamicObject(playerid, noclipdata[playerid][flyobject]);

	FlyMode[playerid] = true;
	noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;
	return 1;
}

//--------------------------------------------------
