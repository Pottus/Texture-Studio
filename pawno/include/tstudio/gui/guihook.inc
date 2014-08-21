#include <a_samp>

forward GUIOnPCPDT(playerid, PlayerText:playertextid);

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!GUIOnPCPDT(playerid, playertextid))
	{
		OnPlayerClickPlayerTD(playerid, PlayerText:playertextid);
	}
	return 1;
}

#if defined _ALS_OnPlayerClickPlayerTD
	#undef OnPlayerClickPlayerTextDraw
#else
	#define _ALS_OnPlayerClickPlayerTD
#endif
#define OnPlayerClickPlayerTextDraw OnPlayerClickPlayerTD
forward OnPlayerClickPlayerTD(playerid, PlayerText:playertextid);

