/*
 * Copyright (C) 2014 Incognito
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <a_samp>

// Definitions

#define STREAMER_TYPE_OBJECT (0)
#define STREAMER_TYPE_PICKUP (1)
#define STREAMER_TYPE_CP (2)
#define STREAMER_TYPE_RACE_CP (3)
#define STREAMER_TYPE_MAP_ICON (4)
#define STREAMER_TYPE_3D_TEXT_LABEL (5)
#define STREAMER_TYPE_AREA (6)

#define STREAMER_AREA_TYPE_CIRCLE (0)
#define STREAMER_AREA_TYPE_RECTANGLE (1)
#define STREAMER_AREA_TYPE_SPHERE (2)
#define STREAMER_AREA_TYPE_CUBE (3)
#define STREAMER_AREA_TYPE_POLYGON (4)

#define STREAMER_OBJECT_TYPE_GLOBAL (0)
#define STREAMER_OBJECT_TYPE_PLAYER (1)
#define STREAMER_OBJECT_TYPE_DYNAMIC (2)

#if !defined FLOAT_INFINITY
    #define FLOAT_INFINITY (Float:0x7F800000)
#endif

// Include File Version

public Streamer_IncludeFileVersion = 0x27201;

#pragma unused Streamer_IncludeFileVersion

// Enumerator

enum
{
	E_STREAMER_ATTACHED_OBJECT,
	E_STREAMER_ATTACHED_PLAYER,
	E_STREAMER_ATTACHED_VEHICLE,
	E_STREAMER_ATTACH_OFFSET_X,
	E_STREAMER_ATTACH_OFFSET_Y,
	E_STREAMER_ATTACH_OFFSET_Z,
	E_STREAMER_ATTACH_R_X,
	E_STREAMER_ATTACH_R_Y,
	E_STREAMER_ATTACH_R_Z,
	E_STREAMER_ATTACH_X,
	E_STREAMER_ATTACH_Y,
	E_STREAMER_ATTACH_Z,
	E_STREAMER_COLOR,
	E_STREAMER_DRAW_DISTANCE,
	E_STREAMER_EXTRA_ID,
	E_STREAMER_INTERIOR_ID,
	E_STREAMER_MAX_X,
	E_STREAMER_MAX_Y,
	E_STREAMER_MAX_Z,
	E_STREAMER_MIN_X,
	E_STREAMER_MIN_Y,
	E_STREAMER_MIN_Z,
	E_STREAMER_MODEL_ID,
	E_STREAMER_MOVE_R_X,
	E_STREAMER_MOVE_R_Y,
	E_STREAMER_MOVE_R_Z,
	E_STREAMER_MOVE_SPEED,
	E_STREAMER_MOVE_X,
	E_STREAMER_MOVE_Y,
	E_STREAMER_MOVE_Z,
	E_STREAMER_NEXT_X,
	E_STREAMER_NEXT_Y,
	E_STREAMER_NEXT_Z,
	E_STREAMER_PLAYER_ID,
	E_STREAMER_R_X,
	E_STREAMER_R_Y,
	E_STREAMER_R_Z,
	E_STREAMER_SIZE,
	E_STREAMER_STREAM_DISTANCE,
	E_STREAMER_STYLE,
	E_STREAMER_TEST_LOS,
	E_STREAMER_TYPE,
	E_STREAMER_WORLD_ID,
	E_STREAMER_X,
	E_STREAMER_Y,
	E_STREAMER_Z
}

// Natives (Settings)

native Streamer_GetTickRate();
native Streamer_SetTickRate(rate);
native Streamer_GetMaxItems(type);
native Streamer_SetMaxItems(type, items);
native Streamer_GetVisibleItems(type);
native Streamer_SetVisibleItems(type, items);
native Streamer_GetCellDistance(&Float:distance);
native Streamer_SetCellDistance(Float:distance);
native Streamer_GetCellSize(&Float:size);
native Streamer_SetCellSize(Float:size);

// Natives (Updates)

native Streamer_ProcessActiveItems();
native Streamer_ToggleIdleUpdate(playerid, toggle);
native Streamer_IsToggleIdleUpdate(playerid);
native Streamer_ToggleItemUpdate(playerid, type, toggle);
native Streamer_IsToggleItemUpdate(playerid, type);
native Streamer_Update(playerid);
native Streamer_UpdateEx(playerid, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1);

// Natives (Data Manipulation)

native Streamer_GetFloatData(type, {Text3D,_}:id, data, &Float:result);
native Streamer_SetFloatData(type, {Text3D,_}:id, data, Float:value);
native Streamer_GetIntData(type, {Text3D,_}:id, data);
native Streamer_SetIntData(type, {Text3D,_}:id, data, value);
native Streamer_GetArrayData(type, {Text3D,_}:id, data, dest[], maxlength = sizeof dest);
native Streamer_SetArrayData(type, {Text3D,_}:id, data, const src[], maxlength = sizeof src);
native Streamer_IsInArrayData(type, {Text3D,_}:id, data, value);
native Streamer_AppendArrayData(type, {Text3D,_}:id, data, value);
native Streamer_RemoveArrayData(type, {Text3D,_}:id, data, value);
native Streamer_GetUpperBound(type);

// Natives (Miscellaneous)

native Streamer_GetDistanceToItem(Float:x, Float:y, Float:z, type, {Text3D,_}:id, &Float:distance, dimensions = 3);
native Streamer_GetItemInternalID(playerid, type, {Text3D,_}:streamerid);
native Streamer_GetItemStreamerID(playerid, type, {Text3D,_}:internalid);
native Streamer_IsItemVisible(playerid, type, {Text3D,_}:id);
native Streamer_DestroyAllVisibleItems(playerid, type, serverwide = 1);
native Streamer_CountVisibleItems(playerid, type, serverwide = 1);
native Streamer_DestroyAllItems(type, serverwide = 1);
native Streamer_CountItems(type, serverwide = 1);

// Natives (Objects)

native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 200.0, Float:drawdistance = 0.0);
native DestroyDynamicObject(objectid);
native IsValidDynamicObject(objectid);
native SetDynamicObjectPos(objectid, Float:x, Float:y, Float:z);
native GetDynamicObjectPos(objectid, &Float:x, &Float:y, &Float:z);
native SetDynamicObjectRot(objectid, Float:rx, Float:ry, Float:rz);
native GetDynamicObjectRot(objectid, &Float:rx, &Float:ry, &Float:rz);
native MoveDynamicObject(objectid, Float:x, Float:y, Float:z, Float:speed, Float:rx = -1000.0, Float:ry = -1000.0, Float:rz = -1000.0);
native StopDynamicObject(objectid);
native IsDynamicObjectMoving(objectid);
native AttachCameraToDynamicObject(playerid, objectid);
native AttachDynamicObjectToVehicle(objectid, vehicleid, Float:offsetx, Float:offsety, Float:offsetz, Float:rx, Float:ry, Float:rz);
native EditDynamicObject(playerid, objectid);
native GetDynamicObjectMaterial(objectid, materialindex, &modelid, txdname[], texturename[], &materialcolor, maxtxdname = sizeof txdname, maxtexturename = sizeof texturename);
native SetDynamicObjectMaterial(objectid, materialindex, modelid, const txdname[], const texturename[], materialcolor = 0);
native GetDynamicObjectMaterialText(objectid, materialindex, text[], &materialsize, fontface[], &fontsize, &bold, &fontcolor, &backcolor, &textalignment, maxtext = sizeof text, maxfontface = sizeof fontface);
native SetDynamicObjectMaterialText(objectid, materialindex, const text[], materialsize = OBJECT_MATERIAL_SIZE_256x128, const fontface[] = "Arial", fontsize = 24, bold = 1, fontcolor = 0xFFFFFFFF, backcolor = 0, textalignment = 0);

// Natives (Pickups)

native CreateDynamicPickup(modelid, type, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 100.0);
native DestroyDynamicPickup(pickupid);
native IsValidDynamicPickup(pickupid);

// Natives (Checkpoints)

native CreateDynamicCP(Float:x, Float:y, Float:z, Float:size, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 100.0);
native DestroyDynamicCP(checkpointid);
native IsValidDynamicCP(checkpointid);
native TogglePlayerDynamicCP(playerid, checkpointid, toggle);
native TogglePlayerAllDynamicCPs(playerid, toggle);
native IsPlayerInDynamicCP(playerid, checkpointid);
native GetPlayerVisibleDynamicCP(playerid);

// Natives (Race Checkpoints)

native CreateDynamicRaceCP(type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 100.0);
native DestroyDynamicRaceCP(checkpointid);
native IsValidDynamicRaceCP(checkpointid);
native TogglePlayerDynamicRaceCP(playerid, checkpointid, toggle);
native TogglePlayerAllDynamicRaceCPs(playerid, toggle);
native IsPlayerInDynamicRaceCP(playerid, checkpointid);
native GetPlayerVisibleDynamicRaceCP(playerid);

// Natives (Map Icons)

native CreateDynamicMapIcon(Float:x, Float:y, Float:z, type, color, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 100.0, style = MAPICON_LOCAL);
native DestroyDynamicMapIcon(iconid);
native IsValidDynamicMapIcon(iconid);

// Natives (3D Text Labels)

native Text3D:CreateDynamic3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer = INVALID_PLAYER_ID, attachedvehicle = INVALID_VEHICLE_ID, testlos = 0, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 100.0);
native DestroyDynamic3DTextLabel(Text3D:id);
native IsValidDynamic3DTextLabel(Text3D:id);
native GetDynamic3DTextLabelText(Text3D:id, text[], maxlength = sizeof text);
native UpdateDynamic3DTextLabelText(Text3D:id, color, const text[]);

// Natives (Areas)

native CreateDynamicCircle(Float:x, Float:y, Float:size, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicRectangle(Float:minx, Float:miny, Float:maxx, Float:maxy, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicSphere(Float:x, Float:y, Float:z, Float:size, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicCube(Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicPolygon(Float:points[], Float:minz = -FLOAT_INFINITY, Float:maxz = FLOAT_INFINITY, maxpoints = sizeof points, worldid = -1, interiorid = -1, playerid = -1);
native DestroyDynamicArea(areaid);
native IsValidDynamicArea(areaid);
native GetDynamicPolygonPoints(areaid, Float:points[], maxlength = sizeof points);
native GetDynamicPolygonNumberPoints(areaid);
native TogglePlayerDynamicArea(playerid, areaid, toggle);
native TogglePlayerAllDynamicAreas(playerid, toggle);
native IsPlayerInDynamicArea(playerid, areaid, recheck = 0);
native IsPlayerInAnyDynamicArea(playerid, recheck = 0);
native IsAnyPlayerInDynamicArea(areaid, recheck = 0);
native IsAnyPlayerInAnyDynamicArea(recheck = 0);
native GetPlayerDynamicAreas(playerid, areas[], maxlength = sizeof areas);
native GetPlayerNumberDynamicAreas(playerid);
native IsPointInDynamicArea(areaid, Float:x, Float:y, Float:z);
native IsPointInAnyDynamicArea(Float:x, Float:y, Float:z);
native AttachDynamicAreaToObject(areaid, objectid, type = STREAMER_OBJECT_TYPE_DYNAMIC, playerid = INVALID_PLAYER_ID);
native AttachDynamicAreaToPlayer(areaid, playerid);
native AttachDynamicAreaToVehicle(areaid, vehicleid);

// Natives (Extended)

native CreateDynamicObjectEx(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:drawdistance = 0.0, Float:streamdistance = 200.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicPickupEx(modelid, type, Float:x, Float:y, Float:z, Float:streamdistance = 100.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicCPEx(Float:x, Float:y, Float:z, Float:size, Float:streamdistance = 100.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicRaceCPEx(type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size, Float:streamdistance = 100.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicMapIconEx(Float:x, Float:y, Float:z, type, color, style = MAPICON_LOCAL, Float:streamdistance = 100.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native Text3D:CreateDynamic3DTextLabelEx(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer = INVALID_PLAYER_ID, attachedvehicle = INVALID_VEHICLE_ID, testlos = 0, Float:streamdistance = 100.0, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicCircleEx(Float:x, Float:y, Float:size, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicRectangleEx(Float:minx, Float:miny, Float:maxx, Float:maxy, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicSphereEx(Float:x, Float:y, Float:z, Float:size, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicCubeEx(Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);
native CreateDynamicPolygonEx(Float:points[], Float:minz = -FLOAT_INFINITY, Float:maxz = FLOAT_INFINITY, maxpoints = sizeof points, worlds[] = { -1 }, interiors[] = { -1 }, players[] = { -1 }, maxworlds = sizeof worlds, maxinteriors = sizeof interiors, maxplayers = sizeof players);

// Natives (Internal)

native Streamer_CallbackHook(callback, {Float,_}:...);

// Natives (Deprecated)

native Streamer_TickRate(rate);
native Streamer_MaxItems(type, items);
native Streamer_VisibleItems(type, items);
native Streamer_CellDistance(Float:distance);
native Streamer_CellSize(Float:size);

native DestroyAllDynamicObjects();
native CountDynamicObjects();
native DestroyAllDynamicPickups();
native CountDynamicPickups();
native DestroyAllDynamicCPs();
native CountDynamicCPs();
native DestroyAllDynamicRaceCPs();
native CountDynamicRaceCPs();
native DestroyAllDynamicMapIcons();
native CountDynamicMapIcons();
native DestroyAllDynamic3DTextLabels();
native CountDynamic3DTextLabels();
native DestroyAllDynamicAreas();
native CountDynamicAreas();

// Callbacks

forward OnDynamicObjectMoved(objectid);
forward OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
forward OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z);
forward OnPlayerShootDynamicObject(playerid, weaponid, objectid, Float:x, Float:y, Float:z);
forward OnPlayerPickUpDynamicPickup(playerid, pickupid);
forward OnPlayerEnterDynamicCP(playerid, checkpointid);
forward OnPlayerLeaveDynamicCP(playerid, checkpointid);
forward OnPlayerEnterDynamicRaceCP(playerid, checkpointid);
forward OnPlayerLeaveDynamicRaceCP(playerid, checkpointid);
forward OnPlayerEnterDynamicArea(playerid, areaid);
forward OnPlayerLeaveDynamicArea(playerid, areaid);

// Callback Hook Section

#define STREAMER_OPC (0)
#define STREAMER_OPDC (1)
#define STREAMER_OPEO (2)
#define STREAMER_OPSO (3)
#define STREAMER_OPPP (4)
#define STREAMER_OPEC (5)
#define STREAMER_OPLC (6)
#define STREAMER_OPERC (7)
#define STREAMER_OPLRC (8)
#define STREAMER_OPWS (9)

public OnPlayerConnect(playerid)
{
	Streamer_CallbackHook(STREAMER_OPC, playerid);
	#if defined Streamer_OnPlayerConnect
		return Streamer_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerConnect
	forward Streamer_OnPlayerConnect(playerid);
#endif
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Streamer_OnPlayerConnect

public OnPlayerDisconnect(playerid, reason)
{
	Streamer_CallbackHook(STREAMER_OPDC, playerid, reason);
	#if defined Streamer_OnPlayerDisconnect
		return Streamer_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerDisconnect
	forward Streamer_OnPlayerDisconnect(playerid, reason);
#endif
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Streamer_OnPlayerDisconnect

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if (playerobject)
	{
		Streamer_CallbackHook(STREAMER_OPEO, playerid, playerobject, objectid, response, fX, fY, fZ, fRotX, fRotY, fRotZ);
	}
	#if defined Streamer_OnPlayerEditObject
		return Streamer_OnPlayerEditObject(playerid, playerobject, objectid, response, fX, fY, fZ, fRotX, fRotY, fRotZ);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerEditObject
	forward Streamer_OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ);
#endif
#if defined _ALS_OnPlayerEditObject
	#undef OnPlayerEditObject
#else
	#define _ALS_OnPlayerEditObject
#endif
#define OnPlayerEditObject Streamer_OnPlayerEditObject

public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{
	if (type == SELECT_OBJECT_PLAYER_OBJECT)
	{
		Streamer_CallbackHook(STREAMER_OPSO, playerid, type, objectid, modelid, fX, fY, fZ);
	}
	#if defined Streamer_OnPlayerSelectObject
		return Streamer_OnPlayerSelectObject(playerid, type, objectid, modelid, fX, fY, fZ);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerSelectObject
	forward Streamer_OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ);
#endif
#if defined _ALS_OnPlayerSelectObject
	#undef OnPlayerSelectObject
#else
	#define _ALS_OnPlayerSelectObject
#endif
#define OnPlayerSelectObject Streamer_OnPlayerSelectObject

public OnPlayerPickUpPickup(playerid, pickupid)
{
	Streamer_CallbackHook(STREAMER_OPPP, playerid, pickupid);
	#if defined Streamer_OnPlayerPickUpPickup
		return Streamer_OnPlayerPickUpPickup(playerid, pickupid);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerPickUpPickup
	forward Streamer_OnPlayerPickUpPickup(playerid, pickupid);
#endif
#if defined _ALS_OnPlayerPickUpPickup
	#undef OnPlayerPickUpPickup
#else
	#define _ALS_OnPlayerPickUpPickup
#endif
#define OnPlayerPickUpPickup Streamer_OnPlayerPickUpPickup

public OnPlayerEnterCheckpoint(playerid)
{
	Streamer_CallbackHook(STREAMER_OPEC, playerid);
	#if defined Streamer_OnPlayerEnterCP
		return Streamer_OnPlayerEnterCP(playerid);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerEnterCP
	forward Streamer_OnPlayerEnterCP(playerid);
#endif
#if defined _ALS_OnPlayerEnterCheckpoint
	#undef OnPlayerEnterCheckpoint
#else
	#define _ALS_OnPlayerEnterCheckpoint
#endif
#define OnPlayerEnterCheckpoint Streamer_OnPlayerEnterCP

public OnPlayerLeaveCheckpoint(playerid)
{
	Streamer_CallbackHook(STREAMER_OPLC, playerid);
	#if defined Streamer_OnPlayerLeaveCP
		return Streamer_OnPlayerLeaveCP(playerid);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerLeaveCP
	forward Streamer_OnPlayerLeaveCP(playerid);
#endif
#if defined _ALS_OnPlayerLeaveCheckpoint
	#undef OnPlayerLeaveCheckpoint
#else
	#define _ALS_OnPlayerLeaveCheckpoint
#endif
#define OnPlayerLeaveCheckpoint Streamer_OnPlayerLeaveCP

public OnPlayerEnterRaceCheckpoint(playerid)
{
	Streamer_CallbackHook(STREAMER_OPERC, playerid);
	#if defined Streamer_OnPlayerEnterRaceCP
		return Streamer_OnPlayerEnterRaceCP(playerid);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerEnterRaceCP
	forward Streamer_OnPlayerEnterRaceCP(playerid);
#endif
#if defined _ALS_OnPlayerEnterRaceCP
	#undef OnPlayerEnterRaceCheckpoint
#else
	#define _ALS_OnPlayerEnterRaceCP
#endif
#define OnPlayerEnterRaceCheckpoint Streamer_OnPlayerEnterRaceCP

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	Streamer_CallbackHook(STREAMER_OPLRC, playerid);
	#if defined Streamer_OnPlayerLeaveRaceCP
		return Streamer_OnPlayerLeaveRaceCP(playerid);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerLeaveRaceCP
	forward Streamer_OnPlayerLeaveRaceCP(playerid);
#endif
#if defined _ALS_OnPlayerLeaveRaceCP
	#undef OnPlayerLeaveRaceCheckpoint
#else
	#define _ALS_OnPlayerLeaveRaceCP
#endif
#define OnPlayerLeaveRaceCheckpoint Streamer_OnPlayerLeaveRaceCP

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if (hittype == BULLET_HIT_TYPE_PLAYER_OBJECT)
	{
		Streamer_CallbackHook(STREAMER_OPWS, playerid, weaponid, hittype, hitid, fX, fY, fZ);
	}
	#if defined Streamer_OnPlayerWeaponShot
		return Streamer_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, fX, fY, fZ);
	#else
		return 1;
	#endif
}

#if defined Streamer_OnPlayerWeaponShot
	forward Streamer_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif
#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
#define OnPlayerWeaponShot Streamer_OnPlayerWeaponShot
