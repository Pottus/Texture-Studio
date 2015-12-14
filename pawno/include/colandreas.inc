////////////////////////////////////////////////////////////////////////////////
// ColAndreas Plugin Include ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/*
Written by [uL]Pottus

Native Functions:
Add any remove building first before initializing the map
native CA_RemoveBuilding(modelid, Float:x, Float:y, Float:z, Float:radius)

Initialize the static map (used after CA_RemoveBuilding() )
native CA_Init();

Cast a line from p1 to p2 and return the point of collision
native CA_RayCastLine(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, &Float:x, &Float:y, &Float:z)

Cast a line that will return multiple layers of collision results (Results are unsorted in terms sequence of collisions)
native CA_RayCastMultiLine(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, Float:retx[], Float:rety[], Float:retz[], Float:retdist[], ModelIDs[], size = sizeof(retx));

Converts SAMP rx,ry,rz rotations to quaternion used by ColAndreas
native CA_EulerToQuat(Float:rx, Float:ry, Float:rz, &Float:x, &Float:y, &Float:z, &Float:w)

Convert quaternion to euler
native CA_QuatToEuler(Float:x, Float:y, Float:z, Float:w, Float:rx, Float:ry, Float:rz)

Create a collision object
native CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, bool:add = false)

Destroy a collision object
native CA_DestroyObject(index)

Stock functions:
Create a dynamic object (Streamer) with collision in ColAndreas static
CA_CreateDynamicObject_SC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, vw = -1, interior = -1, playerid = -1, Float:streamdist = 300.0, Float:drawdist = 300.0)
CA_CreateDynamicObjectEx_SC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 0.0, Float:streamdistance = 200.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players)

Create a object with collision in ColAndreas static
CA_CreateObject_SC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 300.0)

Create a dynamic object (Streamer) with collision in ColAndreas dynamic
CA_CreateDynamicObject_DC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, vw = -1, interior = -1, playerid = -1, Float:streamdist = 300.0, Float:drawdist = 300.0)
CA_CreateDynamicObjectEx_DC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 0.0, Float:streamdistance = 200.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players)

Create a object with collision in ColAndreas dynamic
CA_CreateObject_DC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 300.0)

Destroy a object with collision in ColAndreas
CA_DestroyObject_DC(index)

Destoys all objects streamer/regular
CA_DestroyAllObjects_DC()

MapAndreas replacement function
CA_FindZ_For2DCoord(Float:x, Float:y, &Float:z)

Explode ray casts in every direction
CA_RayCastExplode(Float:cX, Float:cY, Float:cZ, Float:Radius, Float:intensity = 20.0, Float:collisions[][3])

Checks if a player is standing on any surface (prevent animation exploit when falling)
CA_IsOnSurface(playerid, Float:tolerance=1.5)

Removes all barries this function only works BEFORE using CA_Init()
CA_RemoveBarriers()

Removes all dynamic breakable objects, also only works BEFORE using CA_Init()
CA_RemoveBreakableBuildings()

Checks if a player is in the water depth returns the lowest collision point found playerdepth returns
how deep the player is below the surface
CA_IsPlayerInWater(playerid, &Float:depth, &Float:playerdepth)

Checks if a player is near water (returns 0 if they are actually in the water) distance is the radius to check
Height is how high above the water to detect
CA_IsNearWater(playerid, Float:dist=3.0, Float:height=3.0)

// Check if a player is blocked by a wall
CA_IsBlocked(playerid, Float:dist=1.5, Float:height=0.5)


Notes:

Recommended loading order
- RemoveBuildings
- Init static map
- Add static objects

There is currently no support for virtual worlds / interior or per player with streamer objects

*/

// Used for other scripts to check if ColAndreas is being used
#define COLANDREAS

// Natives
native CA_Init();
native CA_RemoveBuilding(modelid, Float:x, Float:y, Float:z, Float:radius);
native CA_RayCastLine(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, &Float:x, &Float:y, &Float:z);
native CA_RayCastMultiLine(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, Float:retx[], Float:rety[], Float:retz[], Float:retdist[], ModelIDs[], size = sizeof(retx));
native CA_RayCastLineAngle(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, &Float:x, &Float:y, &Float:z, &Float:rx, &Float:ry, &Float:rz);
native CA_RayCastReflectionVector(Float:startx, Float:starty, Float:startz, Float:endx, Float:endy, Float:endz, &Float:x, &Float:y, &Float:z, &Float:nx, &Float:ny, &Float:nz);
native CA_RayCastLineNormal(Float:startx, Float:starty, Float:startz, Float:endx, Float:endy, Float:endz, &Float:x, &Float:y, &Float:z, &Float:nx, &Float:ny, &Float:nz);
native CA_ContactTest(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
native CA_EulerToQuat(Float:rx, Float:ry, Float:rz, &Float:x, &Float:y, &Float:z, &Float:w);
native CA_QuatToEuler(Float:x, Float:y, Float:z, Float:w, &Float:rx, &Float:ry, &Float:rz);
native CA_GetModelBoundingSphere(modelid, &Float:offx, &Float:offy, &Float:offz, &Float:radius);
native CA_GetModelBoundingBox(modelid, &Float:minx, &Float:miny, &Float:minz, &Float:maxx, &Float:maxy, &Float:maxz);

// Extended raycast function returns internal pointer of mapobject class instead of modelid
native CA_RayCastLineEx(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, &Float:x, &Float:y, &Float:z, &Float:rx, &Float:ry, &Float:rz, &Float:rw, &Float:cx, &Float:cy, &Float:cz);
native CA_RayCastLineAngleEx(Float:StartX, Float:StartY, Float:StartZ, Float:EndX, Float:EndY, Float:EndZ, &Float:x, &Float:y, &Float:z, &Float:rx, &Float:ry, &Float:rz, &Float:ocx, &Float:ocy, &Float:ocz, &Float:orx, &Float:ory, &Float:orz);

// Used internally
native CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, bool:add = false);
native CA_DestroyObject(index);
native CA_SetObjectPos(index, Float:x, Float:y, Float:z);
native CA_SetObjectRot(index, Float:rx, Float:ry, Float:rz);

// ColAndreas currently supports 50000 user collision objects (This can be raised as needed)
#define         MAX_CA_OBJECTS          10000

// Water object ID
#define         WATER_OBJECT            20000

// Object types (Player objects are supported as dynamic only)
#define         OBJECT_TYPE_OBJECT      0
#define         OBJECT_TYPE_DYNAMIC     1


#if !defined INFINITY
	#define INFINITY (Float:0x7F800000)
#endif

#if defined _Y_ITERATE_LOCAL_VERSION
	static stock Iterator:CA_Objects<MAX_CA_OBJECTS>;
#endif

enum CAOBJECTINFO
{
	ColdAndreadsID,
	ObjectID,
	ObjectType,

	#if !defined _Y_ITERATE_LOCAL_VERSION
		bool:ObjectUsed,
	#endif
}

static stock CA_ObjectList[MAX_CA_OBJECTS][CAOBJECTINFO];

// Static collision object functions (The index is not returned these can not be deleted!)
stock CA_CreateDynamicObjectEx_SC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 0.0, Float:streamdistance = 200.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players)
{
    new id = CreateDynamicObjectEx(modelid, x, y, z, rx, ry, rz, drawdistance, streamdistance, worlds, interiors, players, maxworlds, maxinteriors, maxplayers);
	CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
	return id;
}

stock CA_CreateDynamicObject_SC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, vw = -1, interior = -1, playerid = -1, Float:streamdist = 300.0, Float:drawdist = 300.0)
{
    new id = CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, vw, interior, playerid, streamdist, drawdist);
	CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
	return id;
}

stock CA_CreateObject_SC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 300.0)
{
	new id = CreateObject(modelid, x, y, z, rx, ry, rz, drawdistance);
	CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
	return id;
}

// Dynamic collision object functions (Removable)
stock CA_CreateDynamicObjectEx_DC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 0.0, Float:streamdistance = 200.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players)
{
	new index = -1;
   	#if defined _Y_ITERATE_LOCAL_VERSION
		index = Iter_Free(CA_Objects);
	#else
		for(new i = 0; i < MAX_CA_OBJECTS; i++)
		{
		    if(CA_ObjectList[i][ObjectUsed] == false)
		    {
		        index = i;
		        break;
		    }
		}
	#endif

	if(index > -1)
	{
		#if defined _Y_ITERATE_LOCAL_VERSION
			Iter_Add(CA_Objects, index);
		#else
		    CA_ObjectList[index][ObjectUsed] = true;
		#endif
	    CA_ObjectList[index][ObjectID] = CreateDynamicObjectEx(modelid, x, y, z, rx, ry, rz, drawdistance, streamdistance, worlds, interiors, players, maxworlds, maxinteriors, maxplayers);
		CA_ObjectList[index][ColdAndreadsID] = CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, true);
		CA_ObjectList[index][ObjectType] = OBJECT_TYPE_DYNAMIC;
	}
	return index;
}


stock CA_CreateDynamicObject_DC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, vw = -1, interior = -1, playerid = -1, Float:streamdist = 300.0, Float:drawdist = 300.0)
{
	new index = -1;
   	#if defined _Y_ITERATE_LOCAL_VERSION
		index = Iter_Free(CA_Objects);
	#else
		for(new i = 0; i < MAX_CA_OBJECTS; i++)
		{
		    if(CA_ObjectList[i][ObjectUsed] == false)
		    {
		        index = i;
		        break;
		    }
		}
	#endif

	if(index > -1)
	{
		#if defined _Y_ITERATE_LOCAL_VERSION
			Iter_Add(CA_Objects, index);
		#else
		    CA_ObjectList[index][ObjectUsed] = true;
		#endif
	    CA_ObjectList[index][ObjectID] = CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, vw, interior, playerid, streamdist, drawdist);
		CA_ObjectList[index][ColdAndreadsID] = CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, true);
		CA_ObjectList[index][ObjectType] = OBJECT_TYPE_DYNAMIC;
	}
	return index;
}

stock CA_CreateObject_DC(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 300.0)
{
	new index = -1;
   	#if defined _Y_ITERATE_LOCAL_VERSION
		index = Iter_Free(CA_Objects);
	#else
		for(new i = 0; i < MAX_CA_OBJECTS; i++)
		{
		    if(CA_ObjectList[i][ObjectUsed] == false)
		    {
		        index = i;
		        break;
		    }
		}
	#endif

	if(index > -1)
	{
		#if defined _Y_ITERATE_LOCAL_VERSION
			Iter_Add(CA_Objects, index);
		#else
		    CA_ObjectList[index][ObjectUsed] = true;
		#endif
	    CA_ObjectList[index][ObjectID] = CreateObject(modelid, x, y, z, rx, ry, rz, drawdistance);
		CA_ObjectList[index][ColdAndreadsID] = CA_CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, true);
		CA_ObjectList[index][ObjectType] = OBJECT_TYPE_OBJECT;
	}
	return index;
}


stock CA_DestroyObject_DC(index)
{
	// Out of bounds
	if(index < 0 || index >= MAX_CA_OBJECTS) return -1;
   	#if defined _Y_ITERATE_LOCAL_VERSION
		if(Iter_Contains(CA_Objects, index))
		{
			new next;
		    Iter_SafeRemove(CA_Objects, index, next);
   			if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_OBJECT) DestroyObject(CA_ObjectList[index][ObjectID]);
   			#if defined STREAMER_TYPE_OBJECT
		    	else if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_DYNAMIC) DestroyDynamicObject(CA_ObjectList[index][ObjectID]);
			#endif
		    CA_DestroyObject(CA_ObjectList[index][ColdAndreadsID]);
		    return next;
		}
	#else
        if(CA_ObjectList[index][ObjectUsed])
        {
   			if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_OBJECT) DestroyObject(CA_ObjectList[index][ObjectID]);
			#if defined STREAMER_TYPE_OBJECT
		    	else if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_DYNAMIC) DestroyDynamicObject(CA_ObjectList[index][ObjectID]);
			#endif
            CA_ObjectList[index][ObjectUsed] = false;
            CA_DestroyObject(CA_ObjectList[index][ColdAndreadsID]);
			return 1;
        }
   #endif
   return -1;
}

stock CA_SetObjectPos_DC(index, Float:x, Float:y, Float:z)
{
	// Out of bounds
	if(index < 0 || index >= MAX_CA_OBJECTS) return -1;
   	#if defined _Y_ITERATE_LOCAL_VERSION
		if(Iter_Contains(CA_Objects, index))
		{
			if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_OBJECT) SetObjectPos(CA_ObjectList[index][ObjectID], x, y, z);
			#if defined STREAMER_TYPE_OBJECT
			    else if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_DYNAMIC) SetDynamicObjectPos(CA_ObjectList[index][ObjectID], x, y, z);
			#endif
		    CA_SetObjectPos(CA_ObjectList[index][ColdAndreadsID], x, y, z);
		}
	#else
        if(CA_ObjectList[index][ObjectUsed])
        {
			if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_OBJECT) SetObjectPos(CA_ObjectList[index][ObjectID], x, y, z);
			#if defined STREAMER_TYPE_OBJECT
		    	else if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_DYNAMIC) SetDynamicObjectPos(CA_ObjectList[index][ObjectID], x, y, z);
			#endif
		    SetObjectPos(CA_ObjectList[index][ObjectID], x, y, z);
		    CA_SetObjectPos(CA_ObjectList[index][ColdAndreadsID], x, y, z);
			return 1;
        }
   #endif
   return -1;
}

stock CA_SetObjectRot_DC(index, Float:rx, Float:ry, Float:rz)
{
	// Out of bounds
	if(index < 0 || index >= MAX_CA_OBJECTS) return -1;
   	#if defined _Y_ITERATE_LOCAL_VERSION
		if(Iter_Contains(CA_Objects, index))
		{
		    if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_OBJECT) SetObjectRot(CA_ObjectList[index][ObjectID], rx, ry, rz);
			#if defined STREAMER_TYPE_OBJECT
				else if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_DYNAMIC) SetDynamicObjectRot(CA_ObjectList[index][ObjectID], rx, ry, rz);
			#endif
		    CA_SetObjectRot(CA_ObjectList[index][ColdAndreadsID], rx, ry, rz);
		}
	#else
        if(CA_ObjectList[index][ObjectUsed])
        {
		    if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_OBJECT) SetObjectRot(CA_ObjectList[index][ObjectID], rx, ry, rz);
			#if defined STREAMER_TYPE_OBJECT
				else if(CA_ObjectList[index][ObjectType] == OBJECT_TYPE_DYNAMIC) SetDynamicObjectRot(CA_ObjectList[index][ObjectID], rx, ry, rz);
			#endif
		    CA_SetObjectRot(CA_ObjectList[index][ColdAndreadsID], rx, ry, rz);
			return 1;
        }
   #endif
   return -1;
}

// Destroy all objects
stock CA_DestroyAllObjects_DC()
{
   	#if defined _Y_ITERATE_LOCAL_VERSION
		foreach(new i : CA_Objects)
		{
			if(CA_ObjectList[i][ObjectType] == OBJECT_TYPE_OBJECT) i = CA_DestroyObject_DC(i);
		}
	#else
		for(new i = 0; i < MAX_CA_OBJECTS; i++)
		{
		    if(CA_ObjectList[i][ObjectUsed])
		    {
				if(CA_ObjectList[i][ObjectType] == OBJECT_TYPE_OBJECT) CA_DestroyObject_DC(i);
	       }
		}

	#endif
}

// MapAndreas simulation
stock CA_FindZ_For2DCoord(Float:x, Float:y, &Float:z)
{
	if(CA_RayCastLine(x, y, 700.0, x, y, -1000.0, x, y, z)) return 1;
	return 0;
}

// Explode ray casts in every direction
stock CA_RayCastExplode(Float:cX, Float:cY, Float:cZ, Float:Radius, Float:intensity = 20.0, Float:collisions[][3])
{
	if(intensity < 1.0 || intensity > 360.0 || (((360.0 / intensity) - floatround((360.0 / intensity), floatround_floor)) * intensity))
		return 0;

	new index;
	for(new Float:lat = -180.0; lat < 180.0; lat += (intensity * 0.75))
	for(new Float:lon = -90.0; lon < 90.0; lon += intensity)
	{
		new Float:LAT = lat * 3.141593 / 180.0,
			Float:LON = lon * 3.141593 / 180.0,
			Float:x = -Radius * floatcos(LAT) * floatcos(LON),
			Float:y = Radius * floatcos(LAT) * floatsin(LON),
			Float:z = Radius * floatsin(LAT);
		
		if(CA_RayCastLine(cX, cY, cZ, cX + x, cY + y, cZ + z, x, y, z))
		{
			collisions[index][0] = x;
			collisions[index][1] = y;
			collisions[index][2] = z;
			index++;
		}
	}
	
	return index;
}

// Check if a player is standing on a surface
stock CA_IsPlayerOnSurface(playerid, Float:tolerance=1.5)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	// Check if player is actually on the ground
	if(!CA_RayCastLine(x, y, z, x, y, z-tolerance, x, y, z))
		return 0;
	return 1;
}

// remove all barries
stock CA_RemoveBarriers()
{
	static const BarrierIDS[] = {
	    16439, 16438, 16437, 16436, 4527, 4526, 4525, 4524,
	    4523, 4517, 4516, 4515, 4514, 4513, 4512, 4511, 4510,
	    4509, 4508, 4507, 4506, 4505, 4504, 1662
 	};
 	
 	for(new i = 0; i < sizeof(BarrierIDS); i++)
		CA_RemoveBuilding(BarrierIDS[i], 0.0, 0.0, 0.0, 4242.6407);

	return 1;
}

// remove all breakables
stock CA_RemoveBreakableBuildings()
{
	static const BreakableIDs[] = { 
	    625, 626, 627, 628, 629, 630, 631, 632, 633, 642, 643, 644, 646, 650, 716, 717, 737, 738, 792, 858, 881, 882, 883, 
	    884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 904, 905, 941, 955, 956, 959, 961, 990, 993, 996, 1209, 
	    1211, 1213, 1219, 1220, 1221, 1223, 1224, 1225, 1226, 1227, 1228, 1229, 1230, 1231, 1232, 1235, 1238, 1244, 1251, 
	    1255, 1257, 1262, 1264, 1265, 1270, 1280, 1281, 1282, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1293, 
	    1294, 1297, 1300, 1302, 1315, 1328, 1329, 1330, 1338, 1350, 1351, 1352, 1370, 1373, 1374, 1375, 1407, 1408, 1409, 
	    1410, 1411, 1412, 1413, 1414, 1415, 1417, 1418, 1419, 1420, 1421, 1422, 1423, 1424, 1425, 1426, 1428, 1429, 1431, 
	    1432, 1433, 1436, 1437, 1438, 1440, 1441, 1443, 1444, 1445, 1446, 1447, 1448, 1449, 1450, 1451, 1452, 1456, 1457, 
	    1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476, 
	    1477, 1478, 1479, 1480, 1481, 1482, 1483, 1514, 1517, 1520, 1534, 1543, 1544, 1545, 1551, 1553, 1554, 1558, 1564, 
	    1568, 1582, 1583, 1584, 1588, 1589, 1590, 1591, 1592, 1645, 1646, 1647, 1654, 1664, 1666, 1667, 1668, 1669, 1670, 
	    1672, 1676, 1684, 1686, 1775, 1776, 1949, 1950, 1951, 1960, 1961, 1962, 1975, 1976, 1977, 2647, 2663, 2682, 2683, 
	    2885, 2886, 2887, 2900, 2918, 2920, 2925, 2932, 2933, 2942, 2943, 2945, 2947, 2958, 2959, 2966, 2968, 2971, 2977, 
	    2987, 2988, 2989, 2991, 2994, 3006, 3018, 3019, 3020, 3021, 3022, 3023, 3024, 3029, 3032, 3036, 3058, 3059, 3067, 
	    3083, 3091, 3221, 3260, 3261, 3262, 3263, 3264, 3265, 3267, 3275, 3276, 3278, 3280, 3281, 3282, 3302, 3374, 3409, 
	    3460, 3516, 3794, 3795, 3797, 3853, 3855, 3864, 3884, 11103, 12840, 16627, 16628, 16629, 16630, 16631, 16632, 
	    16633, 16634, 16635, 16636, 16732, 17968 
	};
 	
 	for(new i = 0; i < sizeof(BreakableIDs); i++)
		CA_RemoveBuilding(BreakableIDs[i], 0.0, 0.0, 0.0, 4242.6407);

	return 1;
}

// Checks if player is in the water
stock CA_IsPlayerInWater(playerid, &Float:depth, &Float:playerdepth)
{
	new Float:x, Float:y, Float:z, Float:retx[10], Float:rety[10], Float:retz[10], Float: retdist[10], modelids[10];
	GetPlayerPos(playerid, x, y, z);
    new collisions = CA_RayCastMultiLine(x, y, z+1000.0, x, y, z-1000.0, retx, rety, retz, retdist, modelids, 10);
	if(collisions)
	{
		for(new i = 0; i < collisions; i++)
		{
		    if(modelids[i] == WATER_OBJECT)
		    {
				depth = INFINITY;

				for(new j = 0; j < collisions; j++)
				{
				    if(retz[j] < depth)
        				depth = retz[j];
				}

				depth = retz[i] - depth;
				if(depth < 0.001 && depth > -0.001)
					depth = 100.0;
				playerdepth = retz[i] - z;

			    if(playerdepth < -2.0)
					return 0;

		        return 1;
		    }
		}
	}
	return 0;
}

// Check if player is near water
stock CA_IsPlayerNearWater(playerid, Float:dist=3.0, Float:height=3.0)
{
	new Float:x, Float:y, Float:z, Float:tmp;
	GetPlayerPos(playerid, x, y, z);
	
	for(new i; i < 6; i++) 
		if(CA_RayCastLine(x + (dist * floatsin(i * 60.0, degrees)), y + (dist * floatcos(i * 60.0, degrees)), z + height, x + (dist * floatsin(i * 60.0, degrees)), y + (dist * floatcos(i * 60.0, degrees)), z - height, tmp, tmp, tmp) == WATER_OBJECT)
			return 1;
	return 0;
}

// Check if player is facing water
stock CA_IsPlayerFacingWater(playerid, Float:dist=3.0, Float:height=3.0)
{
    new Float:x, Float:y, Float:z, Float:r;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, r);

    if(CA_RayCastLine(x + (dist * floatsin(-r, degrees)), y + (dist * floatcos(-r, degrees)), z, x + (dist * floatsin(-r, degrees)), y + (dist * floatcos(-r, degrees)), z - height, tmp, tmp, tmp) == WATER_OBJECT)
        return 1;
    return 0;
}

// Checks if a player is blocked by a wall
stock CA_IsPlayerBlocked(playerid, Float:dist=1.5, Float:height=0.5)
{
	new Float:x, Float:y, Float:z, Float:endx, Float:endy, Float:fa;
	GetPlayerPos(playerid, x, y, z);
	z -= 1.0 + height;
	GetPlayerFacingAngle(playerid, fa);

	endx = (x + dist * floatsin(-fa,degrees));
	endy = (y + dist * floatcos(-fa,degrees));
	if(CA_RayCastLine(x, y, z, endx, endy, z, x, y, z))
		return 1;
	return 0;
}

stock Float:CA_GetRoomHeight(Float:x, Float:y, Float:z)
{
	new Float:fx, Float:fy, Float:fz, Float:cx, Float:cy, Float:cz;
	if(CA_RayCastLine(x, y, z, x, y, z-1000.0, fx, fy, fz))
	{
	    if(CA_RayCastLine(x, y, z, x, y, z+1000.0, cx, cy, cz))
			return floatsqroot(((fx-cx)*(fx-cx))+((fy-cy)*(fy-cy))+((fz-cz)*(fz-cz)));
	}
	return 0.0;
}

stock Float:CA_GetRoomCenter(Float:x, Float:y, Float:z, &Float:m_x, &Float:m_y)
{
	new Float:pt1x, Float:pt1y,
		Float:pt2x, Float:pt2y,
		Float:pt3x, Float:pt3y,
		Float:tmp;

	if(!CA_RayCastLine(x, y, z, x + 1000.0 * floatcos(0.0, degrees), y + 1000.0 * floatsin(0.0, degrees), z, pt1x, pt1y, tmp) ||
		!CA_RayCastLine(x, y, z, x + 1000.0 * floatcos(120.0, degrees), y + 1000.0 * floatsin(120.0, degrees), z, pt2x, pt2y, tmp) ||
		!CA_RayCastLine(x, y, z, x + 1000.0 * floatcos(-120.0, degrees), y + 1000.0 * floatsin(-120.0, degrees), z, pt3x, pt3y, tmp))
		return -1.0;
	
	new Float:yDelta_a = pt2y - pt1y,
		Float:xDelta_a = pt2x - pt1x,
		Float:yDelta_b = pt3y - pt2y,
		Float:xDelta_b = pt3x - pt2x;
	
	if (floatabs(xDelta_a) <= 0.000000001 && floatabs(yDelta_b) <= 0.000000001) {
		m_x = 0.5 * (pt2x + pt3x);
		m_y = 0.5 * (pt1y + pt2y);
		return VectorSize(m_x - pt1x, m_y - pt1y, 0.0);
	}
	
	new Float:aSlope = yDelta_a / xDelta_a,
		Float:bSlope = yDelta_b / xDelta_b;
	
	if (floatabs(aSlope-bSlope) <= 0.000000001)
		return -1.0;

	m_x = (aSlope * bSlope * (pt1y - pt3y) + bSlope * (pt1x + pt2x) - aSlope * (pt2x + pt3x)) / (2.0 * (bSlope - aSlope));
	m_y = -1.0 * (m_x - (pt1x + pt2x) / 2.0) / aSlope + (pt1y + pt2y) / 2.0;

	return VectorSize(m_x - pt1x, m_y - pt1y, 0.0);
}


// Hooked functions
public OnFilterScriptExit()
{
	CA_DestroyAllObjects_DC();
	if (funcidx("CA_OnFilterScriptExit") != -1)
  	{
    	return CallLocalFunction("CA_OnFilterScriptExit", "");
  	}
  	return 1;
 }

#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit CA_OnFilterScriptExit

forward CA_OnFilterScriptExit();


public OnGameModeExit()
{
	CA_DestroyAllObjects_DC();
	if (funcidx("CA_OnGameModeExit") != -1)
  	{
    	return CallLocalFunction("CA_OnGameModeExit", "");
  	}
  	return 1;
 }

#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit CA_OnGameModeExit

forward CA_OnGameModeExit();
