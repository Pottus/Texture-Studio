#define MAX_COMMAND_BUFFER          (20)

new CommandBuffer[MAX_PLAYERS][MAX_COMMAND_BUFFER][128],
    bool:CommandBuffed[MAX_PLAYERS][MAX_COMMAND_BUFFER];

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

new bool:HoldKeyPressed;
OnPlayerKeyStateChangeCMD(playerid,newkeys,oldkeys)
{
	if(HoldKeyPressed && PRESSED(KEY_CROUCH) && !isnull(CommandBuffer[playerid][0]))
        Command_ReProcess(playerid, CommandBuffer[playerid][0], 0); //BroadcastCommand(playerid, CommandBuffer[playerid][0]);
    
	if(PRESSED(KEY_WALK))
        HoldKeyPressed = true;
	else if(RELEASED(KEY_WALK))
        HoldKeyPressed = false;
    
    return 0;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) 
{ 
    if(success)
    {
        // If we need to shift the buffer
        if(CommandBuffed[playerid][MAX_COMMAND_BUFFER - 1])
        {
            // Make every slot, start from slot 2, take the data from the slot before
            for(new i = 1; i < MAX_COMMAND_BUFFER; i++)
                CommandBuffer[playerid][i] = CommandBuffer[playerid][i - 1];
        }
        
        // Insert the command and it's parameters into the buffer
        CommandBuffer[playerid][0][0] = EOS;
        strcat(CommandBuffer[playerid][0], cmdtext);
		
		return 1;
    } 
	return 0;
}  

public OnPlayerConnect(playerid)
{
    // Reset the player's buffer
    new tmpCommandBuffer[MAX_COMMAND_BUFFER][128];
    CommandBuffer[playerid] = tmpCommandBuffer;

	#if defined CB_OnPlayerConnect
		CB_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect CB_OnPlayerConnect
#if defined CB_OnPlayerConnect
	forward CB_OnPlayerConnect(playerid);
#endif
