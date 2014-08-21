/*----------------------------------------------------------------------------*\
					=======================================
					  YSI - YSI Server Includes functions
					=======================================
Description:
	Lists all the functions available in YSI for PAWNO.
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 (the "License"); you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the YSI group include.
	
	The Initial Developer of the Original Code is Alex "Y_Less" Cole.
	Portions created by the Initial Developer are Copyright (C) 2011
	the Initial Developer. All Rights Reserved.
	
	Contributors:
		ZeeX, koolk, JoeBullet/Google63, g_aSlice/Slice
	
	Thanks:
		JoeBullet/Google63 - Handy arbitrary ASM jump code using SCTRL.
		ZeeX - Very productive conversations.
		koolk - IsPlayerinAreaEx code.
		TheAlpha - Danish translation.
		breadfish - German translation.
		Fireburn - Dutch translation.
		yom - French translation.
		50p - Polish translation.
		Zamaroht - Spanish translation.
		Dracoblue, sintax, mabako, Xtreme, other coders - Producing other modes
			for me to strive to better.
		Pixels^ - Running XScripters where the idea was born.
		Matite - Pestering me to release it and using it.
	
	Very special thanks to:
		Thiadmer - PAWN, whose limits continue to amaze me!
		Kye/Kalcor - SA:MP.
		SA:MP Team past, present and future - SA:MP.
	
Version:
	1.0
Changelog:
	25/02/12:
		First version
\*----------------------------------------------------------------------------*/

#include <YSI\internal\y_version>

/*

native 
native __y_als__();
native 
native 
native 

*/

// CAN'T include by default.
//#include <YSI\y_als>

/*

native 
native __y_amx__();
native 
native 
native AMX_GetBaseCount(E_AMX_TABLE:table, &base, &count)
native AMX_GetGlobalAddress(...);
native AMX_Read(addr)
native AMX_Write(addr, value)
native AMX_ReadString(addr, str[], len = sizeof (str))
native AMX_WriteString(addr, const str[], len = sizeof (str))
native AMX_ReadArray(addr, dest[], len = sizeof (dest))
native AMX_WriteArray(addr, const src[], len = sizeof (src))
native 
native AMX_GetPublicEntry(idx, &buffer, const pattern[] = "")
native AMX_GetNativeEntry(idx, &buffer, const pattern[] = "")
native AMX_GetLibraryEntry(idx, &buffer, const pattern[] = "")
native AMX_GetPubvarEntry(idx, &buffer, const pattern[] = "")
native AMX_GetTagEntry(idx, &buffer, const pattern[] = "")
native AMX_GetEntry(E_AMX_TABLE:table, idx, &buffer, const pattern[] = "")
native 
native AMX_GetPublicEntryPrefix(idx, &buffer, pattern)
native AMX_GetNativeEntryPrefix(idx, &buffer, pattern)
native AMX_GetLibraryEntryPrefix(idx, &buffer, pattern)
native AMX_GetPubvarEntryPrefix(idx, &buffer, pattern)
native AMX_GetTagEntryPrefix(idx, &buffer, pattern)
native AMX_GetEntryPrefix(E_AMX_TABLE:table, idx, &buffer, pattern)
native 
native AMX_GetPublicEntrySuffix(idx, &buffer, pattern)
native AMX_GetNativeEntrySuffix(idx, &buffer, pattern)
native AMX_GetLibraryEntrySuffix(idx, &buffer, pattern)
native AMX_GetPubvarEntrySuffix(idx, &buffer, pattern)
native AMX_GetTagEntrySuffix(idx, &buffer, pattern)
native AMX_GetEntrySuffix(E_AMX_TABLE:table, idx, &buffer, pattern)
native 
native AMX_GetPublicName(idx, buffer[32], const pattern[] = "")
native AMX_GetNativeName(idx, buffer[32], const pattern[] = "")
native AMX_GetLibraryName(idx, buffer[32], const pattern[] = "")
native AMX_GetPubvarName(idx, buffer[32], const pattern[] = "")
native AMX_GetTagName(idx, buffer[32], const pattern[] = "")
native AMX_GetName(E_AMX_TABLE:table, idx, buffer[32], const pattern[] = "")
native 
native AMX_GetPublicNamePrefix(idx, buffer[32], pattern)
native AMX_GetNativeNamePrefix(idx, buffer[32], pattern)
native AMX_GetLibraryNamePrefix(idx, buffer[32], pattern)
native AMX_GetPubvarNamePrefix(idx, buffer[32], pattern)
native AMX_GetTagNamePrefix(idx, buffer[32], pattern)
native AMX_GetNamePrefix(E_AMX_TABLE:table, idx, buffer[32], pattern)
native 
native AMX_GetPublicNameSuffix(idx, buffer[32], pattern)
native AMX_GetNativeNameSuffix(idx, buffer[32], pattern)
native AMX_GetLibraryNameSuffix(idx, buffer[32], pattern)
native AMX_GetPubvarNameSuffix(idx, buffer[32], pattern)
native AMX_GetTagNameSuffix(idx, buffer[32], pattern)
native AMX_GetNameSuffix(E_AMX_TABLE:table, idx, buffer[32], pattern)
native 
native AMX_GetPublicPointer(idx, &buffer, const pattern[] = "")
native AMX_GetNativePointer(idx, &buffer, const pattern[] = "")
native AMX_GetLibraryPointer(idx, &buffer, const pattern[] = "")
native AMX_GetPubvarPointer(idx, &buffer, const pattern[] = "")
native AMX_GetTagPointer(idx, &buffer, const pattern[] = "")
native AMX_GetPointer(E_AMX_TABLE:table, idx, &buffer, const pattern[] = "")
native 
native AMX_GetPublicPointerPrefix(idx, &buffer, pattern)
native AMX_GetNativePointerPrefix(idx, &buffer, pattern)
native AMX_GetLibraryPointerPrefix(idx, &buffer, pattern)
native AMX_GetPubvarPointerPrefix(idx, &buffer, pattern)
native AMX_GetTagPointerPrefix(idx, &buffer, pattern)
native AMX_GetPointerPrefix(E_AMX_TABLE:table, idx, &buffer, pattern)
native 
native AMX_GetPublicPointerSuffix(idx, &buffer, pattern)
native AMX_GetNativePointerSuffix(idx, &buffer, pattern)
native AMX_GetLibraryPointerSuffix(idx, &buffer, pattern)
native AMX_GetPubvarPointerSuffix(idx, &buffer, pattern)
native AMX_GetTagPointerSuffix(idx, &buffer, pattern)
native AMX_GetPointerSuffix(E_AMX_TABLE:table, idx, &buffer, pattern)
native 
native AMX_GetPublicValue(idx, &buffer, const pattern[] = "")
native AMX_GetNativeValue(idx, &buffer, const pattern[] = "")
native AMX_GetLibraryValue(idx, &buffer, const pattern[] = "")
native AMX_GetPubvarValue(idx, &buffer, const pattern[] = "")
native AMX_GetTagValue(idx, &buffer, const pattern[] = "")
native AMX_GetValue(E_AMX_TABLE:table, idx, &buffer, const pattern[] = "")
native 
native AMX_GetPublicValuePrefix(idx, &buffer, pattern)
native AMX_GetNativeValuePrefix(idx, &buffer, pattern)
native AMX_GetLibraryValuePrefix(idx, &buffer, pattern)
native AMX_GetPubvarValuePrefix(idx, &buffer, pattern)
native AMX_GetTagValuePrefix(idx, &buffer, pattern)
native AMX_GetValuePrefix(E_AMX_TABLE:table, idx, &buffer, pattern)
native 
native AMX_GetPublicValueSuffix(idx, &buffer, pattern)
native AMX_GetNativeValueSuffix(idx, &buffer, pattern)
native AMX_GetLibraryValueSuffix(idx, &buffer, pattern)
native AMX_GetPubvarValueSuffix(idx, &buffer, pattern)
native AMX_GetTagValueSuffix(idx, &buffer, pattern)
native AMX_GetValueSuffix(E_AMX_TABLE:table, idx, &buffer, pattern)
native 

*/

#include <YSI\y_amx>

/*

native 
native __y_areas__();
native 
native 
native Area_AddCube(Float:x0, Float:y0, Float:z0, Float:x1, Float:y1, Float:z1);
native Area_AddBox(Float:minx, Float:miny, Float:maxx, Float:maxy);
native Area_AddCircle(Float:x, Float:y, Float:r, Float:h = FLOAT_INFINITY)
native Area_AddSphere(Float:x, Float:y, Float:z, Float:r);
native Area_AddPoly(Float:x1, Float:y1, Float:x2, Float:y2, Float:x3, Float:y3, Float:...);
native Area_Delete(area);
native Area_GetPlayerArea(playerid);
native Area_SetPlayer(area, playerid, bool:set);
native bool:Area_GetPlayer(area, playerid);
native Area_SetAllPlayers(area, bool:set);
native Area_SetWorld(area, world, bool:set);
native bool:Area_GetWorld(area, world);
native Area_SetAllWorlds(area, bool:set);
native bool:Area_IsValid(area);
native bool:Area_IsEmpty(area);
native 

*/

//#include <YSI\y_areas>

/*

native 
native __y_bintree__();
native 
native 
native Bintree_Generate(BinaryTree:output<>, input[][E_BINTREE_INPUT], size);
native Bintree_Reset(BinaryTree:tree<>, pointer = 0);
native Bintree_FindValue(BinaryTree:tree<>, value, &cont = 0, &old = 0);
native Bintree_Add(BinaryTree:data<>, pointer, value, offset, maxsize = sizeof (data));
native Bintree_Delete(BinaryTree:source<>, index, count);
native Bintree_UpdatePointers(BinaryTree:data<>, offset, size, mod = -1);
native 

*/

#include <YSI\y_bintree>

/*

native 
native __y_bit__();
native 
native 
native Bit_Set(BitArray:array<>, slot, bool:set);
native Bit_SetAll(BitArray:array<>, bool:set, size = sizeof (array));
native Bit_Get(BitArray:array<>, slot);
native Bit_Let(BitArray:array<>, slot);
native Bit_Vet(BitArray:array<>, slot);
native Bit_Slot(value);
native Bit_Mask(value);
native Bit_GetCount(BitArray:array<>, size = sizeof (array));
native Bit_Display(BitArray:array<>, size = sizeof (array));
native Iterator:Bits(BitArray:array<>);
native Iterator:Blanks(BitArray:array<>);
native 
native bits();
native bitsof();
native 

*/

#include <YSI\y_bit>

/*

native 
native __y_cell__();
native 
native 
native Cell_ReverseBits({Float, _}:data);
native Cell_ReverseNibbles({Float, _}:data);
native Cell_ReverseBytes({Float, _}:data);
native Cell_CountBits({Float, _}:data);
native Cell_GetLowestBit({Float, _}:data);
native Cell_GetLowestComponent({Float, _}:data);
native 

*/

#include <YSI\y_cell>

/*

native 
native __y_classes__();
native 
native 
native Class_Add(skin, Float:x, Float:y, Float:z, Float:a, ...);
native 
native Class_AddEx(Group:forgroup, Group:setgroup, skin, Float:x, Float:y, Float:z, Float:a, ...);
native Class_AddForGroup(Group:group, skin, Float:x, Float:y, Float:z, Float:a, ...);
native Class_AddWithGroupSet(Group:group, skin, Float:x, Float:y, Float:z, Float:a, ...);
native Class_Enable(classid, bool:toggle);
native Class_Delete(classid);
native Class_SetPlayer(classid, playerid, bool:s);
native bool:Class_GetPlayer(classid, playerid);
native Class_Get(playerid);
native Class_Goto(playerid, playerclass);
native 
native Class_DisableSelection(playerid);
native Class_DisableReselection(playerid);
native Class_EnableReselection(playerid);
native Class_ForceReselection(playerid);
native Class_ReturnToSelection(playerid);
native 

*/

#include <YSI\y_classes>

/*

native 
native __y_colours__();
native __y_colors__();
native 
native 
native SetColoursCanHaveSpaces(bool:set);
native SetColour(const name[], color);
native SetColourHash(hash, color);
native GetColour(const name[], alpha = 0xAA);
native GetColourStream(const str[], &idx, alpha = 0xAA);
native GetColourHash(hash, alpha = 0xAA);
native 

*/

#include <YSI\y_colours>

/*

native 
native __y_commands__();
native 
native 
native Command_AddAlt(commandid, altname[]);
native Command_AddAltNamed(command[], altname[]);
native Command_SetPlayer(commandid, playerid, bool:set);
native Command_SetPlayerNamed(command[], playerid, bool:set);
native 
native Command_SetDeniedReturn(bool:set);
native bool:Command_GetDeniedReturn();
native Command_SetIllegalReturn(bool:set);
native bool:Command_GetIllegalReturn();
native Command_SetUnknownReturn(bool:set);
native bool:Command_GetUnknownReturn();
native Command_SetDisconnectReturn(bool:set);
native bool:Command_GetDisconnectReturn();
native 
native Command_GetID(command[]);
native bool:Command_GetPlayer(commandid, playerid);
native bool:Command_GetPlayerNamed(command[], playerid);
native Command_Remove(commandid);
native Command_RemoveNamed(command[]);
native Command_ReProcess(playerid, cmdtext[], help);
native Command_GetName(commandid);
native Command_GetDisplay(commandid, playerid);
native Command_GetDisplayNamed(command[], playerid);
native Command_GetPlayerCommandCount(playerid);
native Command_GetNext(index, playerid);
native 
native Command_SetProvider(p);
native Command_GetProvider();
native Command_SetPlayerProvider(playerid, p);
native Command_GetPlayerProvider(playerid);
native 

*/

#include <YSI\y_commands>

/*

native 
native __y_debug__();
native 
native 
native P_level(str[], {Float, _}:...);
native P_I(str[], {Float, _}:...);
native P_W(str[], {Float, _}:...);
native P_E(str[], {Float, _}:...);
native P_F(str[], {Float, _}:...);
native P_C(str[], {Float, _}:...);
native 

*/

#include <YSI\y_debug>

/*

native 
native __y_dialog__();
native 
native 
native Dialog_Show(playerid, style, title[], caption[], button1[], button2[] = "", dialogid = -1);
native Dialog_ShowCallback(playerid, using:callback[], style, title[], caption[], button1[], button2[] = "", dialogid = -1);
native 
native Dialog_ObtainID();
native Dialog_TryObtainID(id);
native Dialog_Get(playerid);
native Dialog_Garbage(dialogid);
native Dialog_Free(dialogid);
native Dialog_Set(playerid, dialogid);
native Dialog_ShowCallbackData(playerid, callback[E_CALLBACK_DATA], style, title[], caption[], button1[], button2[] = "", dialogid = -1);
native Dialog_Hide(playerid);
native Dialog_SetCallback(dialogid, using:callback[]);
native Dialog_SetCallbackData(dialogid, callback[E_CALLBACK_DATA]);
native 

*/

#include <YSI\y_dialog>

/*

native 
native __y_flooding__();
native 
native 
native SetMaxConnections(max = -1, e_FLOOD_ACTION:action = e_FLOOD_ACTION_BLOCK)
native 

*/

#include <YSI\y_flooding>

/*

native 
native __y_groups__();
native 
native 
native Group:Group_Create(name[]);
native Group_Destroy(Group:group);
native Group_SetPlayer(Group:group, playerid, bool:s);
native bool:Group_GetPlayer(Group:group, playerid);
native 
native Group_SetGroup(Group:parent, Group:child, bool:s);
native Group_SetGlobalGroup(Group:child, bool:s);
naitve 
native Group_SetCommand(Group:group, commandid, bool:s);
native Group_SetCommandDefault(Group:group, bool:s);
native Group_SetGlobalCommand(commandid, bool:s);
native Group_SetGlobalCommandDefault(bool:s);
native 
native Group_SetArea(Group:group, area, bool:s);
native Group_SetAreaDefault(Group:group, bool:s);
native Group_SetGlobalArea(area, bool:s);
native Group_SetGlobalAreaDefault(bool:s);
native 
native Group_SetClass(Group:group, class, bool:s);
native Group_SetClassDefault(Group:group, bool:s);
native Group_SetGlobalClass(class, bool:s);
native Group_SetGlobalCalssDefault(bool:s);
native 
native Iterator:PlayerGroups(playerid)
native Iterator:Group(Group:group)
native 
native Group:Group_SetBalanced(playerid, Group:...)
native Group_GetColour(Group:group);
native Group_GetColor(Group:group);
native Group_SetColour(Group:group, colour);
native Group_SetColor(Group:group, color);
native bool:Group_GetGang(Group:group);
native Group_SetGang(Group:group, bool:set);
native Group:Group_GetID(name[]);
native Group_GetName(Group:group);
native Group_SetName(Group:group, name[]);
native 

*/

#include <YSI\y_groups>

/*

native 
native __y_hooks__();
native 
native 
native hook();
native 

*/

// Is included as then they can use hooks straight off.
#include <YSI\y_hooks>

/*

native 
native __y_ini__();
native 
native 
native bool:INI_ParseFile(fname[], remoteFormat[], bool:bFileFirst = false, bool:bExtra = false, extra = 0, bool:bLocal = true, bool:bPassTag = false, bool:bFilter = true, filter[] = "")
native bool:INI_Load(filename[], bool:bExtra = false, extra = 0, bool:bLocal = true)
native 
native INI_Int(name[], &dest);
native INI_Float(name[], &Float:dest);
native INI_Hex(name[], &dest);
native INI_Bin(name[], &dest);
native INI_String(name[], dest[], size);
native 
native INI:INI_Open(filename[])
native INI_Close(INI:file)
native 
native INI_SetTag(INI:file, tag[])
native INI_DeleteTag(INI:file, tag[])
native INI_WriteArray(INI:file, const name[], data[], len)
native INI_RemoveEntry(INI:file, name[])
native INI_WriteString(INI:file, name[], data[])
native INI_WriteInt(INI:file, name[], data)
native INI_WriteHex(INI:file, name[], data)
native INI_WriteBin(INI:file, name[], data)
native INI_WriteBool(INI:file, name[], bool:data)
native INI_WriteFloat(INI:file, name[], Float:data, accuracy = 6)
native 

*/

#include <YSI\y_ini>

/*

native 
native __y_inline__();
native 
native 
native using();
native inline();
native 
native Callback_Get(callback:name, result[E_CALLBACK_DATA], expect = -1);
native Callback_Release(const input[E_CALLBACK_DATA]);
native Callback_Call(const input[E_CALLBACK_DATA], {Float, _}:...);
native 

*/

#include <YSI\y_inline>

/*

native 
native __y_iterate__();
native 
native 
native Iter_Init(Iterator:arr[]<>);
native Iter_Add(Iterator:iter<>, element);
native Iter_Remove(Iterator:iter<>, element);
native Iter_Contains(Iterator:iter<>, element);
native Iter_SafeRemove(Iterator:iter<>, element, &ret);
native Iter_Random(Iterator:iter<>);
native Iter_Count(Iterator:iter<>);
native Iter_Clear(Iterator:iter<>);
native Iter_Free(Iterator:iter<>);
native 
native foreach();
native 
native Iter_Begin(Iterator:iter<>);
native Iter_End(Iterator:iter<>);
native Iter_First(Iterator:iter<>);
native Iter_Last(Iterator:iter<>);
native Iter_Next(Iterator:iter<>, cur);
native Iter_Prev(Iterator:iter<>, cur);
native 

*/

#include <YSI\y_iterate>

/*

native 
native __y_languages__();
native 
native 
native Language:Langs_Add(code[], name[]);
native Language:Langs_SetPlayerLanguage(playerid, Language:l);
native Language:Langs_GetPlayerLanguage(playerid);
native 
native Language:Langs_AddLanguage(code[], name[]);
native Langs_RemoveLanguage(Language:l);
native Language:Langs_GetLanguage(identifier[]);
native Language:Langs_GetLanguageCount();
native Langs_GetLanguageCodes();
native Langs_GetName(Language:l);
native Langs_GetCode(Language:l);
native bool:Langs_IsValid(Language:l);
native Language:Langs_SetPlayerCode(playerid, code[]);
native 

*/

#include <YSI\y_languages>

/*

native 
native __y_lock__();
native 
native 
native 

*/

// DO NOT include by default!
//#include <YSI\y_lock>

/*

native 
native __y_malloc__();
native 
native 
native Alloc:malloc(size);
native Alloc:calloc(size);
native free(Alloc:slot);
native 
native mget(Alloc:array, index);
native mset(Alloc:array, index, value);
native mgets(target[], length, Alloc:array, index);
native msets(Alloc:array, index, const str[]);
native 
native Malloc_SlotSize(Alloc:array);
native Malloc_Get(Alloc:array, index);
native Malloc_Set(Alloc:array, index, value);
native Malloc_GetS(target[], length, Alloc:array, index);
native Malloc_SetS(Alloc:array, index, const str[]);
native Malloc_GetA(target[], length, Alloc:array, index);
native Malloc_SetA(Alloc:array, index, const arr[], len);
native 

*/

#include <YSI\y_malloc>

/*

native 
native __y_master__();
native 
native 
native Master_Caller();
native 
native foreign();
native global();
native 

*/

#include <YSI\y_master>

/*

native 
native __y_php__();
native 
native 
native PHP_SendString(string:name[], string:value[], bool:priority = false);
native PHP_SendFloat(string:name[], Float:value, bool:priority = false);
native PHP_SendBool(string:name[], bool:value, bool:priority = false);
native PHP_SendInt(string:name[], value, bool:priority = false);
native 
native phpdata();
native phpfunc();
native 

*/

// DO NOT include by default!
//#include <YSI\y_php>

/*

native 
native __y_playerarray__();
native 
native 
native PA_Init(PlayerArray:pa<>, bool:init = false, s = bits<MAX_PLAYERS>);
native PA_FastInit(PlayerArray:pa<>);
native PA_Set(PlayerArray:pa<>, slot, bool:set);
native PA_Let(PlayerArray:pa<>, slot);
native PA_Vet(PlayerArray:pa<>, slot);
native PA_Get(PlayerArray:pa<>, slot);
native PA_GetCount(PlayerArray:pa<>);
native Iterator:PA(PlayerArray:pa<>);
native 

*/

#include <YSI\y_playerarray>

/*

native 
native __y_playerset__();
native 
native 
native Iterator:PS(@PlayerSet:iter);
native 

*/

#include <YSI\y_playerset>

/*

native 
native __y_remote__();
native 
native 
native remotefunc();
native broadcastfunc();
native localfunc();
native targetfunc();
native 

*/

#include <YSI\y_remote>

/*

native 
native __y_scriptinit__();
native 
native 
native 

*/

#include <YSI\y_scriptinit>

/*

native 
native __y_stringhash__();
native 
native 
native YHash(const str[], bool:sensitive = true, e_HASH_TYPE:type = hash_bernstein, len = -1, pack = false);
native 

*/

#include <YSI\y_stringhash>

/*

native 
native __y_svar__();
native 
native 
native svar();
native 

*/

#include <YSI\y_svar>

/*

native 
native __y_td__();
native 
native 
native Style:TD_Create(Float:x = 0.0, Float:y = 0.0, Float:letterX = 0.48, Float:letterY = 1.12, Float:textX = 1280.0, Float:textY = 1280.0, colour = 0xE1E1E1FF, boxColour = 0x80808080, bgColour = 0x000000FF, shadow = 2, outline = 0, align = _:td_align_none, font = 1, bool:proportional = false, bool:box = false, time = 0, name[] = "\1");
native TD_Delete(Style:styleId);
native 
native Text:TD_Display(text[], Style:id, Float:x = NAN, Float:y = NAN);
native TD_Destroy(Text:textDraw);
native TD_TextPosition(Text:textID, Float:x, Float:y);
native TD_TextXPos(Text:textID, Float:x);
native TD_TextYPos(Text:textID, Float:y);
native TD_SetString(Text:td, text[]);
native 
native TD_ShowForPlayer(playerid, Text:textDraw);
native TD_HideForPlayer(playerid, Text:textDraw);
native TD_ShowForAll(Text:textDraw);
native TD_HideForAll(Text:textDraw);
native Text:TD_DisplayForPlayer(playerid, text[], Style:id, Float:x = NAN, Float:y = NAN);
native Text:TD_DisplayForAll(text[], Style:id, Float:x = NAN, Float:y = NAN);
native 
native TD_StylePosition(Style:styleID, Float:x, Float:y);
native TD_StyleXPos(Style:styleID, Float:x);
native TD_StyleYPos(Style:styleID, Float:y);
native TD_LetterSize(Style:styleID, Float:x, Float:y);
native TD_LetterX(Style:styleID, Float:x);
native TD_LetterY(Style:styleID, Float:y);
native TD_TextSize(Style:styleID, Float:x, Float:y);
native TD_TextX(Style:styleID, Float:x);
native TD_TextY(Style:styleID, Float:y);
native TD_Alignment(Style:styleID, alignment = _:td_align_none);
native TD_Colour(Style:styleID, colour);
native TD_Color(Style:styleID, color);
native TD_UseBox(Style:styleID, bool:use);
native TD_BoxColour(Style:styleID, colour);
native TD_BoxColor(Style:styleID, color);
native TD_SetShadow(Style:styleID, size);
native TD_SetOutline(Style:styleID, size);
native TD_BackgroundColour(Style:styleID, colour);
native TD_BackgroundColor(Style:styleID, color);
native TD_Font(Style:styleID, font);
native TD_SetProportional(Style:styleID, bool:set);
native TD_SetTime(Style:styleID, time, bool:existing = false);
native 
native TD_Morph(Text:textDraw, Style:style, time, delay = 0);
native TD_Link(Text:base, Text:other);
native TD_Unlink(Text:td);
native Style:TD_GetDisplayStyle(Text:td);
native Text:TD_DisplayHashed(text[], hash, Float:x = NAN, Float:y = NAN);
native Text:TD_DisplayHashedForPlayer(playerid, text[], hash, Float:x = NAN, Float:y = NAN);
native Text:TD_DisplayHashedForAll(text[], hash, Float:x = NAN, Float:y = NAN);
native Text:TD_DisplayNamed(text[], style[], Float:x = NAN, Float:y = NAN);
native Text:TD_DisplayNamedForPlayer(playerid, text[], style[], Float:x = NAN, Float:y = NAN);
native Text:TD_DisplayNamedForAll(text[], style[], Float:x = NAN, Float:y = NAN);
native TD_Garbage(Text:textDraw);
native TD_Parse(filename[]);
native 
native Style:TD_GetNamed(name[]);
native Style:TD_GetID(hash);
native Style:TD_Clone(Style:styleID, name[] = "\1");
native TD_GetStyleData(Style:styleID, ret[E_TD_DATA]);
native TD_Name(Style:styleID, name[]);
native 

*/

#include <YSI\y_td>

/*

native 
native __y_testing__();
native 
native 
native Testing_RunAll();
native 

*/

// DO NOT include by default!
//#include <YSI\y_testing>

/*

native 
native __y_text__();
native 
native 
native Text_Send(@PlayerSet:players, message[], {Float, _}:...);
native 
native Text_MessageBox(@PlayerSet:players, using:callback[], title[], text[], button1[], button2[], {Float, _}:...);
native Text_InputBox(@PlayerSet:players, using:callback[], title[], text[], button1[], button2[], {Float, _}:...);
native Text_ListBox(@PlayerSet:players, using:callback[], title[], text[], button1[], button2[], {Float, _}:...);
native Text_PasswordBox(@PlayerSet:players, using:callback[], title[], text[], button1[], button2[], {Float, _}:...);
native Text_DialogBox(@PlayerSet:players, style, using:callback[], title[], text[], button1[], button2[], {Float, _}:...);
native 

*/

#include <YSI\y_text>

/*

native 
native __y_timers__();
native 
native 
native stop();
native defer();
native repeat();
native timer();
native task();
native ptask();
native pause();
native resume();
native 

*/

#include <YSI\y_timers>

/*

native 
native __y_users__();
native 
native 
native Language:Player_GetPreloadLanguage(playerid);
native Player_IsRegistered(playerid);
native bool:Player_IsLoggedIn(playerid);
native Player_GetYID(playerid);
native 
native Player_RemoveEntry(name[]);
native Player_WriteString(name[], data[]);
native Player_WriteArray(const name[], data[], len);
native Player_WriteInt(name[], data);
native Player_WriteHex(name[], data);
native Player_WriteBin(name[], data);
native Player_WriteBool(name[], bool:data);
native Player_WriteFloat(name[], Float:data, accuracy = 6);
native Player_SetTag(tag[]);
native Player_DeleteTag(tag[]);
native 
native Player_TryLogin(playerid, password[]);
native Player_ForceLogin(playerid);
native Player_TryRegister(playerid, password[]);
native Player_ChangePassword(playerid, password[]);
native Player_TryGroup(playerid, other[], password[]);
native Player_ForceGroup(playerid, other[]);
native 
native Player_Reload(playerid);
native Player_SetPreload(playerid, data[E_USER_PRELOAD]);
native Player_Preload(name[], ret[E_USER_PRELOAD]);
native 

*/

#include <YSI\y_users>

/*

native 
native __y_utils__();
native 
native 
native ceildiv(num, denom);
native floordiv(num, denom);
native isnull(str[]);
native isodd(num);
native iseven(num);
native strcpy(dest[], src[], maxlength = sizeof (dest));
native StripNL(str[]);
native endofline(line[], pos);
native chrfind(needle, haystack[], start = 0);
native chrfindp(needle, haystack[], start = 0);
native bernstein(string[]);
native ishex(str[]);
native unpack(const str[]);
native GetIP(playerid);
native getstring(addr);
native getstringarg(addr);
native isnumeric(str[]);
native hexstr(string[]);
native bool:boolstr(string[]);
native binstr(string[]);
native memset(dest[], size = sizeof (dest), val = 0, blocksize = 8);
native ReturnPlayerName(playerid);
native ftouch(const filename[]);
native 

*/

#include <YSI\y_utils>

/*

native 
native __y_uvar__();
native 
native 
native uvar();
native 

*/

#include <YSI\y_uvar>

/*

native 
native __y_va__();
native 
native 
native va_printf(fmat[], va_start);
native va_format(out[], size, fmat[], va_start);
native va_strlen(arg);
native va_getstring(dest[], arg, len = sizeof (dest));
native 

*/

#include <YSI\y_va>

/*

native 
native __y_writemem__();
native 
native 
native WriteMem(addr, value);
native 

*/

#include <YSI\y_writemem>

/*

native 
native __y_xml__();
native 
native 
native XML:XML_New();
native XML_Destroy(XML:rule);
native 
native XML_AddHandler(XML:rule, trigger[], function[]);
native XML_RemoveHandler(XML:rule, trigger[]);
native XML_Parse(XML:rule, filename[]);
native XML_GetKeyValue(key[], value[]);
native 
native XMLEntry:XML_AddParameter(XMLEntry:parent, tag[], value[] = "");
native XMLEntry:XML_AddItem(tag[], name[] = "", XMLEntry:parent = XMLEntry:cellmax);
native XMLEntry:XML_CreateEntry(tag[], name[] = "", XMLEntry:parent = XMLEntry:cellmax);
native XMLEntry:XML_AddSubEntry(tag[], name[] = "", XMLEntry:parent = XMLEntry:cellmax);
native XML_WriteItem(filename[], XMLEntry:item, bool:bIncludeXML = true, bool:bFavourShort = false);
native XML_WriteEntry(filename[], XMLEntry:item, bool:bIncludeXML = true, bool:bFavourShort = false);
naitve XML_RemoveItem(file[], tag[], name[]);
naitve XML_ReplaceItem(file[], tag[], name[], replacement);
native 

*/

#include <YSI\y_xml>

/*

native 
native __y_zonepulse__();
native 
native 
native GangZonePulse(@PlayerSet:players, zone, from, to, time, delay = ZONE_PULSE_STAGE_TIME, time2 = -1, delay2 = -1);
native GangZonePulseForPlayer(playerid, zone, from, to, time, delay = ZONE_PULSE_STAGE_TIME, time2 = -1, delay2 = -1);
native GangZonePulseForAll(zone, from, to, time, delay = ZONE_PULSE_STAGE_TIME, time2 = -1, delay2 = -1);
native GangZoneStopPulse(@PlayerSet:players, zone);
native GangZoneStopPulseForPlayer(playerid, zone);
native GangZoneStopPulseForAll(zone);
native 

*/

#include <YSI\y_zonepulse>
