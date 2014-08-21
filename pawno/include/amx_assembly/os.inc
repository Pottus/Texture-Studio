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

#if defined OS_INC
	#endinput
#endif
#define OS_INC

#include "opcode"

enum OS {
	OS_UNKNOWN,
	OS_LINUX,
	OS_WINDOWS
};

stock OS:GetOS() {
	static OS:os = OS_UNKNOWN;
	if (os == OS_UNKNOWN) {
		os = RelocateOpcode(OP_LOAD_PRI) == OP_LOAD_PRI
			? OS_WINDOWS
			: OS_LINUX;
	}
	return os;
}

stock bool:IsWindows() {
	return GetOS() == OS_WINDOWS;
}

stock bool:IsLinux() {
	return GetOS() == OS_LINUX;
}
