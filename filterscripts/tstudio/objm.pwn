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

#include <YSI\y_hooks>
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

hook OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		for(new j = 0; j < MAX_OBM; j++) OBMStack[i][j][OMBID] = -1;
	}
	return 1;
}

hook OnFilterScriptExit()
{
	foreach(new i : Player) ClearOBMStack(i);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    ClearOBMStack(playerid);
	return 1;
}

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

CreateDynamicObjectCircle(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:radius,Float:sep,bool:facecenter=false)
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
				AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz);
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
                    orx, ory, angle-180.0,
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

/* Creates objects in a Helical path */
CreateDynamicObjectSpiral(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:radius,Float:hsep,Float:vsep,bool:facecenter=false)
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
				AddOBMObject(playerid,modelid, x, y, posz+c,rx,ry,rz);
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
                    orx, ory, angle+180.0,
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
CreateDynamicObjectCylinder(playerid,modelid,deg,Float:posx,Float:posy,Float:posz, Float:rx, Float:ry, Float:rz, Float:orx, Float:ory, Float:radius,Float:hsep,Float:vsep,parts,bool:facecenter=false)
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
					AddOBMObject(playerid,modelid, x, y, posz+c,rx,ry,rz);
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
	                    orx, ory, angle+180.0,
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
CreateDynamicObjectWhirl(playerid,modelid,deg,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz, Float:orx, Float:ory, Float:radius,Float:sep,bool:facecenter=false)
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
				AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz);
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
                    orx, ory, angle+180.0,
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
CreateDynamicCircleIn(playerid,modelid,deg,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz, Float:orx, Float:ory, Float:radius,Float:sep,parts,bool:facecenter=false)
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
					AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz);
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
	                    orx, ory, angle+180.0,
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
CreateDynamicCircleOut(playerid,modelid,deg,Float:posx,Float:posy,Float:posz,Float:rx,Float:ry,Float:rz, Float:orx, Float:ory, Float:radius,Float:sep,parts,bool:facecenter=false)
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
					AddOBMObject(playerid,modelid, x, y, posz,rx,ry,rz);
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
	                    orx, ory, angle+180.0,
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
