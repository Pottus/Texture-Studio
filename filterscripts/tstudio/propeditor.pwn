
YCMD:oprop(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Edit/view an objects properties.");
		return 1;
	}

    MapOpenCheck();
    EditCheck(playerid);
    NoEditingMode(playerid);

    ShowObjectPropMenu(playerid);

	return 1;
}

static propline[2048];

ShowObjectPropMenu(playerid)
{
	// Init the prop menu
    inline SelectObjProp(spid, sdialogid, sresponse, slistitem, string:stext[])
	{
		#pragma unused slistitem, sdialogid, spid, stext
		if(sresponse)
		{
		    switch(slistitem)
		    {
				// Group
		        case 0:
		        {
				    inline ChangeGroup(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							if(!isnull(etext))
							{
								SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
								new groupid = strval(etext);
								ObjectData[CurrObject[playerid]][oGroup] = groupid;
								OnUpdateGroup3DText(CurrObject[playerid]);
								UpdateObject3DText(CurrObject[playerid]);
								sqlite_ObjGroup(CurrObject[playerid]);
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Group changed");
							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a group!");
							}
							ShowObjectPropMenu(playerid);
						}
					}
					Dialog_ShowCallback(playerid, using inline ChangeGroup, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new group", "Ok", "Cancel");
				}
				
				// Model
				case 1:
				{
				    inline ChangeModel(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							new model = strval(etext);

							SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							ObjectData[CurrObject[playerid]][oModel] = model;
							sqlite_ObjModel(CurrObject[playerid]);
							RebuildObject(CurrObject[playerid]);
							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_YELLOW, "Model changed");
						}
                        ShowObjectPropMenu(playerid);
				    }
				    Dialog_ShowCallback(playerid, using inline ChangeModel, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new model", "Ok", "Cancel");
				}
				
				// Position / Rotation
				case 2..7:
				{

					inline ChangePosition(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
						    if(!isnull(etext))
						    {
	                            SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								if(slistitem == 2)
								{
									SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
									ObjectData[CurrObject[playerid]][oX] = floatstr(etext);
									SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);
									sqlite_UpdateObjectPos(CurrObject[playerid]);
									UpdateObject3DText(CurrObject[playerid]);
									SendClientMessage(playerid, STEALTH_GREEN, "X Updated");
								}
								if(slistitem == 3)
								{
								    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
									ObjectData[CurrObject[playerid]][oY] = floatstr(etext);
									SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);
									sqlite_UpdateObjectPos(CurrObject[playerid]);
									UpdateObject3DText(CurrObject[playerid]);
									SendClientMessage(playerid, STEALTH_GREEN, "Y Updated");
								}
								if(slistitem == 4)
								{
								    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
									ObjectData[CurrObject[playerid]][oZ] = floatstr(etext);
									SetDynamicObjectPos(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oX], ObjectData[CurrObject[playerid]][oY], ObjectData[CurrObject[playerid]][oZ]);
									sqlite_UpdateObjectPos(CurrObject[playerid]);
									UpdateObject3DText(CurrObject[playerid]);
									SendClientMessage(playerid, STEALTH_GREEN, "Z Updated");
								}
								
								if(slistitem == 5)
								{
								    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
									ObjectData[CurrObject[playerid]][oRX] = floatstr(etext);
									SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
									sqlite_UpdateObjectPos(CurrObject[playerid]);
									UpdateObject3DText(CurrObject[playerid]);
									SendClientMessage(playerid, STEALTH_GREEN, "RX Updated");
								}

								if(slistitem == 6)
								{
								    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
									ObjectData[CurrObject[playerid]][oRY] = floatstr(etext);
									SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
									sqlite_UpdateObjectPos(CurrObject[playerid]);
									UpdateObject3DText(CurrObject[playerid]);
									SendClientMessage(playerid, STEALTH_GREEN, "RY Updated");
								}
								
								if(slistitem == 7)
								{
								    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
									ObjectData[CurrObject[playerid]][oRZ] = floatstr(etext);
									SetDynamicObjectRot(ObjectData[CurrObject[playerid]][oID], ObjectData[CurrObject[playerid]][oRX], ObjectData[CurrObject[playerid]][oRY], ObjectData[CurrObject[playerid]][oRZ]);
									sqlite_UpdateObjectPos(CurrObject[playerid]);
									UpdateObject3DText(CurrObject[playerid]);
									SendClientMessage(playerid, STEALTH_GREEN, "RZ Updated");
								}
							}
						}
                        ShowObjectPropMenu(playerid);
				    }
				    
					new line[128];
					if(slistitem == 2) line = "Enter new X position";
					if(slistitem == 3) line = "Enter new Y position";
					if(slistitem == 4) line = "Enter new Z position";
					if(slistitem == 5) line = "Enter new RX position";
					if(slistitem == 6) line = "Enter new RY position";
					if(slistitem == 7) line = "Enter new RZ position";
					
				    Dialog_ShowCallback(playerid, using inline ChangePosition, DIALOG_STYLE_INPUT, "Texture Studio", line, "Ok", "Cancel");
				}
				
				// Materials
				case 8..23:
				{
					inline ChangeMaterial(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
						    new cmd[128];
						    format(cmd, sizeof(cmd), "/mtset %i %s", slistitem - 8, etext);
						    BroadcastCommand(playerid, cmd);
						    
							printf(cmd);
						}
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline ChangeMaterial, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new material index", "Ok", "Cancel");
				}


				// Colors
				case 24..39:
				{
					inline ChangeColor(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
						    new cmd[128];
						    format(cmd, sizeof(cmd), "/mtcolor %i %s", slistitem - 24, etext);
						    BroadcastCommand(playerid, cmd);
						}
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline ChangeColor, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new color use 0xFFFFFFFF format input", "Ok", "Cancel");
				}

				// Use text
				case 40:
				{
					inline PropUseText(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							if(!ObjectData[CurrObject[playerid]][ousetext])
							{
								SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							    ObjectData[CurrObject[playerid]][ousetext] = 1;
							    RebuildObject(CurrObject[playerid]);
								sqlite_ObjUseText(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Text turned on");

							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Text was already on");
							}
						}
						else
						{
							if(ObjectData[CurrObject[playerid]][ousetext])
							{
							    ObjectData[CurrObject[playerid]][ousetext] = 0;
							    RebuildObject(CurrObject[playerid]);
								sqlite_ObjUseText(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Text turned off");
							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Text was already off");
							}
							
						}
						
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline PropUseText, DIALOG_STYLE_MSGBOX, "Texture Studio", "Turn text on/off", "On", "Off");
				}
				
				// Fontface
				case 41:
				{
					inline PropFontFace(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
                            SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
						    ObjectData[CurrObject[playerid]][oFontFace] = elistitem;
						    RebuildObject(CurrObject[playerid]);
							sqlite_ObjFontFace(CurrObject[playerid]);

							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_GREEN, "Font face changed");
						}
						ShowObjectPropMenu(playerid);
				    }
				    new line[512];
					for(new i = 0; i < sizeof(FontNames); i++) format(line, sizeof(line), "%s%s\n", line, FontNames[i]);
                    Dialog_ShowCallback(playerid, using inline PropFontFace, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
				}
				
				// oFontSize
				case 42:
				{
					inline PropFontSize(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
						    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
						    ObjectData[CurrObject[playerid]][oFontSize] = elistitem;
						    RebuildObject(CurrObject[playerid]);
						    sqlite_ObjFontSize(CurrObject[playerid]);

							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_GREEN, "Font size changed");
						}
						ShowObjectPropMenu(playerid);
				    }
				    new line[512];
					for(new i = 0; i < sizeof(FontSizeNames); i++) format(line, sizeof(line), "%s%s\n", line, FontSizeNames[i]);
                    Dialog_ShowCallback(playerid, using inline PropFontSize, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
				}
				
				// Fontbold
				case 43:
				{
					inline PropFontBold(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							if(!ObjectData[CurrObject[playerid]][oFontBold])
							{
							    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							    ObjectData[CurrObject[playerid]][oFontBold] = 1;
							    RebuildObject(CurrObject[playerid]);
							    sqlite_ObjFontBold(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Font bold turned on");

							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Font bold was already on");
							}

						}
						else
						{
							if(ObjectData[CurrObject[playerid]][oFontBold])
							{
							    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							    ObjectData[CurrObject[playerid]][oFontBold] = 0;
							    RebuildObject(CurrObject[playerid]);
								sqlite_ObjFontBold(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Font bold turned off");

							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Font bold was already off");
							}
						}

						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline PropFontBold, DIALOG_STYLE_MSGBOX, "Texture Studio", "Turn bold on/off", "On", "Off");

				}
				
				// Font color
				case 44:
				{
					inline ChangeFontColor(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
                            if(IsHexValue(etext))
                            {
                                SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
	     						sscanf(etext, "h", ObjectData[CurrObject[playerid]][oFontColor]);
							    RebuildObject(CurrObject[playerid]);
							    sqlite_ObjFontColor(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Font color set");
                            }
                            else
                            {
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Invalid hex value");
                            }
						}
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline ChangeFontColor, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new color use 0xFFFFFFFF format input", "Ok", "Cancel");
				}
				
				// Back color
				case 45:
				{
					inline ChangeFontBackColor(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
                            if(IsHexValue(etext))
                            {
                                SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
	     						sscanf(etext, "h", ObjectData[CurrObject[playerid]][oBackColor]);
							    RebuildObject(CurrObject[playerid]);
							    sqlite_ObjBackColor(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Font back color set");
                            }
                            else
                            {
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Invalid hex value");
                            }

						}
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline ChangeFontBackColor, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new color use 0xFFFFFFFF format input", "Ok", "Cancel");
				}
				
				// Alignment
				case 46:
				{
					inline PropFontSize(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
						    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
						    ObjectData[CurrObject[playerid]][oAlignment] = elistitem;
						    RebuildObject(CurrObject[playerid]);
							sqlite_ObjAlignment(CurrObject[playerid]);

							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_GREEN, "Font size changed");
						}
						ShowObjectPropMenu(playerid);
				    }
				    new line[512];
     				for(new i = 0; i < sizeof(AlignmentNames); i++) format(line, sizeof(line), "%s%s\n", line, AlignmentNames[i]);
                    Dialog_ShowCallback(playerid, using inline PropFontSize, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
				}
				
				// Textsize
				case 47:
				{
					inline ChangeTextSize(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							new size = strval(etext);
							
							if(size > 0 && size < 201)
							{
							    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							    ObjectData[CurrObject[playerid]][oTextFontSize] = size;
							    RebuildObject(CurrObject[playerid]);
							    sqlite_ObjFontTextSize(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Text size changed");
							}
						}
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline ChangeTextSize, DIALOG_STYLE_INPUT, "Texture Studio", "A new text size", "Ok", "Cancel");
				
				}
				
				// Text
				case 48:
				{
					inline ChangeTextString(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							if(!isnull(etext))
							{
							    SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							    format(ObjectData[CurrObject[playerid]][oObjectText], MAX_TEXT_LENGTH, "%s", etext);
							    RebuildObject(CurrObject[playerid]);
                                sqlite_ObjObjectText(CurrObject[playerid]);

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Text has been changed");
							}
						}
						ShowObjectPropMenu(playerid);
				    }
                    Dialog_ShowCallback(playerid, using inline ChangeTextString, DIALOG_STYLE_INPUT, "Texture Studio", "A new text string", "Ok", "Cancel");
				}
				
				// Note
				case 49:
				{
				    inline ChangeNote(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							format(ObjectData[CurrObject[playerid]][oNote], 64, "%s", etext);
							sqlite_ObjNote(CurrObject[playerid]);
                            UpdateObject3DText(CurrObject[playerid]);
							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_YELLOW, "Note changed");
						}
                        ShowObjectPropMenu(playerid);
				    }
				    Dialog_ShowCallback(playerid, using inline ChangeNote, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new note", "Ok", "Cancel");
				}
				
				// Draw Distance
				case 50:
				{
				    inline ChangeDD(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_EDIT);
							
                            ObjectData[CurrObject[playerid]][oDD] = floatstr(etext);
                            if(ObjectData[CurrObject[playerid]][oDD] == 0.0) ObjectData[CurrObject[playerid]][oDD] = 300.0;
                            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CurrObject[playerid]][oID], E_STREAMER_DRAW_DISTANCE, ObjectData[CurrObject[playerid]][oDD]);
                            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[CurrObject[playerid]][oID], E_STREAMER_STREAM_DISTANCE, ObjectData[CurrObject[playerid]][oDD]);
							
                            sqlite_UpdateObjectDD(CurrObject[playerid]);
							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_YELLOW, sprintf("Draw distance set to %.2f", ObjectData[CurrObject[playerid]][oDD]));
						}
                        ShowObjectPropMenu(playerid);
				    }
				    Dialog_ShowCallback(playerid, using inline ChangeDD, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new draw distance", "Ok", "Cancel");
				}
		    }
		}
	}
	
	// Create menu
	new index = CurrObject[playerid];

	format(propline, sizeof(propline), "{FFFF00}Group: {00FF00}%i\n{FFFF00}Model: {00FF00}%i\n{FFFF00}x: {00FF00}%f\n{FFFF00}y: {00FF00}%f\n{FFFF00}z: {00FF00}%f\n{FFFF00}rx: {00FF00}%f\n{FFFF00}ry: {00FF00}%f\n{FFFF00}rz: {00FF00}%f\n", ObjectData[index][oGroup], ObjectData[index][oModel],
        ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ]);

	for(new i = 0; i < MAX_MATERIALS; i++) format(propline, sizeof(propline), "%s{FFFF00}Material Index %i: {00FF00}%i\n", propline, i, ObjectData[index][oTexIndex][i]);
	for(new i = 0; i < MAX_MATERIALS; i++) format(propline, sizeof(propline), "%s{FFFF00}Material Color %i: {00FF00}%i\n", propline, i, ObjectData[index][oColorIndex][i]);

	format(propline, sizeof(propline), "%s{FFFF00}Usetext: {00FF00}%i\n{FFFF00}FontFace: {00FF00}%s\n{FFFF00}FontSize: {00FF00}%s\n{FFFF00}FontBold: {00FF00}%i\n{FFFF00}FontColor: {00FF00}%i\n{FFFF00}FontBackColor: {00FF00}%i\n{FFFF00}Alignment: {00FF00}%s\n{FFFF00}FontTextSize: {00FF00}%i\n{FFFF00}Text: {00FF00}%s\n", propline,
        ObjectData[index][ousetext], FontNames[ObjectData[index][oFontFace]], FontSizeNames[ObjectData[index][oFontSize]], ObjectData[index][oFontBold], ObjectData[index][oFontColor],
        ObjectData[index][oBackColor], AlignmentNames[ObjectData[index][oAlignment]], ObjectData[index][oTextFontSize], ObjectData[index][oObjectText]);

	format(propline, sizeof(propline), "%s{FFFF00}Note: {00FF00}%s\n{FFFF00}Draw Distance: {00FF00}%.2f", propline,
        ObjectData[index][oNote], ObjectData[index][oDD]);

	Dialog_ShowCallback(playerid, using inline SelectObjProp, DIALOG_STYLE_LIST, "Texture Studio - Object Property editor", propline, "Ok", "Cancel");

	return 1;
}

YCMD:mprop(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Edit the maps properties.");
		return 1;
	}

    MapOpenCheck();

    ShowMapPropMenu(playerid);

	return 1;
}

ShowMapPropMenu(playerid)
{
	// Init the prop menu
    inline SelectMapProp(spid, sdialogid, sresponse, slistitem, string:stext[])
	{
		#pragma unused slistitem, sdialogid, spid, stext
		if(sresponse)
		{
		    switch(slistitem)
		    {
				// Interior
		        case 0:
		        {
				    inline ChangeInterior(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							if(!isnull(etext) || !isnumeric(etext))
							{
								MapSetting[mInterior] = strval(etext);
                                sqlite_UpdateSettings();
                                
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Interior changed");
							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "You must supply an interior index!");
							}
						}
                        ShowMapPropMenu(playerid);
					}
					Dialog_ShowCallback(playerid, using inline ChangeInterior, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new interior", "Ok", "Cancel");
				}
				
				// Virtual World
				case 1:
				{
				    inline ChangeVW(epid, edialogid, eresponse, elistitem, string:etext[])
				    {
						#pragma unused elistitem, edialogid, epid, etext
						if(eresponse)
						{
							if(!isnull(etext) || !isnumeric(etext))
							{
								MapSetting[mVirtualWorld] = strval(etext);
                                sqlite_UpdateSettings();
                                
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "Virtual world changed");
							}
							else
							{
								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_YELLOW, "You must supply a virtual world index!");
							}
						}
                        ShowMapPropMenu(playerid);
				    }
				    Dialog_ShowCallback(playerid, using inline ChangeVW, DIALOG_STYLE_INPUT, "Texture Studio", "Enter new virtual world", "Ok", "Cancel");
				}
		    }
		}
	}
	
	format(propline, sizeof(propline), "{FFFF00}Interior: {00FF00}%i\n{FFFF00}Virtual World: {00FF00}%i\n",
        MapSetting[mInterior], MapSetting[mVirtualWorld]);

	Dialog_ShowCallback(playerid, using inline SelectMapProp, DIALOG_STYLE_LIST, "Texture Studio - Map Property editor", propline, "Ok", "Cancel");

	return 1;
}


RebuildObject(index)
{
    // Destroy the object
	DestroyDynamicObject(ObjectData[index][oID]);

	// Re-create object
	ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

	// Update the streamer
	foreach(new i : Player)
	{
	    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
	}

	// Update the materials
	UpdateMaterial(index);

	// Update object text
	UpdateObjectText(index);

	return 1;
}



