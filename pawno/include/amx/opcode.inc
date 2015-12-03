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

#if defined OPCODE_INC
	#endinput
#endif
#define OPCODE_INC

enum Opcode {
  OP_NONE,         OP_LOAD_PRI,     OP_LOAD_ALT,
  OP_LOAD_S_PRI,   OP_LOAD_S_ALT,   OP_LREF_PRI,
  OP_LREF_ALT,     OP_LREF_S_PRI,   OP_LREF_S_ALT,
  OP_LOAD_I,       OP_LODB_I,       OP_CONST_PRI,
  OP_CONST_ALT,    OP_ADDR_PRI,     OP_ADDR_ALT,
  OP_STOR_PRI,     OP_STOR_ALT,     OP_STOR_S_PRI,
  OP_STOR_S_ALT,   OP_SREF_PRI,     OP_SREF_ALT,
  OP_SREF_S_PRI,   OP_SREF_S_ALT,   OP_STOR_I,
  OP_STRB_I,       OP_LIDX,         OP_LIDX_B,
  OP_IDXADDR,      OP_IDXADDR_B,    OP_ALIGN_PRI,
  OP_ALIGN_ALT,    OP_LCTRL,        OP_SCTRL,
  OP_MOVE_PRI,     OP_MOVE_ALT,     OP_XCHG,
  OP_PUSH_PRI,     OP_PUSH_ALT,     OP_PUSH_R,
  OP_PUSH_C,       OP_PUSH,         OP_PUSH_S,
  OP_POP_PRI,      OP_POP_ALT,      OP_STACK,
  OP_HEAP,         OP_PROC,         OP_RET,
  OP_RETN,         OP_CALL,         OP_CALL_PRI,
  OP_JUMP,         OP_JREL,         OP_JZER,
  OP_JNZ,          OP_JEQ,          OP_JNEQ,
  OP_JLESS,        OP_JLEQ,         OP_JGRTR,
  OP_JGEQ,         OP_JSLESS,       OP_JSLEQ,
  OP_JSGRTR,       OP_JSGEQ,        OP_SHL,
  OP_SHR,          OP_SSHR,         OP_SHL_C_PRI,
  OP_SHL_C_ALT,    OP_SHR_C_PRI,    OP_SHR_C_ALT,
  OP_SMUL,         OP_SDIV,         OP_SDIV_ALT,
  OP_UMUL,         OP_UDIV,         OP_UDIV_ALT,
  OP_ADD,          OP_SUB,          OP_SUB_ALT,
  OP_AND,          OP_OR,           OP_XOR,
  OP_NOT,          OP_NEG,          OP_INVERT,
  OP_ADD_C,        OP_SMUL_C,       OP_ZERO_PRI,
  OP_ZERO_ALT,     OP_ZERO,         OP_ZERO_S,
  OP_SIGN_PRI,     OP_SIGN_ALT,     OP_EQ,
  OP_NEQ,          OP_LESS,         OP_LEQ,
  OP_GRTR,         OP_GEQ,          OP_SLESS,
  OP_SLEQ,         OP_SGRTR,        OP_SGEQ,
  OP_EQ_C_PRI,     OP_EQ_C_ALT,     OP_INC_PRI,
  OP_INC_ALT,      OP_INC,          OP_INC_S,
  OP_INC_I,        OP_DEC_PRI,      OP_DEC_ALT,
  OP_DEC,          OP_DEC_S,        OP_DEC_I,
  OP_MOVS,         OP_CMPS,         OP_FILL,
  OP_HALT,         OP_BOUNDS,       OP_SYSREQ_PRI,
  OP_SYSREQ_C,     OP_FILE,         OP_LINE,
  OP_SYMBOL,       OP_SRANGE,       OP_JUMP_PRI,
  OP_SWITCH,       OP_CASETBL,      OP_SWAP_PRI,
  OP_SWAP_ALT,     OP_PUSH_ADR,     OP_NOP,
  OP_SYSREQ_D,     OP_SYMTAG,       OP_BREAK,
  OP_LAST_
};

const NUM_OPCODES = _:OP_LAST_;

static stock Opcode:ReadOpcodeNearThis(offset = 0) {
	new ret_addr;

	// Get return address + COD - DAT + offset.
	#emit load.s.alt 4
	#emit lctrl 0
	#emit add
	#emit move.alt
	#emit lctrl 1
	#emit xchg
	#emit sub
	#emit load.s.alt offset
	#emit add

	#emit stor.s.pri ret_addr
	#emit lref.s.pri ret_addr

	#emit stack 4
	#emit retn

	return OP_NONE; // make compiler happy
}

static stock bool:HaveToRelocateOpcodes() {
	return ReadOpcodeNearThis(-8) != OP_CALL;
}

// Based on this idea: http://forum.sa-mp.com/showthread.php?t=358084
stock Opcode:RelocateOpcodeNow(Opcode:opcode) {
	if (!HaveToRelocateOpcodes()) {
		return opcode;
	}
	switch (opcode) {
		case OP_LOAD_PRI: {
			return ReadOpcodeNearThis(4);
			#emit load.pri 0
		}
		case OP_LOAD_ALT: {
			return ReadOpcodeNearThis(4);
			#emit load.alt 0
		}
		case OP_LOAD_S_PRI: {
			return ReadOpcodeNearThis(4);
			#emit load.s.pri 0
		}
		case OP_LOAD_S_ALT: {
			return ReadOpcodeNearThis(4);
			#emit load.s.alt 0
		}
		case OP_LREF_PRI: {
			return ReadOpcodeNearThis(4);
			#emit lref.pri 0
		}
		case OP_LREF_ALT: {
			return ReadOpcodeNearThis(4);
			#emit lref.alt 0
		}
		case OP_LREF_S_PRI: {
			return ReadOpcodeNearThis(4);
			#emit lref.s.pri 0
		}
		case OP_LREF_S_ALT: {
			return ReadOpcodeNearThis(4);
			#emit lref.s.alt 0
		}
		case OP_LOAD_I: {
			return ReadOpcodeNearThis(4);
			#emit load.i
		}
		case OP_LODB_I: {
			return ReadOpcodeNearThis(4);
			#emit lodb.i 1
		}
		case OP_CONST_PRI: {
			return ReadOpcodeNearThis(4);
			#emit const.pri 0
		}
		case OP_CONST_ALT: {
			return ReadOpcodeNearThis(4);
			#emit const.alt 0
		}
		case OP_ADDR_PRI: {
			return ReadOpcodeNearThis(4);
			#emit addr.pri 0
		}
		case OP_ADDR_ALT: {
			return ReadOpcodeNearThis(4);
			#emit addr.alt 0
		}
		case OP_STOR_PRI: {
			return ReadOpcodeNearThis(4);
			#emit stor.pri 0
		}
		case OP_STOR_ALT: {
			return ReadOpcodeNearThis(4);
			#emit stor.alt 0
		}
		case OP_STOR_S_PRI: {
			return ReadOpcodeNearThis(4);
			#emit stor.s.pri 0
		}
		case OP_STOR_S_ALT: {
			return ReadOpcodeNearThis(4);
			#emit stor.s.alt 0
		}
		case OP_SREF_PRI: {
			return ReadOpcodeNearThis(4);
			#emit sref.pri 0
		}
		case OP_SREF_ALT: {
			return ReadOpcodeNearThis(4);
			#emit sref.alt 0
		}
		case OP_SREF_S_PRI: {
			return ReadOpcodeNearThis(4);
			#emit sref.s.pri 0
		}
		case OP_SREF_S_ALT: {
			return ReadOpcodeNearThis(4);
			#emit sref.s.alt 0
		}
		case OP_STOR_I: {
			return ReadOpcodeNearThis(4);
			#emit stor.i
		}
		case OP_STRB_I: {
			return ReadOpcodeNearThis(4);
			#emit strb.i 1
		}
		case OP_LIDX: {
			return ReadOpcodeNearThis(4);
			#emit lidx
		}
		case OP_LIDX_B: {
			return ReadOpcodeNearThis(4);
			#emit lidx.b 0
		}
		case OP_IDXADDR: {
			return ReadOpcodeNearThis(4);
			#emit idxaddr
		}
		case OP_IDXADDR_B: {
			return ReadOpcodeNearThis(4);
			#emit idxaddr.b 0
		}
		case OP_ALIGN_PRI: {
			return ReadOpcodeNearThis(4);
			#emit align.pri 0
		}
		case OP_ALIGN_ALT: {
			return ReadOpcodeNearThis(4);
			#emit align.alt 0
		}
		case OP_LCTRL: {
			return ReadOpcodeNearThis(4);
			#emit lctrl 0
		}
		case OP_SCTRL: {
			return ReadOpcodeNearThis(4);
			#emit sctrl 0
		}
		case OP_MOVE_PRI: {
			return ReadOpcodeNearThis(4);
			#emit move.pri
		}
		case OP_MOVE_ALT: {
			return ReadOpcodeNearThis(4);
			#emit move.alt
		}
		case OP_XCHG: {
			return ReadOpcodeNearThis(4);
			#emit xchg
		}
		case OP_PUSH_PRI: {
			return ReadOpcodeNearThis(4);
			#emit push.pri
		}
		case OP_PUSH_ALT: {
			return ReadOpcodeNearThis(4);
			#emit push.alt
		}
		case OP_PUSH_C: {
			return ReadOpcodeNearThis(4);
			#emit push.c 0
		}
		case OP_PUSH: {
			return ReadOpcodeNearThis(4);
			#emit push 0
		}
		case OP_PUSH_S: {
			return ReadOpcodeNearThis(4);
			#emit push.s 0
		}
		case OP_POP_PRI: {
			return ReadOpcodeNearThis(4);
			#emit pop.pri
		}
		case OP_POP_ALT: {
			return ReadOpcodeNearThis(4);
			#emit pop.alt
		}
		case OP_STACK: {
			return ReadOpcodeNearThis(4);
			#emit stack 0
		}
		case OP_HEAP: {
			return ReadOpcodeNearThis(4);
			#emit heap 0
		}
		case OP_PROC: {
			return ReadOpcodeNearThis(4);
			#emit proc
		}
		case OP_RET: {
			return ReadOpcodeNearThis(4);
			#emit ret
		}
		case OP_RETN: {
			return ReadOpcodeNearThis(4);
			#emit retn
		}
		case OP_CALL: {
			// We can't do just "#emit call 0" - this will crash compiler for some reason (bug?).
			return ReadOpcodeNearThis(-8);
		}
		case OP_JUMP: {
			return ReadOpcodeNearThis(4);
			#emit jump 0
		}
		case OP_JZER: {
			return ReadOpcodeNearThis(4);
			#emit jzer 0
		}
		case OP_JNZ: {
			return ReadOpcodeNearThis(4);
			#emit jnz 0
		}
		case OP_JEQ: {
			return ReadOpcodeNearThis(4);
			#emit jeq 0
		}
		case OP_JNEQ: {
			return ReadOpcodeNearThis(4);
			#emit jneq 0
		}
		case OP_JLESS: {
			return ReadOpcodeNearThis(4);
			#emit jless 0
		}
		case OP_JLEQ: {
			return ReadOpcodeNearThis(4);
			#emit jleq 0
		}
		case OP_JGRTR: {
			return ReadOpcodeNearThis(4);
			#emit jgrtr 0
		}
		case OP_JGEQ: {
			return ReadOpcodeNearThis(4);
			#emit jgeq 0
		}
		case OP_JSLESS: {
			return ReadOpcodeNearThis(4);
			#emit jsless 0
		}
		case OP_JSLEQ: {
			return ReadOpcodeNearThis(4);
			#emit jsleq 0
		}
		case OP_JSGRTR: {
			return ReadOpcodeNearThis(4);
			#emit jsgrtr 0
		}
		case OP_JSGEQ: {
			return ReadOpcodeNearThis(4);
			#emit jsgeq 0
		}
		case OP_SHL: {
			return ReadOpcodeNearThis(4);
			#emit shl
		}
		case OP_SHR: {
			return ReadOpcodeNearThis(4);
			#emit shr
		}
		case OP_SSHR: {
			return ReadOpcodeNearThis(4);
			#emit sshr
		}
		case OP_SHL_C_PRI: {
			return ReadOpcodeNearThis(4);
			#emit shl.c.pri 0
		}
		case OP_SHL_C_ALT: {
			return ReadOpcodeNearThis(4);
			#emit shl.c.alt 0
		}
		case OP_SHR_C_PRI: {
			return ReadOpcodeNearThis(4);
			#emit shr.c.pri 0
		}
		case OP_SHR_C_ALT: {
			return ReadOpcodeNearThis(4);
			#emit shr.c.alt 0
		}
		case OP_SMUL: {
			return ReadOpcodeNearThis(4);
			#emit smul
		}
		case OP_SDIV: {
			return ReadOpcodeNearThis(4);
			#emit sdiv
		}
		case OP_SDIV_ALT: {
			return ReadOpcodeNearThis(4);
			#emit sdiv.alt
		}
		case OP_UMUL: {
			return ReadOpcodeNearThis(4);
			#emit umul
		}
		case OP_UDIV: {
			return ReadOpcodeNearThis(4);
			#emit udiv
		}
		case OP_UDIV_ALT: {
			return ReadOpcodeNearThis(4);
			#emit udiv.alt
		}
		case OP_ADD: {
			return ReadOpcodeNearThis(4);
			#emit add
		}
		case OP_SUB: {
			return ReadOpcodeNearThis(4);
			#emit sub
		}
		case OP_SUB_ALT: {
			return ReadOpcodeNearThis(4);
			#emit sub.alt
		}
		case OP_AND: {
			return ReadOpcodeNearThis(4);
			#emit and
		}
		case OP_OR: {
			return ReadOpcodeNearThis(4);
			#emit or
		}
		case OP_XOR: {
			return ReadOpcodeNearThis(4);
			#emit xor
		}
		case OP_NOT: {
			return ReadOpcodeNearThis(4);
			#emit not
		}
		case OP_NEG: {
			return ReadOpcodeNearThis(4);
			#emit neg
		}
		case OP_INVERT: {
			return ReadOpcodeNearThis(4);
			#emit invert
		}
		case OP_ADD_C: {
			return ReadOpcodeNearThis(4);
			#emit add.c 0
		}
		case OP_SMUL_C: {
			return ReadOpcodeNearThis(4);
			#emit smul.c 0
		}
		case OP_ZERO_PRI: {
			return ReadOpcodeNearThis(4);
			#emit zero.pri
		}
		case OP_ZERO_ALT: {
			return ReadOpcodeNearThis(4);
			#emit zero.alt
		}
		case OP_ZERO: {
			return ReadOpcodeNearThis(4);
			#emit zero 0
		}
		case OP_ZERO_S: {
			return ReadOpcodeNearThis(4);
			#emit zero.s 0
		}
		case OP_SIGN_PRI: {
			return ReadOpcodeNearThis(4);
			#emit sign.pri
		}
		case OP_SIGN_ALT: {
			return ReadOpcodeNearThis(4);
			#emit sign.alt
		}
		case OP_EQ: {
			return ReadOpcodeNearThis(4);
			#emit eq
		}
		case OP_NEQ: {
			return ReadOpcodeNearThis(4);
			#emit neq
		}
		case OP_LESS: {
			return ReadOpcodeNearThis(4);
			#emit less
		}
		case OP_LEQ: {
			return ReadOpcodeNearThis(4);
			#emit leq
		}
		case OP_GRTR: {
			return ReadOpcodeNearThis(4);
			#emit grtr
		}
		case OP_GEQ: {
			return ReadOpcodeNearThis(4);
			#emit geq
		}
		case OP_SLESS: {
			return ReadOpcodeNearThis(4);
			#emit sless
		}
		case OP_SLEQ: {
			return ReadOpcodeNearThis(4);
			#emit sleq
		}
		case OP_SGRTR: {
			return ReadOpcodeNearThis(4);
			#emit sgrtr
		}
		case OP_SGEQ: {
			return ReadOpcodeNearThis(4);
			#emit sgeq
		}
		case OP_EQ_C_PRI: {
			return ReadOpcodeNearThis(4);
			#emit eq.c.pri 0
		}
		case OP_EQ_C_ALT: {
			return ReadOpcodeNearThis(4);
			#emit eq.c.alt 0
		}
		case OP_INC_PRI: {
			return ReadOpcodeNearThis(4);
			#emit inc.pri
		}
		case OP_INC_ALT: {
			return ReadOpcodeNearThis(4);
			#emit inc.alt
		}
		case OP_INC: {
			return ReadOpcodeNearThis(4);
			#emit inc 0
		}
		case OP_INC_S: {
			return ReadOpcodeNearThis(4);
			#emit inc.s 0
		}
		case OP_INC_I: {
			return ReadOpcodeNearThis(4);
			#emit inc.i
		}
		case OP_DEC_PRI: {
			return ReadOpcodeNearThis(4);
			#emit dec.pri
		}
		case OP_DEC_ALT: {
			return ReadOpcodeNearThis(4);
			#emit dec.alt
		}
		case OP_DEC: {
			return ReadOpcodeNearThis(4);
			#emit dec 0
		}
		case OP_DEC_S: {
			return ReadOpcodeNearThis(4);
			#emit dec.s 0
		}
		case OP_DEC_I: {
			return ReadOpcodeNearThis(4);
			#emit dec.i
		}
		case OP_MOVS: {
			return ReadOpcodeNearThis(4);
			#emit movs 0
		}
		case OP_CMPS: {
			return ReadOpcodeNearThis(4);
			#emit cmps 0
		}
		case OP_FILL: {
			return ReadOpcodeNearThis(4);
			#emit fill 0
		}
		case OP_HALT: {
			return ReadOpcodeNearThis(4);
			#emit halt 0
		}
		case OP_BOUNDS: {
			return ReadOpcodeNearThis(4);
			#emit bounds 0
		}
		case OP_SYSREQ_C: {
			return ReadOpcodeNearThis(4);
			#emit sysreq.c 0
		}
		case OP_SWITCH: {
			return ReadOpcodeNearThis(4);
			#emit switch 0
		}
		case OP_CASETBL: {
			new x = 0;
			switch (x) { case 0: return ReadOpcodeNearThis(20); }
		}
		case OP_SWAP_PRI: {
			return ReadOpcodeNearThis(4);
			#emit swap.pri
		}
		case OP_SWAP_ALT: {
			return ReadOpcodeNearThis(4);
			#emit swap.alt
		}
		case OP_PUSH_ADR: {
			return ReadOpcodeNearThis(4);
			#emit push.adr 0
		}
		case OP_NOP: {
			return ReadOpcodeNearThis(4);
			#emit nop
		}
		case OP_SYSREQ_D: {
			// Since there's no way to #emit sysreq.d we have to compute its
			// address using a relative offset to another opcode, e.g. nop.
			new bool:is_crashdetect;
			#emit zero.pri
			#emit lctrl 0xFF
			#emit stor.s.pri is_crashdetect
			if (is_crashdetect) {
				// The offset is different when running under crashdetect as
				// it uses its own (modified) version of the VM. This value
				// value works only with crashdetect 4.13.
				return RelocateOpcodeNow(OP_NOP) - Opcode:0x1EA;
			} else {
				return RelocateOpcodeNow(OP_NOP) - Opcode:0x4F;
			}
		}
		case OP_BREAK: {
			return ReadOpcodeNearThis(4);
			#emit break
		}
	}
	return opcode;
}

static stock Opcode:opcode_table[NUM_OPCODES];
static stock bool:opcode_table_is_ready = false;

static stock InitOpcodeTable() {
	for (new i = 0; i < NUM_OPCODES; i++) {
		opcode_table[i] = RelocateOpcodeNow(Opcode:i);
	}
	opcode_table_is_ready = true;
}

stock Opcode:RelocateOpcode(Opcode:opcode) {
	if (!opcode_table_is_ready) {
		InitOpcodeTable();
	}
	return opcode_table[_:opcode];
}

stock Opcode:UnrelocateOpcode(Opcode:opcode) {
	if (!opcode_table_is_ready) {
		InitOpcodeTable();
	}
	if (OP_NONE <= opcode < Opcode:NUM_OPCODES) {
		return opcode;
	}
	for (new i = 0; i < NUM_OPCODES; i++) {
		if (opcode_table[i] == opcode) {
			return Opcode:i;
		}
	}
	return opcode;
}
