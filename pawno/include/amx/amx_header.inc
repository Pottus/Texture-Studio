// Copyright (C) 2012 Zeex
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

#if defined AMX_HEADER_INC
	#endinput
#endif
#define AMX_HEADER_INC

#include <a_samp>

#include "amx_memory"

#define AMX_HDR_BYTES (60)
#define AMX_HDR_CELLS (AMX_HDR_BYTES / 4)

enum AMX_HDR {
	AMX_HDR_SIZE,
	AMX_HDR_MAGIC,
	AMX_HDR_FILE_VERSION,
	AMX_HDR_AMX_VERSION,
	AMX_HDR_FLAGS,
	AMX_HDR_DEFSIZE,
	AMX_HDR_COD,
	AMX_HDR_DAT,
	AMX_HDR_HEA,
	AMX_HDR_STP,
	AMX_HDR_CIP,
	AMX_HDR_PUBLICS,
	AMX_HDR_NATIVES,
	AMX_HDR_LIBRARIES,
	AMX_HDR_PUBVARS,
	AMX_HDR_TAGS,
	AMX_HDR_NAMETABLE
}

const AMX_HDR_OFFSET_SIZE = 0;
const AMX_HDR_OFFSET_MAGIC = 4;
const AMX_HDR_OFFSET_FILE_VERSION = 6;
const AMX_HDR_OFFSET_AMX_VERSION = 7;
const AMX_HDR_OFFSET_FLAGS = 8;
const AMX_HDR_OFFSET_DEFSIZE = 10;
const AMX_HDR_OFFSET_COD = 12;
const AMX_HDR_OFFSET_DAT = 16;
const AMX_HDR_OFFSET_HEA = 20;
const AMX_HDR_OFFSET_STP = 24;
const AMX_HDR_OFFSET_CIP = 28;
const AMX_HDR_OFFSET_PUBLICS = 32;
const AMX_HDR_OFFSET_NATIVES = 36;
const AMX_HDR_OFFSET_LIBRARIES = 40;
const AMX_HDR_OFFSET_PUBVARS = 44;
const AMX_HDR_OFFSET_TAGS = 48;
const AMX_HDR_OFFSET_NAMETABLE = 52;

enum AMX_FUNCSTUBNT {
	AMX_FUNCSTUBNT_ADDRESS,
	AMX_FUNCSTUBNT_NAMEOFS
}

// Publics
forward GetPublicIndexFromAddress(address);
forward GetPublicIndexFromName(const name[]);
forward bool:GetPublicInfo(index, info[AMX_FUNCSTUBNT]);
forward GetPublicAddressFromName(const name[]);
forward GetPublicAddressFromIndex(index);
forward bool:GetPublicNameFromIndex(index, name[], size = sizeof(name));
forward bool:GetPublicNameFromAddress(address, name[], size = sizeof(name));
forward HookPublic(index, address);

// Natives
forward GetNativeIndexFromAddress(address);
forward GetNativeIndexFromName(const name[]);
forward bool:GetNativeInfo(index, info[AMX_FUNCSTUBNT]);
forward GetNativeAddressFromName(const name[]);
forward GetNativeAddressFromIndex(index);
forward bool:GetNativeNameFromIndex(index, name[], size = sizeof(name));
forward bool:GetNativeNameFromAddress(address, name[], size = sizeof(name));
forward HookNative(index, address);

// Public Variables
forward bool:GetPubVarInfo(index, info[AMX_FUNCSTUBNT]);
forward GetPubVarIndexFromName(const name[]);
forward GetPubVarIndexFromAddress(address);
forward GetPubVarAddressFromName(const name[]);
forward GetPubVarAddressFromIndex(index);
forward bool:GetPubVarNameFromIndex(index, name[], size = sizeof(name));
forward bool:GetPubVarNameFromAddress(address, name[], size = sizeof(name));

// General
forward GetRawAmxHeader(plain_amxhdr[AMX_HDR_CELLS]);
forward GetAmxHeaderNow(amxhdr[AMX_HDR]);
forward GetAmxHeader(amxhdr[AMX_HDR]);
forward GetAmxHeaderComponent(AMX_HDR:comp);
forward PrintAmxHeader();

stock GetRawAmxHeader(plain_amxhdr[AMX_HDR_CELLS]) {
	new address;
	#emit lctrl 1  // DAT
	#emit neg      // -DAT
	#emit stor.s.pri address

	for (new i = 0; i < AMX_HDR_CELLS; i++) {
		plain_amxhdr[i] = ReadAmxMemory(address);
		address += 4;
	}
}

static stock copy_1(&dest, const source[], start) {
	#emit load.s.pri source
	#emit load.s.alt start
	#emit add
	#emit load.s.alt dest
	#emit movs 1
}

static stock copy_2(&dest, const source[], start) {
	#emit load.s.pri source
	#emit load.s.alt start
	#emit add
	#emit load.s.alt dest
	#emit movs 2
}

static stock copy_4(&dest, const source[], start) {
	#emit load.s.pri source
	#emit load.s.alt start
	#emit add
	#emit load.s.alt dest
	#emit movs 4
}

stock GetAmxHeaderNow(amxhdr[AMX_HDR]) {
	new plain_amxhdr[AMX_HDR_CELLS];
	GetRawAmxHeader(plain_amxhdr);

	copy_4(amxhdr[AMX_HDR_SIZE], plain_amxhdr, AMX_HDR_OFFSET_SIZE);
	copy_2(amxhdr[AMX_HDR_MAGIC], plain_amxhdr, AMX_HDR_OFFSET_MAGIC);
	copy_1(amxhdr[AMX_HDR_FILE_VERSION], plain_amxhdr, AMX_HDR_OFFSET_FILE_VERSION);
	copy_1(amxhdr[AMX_HDR_AMX_VERSION], plain_amxhdr, AMX_HDR_OFFSET_AMX_VERSION);
	copy_2(amxhdr[AMX_HDR_FLAGS], plain_amxhdr, AMX_HDR_OFFSET_FLAGS);
	copy_2(amxhdr[AMX_HDR_DEFSIZE], plain_amxhdr, AMX_HDR_OFFSET_DEFSIZE);
	copy_4(amxhdr[AMX_HDR_COD], plain_amxhdr, AMX_HDR_OFFSET_COD);
	copy_4(amxhdr[AMX_HDR_DAT], plain_amxhdr, AMX_HDR_OFFSET_DAT);
	copy_4(amxhdr[AMX_HDR_HEA], plain_amxhdr, AMX_HDR_OFFSET_HEA);
	copy_4(amxhdr[AMX_HDR_STP], plain_amxhdr, AMX_HDR_OFFSET_STP);
	copy_4(amxhdr[AMX_HDR_CIP], plain_amxhdr, AMX_HDR_OFFSET_CIP);
	copy_4(amxhdr[AMX_HDR_PUBLICS], plain_amxhdr, AMX_HDR_OFFSET_PUBLICS);
	copy_4(amxhdr[AMX_HDR_NATIVES], plain_amxhdr, AMX_HDR_OFFSET_NATIVES);
	copy_4(amxhdr[AMX_HDR_LIBRARIES], plain_amxhdr, AMX_HDR_OFFSET_LIBRARIES);
	copy_4(amxhdr[AMX_HDR_PUBVARS], plain_amxhdr, AMX_HDR_OFFSET_PUBVARS);
	copy_4(amxhdr[AMX_HDR_TAGS], plain_amxhdr, AMX_HDR_OFFSET_TAGS);
	copy_4(amxhdr[AMX_HDR_NAMETABLE], plain_amxhdr, AMX_HDR_OFFSET_NAMETABLE);
}

static gHdr[AMX_HDR];
static bool:gInitialized = false;

stock ResetStaticAmxHeader() {
	GetAmxHeaderNow(gHdr);
	gInitialized = true;
}

stock GetAmxHeader(amxhdr[AMX_HDR]) {
	if (!gInitialized) {
		ResetStaticAmxHeader();
	}
	amxhdr = gHdr;
}

stock GetAmxHeaderComponent(AMX_HDR:comp) {
	if (!gInitialized) {
		ResetStaticAmxHeader();
	}
	return gHdr[comp];
}

stock PrintAmxHeader() {
	if (!gInitialized) {
		ResetStaticAmxHeader();
	}
	printf("------------------------");
	printf("AMX Header:");
	printf("------------------------");
	printf("size         %d", gHdr[AMX_HDR_SIZE]);
	printf("magic        %x", gHdr[AMX_HDR_MAGIC]);
	printf("file_version %d", gHdr[AMX_HDR_FILE_VERSION]);
	printf("amx_version  %d", gHdr[AMX_HDR_AMX_VERSION]);
	printf("flags        %d", gHdr[AMX_HDR_FLAGS]);
	printf("defsize      %d", gHdr[AMX_HDR_DEFSIZE]);
	printf("cod          0x%08x", gHdr[AMX_HDR_COD]);
	printf("dat          0x%08x", gHdr[AMX_HDR_DAT]);
	printf("hea          0x%08x", gHdr[AMX_HDR_HEA]);
	printf("stp          0x%08x", gHdr[AMX_HDR_STP]);
	printf("cip          0x%08x", gHdr[AMX_HDR_CIP]);
	printf("publics      0x%08x", gHdr[AMX_HDR_PUBLICS]);
	printf("natives      0x%08x", gHdr[AMX_HDR_NATIVES]);
	printf("libraries    0x%08x", gHdr[AMX_HDR_LIBRARIES]);
	printf("pubvars      0x%08x", gHdr[AMX_HDR_PUBVARS]);
	printf("tags         0x%08x", gHdr[AMX_HDR_TAGS]);
	printf("nametable    0x%08x", gHdr[AMX_HDR_NAMETABLE]);
	printf("------------------------");
}

// Compares a string stored in the name table starting at "s1" (packed)
// with another string "s2" (unpacked).
static stock NtCompare(s1, const s2[]) {
	new index;
	new c1, c2;
	new diff;

	do {
		c1 = ReadAmxMemory(s1++) & 0xFF;
		c2 = s2[index++];
		diff = c1 - c2;
		if (diff != 0) {
			break;
		}
	} while (!(c1 & c2 == 0));

	return diff;
}

// Copies a name from the name table to a string. Returns the number
// of characters copied.
static stock NtCopy(src, dest[], size = sizeof(dest)) {
	new i = 0;
	new c;

	do {
		c = ReadAmxMemory(src++) & 0xFF;
		dest[i++] = c;
	} while (c != '\0' && i <= size);

	dest[i] = '\0'; // terminator

	return i;
}

stock GetNumPublics(amxhdr[AMX_HDR]) {
	new num_publics = (amxhdr[AMX_HDR_NATIVES] - amxhdr[AMX_HDR_PUBLICS]) / amxhdr[AMX_HDR_DEFSIZE];
	return num_publics;
}

stock GetPublicIndexFromAddress(address) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_publics = GetNumPublics(amxhdr);
	new off = amxhdr[AMX_HDR_PUBLICS] - amxhdr[AMX_HDR_DAT];

	// Linear search
	for (new i = 0; i < num_publics; i++) {
		if (ReadAmxMemory(off) == address) {
			return i;
		}
		off += amxhdr[AMX_HDR_DEFSIZE];
	}

	return -1;
}

stock bool:GetPublicInfo(index, info[AMX_FUNCSTUBNT]) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_publics = GetNumPublics(amxhdr);

	if (index < 0 || index >= num_publics) {
		return false;
	}

	new off = amxhdr[AMX_HDR_PUBLICS] - amxhdr[AMX_HDR_DAT] + index * amxhdr[AMX_HDR_DEFSIZE];
	info[AMX_FUNCSTUBNT_ADDRESS] = ReadAmxMemory(off);
	info[AMX_FUNCSTUBNT_NAMEOFS] = ReadAmxMemory(off + 4);

	return true;
}

stock GetPublicIndexFromName(const name[]) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_publics = GetNumPublics(amxhdr);

	// Binary search
	new first = 0;
	new last = num_publics - 1;
	new mid;

	while (first <= last) {
		mid = (first + last) / 2;

		new off = amxhdr[AMX_HDR_PUBLICS] - amxhdr[AMX_HDR_DAT] + mid * amxhdr[AMX_HDR_DEFSIZE];
		new nameofs = ReadAmxMemory(off + 4) - amxhdr[AMX_HDR_DAT];

		new diff = NtCompare(nameofs, name);
		if (diff < 0) {
			first = mid + 1;
		} else if (diff > 0) {
			last = mid - 1;
		} else {
			return mid;
		}
	}

	return -1;
}

stock GetPublicAddressFromIndex(index) {
	new info[AMX_FUNCSTUBNT];
	GetPublicInfo(index, info);
	return info[AMX_FUNCSTUBNT_ADDRESS];
}

stock GetPublicAddressFromName(const name[]) {
	return GetPublicAddressFromIndex(GetPublicIndexFromName(name));
}

stock bool:GetPublicNameFromIndex(index, name[], size = sizeof(name)) {
	new info[AMX_FUNCSTUBNT];
	if (!GetPublicInfo(index, info)) {
		return false;
	}
	return (NtCopy(info[AMX_FUNCSTUBNT_NAMEOFS]
	        - GetAmxHeaderComponent(AMX_HDR_DAT), name, size) > 0);
}

stock bool:GetPublicNameFromAddress(address, name[], size = sizeof(name)) {
	return GetPublicNameFromIndex(GetPublicIndexFromAddress(address), name, size);
}

stock HookPublic(index, address) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_publics = GetNumPublics(amxhdr);

	if (index < 0 || index >= num_publics) {
		return 0;
	}

	new off = amxhdr[AMX_HDR_PUBLICS] - amxhdr[AMX_HDR_DAT] + index * amxhdr[AMX_HDR_DEFSIZE];
	new old_address = ReadAmxMemory(off);
	WriteAmxMemory(off, address);

	return old_address;
}

stock GetNumNatives(amxhdr[AMX_HDR]) {
	return (amxhdr[AMX_HDR_LIBRARIES] - amxhdr[AMX_HDR_NATIVES]) / amxhdr[AMX_HDR_DEFSIZE];
}

stock GetNativeIndexFromAddress(address) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_natives = GetNumNatives(amxhdr);
	new off = amxhdr[AMX_HDR_NATIVES] - amxhdr[AMX_HDR_DAT];

	// Linear search
	for (new i = 0; i < num_natives; i++) {
		if (ReadAmxMemory(off) == address) {
			return i;
		}
		off += amxhdr[AMX_HDR_DEFSIZE];
	}

	return -1;
}

stock bool:GetNativeInfo(index, info[AMX_FUNCSTUBNT]) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	// For when "index" is not valid
	info[AMX_FUNCSTUBNT_ADDRESS] = -1;

	new num_natives = GetNumNatives(amxhdr);

	if (index < 0 || index >= num_natives) {
		return false;
	}

	new off = amxhdr[AMX_HDR_NATIVES] - amxhdr[AMX_HDR_DAT] + index * amxhdr[AMX_HDR_DEFSIZE];
	info[AMX_FUNCSTUBNT_ADDRESS] = ReadAmxMemory(off);
	info[AMX_FUNCSTUBNT_NAMEOFS] = ReadAmxMemory(off + 4);

	return true;
}

stock GetNativeIndexFromName(const name[]) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_natives = GetNumNatives(amxhdr);
	new off = amxhdr[AMX_HDR_NATIVES] - amxhdr[AMX_HDR_DAT];

	// Linear search
	for (new i = 0; i < num_natives; i++) {
		new nameofs = ReadAmxMemory(off + 4) - amxhdr[AMX_HDR_DAT];

		new diff = NtCompare(nameofs, name);
		if (diff == 0) {
			return i;
		}

		off += amxhdr[AMX_HDR_DEFSIZE];
	}

	return -1;
}

stock GetNativeAddressFromIndex(index) {
	new info[AMX_FUNCSTUBNT];
	GetNativeInfo(index, info);
	return info[AMX_FUNCSTUBNT_ADDRESS];
}

stock GetNativeAddressFromName(const name[]) {
	return GetNativeAddressFromIndex(GetNativeIndexFromName(name));
}

stock bool:GetNativeNameFromIndex(index, name[], size = sizeof(name)) {
	new info[AMX_FUNCSTUBNT];
	if (!GetNativeInfo(index, info)) {
		return false;
	}
	return (NtCopy(info[AMX_FUNCSTUBNT_NAMEOFS]
	        - GetAmxHeaderComponent(AMX_HDR_DAT), name, size) > 0);
}

stock bool:GetNativeNameFromAddress(address, name[], size = sizeof(name)) {
	return GetNativeNameFromIndex(GetNativeIndexFromAddress(address), name, size);
}

stock HookNative(index, address) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_natives = GetNumNatives(amxhdr);

	if (index < 0 || index >= num_natives) {
		return 0;
	}

	new off = amxhdr[AMX_HDR_NATIVES] - amxhdr[AMX_HDR_DAT] + index * amxhdr[AMX_HDR_DEFSIZE];
	new old_address = ReadAmxMemory(off);
	WriteAmxMemory(off, address);

	return old_address;
}

stock GetNumPubVars(amxhdr[AMX_HDR]) {
	return (amxhdr[AMX_HDR_TAGS] - amxhdr[AMX_HDR_PUBVARS]) / amxhdr[AMX_HDR_DEFSIZE];
}

stock bool:GetPubVarInfo(index, info[AMX_FUNCSTUBNT]) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_pubvars = GetNumPubVars(amxhdr);

	if (index < 0 || index >= num_pubvars) {
		return false;
	}

	new off = amxhdr[AMX_HDR_PUBVARS] - amxhdr[AMX_HDR_DAT] + index * amxhdr[AMX_HDR_DEFSIZE];
	info[AMX_FUNCSTUBNT_ADDRESS] = ReadAmxMemory(off);
	info[AMX_FUNCSTUBNT_NAMEOFS] = ReadAmxMemory(off + 4);

	return true;
}

stock GetPubVarIndexFromName(const name[]) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_pubvars = GetNumPubVars(amxhdr);

	// Binary search
	new first = 0;
	new last = num_pubvars - 1;
	new mid;

	while (first <= last) {
		mid = (first + last) / 2;

		new off = amxhdr[AMX_HDR_PUBVARS] - amxhdr[AMX_HDR_DAT] + mid * amxhdr[AMX_HDR_DEFSIZE];
		new nameofs = ReadAmxMemory(off + 4) - amxhdr[AMX_HDR_DAT];

		new diff = NtCompare(nameofs, name);
		if (diff < 0) {
			first = mid + 1;
		} else if (diff > 0) {
			last = mid - 1;
		} else {
			return mid;
		}
	}

	return -1;
}

stock GetPubVarIndexFromAddress(address) {
	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	new num_pubvars = GetNumPubVars(amxhdr);
	new off = amxhdr[AMX_HDR_PUBVARS] - amxhdr[AMX_HDR_DAT];

	// Linear search
	for (new i = 0; i < num_pubvars; i++) {
		if (ReadAmxMemory(off) == address) {
			return i;
		}
		off += amxhdr[AMX_HDR_DEFSIZE];
	}

	return -1;
}

stock GetPubVarAddressFromIndex(index) {
	new info[AMX_FUNCSTUBNT];
	GetPubVarInfo(index, info);
	return info[AMX_FUNCSTUBNT_ADDRESS];
}


stock GetPubVarAddressFromName(const name[]) {
	return GetPubVarAddressFromIndex(GetPubVarIndexFromName(name));
}

stock bool:GetPubVarNameFromIndex(index, name[], size = sizeof(name)) {
	new info[AMX_FUNCSTUBNT];
	if (!GetPubVarInfo(index, info)) {
		return false;
	}
	return (NtCopy(info[AMX_FUNCSTUBNT_NAMEOFS]
	        - GetAmxHeaderComponent(AMX_HDR_DAT), name, size) > 0);
}

stock bool:GetPubVarNameFromAddress(address, name[], size = sizeof(name)) {
	return GetPubVarNameFromIndex(GetPubVarIndexFromAddress(address), name, size);
}
