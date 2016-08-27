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

#define         MAX_OBM         2000

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
	
	db_begin_transaction(EditMap);
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
	db_end_transaction(EditMap);
	return 1;
}

static AddOBMObject(playerid,modelid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
	for(new i = 0; i < MAX_OBM; i++)
	{
	    if(OBMStack[playerid][i][OMBID] == -1)
		{
		    OBMStack[playerid][i][OMBID] = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0, 300.0);
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

/*
x = (a + b * deg) * floatcos(deg, degrees);
y = (a + b * deg) * floatsin(deg, degrees);
*/

/* Creates objects in an Archimedean spiral path */
CreateDynamicObjectSpiral(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:hsep,Float:vsep,bool:facecenter=false)
{
	if(facecenter == false)
	{
    	new Float:x, Float:y, Float:c,
			Float:away, Float:around,
			Float:thetaMax = ((deg + 180) / 360 * 2) * (3.141593),
			Float:awayStep = radius / thetaMax;

		for(new Float:theta = hsep / awayStep; theta <= thetaMax; ) 
		{
			away = awayStep * theta,
			around = theta;
			
			x = floatcos(around) * away,
			y = floatsin(around) * away,
			
			AddOBMObject(playerid,modelid, posx + x, posy + y, posz + c,orx,ory,rz+orz);
		
			//c += vsep;
			c = vsep + floatsqroot(floatpower(floatcos(around) * away, 2) + (floatpower(floatsin(around) * away, 2)));
			theta += hsep / away;
		}
	}
	else
	{
    	new Float:x, Float:y, Float:z, Float:c,
			Float:detrx,Float:detry,Float:detrz,
			Float:away, Float:around,
			Float:thetaMax = ((deg + 180) / 360 * 2) * (3.141593),
			Float:awayStep = radius / thetaMax;

		for(new Float:theta = hsep / awayStep; theta <= thetaMax; ) 
		{
			away = awayStep * theta,
			around = theta;
			
			x = floatcos(around) * away,
			y = floatsin(around) * away,
		
			// Translate to rotation
			AttachPoint(
				posx + x, posy + y, posz + c,			orx, ory, atan2(y, x) + orz,
				posx, posy, posz,						rx, ry, rz,
				x, y, z,								detrx, detry, detrz
			);
			AddOBMObject(playerid,modelid, x, y, z, detrx, detry, detrz);
		
			//c += vsep;
			c = vsep + floatsqroot(floatpower(floatcos(around) * away, 2) + (floatpower(floatsin(around) * away, 2)));
			theta += hsep / away;
		}
	}
	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a Helical path */
CreateDynamicObjectHelix(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:hsep,Float:vsep,bool:facecenter=false)
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

/* Creates objects in a Conical path */
CreateDynamicObjectCone(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:radius,Float:hsep,Float:vsep,parts,bool:facecenter=false)
{
	if(facecenter == false)
	{
     	new Float:angle=0.0,Float:x=0.0,Float:y=0.0,Float:c=0.0;
    	for(new j=0;j<parts;j++)
    	{
			/*|		No Radius
			j4|			*
			j3|		   * *
			j2|		  *   *
			j1|		 *     *
			j0|		*       *
			*///   Full Radius	
    	    angle = 0.0,x = 0.0,y = 0.0;
			new Float:rad = radius - ((radius / (parts - 1)) * j);
			for(new i=0;i<deg;i+=1)
			{
			    if(angle <= float(deg))
			    {
					x=posx+rad*floatcos(angle,degrees);
					y=posy+rad*floatsin(angle,degrees);
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
			new Float:rad = radius - ((radius / (parts - 1)) * j);
   			for(new i=0;i<deg;i+=1)
   			{
   			    if(angle <= float(deg))
   			    {
					x=posx+rad*floatcos(angle,degrees);
					y=posy+rad*floatsin(angle,degrees);
					
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

/* Creates objects in a line */
CreateDynamicLine(playerid, modelid, Float:sx, Float:sy, Float:sz, Float:ex, Float:ey, Float:ez, Float:orx, Float:ory, Float:orz, segs)
{
	new Float:dx = (ex - sx),
		Float:dy = (ey - sy),
		Float:dz = (ez - sz),
		Float:d = VectorSize(dx, dy, dz);
	
	new Float:step = d / segs;
	dx /= d; dy /= d; dz /= d;
	
	for(new Float:j; j <= segs * step; j += step)
		AddOBMObject(
			playerid, modelid,
			sx + (j * dx), sy + (j * dy), sz + (j * dz),
			orx, ory, orz
		);

	Streamer_Update(playerid);
    return 1;
}

/* Creates objects in a line */
CreateDynamicQuadrilateral(playerid, modelid, Float:cx, Float:cy, Float:cz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:length, Float:width, lsegs, wsegs, bool:fill)
{ 
	length -= 1.0, width -= 1.0, 
	lsegs -= 1, wsegs -= 1;
	
	new Float:sx = cx - (length / 2.0),		Float:sy = cy - (width / 2.0),
		Float:ex = cx + (length / 2.0),		Float:ey = cy + (width / 2.0),
		Float:dx = (ex - sx),				Float:dy = (ey - sy),
		Float:lstep = dx / lsegs,			Float:wstep = dy / wsegs;

	new Float:nx, Float:ny, Float:nz, Float:nrx, Float:nry, Float:nrz;
	
	for(new Float:x, Float:mx = lsegs * lstep; x <= mx; x += lstep) {
		for(new Float:y, Float:my = wsegs * wstep; y <= my; y += wstep) {
			if(fill || (x == 0.0 || y == 0.0 || x == mx || y == my)) {
				AttachPoint(
					sx + x, sy + y, cz, orx, ory, orz,
					cx, cy, cz, rx, ry, rz,
					nx, ny, nz, nrx, nry, nrz
				);
				AddOBMObject(playerid, modelid, nx, ny, nz, nrx, nry, nrz);
			}
		}
	}
	return 1;
}

/* Creates objects in a line */
CreateDynamicPrism(playerid, modelid, Float:cx, Float:cy, Float:cz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:orz, Float:length, Float:width, Float:height, lsegs, wsegs, hsegs, bool:fill)
{ 
	length -= 1.0, width -= 1.0, 
	lsegs -= 1, wsegs -= 1;
	
	new Float:sx = cx - (length / 2.0),		Float:sy = cy - (width / 2.0),		Float:sz = cz - (height / 2.0),
		Float:ex = cx + (length / 2.0),		Float:ey = cy + (width / 2.0),		Float:ez = cz + (height / 2.0),
		Float:dx = (ex - sx),				Float:dy = (ey - sy),				Float:dz = (ez - sz),
		Float:lstep = dx / lsegs,			Float:wstep = dy / wsegs,			Float:hstep = dz / hsegs;

	new Float:nx, Float:ny, Float:nz, Float:nrx, Float:nry, Float:nrz;
	
	for(new Float:x, Float:mx = lsegs * lstep; x <= mx; x += lstep) {
		for(new Float:y, Float:my = wsegs * wstep; y <= my; y += wstep) {
			for(new Float:z, Float:mz = hsegs * hstep; z <= mz; z += hstep) {
				if(fill || (x == 0.0 || y == 0.0 || z == 0.0 || x == mx || y == my || z == mz)) {
					AttachPoint(
						sx + x, sy + y, sy + y, orx, ory, orz,
						cx, cy, cz, rx, ry, rz,
						nx, ny, nz, nrx, nry, nrz
					);
					AddOBMObject(playerid, modelid, nx, ny, nz, nrx, nry, nrz);
				}
			}
		}
	}
	return 1;
}

/* Creates objects in a line */
/*CreateDynamicPrism(playerid, modelid,
	Float:cx, Float:cy, Float:cz,
	Float:l, Float:w, Float:h,
	Float:rx, Float:ry, Float:rz,
	Float:orz, Float:ory, Float:orz,
	segs, bool:fill)
{

	const
		Float:halve = l / 2.0,
		Float:d = VectorSize(l, w, h),
		Float:step = d / segs;
	new
		Float:sx = cx - halve,
		Float:sy = cy - halve,
		Float:sz = cz - halve;
	//	Float:ex = cx + halve,
	//	Float:ey = cy + halve,
	//	Float:ez = cz + halve;

	l /= d; w /= d; h /= d;
	
	for(new Float:j; j <= segs * step; j += step)
		AddOBMObject(
			playerid, modelid,
			sx + (j * l), sy + (j * w), sz + (j * h),
			orx, ory, orz
		);

	Streamer_Update(playerid);
    return 1;
}*/

//==========================================================================================
