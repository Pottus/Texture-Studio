// Copyright (C) 2011-2012 Zeex
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

#if defined PHYS_MEMORY_INC
	#endinput
#endif
#define PHYS_MEMORY_INC

#include <core>

#include "amx_base"

static stock GetDat() {
	#emit lctrl 1
	#emit retn
	return 0; // make compiler happy
}

static stock AbsToRel(address) {
	return address - (GetAmxBaseAddress() + GetDat());
}

static stock RelToAbs(address) {
	return address + (GetAmxBaseAddress() + GetDat());
}

// Returns the absolute address of a variable/array.
stock refabs(...) {
	assert(numargs() == 1);
	new address;
	#emit load.s.pri 12
	#emit stor.s.pri address
	return RelToAbs(address);
}

stock ReadPhysMemory(address, dest[], num = sizeof(dest)) {
	new rel_addr = AbsToRel(address);

	// Current destination cell address.
	new cur_dest;
	#emit load.s.pri dest
	#emit stor.s.pri cur_dest

	// Currently reading address.
	new cur_addr = rel_addr;

	// Read num cells to dest.
	for (new i = 0; i < num; i++, cur_addr += 4, cur_dest += 4) {
		#emit lref.s.pri cur_addr
		#emit sref.s.pri cur_dest
	}

	#emit stack 12
	#emit retn

	return 0; // make compiler happy
}

stock WritePhysMemory(address, src[], num = sizeof(src)) {
	new rel_addr = AbsToRel(address);

	// Current destination cell address..
	new cur_src;
	#emit load.s.pri src
	#emit stor.s.pri cur_src

	// Currently reading address.
	new cur_addr = rel_addr;

	// Write num cells from src.
	for (new i = 0; i < num; i++, cur_addr += 4, cur_src += 4) {
		#emit lref.s.pri cur_src
		#emit sref.s.pri cur_addr
	}

	#emit stack 12
	#emit retn

	return 0; // make compiler happy
}

stock ReadPhysMemoryCell(address) {
	new rel_addr = AbsToRel(address);
	#emit lref.s.pri rel_addr
	#emit stack 4
	#emit retn
	return 0; // make compiler happy
}

stock WritePhysMemoryCell(address, what) {
	new rel_addr = AbsToRel(address);
	#emit load.s.pri what
	#emit sref.s.pri rel_addr
	#emit stack 4
	#emit retn
	return 0; // make compiler happy
}
