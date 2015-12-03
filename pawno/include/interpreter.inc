#if !defined PARSER_TEXT_CHAR
	#define PARSER_TEXT_CHAR '>'
#endif

#define INTROSPECT_NATIVES
#define INTROSPECT_PLAYER_DATA

#tryinclude "introspect\exec"
#tryinclude "exec"
#tryinclude <introspect\exec>
#tryinclude <exec>

#if !defined RunExpression
	#error "introspect" is required.  Get it here: github.com/oscar-broman/samp-introspect
#endif

public OnPlayerText(playerid, text[])
{
	if (text[0] == PARSER_TEXT_CHAR)
	{
		if (IsPlayerAdmin(playerid))
		{
			printf("Running (%d): %s", playerid, text[1]);
			new
				dest[144],
				token[E_TOKEN];
			token = RunExpression(text[1], strlen(text[1]), playerid);
			RenderToken(dest, token);
			SendClientMessage(playerid, 0x66CD00FF, dest);
		}
		return 0;
	}
	#if defined Parser_OnPlayerText
		return Parser_OnPlayerText(playerid, text);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerText
	#undef OnPlayerText
#else
	#define _ALS_OnPlayerText
#endif

#if defined Parser_OnPlayerText
	forward Parser_OnPlayerText(playerid, text[]);
#endif
