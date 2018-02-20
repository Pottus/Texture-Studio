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
	GameTextForPlayer(playerid,"~r~T~w~exture ~r~S~w~tudio ~b~1.9~g~d",5000,5);
	JustConnected[playerid] = true;
	return 1;
}

public OnGameModeInit()
{
	SetGameModeText("TS 1.9d");
	UsePlayerPedAnims();

	AddPlayerClass(265,1322.1832,1564.2081,10.8203,300.1425,0,0,0,0,-1,-1);
	//AddPlayerClass(265,1958.3783,1343.1572,15.3746,270.1425,0,0,0,0,-1,-1);

	return 1;
}
