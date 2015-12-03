#include <a_samp>

#if !defined INTROSPECT_MAX_ARGS
	#define INTROSPECT_MAX_ARGS 16
#endif

#if !defined INTROSPECT_MAX_GLOBALS
	#define INTROSPECT_MAX_GLOBALS 2048
#endif

#if !defined INTROSPECT_MAX_FUNCTIONS
	#define INTROSPECT_MAX_FUNCTIONS 2048
#endif

#if !defined INTROSPECT_MAX_TOTAL_ARGS
	#define INTROSPECT_MAX_TOTAL_ARGS (INTROSPECT_MAX_FUNCTIONS * 4)
#endif

#if !defined INTROSPECT_MAX_TAGS
	#define INTROSPECT_MAX_TAGS 512
#endif

enum {
	IDENT_VARIABLE  = 1,
	IDENT_REFERENCE = 2,
	IDENT_ARRAY     = 3,
	IDENT_REFARRAY  = 4,
	IDENT_FUNCTION  = 9
}

enum {
	VCLASS_GLOBAL,
	VCLASS_LOCAL,
	VCLASS_STATIC
}

enum E_VARIABLE {
	Address,
	Tag,
	CodeStart,
	CodeEnd,
	Ident,
	Name[32],
	Dimensions,
	DimensionSize[3],
	DimensionTag[3]
}

enum E_FUNCTION {
	Address,
	CodeStart = 0,
	CodeEnd,
	Name[48],
	Tag,
	DimensionSize,
	StaticArgs,
	Arg[INTROSPECT_MAX_ARGS]
}

enum E_TAG {
	Tag,
	Name[32]
}

static stock
	s_Globals[INTROSPECT_MAX_GLOBALS][E_VARIABLE],
	s_Arguments[INTROSPECT_MAX_TOTAL_ARGS][E_VARIABLE],
	s_Functions[INTROSPECT_MAX_FUNCTIONS][E_FUNCTION],
	s_Tags[INTROSPECT_MAX_TAGS][E_TAG],
	
	s_NumGlobals,
	s_NumArguments,
	s_NumFunctions,
	s_NumTags
;

public _@_isdi_funcinc();
public _@_isdi_funcinc() {
	strunpack("", "", 0);
}

stock ReadAmxDebugData(File:fp) {
	new offset = 0;
	
	s_NumGlobals = 0;
	s_NumArguments = 0;
	s_NumFunctions = 0;
	s_NumTags = 0;
	
	// Go to the end of the AMX (0 contains the size excluding debug information)
	offset = freadcell(fp);
	fseek(fp, 0), fseek(fp, offset);
	
	// Read the header
	new size         = freadcell(fp);
	new magic        = freadshort(fp);
	new file_version = freadbyte(fp);
	new amx_version  = freadbyte(fp);
	new flags        = freadshort(fp);
	new num_files    = freadshort(fp);
	new num_lines    = freadshort(fp);
	new num_symbols  = freadshort(fp);
	new num_tags     = freadshort(fp);
	new num_machines = freadshort(fp);
	new num_states   = freadshort(fp);
	
	offset += 22;
	
	#pragma unused num_states, num_machines, flags, amx_version, file_version, magic, size
	
	// Skip the file table
	for (new i = 0; i < num_files; i++) {
		fseek(fp, 4, seek_current);
		offset += 4;
		
		do {
			offset++;
		} while (freadbyte(fp));
	}
	
	// Skip the line table
	fseek(fp, num_lines * 8, seek_current);
	offset += num_lines * 8;
	
	// Read global variables and functions from the symbol table
	ReadSymbolTable(fp, num_symbols);
	
	// Read function arguments from the symbol table
	fseek(fp, offset);
	ReadSymbolTable(fp, num_symbols, true);
	
	// Read tags
	for (new i = 0; i < num_tags; i++) {
		s_Tags[i][Tag] = freadshort(fp);
		freadstr(fp, s_Tags[i][Name], 32);
	}
	
	s_NumTags = num_tags;
}

static stock ReadSymbolTable(File:fp, num_symbols, bool:read_args = false) {
	for (new i = 0; i < num_symbols; i++) {
		new address = freadcell(fp);
		new tag = freadshort(fp);
		new codestart = freadcell(fp);
		new codeend = freadcell(fp);
		new ident = freadbyte(fp);
		new vclass = freadbyte(fp);
		new dim = freadshort(fp);
		new name[48]; freadstr(fp, name);
		new dim_tag[4], dim_size[4];
		
		for (new j = 0; j < dim; j++) {
			dim_tag[j] = freadshort(fp);
			dim_size[j] = freadcell(fp);
		}
		
		if (read_args) {
			if (vclass == VCLASS_LOCAL) {
				for (new n = 0; n < s_NumFunctions; n++) {
					if (s_Functions[n][CodeStart] == codestart) {
						s_Arguments[s_NumArguments][Address] = address;
						s_Arguments[s_NumArguments][Tag] = tag;
						s_Arguments[s_NumArguments][Dimensions] = dim;
						s_Arguments[s_NumArguments][CodeStart] = codeend;
						s_Arguments[s_NumArguments][CodeEnd] = codestart;
						s_Arguments[s_NumArguments][Ident] = ident;
						strunpack(s_Arguments[s_NumArguments][Name], name, 32);
						
						for (new j = 0; j < 3; j++) {
							s_Arguments[s_NumArguments][DimensionTag][j] = dim_tag[j];
							s_Arguments[s_NumArguments][DimensionSize][j] = dim_size[j];
						}
						
						s_Functions[n][Arg][s_Functions[n][StaticArgs]] = s_NumArguments;
						
						s_Functions[n][StaticArgs]++;
						s_NumArguments++;
						
						break;
					}
				}
			}
			
			continue;
		}
		
		if (vclass != VCLASS_GLOBAL) {
			continue;
		}
		
		switch (ident) {
			case IDENT_VARIABLE,
			     IDENT_ARRAY: {
				 // TODO: detect if it's a global static
				s_Globals[s_NumGlobals][Address] = address;
				s_Globals[s_NumGlobals][Tag] = tag;
				s_Globals[s_NumGlobals][Dimensions] = dim;
				s_Globals[s_NumGlobals][CodeStart] = codeend;
				s_Globals[s_NumGlobals][CodeEnd] = codestart;
				s_Globals[s_NumGlobals][Ident] = ident;
				strunpack(s_Globals[s_NumGlobals][Name], name, 32);
				
				for (new j = 0; j < 3; j++) {
					s_Globals[s_NumGlobals][DimensionTag][j] = dim_tag[j];
					s_Globals[s_NumGlobals][DimensionSize][j] = dim_size[j];
				}
				
				s_NumGlobals++;
			}
			
			case IDENT_FUNCTION: {
				s_Functions[s_NumFunctions][Address] = address;
				s_Functions[s_NumFunctions][CodeEnd] = codeend;
				strunpack(s_Functions[s_NumFunctions][Name], name, 48);
				s_Functions[s_NumFunctions][Tag] = tag;
				s_Functions[s_NumFunctions][DimensionSize] = dim_size[0];
				
				s_NumFunctions++;
			}
		}
	}
}

stock GetFunctionFromAddress(address) {
	new ret[48];
	
	for (new i = 0; i < s_NumFunctions; i++) {
		if (address == s_Functions[i][Address]) {
			strcat(ret, s_Functions[i][Name]);
			break;
		}
	}
	
	return ret;
}

stock GetVariableFromAddress(address) {
	new ret[32];
	
	for (new i = 0; i < s_NumGlobals; i++) {
		if (address == s_Globals[i][Address]) {
			strcat(ret, s_Globals[i][Name]);
			break;
		}
	}
	
	return ret;
}

stock GetFunctionIdx(const name[]) {
	for (new i = 0; i < s_NumFunctions; i++) {
		if (!strcmp(name, s_Functions[i][Name])) {
			return i;
		}
	}
	
	return -1;
}

stock GetVariableIdx(const name[]) {
	for (new i = 0; i < s_NumGlobals; i++) {
		if (!strcmp(name, s_Globals[i][Name])) {
			return i;
		}
	}
	
	return -1;
}

stock GetFunctionInfo(const name[], info[E_FUNCTION]) {
	new i = GetFunctionIdx(name);
	
	if (i == -1) {
		return false;
	}
	
	memcpy(info[E_FUNCTION:0], s_Functions[i][E_FUNCTION:0], 0, _:E_FUNCTION * 4, _:E_FUNCTION);
	
	return true;
}

stock GetVariableInfo(const name[], info[E_VARIABLE]) {
	new i = GetVariableIdx(name);
	
	if (i == -1) {
		return false;
	}
	
	memcpy(info[E_VARIABLE:0], s_Globals[i][E_VARIABLE:0], 0, _:E_VARIABLE * 4, _:E_VARIABLE);
	
	return true;
}

stock GetFunctionArgument(const func_info[E_FUNCTION], idx, info[E_VARIABLE]) {
	idx = func_info[StaticArgs] - 1 - idx;
	
	if (idx < 0 || idx >= INTROSPECT_MAX_ARGS) {
		return false;
	}
	
	new arg = func_info[Arg][idx];
	
	if (!(0 <= arg < s_NumArguments)) {
		return false;
	}
	
	memcpy(info[E_VARIABLE:0], s_Arguments[arg][E_VARIABLE:0], 0, _:E_VARIABLE * 4, _:E_VARIABLE);
	
	return true;
}

stock GetTagIdx(const name[]) {
	for (new i = 0; i < s_NumTags; i++) {
		if (!strcmp(name, s_Tags[i][Name])) {
			return s_Tags[i][Tag] | 0xC0000000;
		}
	}
	
	return -1;
}

stock GetTagName(tag) {
	new output[32] = "";
	
	tag &= 0xC0000000;
	
	for (new i = 0; i < s_NumTags; i++) {
		if (s_Tags[i][Tag] == tag) {
			strunpack(output, s_Tags[i][Name]);
		}
	}
	
	return output;
}

stock GetStringFromVariableValue(output[], maxlength = sizeof(output), const info[E_VARIABLE], ...) {
	if (info[Dimensions] > 0) {
		if (info[Dimensions] > 1 || (info[Tag] && info[DimensionSize] == 0)) {
			if (info[Tag]) {
				new tag[32]; tag = GetTagName(info[Tag]);
				
				format(output, maxlength, "<%s:array", tag);
			} else {
				strunpack(output, "<array", maxlength);
			}
			
			for (new i = 0; i < info[Dimensions]; i++) {
				if (info[DimensionSize][i]) {
					format(output, maxlength, "%s[%d]", output, info[DimensionSize][i]);
				} else {
					strcat(output, "[]", maxlength);
				}
			}
			
			strcat(output, ">", maxlength);
			
			return;
		} else {
			// TODO: is zero-terminated with mostly ascii characters? otherwise array
			if (info[Tag]) {
				new tag[32]; tag = GetTagName(info[Tag]);
				
				strunpack(output, "[", maxlength);
				
				if (!strcmp("Float", tag)) {
					for (new i = 0; i < info[DimensionSize][0]; i++) {
						format(output, maxlength, i ? ("%s, %.4f") : ("%s%.4f"), output, getarg(3, i));
					}
				} else {
					for (new i = 0; i < info[DimensionSize][0]; i++) {
						format(output, maxlength, i ? ("%s, %d") : ("%s%d"), output, getarg(3, i));
					}
				}
				
				strcat(output, "]", maxlength);
			} else {
				output[0] = '\0';
				
				// TODO: string literal
				#emit PUSH.S   maxlength
				#emit LCTRL    5
				#emit ADD.C    24
				#emit LOAD.I
				#emit PUSH.pri
				#emit PUSH.S   output
				#emit PUSH.C   12
				#emit SYSREQ.C strunpack
				#emit STACK    16
			}
		}
	} else {
		if (!info[Tag]) {
			format(output, maxlength, "%d", getarg(3));
		} else {
			new tag[32]; tag = GetTagName(info[Tag]);
			
			if (!strcmp("Float", tag)) {
				format(output, maxlength, "%.4f", getarg(3));
			} else if (!strcmp("bool", tag, true)) {
				if (getarg(3)) {
					strunpack(output, "true", maxlength);
				} else {
					strunpack(output, "false", maxlength);
				}
			} else if (!strcmp("hex", tag, true)) {
				format(output, maxlength, "%08x", getarg(3));
			} else if (!strcmp("bin", tag, true) || !strcmp("binary", tag, true)) {
				format(output, maxlength, "%032b", getarg(3));
			}
		}
	}
}

// Read a single cell
static stock freadcell(File:fp) {
	new buf[1];
	
	fblockread(fp, buf);
	
	return buf[0];
}

// Read a 16-bit integer
static stock freadshort(File:fp) {
	new buf[1];
	
	fblockread(fp, buf);
	fseek(fp, -2, seek_current);
	
	return buf[0] & 0xFFFF;
}

// Read a single byte
static stock freadbyte(File:fp) {
	return fgetchar(fp, 0, false);
}

// Read a zero-terminated string
static stock freadstr(File:fp, buf[], maxlength = sizeof(buf)) {
	new i = 0, c;
	
	buf[i] = '\0';
	
	while ((c = fgetchar(fp, 0))) {
		if (i + 1 < maxlength) {
			buf[i++] = c;
		}
	}
	
	buf[i] = '\0';
	
	return i;
}