/*
 * =============================================================================================== *
 * =============================================================================================== *
 * =============================================================================================== *
 * =============================================================================================== *
 * ================================           Codectile's         ================================ *
 * ================================          Objectometry         ================================ *
 * ================================            -Library-          ================================ *
 * ================================          -Version 1.0-        ================================ *
 * ================================                               ================================ *
 * =============================================================================================== *
 * =============================================================================================== *
 * =============================================================================================== *
 */

 /*
 Introduction: This include helps in creating objects in different types of circular paths/tracks.This include is still under development.
 			   The functions below will not work unless streamer plugin is included in your script.
			   There are total 6 different types of functions -

CreateDynamicObjectCircle(playerid,modelid,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz,Float:radius,Float:sep,bool:facecenter=false)
CreateDynamicObjectSpiral(playerid,modelid,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz,Float:radius,Float:hsep,Float:vsep,bool:facecenter=false)
CreateDynamicObjectCylinder(playerid,modelid,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz,Float:radius,Float:hsep,Float:vsep,parts,bool:facecenter=false)
CreateDynamicObjectWhirl(playerid,modelid,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz,Float:radius,Float:sep,bool:facecenter=false)
CreateDynamicCircleIn(playerid,modelid,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz,Float:radius,Float:sep,parts,bool:facecenter=false)
CreateDynamicCircleOut(playerid,modelid,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz,Float:radius,Float:sep,parts,bool:facecenter=false)


Dependencies: Streamer Plugin (Incognito)

Bugs: None yet.

Source Code: www.github.com/codectile
Credits: Incognito

Note: This include has been modified and integrated for use in Texture Studio
*/



/* The following codes are too much fragile, please "do not edit them". */

/* Creates object in a circular path */

#define         MAX_OBM         1000

enum OBMINFO
{
	OMBID,
	OMBModel,
	Float:OBMX,
	Float:OBMY,
	Float:OBMZ,
	Float:OBMRX,
	Float:OBMRY,
	Float:OBMRZ,
}

static OBMStack[MAX_PLAYERS][MAX_OBM][OBMINFO];

public OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		for(new j = 0; j < MAX_OBM; j++) OBMStack[i][j][OMBID] = -1;
	}

	#if defined OM_OnFilterScriptInit
		OM_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit OM_OnFilterScriptInit
#if defined OM_OnFilterScriptInit
	forward OM_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
	foreach(new i : Player) ClearOBMStack(i);

	#if defined OM_OnFilterScriptExit
		OM_OnFilterScriptExit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit OM_OnFilterScriptExit
#if defined OM_OnFilterScriptExit
	forward OM_OnFilterScriptExit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
    ClearOBMStack(playerid);

	#if defined OM_OnPlayerDisconnect
		OM_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect OM_OnPlayerDisconnect
#if defined OM_OnPlayerDisconnect
	forward OM_OnPlayerDisconnect(playerid, reason);
#endif

ClearOBMStack(playerid)
{
	for(new i = 0; i < MAX_OBM; i++)
	{
	    if(OBMStack[playerid][i][OMBID] != -1)
		{
			DestroyDynamicObject(OBMStack[playerid][i][OMBID]);
	        OBMStack[playerid][i][OMBID] = -1;
		}
	}
	return 1;
}

ApplyOBM(playerid)
{
	ClearGroup(playerid);
	new index;
	new time = GetTickCount();
	for(new i = 0; i < MAX_OBM; i++)
	{
	    if(OBMStack[playerid][i][OMBID] != -1)
		{
			index = AddDynamicObject(OBMStack[playerid][i][OMBModel],
				OBMStack[playerid][i][OBMX], OBMStack[playerid][i][OBMY], OBMStack[playerid][i][OBMZ],
				OBMStack[playerid][i][OBMRX], OBMStack[playerid][i][OBMRY], OBMStack[playerid][i][OBMRZ]
			);
			SaveUndoInfo(index, UNDO_TYPE_CREATED, time);
			GroupedObjects[playerid][index] = true;
			UpdateObject3DText(index, true);
			OnUpdateGroup3DText(index);
		}
	}
	return 1;
}

static AddOBMObject(playerid,modelid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
	for(new i = 0; i < MAX_OBM; i++)
	{
	    if(OBMStack[playerid][i][OMBID] == -1)
		{
		    OBMStack[playerid][i][OMBID] = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, -1, -1, -1, 300.0, 300.0);
		    OBMStack[playerid][i][OMBModel] = modelid;
		    OBMStack[playerid][i][OBMX] = x;
		    OBMStack[playerid][i][OBMY] = y;
		    OBMStack[playerid][i][OBMZ] = z;
		    OBMStack[playerid][i][OBMRX] = rx;
		    OBMStack[playerid][i][OBMRY] = ry;
		    OBMStack[playerid][i][OBMRZ] = rz;
		    return i;
		}
	}
	return 1;
}

CreateDynamicObjectCircle(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:sep,bool:facecenter=false)
{
	if(facecenter == false)
	{
    	new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0;
    	for(new i = 0;i < deg;i += 1)
    	{
    	    if(angle <= float(deg))
    	    {
				x = posx+radius*floatcos(angle,degrees);
      			y = posy+radius*floatsin(angle,degrees);
				AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz+orz);
				angle = angle+sep;
			}
			else break;
		}
	}
	else
	{
		new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:z,Float:detrx,Float:detry,Float:detrz;
	    for(new i = 0;i < float(deg);i += 1)
        {
 	   		if(angle <= deg)
    	    {
		   		x=posx+radius*floatcos(angle,degrees);
			   	y=posy+radius*floatsin(angle,degrees);
			   	
				// Translate to rotation
                AttachPoint(x, y, posz,
                    orx, ory, angle-180.0+orz,
                    posx, posy, posz, rx, ry, rz,
					x, y, z,
                    detrx, detry, detrz
				);
                AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);
			   	angle = angle+sep;
           	}
	       	else break;
		}
	}
	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a Spherical path */
CreateDynamicObjectSphere(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:hsep,Float:vsep,bool:facecenter=false)
{
	if(facecenter == false)
	{
    	new Float:x, Float:y, Float:z;
		for(new Float:lat = -90.0; lat <= 90.0; lat += vsep)
		for(new Float:lon = -180.0, Float:angle = float(clamp(deg, 0, 360) - 180); lon <= angle; lon += hsep)
    	{
			x = radius * -(floatcos(lat, degrees) * floatsin(-lon, degrees));
			y = radius * floatcos(lat, degrees) * floatcos(-lon, degrees);
			z = radius * floatsin(lat, degrees);
			
			AddOBMObject(playerid, modelid, posx + x, posy + y, posz + z, rx, ry, rz + orz);
		}
	}
	else
	{
    	new Float:x, Float:y, Float:z, Float:detrx, Float:detry, Float:detrz;
		for(new Float:lat = -90.0; lat <= 90.0; lat += vsep)
		for(new Float:lon = -180.0, Float:angle = float(clamp(deg, 0, 360) - 180); lon <= angle; lon += hsep)
    	{
			x = -(floatcos(lat, degrees) * floatsin(-lon, degrees));
			y = floatcos(lat, degrees) * floatcos(-lon, degrees);
			z = floatsin(lat, degrees);
			
			AttachPoint(x * radius, y * radius, z * radius, orx + 90 - lat, ory, orz + 180.0 - lon,
				posx, posy, posz, rx, ry, rz,
				x, y, z, detrx, detry, detrz
			);
			
			AddOBMObject(playerid, modelid, posx + x, posy + y, posz + z, detrx, detry, detrz);
		}
	}
	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a Helical path */
CreateDynamicObjectSpiral(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:hsep,Float:vsep,bool:facecenter=false)
{
	if(facecenter == false)
	{
    	new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:c = 0.0;
   		for(new i = 0;i < deg;i += 1)
   		{
   		    if(angle <= float(deg))
   		    {
				x=posx+radius*floatcos(angle,degrees);
				y=posy+radius*floatsin(angle,degrees);
				AddOBMObject(playerid,modelid, x, y, posz+c,rx,ry,rz+orz);
				c = c+vsep;
				angle = angle+hsep;
			}
			else break;
		}
	}
	else
	{
	    new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:z, Float:c = 0.0, Float:detrx,Float:detry,Float:detrz;
   		for(new i = 0;i < deg;i += 1)
   		{
   		    if(angle <= float(deg))
   		    {
				x=posx+radius*floatcos(angle,degrees);
				y=posy+radius*floatsin(angle,degrees);


				// Translate to rotation
                AttachPoint(x, y, posz+c,
                    orx, ory, angle+180.0+orz,
                    posx, posy, posz, rx, ry, rz,
					x, y, z,
                    detrx, detry, detrz
				);
                AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);

				c=c+vsep;
				angle = angle+hsep;
			}
			else break;
		}
	}
	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a Cylinderical path */
CreateDynamicObjectCylinder(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:hsep,Float:vsep,parts,bool:facecenter=false)
{
	if(facecenter == false)
	{
     	new Float:angle=0.0,Float:x=0.0,Float:y=0.0,Float:c=0.0;
    	for(new j=0;j<parts;j++)
    	{
    	    angle = 0.0,x = 0.0,y = 0.0;
			for(new i=0;i<deg;i+=1)
			{
			    if(angle <= float(deg))
			    {
					x=posx+radius*floatcos(angle,degrees);
					y=posy+radius*floatsin(angle,degrees);
					AddOBMObject(playerid,modelid, x, y, posz+c,rx,ry,rz+orz);
					angle=angle+hsep;
				}
				else break;
			}
			c=c+vsep;
		}
	}
	else
	{
	    new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:z, Float:c = 0.0, Float:detrx,Float:detry,Float:detrz;
    	for(new j=0;j<parts;j++)
    	{
    	    angle = 0.0,x = 0.0,y = 0.0;
   			for(new i=0;i<deg;i+=1)
   			{
   			    if(angle <= float(deg))
   			    {
					x=posx+radius*floatcos(angle,degrees);
					y=posy+radius*floatsin(angle,degrees);
					
					// Translate to rotation
	                AttachPoint(x, y, posz+c,
	                    orx, ory, angle+180.0+orz,
	                    posx, posy, posz, rx, ry, rz,
						x, y, z,
	                    detrx, detry, detrz
					);
	                AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);
					angle=angle+hsep;
				}
				else break;
			}
			c=c+vsep;
		}
	}
	Streamer_Update(playerid);
    return 1;
}


/* Creates objects in a reversed "6" type of path */
CreateDynamicObjectWhirl(playerid,modelid,deg,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:sep,bool:facecenter=false)
{
	if(facecenter == false)
	{
	    new Float:angle=0.0,Float:x=0.0,Float:y=0.0;
    	for(new i=0;i<deg;i+=1)
    	{
        	if(angle <= float(deg))
        	{
				x=posx+(radius-i)*floatcos(angle,degrees);
				y=posy+(radius-i)*floatsin(angle,degrees);
				AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz+orz);
				angle=angle+sep;
			}
			else break;
		}
	}
	else
	{
    	new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:z,Float:detrx,Float:detry,Float:detrz;
    	for(new i = 0;i < deg;i += 1)
    	{
        	if(angle <= float(deg))
        	{
				x=posx+(radius-i)*floatcos(angle,degrees);
				y=posy+(radius-i)*floatsin(angle,degrees);

				// Translate to rotation
                AttachPoint(x, y, posz,
                    orx, ory, angle+180.0+orz,
                    posx, posy, posz, rx, ry, rz,
					x, y, z,
                    detrx, detry, detrz
				);
                AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);
				angle=angle+sep;
			}
			else break;
		}
	}

	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a circular path within a circular pathed object */
CreateDynamicCircleIn(playerid,modelid,deg,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:sep,parts,bool:facecenter=false)
{
	if(facecenter == false)
	{
	    new Float:angle=0.0,Float:x=0.0,Float:y=0.0;
    	for(new j=0;j<parts;j++)
    	{
        	angle=0.0,x=0.0,y=0.0;
    		for(new i=0;i<deg;i+=1)
    		{
        		if(angle <= float(deg))
        		{
					x=posx+(radius)*floatcos(angle,degrees);
					y=posy+(radius)*floatsin(angle,degrees);
					AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz+orz);
					angle=angle+sep;
				}
				else break;
			}
			radius-=2.5;
		}
	}
	else
	{
		new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:z,Float:detrx,Float:detry,Float:detrz;
    	for(new j=0;j<parts;j++)
    	{
        	angle=0.0,x=0.0,y=0.0;
    		for(new i=0;i<deg;i+=1)
    		{
        		if(angle <= float(deg))
        		{
					x=posx+(radius)*floatcos(angle,degrees);
					y=posy+(radius)*floatsin(angle,degrees);

					// Translate to rotation
	                AttachPoint(x, y, posz,
	                    orx, ory, angle+180.0+orz,
	                    posx, posy, posz, rx, ry, rz,
						x, y, z,
	                    detrx, detry, detrz
					);
	                AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);
					angle=angle+sep;
				}
				else break;
			}
			radius-=2.5;
		}
	}
	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a circular path outside a circular pathed object */
CreateDynamicCircleOut(playerid,modelid,deg,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:sep,parts,bool:facecenter=false)
{
    if(facecenter == false)
	{
	    new Float:angle=0.0,Float:x=0.0,Float:y=0.0;
    	for(new j=0;j<parts;j++)
    	{
        	angle=0.0,x=0.0,y=0.0;
    		for(new i=0;i<deg;i+=1)
    		{
        		if(angle <= float(deg))
        		{
					x=posx+(radius)*floatcos(angle,degrees);
					y=posy+(radius)*floatsin(angle,degrees);
					AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz+orz);
					angle=angle+sep;
				}
				else break;
			}
			radius+=2.5;
		}
	}
	else
	{
    	new Float:angle = 0.0,Float:x = 0.0,Float:y = 0.0,Float:z,Float:detrx,Float:detry,Float:detrz;
    	for(new j=0;j<parts;j++)
    	{
        	angle=0.0,x=0.0,y=0.0;
    		for(new i=0;i<deg;i+=1)
    		{
        		if(angle <= float(deg))
        		{
					x=posx+(radius)*floatcos(angle,degrees);
					y=posy+(radius)*floatsin(angle,degrees);
					// Translate to rotation
	                AttachPoint(x, y, posz,
	                    orx, ory, angle+180.0+orz,
	                    posx, posy, posz, rx, ry, rz,
						x, y, z,
	                    detrx, detry, detrz
					);
	                AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);
					angle=angle+sep;
				}
				else break;
			}
			radius+=2.5;
		}
	}

	Streamer_Update(playerid);
    return 1;
}

//==========================================================================================
