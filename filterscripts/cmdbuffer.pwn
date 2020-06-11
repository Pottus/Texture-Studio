/*
#define MAX_COMMAND_BUFFER          (20)

new CommandBuffer[MAX_PLAYERS][MAX_COMMAND_BUFFER][128];

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

new bool:HoldKeyPressed;
*/
OnPlayerKeyStateChangeCMD(playerid,newkeys,oldkeys)
{
	#pragma unused playerid, newkeys, oldkeys
	/*
	if(HoldKeyPressed && PRESSED(KEY_CROUCH) && !isnull(CommandBuffer[playerid][0]))
        Command_ReProcess(playerid, sprintf("/%s", CommandBuffer[playerid][0]), 0); //BroadcastCommand(playerid, CommandBuffer[playerid][0]);
    
	if(PRESSED(KEY_WALK))
        HoldKeyPressed = true;
	else if(RELEASED(KEY_WALK))
        HoldKeyPressed = false;
    */
    
    return 0;
}

public OnPlayerCommandText(playerid, cmdtext[]) 
{
	/*
	//print(cmdtext);
	
	// Make every slot, start from slot 2, take the data from the slot before
	for(new i = MAX_COMMAND_BUFFER - 1; i > 0; --i) {
		//printf("i = %2i 1, CB[i] = %s, CB[i-1] = %s", i, CommandBuffer[playerid][i], CommandBuffer[playerid][i - 1]);
		//CommandBuffer[playerid][i] = CommandBuffer[playerid][i - 1];
		//printf("i = %2i 2, CB[i] = %s, CB[i-1] = %s", i, CommandBuffer[playerid][i], CommandBuffer[playerid][i - 1]);
		format(CommandBuffer[playerid][i], 128, "%s", CommandBuffer[playerid][i - 1]);
	}
	
	// Insert the command and it's parameters into the buffer
	//CommandBuffer[playerid][0][0] = EOS;
	format(CommandBuffer[playerid][0], 128, "%s", cmdtext);
	*/

	#if defined CB_OnPlayerCommandText
		CB_OnPlayerCommandText(playerid, cmdtext);
	#endif
	
	return 0;
}
#if defined _ALS_OnPlayerCommandText
	#undef OnPlayerCommandText
#else
	#define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText CB_OnPlayerCommandText
#if defined CB_OnPlayerCommandText
	forward CB_OnPlayerCommandText(playerid, cmdtext[]);
#endif

public OnPlayerConnect(playerid)
{
	/*
    // Reset the player's buffer
    new tmpCommandBuffer[MAX_COMMAND_BUFFER][128];
    CommandBuffer[playerid] = tmpCommandBuffer;
    */

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
