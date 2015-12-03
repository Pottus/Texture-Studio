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

#include <a_samp>
#include "../phys_memory"

// Helpful resources:
//
//  o  Peering Inside the PE: A Tour of the Win32 Portable Executable File Format
//
//       http://msdn.microsoft.com/en-us/library/ms809762.aspx
//
//  o  Understanding the Import Address Table
//
//       http://sandsprite.com/CodeStuff/Understanding_imports.html
//
//  o  Microsoft PE and COFF Specification
//
//       http://msdn.microsoft.com/en-us/windows/hardware/gg463119.aspx

static stock const DefaultImageBase = 0x00400000;

static stock const SizeOfFileHeader = 0x14;
static stock const SizeOfOptionalHeader = 0xE0;
static stock const SizeOfImportDirectory = 0x14;

stock GetImportPointer(const name[]) {
	new DosHeader = DefaultImageBase;
	new NtHeaders = DosHeader + ReadDword(DosHeader, 0x3C);

	new FileHeader = NtHeaders + 0x04;
	new OptionalHeader = FileHeader + SizeOfFileHeader;

	new ImageBase = ReadDword(OptionalHeader, 0x1C);

	new ImportTableRva = ReadDword(OptionalHeader, 0x68);
	new ImportDirectories = ImageBase + ImportTableRva;

	for (new i = 0; ; i++) {
		new ImportDirectory = ImportDirectories + i * SizeOfImportDirectory;

		new Name = ReadDword(ImportDirectory, 0x0C);
		if (Name == 0)
			break;

		new ImportLookupTable = ImageBase + ReadDword(ImportDirectory, 0x00);
		new ImportAddressTable = ImageBase + ReadDword(ImportDirectory, 0x10);

		for (new j = 0 ; ; j++) {
			new NameOrdinal = ReadDword(ImportLookupTable, j * 4);

			new bool:NameOrdinalFlag = (NameOrdinal & 0x80000000) != 0;
			if (NameOrdinalFlag)
				continue;

			new ImportByName = NameOrdinal & ~0x80000000;
			if (ImportByName == 0)
				break;

			new iname[256];
			ReadString(ImageBase, ImportByName + 2, iname);

			if (strcmp(iname, name) == 0) {
				return ImportAddressTable + j * 4;
			}
		}
	}

	return 0;
}

// Finds a function in the Import Table and returns its address or 0 if found nothing.
stock GetImportAddress(const name[]) {
	new ImportPointer = GetImportPointer(name);

	if (ImportPointer != 0) {
		return ReadDword(ImportPointer, 0);
	}

	return 0;
}

static stock ToCharString(s[], size = sizeof(s)) {
	for (new i = 0; i < size; i++) {
		s[i] = swapchars(s[i]);
	}
}

static stock ReadDword(base, offset = 0) {
	return ReadPhysMemoryCell(base + offset);
}

static stock ReadString(base, offset = 0, dest[], size = sizeof(dest)) {
	ReadPhysMemory(base + offset, dest, size);
	ToCharString(dest, size);
	strunpack(dest, dest, size);
}
