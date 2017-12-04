#include <a_samp>

main()
{
	print("\n/*-----------------------------------*\\");
	print("|*=====[TS Base GameMode Loaded]=====*|");
	print("\\*-----------------------------------*/\n");
}

new bool:JustConnected[MAX_PLAYERS];

public OnPlayerRequestClass(playerid, classid)
{
	TogglePlayerSpectating(playerid, true);
	if(JustConnected[playerid])
	{
		JustConnected[playerid] = false;
		SetTimerEx("OnPlayerRequestClass", 100, false, "ii", playerid, classid);
	}
	else
	{
		TogglePlayerSpectating(playerid, false);
		SpawnPlayer(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~r~T~w~exture ~r~S~w~tudio ~b~1.9",5000,5);
	JustConnected[playerid] = true;
	return 1;
}

public OnGameModeInit()
{
	SetGameModeText("TS 1.9");
	UsePlayerPedAnims();

	AddPlayerClass(265,1958.3783,1343.1572,15.3746,270.1425,0,0,0,0,-1,-1);

	return 1;
}
