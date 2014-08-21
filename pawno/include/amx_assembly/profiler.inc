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

#if defined PROFILER_INC
	#endinput
#endif
#define PROFILER_INC

#include <a_samp>

#include "amx_base"
#include "amx_header"
#include "opcode"

// Call stack size (maximum call depth).
#if !defined PROF_MAX_CALL_STACK
	#define PROF_MAX_CALL_STACK 10
#endif

// Maximum number of profiled publics.
#if !defined PROF_MAX_PUBLICS
	#define PROF_MAX_PUBLICS 1000
#endif

enum ProfEntryCode {
	pec_push_address[2],
	pec_push_index[2],
	pec_push_8[2],
	pec_call_enter[2]
}

static stock g_pecs[PROF_MAX_PUBLICS][ProfEntryCode];
static stock g_num_pecs;

enum ProfCallInfo {
	pci_index,
	pci_start_time
}

enum ProfPublicInfo {
	ppi_child_time,
	ppi_total_time,
	ppi_num_calls
}

static stock g_publics[PROF_MAX_PUBLICS][ProfPublicInfo];
static stock g_num_publics;

static stock g_call_stack[PROF_MAX_CALL_STACK][ProfCallInfo];
static stock g_call_depth;

static stock exit_public() {
	if (--g_call_depth < sizeof(g_call_stack)) {
		new index = g_call_stack[g_call_depth][pci_index];

		new parent = -1;
		if (g_call_depth > 0) {
			parent = g_call_stack[g_call_depth-1][pci_index];
		}

		if (index < g_num_publics) {
			new i = g_call_depth;
			new tick = GetTickCount();
			new time = tick - g_call_stack[i][pci_start_time];
			if (time < 0) {
				// Work around negative intervals due to tick count overflow
				if (tick < 0) {
					time = (tick - cellmin) + (cellmax - g_call_stack[i][pci_start_time]);
				}
			}
			if (time > 0) {
				g_publics[index][ppi_total_time] += time;
				if (parent > 0) {
					g_publics[parent][ppi_child_time] += time;
				}
			}
			g_publics[index][ppi_num_calls]++;
		}
		//{
		//	new public_name[32];
		//	GetPublicNameByIndex(index, public_name);
		//	printf("Leaving %s", public_name);
		//}
	}

	#emit halt 0
	return 0; // make compiler happy
}

static stock enter_public(index, address) {
	//{
	//	new public_name[32];
	//	GetPublicNameByIndex(index, public_name);
	//	printf("Entering %s", public_name);
	//}

	if (g_call_depth < sizeof(g_call_stack)) {
		new pci[ProfCallInfo];
		pci[pci_index] = index;
		pci[pci_start_time] = GetTickCount();
		g_call_stack[g_call_depth] = pci;
	} else {
		printf("profiler warning: PROF_MAX_CALL_STACK is set to %d but current level is %d", PROF_MAX_CALL_STACK, g_call_depth);
	}

	// Pop locals + arguments + numbytes + return address + frm.
	#emit stack 20

	++g_call_depth;

	// modify public's return address so it will jump to exit_public() when done
	#emit stack 4
	#emit push.c exit_public

	// jump to the public
	#emit load.s.pri address
	#emit jump.pri

	return 0; // make compiler happy
}

static stock new_pec(index, address, code_start) {
	if (g_num_pecs < sizeof(g_pecs)) {
		new pec[ProfEntryCode];

		pec[pec_push_address][0] = RelocateOpcode(OP_PUSH_C);
		pec[pec_push_address][1] = address;

		pec[pec_push_index][0] = RelocateOpcode(OP_PUSH_C);
		pec[pec_push_index][1] = index;

		pec[pec_push_8][0] = RelocateOpcode(OP_PUSH_C);
		pec[pec_push_8][1] = 8;

		new enter_proc;
		#emit const.pri enter_public
		#emit stor.s.pri enter_proc
		pec[pec_call_enter][0] = RelocateOpcode(OP_CALL);
		pec[pec_call_enter][1] = code_start + enter_proc;

		g_pecs[g_num_pecs] = pec;
		return g_num_pecs++;
	}

	return -1;
}

stock ProfilerInit() {
	new hdr[AMX_HDR];
	GetAmxHeader(hdr);

	new publics = hdr[AMX_HDR_PUBLICS] - hdr[AMX_HDR_DAT];
	new defsize = hdr[AMX_HDR_DEFSIZE];
	new num_publics = (hdr[AMX_HDR_NATIVES] - hdr[AMX_HDR_PUBLICS]) / defsize;

	new amx_base = GetAmxBase();

	// Redirect all public calls to ProfileHook().
	for (new i = 0, cur = publics; i < num_publics; cur += defsize, i++) {
		new address;
		#emit lref.s.pri cur
		#emit stor.s.pri address

		new pec_index = new_pec(i, address, amx_base + hdr[AMX_HDR_COD]);
		if (pec_index < 0) {
			printf("profiler warning: Too many public functions (%d). Consider increasing PROF_MAX_PUBLICS.", num_publics);
			break;
		}

		// Get start address of the g_pecs sub-array at pec_index.
		new pec_start;
		#emit const.alt g_pecs
		#emit load.s.pri pec_index
		#emit idxaddr
		#emit move.alt
		#emit load.i
		#emit add
		#emit stor.s.pri pec_start

		// Alter public table to redirect calls to the PEC.
		HookPublic(i, pec_start + hdr[AMX_HDR_DAT] - hdr[AMX_HDR_COD]);

		g_publics[i][ppi_child_time] = 0;
		g_publics[i][ppi_total_time] = 0;
		g_publics[i][ppi_num_calls] = 0;
		g_num_publics++;
	}
}

stock bool:ProfilerWriteData(const filename[]) {
	new File:file = fopen(filename, io_write);
	new buffer[100];

	if (!file) {
		return false;
	}

	fwrite(file, "+----------------------------------+----------------+----------------+----------------+\n");
	fwrite(file, "| name                             |          calls |      self_time |     total_time |\n");
	fwrite(file, "+----------------------------------+----------------+----------------+----------------+\n");

	for (new i = 0; i < g_num_publics; i++) {
		new name[32];
		GetPublicNameByIndex(i, name);
		format(buffer, sizeof(buffer), "| %32s |%15d |%15d |%15d |\n",
			name,
			g_publics[i][ppi_num_calls],
			g_publics[i][ppi_total_time] - g_publics[i][ppi_child_time],
			g_publics[i][ppi_total_time]
		);
		fwrite(file, buffer);
		fwrite(file, "+----------------------------------+----------------+----------------+----------------+\n");
	}

	fclose(file);
	return true;
}
