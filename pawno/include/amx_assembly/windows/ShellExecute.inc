// Copyright (C) 2012 Zeex
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "import_table"
#include "../amx_header"
#include "../amx_memory"
#include "../dynamic_call"
#include "../phys_memory"
#include "../shellcode"

// http://msdn.microsoft.com/en-us/library/windows/desktop/bb762153%28v=vs.85%29.aspx

#define SW_HIDE (0)
#define SW_MAXIMIZE (3)
#define SW_MINIMIZE (6)
#define SW_RESTORE (9)
#define SW_SHOW (5)
#define SW_SHOWDEFAULT (10)
#define SW_SHOWMAXIMIZED (3)
#define SW_SHOWMINIMIZED (2)
#define SW_SHOWMINNOACTIVE (7)
#define SW_SHOWNA (8)
#define SW_SHOWNOACTIVATE (4)
#define SW_SHOWNORMAL (1)

// NOTE: string arguments must be prepared with ToCharString() or similar function.
stock ShellExecute(const Operation[], const File[], const Parameters[], ShowCmd) {
	/*
	.text:10001000 55                                push    ebp
	.text:10001001 8B EC                             mov     ebp, esp
	.text:10001003 8B 45 0C                          mov     eax, [ebp+arg_4]
	.text:10001006 8B 48 18                          mov     ecx, [eax+18h]
	.text:10001009 51                                push    ecx             ; nShowCmd
	.text:1000100A 8B 55 0C                          mov     edx, [ebp+arg_4]
	.text:1000100D 8B 42 14                          mov     eax, [edx+14h]
	.text:10001010 50                                push    eax             ; lpDirectory
	.text:10001011 8B 4D 0C                          mov     ecx, [ebp+arg_4]
	.text:10001014 8B 51 10                          mov     edx, [ecx+10h]
	.text:10001017 52                                push    edx             ; lpParameters
	.text:10001018 8B 45 0C                          mov     eax, [ebp+arg_4]
	.text:1000101B 8B 48 0C                          mov     ecx, [eax+0Ch]
	.text:1000101E 51                                push    ecx             ; lpFile
	.text:1000101F 8B 55 0C                          mov     edx, [ebp+arg_4]
	.text:10001022 8B 42 08                          mov     eax, [edx+8]
	.text:10001025 50                                push    eax             ; lpOperation
	.text:10001026 8B 4D 0C                          mov     ecx, [ebp+arg_4]
	.text:10001029 8B 51 04                          mov     edx, [ecx+4]
	.text:1000102C 52                                push    edx             ; hwnd
	.text:1000102D FF 15 78 56 34 12                 call    ds:ShellExecuteA ; Opens or prints a specified file
	.text:10001033 5D                                pop     ebp
	.text:10001034 C3                                retn
	*/

	#define __(%0,%1,%2,%3) (((0x%3) << 24) | ((0x%2) << 16) | (0x%1 << 8) | (0x%0))

	static const asm[] = {
		__(90,90,90,90),
		__(90,90,90,90),
		__(90,90,90,90),
		__(90,90,90,90),
		__(55,8B,EC,8B),
		__(45,0C,8B,48),
		__(18,51,8B,55),
		__(0C,8B,42,14),
		__(50,8B,4D,0C),
		__(8B,51,10,52),
		__(8B,45,0C,8B),
		__(48,0C,51,8B),
		__(55,0C,8B,42),
		__(08,50,8B,4D),
		__(0C,8B,51,04),
		__(52,FF,15,00),
		__(00,00,00,5D),
		__(C3,CC,CC,CC)
	};

	#undef __

	new address = GetImportAddress("ShellExecuteA");
	WriteAmxMemory(ref(asm) + 63, refabs(address));

	Push(0);                  // HWND hwnd
	Push(refabs(Operation));  // LPCTSTR lpOperation
	Push(refabs(File));       // LPCTSTR lpFile
	Push(refabs(Parameters)); // LPCTSTR lpParameters
	Push(0);                  // LPCTSTR lpDirectory
	Push(ShowCmd);            // INT nShowCmd

	return RunShellcode(refabs(asm));
}
