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

#if defined DISASM_INC
	#endinput
#endif
#define DISASM_INC

#include <string>

#include "amx_base"
#include "amx_header"
#include "amx_memory"
#include "opcode"

#define DISASM_MAX_INSN_NAME 15
#define DISASM_MAX_PUBLIC_NAME 32
#define DISASM_MAX_NATIVE_NAME 100

enum DisasmInsnInfo {
	DisasmInsnInfo_name[DISASM_MAX_INSN_NAME],
	DisasmInsnInfo_num_opers,
	bool:DisasmInsnInfo_needs_reloc
}

enum DisasmContext {
	DisasmContext_start_ip,
	DisasmContext_end_ip,
	DisasmContext_nip,
	DisasmContext_cip,
	Opcode:DisasmContext_opcode,
	DisasmContext_insn[DisasmInsnInfo]
}

static stock const insn_table[][DisasmInsnInfo] = {
	{ "none",        0, false },
	{ "load.pri",    1, false },
	{ "load.alt",    1, false },
	{ "load.s.pri",  1, false },
	{ "load.s.alt",  1, false },
	{ "lref.pri",    1, false },
	{ "lref.alt",    1, false },
	{ "lref.s.pri",  1, false },
	{ "lref.s.alt",  1, false },
	{ "load.i",      0, false },
	{ "lodb.i",      1, false },
	{ "const.pri",   1, false },
	{ "const.alt",   1, false },
	{ "addr.pri",    1, false },
	{ "addr.alt",    1, false },
	{ "stor.pri",    1, false },
	{ "stor.alt",    1, false },
	{ "stor.s.pri",  1, false },
	{ "stor.s.alt",  1, false },
	{ "sref.pri",    1, false },
	{ "sref.alt",    1, false },
	{ "sref.s.pri",  1, false },
	{ "sref.s.alt",  1, false },
	{ "stor.i",      0, false },
	{ "strb.i",      1, false },
	{ "lidx",        0, false },
	{ "lidx.b",      1, false },
	{ "idxaddr",     0, false },
	{ "idxaddr.b",   1, false },
	{ "align.pri",   1, false },
	{ "align.alt",   1, false },
	{ "lctrl",       1, false },
	{ "sctrl",       1, false },
	{ "move.pri",    0, false },
	{ "move.alt",    0, false },
	{ "xchg",        0, false },
	{ "push.pri",    0, false },
	{ "push.alt",    0, false },
	{ "push.r",      1, false },
	{ "push.c",      1, false },
	{ "push",        1, false },
	{ "push.s",      1, false },
	{ "pop.pri",     0, false },
	{ "pop.alt",     0, false },
	{ "stack",       1, false },
	{ "heap",        1, false },
	{ "proc",        0, false },
	{ "ret",         0, false },
	{ "retn",        0, false },
	{ "call",        1, true  },
	{ "call.pri",    0, false },
	{ "jump",        1, true  },
	{ "jrel",        1, true  },
	{ "jzer",        1, true  },
	{ "jnz",         1, true  },
	{ "jeq",         1, true  },
	{ "jneq",        1, true  },
	{ "jless",       1, true  },
	{ "jleq",        1, true  },
	{ "jgrtr",       1, true  },
	{ "jgeq",        1, true  },
	{ "jsless",      1, true  },
	{ "jsleq",       1, true  },
	{ "jsgrtr",      1, true  },
	{ "jsgeq",       1, true  },
	{ "shl",         0, false },
	{ "shr",         0, false },
	{ "sshr",        0, false },
	{ "shl.c.pri",   1, false },
	{ "shl.c.alt",   1, false },
	{ "shr.c.pri",   1, false },
	{ "shr.c.alt",   1, false },
	{ "smul",        0, false },
	{ "sdiv",        0, false },
	{ "sdiv.alt",    0, false },
	{ "umul",        0, false },
	{ "udiv",        0, false },
	{ "udiv.alt",    0, false },
	{ "add",         0, false },
	{ "sub",         0, false },
	{ "sub.alt",     0, false },
	{ "and",         0, false },
	{ "or",          0, false },
	{ "xort",        0, false },
	{ "not",         0, false },
	{ "neg",         0, false },
	{ "invert",      0, false },
	{ "add.c",       1, false },
	{ "smul.c",      1, false },
	{ "zero.pri",    0, false },
	{ "zero.alt",    0, false },
	{ "zero",        1, false },
	{ "zero.s",      1, false },
	{ "sign.pri",    0, false },
	{ "sign.alt",    0, false },
	{ "eq",          0, false },
	{ "neq",         0, false },
	{ "less",        0, false },
	{ "leq",         0, false },
	{ "grtr",        0, false },
	{ "geq",         0, false },
	{ "sless",       0, false },
	{ "sleq",        0, false },
	{ "sgrtr",       0, false },
	{ "sgeq",        0, false },
	{ "eq.c.pri",    1, false },
	{ "eq.c.alt",    1, false },
	{ "inc.pri",     0, false },
	{ "inc.alt",     0, false },
	{ "inc",         1, false },
	{ "inc.s",       1, false },
	{ "inc.i",       0, false },
	{ "dec.pri",     0, false },
	{ "dec.alt",     0, false },
	{ "dec",         1, false },
	{ "dec.s",       1, false },
	{ "dec.i",       0, false },
	{ "movs",        1, false },
	{ "cmps",        1, false },
	{ "fill",        1, false },
	{ "halt",        1, false },
	{ "bounds",      1, false },
	{ "sysreq.pri",  1, false },
	{ "sysreq.c",    1, false },
	{ "file",       -1, false }, // obsolete
	{ "line",       -1, false }, // obsolete
	{ "symbol",     -1, false }, // obsolete
	{ "srange",     -1, false }, // obsolete
	{ "jump.pri",    0, false },
	{ "switch",      1, true },
	{ "casetbl",    -1, true },
	{ "swap.pri",    0, false },
	{ "swap.alt",    0, false },
	{ "push.adr",    1, false },
	{ "nop",         0, false },
	{ "sysreq.d",    1, false },
	{ "symtag",      1, false }, // obsolete
	{ "break",       0, false }
};

stock DisasmInit(ctx[DisasmContext], start = 0, end = 0) {
	new hdr[AMX_HDR];
	GetAmxHeader(hdr);

	new dat = hdr[AMX_HDR_DAT];
	new cod = hdr[AMX_HDR_COD];

	new code_base = cod - dat;

	start += code_base;

	ctx[DisasmContext_nip] = start;
	ctx[DisasmContext_cip] = start;

	ctx[DisasmContext_start_ip] = start;
	if (end != 0) {
		ctx[DisasmContext_end_ip] = code_base + end;
	} else {
		ctx[DisasmContext_end_ip] = code_base + (dat - cod);
	}
}

stock bool:DisasmDecodeInsn(ctx[DisasmContext]) {
	new ip = ctx[DisasmContext_nip];
	if (ip >= 0) {
		return false;
	}

	new Opcode:opcode = UnrelocateOpcode(Opcode:ReadAmxMemory(ip));
	if (opcode <= OP_NONE || _:opcode >= NUM_OPCODES) {
		return false;
	}

	ctx[DisasmContext_cip] = ip;
	ctx[DisasmContext_opcode] = opcode;
	ctx[DisasmContext_insn] = insn_table[_:opcode];

	ip += 4;

	if (opcode == OP_CASETBL) {
		new n = ReadAmxMemory(ip);
		ip += 4;
		ip += (2 * n + 1) * 4;
		ctx[DisasmContext_insn][DisasmInsnInfo_num_opers] = n;
	} else {
		ip += 4 * insn_table[_:opcode][DisasmInsnInfo_num_opers];
	}

	ctx[DisasmContext_nip] = ip;
	return true;
}

stock Opcode:DisasmNextInsn(ctx[DisasmContext]) {
	if (DisasmDecodeInsn(ctx)) {
		return ctx[DisasmContext_opcode];
	}
	return OP_NONE;
}

stock Opcode:DisasmGetOpcode(ctx[DisasmContext]) {
	return ctx[DisasmContext_opcode];
}

stock DisasmGetOperand(ctx[DisasmContext], index = 0) {
	return ReadAmxMemory(ctx[DisasmContext_cip] + (index + 1) * 4);
}

stock DisasmGetNumOperands(ctx[DisasmContext]) {
	return ctx[DisasmContext_insn][DisasmInsnInfo_num_opers];
}

stock bool:DisasmNeedReloc(ctx[DisasmContext]) {
	return ctx[DisasmContext_insn][DisasmInsnInfo_needs_reloc];
}

stock DisasmGetNextIp(ctx[DisasmContext]) {
	return ctx[DisasmContext_nip];
}

stock DisasmGetCurIp(ctx[DisasmContext]) {
	return ctx[DisasmContext_cip];
}

stock DisasmGetInsnName(ctx[DisasmContext], name[], size = sizeof(name)) {
	name[0] = '\0';
	strcat(name, ctx[DisasmContext_insn][DisasmInsnInfo_name], size);
}

static stock ToHexStr(x) {
	new s[11];
	new i = 0;
	new j = 0;

	while (i < sizeof(s) && j < 8) {
		new n = x >> (7 - j) * 4 & 0xF;
		switch (n) {
			case 0x0..0x9:
				s[i] = n + '0';
			case 0xA..0xF:
				s[i] = n + 'a' - 0xA;
		}
		i++;
		j++;
	}

	return s;
}

static stock bool:IsPrintableAscii(c) {
	return 32 <= c <= 126;
}

static stock ToPrintableAscii(c) {
	return IsPrintableAscii(c) ? c : ' ';
}

stock DisasmWriteCode(File:file) {
	new ctx[DisasmContext];
	DisasmInit(ctx);

	new base = GetAmxBaseAddress();

	new hdr[AMX_HDR];
	GetAmxHeader(hdr);

	new dat = hdr[AMX_HDR_DAT];
	new cod = hdr[AMX_HDR_COD];

	fwrite(file, "; CODE\n\n");

	while (DisasmGetNextIp(ctx) < ctx[DisasmContext_end_ip])
	{
		if (!DisasmDecodeInsn(ctx)) {
			new cip = DisasmGetNextIp(ctx);
			ctx[DisasmContext_nip] += 4;
			fwrite(file, ToHexStr(cip + dat - cod));
			fwrite(file, " ???? ");
			fwrite(file, ToHexStr(ReadAmxMemory(cip)));
			fwrite(file, "\n");
			continue;
		}

		new Opcode:opcode = DisasmGetOpcode(ctx);

		if (opcode == OP_PROC) {
			fwrite(file, "\n");
		}

		new cip = DisasmGetCurIp(ctx);

		new insn_name[DISASM_MAX_INSN_NAME];
		DisasmGetInsnName(ctx, insn_name);
		fwrite(file, ToHexStr(cip + dat - cod));
		fwrite(file, " ");
		fwrite(file, insn_name);
		fwrite(file, " ");

		switch (opcode) {
			case OP_PROC: {
				new name[32];
				new address = cip + dat - cod;
				if (address == hdr[AMX_HDR_CIP]) {
					strcat(name, "main");
				} else {
					new index = GetPublicIndexFromAddress(address);
					if (index >= 0) {
						GetPublicNameFromIndex(index, name);
					}
				}
				if (strlen(name) != 0) {
					fwrite(file, "; ");
					fwrite(file, name);
				}
			}
			case OP_CASETBL: {
				new num = DisasmGetNumOperands(ctx);
				fwrite(file, ToHexStr(num));
				fwrite(file, " ");
				new rel_addr = DisasmGetOperand(ctx, 1) - (base + cod);
				fwrite(file, ToHexStr(rel_addr));
				for (new i = 1; i <= num; i++) {
					fwrite(file, "\n         case ");
					new val = DisasmGetOperand(ctx, i * 2);
					fwrite(file, ToHexStr(val));
					fwrite(file, " ");
					rel_addr = DisasmGetOperand(ctx, i * 2 + 1) - (base + cod);
					fwrite(file, ToHexStr(rel_addr));
				}
			}
			case OP_CALL: {
				new name[DISASM_MAX_PUBLIC_NAME];
				new address = DisasmGetOperand(ctx) - base - cod;
				if (address == hdr[AMX_HDR_CIP]) {
					strcat(name, "main");
				} else {
					new index = GetPublicIndexFromAddress(address);
					if (index >= 0) {
						GetPublicNameFromIndex(index, name);
					}
				}
				fwrite(file, ToHexStr(address));
				if (strlen(name) > 0) {
					fwrite(file, "; ");
					fwrite(file, name);
				}
			}
			case OP_SYSREQ_C, OP_SYSREQ_D: {
				new name[DISASM_MAX_NATIVE_NAME];
				new address = DisasmGetOperand(ctx);
				if (opcode == OP_SYSREQ_C) {
					new index = DisasmGetOperand(ctx);
					GetNativeNameFromIndex(index, name);
				} else {
					new index = GetNativeIndexFromAddress(address);
					if (index >= 0) {
						GetNativeNameFromIndex(index, name);
					}
				}
				fwrite(file, ToHexStr(address));
				if (strlen(name) > 0) {
					fwrite(file, "; ");
					fwrite(file, name);
				}
			}
			default: {
				new n = DisasmGetNumOperands(ctx);
				for (new i = 0; i < n; i++) {
					new operand = DisasmGetOperand(ctx, i);
					if (DisasmNeedReloc(ctx)) {
						operand -= base + cod;
					}
					fwrite(file, ToHexStr(operand));
				}
			}
		}

		fwrite(file, "\n");
	}
}

stock DisasmWriteDataRowChar(File:file, start, num, max) {
	new cur = start;
	new end = start + num*4;

	while (cur < max) {
		new p[4 char + 1];
		p[0] = ReadAmxMemory(cur);

		new u[4 + 1];
		u[0] = ToPrintableAscii(p{0});
		u[1] = ToPrintableAscii(p{1});
		u[2] = ToPrintableAscii(p{2});
		u[3] = ToPrintableAscii(p{3});
		u[4] = '\0';

		if (cur < end) {
			fwrite(file, u);
		} else {
			fwrite(file, " ");
		}
		cur += 4;
	}
}

stock DisasmWriteDataRowHex(File:file, start, num, max) {
	new cur = start;
	new end = start + num*4;

	while (cur < max) {
		if (cur < end) {
			fwrite(file, ToHexStr(ReadAmxMemory(cur)));
		} else {
			fwrite(file, "        ");
		}
		fwrite(file, " ");
		cur += 4;
	}
}

stock DisasmWriteData(File:file) {
	fwrite(file, "\n\n; DATA\n");

	new hdr[AMX_HDR];
	GetAmxHeader(hdr);

	new dat = hdr[AMX_HDR_DAT];
	new hea = hdr[AMX_HDR_HEA];
	new data_end = hea - dat;

	for (new i = 0; i < data_end; i += 0x10) {
		fwrite(file, ToHexStr(i));
		fwrite(file, "  ");
		DisasmWriteDataRowHex(file, i, 4, min(i + 0x10, data_end));
		fwrite(file, " ");
		DisasmWriteDataRowChar(file, i, 4, min(i + 0x10, data_end));
		fwrite(file, "\n");
	}
}

stock DisasmWriteFile(File:file) {
	DisasmWriteCode(file);
	DisasmWriteData(file);
}

stock bool:DisasmWrite(const filename[]) {
	new File:file = fopen(filename, io_write);
	if (file) {
		DisasmWriteFile(file);
		fclose(file);
		return true;
	}
	return false;
}

stock DisasmDump(const filename[]) {
	DisasmWrite(filename);
}
