
#define         OBM_NONE        0

//ROUND
#define         OBM_CIRCLE      1
#define         OBM_SPHERE      2
#define         OBM_SPIRAL      3
#define         OBM_HELIX		4
#define         OBM_CLYINDER    5
#define         OBM_CONE		6
#define         OBM_WHIRL       7
#define         OBM_CIRCLEIN    8
#define         OBM_CIRCLEOUT   9
//NO ROUND
#define			OBM_LINE		10
#define			OBM_RECTANGLE	11
#define			OBM_RECTPRISM	12

#define         OBME_ORIGIN     0
#define         OMBE_ORIENT     1

static const OBMTypes[][] = {
	"Change This!",
	
	//ROUND
	"Objectmetry Circle",
	"Objectmetry Sphere",
	"Objectmetry Spiral",
	"Objectmetry Helix",
	"Objectmetry Cylinder",
	"Objectmetry Cone",
	"Objectmetry Whirl",
	"Objectmetry Circle In",
	"Objectmetry Circle Out",
	
	//NOT ROUND
	"Objectmetry Line",
	"Objectmetry Rectangle",
	"Objectmetry Prism"
};

static const FaceCenterOnOff[][] = { "True", "False" };

static OBMObject[MAX_PLAYERS];

enum pOBMINFO
{
	pOBMType,
	pOBMModel,
	bool:pOBMfacecenter,
	bool:OriginSet,
	Float:pOBMOriginX, Float:pOBMOriginY, Float:pOBMOriginZ,
	Float:pOBMOriginRX, Float:pOBMOriginRY, Float:pOBMOriginRZ,
	Float:pOBMOrientationRX, Float:pOBMOrientationRY, Float:pOBMOrientationRZ,
	
	//Round
	pOBMParts,
	pOBMDegrees,
	Float:pOBMRadius,
	Float:pOBMhsep, //degrees
	Float:pOBMvsep, //degrees

	//Not Round
	Float:pOBMEndX, Float:pOBMEndY, Float:pOBMEndZ,
	Float:pOBMLength, Float:pOBMWidth, Float:pOBMHeight,
	pOBMLSegs, pOBMWSegs, pOBMHSegs,
	bool:pOBMFill
}

static OBMData[MAX_PLAYERS][pOBMINFO];
static Float:OBMOriginSave[MAX_PLAYERS][6];
static Float:OBMOrientationSave[MAX_PLAYERS][3];
static OBMEditMode[MAX_PLAYERS];

public OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    OBMData[i][pOBMParts] = 10;
	    OBMData[i][pOBMDegrees] = 360;
	}

	#if defined OE_OnFilterScriptInit
		OE_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit OE_OnFilterScriptInit
#if defined OE_OnFilterScriptInit
	forward OE_OnFilterScriptInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
    ResetOBMValues(playerid);

	#if defined OE_OnPlayerDisconnect
		OE_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect OE_OnPlayerDisconnect
#if defined OE_OnPlayerDisconnect
	forward OE_OnPlayerDisconnect(playerid, reason);
#endif

YCMD:obmedit(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Create an \"objectmetry\" masterpiece.");
		return 1;
	}

   	NoEditingMode(playerid);

    MapOpenCheck();

    EditingMode[playerid] = true;
    
    SetEditMode(playerid, EDIT_MODE_OBM);
    
	UpdateOBM(playerid);
    OBMEditor(playerid);

	return 1;
}

static ResetOBMValues(playerid)
{
    OBMData[playerid][pOBMType] = 0;
    OBMData[playerid][pOBMModel] = 0;
    OBMData[playerid][pOBMParts] = 10;
    OBMData[playerid][pOBMDegrees] = 360;
    OBMData[playerid][pOBMOriginX] = 0.0;
    OBMData[playerid][pOBMOriginY] = 0.0;
    OBMData[playerid][pOBMOriginZ] = 0.0;
    OBMData[playerid][pOBMOriginRX] = 0.0;
    OBMData[playerid][pOBMOriginRY] = 0.0;
    OBMData[playerid][pOBMOriginRZ] = 0.0;
    OBMData[playerid][pOBMOrientationRX] = 0.0;
    OBMData[playerid][pOBMOrientationRY] = 0.0;
    OBMData[playerid][pOBMOrientationRZ] = 0.0;
    OBMData[playerid][pOBMRadius] = 0.0;
    OBMData[playerid][pOBMhsep] = 0.0;
    OBMData[playerid][pOBMvsep] = 0.0;
    OBMData[playerid][pOBMfacecenter] = false;
    OBMData[playerid][OriginSet] = false;
    OBMData[playerid][pOBMEndX] = 0.0;
    OBMData[playerid][pOBMEndY] = 0.0;
    OBMData[playerid][pOBMEndZ] = 0.0;
    OBMData[playerid][pOBMLength] = 0.0;
    OBMData[playerid][pOBMWidth] = 0.0;
    OBMData[playerid][pOBMHeight] = 0.0;
    OBMData[playerid][pOBMLSegs] = 0;
    OBMData[playerid][pOBMWSegs] = 0;
    OBMData[playerid][pOBMHSegs] = 0;
    OBMData[playerid][pOBMFill] = false;
	return 1;
}

static OBMEditor(playerid)
{
	new line[1024];
	switch(OBMData[playerid][pOBMType])
	{
		case 1 .. 9:
		{
			inline OBMEdit(opid, odialogid, oresponse, olistitem, string:otext[])
			{
				#pragma unused olistitem, odialogid, opid, otext

				if(oresponse)
				{
					switch(olistitem)
					{
						// Set type
						case 0:
						{
							inline OBMType(tpid, tdialogid, tresponse, tlistitem, string:ttext[])
							{
								#pragma unused tlistitem, tdialogid, tpid, ttext
								if(tresponse) OBMData[playerid][pOBMType] = tlistitem;
								OBMEditor(playerid);
								UpdateOBM(playerid);
							}
							line[0] = '\0';
							for(new i = 0; i < sizeof(OBMTypes); i++) format(line, sizeof(line), "%s%s\n", line, OBMTypes[i]);
							Dialog_ShowCallback(playerid, using inline OBMType, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
						}
						
						// Model
						case 1:
						{
							inline OBMModel(mpid, mdialogid, mresponse, mlistitem, string:mtext[])
							{
								#pragma unused mlistitem, mdialogid, mpid, mtext
								if(mresponse)
								{
									new model = strval(mtext);
									OBMData[playerid][pOBMModel] = model;
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMModel, DIALOG_STYLE_INPUT, "Texture Studio", "Select a model", "Ok", "Cancel");
						}
						
						// Parts
						case 2:
						{
							inline OBMParts(ppid, pdialogid, presponse, plistitem, string:ptext[])
							{
								#pragma unused plistitem, pdialogid, ppid, ptext
								if(presponse)
								{
									new parts = strval(ptext);
									if(parts < 1) SendClientMessage(playerid, STEALTH_GREEN, "You must have at least 1 part");
									else if(parts > 1000) SendClientMessage(playerid, STEALTH_GREEN, "Too many parts");
									else
									{
										OBMData[playerid][pOBMParts] = parts;
										UpdateOBM(playerid);
									}
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMParts, DIALOG_STYLE_INPUT, "Texture Studio", "Number of parts", "Ok", "Cancel");
						}
						
						// Degrees
						case 3:
						{
							inline OBMDegrees(degpid, degdialogid, degresponse, deglistitem, string:degtext[])
							{
								#pragma unused deglistitem, degdialogid, degpid, degtext
								if(degresponse)
								{
									new deg = strval(degtext);
									if(deg < 1) SendClientMessage(playerid, STEALTH_GREEN, "You must have at least 1 degree");
									else if(deg > 3600) SendClientMessage(playerid, STEALTH_GREEN, "Excessive degrees");
									else
									{
										OBMData[playerid][pOBMDegrees] = deg;
										UpdateOBM(playerid);
									}
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMDegrees, DIALOG_STYLE_INPUT, "Texture Studio", "Degrees (Integer)", "Ok", "Cancel");
						}


						
						// Horizontal seperation
						case 4:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMhsep] = floatstr(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Horizontal Seperation or Seperation", "Ok", "Cancel");
						}
					
						// Vertical Seperation
						case 5:
						{
							inline OBMVS(vpid, vdialogid, vresponse, vlistitem, string:vtext[])
							{
								#pragma unused vlistitem, vdialogid, vpid, vtext
								if(vresponse)
								{
									OBMData[playerid][pOBMvsep] = floatstr(vtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMVS, DIALOG_STYLE_INPUT, "Texture Studio", "Veritcal Seperation", "Ok", "Cancel");
						}
						
						// Face Center
						case 6:
						{
							inline OBMFaceCenter(fpid, fdialogid, fresponse, flistitem, string:ftext[])
							{
								#pragma unused flistitem, fdialogid, fpid, ftext
								if(fresponse) OBMData[playerid][pOBMfacecenter] = true;
								else OBMData[playerid][pOBMfacecenter] = false;
								UpdateOBM(playerid);
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMFaceCenter, DIALOG_STYLE_MSGBOX, "Texture Studio", "Face Center", "On", "Off");
						}
						
						// OriginX
						case 7:
						{
							inline OBMOX(oxpid, oxdialogid, oxresponse, oxlistitem, string:oxtext[])
							{
								#pragma unused oxlistitem, oxdialogid, oxpid, oxtext
								if(oxresponse)
								{
									OBMData[playerid][pOBMOriginX] = floatstr(oxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOX, DIALOG_STYLE_INPUT, "Texture Studio", "Origin X", "Ok", "Cancel");
						}
						
						// OriginY
						case 8:
						{
							inline OBMOY(oypid, oydialogid, oyresponse, oylistitem, string:oytext[])
							{
								#pragma unused oylistitem, oydialogid, oypid, oytext
								if(oyresponse)
								{
									OBMData[playerid][pOBMOriginY] = floatstr(oytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOY, DIALOG_STYLE_INPUT, "Texture Studio", "Origin Y", "Ok", "Cancel");
						}

						// OriginZ
						case 9:
						{
							inline OBMOZ(ozpid, ozdialogid, ozresponse, ozlistitem, string:oztext[])
							{
								#pragma unused ozlistitem, ozdialogid, ozpid, oztext
								if(ozresponse)
								{
									OBMData[playerid][pOBMOriginZ] = floatstr(oztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOZ, DIALOG_STYLE_INPUT, "Texture Studio", "Origin Z", "Ok", "Cancel");
						}

						// OriginRX
						case 10:
						{
							inline OBMORX(orxpid, orxdialogid, orxresponse, orxlistitem, string:orxtext[])
							{
								#pragma unused orxlistitem, orxdialogid, orxpid, orxtext
								if(orxresponse)
								{
									OBMData[playerid][pOBMOriginRX] = floatstr(orxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORX, DIALOG_STYLE_INPUT, "Texture Studio", "Origin RX", "Ok", "Cancel");


						}

						// OriginRY
						case 11:
						{
							inline OBMORY(orypid, orydialogid, oryresponse, orylistitem, string:orytext[])
							{
								#pragma unused orylistitem, orydialogid, orypid, orytext
								if(oryresponse)
								{
									OBMData[playerid][pOBMOriginRY] = floatstr(orytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORY, DIALOG_STYLE_INPUT, "Texture Studio", "Origin RY", "Ok", "Cancel");
						}

						// OriginRZ
						case 12:
						{
							inline OBMORZ(orzpid, orzdialogid, orzresponse, orzlistitem, string:orztext[])
							{
								#pragma unused orzlistitem, orzdialogid, orzpid, orztext
								if(orzresponse)
								{
									OBMData[playerid][pOBMOriginRZ] = floatstr(orztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORZ, DIALOG_STYLE_INPUT, "Texture Studio", "Origin RZ", "Ok", "Cancel");

						}

						// OrientationRX
						case 13:
						{
							inline OBMORTRX(ortrxpid, ortrxdialogid, ortrxresponse, ortrxlistitem, string:ortrxtext[])
							{
								#pragma unused ortrxlistitem, ortrxdialogid, ortrxpid, ortrxtext
								if(ortrxresponse)
								{
									OBMData[playerid][pOBMOrientationRX] = floatstr(ortrxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORTRX, DIALOG_STYLE_INPUT, "Texture Studio", "Orientation RX", "Ok", "Cancel");
						}

						// OrientationRY
						case 14:
						{
							inline OBMORTRY(ortrypid, ortrydialogid, ortryresponse, ortrylistitem, string:ortrytext[])
							{
								#pragma unused ortrylistitem, ortrydialogid, ortrypid, ortrytext
								if(ortryresponse)
								{
									OBMData[playerid][pOBMOrientationRY] = floatstr(ortrytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORTRY, DIALOG_STYLE_INPUT, "Texture Studio", "Orientation RY", "Ok", "Cancel");
						}

						// OrientationRZ
						case 15:
						{
							inline OBMORTRZ(ortrzpid, ortrzdialogid, ortrzresponse, ortrzlistitem, string:ortrztext[])
							{
								#pragma unused ortrzlistitem, ortrzdialogid, ortrzpid, ortrztext
								if(ortrzresponse)
								{
									OBMData[playerid][pOBMOrientationRZ] = floatstr(ortrztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORTRZ, DIALOG_STYLE_INPUT, "Texture Studio", "Orientation RZ", "Ok", "Cancel");
						}

						// Radius
						case 16:
						{
							inline OBMRadius(rpid, rdialogid, rresponse, rlistitem, string:rtext[])
							{
								#pragma unused rlistitem, rdialogid, rpid, rtext
								if(rresponse)
								{
									OBMData[playerid][pOBMRadius] = floatstr(rtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMRadius, DIALOG_STYLE_INPUT, "Texture Studio", "Radius", "Ok", "Cancel");
						}


						// Set origin
						case 17:
						{
							if(!OBMData[playerid][OriginSet])
							{
								new Float:x, Float:y, Float:z, Float:fa;
								GetPosFaInFrontOfPlayer(playerid, 2.0, x, y, z, fa);
								OBMObject[playerid] = CreateDynamicObject(1974, x, y, z, 0.0, 0.0, 0.0, -1, -1, playerid);
							}
							else OBMObject[playerid] = CreateDynamicObject(1974, OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ], OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ], -1, -1, playerid);

							OBMOriginSave[playerid][0] = OBMData[playerid][pOBMOriginX];
							OBMOriginSave[playerid][1] = OBMData[playerid][pOBMOriginY];
							OBMOriginSave[playerid][2] = OBMData[playerid][pOBMOriginZ];
							OBMOriginSave[playerid][3] = OBMData[playerid][pOBMOriginRX];
							OBMOriginSave[playerid][4] = OBMData[playerid][pOBMOriginRY];
							OBMOriginSave[playerid][5] = OBMData[playerid][pOBMOriginRZ];

							Streamer_SetFloatData(STREAMER_TYPE_OBJECT, OBMObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

							SetDynamicObjectMaterial(OBMObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

							Streamer_Update(playerid);

							EditDynamicObject(playerid, OBMObject[playerid]);

							OBMEditMode[playerid] = OBME_ORIGIN;

							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_GREEN, "Editing your objectmetry origin");
						}
						
						// Set rotation orientation
						case 18:
						{
							if(!OBMData[playerid][OriginSet]) 
							{
								SendClientMessage(playerid, STEALTH_YELLOW, "Please set your origin first");
								OBMEditor(playerid);
							}
							else
							{
								OBMObject[playerid] = CreateDynamicObject(1974, OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ], OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ], -1, -1, playerid);

								OBMOrientationSave[playerid][0] = OBMData[playerid][pOBMOrientationRX];
								OBMOrientationSave[playerid][1] = OBMData[playerid][pOBMOrientationRY];
								OBMOrientationSave[playerid][2] = OBMData[playerid][pOBMOrientationRZ];

								Streamer_SetFloatData(STREAMER_TYPE_OBJECT, OBMObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

								SetDynamicObjectMaterial(OBMObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

								Streamer_Update(playerid);

								EditDynamicObject(playerid, OBMObject[playerid]);

								OBMEditMode[playerid] = OMBE_ORIENT;

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Editing your rotation orientation");
							}
						}

						// Apply objects to map
						case 19:
						{
							inline OBMApply(apid, adialogid, aresponse, alistitem, string:atext[])
							{
								#pragma unused alistitem, adialogid, apid, atext
								if(aresponse)
								{
									ApplyOBM(playerid);
									SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
									SendClientMessage(playerid, STEALTH_GREEN, "Current objectmetry applied to your map");
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMApply, DIALOG_STYLE_MSGBOX, "Texture Studio", "Apply this objectmetry to your map?", "On", "Off");
						}

						// Reset values
						case 20:
						{
							inline OBMReset(epid, edialogid, eresponse, elistitem, string:etext[])
							{
								#pragma unused elistitem, edialogid, epid, etext
								if(eresponse)
								{
									ResetOBMValues(playerid);
									ClearOBMStack(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMReset, DIALOG_STYLE_MSGBOX, "Texture Studio", "Reset all values?", "Ok", "Cancel");
						}
						
						// Hide object stack
						case 21:
						{
							inline OBMHideStack(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse) ClearOBMStack(playerid);
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHideStack, DIALOG_STYLE_MSGBOX, "Texture Studio", "Hide objectmetry?", "Ok", "Cancel");
						}
					}
				}
				else
				{
					EditingMode[playerid] = false;
					SetEditMode(playerid, EDIT_MODE_NONE);
				}
			}
			
			format(line, sizeof(line), "Set Type: %s\nModel: %i\nParts: %i\nDegrees: %i\nHorizontal Seperation: %f\nVertical Seperation: %f\nFace Center: %s\nOriginX: %f\nOriginY: %f\nOriginZ: %f\nOriginRX: %f\nOriginRY: %f\nOriginRZ: %f\nOrientationRX: %f\nOrientationRY: %f\nOrientationRZ: %f\nRadius: %f\nSet Origin\nSet Rotation Orientation\nApply Objects to map\nReset Values\nHide Objects",
				OBMTypes[OBMData[playerid][pOBMType]],
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMParts],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMvsep],
				OBMData[playerid][pOBMfacecenter] ? FaceCenterOnOff[0] : FaceCenterOnOff[1],
				OBMData[playerid][pOBMOriginX],
				OBMData[playerid][pOBMOriginY],
				OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX],
				OBMData[playerid][pOBMOriginRY],
				OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX],
				OBMData[playerid][pOBMOrientationRY],
				OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius]
			);
			
			Dialog_ShowCallback(playerid, using inline OBMEdit, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
		}
		case 10 .. 100: {
			inline OBMEdit(opid, odialogid, oresponse, olistitem, string:otext[])
			{
				#pragma unused olistitem, odialogid, opid, otext

				if(oresponse)
				{
					switch(olistitem)
					{
						// Set type
						case 0 :
						{
							inline OBMType(tpid, tdialogid, tresponse, tlistitem, string:ttext[])
							{
								#pragma unused tlistitem, tdialogid, tpid, ttext
								if(tresponse) OBMData[playerid][pOBMType] = tlistitem;
								OBMEditor(playerid);
								UpdateOBM(playerid);
							}
							line[0] = '\0';
							for(new i = 0; i < sizeof(OBMTypes); i++) format(line, sizeof(line), "%s%s\n", line, OBMTypes[i]);
							Dialog_ShowCallback(playerid, using inline OBMType, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
						}
						
						// Model
						case 1 :
						{
							inline OBMModel(mpid, mdialogid, mresponse, mlistitem, string:mtext[])
							{
								#pragma unused mlistitem, mdialogid, mpid, mtext
								if(mresponse)
								{
									new model = strval(mtext);
									OBMData[playerid][pOBMModel] = model;
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMModel, DIALOG_STYLE_INPUT, "Texture Studio", "Select a model", "Ok", "Cancel");
						}
						
						// Face Center
						case 2 :
						{
							inline OBMFaceCenter(fpid, fdialogid, fresponse, flistitem, string:ftext[])
							{
								#pragma unused flistitem, fdialogid, fpid, ftext
								if(fresponse) OBMData[playerid][pOBMfacecenter] = true;
								else OBMData[playerid][pOBMfacecenter] = false;
								UpdateOBM(playerid);
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMFaceCenter, DIALOG_STYLE_MSGBOX, "Texture Studio", "Face Center", "On", "Off");
						}
						
						// Fill Center
						case 3 :
						{
							inline OBMFaceCenter(fpid, fdialogid, fresponse, flistitem, string:ftext[])
							{
								#pragma unused flistitem, fdialogid, fpid, ftext
								if(fresponse) OBMData[playerid][pOBMFill] = true;
								else OBMData[playerid][pOBMFill] = false;
								UpdateOBM(playerid);
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMFaceCenter, DIALOG_STYLE_MSGBOX, "Texture Studio", "Face Center", "On", "Off");
						}
						
						// OriginX
						case 4 :
						{
							inline OBMOX(oxpid, oxdialogid, oxresponse, oxlistitem, string:oxtext[])
							{
								#pragma unused oxlistitem, oxdialogid, oxpid, oxtext
								if(oxresponse)
								{
									OBMData[playerid][pOBMOriginX] = floatstr(oxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOX, DIALOG_STYLE_INPUT, "Texture Studio", "Origin X", "Ok", "Cancel");
						}
						
						// OriginY
						case 5 :
						{
							inline OBMOY(oypid, oydialogid, oyresponse, oylistitem, string:oytext[])
							{
								#pragma unused oylistitem, oydialogid, oypid, oytext
								if(oyresponse)
								{
									OBMData[playerid][pOBMOriginY] = floatstr(oytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOY, DIALOG_STYLE_INPUT, "Texture Studio", "Origin Y", "Ok", "Cancel");
						}

						// OriginZ
						case 6 :
						{
							inline OBMOZ(ozpid, ozdialogid, ozresponse, ozlistitem, string:oztext[])
							{
								#pragma unused ozlistitem, ozdialogid, ozpid, oztext
								if(ozresponse)
								{
									OBMData[playerid][pOBMOriginZ] = floatstr(oztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOZ, DIALOG_STYLE_INPUT, "Texture Studio", "Origin Z", "Ok", "Cancel");
						}
						
						// EndX
						case 7 :
						{
							inline OBMOX(oxpid, oxdialogid, oxresponse, oxlistitem, string:oxtext[])
							{
								#pragma unused oxlistitem, oxdialogid, oxpid, oxtext
								if(oxresponse)
								{
									OBMData[playerid][pOBMEndX] = floatstr(oxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOX, DIALOG_STYLE_INPUT, "Texture Studio", "End X", "Ok", "Cancel");
						}
						
						// EndY
						case 8 :
						{
							inline OBMOY(oypid, oydialogid, oyresponse, oylistitem, string:oytext[])
							{
								#pragma unused oylistitem, oydialogid, oypid, oytext
								if(oyresponse)
								{
									OBMData[playerid][pOBMEndY] = floatstr(oytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOY, DIALOG_STYLE_INPUT, "Texture Studio", "End Y", "Ok", "Cancel");
						}

						// EndZ
						case 9 :
						{
							inline OBMOZ(ozpid, ozdialogid, ozresponse, ozlistitem, string:oztext[])
							{
								#pragma unused ozlistitem, ozdialogid, ozpid, oztext
								if(ozresponse)
								{
									OBMData[playerid][pOBMEndZ] = floatstr(oztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMOZ, DIALOG_STYLE_INPUT, "Texture Studio", "End Z", "Ok", "Cancel");
						}

						// OriginRX
						case 10 :
						{
							inline OBMORX(orxpid, orxdialogid, orxresponse, orxlistitem, string:orxtext[])
							{
								#pragma unused orxlistitem, orxdialogid, orxpid, orxtext
								if(orxresponse)
								{
									OBMData[playerid][pOBMOriginRX] = floatstr(orxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORX, DIALOG_STYLE_INPUT, "Texture Studio", "Origin RX", "Ok", "Cancel");


						}

						// OriginRY
						case 11:
						{
							inline OBMORY(orypid, orydialogid, oryresponse, orylistitem, string:orytext[])
							{
								#pragma unused orylistitem, orydialogid, orypid, orytext
								if(oryresponse)
								{
									OBMData[playerid][pOBMOriginRY] = floatstr(orytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORY, DIALOG_STYLE_INPUT, "Texture Studio", "Origin RY", "Ok", "Cancel");
						}

						// OriginRZ
						case 12:
						{
							inline OBMORZ(orzpid, orzdialogid, orzresponse, orzlistitem, string:orztext[])
							{
								#pragma unused orzlistitem, orzdialogid, orzpid, orztext
								if(orzresponse)
								{
									OBMData[playerid][pOBMOriginRZ] = floatstr(orztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORZ, DIALOG_STYLE_INPUT, "Texture Studio", "Origin RZ", "Ok", "Cancel");

						}

						// OrientationRX
						case 13:
						{
							inline OBMORTRX(ortrxpid, ortrxdialogid, ortrxresponse, ortrxlistitem, string:ortrxtext[])
							{
								#pragma unused ortrxlistitem, ortrxdialogid, ortrxpid, ortrxtext
								if(ortrxresponse)
								{
									OBMData[playerid][pOBMOrientationRX] = floatstr(ortrxtext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORTRX, DIALOG_STYLE_INPUT, "Texture Studio", "Orientation RX", "Ok", "Cancel");
						}

						// OrientationRY
						case 14:
						{
							inline OBMORTRY(ortrypid, ortrydialogid, ortryresponse, ortrylistitem, string:ortrytext[])
							{
								#pragma unused ortrylistitem, ortrydialogid, ortrypid, ortrytext
								if(ortryresponse)
								{
									OBMData[playerid][pOBMOrientationRY] = floatstr(ortrytext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORTRY, DIALOG_STYLE_INPUT, "Texture Studio", "Orientation RY", "Ok", "Cancel");
						}

						// OrientationRZ
						case 15:
						{
							inline OBMORTRZ(ortrzpid, ortrzdialogid, ortrzresponse, ortrzlistitem, string:ortrztext[])
							{
								#pragma unused ortrzlistitem, ortrzdialogid, ortrzpid, ortrztext
								if(ortrzresponse)
								{
									OBMData[playerid][pOBMOrientationRZ] = floatstr(ortrztext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMORTRZ, DIALOG_STYLE_INPUT, "Texture Studio", "Orientation RZ", "Ok", "Cancel");
						}
						
						// Length
						case 16:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMLength] = floatstr(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Dimension", "Ok", "Cancel");
						}
						
						// Width
						case 17:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMWidth] = floatstr(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Dimension", "Ok", "Cancel");
						}
						
						// Height
						case 18:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMHeight] = floatstr(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Dimension", "Ok", "Cancel");
						}
						
						// Length Segments
						case 19:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMLSegs] = strval(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Dimension Segments", "Ok", "Cancel");
						}
						
						// Width Segments
						case 20:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMWSegs] = strval(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Dimension Segments", "Ok", "Cancel");
						}
						
						// Height Segments
						case 21:
						{
							inline OBMHS(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse)
								{
									OBMData[playerid][pOBMHSegs] = strval(htext);
									UpdateOBM(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHS, DIALOG_STYLE_INPUT, "Texture Studio", "Dimension Segments", "Ok", "Cancel");
						}


						// Set origin
						case 22:
						{
							if(!OBMData[playerid][OriginSet])
							{
								new Float:x, Float:y, Float:z, Float:fa;
								GetPosFaInFrontOfPlayer(playerid, 2.0, x, y, z, fa);
								OBMObject[playerid] = CreateDynamicObject(1974, x, y, z, 0.0, 0.0, 0.0, -1, -1, playerid);
							}
							else OBMObject[playerid] = CreateDynamicObject(1974, OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ], OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ], -1, -1, playerid);

							OBMOriginSave[playerid][0] = OBMData[playerid][pOBMOriginX];
							OBMOriginSave[playerid][1] = OBMData[playerid][pOBMOriginY];
							OBMOriginSave[playerid][2] = OBMData[playerid][pOBMOriginZ];
							OBMOriginSave[playerid][3] = OBMData[playerid][pOBMOriginRX];
							OBMOriginSave[playerid][4] = OBMData[playerid][pOBMOriginRY];
							OBMOriginSave[playerid][5] = OBMData[playerid][pOBMOriginRZ];

							Streamer_SetFloatData(STREAMER_TYPE_OBJECT, OBMObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

							SetDynamicObjectMaterial(OBMObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

							Streamer_Update(playerid);

							EditDynamicObject(playerid, OBMObject[playerid]);

							OBMEditMode[playerid] = OBME_ORIGIN;

							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_GREEN, "Editing your objectmetry origin");
						}
						
						// Set rotation orientation
						case 23:
						{
							if(!OBMData[playerid][OriginSet]) 
							{
								SendClientMessage(playerid, STEALTH_YELLOW, "Please set your origin first");
								OBMEditor(playerid);
							}
							else
							{
								OBMObject[playerid] = CreateDynamicObject(1974, OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ], OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ], -1, -1, playerid);

								OBMOrientationSave[playerid][0] = OBMData[playerid][pOBMOrientationRX];
								OBMOrientationSave[playerid][1] = OBMData[playerid][pOBMOrientationRY];
								OBMOrientationSave[playerid][2] = OBMData[playerid][pOBMOrientationRZ];

								Streamer_SetFloatData(STREAMER_TYPE_OBJECT, OBMObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

								SetDynamicObjectMaterial(OBMObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

								Streamer_Update(playerid);

								EditDynamicObject(playerid, OBMObject[playerid]);

								OBMEditMode[playerid] = OMBE_ORIENT;

								SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
								SendClientMessage(playerid, STEALTH_GREEN, "Editing your rotation orientation");
							}
						}

						// Apply objects to map
						case 24:
						{
							inline OBMApply(apid, adialogid, aresponse, alistitem, string:atext[])
							{
								#pragma unused alistitem, adialogid, apid, atext
								if(aresponse)
								{
									ApplyOBM(playerid);
									SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
									SendClientMessage(playerid, STEALTH_GREEN, "Current objectmetry applied to your map");
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMApply, DIALOG_STYLE_MSGBOX, "Texture Studio", "Apply this objectmetry to your map?", "On", "Off");
						}

						// Reset values
						case 25:
						{
							inline OBMReset(epid, edialogid, eresponse, elistitem, string:etext[])
							{
								#pragma unused elistitem, edialogid, epid, etext
								if(eresponse)
								{
									ResetOBMValues(playerid);
									ClearOBMStack(playerid);
								}
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMReset, DIALOG_STYLE_MSGBOX, "Texture Studio", "Reset all values?", "Ok", "Cancel");
						}
						
						// Hide object stack
						case 26:
						{
							inline OBMHideStack(hpid, hdialogid, hresponse, hlistitem, string:htext[])
							{
								#pragma unused hlistitem, hdialogid, hpid, htext
								if(hresponse) ClearOBMStack(playerid);
								OBMEditor(playerid);
							}
							Dialog_ShowCallback(playerid, using inline OBMHideStack, DIALOG_STYLE_MSGBOX, "Texture Studio", "Hide objectmetry?", "Ok", "Cancel");
						}
					}
				}
				else
				{
					EditingMode[playerid] = false;
					SetEditMode(playerid, EDIT_MODE_NONE);
				}
			}
			
			format(line, sizeof(line), "Set Type: %s\nModel: %i\nFace Center: %s\nFill: %s\n\
				OriginX: %f\nOriginY: %f\nOriginZ: %f\n\
				EndX: %f\nEndY: %f\nEndZ: %f\n\
				OriginRX: %f\nOriginRY: %f\nOriginRZ: %f\n\
				OrientationRX: %f\nOrientationRY: %f\nOrientationRZ: %f\n\
				Length: %f\nWidth: %f\nHeight: %f\n\
				Length Segments: %i\nWidth Segments: %i\nHeight Segments: %i\n\
				Set Origin\nSet Rotation Orientation\nApply Objects to map\nReset Values\nHide Objects",
				OBMTypes[OBMData[playerid][pOBMType]],
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMfacecenter] ? FaceCenterOnOff[0] : FaceCenterOnOff[1],
				OBMData[playerid][pOBMFill] ? FaceCenterOnOff[0] : FaceCenterOnOff[1],
				OBMData[playerid][pOBMOriginX],
				OBMData[playerid][pOBMOriginY],
				OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMEndX],
				OBMData[playerid][pOBMEndY],
				OBMData[playerid][pOBMEndZ],
				OBMData[playerid][pOBMOriginRX],
				OBMData[playerid][pOBMOriginRY],
				OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX],
				OBMData[playerid][pOBMOrientationRY],
				OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMLength],
				OBMData[playerid][pOBMWidth],
				OBMData[playerid][pOBMHeight],
				OBMData[playerid][pOBMLSegs],
				OBMData[playerid][pOBMWSegs],
				OBMData[playerid][pOBMHSegs]
			);
			
			Dialog_ShowCallback(playerid, using inline OBMEdit, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
		}
		default: {
			inline OBMEdit(opid, odialogid, oresponse, olistitem, string:otext[])
			{
				#pragma unused olistitem, odialogid, opid, otext

				if(oresponse && olistitem == 0)
				{
					inline OBMType(tpid, tdialogid, tresponse, tlistitem, string:ttext[])
					{
						#pragma unused tlistitem, tdialogid, tpid, ttext
						if(tresponse) OBMData[playerid][pOBMType] = tlistitem;
						OBMEditor(playerid);
						UpdateOBM(playerid);
					}
					line[0] = '\0';
					for(new i = 0; i < sizeof(OBMTypes); i++) format(line, sizeof(line), "%s%s\n", line, OBMTypes[i]);
					Dialog_ShowCallback(playerid, using inline OBMType, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
				}
			}
			format(line, sizeof(line), "{FF0000}Set Type: %s", OBMTypes[OBMData[playerid][pOBMType]]);
			
			Dialog_ShowCallback(playerid, using inline OBMEdit, DIALOG_STYLE_LIST, "Texture Studio", line, "Ok", "Cancel");
		}
	}
	
	return 1;
}

static UpdateOBM(playerid)
{
	// Clear the stack
    ClearOBMStack(playerid);

	// Apply OBM settings
	if(OBMData[playerid][pOBMModel] > 0)
	{
		switch(OBMData[playerid][pOBMType])
		{
	 		case OBM_NONE: { }
		    case OBM_CIRCLE: { CreateDynamicObjectCircle(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMfacecenter]
			);	}


		    case OBM_SPHERE: { CreateDynamicObjectSphere(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMvsep],
				OBMData[playerid][pOBMfacecenter]
			);	}


		    case OBM_SPIRAL: { CreateDynamicObjectSpiral(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMvsep],
				OBMData[playerid][pOBMfacecenter]
			);	}


		    case OBM_HELIX: { CreateDynamicObjectHelix(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMvsep],
				OBMData[playerid][pOBMfacecenter]
			);	}


		    case OBM_CLYINDER: { CreateDynamicObjectCylinder(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMvsep],
				OBMData[playerid][pOBMParts],
				OBMData[playerid][pOBMfacecenter]
			);	}


		    case OBM_CONE: { CreateDynamicObjectCone(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMvsep],
				OBMData[playerid][pOBMParts],
				OBMData[playerid][pOBMfacecenter]
			);	}

		    case OBM_WHIRL: { CreateDynamicObjectWhirl(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMfacecenter]
			);	}


		    case OBM_CIRCLEIN: { CreateDynamicCircleIn(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMParts],
				OBMData[playerid][pOBMfacecenter]
			);	}
			
		    case OBM_CIRCLEOUT: { CreateDynamicCircleOut(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMDegrees],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMRadius],
				OBMData[playerid][pOBMhsep],
				OBMData[playerid][pOBMParts],
				OBMData[playerid][pOBMfacecenter]
			);	}
			
			//////////////////Non Round
		    case OBM_LINE: { CreateDynamicLine(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMEndX], OBMData[playerid][pOBMEndY], OBMData[playerid][pOBMEndZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMLSegs]
			);	}
		
		    case OBM_RECTANGLE: { CreateDynamicQuadrilateral(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMLength], OBMData[playerid][pOBMWidth],
				OBMData[playerid][pOBMLSegs], OBMData[playerid][pOBMWSegs],
				OBMData[playerid][pOBMFill]
			);	}
		
		    case OBM_RECTPRISM: { CreateDynamicPrism(playerid,
				OBMData[playerid][pOBMModel],
				OBMData[playerid][pOBMOriginX], OBMData[playerid][pOBMOriginY], OBMData[playerid][pOBMOriginZ],
				OBMData[playerid][pOBMOriginRX], OBMData[playerid][pOBMOriginRY], OBMData[playerid][pOBMOriginRZ],
				OBMData[playerid][pOBMOrientationRX], OBMData[playerid][pOBMOrientationRY], OBMData[playerid][pOBMOrientationRZ],
				OBMData[playerid][pOBMLength], OBMData[playerid][pOBMWidth], OBMData[playerid][pOBMHeight],
				OBMData[playerid][pOBMLSegs], OBMData[playerid][pOBMWSegs], OBMData[playerid][pOBMHSegs],
				OBMData[playerid][pOBMFill]
			);	}
		}
	}
	return 1;
}




OnPlayerEditDOOBM(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	#pragma unused objectid
	
	// Edit origin
	if(OBMEditMode[playerid] == OBME_ORIGIN)
	{
		if(response == EDIT_RESPONSE_FINAL)
		{
	   	    OBMData[playerid][pOBMOriginX] = x;
	 		OBMData[playerid][pOBMOriginY] = y;
	 		OBMData[playerid][pOBMOriginZ] = z;
	   	    OBMData[playerid][pOBMOriginRX] = rx;
	 		OBMData[playerid][pOBMOriginRY] = ry;
	 		OBMData[playerid][pOBMOriginRZ] = rz;
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		    SendClientMessage(playerid, STEALTH_GREEN, "Objectmetry origin set");
			DestroyDynamicObject(OBMObject[playerid]);
	        OBMData[playerid][OriginSet] = true;
			UpdateOBM(playerid);
	        OBMEditor(playerid);
		}
		else if(response == EDIT_RESPONSE_UPDATE)
		{
	   	    OBMData[playerid][pOBMOriginX] = x;
	 		OBMData[playerid][pOBMOriginY] = y;
	 		OBMData[playerid][pOBMOriginZ] = z;
	   	    OBMData[playerid][pOBMOriginRX] = rx;
	 		OBMData[playerid][pOBMOriginRY] = ry;
	 		OBMData[playerid][pOBMOriginRZ] = rz;
	 		UpdateOBM(playerid);

		}
		else if(response == EDIT_RESPONSE_CANCEL)
		{
			OBMData[playerid][pOBMOriginX] = OBMOriginSave[playerid][0];
			OBMData[playerid][pOBMOriginY] = OBMOriginSave[playerid][1];
			OBMData[playerid][pOBMOriginZ] = OBMOriginSave[playerid][2];
			OBMData[playerid][pOBMOriginRX] = OBMOriginSave[playerid][3];
			OBMData[playerid][pOBMOriginRY] = OBMOriginSave[playerid][4];
			OBMData[playerid][pOBMOriginRZ] = OBMOriginSave[playerid][5];

			DestroyDynamicObject(OBMObject[playerid]);
			UpdateOBM(playerid);
			OBMEditor(playerid);
		}
	}
	
	// Edit orientation
	else if(OBMEditMode[playerid] == OMBE_ORIENT)
	{
		if(response == EDIT_RESPONSE_FINAL)
		{
	   	    OBMData[playerid][pOBMOrientationRX] = rx;
	 		OBMData[playerid][pOBMOrientationRY] = ry;
	 		OBMData[playerid][pOBMOrientationRZ] = rz;
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		    SendClientMessage(playerid, STEALTH_GREEN, "Objectmetry orientation set");
			DestroyDynamicObject(OBMObject[playerid]);
			UpdateOBM(playerid);
	        OBMEditor(playerid);
		}
		else if(response == EDIT_RESPONSE_UPDATE)
		{
	   	    OBMData[playerid][pOBMOrientationRX] = rx;
	 		OBMData[playerid][pOBMOrientationRY] = ry;
	 		OBMData[playerid][pOBMOrientationRZ] = rz;
	 		UpdateOBM(playerid);
		}
		else if(response == EDIT_RESPONSE_CANCEL)
		{
			OBMData[playerid][pOBMOrientationRX] = OBMOrientationSave[playerid][0];
			OBMData[playerid][pOBMOrientationRY] = OBMOrientationSave[playerid][1];
			OBMData[playerid][pOBMOrientationRZ] = OBMOrientationSave[playerid][2];

			DestroyDynamicObject(OBMObject[playerid]);
			UpdateOBM(playerid);
			OBMEditor(playerid);
		}
	}
	return 1;
}
