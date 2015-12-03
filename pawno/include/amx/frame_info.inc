// Copyright (C) 2012 Y_Less
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

#if defined FRAME_INFO_INC
	#endinput
#endif
#define FRAME_INFO_INC

#include "amx_header"
#include "amx_base"
#include "opcode"

stock GetCurrentFrame() {
	#emit lctrl 5
	#emit push.pri
	#emit lref.s.pri 0xfffffffc

	#emit stack 4
	#emit retn

	return 0; // make compiler happy
}

stock GetFramePreviousFrame(frm_addr) {
	#emit lref.s.pri frm_addr
	#emit retn

	return 0; // make compiler happy
}

stock GetFrameReturn(frm_addr) {
	#emit load.s.pri frm_addr
	#emit add.c 4

	#emit push.pri
	#emit lref.s.pri 0xfffffffc

	#emit stack 4
	#emit retn

	return 0; // make compiler happy
}

stock SetFramePreviousFrame(frm_addr, addr) {
	#emit load.s.pri frm_addr

	#emit push.pri
	#emit load.s.alt addr
	#emit sref.s.alt 0xfffffffc

	#emit stack 4
	#emit retn
}

stock SetFrameReturn(frm_addr, addr) {
	#emit load.s.pri frm_addr
	#emit add.c 4

	#emit push.pri
	#emit load.s.alt addr
	#emit sref.s.alt 0xfffffffc

	#emit stack 4
	#emit retn
}

stock SetFrameParameterSize(frm_addr, size) {
	#emit load.s.pri frm_addr
	#emit add.c 8

	#emit push.pri
	#emit load.s.pri size
	#emit sref.s.pri 0xfffffffc

	#emit stack 4
	#emit retn
}

stock SetFrameParameterCount(frm_addr, count) {
	return SetFrameParameterSize(frm_add, count << 2);
}

stock GetFrameTotalSize(frm_addr) {
	return GetFrameLocalSize(frm_addr) + GetFrameHeaderSize(frm_addr) + GetFrameParameterSize(frm_addr);
}

stock GetFrameTotalCount(frm_addr) {
	return GetFrameTotalSize(frm_addr) / 4;
}

stock GetFrameNextFrame(frm_addr) {
	// this function always works because it is at the top of the stack
	// run back through the stack
	new cur_frm = GetCurrentFrame();

	while (cur_frm != 0) {
		new prev_frm = GetFramePreviousFrame(cur_frm);
		if (prev_frm == frm_addr) {
			break;
		}
		cur_frm = prev_frm;
	}

	return cur_frm;
}

stock GetFrameLocalSize(frm_addr) {
	// run back through the stack
	new next_frm = GetFrameNextFrame(frm_addr);

	// find the size of local variables in the selected frame
	new frm_bottom = next_frm + GetFrameHeaderSize(next_frm) + GetFrameParameterSize(next_frm);

	return frm_addr - frm_bottom;
}

stock GetFrameLocalCount(frm_addr) {
	return GetFrameLocalSize(frm_addr) / 4;
}

stock GetFrameHeaderSize(frm_addr) {
	#pragma unused frm_addr
	return 12;
}

stock GetFrameHeaderCount(frm_addr) {
	return GetFrameHeaderSize(frm_addr) / 4;
}

stock GetFrameParameterSize(frm_addr) {
	#emit load.s.pri frm_addr
	#emit add.c 8

	#emit push.pri
	#emit lref.s.pri 0xfffffffc

	#emit stack 4
	#emit retn

	return 0; // make compiler happy
}

stock GetFrameParameterCount(frm_addr) {
	return GetFrameParameterSize(frm_addr) / 4;
}

stock GetFrameParameter(frm_addr, param, idx = -1) {
	if (idx == -1) {
		#emit load.s.pri param
		#emit shl.c.pri 2

		#emit load.s.alt frm_addr
		#emit add

		#emit add.c 12

		#emit push.pri
		#emit lref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	} else {
		#emit load.s.pri param
		#emit shl.c.pri 2

		#emit load.s.alt frm_addr
		#emit add

		#emit add.c 12

		#emit push.pri
		#emit lref.s.alt 0xfffffffc

		#emit load.s.pri idx
		#emit lidx

		#emit stack 4
		#emit retn
	}

	return 0; // make compiler happy
}

stock GetFrameVariable(frm_addr, param, idx = -1) {
	if (idx == -1) {
		#emit load.s.pri param
		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit lref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	} else {
		#emit load.s.pri param
		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit lref.s.alt 0xfffffffc

		#emit load.s.pri idx
		#emit lidx

		#emit stack 4
		#emit retn
	}

	return 0; // make compiler happy
}

stock GetFrameLocal(frm_addr, param) {
	if (param < 0) {
		// probably in correct format for negative offsets
		#emit load.s.pri param
		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit lref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	} else {
		#emit load.s.pri param
		#emit shl.c.pri 2

		#emit const.alt 0xfffffffc
		#emit sub.alt

		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit lref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	}

	return 0; // make compiler happy
}

stock SetFrameParameter(frm_addr, param, value, idx = -1) {
	if (idx == -1) {
		#emit load.s.pri param
		#emit shl.c.pri 2

		#emit load.s.alt frm_addr
		#emit add

		#emit add.c 12

		#emit push.pri
		#emit load.s.pri value
		#emit sref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	} else {
		#emit load.s.pri param
		#emit shl.c.pri 2

		#emit load.s.alt frm_addr
		#emit add

		#emit add.c 12

		#emit push.pri
		#emit lref.s.alt 0xfffffffc

		#emit load.s.pri idx
		#emit idxaddr

		#emit load.s.alt value
		#emit xchg
		#emit stor.i

		#emit stack 4
		#emit retn
	}

	return 0; // make compiler happy
}

stock SetFrameVariable(frm_addr, param, value, idx = -1) {
	if (idx == -1) {
		#emit load.s.pri param
		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit load.s.pri value
		#emit sref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	} else {
		#emit load.s.pri param
		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit lref.s.alt 0xfffffffc

		#emit load.s.pri idx
		#emit idxaddr

		#emit load.s.alt value
		#emit xchg
		#emit stor.i

		#emit stack 4
		#emit retn
	}

	return 0; // make compiler happy
}

stock SetFrameLocal(frm_addr, param, value) {
	if (param < 0) {
		// probably in correct format for negative offsets
		#emit load.s.pri param
		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit load.s.pri value
		#emit sref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	} else {
		#emit load.s.pri param
		#emit shl.c.pri 2

		#emit const.alt 0xfffffffc
		#emit sub.alt

		#emit load.s.alt frm_addr
		#emit add

		#emit push.pri
		#emit load.s.pri value
		#emit sref.s.pri 0xfffffffc

		#emit stack 4
		#emit retn
	}

	return 0; // make compiler happy
}

static stock GetCallerFrame() {
	#emit lctrl 5

	#emit push.pri
	#emit lref.s.pri 0xfffffffc

	#emit push.pri
	#emit lref.s.pri 0xfffffff8

	#emit stack 8
	#emit retn

	return 0; // make compiler happy
}

stock GetCurrentFramePreviousFrame() {
	return GetFramePreviousFrame(GetCallerFrame());
}

stock GetCurrentFrameReturn() {
	return GetFrameReturn(GetCallerFrame());
}

stock GetCurrentFrameTotalSize() {
	return GetFrameTotalSize(GetCallerFrame());
}

stock GetCurrentFrameTotalCount() {
	return GetFrameTotalCount(GetCallerFrame());
}

stock GetCurrentFrameLocalSize() {
	return GetFrameLocalSize(GetCallerFrame());
}

stock GetCurrentFrameLocalCount() {
	return GetFrameLocalCount(GetCallerFrame());
}

stock GetCurrentFrameHeaderSize() {
	return GetFrameHeaderSize(GetCallerFrame());
}

stock GetCurrentFrameHeaderCount() {
	return GetFrameHeaderCount(GetCallerFrame());
}

stock GetCurrentFrameParameterSize() {
	return GetFrameParameterSize(GetCallerFrame());
}

stock GetCurrentFrameParameter(param, idx = -1) {
	return GetFrameParameter(GetCallerFrame(), param, idx);
}

stock GetCurrentFrameLocal(param) {
	return GetFrameLocal(GetCallerFrame(), param);
}

stock GetCurrentFrameParameterCount() {
	return GetFrameParameterCount(GetCallerFrame());
}

stock SetCurrentFrameReturn(addr) {
	SetFrameReturn(GetCallerFrame(), addr);
}

stock SetCurrentFramePreviousFrame(addr) {
	SetFramePreviousFrame(GetCallerFrame(), addr);
}

stock SetCurrentParameterSize(size) {
	SetFrameParameterSize(GetCallerFrame(), size);
}

stock SetCurrentParameterCount(count) {
	SetFrameParameterCount(GetCallerFrame(), count);
}

stock GetFrameFunction(frm_addr) {
	// try to determine the start address of the function this frame is for
	new prev_frm = GetFramePreviousFrame(frm_addr);

	new amxhdr[AMX_HDR];
	GetAmxHeader(amxhdr);

	if (prev_frm == 0) {
		// public entry point
		new call_addr = GetFrameReturn(GetFrameNextFrame(frm_addr));

		// find the closest public/main
		new highest_found = 0;
		new defsize = amxhdr[AMX_HDR_DEFSIZE];
		new num_publics = (amxhdr[AMX_HDR_NATIVES] - amxhdr[AMX_HDR_PUBLICS]) / defsize;
		new off = amxhdr[AMX_HDR_PUBLICS] - amxhdr[AMX_HDR_DAT];

		for (new i = 0; i != num_publics; ++i) {
			new addr = ReadAmxMemory(off);
			off += defsize;

			if (highest_found < addr < call_addr) {
				highest_found = addr;
			}
		}

		if (highest_found < amxhdr[AMX_HDR_CIP] < call_addr) {
			highest_found = amxhdr[AMX_HDR_CIP];
		}

		// return the best found match
		return highest_found;
	} else {
		// called from inside the script
		new ret_addr = (GetFrameReturn(frm_addr) - 8) + (amxhdr[AMX_HDR_COD] - amxhdr[AMX_HDR_DAT]);

		new Opcode:opcode = UnrelocateOpcode(Opcode:ReadAmxMemory(ret_addr));

		if (opcode == OP_CALL) {
			// standard function call, get the call address
			return ReadAmxMemory(ret_addr + 4) - amxhdr[AMX_HDR_COD] - GetAmxBaseAddress();

		} else if (opcode == OP_SCTRL) {
			// modified code to call a function by pointer
			opcode = UnrelocateOpcode(Opcode:ReadAmxMemory(ret_addr - 8));

			if (opcode == OP_LOAD_PRI) {
				return ReadAmxMemory(ReadAmxMemory(ret_addr - 4));
			} else if (opcode == OP_LOAD_S_PRI) {
				return GetFrameVariable(prev_frm, ReadAmxMemory(ret_addr - 4));
			} else if (opcode == OP_CONST_PRI) {
				return ReadAmxMemory(ret_addr - 4);
			}
		}

		// guess!
		new end = amxhdr[AMX_HDR_COD] - amxhdr[AMX_HDR_DAT] + 8; // "halt"
		ret_addr = GetFrameReturn(GetFrameNextFrame(frm_addr)) + end;

		opcode = RelocateOpcode(OP_RETN);
		new Opcode:proc = RelocateOpcode(OP_PROC);

		while (ret_addr >= end) {
			if (Opcode:ReadAmxMemory(ret_addr) == proc) {
				if (ret_addr == end || Opcode:ReadAmxMemory(ret_addr - 4) == opcode) {
					// found a retn/proc pair.
					return ret_addr;
				}
			}
			ret_addr -= 4;
		}
	}

	// give up...
	return 0;
}

stock GetCurrentFrameFunction() {
	// this function gets its own caller - pointless but here for completeness
	return GetFrameFunction(GetCallerFrame());
}
