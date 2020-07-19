#if defined MANGLE
	#define TYPES 11
#else
	#define TYPES 10
#endif

new CommandTypes[][] = {
    "Maps",
    "Objects",
    "Textures",
    "Movement",
    "Selection",
    "Groups",
    "Buildings",
    "Vehicles",
    "Binds",
    "Other"
#if defined MANGLE
    ,"Mangle"
#endif
};

new CommandGroups[][] = {
    "General",
    "Texture Buffer",   // Textures
    "Texture Indexes",  // Textures
    "Texture Themes",   // Textures
    "Delta Movement",   // Movement
    "Pivot",            // Movement
    "Group Movement",   // Groups
    "Group Prefabs",    // Groups
    "Vehicle Objects"   // Vehicles
#if defined MANGLE
    ,"Object",           // Mangle
    "Groups",           // Mangle
    "Group Prefabs"    // Mangle
#endif
};

enum COMMAND_INFO {
    cType, cGroup, cName[32]
}
new Commands[][COMMAND_INFO] = {
    {0, 0, "loadmap"},
    {0, 0, "renamemap"},
    {0, 0, "deletemap"},
    {0, 0, "newmap"},
    {0, 0, "importmap"},
    {0, 0, "export"},
    {0, 0, "exportmap"},
    {0, 0, "exportallmap"},
    {0, 0, "mprop"},
    
    {1, 0, "cobject"},
    {1, 0, "dobject"},
    {1, 0, "robject"},
    {1, 0, "clone"},
    {1, 0, "ogroup"},
    {1, 0, "ogoto"},
    {1, 0, "oswap"},
    {1, 0, "osearch"},
    {1, 0, "osearchex"},
    {1, 0, "oprop"},
    {1, 0, "note"},
    {1, 0, "odd"},
    
    {2, 0, "mtextures"},
    {2, 0, "mtsearch"},
    {2, 0, "ttextures"},
    {2, 0, "stexture"},
    {2, 0, "mtset"},
    {2, 0, "mtsetall"},
    {2, 0, "mtreset"},
    {2, 0, "mtcolor"},
    {2, 0, "mtcolorall"},
    {2, 0, "tsearch"},
    {2, 0, "text"},
    
    {2, 1, "copy"},
    {2, 1, "clear"},
    {2, 1, "paste"},
    
    {2, 2, "settindex"},
    {2, 2, "sindex"},
    {2, 2, "rindex"},
    
    {2, 3, "savetheme"},
    {2, 3, "deletetheme"},
    {2, 3, "loadtheme"},
    
    {3, 0, "editobject"},
    {3, 0, "ox"},
    {3, 0, "oy"},
    {3, 0, "oz"},
    {3, 0, "rx"},
    {3, 0, "ry"},
    {3, 0, "rz"},
    {3, 0, "rotreset"},
    
    {3, 4, "dox"},
    {3, 4, "doy"},
    {3, 4, "doz"},
    {3, 4, "drx"},
    {3, 4, "dry"},
    {3, 4, "drz"},
    
    {3, 5, "pivot"},
    {3, 5, "togpivot"},
    
    {4, 0, "sel"},
    {4, 0, "csel"},
    {4, 0, "lsel"},
    {4, 0, "scsel"},
    {4, 0, "dsel"},
    {4, 0, "dcsel"},
    
    {5, 0, "obmedit"},
    {5, 0, "setgroup"},
    {5, 0, "selectgroup"},
    {5, 0, "gselmodel"},
    {5, 0, "gsel"},
    {5, 0, "gadd"},
    {5, 0, "grem"},
    {5, 0, "gmtset"},
    {5, 0, "gmtcolor"},
    {5, 0, "gclear"},
    {5, 0, "gclone"},
    {5, 0, "gdelete"},
    {5, 0, "gall"},
    {5, 0, "gdd"},
    {5, 0, "0group"},
    
    {5, 6, "editgroup"},
    {5, 6, "gox"},
    {5, 6, "goy"},
    {5, 6, "goz"},
    {5, 6, "grx"},
    {5, 6, "gry"},
    {5, 6, "grz"},
    {5, 6, "ginfront"},
    {5, 6, "ginvert"},
    
    {5, 7, "gaexport"},
    {5, 7, "gprefab"},
    {5, 7, "prefabsetz"},
    {5, 7, "prefab"},
    
    {6, 0, "gtaobjects"},
    {6, 0, "gtashow"},
    {6, 0, "gtahide"},
    {6, 0, "remobject"},
    {6, 0, "rremobject"},
    {6, 0, "swapbuilding"},
    {6, 0, "clonebuilding"},
    
    {7, 0, "tcar"},
    {7, 0, "avmodcar"},
    {7, 0, "avsetspawn"},
    {7, 0, "avdeletecar"},
    {7, 0, "avselectcar"},
    {7, 0, "avnewcar"},
    {7, 0, "avcarcolor"},
    {7, 0, "avpaint"},
    {7, 0, "avsiren"},
    {7, 0, "avrespawn"},
    {7, 0, "avsel"},
    {7, 0, "avclonecar"},
    {7, 0, "avexport"},
    {7, 0, "avexportall"},
    
    {7, 8, "avclone"},
    {7, 8, "avattach"},
    {7, 8, "avdetach"},
    {7, 8, "avox"},
    {7, 8, "avoy"},
    {7, 8, "avoz"},
    {7, 8, "avrx"},
    {7, 8, "avry"},
    {7, 8, "avrz"},
    {7, 8, "avmirror"},
    
    {8, 0, "runbind"},
    //{8, 0, "makebind"},
    {8, 0, "bindeditor"},
    
    {9, 0, "hidetext3d"},
    {9, 0, "showtext3d"},
    {9, 0, "edittext3d"},
    {9, 0, "minfo"},
    {9, 0, "flymode"},
    {9, 0, "fmspeed"},
    {9, 0, "fmaccel"},
    {9, 0, "fmtoggle"},
    {9, 0, "thelp"},
    {9, 0, "undo"},
    {9, 0, "echo"},
    {9, 0, "setspawn"},
    {9, 0, "gotomap"},
    {9, 0, "restrict"},
    {9, 0, "unrestrict"},
    {9, 0, "stopedit"}
#if defined MANGLE
    ,{10, 9, "cobjectsets"},
    {10, 9, "osets"},
    
    {10, 10, "gsets"},
    
    {10, 11, "prefabsets"}
#endif
};

// Command list
YCMD:thelp(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "View a list of all commands and see what they do.");
		return 1;
	}
	
	if(!isnull(arg) && Command_GetPlayerNamed(arg, playerid))
		Command_ReProcess(playerid, arg, true);

	new cmdtypes[256];
	for(new i; i < sizeof(CommandTypes); i++)
		strcat(cmdtypes, sprintf("%s\n", CommandTypes[i]));

	inline SelectCommandType(spid, sdialogid, sresponse, slistitem, string:stext[])
	{
		#pragma unused slistitem, sdialogid, spid, stext
		if(sresponse)
		{
			new cmds[2048];
			
			for(new i, lg = -1; i < sizeof(Commands); i++) {
                if(slistitem == Commands[i][cType]) {
                    if(!isnull(Commands[i][cName])) {
						if(lg != Commands[i][cGroup]) {
							lg = Commands[i][cGroup];
							if(Commands[i][cGroup] == 0)
								strcat(cmds, sprintf("{81181C} - %s{FFFFFF}\n", CommandGroups[lg]));
							else
								strcat(cmds, sprintf(" \n{81181C} - %s{FFFFFF}\n", CommandGroups[lg]));
						}
						strcat(cmds, sprintf("%s\n", Commands[i][cName]));
                    }
                }
			}
            
			inline SelectCommand(epid, edialogid, eresponse, elistitem, string:etext[])
			{
				#pragma unused elistitem, edialogid, epid, etext
				if(eresponse)
				{
					if(Command_GetPlayerNamed(etext, playerid))
					{
						#if defined Y_COMMANDS_NO_IPC
						Command_ReProcess(playerid, etext, 1);
						#else
						Command_OnReceived(OK, playerid, etext);
						#endif
					}
					Dialog_ShowCallback(playerid, using inline SelectCommand, DIALOG_STYLE_LIST, "Texture Studio - Command List", cmds, "Select", "Back");
				}
				else
					Dialog_ShowCallback(playerid, using inline SelectCommandType, DIALOG_STYLE_LIST, "Texture Studio - Command List", cmdtypes, "Select", "Cancel");
			}
			Dialog_ShowCallback(playerid, using inline SelectCommand, DIALOG_STYLE_LIST, "Texture Studio - Command List", cmds, "Select", "Back");
		}
	}
	Dialog_ShowCallback(playerid, using inline SelectCommandType, DIALOG_STYLE_LIST, "Texture Studio - Command List", cmdtypes, "Select", "Cancel");
	return 1;
}
