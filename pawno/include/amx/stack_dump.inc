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

#if defined STACK_DUMP_INC
	#endinput
#endif
#define STACK_DUMP_INC

/////////////////////////////////////////////////
//                  Stack layout
/////////////////////////////////////////////////
//          what       |   stack pointer (STK)
//-----------------------------------------------
//       <STACK TOP>   |        STP
//           ...       |      STP - 4
//           ...       |      STP - 8
//           ...       |        ...
//       argument_N    |     FRM + 4*(N+3)
//           ...       |        ...
//       argument_2    |     FRM + 16
//       argument_1    |     FRM + 12
//          4*N        |     FRM + 8
//       RET address   |     FRM + 4
//         old FRM     |     FRM
//                     |
//-------------- N E W  F R A M E ---------------
//                     |
//       local_var_1   |     FRM - 4
//       local_var_2   |     FRM - 8
//           ...       |        ...
//       local_var_M   |     FRM - 4*M
//          ...        |        ...
//          ...        |         8
//          ...        |         4
//        <BOTTOM>     |         0
//-----------------------------------------------

#include <a_samp>

#include "amx_memory"

stock DumpStack()
{
	new stp, stk;

	#emit lctrl 3
	#emit stor.s.pri stp
	#emit lctrl 4
	#emit stor.s.pri stk

	print("------------------------");
	print("Stack dump:");
	print("------------------------");

	// Skip locals + FRM + RETN address + paramcount.
	stk += 20;

	// Don't print above the top of the stack.
	new i = stp;
	printf("[0x%08x]: TOP", i);
	i -= 4;
	for ( ; i >= stk; i -= 4) {
		printf("[0x%08x]: 0x%08x", i, ReadAmxMemory(i));
	}

	print("------------------------");
}
