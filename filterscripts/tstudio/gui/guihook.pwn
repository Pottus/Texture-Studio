#include <a_samp>

forward GUIOnPCPDT(playerid, PlayerText:playertextid);

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!GUIOnPCPDT(playerid, playertextid))
	{
		#if defined GH_OnPlayerClickPlayerTextDraw
			return GH_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
		#endif
	}

	return 1;
}
#if defined _ALS_OnPlayerClickPlayerTD
	#undef OnPlayerClickPlayerTextDraw
#else
	#define _ALS_OnPlayerClickPlayerTD
#endif
#define OnPlayerClickPlayerTextDraw GH_OnPlayerClickPlayerTextDraw
#if defined GH_OnPlayerClickPlayerTextDraw
	forward GH_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
#endif
