#include <a_samp>
#include <zcmd>


static ArrestVID[MAX_PLAYERS];
static ArrestSeat[MAX_PLAYERS];

public OnFilterScriptInit()
{
	SetTimer("CheckArrest", 50, true);


}


forward CheckArrest();
public CheckArrest()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(ArrestVID[i] > 0 && !GetPlayerVehicleID(i)) PutPlayerInVehicle(i, ArrestVID[i], ArrestSeat[i]);
	}

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    ArrestVID[playerid] = 0;
    ArrestSeat[playerid] = -1;
	return 1;
}

CMD:arresttest(playerid, arg[])
{
    SetArrested(playerid, GetPlayerVehicleID(playerid), GetPlayerVehicleSeat(playerid));
	return 1;
}


SetArrested(playerid, vid, seat)
{
    ArrestVID[playerid] = vid;
    ArrestSeat[playerid] = seat;
	return 1;
}
