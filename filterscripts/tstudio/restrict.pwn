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
    
    if(!(0 < groupid < MAX_GROUPS))
        return SendClientMessage(playerid, STEALTH_YELLOW, sprintf("You can only restrict groups 1-%d", MAX_GROUPS - 1));
    
    Iter_Clear(Restriction[groupid]);
    
    for(new i; i < 10; i++)
    {
        if(players[i] != -1)
            Iter_Add(Restriction[groupid], players[i]);
        else
            break;
    }
    
    gRestricted[groupid] = true;
    
    foreach(new p: Player)
    {
        new bool:cont;
        for(new i; i < 10; i++)
        {
            if(players[i] == p)
            {
                cont = true;
                break;
            }
        }
        if(cont || IsPlayerAdmin(p))
            continue;
        
        if(ObjectData[CurrObject[p]][oGroup] == groupid)
        {
            CurrObject[p] = -1;
            SendClientMessage(p, STEALTH_YELLOW, "You're selected object has been deselected due to a restriction");
        }
        
        new count;
        foreach(new i : Objects)
        {
            if(GroupedObjects[p][i] && ObjectData[i][oGroup] == groupid)
            {
                GroupedObjects[p][i] = false;
                OnUpdateGroup3DText(i);
                UpdateObject3DText(i);
                count++;
            }
        }
        if(count)
        {
            UpdatePlayerGSelText(p);
            SendClientMessage(p, STEALTH_YELLOW, sprintf("%i of your grouped objects have been deselected due to a restriction", count));
        }
    }
    
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
    
    if(!(0 < groupid < MAX_GROUPS))
        return SendClientMessage(playerid, STEALTH_YELLOW, sprintf("You can only restrict groups 1-%d", MAX_GROUPS - 1));
    
    Iter_Clear(Restriction[groupid]);
    gRestricted[groupid] = false;
    
    SendClientMessage(playerid, STEALTH_GREEN, "You've unrestricted this group");
    return 1;
}
