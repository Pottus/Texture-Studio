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

#if defined AMX_MEMORY_INC
	#endinput
#endif
#define AMX_MEMORY_INC

#include <core>

// Returns the address of a variable/array.
stock ref(...) {
	assert(numargs() == 1);
	#emit load.s.pri 12 // first argument
	#emit retn
	return 0; // make compiler happy
}

stock ReadAmxMemory(address) {
	#emit lref.s.pri address
	#emit retn
	return 0; // make compiler happy
}

stock ReadAmxMemoryArray(address, values[], size = sizeof(values)) {
	for (new i = 0; i < size; i++) {
		values[i] = ReadAmxMemory(address + i * 4);
	}
}

stock WriteAmxMemory(address, value) {
	#emit load.s.pri value
	#emit sref.s.pri address
	#emit retn
	return 0; // make compiler happy
}

stock WriteAmxMemoryArray(address, const values[], size = sizeof(values)) {
	for (new i = 0; i < size; i++) {
		WriteAmxMemory(address + i * 4, values[i]);
	}
}
