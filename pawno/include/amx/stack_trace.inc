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

#if defined STACK_TRACE_INC
	#endinput
#endif
#define STACK_TRACE_INC

#include "amx_base"
#include "amx_header"
#include "frame_info"

stock GetFunctionFromReturnAddress(ret_addr) {
	new addr = ret_addr - 4;

	#emit load.s.alt addr
	#emit lctrl 0
	#emit add
	#emit move.alt
	#emit lctrl 1
	#emit sub.alt

	#emit stor.s.pri addr
	#emit lref.s.alt addr
	#emit lctrl 0
	#emit sub.alt
	#emit stor.s.pri addr

	return addr - GetAmxBaseAddress();
}

stock GetStackTrace(trace[], skip = 0, max = sizeof(trace)) {
	new frm_addr;
	#emit lctrl 5
	#emit stor.s.pri frm_addr

	new length = 0;
	while (length < max) {
		new ret_addr = GetFrameReturn(frm_addr);
		if (length >= skip) {
			trace[length] = ret_addr;
		}
		if (ret_addr == 0) {
			break;
		}
		frm_addr = GetFramePreviousFrame(frm_addr);
		if (frm_addr == 0) {
			break;
		}
		length++;
	}

	return length;
}

stock PrintStackTrace(trace[], max = sizeof(trace)) {
	print("Stack trace:");

	new i = 0;

	for (; trace[i] != 0 && i < max - 1; i++) {
		new name[32];
		new address = GetFunctionFromReturnAddress(trace[i + 1]);
		if (GetPublicNameFromAddress(address, name)) {
			printf(" %s[%08x]", name, trace[i]);
		} else {
			printf(" ??[%08x]", trace[i]);
		}
	}

	printf(" ??[%08x]", trace[i]);
}
