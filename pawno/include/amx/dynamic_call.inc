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

#if defined DYNAMIC_CALL_INC
	#endinput
#endif
#define DYNAMIC_CALL_INC

#include <a_samp>

#include "amx_header"
#include "amx_memory"
#include "opcode"

#if !defined DYNAMIC_CALL_MAX_ARGS
	#define DYNAMIC_CALL_MAX_ARGS 256
#endif

forward bool:Push(arg);
forward bool:PushString(const string[]);
forward bool:Pop(&arg = 0);
forward Call(address, bool:auto_pop = true);
forward SysreqC(index, bool:auto_pop = true);
forward SysreqD(address, bool:auto_pop = true);
forward CallN(address, args_to_push, bool:auto_pop = true);
forward SysreqCN(index, args_to_push, bool:auto_pop = true);
forward SysreqDN(address, args_to_push, bool:auto_pop = true);
forward CallFunction(address, {Float,_}:...);
forward CallNative(index, {Float,_}:...);
forward CallNativeByAddress(address, {Float,_}:...);

static stock g_nargs = 0;
static stock g_args[DYNAMIC_CALL_MAX_ARGS];

stock bool:Push(arg) {
	if (g_nargs < sizeof(g_args)) {
		g_args[g_nargs++] = arg;
		return true;
	}
	return false;
}

stock bool:PushString(const string[]) {
	new address;
	#emit load.s.pri string
	#emit stor.s.pri address
	return Push(address);
}

stock bool:Pop(&arg = 0) {
	if (g_nargs > 0) {
		arg = g_args[--g_nargs];
		return true;
	}
	return false;
}

stock Call(address, bool:auto_pop = true) {
	new arg = 0;
	new index = g_nargs;
	new bytes = g_nargs * 4;
	new retval;

	while (--index >= 0) {
		arg = g_args[index];
		#emit push.s arg
	}

	#emit load.s.pri bytes
	#emit push.pri

	#emit lctrl 6
	#emit add.c 0x1c
	#emit push.pri
	#emit load.s.pri address
	#emit sctrl 6

	#emit stor.s.pri retval

	if (auto_pop) {
		while (Pop()) {}
	}

	return retval;
}

stock CallN(address, args_to_push, bool:auto_pop = true) {
	// Like "Call", but doesn't pass all parameters.
	new arg = 0;
	new index = g_nargs;
	new bytes = args_to_push * 4;
	new end = g_nargs - args_to_push;
	new retval;

	if (end < 0) {
		return cellmin;
	}

	while (--index >= end) {
		arg = g_args[index];
		#emit push.s arg
	}

	#emit load.s.pri bytes
	#emit push.pri

	#emit lctrl 6
	#emit add.c 0x1c
	#emit push.pri
	#emit load.s.pri address
	#emit sctrl 6

	#emit stor.s.pri retval

	if (auto_pop) {
		while (args_to_push--) {
			Pop();
		}
	}

	return retval;
}

stock CallFunction(address, {Float,_}:...) {
	new arg_bytes, arg_begin, arg_end;

	// Get number of bytes passed.
	#emit load.s.pri 0x8
	#emit const.alt 4
	#emit sub
	#emit stor.s.pri arg_bytes
	#emit move.alt

	// Last argument is at FRM + 0x0C + arg_bytes (which is in ALT).
	#emit lctrl 5
	#emit add.c 0xc
	#emit add
	#emit stor.s.pri arg_end

	// Frist argument is at FRM + 0x10.
	#emit lctrl 5
	#emit add.c 0x10
	#emit stor.s.pri arg_begin

	new arg = arg_end;
	while (arg >= arg_begin) {
		#emit lref.s.pri arg
		#emit load.i
		#emit push.pri
		arg -= 4;
	}

	// Call the function
	#emit push.s arg_bytes
	#emit lctrl 6
	#emit add.c 0x1c
	#emit push.pri
	#emit load.s.pri address
	#emit sctrl 6
	// Arguments are popped by callee.

	// Pop locals and return.
	#emit stack 0x10
	#emit retn

	return 0; // make compiler happy
}

stock SysreqC(index, bool:auto_pop = true) {
	new arg = 0;
	new i = g_nargs;
	new bytes = g_nargs * 4;
	new tmp;
	new Opcode:sysreq_c = RelocateOpcode(OP_SYSREQ_C);
	new retval;

	while (--i >= 0) {
		arg = g_args[i];
		#emit push.s arg
	}

	#emit load.s.pri bytes
	#emit push.pri

	// tmp = cod + cip - dat + <distance to SYSREQ.C's operand>
	#emit lctrl 0  // COD
	#emit move.alt
	#emit lctrl 6  // CIP
	#emit add
	#emit move.alt
	#emit lctrl 1  // DAT
	#emit sub.alt
	#emit add.c 0x5c
	#emit stor.s.pri tmp

	// nop #1 = sysreq.c
	#emit load.s.pri sysreq_c
	#emit sref.s.pri tmp

	// tmp += 4
	#emit load.s.pri tmp
	#emit add.c 4
	#emit stor.s.pri tmp

	// nop #2 = index
	#emit load.s.pri index
	#emit sref.s.pri tmp

	#emit nop
	#emit nop

	#emit stor.s.pri retval

	// Pop native arguments.
	#emit lctrl 4
	#emit load.s.alt bytes
	#emit add
	#emit add.c 4
	#emit sctrl 4

	if (auto_pop) {
		while (Pop()) {}
	}

	return retval;
}

stock SysreqD(address, bool:auto_pop = true) {
	new arg = 0;
	new i = g_nargs;
	new bytes = g_nargs * 4;
	new tmp;
	new Opcode:sysreq_d = RelocateOpcode(OP_SYSREQ_D);
	new retval;

	while (--i >= 0) {
		arg = g_args[i];
		#emit push.s arg
	}

	#emit load.s.pri bytes
	#emit push.pri

	// tmp = cod + cip - dat + <distance to nop #1>
	#emit lctrl 0  // COD
	#emit move.alt
	#emit lctrl 6  // CIP
	#emit add
	#emit move.alt
	#emit lctrl 1 // DAT
	#emit sub.alt
	#emit add.c 0x5c
	#emit stor.s.pri tmp

	// nop #1 = sysreq.d
	#emit load.s.pri sysreq_d
	#emit sref.s.pri tmp

	// tmp += 4
	#emit load.s.pri tmp
	#emit add.c 4
	#emit stor.s.pri tmp

	// nop #2 = address
	#emit load.s.pri address
	#emit sref.s.pri tmp

	#emit nop
	#emit nop

	#emit stor.s.pri retval

	// Pop native arguments.
	#emit lctrl 4
	#emit load.s.alt bytes
	#emit add
	#emit add.c 4
	#emit sctrl 4

	if (auto_pop) {
		while (Pop()) {}
	}

	return retval;
}

stock SysreqCN(index, args_to_push, bool:auto_pop = true) {
	new arg = 0;
	new i = g_nargs;
	new bytes = args_to_push * 4;
	new tmp;
	new Opcode:sysreq_c = RelocateOpcode(OP_SYSREQ_C);
	new end = g_nargs - args_to_push;
	new retval;

	if (end < 0) {
		return cellmin;
	}

	while (--i >= end) {
		arg = g_args[i];
		#emit push.s arg
	}
	#emit load.s.pri bytes
	#emit push.pri

	// tmp = cod + cip - dat + <distance to SYSREQ.C's operand>
	#emit lctrl 0  // COD
	#emit move.alt
	#emit lctrl 6  // CIP
	#emit add
	#emit move.alt
	#emit lctrl 1  // DAT
	#emit sub.alt
	#emit add.c 0x5c
	#emit stor.s.pri tmp

	// nop #1 = sysreq.c
	#emit load.s.pri sysreq_c
	#emit sref.s.pri tmp

	// tmp += 4
	#emit load.s.pri tmp
	#emit add.c 4
	#emit stor.s.pri tmp

	// nop #2 = index
	#emit load.s.pri index
	#emit sref.s.pri tmp

	#emit nop
	#emit nop

	#emit stor.s.pri retval

	// Pop native arguments.
	#emit lctrl 4
	#emit load.s.alt bytes
	#emit add
	#emit add.c 4
	#emit sctrl 4

	if (auto_pop) {
		while (args_to_push--) {
			Pop();
		}
	}

	return retval;
}

stock SysreqDN(address, args_to_push, bool:auto_pop = true) {
	new arg = 0;
	new i = g_nargs;
	new bytes = args_to_push * 4;
	new tmp;
	new Opcode:sysreq_d = RelocateOpcode(OP_SYSREQ_D);
	new end = g_nargs - args_to_push;
	new retval;

	if (end < 0) {
		return cellmin;
	}

	while (--i >= end) {
		arg = g_args[i];
		#emit push.s arg
	}

	#emit load.s.pri bytes
	#emit push.pri

	// tmp = cod + cip - dat + <distance to nop #1>
	#emit lctrl 0  // COD
	#emit move.alt
	#emit lctrl 6  // CIP
	#emit add
	#emit move.alt
	#emit lctrl 1 // DAT
	#emit sub.alt
	#emit add.c 0x5c
	#emit stor.s.pri tmp

	// nop #1 = sysreq.d
	#emit load.s.pri sysreq_d
	#emit sref.s.pri tmp

	// tmp += 4
	#emit load.s.pri tmp
	#emit add.c 4
	#emit stor.s.pri tmp

	// nop #2 = address
	#emit load.s.pri address
	#emit sref.s.pri tmp

	#emit nop
	#emit nop

	#emit stor.s.pri retval

	// Pop native arguments.
	#emit lctrl 4
	#emit load.s.alt bytes
	#emit add
	#emit add.c 4
	#emit sctrl 4

	if (auto_pop) {
		while (args_to_push--) {
			Pop();
		}
	}

	return retval;
}

stock CallNative(index, {Float,_}:...) {
	new arg_bytes, arg_begin, arg_end;
	new Opcode:sysreq_c = RelocateOpcode(OP_SYSREQ_C);

	// Get number of bytes passed.
	#emit load.s.pri 0x8
	#emit const.alt 4
	#emit sub
	#emit stor.s.pri arg_bytes
	#emit move.alt

	// Last argument is at FRM + 0x0C + arg_bytes (which is in ALT).
	#emit lctrl 5
	#emit add.c 0xc
	#emit add
	#emit stor.s.pri arg_end

	// Frist argument is at FRM + 0x10.
	#emit lctrl 5
	#emit add.c 0x10
	#emit stor.s.pri arg_begin

	new arg = arg_end;
	new tmp;

	while (arg >= arg_begin) {
		#emit lref.s.pri arg
		#emit load.i
		#emit push.pri
		arg -= 4;
	}

	// Push number of arguments * 4 (which is params[0]).
	#emit push.s arg_bytes

	// tmp = cod + cip - dat + <distance to nop #1>
	#emit lctrl 0  // COD
	#emit move.alt
	#emit lctrl 6  // CIP
	#emit add
	#emit move.alt
	#emit lctrl 1 // DAT
	#emit sub.alt
	#emit add.c 0x5c
	#emit stor.s.pri tmp

	// nop #1 = sysreq.c
	#emit load.s.pri sysreq_c
	#emit sref.s.pri tmp

	// tmp += 4
	#emit load.s.pri tmp
	#emit add.c 4
	#emit stor.s.pri tmp

	// nop #2 = index
	#emit load.s.pri index
	#emit sref.s.pri tmp

	#emit nop
	#emit nop

	new retval;
	#emit stor.s.pri retval

	// Pop native arguments.
	#emit lctrl 4
	#emit load.s.alt arg_bytes
	#emit add
	#emit add.c 4
	#emit sctrl 4

	return retval;
}

// Unlike CallNative(), this function calls natives directly via SYSREQ.D.
stock CallNativeByAddress(address, {Float,_}:...) {
	new arg_bytes, arg_begin, arg_end;
	new Opcode:sysreq_d = RelocateOpcode(OP_SYSREQ_D);

	// Get number of bytes passed.
	#emit load.s.pri 0x8
	#emit const.alt 4
	#emit sub
	#emit stor.s.pri arg_bytes
	#emit move.alt

	// Last argument is at FRM + 0x0C + arg_bytes (which is in ALT).
	#emit lctrl 5
	#emit add.c 0xc
	#emit add
	#emit stor.s.pri arg_end

	// Frist argument is at FRM + 0x10.
	#emit lctrl 5
	#emit add.c 0x10
	#emit stor.s.pri arg_begin

	new arg = arg_end;
	new tmp;

	while (arg >= arg_begin) {
		#emit lref.s.pri arg
		#emit load.i
		#emit push.pri
		arg -= 4;
	}

	// Push number of arguments * 4 (which is params[0]).
	#emit push.s arg_bytes

	// tmp = cod + cip - dat + <distance to nop #1>
	#emit lctrl 0  // COD
	#emit move.alt
	#emit lctrl 6  // CIP
	#emit add
	#emit move.alt
	#emit lctrl 1 // DAT
	#emit sub.alt
	#emit add.c 0x5c
	#emit stor.s.pri tmp

	// nop #1 = sysreq.d
	#emit load.s.pri sysreq_d
	#emit sref.s.pri tmp

	// tmp += 4
	#emit load.s.pri tmp
	#emit add.c 4
	#emit stor.s.pri tmp

	// nop #2 = address
	#emit load.s.pri address
	#emit sref.s.pri tmp

	#emit nop
	#emit nop

	new retval;
	#emit stor.s.pri retval

	// Pop native arguments.
	#emit lctrl 4
	#emit load.s.alt arg_bytes
	#emit add
	#emit add.c 4
	#emit sctrl 4

	return retval;
}
