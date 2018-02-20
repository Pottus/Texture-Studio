public OnPlayerCommandText(playerid, cmdtext[]) 
{
	print(cmdtext);

	#if defined DB_OnPlayerCommandText
		DB_OnPlayerCommandText(playerid, cmdtext);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerCommandText
	#undef OnPlayerCommandText
#else
	#define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText DB_OnPlayerCommandText
#if defined DB_OnPlayerCommandText
	forward DB_OnPlayerCommandText(playerid, cmdtext[]);
#endif
