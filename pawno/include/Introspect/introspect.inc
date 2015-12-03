#include <a_samp>

#if !defined AMX_NAME
	#error Please #define AMX_NAME "amx_name.amx"
#endif

#if debug < 2
	#error The debug level must be 2 or 3
#endif

#if !defined MAX_GLOBAL_VARIABLES
	#define MAX_GLOBAL_VARIABLES 4096
#endif

#if !defined MAX_FUNCTIONS
	#define MAX_FUNCTIONS 2048
#endif

#if !defined MAX_TAGS
	#define MAX_TAGS 512
#endif

#include "introspect-debug-info"

#if defined INTROSPECT_NATIVES
	#include "introspect-natives"
	
	#tryinclude "..\amx\amx_header"
	#tryinclude "..\amx\dynamic_call"
	
	#if !defined CallNative || !defined SysreqCN
		#error amx_assembly is required. Get it here: github.com/Zeex/amx_assembly
	#endif
#endif

static stock const s_AmxName[] = AMX_NAME;

stock IntrospectInit() {
	static s_initialized = false;
	
	if (s_initialized) {
		return true;
	} else {
		s_initialized = true;
	}
	
	new File:fp = fopen(s_AmxName, io_read);
	
	// Try some more versions based on Y_Less' tool: http://forum.sa-mp.com/showthread.php?t=458669
	if (!fp) {
		static const s_ServerDir[] = "DANGEROUS_SERVER_ROOT/";
		static const s_ModeDirs[][] = {
			"gamemodes/",
			"filterscripts/",
			"npcmodes/"
		};
		new path[64];
		for (new i = 0; i != 6; ++i) {
			format(path, sizeof (path), "%s%s%s", (i < 3) ? (s_ServerDir) : (""), s_ModeDirs[i % 3], s_AmxName);
			if ((fp = fopen(path))) break;
		}
	}

	if (!fp) {
		printf("(introspect.inc) Unable to open \"%s\"", s_AmxName);

		return false;
	}
	
	ReadAmxDebugData(fp);
	
	fclose(fp);
	
	return (s_initialized = true);
}

static stock DereferenceArray(addr, dimensions, ...) {
	new resolve = numargs() - 3;
	
	for (new i = 0; i <= resolve; i++) {
		new idx = getarg(2 + i);
	
		if (i + 1 >= dimensions) {
			#emit LOAD.S.pri idx
			#emit LOAD.S.alt addr
			#emit IDXADDR
			#emit STOR.S.pri addr
		} else {
			#emit LOAD.S.pri idx
			#emit LOAD.S.alt addr
			#emit IDXADDR
			#emit MOVE.alt
			#emit LOAD.I
			#emit ADD
			#emit STOR.S.pri addr
		}
	}
	
	return addr;
}

static stock ReadSymbol(const input[], &index, output[], maxlength = sizeof(output)) {
	new i = index, j = 0;
	
	if ('0' <= input[i] <= '9') {
		return false;
	}
	
	for (new c; (c = input[i]); i++) {
		if (j + 1 >= maxlength) {
			return false;
		}
		
		switch (c) {
			case 'a' .. 'z',
			     'A' .. 'Z',
			     '0' .. '9',
			     '@', '_': {
				output[j++] = c;
				
				continue;
			}
			
			default: {
				break;
			}
		}
	}
	
	if (!j) {
		return false;
	}
	
	output[j] = '\0';
	
	index = i;
	
	return j;
}

static stock ReadString(const input[], &index, output[], maxlength = sizeof(output)) {
	new in_esc = false, i = 0, c;
	
	for (index++; (c = input[index]); index++) {
		if (i + 1 >= maxlength) {
			break;
		}
		
		if (c == '\\') {
			if (in_esc) {
				in_esc = false;
				
				output[i++] = '\\';
			} else {
				in_esc = true;
			}
		} else if (in_esc) {
			switch (c) {
				case '"': output[i++] = c;
				case 'a': output[i++] = '\a';
				case 'b': output[i++] = '\b';
				case 'e': output[i++] = '\e';
				case 'r': output[i++] = '\r';
				case 'n': output[i++] = '\n';
				case 't': output[i++] = '\t';
				case 'v': output[i++] = '\v';
			}
			
			in_esc = false;
		} else {
			if ( c == '"') {
				output[i] = '\0';
				index++;
				
				return true;
			} else {
				output[i++] = c;
			}
		}
	}
	
	output[i] = '\0';
	
	return false;
}

static stock ReadNumber(const input[], &index, &output, &type) {
	new i, c, had_num = false;
	
	type = 'i';
	
	for (i = index; (c = input[i]); i++) {
		if (i == 0 && c == '-') {
			continue;
		}
		
		switch (c) {
			case '0' .. '9': {
				had_num = true;
				
				continue;
			}
			
			case '.': {
				if (!had_num) {
					return false;
				}
				
				type = 'f';
			}
			
			case '-', '+', 'e': {
				if (!had_num) {
					return false;
				}
				
				continue;
			}
			
			default: {
				break;
			}
		}
	}
	
	if (!had_num) {
		return false;
	}
	
	if (type == 'f') {
		output = _:floatstr(input[index]);
	} else {
		output = strval(input[index]);
	}
	
	index = i;
	
	return true;
}

static stock ReadArrayIndexes(info[E_VARIABLE], const input[], &index) {
	SkipSpaces(input, index);
	
	while (input[index] == '[') {
		index++, SkipSpaces(input, index);
		
		new idx, type;
		
		if (!ReadNumber(input, index, idx, type) || type != 'i') {
			return false;
		}
		
		info[Address] = DereferenceArray(info[Address], info[Dimensions], idx);
		
		info[Dimensions]--;
		
		info[DimensionSize][0] = info[DimensionSize][1];
		info[DimensionSize][1] = info[DimensionSize][2];
		info[DimensionSize][2] = 0;
		
		info[DimensionTag][0] = info[DimensionTag][1];
		info[DimensionTag][1] = info[DimensionTag][2];
		info[DimensionTag][2] = 0;
		
		SkipSpaces(input, index);
		
		if (input[index] == ']') {
			index++, SkipSpaces(input, index);
		} else {
			return false;
		}
	}
	
	return true;
}

static stock SkipSpaces(const buf[], &index) {
	while ('\0' < buf[index] <= ' ') {
		index++;
	}
}

static stock GetVariableAddress(...) {
	#emit LOAD.S.pri 12
	#emit RETN
	
	return 0;
}

stock RunSimpleStatement(const statement[], &output_type = 0, output[] = {0}, outlen = sizeof(output), error[] = "", errlen = sizeof(error)) {
	IntrospectInit();
	
	new sym[32], idx = 0, start_idx;
	
	#pragma unused outlen
	
	SkipSpaces(statement, idx);
	
	start_idx = idx;
	
	if (!ReadSymbol(statement, idx, sym)) {
		strunpack(error, "Invalid symbol given", errlen);
		
		return false;
	}
	
	SkipSpaces(statement, idx);
	
	if (statement[idx] == '=' || statement[idx] == '[') {
		new info[E_VARIABLE];
		
		if (!GetVariableInfo(sym, info)) {
			format(error, errlen, "Invalid variable: %s", sym);
			
			return false;
		}
		
		if (statement[idx] == '[') {
			if (!ReadArrayIndexes(info, statement, idx)) {
				format(error, errlen, "Failed to read array subscripts");
				
				return false;
			}
			
			SkipSpaces(statement, idx);
		}
		
		if (statement[idx] != '=') {
			format(error, errlen, "Expected \"=\"");
			
			return false;
		}
		
		idx++;
		
		SkipSpaces(statement, idx);
		
		switch (statement[idx]) {
			case '"': {
				new buf[512];
				
				if (!ReadString(statement, idx, buf)) {
					strunpack(error, "Invalid string literal", errlen);
					
					return false;
				}
				
				new addr = info[Address];
				new len = info[DimensionSize][0];
				
				if (!len) {
					len = sizeof(buf);
				}{}
				
				#emit PUSH.S   len
				#emit PUSH.ADR buf
				#emit PUSH.S   addr
				#emit PUSH.C   12
				#emit SYSREQ.C strunpack
				#emit STACK    16
				
				return true;
			}
			
			case '-', '0' .. '9': {
				new type, value;
				
				if (!ReadNumber(statement, idx, value, type)) {
					strunpack(error, "Invalid number", errlen);
					
					return false;
				}
				
				new addr = info[Address];
				
				#emit LOAD.S.pri value
				#emit SREF.S.pri addr
				
				return true;
			}
			
			default: {
				strunpack(error, "Invalid value in assignment (expects string or number)", errlen);
				
				return false;
			}
		}
	} else if (statement[idx] == '(') {
		idx++;
		
		new addr = 0, info[E_FUNCTION];
		
		#if defined INTROSPECT_NATIVES
			new is_native = false;
			
			if (-1 != (addr = GetNativeIndexFromName(sym))) {
				is_native = true;
			}
		#endif
			
		if (addr == -1 && GetFunctionInfo(sym, info)) {
			addr = info[Address];
			
			if (info[DimensionSize] != 0) {
				format(error, errlen, "Functions that return arrays are not yet supported (%s)", sym);
			}
		}
		
		if (addr == -1) {
			format(error, errlen, "Invalid function: %s", sym);
			
			return false;
		}
		
		new
			arg[16],
			arg_ref[16],
			arg_type[16],
			args = 0,
			buf[2048],
			buf_idx = 0,
			buf_adr,
			is_ref = false;
		
		#emit ADDR.pri   buf
		#emit STOR.S.pri buf_adr
		
		while (statement[idx]) {
			SkipSpaces(statement, idx);
			
			if (statement[idx] == '&') {
				is_ref = true;
				idx++;
			} else {
				is_ref = false;
			}
			
			switch (statement[idx]) {
				case ')': {
					break;
				}
				
				case ',': {
					idx++;
					continue;
				}
				
				case '"': {
					if (!ReadString(statement, idx, buf[buf_idx], sizeof(buf) - buf_idx)) {
						strunpack(error, "Invalid string literal", errlen);
					
						return false;
					}
					
					arg_type[args] = 's';
					
					if (is_ref) {
						arg_ref[args] = buf_adr + buf_idx * 4;
						arg[args] = GetVariableAddress(arg_ref[args]);
					} else {
						arg[args] = buf_adr + buf_idx * 4;
					}
					
					args++;
					
					buf_idx += strlen(buf[buf_idx]) + 1;
				}
				
				case '-', '0' .. '9': {
					new type, value;
				
					if (!ReadNumber(statement, idx, value, type)) {
						strunpack(error, "Invalid number", errlen);
					
						return false;
					}
					
					arg_type[args] = 'i';
					
					if (is_ref) {
						arg_ref[args] = value;
						arg[args] = GetVariableAddress(arg_ref[args]);
					} else {
						arg[args] = value;
					}
					
					args++;
				}
			}
		}
		
		#if defined INTROSPECT_NATIVES
			if (is_native) {
				new arg_bytes = 4 + args * 4;
				
				while (--args >= 0) {
					#emit ADDR.pri arg
					#emit LOAD.S.alt args
					#emit SHL.C.alt 2
					#emit ADD
					#emit PUSH.pri
				}
				
				#emit PUSH.S addr
				#emit PUSH.S arg_bytes
		
				#emit LCTRL 6
				#emit ADD.C 28
				#emit PUSH.pri
				#emit CONST.pri CallNative
				#emit SCTRL 6
				
				return true;
			}
		#endif
		
		new value, arg_bytes = args * 4;
		new retval;
		
		while (--args >= 0) {
			value = arg[args];
			#emit PUSH.S value
		}
		
		#emit PUSH.S arg_bytes
		
		#emit LCTRL 6
		#emit ADD.C 28
		#emit PUSH.pri
		#emit LOAD.S.pri addr
		#emit SCTRL 6
		#emit STOR.S.pri retval
		
		output[0] = retval;
		
		if (!strcmp("Float", GetTagName(info[Tag]))) {
			output_type = 'f';
		} else {
			output_type = 'i';
		}
		
		return true;
	}
	
	strunpack(error, "Invalid simple statement", errlen);
	
	return false;
}
