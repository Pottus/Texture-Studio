YCMD:420carexport(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Export current vehicle to 420 DayZ format.");
		return 1;
	}

	MapOpenCheck();
	
	VehicleCheck(playerid);

	// Ask for a map name
	inline Export420Car(epid, edialogid, eresponse, elistitem, string:etext[])
	{
	    #pragma unused elistitem, edialogid, epid
	    if(eresponse)
	    {
			// Was a map name supplied ?
			if(!isnull(etext))
			{
				new exportcar[256];

				// Check map name length
				if(strlen(etext) >= 20)
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "Choose a shorter car name to export to...");
					return 1;
				}

				// Format the output name
				format(exportcar, sizeof(exportcar), "tstudio/420ExportCars/%s.txt", etext);

				// Map exists ask to remove
			    if(fexist(exportcar))
				{
					inline RemoveCar(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
					{
				        #pragma unused rlistitem, rdialogid, rpid, rtext

						// Remove map and export
				        if(rresponse)
				        {
				            fremove(exportcar);
				            DayzCarExport(playerid, exportcar);
				        }
					}
					Dialog_ShowCallback(playerid, using inline RemoveCar, DIALOG_STYLE_MSGBOX, "Texture Studio (420 Car Export)", "A export exists with this name replace?", "Ok", "Cancel");
				}
				// We can start the export
				else DayzCarExport(playerid, exportcar);
			}
			else
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "You can't export a 420 DayZ car with no name");
				Dialog_ShowCallback(playerid, using inline Export420Car, DIALOG_STYLE_INPUT, "Texture Studio (420 Car Export)", "Enter a export car name", "Ok", "Cancel");
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Export420Car, DIALOG_STYLE_INPUT, "Texture Studio (420 Car Export)", "Enter a export car name", "Ok", "Cancel");
	return 1;
}


/*
	{
		VEHICLE_TYPE_LOCKED, 468, 3, 135, 135, -1, 1, 0, 0, 0, 4.0,
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 3026, 3026, 19477, 18634, 18702, INVALID_OBJECT_ID, INVALID_OBJECT_ID, INVALID_OBJECT_ID, INVALID_OBJECT_ID, INVALID_OBJECT_ID },
		{
			2644, 0, 0, 0, 0, 0,
			2644, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0
		},
		{
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0
		},
		{ 0,0,1,0,0,0,0,0,0,0 },
		{ "none|none|Haze |none|none|none|none|none|none|none" },
		{ 0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,130,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,-16715022,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,25,0,0,0,0,0,0,0 },
		{ -0.100000, 0.089000, 0.085000, -0.128000, 0.108000, 0.0, 0.0, 0.0, 0.0, 0.0 },
		{ 0.298000, 0.298000, 0.629000, -0.349000, -0.759000, 0.0, 0.0, 0.0, 0.0, 0.0 },
		{ -0.008000, -0.008000, -0.717000, 0.200000, -1.429000, 0.0, 0.0, 0.0, 0.0, 0.0 },
		{ 180.000000, 180.000000, -10.000000, 12.899000, 0.000000, 0.0, 0.0, 0.0, 0.0, 0.0 },
		{ 90.000000, 90.000000, 1.000000, 5.000000, 0.000000, 0.0, 0.0, 0.0, 0.0, 0.0 },
		{ 450.000000, 270.000000, 363.299011, 176.000000, 0.000000, 0.0, 0.0, 0.0, 0.0, 0.0 }
	}


*/

static DayzCarExport(playerid, exportcar)
{
	new File:f = f_open(exportcar, io_write);
	
	


}
