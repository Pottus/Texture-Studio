////////////////////////////////////////////////////////////////////////////////
///Object Text editing module //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// This is adapted from 420medit

#include "tstudio\fontdata.pwn"

// Text draws background
new Text:TextEdit_Background_0;
new Text:TextEdit_Background_2;
new Text:TextEdit_Background_3;
new Text:TextEdit_Background_4;
new Text:TextEdit_Background_5;
new Text:TextEdit_Background_6;
new Text:TextEdit_Background_7;
new Text:TextEdit_Background_8;
new Text:TextEdit_Background_9;

// Clickable text draws
new PlayerText:Click_ToggleText[MAX_PLAYERS];
new PlayerText:Click_SetText[MAX_PLAYERS];
new PlayerText:Click_SetFont[MAX_PLAYERS];
new PlayerText:Click_SetFontSize[MAX_PLAYERS];
new PlayerText:Click_ToggleBold[MAX_PLAYERS];
new PlayerText:Click_FontColor[MAX_PLAYERS];
new PlayerText:Click_BackColor[MAX_PLAYERS];
new PlayerText:Click_Alignment[MAX_PLAYERS];
new PlayerText:Click_FontTextSize[MAX_PLAYERS];

static bool:TextEditing[MAX_PLAYERS];

#define IsTextEditing(%0) TextEditing[%0]

// Open text editor
YCMD:text(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Add/edit/remove text on an object. (Only texture slot 0 is supported.)");
		return 1;
	}

    NoEditingMode(playerid);

    MapOpenCheck();
    
    EditCheck(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Started Editing Text");

	// In editing mode
	EditingMode[playerid] = true;
	TextEditing[playerid] = true;

	// Text editing mode
	SetEditMode(playerid, EDIT_MODE_TEXT);
	
	// Update the text editor
    UpdateTextEditor(playerid);

	// Show the text editor
    ShowTextEditorDraw(playerid);

	// Set the current textdraw
	SetCurrTextDraw(playerid, TEXTDRAW_TEXTEDIT);

	// Select textdraw mode
	SelectTextDraw(playerid, 0xD9D919FF);

	return 1;
}

// Update the text editor (when opening)
UpdateTextEditor(playerid)
{
	new index = CurrObject[playerid];

	new tmp[64];

   	// Update active status
	if(GetObjectUseText(index)) PlayerTextDrawSetString(playerid, Click_ToggleText[playerid], "On");
	else PlayerTextDrawSetString(playerid, Click_ToggleText[playerid], "Off");

	// Update text
	if(isnull(GetObjectObjectText(index))) PlayerTextDrawSetString(playerid, Click_SetText[playerid], "None");
	else PlayerTextDrawSetString(playerid, Click_SetText[playerid], "Click To Edit");

	// Update font
	PlayerTextDrawSetString(playerid, Click_SetFont[playerid], FontNames[GetObjectFontFace(index)]);

	// Update font size
	PlayerTextDrawSetString(playerid, Click_SetFontSize[playerid], FontSizeNames[GetObjectFontSize(index)]);

	// Update bold
	if(GetObjectFontBold(index)) PlayerTextDrawSetString(playerid, Click_ToggleBold[playerid], "On");
	else PlayerTextDrawSetString(playerid, Click_ToggleBold[playerid], "Off");

	// Update font color
	valstr(tmp, GetObjectFontColor(index));
	PlayerTextDrawSetString(playerid, Click_FontColor[playerid], tmp);

	// Update back color
	valstr(tmp, GetObjectBackColor(index));
	PlayerTextDrawSetString(playerid, Click_BackColor[playerid], tmp);

	// Update alignment
	if(GetObjectAlignment(index) == 0) PlayerTextDrawSetString(playerid, Click_Alignment[playerid], "Left");
	else if(GetObjectAlignment(index) == 1) PlayerTextDrawSetString(playerid, Click_Alignment[playerid], "Center");
	else if(GetObjectAlignment(index) == 2) PlayerTextDrawSetString(playerid, Click_Alignment[playerid], "Right");

	// Update Text Font Size
	valstr(tmp, GetObjectTextFontSize(index));
	PlayerTextDrawSetString(playerid, Click_FontTextSize[playerid], tmp);
}

// Only closes text editor
forward ClickTextDrawEditText(playerid, Text:clickedid);
public ClickTextDrawEditText(playerid, Text:clickedid)
{
	if (Text:INVALID_TEXT_DRAW == clickedid)
	{
		// Textdraws are now closed
	    ToggleTextDrawOpen(playerid, false);

	    // Player is not in text editing mode anymore
    	SetCurrTextDraw(playerid, TEXTDRAW_NONE);

		// Hide the text editor
	    HideTextEditorDraw(playerid);

		// Cancel textdraw select
		CancelSelectTextDraw(playerid);

		// Click finished processing
		EditingMode[playerid] = false;
		SetEditMode(playerid, EDIT_MODE_NONE);
				
	    return 1;
	}
	return 0;
}

// Player clicked a textdraw option
forward ClickPlayerTextDrawEditText(playerid, PlayerText:playertextid);
public ClickPlayerTextDrawEditText(playerid, PlayerText:playertextid)
{
	new index = CurrObject[playerid];

	// Toggle text off and on
	if(playertextid == Click_ToggleText[playerid])
	{
		if(GetObjectUseText(index))
		{
            SetObjectUseText(index, false);
			PlayerTextDrawSetString(playerid, Click_ToggleText[playerid], "Off");
		}
		else
		{
            SetObjectUseText(index, true);
			PlayerTextDrawSetString(playerid, Click_ToggleText[playerid], "On");
		}

		sqlite_ObjUseText(index);

		// Need to update materials when turning off
		UpdateMaterial(index);
		
        UpdateObjectText(index);

       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);

		return 1;
	}
	
	// Set the text
	else if(playertextid == Click_SetText[playerid])
	{
		inline Response(pid, dialogid, response, listitem, string:text[])
		{
			#pragma unused listitem, dialogid, pid
			if(response)
			{
				if(strlen(text) > 0)
				{
					if(strlen(text) < MAX_TEXT_LENGTH)
					{
						SetObjectObjectText(index, text);
						PlayerTextDrawSetString(playerid, Click_SetText[playerid], "Click To Edit");

                        sqlite_ObjObjectText(index);

						UpdateObjectText(index);

			        	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
					}
					else
					{
					    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					    SendClientMessage(playerid, STEALTH_YELLOW, "Text length is too long");
					}
				}
				else
				{
				    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				    SendClientMessage(playerid, STEALTH_YELLOW, "Text must contain at least 1 character.");
				}
                return 1;
			}
		}
		new tmptext[MAX_TEXT_LENGTH];
		strcat(tmptext, ObjectData[index][oObjectText], MAX_TEXT_LENGTH);
	    FixText(tmptext);


		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Set Material Text", tmptext, "Ok", "Cancel");
		return 1;
	}
	
	
	// Set the font
	else if(playertextid == Click_SetFont[playerid])
	{
		// Increment the font face index
		SetObjectFontFace(index, GetObjectFontFace(index) + 1);
		
		// Too high reset to 0
		if(GetObjectFontFace(index) == sizeof(FontNames)) SetObjectFontFace(index, 0);
        PlayerTextDrawSetString(playerid, Click_SetFont[playerid], FontNames[GetObjectFontFace(index)]);

		sqlite_ObjFontFace(index);
		
		UpdateObjectText(index);

       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
		
        return 1;
	}
	
	// Set font size
	else if(playertextid == Click_SetFontSize[playerid])
	{
		SetObjectFontSize(index, GetObjectFontSize(index) + 1);

		if(GetObjectFontSize(index) == sizeof(FontSizeNames)) SetObjectFontSize(index, 0);
        PlayerTextDrawSetString(playerid, Click_SetFontSize[playerid], FontSizeNames[GetObjectFontSize(index)]);

        sqlite_ObjFontSize(index);
        
        UpdateObjectText(index);

       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
        
		return 1;
	}
	
	// Toggle bold on off
    else if(playertextid == Click_ToggleBold[playerid])
    {
		if(GetObjectFontBold(index))
		{
            SetObjectFontBold(index, false);
			PlayerTextDrawSetString(playerid, Click_ToggleBold[playerid], "Off");
		}
		else
		{
            SetObjectFontBold(index, true);
			PlayerTextDrawSetString(playerid, Click_ToggleBold[playerid], "On");
		}

		sqlite_ObjFontBold(index);
		
		UpdateObjectText(index);

       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
        
		return 1;
    }
    
    	// Set alignment
    else if(playertextid == Click_Alignment[playerid])
	{
		if(GetObjectAlignment(index) < 2) SetObjectAlignment(index, GetObjectAlignment(index) + 1);
		else SetObjectAlignment(index, 0);

		if(GetObjectAlignment(index) == 0) PlayerTextDrawSetString(playerid, Click_Alignment[playerid], "Left");
		else if(GetObjectAlignment(index) == 1) PlayerTextDrawSetString(playerid, Click_Alignment[playerid], "Center");
		else if(GetObjectAlignment(index) == 2) PlayerTextDrawSetString(playerid, Click_Alignment[playerid], "Right");

        sqlite_ObjAlignment(index);
        
        UpdateObjectText(index);

       	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
        
		return 1;
	}
	
	// Set the font text size
 	else if(playertextid == Click_FontTextSize[playerid])
	{
		inline Response(pid, dialogid, response, listitem, string:text[])
		{
			#pragma unused listitem, dialogid, pid
			if(response)
			{
			    new size;
				size = strval(text);
				if(size > 0 && size < 200)
				{
					SetObjectTextFontSize(index, size);
                    PlayerTextDrawSetString(playerid, Click_FontTextSize[playerid], text);
                    
					sqlite_ObjFontTextSize(index);
					
					UpdateObjectText(index);

		        	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
				}
				else
				{
				    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				    SendClientMessage(playerid, STEALTH_YELLOW, "Invalid text font size (0 - 200).");
				}
			}
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Set Font Text Size", "Choose a Font Text Size", "Ok", "Cancel");
		return 1;
	}
	
	// Set the font color
	else if(playertextid == Click_FontColor[playerid])
	{
		inline Response(pid, dialogid, response, listitem, string:text[])
		{
			#pragma unused listitem, dialogid, pid
			if(response)
			{
				new hexcolor;
				if(sscanf(text, "h", hexcolor))
				{
				    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				    SendClientMessage(playerid, STEALTH_YELLOW, "Invalid hex color.");
				}
				else
				{
				    // Set the font color
				    SetFontColor(index, hexcolor);
					    
					// Save the font color
					sqlite_ObjFontColor(index);
					
					UpdateObjectText(index);

		        	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);
						
				    new tmp[12];
					valstr(tmp, hexcolor);
					PlayerTextDrawSetString(playerid, Click_FontColor[playerid], tmp);
				}
			}
		}
        Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Set Font Color", "Enter a hex value for the font color (ARGB) ", "Ok", "Cancel");
		return 1;
	}

	// Set Back color
    else if(playertextid == Click_BackColor[playerid])
    {
		inline Response(pid, dialogid, response, listitem, string:text[])
		{
			#pragma unused listitem, dialogid, pid
			if(response)
			{
				new hexcolor;
				if(sscanf(text, "h", hexcolor))
				{
				    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				    SendClientMessage(playerid, STEALTH_YELLOW, "Invalid hex color.");
				}
				else
				{
				    // Set the font color
				    SetBackColor(index, hexcolor);

					// Save the font color
					sqlite_ObjBackColor(index);

					UpdateObjectText(index);

		        	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);

				    new tmp[12];
					valstr(tmp, hexcolor);
					PlayerTextDrawSetString(playerid, Click_BackColor[playerid], tmp);
				}
			}
		}
        Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Set Back Color", "Enter a hex value for the font color (ARGB) ", "Ok", "Cancel");
		return 1;
    }

	return 0;
}

// Show the editor for a player
ShowTextEditorDraw(playerid)
{
	TextDrawShowForPlayer(playerid,TextEdit_Background_0);
	TextDrawShowForPlayer(playerid,TextEdit_Background_2);
	TextDrawShowForPlayer(playerid,TextEdit_Background_3);
	TextDrawShowForPlayer(playerid,TextEdit_Background_4);
	TextDrawShowForPlayer(playerid,TextEdit_Background_5);
	TextDrawShowForPlayer(playerid,TextEdit_Background_6);
	TextDrawShowForPlayer(playerid,TextEdit_Background_7);
	TextDrawShowForPlayer(playerid,TextEdit_Background_8);
	TextDrawShowForPlayer(playerid,TextEdit_Background_9);

	PlayerTextDrawShow(playerid,Click_ToggleText[playerid]);
	PlayerTextDrawShow(playerid,Click_SetText[playerid]);
	PlayerTextDrawShow(playerid,Click_SetFont[playerid]);
	PlayerTextDrawShow(playerid,Click_SetFontSize[playerid]);
	PlayerTextDrawShow(playerid,Click_ToggleBold[playerid]);
	PlayerTextDrawShow(playerid,Click_FontColor[playerid]);
	PlayerTextDrawShow(playerid,Click_BackColor[playerid]);
	PlayerTextDrawShow(playerid,Click_Alignment[playerid]);
	PlayerTextDrawShow(playerid,Click_FontTextSize[playerid]);

	TextEditing[playerid] = true;

	// Disable the GUI system while using this system
	PlayerSetGUIPaused(playerid, true);
}

// Hide the editor for a player
HideTextEditorDraw(playerid)
{
	TextDrawHideForPlayer(playerid,TextEdit_Background_0);
	TextDrawHideForPlayer(playerid,TextEdit_Background_2);
	TextDrawHideForPlayer(playerid,TextEdit_Background_3);
	TextDrawHideForPlayer(playerid,TextEdit_Background_4);
	TextDrawHideForPlayer(playerid,TextEdit_Background_5);
	TextDrawHideForPlayer(playerid,TextEdit_Background_6);
	TextDrawHideForPlayer(playerid,TextEdit_Background_7);
	TextDrawHideForPlayer(playerid,TextEdit_Background_8);
	TextDrawHideForPlayer(playerid,TextEdit_Background_9);

	PlayerTextDrawHide(playerid,Click_ToggleText[playerid]);
	PlayerTextDrawHide(playerid,Click_SetText[playerid]);
	PlayerTextDrawHide(playerid,Click_SetFont[playerid]);
	PlayerTextDrawHide(playerid,Click_SetFontSize[playerid]);
	PlayerTextDrawHide(playerid,Click_ToggleBold[playerid]);
	PlayerTextDrawHide(playerid,Click_FontColor[playerid]);
	PlayerTextDrawHide(playerid,Click_BackColor[playerid]);
	PlayerTextDrawHide(playerid,Click_Alignment[playerid]);
	PlayerTextDrawHide(playerid,Click_FontTextSize[playerid]);
	
	// Enable the GUI system when complete

	TextEditing[playerid] = false;

	// Put a small pause to prevent any interferring
	SetTimerEx("PlayerSetGUIPaused", 300, false, "ii", playerid, 0);
}


// Initalize Static draws
public OnFilterScriptInit()
{
	TextEdit_Background_0 = TextDrawCreate(10.000000, 150.000000, "Text On:");
	TextDrawBackgroundColor(TextEdit_Background_0, 255);
	TextDrawFont(TextEdit_Background_0, 2);
	TextDrawLetterSize(TextEdit_Background_0, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_0, 16711935);
	TextDrawSetOutline(TextEdit_Background_0, 1);
	TextDrawSetProportional(TextEdit_Background_0, 1);
	TextDrawSetSelectable(TextEdit_Background_0, 0);

	TextEdit_Background_2 = TextDrawCreate(10.000000, 160.000000, "Text:");
	TextDrawBackgroundColor(TextEdit_Background_2, 255);
	TextDrawFont(TextEdit_Background_2, 2);
	TextDrawLetterSize(TextEdit_Background_2, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_2, 16711935);
	TextDrawSetOutline(TextEdit_Background_2, 1);
	TextDrawSetProportional(TextEdit_Background_2, 1);
	TextDrawSetSelectable(TextEdit_Background_2, 0);

	TextEdit_Background_3 = TextDrawCreate(10.000000, 170.000000, "Font:");
	TextDrawBackgroundColor(TextEdit_Background_3, 255);
	TextDrawFont(TextEdit_Background_3, 2);
	TextDrawLetterSize(TextEdit_Background_3, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_3, 16711935);
	TextDrawSetOutline(TextEdit_Background_3, 1);
	TextDrawSetProportional(TextEdit_Background_3, 1);
	TextDrawSetSelectable(TextEdit_Background_3, 0);

	TextEdit_Background_4 = TextDrawCreate(10.000000, 180.000000, "Font Size:");
	TextDrawBackgroundColor(TextEdit_Background_4, 255);
	TextDrawFont(TextEdit_Background_4, 2);
	TextDrawLetterSize(TextEdit_Background_4, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_4, 16711935);
	TextDrawSetOutline(TextEdit_Background_4, 1);
	TextDrawSetProportional(TextEdit_Background_4, 1);
	TextDrawSetSelectable(TextEdit_Background_4, 0);

	TextEdit_Background_5 = TextDrawCreate(10.000000, 190.000000, "Font Bold:");
	TextDrawBackgroundColor(TextEdit_Background_5, 255);
	TextDrawFont(TextEdit_Background_5, 2);
	TextDrawLetterSize(TextEdit_Background_5, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_5, 16711935);
	TextDrawSetOutline(TextEdit_Background_5, 1);
	TextDrawSetProportional(TextEdit_Background_5, 1);
	TextDrawSetSelectable(TextEdit_Background_5, 0);

	TextEdit_Background_6 = TextDrawCreate(10.000000, 200.000000, "Font Color:");
	TextDrawBackgroundColor(TextEdit_Background_6, 255);
	TextDrawFont(TextEdit_Background_6, 2);
	TextDrawLetterSize(TextEdit_Background_6, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_6, 16711935);
	TextDrawSetOutline(TextEdit_Background_6, 1);
	TextDrawSetProportional(TextEdit_Background_6, 1);
	TextDrawSetSelectable(TextEdit_Background_6, 0);

	TextEdit_Background_7 = TextDrawCreate(10.000000, 211.000000, "Back Color:");
	TextDrawBackgroundColor(TextEdit_Background_7, 255);
	TextDrawFont(TextEdit_Background_7, 2);
	TextDrawLetterSize(TextEdit_Background_7, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_7, 16711935);
	TextDrawSetOutline(TextEdit_Background_7, 1);
	TextDrawSetProportional(TextEdit_Background_7, 1);
	TextDrawSetSelectable(TextEdit_Background_7, 0);

	TextEdit_Background_8 = TextDrawCreate(10.000000, 222.000000, "Alignment:");
	TextDrawBackgroundColor(TextEdit_Background_8, 255);
	TextDrawFont(TextEdit_Background_8, 2);
	TextDrawLetterSize(TextEdit_Background_8, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_8, 16711935);
	TextDrawSetOutline(TextEdit_Background_8, 1);
	TextDrawSetProportional(TextEdit_Background_8, 1);
	TextDrawSetSelectable(TextEdit_Background_8, 0);

	TextEdit_Background_9 = TextDrawCreate(10.000000, 233.000000, "Font Text Size:");
	TextDrawBackgroundColor(TextEdit_Background_9, 255);
	TextDrawFont(TextEdit_Background_9, 2);
	TextDrawLetterSize(TextEdit_Background_9, 0.300000, 1.000000);
	TextDrawColor(TextEdit_Background_9, 16711935);
	TextDrawSetOutline(TextEdit_Background_9, 1);
	TextDrawSetProportional(TextEdit_Background_9, 1);
	TextDrawSetSelectable(TextEdit_Background_9, 0);

	foreach(new i : Player)
	{
	    CreatePlayerTextDraws(i);
	
	}

	#if defined TE_OnFilterScriptInit
		TE_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit TE_OnFilterScriptInit
#if defined TE_OnFilterScriptInit
	forward TE_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
	foreach(new i : Player)
	{
		TextDrawDestroy(TextEdit_Background_0);
		TextDrawDestroy(TextEdit_Background_2);
		TextDrawDestroy(TextEdit_Background_3);
		TextDrawDestroy(TextEdit_Background_4);
		TextDrawDestroy(TextEdit_Background_5);
		TextDrawDestroy(TextEdit_Background_6);
		TextDrawDestroy(TextEdit_Background_7);
		TextDrawDestroy(TextEdit_Background_8);
		TextDrawDestroy(TextEdit_Background_9);

		PlayerTextDrawDestroy(i,Click_ToggleText[i]);
		PlayerTextDrawDestroy(i,Click_SetText[i]);
		PlayerTextDrawDestroy(i,Click_SetFont[i]);
		PlayerTextDrawDestroy(i,Click_SetFontSize[i]);
		PlayerTextDrawDestroy(i,Click_ToggleBold[i]);
		PlayerTextDrawDestroy(i,Click_FontColor[i]);
		PlayerTextDrawDestroy(i,Click_BackColor[i]);
		PlayerTextDrawDestroy(i,Click_Alignment[i]);
		PlayerTextDrawDestroy(i,Click_FontTextSize[i]);

	}

	#if defined TE_OnFilterScriptExit
		TE_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit TE_OnFilterScriptExit
#if defined TE_OnFilterScriptExit
	forward TE_OnFilterScriptExit();
#endif


public OnPlayerConnect(playerid)
{
	CreatePlayerTextDraws(playerid);
    TextEditing[playerid] = false;

	#if defined TE_OnPlayerConnect
		TE_OnPlayerConnect(playerid);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect TE_OnPlayerConnect
#if defined TE_OnPlayerConnect
	forward TE_OnPlayerConnect(playerid);
#endif

CreatePlayerTextDraws(playerid)
{
	Click_ToggleText[playerid] = CreatePlayerTextDraw(playerid,141.000000, 150.000000, "Off");
	PlayerTextDrawBackgroundColor(playerid,Click_ToggleText[playerid], 255);
	PlayerTextDrawFont(playerid,Click_ToggleText[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_ToggleText[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_ToggleText[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_ToggleText[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_ToggleText[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_ToggleText[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_ToggleText[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_ToggleText[playerid], 165.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_ToggleText[playerid], 1);

	Click_SetText[playerid] = CreatePlayerTextDraw(playerid,141.000000, 160.000000, "None");
	PlayerTextDrawBackgroundColor(playerid,Click_SetText[playerid], 255);
	PlayerTextDrawFont(playerid,Click_SetText[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_SetText[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_SetText[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_SetText[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_SetText[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_SetText[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_SetText[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_SetText[playerid], 497.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_SetText[playerid], 1);

	Click_SetFont[playerid] = CreatePlayerTextDraw(playerid,141.000000, 170.000000, "Arial");
	PlayerTextDrawBackgroundColor(playerid,Click_SetFont[playerid], 255);
	PlayerTextDrawFont(playerid,Click_SetFont[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_SetFont[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_SetFont[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_SetFont[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_SetFont[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_SetFont[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_SetFont[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_SetFont[playerid], 190.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_SetFont[playerid], 1);

	Click_SetFontSize[playerid] = CreatePlayerTextDraw(playerid,141.000000, 180.000000, "32 x 32");
	PlayerTextDrawBackgroundColor(playerid,Click_SetFontSize[playerid], 255);
	PlayerTextDrawFont(playerid,Click_SetFontSize[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_SetFontSize[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_SetFontSize[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_SetFontSize[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_SetFontSize[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_SetFontSize[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_SetFontSize[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_SetFontSize[playerid], 221.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_SetFontSize[playerid], 1);

	Click_ToggleBold[playerid] = CreatePlayerTextDraw(playerid,141.000000, 190.000000, "Off");
	PlayerTextDrawBackgroundColor(playerid,Click_ToggleBold[playerid], 255);
	PlayerTextDrawFont(playerid,Click_ToggleBold[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_ToggleBold[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_ToggleBold[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_ToggleBold[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_ToggleBold[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_ToggleBold[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_ToggleBold[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_ToggleBold[playerid], 165.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_ToggleBold[playerid], 1);

	Click_FontColor[playerid] = CreatePlayerTextDraw(playerid,141.000000, 200.000000, "255");
	PlayerTextDrawBackgroundColor(playerid,Click_FontColor[playerid], 255);
	PlayerTextDrawFont(playerid,Click_FontColor[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_FontColor[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_FontColor[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_FontColor[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_FontColor[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_FontColor[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_FontColor[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_FontColor[playerid], 190.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_FontColor[playerid], 1);

	Click_BackColor[playerid] = CreatePlayerTextDraw(playerid,141.000000, 210.000000, "255");
	PlayerTextDrawBackgroundColor(playerid,Click_BackColor[playerid], 255);
	PlayerTextDrawFont(playerid,Click_BackColor[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_BackColor[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_BackColor[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_BackColor[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_BackColor[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_BackColor[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_BackColor[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_BackColor[playerid], 190.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_BackColor[playerid], 1);

	Click_Alignment[playerid] = CreatePlayerTextDraw(playerid,141.000000, 220.000000, "Right");
	PlayerTextDrawBackgroundColor(playerid,Click_Alignment[playerid], 255);
	PlayerTextDrawFont(playerid,Click_Alignment[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_Alignment[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_Alignment[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_Alignment[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_Alignment[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_Alignment[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_Alignment[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_Alignment[playerid], 190.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid, Click_Alignment[playerid], 1);

	Click_FontTextSize[playerid] = CreatePlayerTextDraw(playerid,141.000000, 231.000000, "24");
	PlayerTextDrawBackgroundColor(playerid,Click_FontTextSize[playerid], 255);
	PlayerTextDrawFont(playerid,Click_FontTextSize[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Click_FontTextSize[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor(playerid,Click_FontTextSize[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,Click_FontTextSize[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Click_FontTextSize[playerid], 1);
	PlayerTextDrawUseBox(playerid,Click_FontTextSize[playerid], 1);
	PlayerTextDrawBoxColor(playerid,Click_FontTextSize[playerid], 0);
	PlayerTextDrawTextSize(playerid,Click_FontTextSize[playerid], 190.000000, 8.000000);
	PlayerTextDrawSetSelectable(playerid,Click_FontTextSize[playerid], 1);

	return 1;
}

