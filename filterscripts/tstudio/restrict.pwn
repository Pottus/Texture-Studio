new Iterator:Restriction[51]<MAX_PLAYERS>, bool:gRestricted[51] = {false, ...};

// playerid, object index (must be 0 or more than 50, if not it must be in a group with no restrictions, if not then the restriction must allow this player)
#define CanSelectObject(%0,%1) \
    (!(0 <= %1 < MAX_TEXTURE_OBJECTS) || (!gRestricted[ObjectData[%1][oGroup]] || !(0 < ObjectData[%1][oGroup] <= 50) || !Iter_Count(Restriction[ObjectData[%1][oGroup]]) || Iter_Contains(Restriction[ObjectData[%1][oGroup]], playerid) || IsPlayerAdmin(playerid)))
// playerid, group index (it must be a group with no restrictions, if not then the restriction must allow this player)
#define CanSelectGroup(%0,%1) \
    (!(0 < %1 <= 50) || (!gRestricted[%1] || !Iter_Count(Restriction[%1]) || Iter_Contains(Restriction[%1], playerid) || IsPlayerAdmin(playerid)))
    //not in this ? then safely test these

public OnFilterScriptInit()
{
	Iter_Init(Restriction);
    
	#if defined RS_OnFilterScriptInit
		RS_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit RS_OnFilterScriptInit
#if defined RS_OnFilterScriptInit
	forward RS_OnFilterScriptInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
	for(new g; g < 51; g++)
        Iter_Remove(Restriction[g], playerid);
    
	#if defined RS_OnPlayerDisconnect
		RS_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect RS_OnPlayerDisconnect
#if defined RS_OnPlayerDisconnect
	forward RS_OnPlayerDisconnect(playerid, reason);
#endif

YCMD:restrict(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "[RCON ONLY] Prevent a group of objects from being edited.");
		return 1;
	}
    
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Only RCON administrators can use this command");
    
    new groupid, players[10];
    if(sscanf(arg, "iA<i>(-1)[10]", groupid, players))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "/restrict <Group ID> <Optional: Players, up to 10>");
		SendClientMessage(playerid, STEALTH_GREEN, "If no players are listed then only YOU can edit this group");
		return 1;
	}
    
    if(!(0 < groupid <= 50))
        return SendClientMessage(playerid, STEALTH_YELLOW, "You can only restrict groups 1-50");
    
    Iter_Clear(Restriction[groupid]);
    
    for(new i; i < 10; i++)
        Iter_Add(Restriction[groupid], groupid);
    
    gRestricted[groupid] = true;
    
    SendClientMessage(playerid, STEALTH_GREEN, "You've restricted this group");
    return 1;
}

YCMD:unrestrict(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "[RCON ONLY] Allow all players to edit a group.");
		return 1;
	}
    
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Only RCON administrators can use this command");
    
    new groupid;
    if(sscanf(arg, "i", groupid))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "You must provide a group ID");
		return 1;
	}
    
    if(!(0 < groupid <= 50))
        return SendClientMessage(playerid, STEALTH_YELLOW, "You can only restrict groups 1-50");
    
    Iter_Clear(Restriction[groupid]);
    gRestricted[groupid] = false;
    
    SendClientMessage(playerid, STEALTH_GREEN, "You've unrestricted this group");
    return 1;
}
