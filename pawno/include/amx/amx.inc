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

#if defined AMX_INC
	#endinput
#endif
#define AMX_INC

#include "phys_memory"
#include "shellcode"

const AMX_OFFSET_BASE = 0;
const AMX_OFFSET_DATA = 4;
const AMX_OFFSET_CALLBACK = 8;
const AMX_OFFSET_DEBUG = 12;
const AMX_OFFSET_CIP = 16;
const AMX_OFFSET_FRM = 20;
const AMX_OFFSET_HEA = 24;
const AMX_OFFSET_HLW = 28;
const AMX_OFFSET_STK = 32;
const AMX_OFFSET_STP = 36;
const AMX_OFFSET_FLAGS = 40;
const AMX_OFFSET_USERTAGS = 44;
const AMX_OFFSET_USERDATA = 60;
const AMX_OFFSET_ERROR = 76;
const AMX_OFFSET_PARAMCOUNT = 80;
const AMX_OFFSET_PRI = 84;
const AMX_OFFSET_ALT = 88;
const AMX_OFFSET_RESET_STK = 92;
const AMX_OFFSET_RESET_HEA = 96;
const AMX_OFFSET_SYSREQ_D = 100;

// Returns the address of the AMX struct instance in memory that corresponds
// to this script. This function works only on Windows!
stock GetAmxAddress() {
	static address = 0;
	if (address == 0) {
		static const code[] = {
			0x90909090, 0x90909090, 0x90909090, 0x90909090, // for alignment
			0x0424448b, 0xC3C3C3C3
		};
		address = RunShellcode(refabs(code));
	}
	return address;
}

// Reads a cell from the AMX struct.
stock ReadAmxCell(offset) {
	new amx = GetAmxAddress();
	return ReadPhysMemoryCell(amx + offset);
}

// Writes a cell to the AMX struct.
stock WriteAmxCell(offset, value) {
	new amx = GetAmxAddress();
	WritePhysMemoryCell(amx + offset, value);
}
