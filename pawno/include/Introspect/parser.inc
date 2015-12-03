//#include "introspect"

#include <a_samp>
// Tokeniser.  Read text and convert it to tokens for simple processing.

#if !defined TODO
	#define TODO:%9\32;%0\10;%1 { new TODO; print("TODO: \"%0\""); }
#endif

#include "introspect"

#if defined INTROSPECT_LAMBDA
	#tryinclude "..\YSI_Coding\y_inline"
	#tryinclude "YSI_Coding\y_inline"
	#tryinclude "../YSI_Coding/y_inline"
	#tryinclude "YSI_Coding/y_inline"
	
	#if !defined YSI_MAX_INLINE_STRING
		#error YSI 4.0 is required.  Get it here: github.com/Y-Less/YSI-Includes/tree/YSI.tl
	#endif
#endif

enum e_TOKEN_OP
{
	e_TOKEN_OP_NONE,
	e_TOKEN_OP_ASSIGN,     // =
	e_TOKEN_OP_EQUALS,     // ==
	e_TOKEN_OP_LTE,        // <=
	e_TOKEN_OP_GTE,        // >=
	e_TOKEN_OP_LESS,       // <
	e_TOKEN_OP_GREATER,    // >
	e_TOKEN_OP_NOT,        // !
	e_TOKEN_OP_NEQ,        // !=
	e_TOKEN_OP_INV,        // ~
	e_TOKEN_OP_INV_ASS,    // ~=
	e_TOKEN_OP_ADD,        // +
	e_TOKEN_OP_ADD_ASS,    // +=
	e_TOKEN_OP_SUB,        // -   (INFIX)
	e_TOKEN_OP_NEG,        // -   (PREFIX)
	e_TOKEN_OP_SUB_ASS,    // -=
	e_TOKEN_OP_MUL,        // *
	e_TOKEN_OP_MUL_ASS,    // *=
	e_TOKEN_OP_DIV,        // /
	e_TOKEN_OP_DIV_ASS,    // /=
	e_TOKEN_OP_MOD,        // %
	e_TOKEN_OP_MOD_ASS,    // %=
	e_TOKEN_OP_XOR,        // ^
	e_TOKEN_OP_XOR_ASS,    // ^=
	e_TOKEN_OP_LAND,       // &   (INFIX)
	e_TOKEN_OP_REF,        // &   (PREFIX)
	e_TOKEN_OP_LAND_ASS,   // &=
	e_TOKEN_OP_LOR,        // |
	e_TOKEN_OP_LOR_ASS,    // |=
	e_TOKEN_OP_RSHIFT,     // >>
	e_TOKEN_OP_RSHIFT_ASS, // >>=
	e_TOKEN_OP_SHIFT,      // >>>
	e_TOKEN_OP_SHIFT_ASS,  // >>>=
	e_TOKEN_OP_LSHIFT,     // <<
	e_TOKEN_OP_LSHIFT_ASS, // <<=
	e_TOKEN_OP_AND,        // &&
	e_TOKEN_OP_OR,         // ||
	e_TOKEN_OP_OP_BRACKET, // (
	e_TOKEN_OP_CL_BRACKET, // )
	e_TOKEN_OP_OP_BRACE,   // {
	e_TOKEN_OP_CL_BRACE,   // }
	e_TOKEN_OP_OP_SQUARE,  // [
	e_TOKEN_OP_CL_SQUARE,  // ]
	e_TOKEN_OP_PRE_INC,    // ++  (PREFIX)
	e_TOKEN_OP_POST_INC,   // ++  (SUFFIX)
	e_TOKEN_OP_PRE_DEC,    // --  (PREFIX)
	e_TOKEN_OP_POST_DEC,   // --  (SUFFIX)
	e_TOKEN_OP_ELIPSIS,    // ...
	e_TOKEN_OP_CONCAT,     // ..
	e_TOKEN_OP_HASH,       // #
	e_TOKEN_OP_PAAMAYIM,   // ::
	e_TOKEN_OP_DQUOTE,     // "
	e_TOKEN_OP_QUOTE,      // '
	e_TOKEN_OP_SEMICOLON,  // ;
	e_TOKEN_OP_COMMA,      // ,
	e_TOKEN_OP_POINT,      // .
	e_TOKEN_OP_COLON,      // :
	e_TOKEN_OP_QUESTION,   // ?
}

enum e_TOKEN_TYPE
{
	e_TOKEN_TYPE_NONE,
	e_TOKEN_TYPE_STRING,
	e_TOKEN_TYPE_SYMBOL, // Unknown symbol type.
	// These two are distinct for simplicity.
	e_TOKEN_TYPE_NATIVE,
	e_TOKEN_TYPE_FUNC,
	e_TOKEN_TYPE_FFUNC,
	// This makes the code quite context-aware.
	e_TOKEN_TYPE_VAR,   // Regular variable.
	e_TOKEN_TYPE_FVAR,  // Float variable.
	e_TOKEN_TYPE_FLOAT,
	e_TOKEN_TYPE_BOOL,
	e_TOKEN_TYPE_INT,
	e_TOKEN_TYPE_APPLY,
	e_TOKEN_TYPE_INDEX,
	//e_TOKEN_TYPE_MD,   // This is used when we have a multi-dimensional array.
	e_TOKEN_TYPE_OP,
	// Special types for unresolved arrays.
	e_TOKEN_TYPE_ARRAY,
	e_TOKEN_TYPE_FARRAY,
}

#define TOKEN_TYPE_MASK  (e_TOKEN_TYPE:0x3F)
#define TOKEN_TYPE_SHIFT (e_TOKEN_TYPE:6)

enum E_TOKEN
{
	e_TOKEN_TYPE:E_TOKEN_TYPE,
	E_TOKEN_INT_VAL = 1,
	Float:E_TOKEN_FLOAT_VAL = 1,
	bool:E_TOKEN_BOOL_VAL = 1,
	e_TOKEN_OP:E_TOKEN_OP = 1,
	E_TOKEN_SYM_PTR = 1,
	E_TOKEN_STRING_IDX = 1,
	E_TOKEN_NATIVE_IDX = 1,
	E_TOKEN_FUNC_PTR = 1,
	E_TOKEN_LEFT,
	E_TOKEN_RIGHT,
	//_E_TOKEN_TEMP_STRING[32],
}

#define COMPARE_PARSER_TOKEN(%0,{%1,%2}) (((%0[E_TOKEN_TYPE]) == (%1)) && ((%0[E_TOKEN_INT_VAL]) == (%2)))
#define MAKE_PARSER_TOKEN(%0,%1,%2,%3) {%0, %1, Float:%2, bool:%3}
#define EMPTY_PARSER_TOKEN MAKE_PARSER_TOKEN(e_TOKEN_TYPE_NONE, 0, -1, -1)

#define MAKE_TOKEN(%0,%1,%2) %0[E_TOKEN_TYPE]=%1,%0[E_TOKEN_INT_VAL]=%2,%0[E_TOKEN_LEFT]=%0[E_TOKEN_RIGHT]=-1

enum E_OPERATOR_DATA
{
	E_OPERATOR_DATA_NAME[7],
	E_OPERATOR_DATA_PRECEDENCE, // -1 = unary only.
}

static stock const
	ISI_gscOpData[][E_OPERATOR_DATA] =
		{
			// 3 is a special precedence that makes "=" right-associative.
			{"<none>", 0}, // e_TOKEN_OP_NONE
			{"=", 4}, // e_TOKEN_OP_ASSIGN
			{"==", 12}, // e_TOKEN_OP_EQUALS
			{"<=", 14}, // e_TOKEN_OP_LTE
			{">=", 14}, // e_TOKEN_OP_GTE
			{"<", 14}, // e_TOKEN_OP_LESS
			{">", 14}, // e_TOKEN_OP_GREATER
			{"!", -1}, // e_TOKEN_OP_NOT
			{"!=", 12}, // e_TOKEN_OP_NEQ
			// There is no binary "~".
			{"~", -1}, // e_TOKEN_OP_INV
			{"~=", 4}, // e_TOKEN_OP_INV_ASS
			{"+", 22}, // e_TOKEN_OP_ADD
			{"+=", 4}, // e_TOKEN_OP_ADD_ASS
			// This is the precedence for the binary operator, the unary
			// operators all have the same precedence and are handled specially.
			{"-", 22}, // e_TOKEN_OP_SUB
			{"-", 22}, // e_TOKEN_OP_NEG
			{"-=", 4}, // e_TOKEN_OP_SUB_ASS
			{"*", 24}, // e_TOKEN_OP_MUL
			{"*=", 4}, // e_TOKEN_OP_MUL_ASS
			{"/", 24}, // e_TOKEN_OP_DIV
			{"/=", 4}, // e_TOKEN_OP_DIV_ASS
			{"%", 24}, // e_TOKEN_OP_MOD
			{"%=", 4}, // e_TOKEN_OP_MOD_ASS
			{"^", 17}, // e_TOKEN_OP_XOR
			{"^=", 4}, // e_TOKEN_OP_XOR_ASS
			{"&", 18}, // e_TOKEN_OP_LAND
			{"&", 18}, // e_TOKEN_OP_REF
			{"&=", 4}, // e_TOKEN_OP_LAND_ASS
			{"|", 16}, // e_TOKEN_OP_LOR
			{"|=", 4}, // e_TOKEN_OP_LOR_ASS
			{">>", 20}, // e_TOKEN_OP_RSHIFT
			{">>=", 4}, // e_TOKEN_OP_RSHIFT_ASS
			{">>>", 20}, // e_TOKEN_OP_SHIFT
			{">>>=", 4}, // e_TOKEN_OP_SHIFT_ASS
			{"<<", 20}, // e_TOKEN_OP_LSHIFT
			{"<<=", 4}, // e_TOKEN_OP_LSHIFT_ASS
			{"&&", 10}, // e_TOKEN_OP_AND
			{"||", 9}, // e_TOKEN_OP_OR
			{"(", 0}, // e_TOKEN_OP_OP_BRACKET
			{")", 0}, // e_TOKEN_OP_CL_BRACKET
			{"{", 0}, // e_TOKEN_OP_OP_BRACE
			{"}", 0}, // e_TOKEN_OP_CL_BRACE
			{"[", 0}, // e_TOKEN_OP_OP_SQUARE
			{"]", 0}, // e_TOKEN_OP_CL_SQUARE
			{"++", -1}, // e_TOKEN_OP_PRE_INC
			{"++", -1}, // e_TOKEN_OP_POST_INC
			{"--", -1}, // e_TOKEN_OP_PRE_DEC
			{"--", -1}, // e_TOKEN_OP_POST_DEC
			{"...", 8}, // e_TOKEN_OP_ELIPSIS
			{"..", 26}, // e_TOKEN_OP_CONCAT
			{"#", -1}, // e_TOKEN_OP_HASH
			{"::", 0}, // e_TOKEN_OP_PAAMAYIM
			{"\"", 0}, // e_TOKEN_OP_DQUOTE
			{"'", 0}, // e_TOKEN_OP_QUOTE
			{";", 2}, // e_TOKEN_OP_SEMICOLON
			{",", 2}, // e_TOKEN_OP_COMMA
			{".", 0}, // e_TOKEN_OP_POINT
			// Here "colon" binds slightly tighter than "question mark" so that
			// we don't need extra code to deal with ternary operators, instead
			// we just give "?" a condition and a (true, false) pair.  I might
			// have to change this in the future if I do JIT execution.
			{":", 7}, // e_TOKEN_OP_COLON
			{"?", 6} // e_TOKEN_OP_QUESTION
	};

static stock
	ISI_gFloatTagIndex = -1,
	ISI_gInputPtr,
	ISI_gParsePos,
	ISI_gsStringEnd;

stock
	ISI_gInputLine[512],
	ISI_gsStringTable[32] = {-1, ...},
	ISI_gParseTree[512][E_TOKEN];

#if defined INTROSPECT_PLAYER_DATA
	static stock
		ISI_gCurrentPlayer = -1,
		ISI_gPlayerInts[MAX_PLAYERS][12],  // a - l
		ISI_gPlayerStrM[MAX_PLAYERS][144], // m
		ISI_gPlayerStrN[MAX_PLAYERS][144], // n
		ISI_gPlayerFlts[MAX_PLAYERS][12];  // o - z
#endif

static stock
	ISI_gNoPlayerInts[12],  // a - l
	ISI_gNoPlayerStrM[144], // m
	ISI_gNoPlayerStrN[144], // n
	ISI_gNoPlayerFlts[12];  // o - z

stock Parser_SetPlayer(pid)
{
#if defined INTROSPECT_PLAYER_DATA
	if ((ISI_gCurrentPlayer = pid) == -1)
	{
		state Parser_Error_state : Parser_Error_print;
	}
	else
	{
		state Parser_Error_state : Parser_Error_player;
	}
#else
	#pragma unused pid
#endif
}

static stock Parser_GetLocalName(ptr)
{
#if defined INTROSPECT_PLAYER_DATA
	if (IsPlayerConnected(ISI_gCurrentPlayer))
	{
		new
			sInts = -1,
			sStrM,
			sStrN,
			sFlts;
		sInts = ref(ISI_gPlayerInts[ISI_gCurrentPlayer]),
		sStrM = ref(ISI_gPlayerStrM[ISI_gCurrentPlayer]),
		sStrN = ref(ISI_gPlayerStrN[ISI_gCurrentPlayer]),
		sFlts = ref(ISI_gPlayerFlts[ISI_gCurrentPlayer]);
		if (sInts <= ptr < sInts + 12 * 4)
		{
			return 'a' + (ptr - sInts) / 4;
		}
		else if (sStrM <= ptr < sStrM + 144 * 4)
		{
			return 'm';
		}
		else if (sStrN <= ptr < sStrN + 144 * 4)
		{
			return 'n';
		}
		else if (sFlts <= ptr < sFlts + 12 * 4)
		{
			return 'o' + (ptr - sFlts) / 4;
		}
	}
	else
#endif
	{
		static
			sInts = -1,
			sStrM,
			sStrN,
			sFlts;
		if (sInts == -1)
		{
			sInts = ref(ISI_gNoPlayerInts),
			sStrM = ref(ISI_gNoPlayerStrM),
			sStrN = ref(ISI_gNoPlayerStrN),
			sFlts = ref(ISI_gNoPlayerFlts);
		}
		if (sInts <= ptr < sInts + 12 * 4)
		{
			return 'a' + (ptr - sInts) / 4;
		}
		else if (sStrM <= ptr < sStrM + 144 * 4)
		{
			return 'm';
		}
		else if (sStrN <= ptr < sStrN + 144 * 4)
		{
			return 'n';
		}
		else if (sFlts <= ptr < sFlts + 12 * 4)
		{
			return 'o' + (ptr - sFlts) / 4;
		}
	}
	return '-';
}

forward _@_ParserFuncs();

public _@_ParserFuncs()
{
	printf("");
	format("", 0, "");
}

stock _Parser_Msg(const str[], ...) <Parser_Error_state : Parser_Error_player>
{
	static
		dest[144],
		sPar,
		sRet,
		sFrm;
	// Save the header.
	#emit LOAD.S.pri 0
	#emit STOR.pri   sFrm
	#emit LOAD.S.pri 4
	#emit STOR.pri   sRet
	#emit LOAD.S.pri 8
	#emit STOR.pri   sPar
	// Push the size.
	#emit CONST.alt  144
	#emit STOR.S.alt 8
	// Push the destination.
	#emit CONST.alt  dest
	#emit STOR.S.alt 4
	// Update the parameter count.
	#emit ADD.C      8
	#emit STOR.S.pri 0
	// Call the function.
	#emit SYSREQ.C   format
	// Restore the header.
	#emit LOAD.pri   sFrm
	#emit STOR.S.pri 0
	#emit LOAD.pri   sRet
	#emit STOR.S.pri 4
	#emit LOAD.pri   sPar
	#emit STOR.S.pri 8
	return SendClientMessage(ISI_gCurrentPlayer, (str[7] == 'E') ? 0xCD2626FF : 0xFFD700FF, dest);
}

stock _Parser_Msg(const str[], {Float,_}:...) <Parser_Error_state : Parser_Error_print>
{
	#pragma unused str
	#emit STACK        8
	#emit SYSREQ.C     printf
	#emit STACK        0xFFFFFFF8
	#emit RETN
	return 0;
}

#if defined INTROSPECT_PLAYER_DATA
	#define Parser_Error(%0) _Parser_Msg("PARSER ERROR  : " %0)
	#define Parser_Warning(%0) _Parser_Msg("PARSER WARNING: " %0)
#else
	#define Parser_Error(%0) printf("PARSER ERROR  : " %0)
	#define Parser_Warning(%0) printf("PARSER WARNING: " %0)
#endif

/******************************************************************************\
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
|****                                                                      ****|
|****                           HELPER FUNCTIONS                           ****|
|****                                                                      ****|
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
\******************************************************************************/

/******************************************************************************\
	Parser_PrintOp

	Print an operator (or rather return it) given an identifier.

\******************************************************************************/
static stock Parser_PrintOp(e_TOKEN_OP:op)
{
	new
		none[7];
	if (e_TOKEN_OP_NONE <= op < e_TOKEN_OP)
	{
		strcat(none, ISI_gscOpData[op][E_OPERATOR_DATA_NAME], 7);
	}
	else
	{
		none = "<none>";
	}
	return none;
}

static stock Parser_Print(token[E_TOKEN], ret[], len = sizeof (ret))
{
	switch (token[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
	{
		case e_TOKEN_TYPE_NONE:   ret[0] = '\0';
		case e_TOKEN_TYPE_STRING: format(ret, len, "STRING:   %s", ISI_gInputLine[ISI_gsStringTable[token[E_TOKEN_STRING_IDX]]]);
		case e_TOKEN_TYPE_NATIVE:
		{
			new name[32];
			GetNativeNameFromIndex(token[E_TOKEN_NATIVE_IDX], name);
			format(ret, len, "NATIVE:   %s", name);
		}
		case e_TOKEN_TYPE_SYMBOL:
			format(ret, len, "SYMBOL: %s", ISI_gInputLine[ISI_gsStringTable[token[E_TOKEN_STRING_IDX]]]);
		case e_TOKEN_TYPE_FUNC, e_TOKEN_TYPE_FFUNC:
			format(ret, len, "FUNCTION: %s", GetFunctionFromAddress(token[E_TOKEN_FUNC_PTR]));
		case e_TOKEN_TYPE_VAR, e_TOKEN_TYPE_FVAR, e_TOKEN_TYPE_ARRAY, e_TOKEN_TYPE_FARRAY:
		{
			new
				ch = Parser_GetLocalName(token[E_TOKEN_SYM_PTR]);
			if (ch == '-') format(ret, len, "VARIABLE: %s", GetVariableFromAddress(token[E_TOKEN_SYM_PTR]));
			else format(ret, len, "LOCAL: %c", ch);
		}
		case e_TOKEN_TYPE_FLOAT:  format(ret, len, "FLOAT:    %.2f", token[E_TOKEN_FLOAT_VAL]);
		case e_TOKEN_TYPE_INT:    format(ret, len, "NUMBER:   %d", token[E_TOKEN_INT_VAL]);
		case e_TOKEN_TYPE_BOOL:   format(ret, len, "BOOLEAN:  %s", (token[E_TOKEN_BOOL_VAL]) ? ("true") : ("false"));
		case e_TOKEN_TYPE_OP:     format(ret, len, "OPERATOR: %s", Parser_PrintOp(token[E_TOKEN_OP]));
		case e_TOKEN_TYPE_APPLY: ret[0] = '\0', strcat(ret, "APPLY", len);
		case e_TOKEN_TYPE_INDEX: ret[0] = '\0', strcat(ret, "INDEX", len);
		default: ret[0] = '\0', strcat(ret, "<unknown>", len);
	}
}

static stock PrettyPrint(token[E_TOKEN])
{
	new str[32];
	Parser_Print(token, str);
	print(str);
}

static stock Parser_PeekChar()
{
	return ISI_gInputLine[ISI_gInputPtr];
}

static stock Parser_PeekToken()
{
	// Find out what the next token is, then backtrack to the start of it.
	new
		ret[E_TOKEN] = EMPTY_PARSER_TOKEN,
		ptr = ISI_gInputPtr;
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_NONE,
	Parser_SkipWhitespace();
	// We don't actually NEED the next token most of the time, just the type,
	// which can be determined from the first character.  This solves a tiny and
	// (possibly) rare issue when strings from "peek" would overwrite the true
	// input.
	switch (Parser_PeekChar())
	{
		case '\0': {}
		case '0' .. '9': ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT;
		case 'a' .. 'z', 'A' .. 'Z', '_', '@': ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_SYMBOL;
		case '"': ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_STRING;
		case '\'': ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT;//'
		default: Parser_GetOp(ret);
	}
	return
		ISI_gInputPtr = ptr,
		ret;
}

#define Parser_IsWhitespace((%0)) ('\0' <= (%0) <= ' ')

static stock Parser_SkipWhitespace()
{
	while ('\0' < ISI_gInputLine[ISI_gInputPtr] <= ' ') ++ISI_gInputPtr;
}

/******************************************************************************\
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
|****                                                                      ****|
|****                              TOKENISER                               ****|
|****                                                                      ****|
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
\******************************************************************************/

#define PARSER_DO_OP_1(%9,%0)          else if (p0 == %0) ret[E_TOKEN_OP] = (%9), len = 1;
#define PARSER_DO_OP_2(%9,%0,%1)       else if (p0 == %0 && p1 == %1) ret[E_TOKEN_OP] = (%9), len = 2;
#define PARSER_DO_OP_3(%9,%0,%1,%2)    else if (p0 == %0 && p1 == %1 && p2 == %2) ret[E_TOKEN_OP] = (%9), len = 3;
#define PARSER_DO_OP_4(%9,%0,%1,%2,%3) else if (p0 == %0 && p1 == %1 && p2 == %2 && p3 == %3) ret[E_TOKEN_OP] = (%9), len = 4;

static stock Parser_GetOp(ret[E_TOKEN])
{
	// Should really use a "trie" here, but don't - too complex for now.
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_OP;
	new
		len,
		p0, p1, p2, p3;
	// Very special if - uses short-circuiting to always fail eventually...
	if ((p0 = ISI_gInputLine[ISI_gInputPtr + 0]) &&
		(p1 = ISI_gInputLine[ISI_gInputPtr + 1]) &&
		(p2 = ISI_gInputLine[ISI_gInputPtr + 2]) &&
		(p3 = ISI_gInputLine[ISI_gInputPtr + 3]) && len) {}
	PARSER_DO_OP_4(e_TOKEN_OP_SHIFT_ASS, '>', '>', '>', '=')
	PARSER_DO_OP_3(e_TOKEN_OP_RSHIFT_ASS, '>', '>', '=')
	PARSER_DO_OP_3(e_TOKEN_OP_SHIFT, '>', '>', '>')
	PARSER_DO_OP_3(e_TOKEN_OP_LSHIFT_ASS, '<', '<', '=')
	PARSER_DO_OP_3(e_TOKEN_OP_ELIPSIS, '.', '.', '.')
	PARSER_DO_OP_2(e_TOKEN_OP_EQUALS, '=', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_LTE, '<', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_GTE, '>', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_NEQ, '!', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_INV_ASS, '~', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_ADD_ASS, '+', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_SUB_ASS, '-', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_MUL_ASS, '*', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_DIV_ASS, '/', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_MOD_ASS, '%', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_XOR_ASS, '^', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_LAND_ASS, '&', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_LOR_ASS, '|', '=')
	PARSER_DO_OP_2(e_TOKEN_OP_RSHIFT, '>', '>')
	PARSER_DO_OP_2(e_TOKEN_OP_LSHIFT, '<', '<')
	PARSER_DO_OP_2(e_TOKEN_OP_AND, '&', '&')
	PARSER_DO_OP_2(e_TOKEN_OP_OR, '|', '|')
	PARSER_DO_OP_2(e_TOKEN_OP_PAAMAYIM, ':', ':')
	PARSER_DO_OP_2(e_TOKEN_OP_PRE_INC, '+', '+')
	PARSER_DO_OP_2(e_TOKEN_OP_PRE_DEC, '-', '-')
	PARSER_DO_OP_2(e_TOKEN_OP_CONCAT, '.', '.')
	PARSER_DO_OP_1(e_TOKEN_OP_ASSIGN, '=')
	PARSER_DO_OP_1(e_TOKEN_OP_LESS, '<')
	PARSER_DO_OP_1(e_TOKEN_OP_GREATER, '>')
	PARSER_DO_OP_1(e_TOKEN_OP_NOT, '!')
	PARSER_DO_OP_1(e_TOKEN_OP_INV, '~')
	PARSER_DO_OP_1(e_TOKEN_OP_ADD, '+')
	PARSER_DO_OP_1(e_TOKEN_OP_SUB, '-')
	PARSER_DO_OP_1(e_TOKEN_OP_MUL, '*')
	PARSER_DO_OP_1(e_TOKEN_OP_DIV, '/')
	PARSER_DO_OP_1(e_TOKEN_OP_MOD, '%')
	PARSER_DO_OP_1(e_TOKEN_OP_XOR, '^')
	PARSER_DO_OP_1(e_TOKEN_OP_LAND, '&')
	PARSER_DO_OP_1(e_TOKEN_OP_LOR, '|')
	PARSER_DO_OP_1(e_TOKEN_OP_OP_BRACKET, '(')
	PARSER_DO_OP_1(e_TOKEN_OP_CL_BRACKET, ')')
	PARSER_DO_OP_1(e_TOKEN_OP_OP_BRACE, '{')
	PARSER_DO_OP_1(e_TOKEN_OP_CL_BRACE, '}')
	PARSER_DO_OP_1(e_TOKEN_OP_OP_SQUARE, '[')
	PARSER_DO_OP_1(e_TOKEN_OP_CL_SQUARE, ']')
	PARSER_DO_OP_1(e_TOKEN_OP_HASH, '#')
	PARSER_DO_OP_1(e_TOKEN_OP_DQUOTE, '"')
	PARSER_DO_OP_1(e_TOKEN_OP_QUOTE, '\'')//'
	PARSER_DO_OP_1(e_TOKEN_OP_COMMA, ',')
	PARSER_DO_OP_1(e_TOKEN_OP_POINT, '.')
	PARSER_DO_OP_1(e_TOKEN_OP_QUESTION, '?')
	PARSER_DO_OP_1(e_TOKEN_OP_COLON, ':')
	PARSER_DO_OP_1(e_TOKEN_OP_SEMICOLON, ';')
	if (len)
	{
		// Found an op.
		ISI_gInputPtr += len;
	}
	else
	{
		Parser_Error("Unexpected input at (%d).", ISI_gInputPtr);
		// Skip one character and try again.
		++ISI_gInputPtr;
	}
	return ret;
}

#undef PARSER_DO_OP_1
#undef PARSER_DO_OP_2
#undef PARSER_DO_OP_3
#undef PARSER_DO_OP_4

static stock Parser_GetNextToken(ret[E_TOKEN])
{
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_NONE,
	Parser_SkipWhitespace();
	switch (Parser_PeekChar())
	{
		case '\0': return 0;
		case '0' .. '9': Parser_GetNumber(ret);
		case 'a' .. 'z', 'A' .. 'Z', '_', '@':
		{
			Parser_GetSymbol(ret);
		}
		case '"': Parser_GetString(ret);
		case '\'': Parser_GetChar(ret);//'
		default: Parser_GetOp(ret);
	}
	return 1;
}

static stock Parser_GetHex(ch)
{
	switch (ch)
	{
		case '0' .. '9': return ch - '0';
		case 'a' .. 'f': return ch - 'a' + 10;
		case 'A' .. 'F': return ch - 'A' + 10;
	}
	return -1;
}

/******************************************************************************\
	Parser_DoHex

	Given an input string we KNOW starts with a hex number, return that number.

\******************************************************************************/
static stock Parser_DoHex(ret[E_TOKEN])
{
	new
		ptr = ISI_gInputPtr + 2,
		cur,
		num = Parser_GetHex(ISI_gInputLine[ptr]);
	if (num == -1) Parser_Error("Invalid HEX number.");
	while ((cur = Parser_GetHex(ISI_gInputLine[++ptr])) != -1)
	{
		num = (num << 4) | cur;
	}
	return
		ret[E_TOKEN_INT_VAL] = num,
		ISI_gInputPtr = ptr,
		1;
}

static stock Parser_DoDecimal(ret[E_TOKEN])
{
	new
		ptr = ISI_gInputPtr,
		cur,
		num = ISI_gInputLine[ptr] - '0';
	if (0 <= num <= 9)
	{
		while (0 <= (cur = ISI_gInputLine[++ptr] - '0') <= 9)
		{
			num = num * 10 + cur;
		}
		return
			ret[E_TOKEN_INT_VAL] = num,
			ISI_gInputPtr = ptr,
			1;
	}
	else return Parser_Error("Invalid HEX number.");
}

static stock Parser_GetBinary(ch)
{
	switch (ch)
	{
		case '0': return 0;
		case '1': return 1;
	}
	return -1;
}

static stock Parser_DoBinary(ret[E_TOKEN])
{
	new
		ptr = ISI_gInputPtr + 2,
		cur,
		num = Parser_GetBinary(ISI_gInputLine[ptr]);
	if (num == -1) Parser_Error("Invalid Binary number.");
	while ((cur = Parser_GetBinary(ISI_gInputLine[++ptr])) != -1)
	{
		num = (num << 1) | cur;
	}
	return
		ret[E_TOKEN_INT_VAL] = num,
		ISI_gInputPtr = ptr,
		1;
}

static stock Parser_GetOctal(ch)
{
	switch (ch)
	{
		case '0' .. '7': return ch - '0';
	}
	return -1;
}

static stock Parser_DoOctal(ret[E_TOKEN])
{
	new
		ptr = ISI_gInputPtr + 1,
		cur,
		num = Parser_GetOctal(ISI_gInputLine[ptr]);
	if (num == -1) Parser_Error("Invalid Octal number.");
	while ((cur = Parser_GetOctal(ISI_gInputLine[++ptr])) != -1)
	{
		num = (num << 3) | cur;
	}
	return
		ret[E_TOKEN_INT_VAL] = num,
		ISI_gInputPtr = ptr,
		1;
}

/******************************************************************************\
	Parser_Pow10

	Very quickly raise some number by a given exponent (i.e. n *= 10^e).

\******************************************************************************/
static stock Float:Parser_Pow10(Float:n, e)
{
	static const
		Float:scPow[] = {1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0};
	while (e > 0)
	{
		n *= scPow[e % sizeof (scPow)],
		e -= sizeof (scPow);
	}
	return n;
}

static stock Parser_DoFloat(ret[E_TOKEN])
{
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT;
	new
		part = 0,
		ndp = 0,
		dp = 0,
		parts[3],
		ptr = ISI_gInputPtr - 1,
		ch;
	for ( ; ; )
	{
		switch ((ch = ISI_gInputLine[++ptr]))
		{
			case '0' .. '9': parts[part] = parts[part] * 10 + (ch - '0'), ++dp;
			case '.':
			{
				if (part == 0) part = 1, dp = 0;
				else break;
			}
			case 'e', 'E':
			{
				if (part == 2) break;
				else part = 2, ndp = dp;
			}
			default: break;
		}
	}
	if (ndp) dp = ndp;
	// At this point we have 3 integers - the whole part, the fractional part,
	// and the exponent:
	//
	//  4.6e6 == 4600000 == 4, 6, 6
	//
	return
		ret[E_TOKEN_FLOAT_VAL] = Parser_Pow10(float(parts[0]) + float(parts[1]) / Parser_Pow10(1.0, dp), parts[2]),
		ISI_gInputPtr = ptr,
		1;
}

/******************************************************************************\
	Parser_GetNumber

	Parse an unknown number, this could be: hex, octal, binary, decimal, or a
	float (including exponents).  Loop through assuming its decimal, and if we
	find concrete evidence to the contrary then reparse it as that type instead.

\******************************************************************************/
static stock Parser_GetNumber(ret[E_TOKEN])
{
	new
		num = 0,
		ch,
		ptr = ISI_gInputPtr;
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT;
	if (ISI_gInputLine[ptr] == '0')
	{
		// Hex, binary, or octal (or 0).
		switch ((ch = ISI_gInputLine[++ptr]))
		{
			case 'x', 'X': return Parser_DoHex(ret); // Hex
			case 'b', 'B': return Parser_DoBinary(ret); // Binary
			case 'e', 'E', '.': return Parser_DoFloat(ret); // Float
			case '0' .. '9':
			{
				new
					bool:oct = ('0' <= ch <= '7');
				num = ch - '0';
				for ( ; ; )
				{
					switch ((ch = ISI_gInputLine[++ptr]))
					{
						case '0' .. '7': num = num * 10 + (ch - '0'), oct &= true;
						case 'e', 'E', '.': return Parser_DoFloat(ret); // Float
						case '8', '9': num = num * 10 + (ch - '0'), oct = false;
						default: break;
					}
				}
				if (oct) return Parser_DoOctal(ret);
			}
		}
	}
	else
	{
		// Decimal or float.
		// Lookahead.
		num = ISI_gInputLine[ptr] - '0';
		for ( ; ; )
		{
			switch ((ch = ISI_gInputLine[++ptr]))
			{
				case '0' .. '9': num = num * 10 + (ch - '0');
				case 'e', 'E', '.': return Parser_DoFloat(ret);
				default: break;
			}
		}
	}
	return
		ret[E_TOKEN_INT_VAL] = num,
		// Decimal (default).
		ISI_gInputPtr = ptr,
		1;
}

static stock Parser_GetString(ret[E_TOKEN])
{
	new
		stringSlot;
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_STRING,
	++ISI_gInputPtr;
	if ((stringSlot = Parser_ReserveString()) == -1) return Parser_Error("String table full.");
	while (ISI_gInputLine[ISI_gInputPtr] != '\"')
	{
		// Copy the string to (possibly) earlier in the input string.
		if (ISI_gInputLine[ISI_gInputPtr]) ISI_gInputLine[ISI_gsStringEnd++] = Parser_DoChar();
		else return Parser_Error("Unclosed string literal.");
	}
	return
		ISI_gInputLine[ISI_gsStringEnd++] = '\0',
		ret[E_TOKEN_STRING_IDX] = stringSlot,
		// Decimal (default).
		++ISI_gInputPtr,
		1;
}

static stock Parser_IsSymbolCharacter(ch)
{
	return ('0' <= ch <= '9') || ('a' <= ch <= 'z') || ('A' <= ch <= 'Z') || ch == '_' || ch == '@';
}

static stock Parser_GetSymbol(ret[E_TOKEN])
{
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_NONE;
	// Find the end of the symbol (already have the first character).
	new
		ptr = ISI_gInputPtr + 1;
	while (Parser_IsSymbolCharacter(ISI_gInputLine[ptr])) ++ptr;
	// Store the next character so we can blank it and get the symbol.
	new
		tmp = ISI_gInputLine[ptr]; // So we can restore the value later.
	ISI_gInputLine[ptr] = '\0';
	// Booleans.
	if (!strcmp(ISI_gInputLine[ISI_gInputPtr], "false"))
		ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
		ret[E_TOKEN_BOOL_VAL] = false;
	else if (!strcmp(ISI_gInputLine[ISI_gInputPtr], "true"))
		ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
		ret[E_TOKEN_BOOL_VAL] = true;
	else
	{
		if (ISI_gFloatTagIndex == -1)
		{
			ISI_gFloatTagIndex = GetTagIdx("Float");
		}
		if (ptr - ISI_gInputPtr == 1)
		{
#if defined INTROSPECT_PLAYER_DATA
			if (IsPlayerConnected(ISI_gCurrentPlayer))
			{
				new
					ch = ISI_gInputLine[ISI_gInputPtr];
				if ('a' <= ch <= 'l')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_VAR,
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gPlayerInts[ISI_gCurrentPlayer][ch - 'a']);
					goto Parser_GetSymbol_return;
				}
				else if (ch == 'm')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:1 << TOKEN_TYPE_SHIFT),
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gPlayerStrM[ISI_gCurrentPlayer][0]);
					goto Parser_GetSymbol_return;
				}
				else if (ch == 'n')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:1 << TOKEN_TYPE_SHIFT),
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gPlayerStrN[ISI_gCurrentPlayer][0]);
					goto Parser_GetSymbol_return;
				}
				else if ('o' <= ch <= 'z')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FVAR,
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gPlayerFlts[ISI_gCurrentPlayer][ch - 'o']);
					goto Parser_GetSymbol_return;
				}
				else if (ch == '@')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = ISI_gCurrentPlayer;
					goto Parser_GetSymbol_return;
				}
			}
			else
#endif
			{
				// No player, use default locals.
				new
					ch = ISI_gInputLine[ISI_gInputPtr];
				if ('a' <= ch <= 'l')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_VAR,
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gNoPlayerInts[ch - 'a']);
					goto Parser_GetSymbol_return;
				}
				else if (ch == 'm')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:1 << TOKEN_TYPE_SHIFT),
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gNoPlayerStrM[0]);
					goto Parser_GetSymbol_return;
				}
				else if (ch == 'n')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:1 << TOKEN_TYPE_SHIFT),
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gNoPlayerStrN[0]);
					goto Parser_GetSymbol_return;
				}
				else if ('o' <= ch <= 'z')
				{
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FVAR,
					ret[E_TOKEN_SYM_PTR] = ref(ISI_gNoPlayerFlts[ch - 'o']);
					goto Parser_GetSymbol_return;
				}
				// '@' is undefined for no players.
			}
		}

		{
			// See if this symbol is an array/variable.
			new
				info[E_VARIABLE];
			if (GetVariableInfo(ISI_gInputLine[ISI_gInputPtr], info))
			{
				// Preserve the tag.
				// Preserve the dimension information.
				if (info[Tag] == ISI_gFloatTagIndex) // switch (info[Dimensions])
				{
					if (info[Dimensions]) ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FARRAY | (e_TOKEN_TYPE:info[Dimensions] << TOKEN_TYPE_SHIFT);
					else ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FVAR;
				}
				else
				{
					if (info[Dimensions]) ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:info[Dimensions] << TOKEN_TYPE_SHIFT);
					else ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_VAR;
				}
				// Convert to a pointer.
				ret[E_TOKEN_SYM_PTR] = info[Address];
				goto Parser_GetSymbol_return;
			}
		}
		{
			// See if this symbol is a normal function.
			new
				info[E_FUNCTION];
			if (GetFunctionInfo(ISI_gInputLine[ISI_gInputPtr], info))
			{
				if (info[Tag] == ISI_gFloatTagIndex) ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FFUNC;
				else ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FUNC;
				ret[E_TOKEN_FUNC_PTR] = info[Address];
				goto Parser_GetSymbol_return;
			}
		}
#if defined INTROSPECT_NATIVES
		{
			// See if this symbol is a native function.
			new
				info = GetNativeIndexFromName(ISI_gInputLine[ISI_gInputPtr]);
			if (info != -1)
			{
				ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_NATIVE,
				ret[E_TOKEN_NATIVE_IDX] = info;
				goto Parser_GetSymbol_return;
			}
		}
#endif
		// Unknown symbol.
		ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_SYMBOL,
		ret[E_TOKEN_STRING_IDX] = Parser_AddString(ISI_gInputPtr);
		Parser_Error("Unknown symbol: %s", ISI_gInputLine[ISI_gsStringTable[ret[E_TOKEN_STRING_IDX]]]);
	}
Parser_GetSymbol_return:
	return
		ISI_gInputLine[ptr] = tmp,
		ISI_gInputPtr = ptr,
		1;
}

/******************************************************************************\
	Parser_GetChar

	Gets a number by decoding a single character enclosed in ''s.  This includes
	various escape sequences, decimals, and hex numbers.

\******************************************************************************/
static stock Parser_DoChar()
{
	//ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT;
	new
		ch,
		ret[E_TOKEN];
	switch ((ch = ISI_gInputLine[ISI_gInputPtr++]))
	{
		case '\\':
		{
			switch (ISI_gInputLine[ISI_gInputPtr++])
			{
				case '\0': return Parser_Error("Invalid escape sequence.");
				case 'n':  return '\n';
				case '\\': return '\\';
				case '\'': return '\'';
				case 't':  return '\t';
				case '"':  return '\"';
				case 'a':  return '\a';
				case 'b':  return '\b';
				case 'v':  return '\v';
				case 'r':  return '\r';
				case '0' .. '9':
				{
					--ISI_gInputPtr,
					Parser_DoDecimal(ret);
					if (ISI_gInputLine[ISI_gInputPtr] == ';') ++ISI_gInputPtr;
				}
				case 'x', 'X':
				{
					ISI_gInputPtr -= 2,
					Parser_DoHex(ret);
					if (ISI_gInputLine[ISI_gInputPtr] == ';') ++ISI_gInputPtr;
				}
			}
		}
		default: return ch;
	}
	return ret[E_TOKEN_INT_VAL];
}

static stock Parser_GetChar(ret[E_TOKEN])
{
	++ISI_gInputPtr,
	ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
	ret[E_TOKEN_INT_VAL] = Parser_DoChar();
	if (ISI_gInputLine[ISI_gInputPtr] != '\'') return Parser_Error("Unclosed character literal.");//'
	return
		++ISI_gInputPtr,
		1;
}

/******************************************************************************\
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
|****                                                                      ****|
|****                                PARSER                                ****|
|****                                                                      ****|
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
\******************************************************************************/

static stock Parser_GetLeft(prec)
{
	new
		token[E_TOKEN] = EMPTY_PARSER_TOKEN,
		pos = ISI_gParsePos;
	if (pos >= sizeof (ISI_gParseTree)) return Parser_Error("Parse Tree full.");
	Parser_GetNextToken(token);
	switch (token[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
	{
		case e_TOKEN_TYPE_OP:
		{
			switch (token[E_TOKEN_OP])
			{
				case e_TOKEN_OP_OP_BRACKET:
				{
					new
						t2[E_TOKEN];
					t2 = Parser_PeekToken();
					if (t2[E_TOKEN_TYPE] == e_TOKEN_TYPE_OP && t2[E_TOKEN_OP] == e_TOKEN_OP_CL_BRACKET)
					{
						return
							Parser_GetNextToken(t2),
							0;
					}
					// Start of a new bracketed set.
					pos = Parser_BuildTree(0);
					Parser_GetNextToken(token);
					if (token[E_TOKEN_TYPE] != e_TOKEN_TYPE_OP || token[E_TOKEN_OP] != e_TOKEN_OP_CL_BRACKET)
					{
						new
							pp[32];
						Parser_Print(token, pp);
						return Parser_Error("Expected token \")\", but found: %s", pp);
					}
				}
				case e_TOKEN_OP_OP_BRACE:
				{
					// Start of a new bracketed set.
					pos = Parser_BuildTree(0);
					Parser_GetNextToken(token);
					if (token[E_TOKEN_TYPE] != e_TOKEN_TYPE_OP || token[E_TOKEN_OP] != e_TOKEN_OP_CL_BRACE)
					{
						new
							pp[32];
						Parser_Print(token, pp);
						return Parser_Error("Expected token \")\", but found: %s", pp);
					}
				}
				case e_TOKEN_OP_OP_SQUARE:
				{
					// Start of a new bracketed set.
					pos = Parser_BuildTree(0);
					Parser_GetNextToken(token);
					if (token[E_TOKEN_TYPE] != e_TOKEN_TYPE_OP || token[E_TOKEN_OP] != e_TOKEN_OP_CL_SQUARE)
					{
						new
							pp[32];
						Parser_Print(token, pp);
						return Parser_Error("Expected token \")\", but found: %s", pp);
					}
				}
				case e_TOKEN_OP_SUB: // Prefix, not infix, "-".
				{
					++ISI_gParsePos,
					token[E_TOKEN_OP] = e_TOKEN_OP_NEG,
					token[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
					ISI_gParseTree[pos] = token;
				}
				case e_TOKEN_OP_LAND: // Prefix, not infix, "&".
				{
					++ISI_gParsePos,
					token[E_TOKEN_OP] = e_TOKEN_OP_REF,
					token[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
					ISI_gParseTree[pos] = token;
				}
				case e_TOKEN_OP_NOT,
				     e_TOKEN_OP_INV,
				     e_TOKEN_OP_ADD,
				     e_TOKEN_OP_PRE_INC,
				     e_TOKEN_OP_PRE_DEC,
				     e_TOKEN_OP_HASH:
				{
					++ISI_gParsePos,
					token[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
					ISI_gParseTree[pos] = token;
				}
				default: return Parser_Error("Expected value, found %s", Parser_PrintOp(token[E_TOKEN_OP]));
			}
		}
		case e_TOKEN_TYPE_ARRAY, e_TOKEN_TYPE_FARRAY:
		{
			// Check for postfix operators.
			new
				t2[E_TOKEN];
			ISI_gParseTree[ISI_gParsePos++] = token;
			for ( ; ; )
			{
				t2 = Parser_PeekToken();
				if (t2[E_TOKEN_TYPE] == e_TOKEN_TYPE_OP)
				{
					switch (t2[E_TOKEN_OP])
					{
						case e_TOKEN_OP_PRE_INC:
						{
							return
								t2[E_TOKEN_OP] = e_TOKEN_OP_POST_INC,
								t2[E_TOKEN_LEFT] = pos,
								t2[E_TOKEN_RIGHT] = -1,
								ISI_gParseTree[(pos = ISI_gParsePos++)] = t2,
								Parser_GetNextToken(t2),
								pos;
						}
						case e_TOKEN_OP_PRE_DEC:
						{
							return
								t2[E_TOKEN_OP] = e_TOKEN_OP_POST_DEC,
								t2[E_TOKEN_LEFT] = pos,
								t2[E_TOKEN_RIGHT] = -1,
								ISI_gParseTree[(pos = ISI_gParsePos++)] = t2,
								Parser_GetNextToken(t2),
								pos;
						}
						case e_TOKEN_OP_OP_BRACKET: return Parser_Error("Not a function.");
						case e_TOKEN_OP_OP_SQUARE:
						{
							t2[E_TOKEN_TYPE] = e_TOKEN_TYPE_INDEX,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2;
						}
						default: return pos;
					}
				}
				else return pos;
			}
		}
		case e_TOKEN_TYPE_NATIVE, e_TOKEN_TYPE_FUNC, e_TOKEN_TYPE_FFUNC:
		{
			// Check for postfix operators.
			new
				bool:once = false,
				t2[E_TOKEN];
			ISI_gParseTree[ISI_gParsePos++] = token;
			for ( ; ; )
			{
				t2 = Parser_PeekToken();
				if (t2[E_TOKEN_TYPE] == e_TOKEN_TYPE_OP)
				{
					switch (t2[E_TOKEN_OP])
					{
						case e_TOKEN_OP_PRE_INC: return Parser_Error("Cannot increment functions.");
						case e_TOKEN_OP_PRE_DEC: return Parser_Error("Cannot decrement functions.");
						case e_TOKEN_OP_OP_BRACKET:
						{
							if (once) return Parser_Error("Invalid syntax.");
							once = true,
							t2[E_TOKEN_TYPE] = e_TOKEN_TYPE_APPLY,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2;
						}
						case e_TOKEN_OP_OP_SQUARE:
						{
							t2[E_TOKEN_TYPE] = e_TOKEN_TYPE_INDEX,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2;
						}
						default: return pos;
					}
				}
				else return pos;
			}
		}
		case e_TOKEN_TYPE_VAR, e_TOKEN_TYPE_FVAR:
		{
			// Check for postfix operators.
			new
				t2[E_TOKEN];
			ISI_gParseTree[ISI_gParsePos++] = token;
			t2 = Parser_PeekToken();
			if (t2[E_TOKEN_TYPE] == e_TOKEN_TYPE_OP)
			{
				switch (t2[E_TOKEN_OP])
				{
					case e_TOKEN_OP_PRE_INC:
					{
						return
							t2[E_TOKEN_OP] = e_TOKEN_OP_POST_INC,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = -1,
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2,
							Parser_GetNextToken(t2),
							pos;
					}
					case e_TOKEN_OP_PRE_DEC:
					{
						return
							t2[E_TOKEN_OP] = e_TOKEN_OP_POST_DEC,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = -1,
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2,
							Parser_GetNextToken(t2),
							pos;
					}
					case e_TOKEN_OP_OP_BRACKET: return Parser_Error("Not a function.");
					case e_TOKEN_OP_OP_SQUARE: return Parser_Error("Not an array.");
					default: return pos;
				}
			}
			return pos;
		}
		case e_TOKEN_TYPE_SYMBOL:
		{
			// Check for postfix operators.
			new
				bool:once = false,
				t2[E_TOKEN];
			ISI_gParseTree[ISI_gParsePos++] = token;
			for ( ; ; )
			{
				t2 = Parser_PeekToken();
				if (t2[E_TOKEN_TYPE] == e_TOKEN_TYPE_OP)
				{
					switch (t2[E_TOKEN_OP])
					{
						case e_TOKEN_OP_PRE_INC:
						{
							return
								t2[E_TOKEN_OP] = e_TOKEN_OP_POST_INC,
								t2[E_TOKEN_LEFT] = pos,
								t2[E_TOKEN_RIGHT] = -1,
								ISI_gParseTree[(pos = ISI_gParsePos++)] = t2,
								Parser_GetNextToken(t2),
								pos;
						}
						case e_TOKEN_OP_PRE_DEC:
						{
							return
								t2[E_TOKEN_OP] = e_TOKEN_OP_POST_DEC,
								t2[E_TOKEN_LEFT] = pos,
								t2[E_TOKEN_RIGHT] = -1,
								ISI_gParseTree[(pos = ISI_gParsePos++)] = t2,
								Parser_GetNextToken(t2),
								pos;
						}
						case e_TOKEN_OP_OP_BRACKET:
						{
							if (once) return Parser_Error("Invalid syntax.");
							once = true,
							t2[E_TOKEN_TYPE] = e_TOKEN_TYPE_APPLY,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2;
						}
						case e_TOKEN_OP_OP_SQUARE:
						{
							t2[E_TOKEN_TYPE] = e_TOKEN_TYPE_INDEX,
							t2[E_TOKEN_LEFT] = pos,
							t2[E_TOKEN_RIGHT] = Parser_GetLeft(prec),
							ISI_gParseTree[(pos = ISI_gParsePos++)] = t2;
						}
						default: return pos;
					}
				}
				else return pos;
			}
		}
		default:
		{
			ISI_gParseTree[ISI_gParsePos++] = token;
		}
	}
	return pos;
}

stock Parser_BuildTree(prec = cellmin)
{
	new
		left = Parser_GetLeft(prec),
		token[E_TOKEN];
	for ( ; ; )
	{
		new
			p2 = prec;
		token = Parser_PeekToken();
		switch (token[E_TOKEN_TYPE])
		{
			case e_TOKEN_TYPE_NONE: break; // Done.
			case e_TOKEN_TYPE_OP:
			{
				if ((p2 = ISI_gscOpData[token[E_TOKEN_OP]][E_OPERATOR_DATA_PRECEDENCE]) <= prec) return left;
			}
			default: return Parser_Error("Unexpected token, expected operator.");
		}
		new
			ret = ISI_gParsePos++;
		Parser_GetNextToken(token); // We only peeked, so pop.
		token[E_TOKEN_LEFT] = left;
		token[E_TOKEN_RIGHT] = Parser_BuildTree((p2 == 4) ? (p2 - 1) : p2),
		ISI_gParseTree[ret] = token,
		left = ret;
	}
	return left;
}

stock Parser_SetInput(line[], size = sizeof (line))
{
	IntrospectInit();
	if (size > sizeof (ISI_gInputLine)) return Parser_Error("Insufficient line space.");
	static
		blank[sizeof (ISI_gsStringTable)] = {-1, ...},
		sNoToken[E_TOKEN] = EMPTY_PARSER_TOKEN;
	return
		ISI_gParseTree[0] = sNoToken, // Static "none" token.
		ISI_gsStringEnd = 0,
		ISI_gsStringTable = blank,
		// Pad with one space, so we can store the first symbol correctly.
		ISI_gInputLine[0] = ' ',
		ISI_gInputLine[1] = '\0',
		strcat(ISI_gInputLine, line),
		ISI_gParsePos = 1,
		ISI_gInputPtr = 1,
		1;
}

stock Parser_GetToken(n)
{
	new
		fail[E_TOKEN] = EMPTY_PARSER_TOKEN;
	if (0 <= n < sizeof (ISI_gParseTree)) return ISI_gParseTree[n];
	return fail;
}

/******************************************************************************\
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
|****                                                                      ****|
|****                                TESTS                                 ****|
|****                                                                      ****|
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
\******************************************************************************/

stock Parser_PrintExpr(str[], size, tree[][E_TOKEN], entry)
{
	str[0] = '\0',
	_Parser_PrintExpr(str, size, tree, entry);
}

stock RenderToken(str[], token[E_TOKEN], size = sizeof (str))
{
	str[0] = '\0',
	_Parser_RenderToken(str, size, token);
}

static stock _Parser_RenderToken(str[], size, token[E_TOKEN])
{
	switch (token[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
	{
		case e_TOKEN_TYPE_STRING: format(str, size, "\"%s\"", ISI_gInputLine[ISI_gsStringTable[token[E_TOKEN_STRING_IDX]]]);
		case e_TOKEN_TYPE_FLOAT:  format(str, size, "%.2f",   token[E_TOKEN_FLOAT_VAL]);
		case e_TOKEN_TYPE_ARRAY:  ReadAmxMemoryArray(token[E_TOKEN_SYM_PTR], str, size);
		case e_TOKEN_TYPE_FVAR:   format(str, size, "%.2f", Float:ReadAmxMemory(token[E_TOKEN_SYM_PTR]));
		case e_TOKEN_TYPE_VAR:    format(str, size, "%d", ReadAmxMemory(token[E_TOKEN_SYM_PTR]));
		case e_TOKEN_TYPE_INT:    valstr(str, token[E_TOKEN_INT_VAL]);
		case e_TOKEN_TYPE_BOOL:   strcat(str, (token[E_TOKEN_BOOL_VAL]) ? ("true") : ("false"), size);
	}
}

static stock _Parser_PrintToken(str[], size, token[E_TOKEN], bool:bracket)
{
	switch (token[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
	{
		case e_TOKEN_TYPE_STRING: format(str, size, "%s\"%s\"", str, ISI_gInputLine[ISI_gsStringTable[token[E_TOKEN_STRING_IDX]]]);
		case e_TOKEN_TYPE_FLOAT:  format(str, size, "%s%.2f",   str, token[E_TOKEN_FLOAT_VAL]);
		case e_TOKEN_TYPE_NATIVE:
		{
			new name[32];
			GetNativeNameFromIndex(token[E_TOKEN_NATIVE_IDX], name);
			strcat(str, name, size);
		}
		case e_TOKEN_TYPE_FUNC, e_TOKEN_TYPE_FFUNC:
			strcat(str, GetFunctionFromAddress(token[E_TOKEN_FUNC_PTR]), size);
		case e_TOKEN_TYPE_VAR, e_TOKEN_TYPE_FVAR, e_TOKEN_TYPE_ARRAY, e_TOKEN_TYPE_FARRAY:
		{
			new
				ch = Parser_GetLocalName(token[E_TOKEN_SYM_PTR]);
			if (ch == '-') strcat(str, GetVariableFromAddress(token[E_TOKEN_SYM_PTR]), size);
			else format(str, size, "%s%c", str, ch);
		}
		case e_TOKEN_TYPE_INT:    format(str, size, "%s%d",     str, token[E_TOKEN_INT_VAL]);
		case e_TOKEN_TYPE_BOOL:   strcat(str, (token[E_TOKEN_BOOL_VAL]) ? ("true") : ("false"), size);
		case e_TOKEN_TYPE_OP:
			if (bracket) format(str, size, "%s(%s)", str, Parser_PrintOp(token[E_TOKEN_OP]));
			else format(str, size, "%s%s", str, Parser_PrintOp(token[E_TOKEN_OP]));
		case e_TOKEN_TYPE_APPLY:    strcat(str, "()", size);
		case e_TOKEN_TYPE_INDEX:    strcat(str, "[]", size);
		case e_TOKEN_TYPE_SYMBOL: format(str, size, "%s<<<%s>>>", str, ISI_gInputLine[ISI_gsStringTable[token[E_TOKEN_STRING_IDX]]]);
	}
}

static stock _Parser_PrintExpr(str[], size, tree[][E_TOKEN], entry)
{
	new
		bool:bracket = false;
	switch (tree[entry][E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_INDEX:
		{
			_Parser_PrintExpr(str, size, tree, tree[entry][E_TOKEN_LEFT]);
			strcat(str, "[", size);
			_Parser_PrintExpr(str, size, tree, tree[entry][E_TOKEN_RIGHT]);
			strcat(str, "]", size);
			return;
		}
		case e_TOKEN_TYPE_APPLY:
		{
			_Parser_PrintExpr(str, size, tree, tree[entry][E_TOKEN_LEFT]);
			strcat(str, "(", size);
			_Parser_PrintExpr(str, size, tree, tree[entry][E_TOKEN_RIGHT]);
			strcat(str, ")", size);
			return;
		}
		case e_TOKEN_TYPE_OP: bracket = tree[entry][E_TOKEN_OP] != e_TOKEN_OP_COMMA;
	}
	if (bracket) strcat(str, "(", size);
	if (tree[entry][E_TOKEN_LEFT] != -1) _Parser_PrintExpr(str, size, tree, tree[entry][E_TOKEN_LEFT]);
	_Parser_PrintToken(str, size, tree[entry], false);
	if (tree[entry][E_TOKEN_RIGHT] != -1) _Parser_PrintExpr(str, size, tree, tree[entry][E_TOKEN_RIGHT]);
	if (bracket) strcat(str, ")", size);
}

stock Parser_PrintTree(str[], size, tree[][E_TOKEN], entry)
{
	str[0] = '\0',
	_Parser_PrintTree(str, size, tree, entry, 0);
}

static stock _Parser_PrintTree(str[], size, tree[][E_TOKEN], entry, indent)
{
	static const
		sIndents[] = "|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |- ";
	strcat(str, sIndents[(sizeof (sIndents) - 1) - indent], size);
	_Parser_PrintToken(str, size, tree[entry], true);
	strcat(str, "\n", size);
	if (tree[entry][E_TOKEN_LEFT] != -1) _Parser_PrintTree(str, size, tree, tree[entry][E_TOKEN_LEFT], indent + 3);
	if (tree[entry][E_TOKEN_RIGHT] != -1) _Parser_PrintTree(str, size, tree, tree[entry][E_TOKEN_RIGHT], indent + 3);
}

#if defined INTROSPECT_PARSER_TEST

// "P"arser "T"est "N"umber.
#define PTN(%1) ISI_gInputLine=#%1,ISI_gInputPtr=0,Parser_GetNextToken(ret),printf("%s: \"%s\"",(ret[E_TOKEN_TYPE]==e_TOKEN_TYPE_INT&&ret[E_TOKEN_INT_VAL]==%1)?("PASS"):("FAIL"),ISI_gInputLine)
// "P"arser "T"est "F"loat.
#define PTF(%1) ISI_gInputLine=#%1,ISI_gInputPtr=0,Parser_GetNextToken(ret),printf("%s: \"%s\"",(ret[E_TOKEN_TYPE]==e_TOKEN_TYPE_FLOAT&&ret[E_TOKEN_FLOAT_VAL]==%1)?("PASS"):("FAIL"),ISI_gInputLine)
// "P"arser "T"est "O"ctal (no native PAWN representation).
#define PTO(%0,%1) ISI_gInputLine=#%0,ISI_gInputPtr=0,Parser_GetNextToken(ret),printf("%s: \"%s\"",(ret[E_TOKEN_TYPE]==e_TOKEN_TYPE_INT&&ret[E_TOKEN_INT_VAL]==%1)?("PASS"):("FAIL"),ISI_gInputLine)

#define TEST_OP(%1) ISI_gInputLine=#%1,ISI_gInputPtr=0,Parser_GetNextToken(ret),printf("%s: \"%s\"",(ret[E_TOKEN_TYPE]==e_TOKEN_TYPE_OP&&!strcmp(Parser_PrintOp(ret[E_TOKEN_OP]),#%1))?("PASS"):("FAIL"),ISI_gInputLine)

main()
{
	IntrospectInit();
	print("\n-------------------------");
	print(" Introspect parser tests");
	print("-------------------------\n");
	new
		ret[E_TOKEN];
	// Test numbers.
	PTN(70);
	PTN(0800);
	PTN(0x45);
	PTN(0b11);
	PTN(0b01010101);
	PTN(2345);
	PTF(5.5);
	PTF(9.5e1);
	PTN(77);
	PTF(66.123);
	PTF(0.1);
	PTO(0500, 320);
	PTO(01234, 668);
	// These are a little awkward, because we are simulating run-time input.
	PTN('f');
	PTO('\\n', '\n');
	PTN('7');
	PTN('@');
	PTN('_');
	PTO("'\\x45;'", '\x45;');
	PTO('\\01', '\01');
	PTO("'\\x11;'", '\x11;');
	// Especially these two...
	PTO('\\\\', '\\');
	PTO('\\\'', '\'');
	TEST_OP("=");
	TEST_OP("==");
	TEST_OP("<=");
	TEST_OP(">=");
	TEST_OP("<");
	TEST_OP(">");
	TEST_OP("!");
	TEST_OP("!=");
	TEST_OP("~");
	TEST_OP("~=");
	TEST_OP("+");
	TEST_OP("+=");
	TEST_OP("-");
	TEST_OP("-=");
	TEST_OP("*");
	TEST_OP("*=");
	TEST_OP("/");
	TEST_OP("/=");
	TEST_OP("%");
	TEST_OP("%=");
	TEST_OP("^");
	TEST_OP("^=");
	TEST_OP("&");
	TEST_OP("&=");
	TEST_OP("|");
	TEST_OP("|=");
	TEST_OP(">>");
	TEST_OP(">>=");
	TEST_OP(">>>");
	TEST_OP(">>>=");
	TEST_OP("<<");
	TEST_OP("<<=");
	TEST_OP("&&");
	TEST_OP("||");
	TEST_OP("(");
	TEST_OP(")");
	TEST_OP("{");
	TEST_OP("}");
	TEST_OP("[");
	TEST_OP("]");
	TEST_OP("++");
	TEST_OP("--");
	TEST_OP("...");
	TEST_OP("..");
	TEST_OP("#");
	TEST_OP("::");
	
#if defined INTROSPECT_PLAYER_DATA
	ISI_gCurrentPlayer = 45;
#endif
	
	//ISI_gInputLine = "34 0x55 7.7 \"Hello \\\"there\\\"\" 'a' MyFuncSymbol",
	Parser_SetInput(" -someVar + 5 * ((44) + 5) / func(a, b, c) * arr[5][6][xx[5]] - someVar++ - ++someVar - someVar-- - --someVar");
	new
		pos = Parser_BuildTree(cellmin),
		str[32],
		output[2048];
	//print(Parser_PrintTree(ISI_gParseTree, pos));
	Parser_PrintTree(output, sizeof (output), ISI_gParseTree, pos);
	print(output);
	Parser_PrintExpr(output, sizeof (output), ISI_gParseTree, pos);
	print(output);
	while (pos != ISI_gParsePos)
	{
		Parser_Print(ISI_gParseTree[pos], str);
		print(str);
		++pos;
	}
	//new str[32];
	while (Parser_GetNextToken(ret))
	{
		Parser_Print(ret, str);
		print(str);
	}
	
	
	TEST_OP("\"");
	TEST_OP("\'");//'
	Parser_SetInput(" 70 5.5 0800 0100 0x345 0b11 0.888 0.888e3");
	//new
	//	ret[E_TOKEN];
	printf("%d", e_TOKEN_TYPE_INT);
	Parser_GetNextToken(ret);
	printf("T = %d %d", ret[E_TOKEN_TYPE], ret[E_TOKEN_INT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d %.1f", ret[E_TOKEN_TYPE], ret[E_TOKEN_FLOAT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d %04d", ret[E_TOKEN_TYPE], ret[E_TOKEN_INT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d %04x", ret[E_TOKEN_TYPE], ret[E_TOKEN_INT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d 0x%x", ret[E_TOKEN_TYPE], ret[E_TOKEN_INT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d 0b%b", ret[E_TOKEN_TYPE], ret[E_TOKEN_INT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d %f", ret[E_TOKEN_TYPE], ret[E_TOKEN_FLOAT_VAL]);
	Parser_GetNextToken(ret);
	printf("T = %d %f", ret[E_TOKEN_TYPE], ret[E_TOKEN_FLOAT_VAL]);
	
	// BUG: Using "(a, b)" as the FIRST parameter doesn't work.  Others do.
	Parser_SetInput("Parser_FakeOne((Parser_FakeThree, 77), Parser_FakeTwo(), (7, 57))");
	pos = Parser_BuildTree(cellmin);
	//print(Parser_PrintTree(ISI_gParseTree, pos));
	Parser_PrintTree(output, sizeof (output), ISI_gParseTree, pos);
	print(output);
	
	Parser_SetInput("f = g = h + 55");
	pos = Parser_BuildTree(cellmin);
	//print(Parser_PrintTree(ISI_gParseTree, pos));
	Parser_PrintTree(output, sizeof (output), ISI_gParseTree, pos);
	print(output);
	
	Parser_SetInput("Parser_FakeThree");
	pos = Parser_BuildTree(cellmin);
	//print(Parser_PrintTree(ISI_gParseTree, pos));
	Parser_PrintTree(output, sizeof (output), ISI_gParseTree, pos);
	print(output);
	
	Parser_SetInput("Parser_FakeTwo(one)");
	pos = Parser_BuildTree(cellmin);
	//print(Parser_PrintTree(ISI_gParseTree, pos));
	Parser_PrintTree(output, sizeof (output), ISI_gParseTree, pos);
	print(output);
	Parser_FakeOne();
	Parser_FakeTwo();
}

// Variables we later get the address of.
stock Parser_FakeThree;

stock Parser_FakeTwo()
{
}

stock Parser_FakeOne()
{
	printf("%d", Parser_FakeThree);
}

#endif

/******************************************************************************\
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
|****                                                                      ****|
|****                               STRINGS                                ****|
|****                                                                      ****|
|******************************************************************************|
|******************************************************************************|
|******************************************************************************|
\******************************************************************************/

stock Parser_AddString(start)
{
	new
		i = 0;
	for ( ; i != sizeof (ISI_gsStringTable); ++i)
	{
		if (ISI_gsStringTable[i] == -1) break;
	}
	if (i == sizeof (ISI_gsStringTable)) return -1;
	ISI_gsStringTable[i] = ISI_gsStringEnd;
	while ((ISI_gInputLine[ISI_gsStringEnd++] = ISI_gInputLine[start++])) {}
	return i;
}

stock Parser_ReserveString()
{
	new
		i = 0;
	for ( ; i != sizeof (ISI_gsStringTable); ++i)
	{
		if (ISI_gsStringTable[i] == -1) break;
	}
	if (i == sizeof (ISI_gsStringTable)) return -1;
	ISI_gsStringTable[i] = ISI_gsStringEnd;
	return i;
}

stock Parser_RemoveString(idx)
{
	if (idx == -1) return;
	new
		rem = ISI_gsStringTable[idx];
	if (rem == -1) return;
	for ( ; ; )
	{
		new
			top = cellmax,
			found = -1;
		// Find the next highest slot string.
		for (new i = 0; i != sizeof (ISI_gsStringTable); ++i)
		{
			if (rem < ISI_gsStringTable[i] < top)
			{
				top = ISI_gsStringTable[i],
				found = i;
			}
		}
		if (found == -1) break;
		ISI_gsStringTable[found] = rem;
		// There must be a faster way than this...  Given that the ranges may be
		// overlapping.
		while ((ISI_gInputLine[rem++] = ISI_gInputLine[top++])) {}
	}
	ISI_gsStringTable[idx] = -1;
}

stock Parser_InsertString(str[])
{
	new
		i = 0;
	for ( ; i != sizeof (ISI_gsStringTable); ++i)
	{
		if (ISI_gsStringTable[i] == -1) break;
	}
	if (i == sizeof (ISI_gsStringTable)) return -1;
	ISI_gsStringTable[i] = ISI_gsStringEnd;
	new
		idx = 0;
	while ((ISI_gInputLine[ISI_gsStringEnd++] = str[idx++])) {}
	return i;
}

