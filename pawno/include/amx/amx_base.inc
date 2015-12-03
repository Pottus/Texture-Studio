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

#if defined AMX_BASE_INC
	#endinput
#endif
#define AMX_BASE_INC

static stock GetAmxBaseAddress_helper() {
	return 0;
}

// Returns the AMX base address i.e. amx->base.
stock GetAmxBaseAddressNow() {
	new cod, dat;
	#emit lctrl 0
	#emit stor.s.pri cod
	#emit lctrl 1
	#emit stor.s.pri dat

	// Get code section start address relative to data.
	new code_start = cod - dat;

	// Get address of GetAmxBaseAddress_helper().
	new fn_addr;
	#emit const.pri GetAmxBaseAddress_helper
	#emit stor.s.pri fn_addr

	// Get absolute address from the CALL instruction.
	new fn_addr_reloc, call_addr;
	GetAmxBaseAddress_helper();
	#emit lctrl 6
	#emit stor.s.pri call_addr
	call_addr = call_addr - 12 + code_start;
	#emit lref.s.pri call_addr
	#emit stor.s.pri fn_addr_reloc

	return fn_addr_reloc - fn_addr - cod;
}

stock GetAmxBaseAddress() {
	static amx_base = 0;
	if (amx_base == 0) {
		amx_base = GetAmxBaseAddressNow();
	}
	return amx_base;
}
