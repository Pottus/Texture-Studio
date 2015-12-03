#include "parser"

static stock
	ISI_gHeap[128],
	ISI_gHeapPtr = -1;

static stock const
	_EXEC_TAG_MISMATCH[] = "PARSER WARNING: Tag mismatch.",
	_EXEC_INCOMPATIBLE[] = "PARSER ERROR: Incompatible operands.",
	_EXEC_NOT_LVALUE[] = "PARSER ERROR: Not an lvalue.";

#if defined INTROSPECT_PLAYER_DATA
	#define EXEC_TAG_MISMATCH _Parser_Msg(_EXEC_TAG_MISMATCH)
	#define EXEC_INCOMPATIBLE _Parser_Msg(_EXEC_INCOMPATIBLE)
	#define EXEC_NOT_LVALUE   _Parser_Msg(_EXEC_NOT_LVALUE)
#else
	#define EXEC_TAG_MISMATCH print(_EXEC_TAG_MISMATCH)
	#define EXEC_INCOMPATIBLE print(_EXEC_INCOMPATIBLE)
	#define EXEC_NOT_LVALUE   print(_EXEC_NOT_LVALUE)
#endif

stock RunExpression(line[], size = sizeof (line), as = -1)
{
	new
		ret[E_TOKEN] = EMPTY_PARSER_TOKEN;
	ISI_gHeapPtr = -1;
	Parser_SetPlayer(as);
	if (Parser_SetInput(line, size))
	{
		new
			parse = Parser_BuildTree();
		Exec_Evaluate(ret, ISI_gParseTree, parse);
	}
	Parser_SetPlayer(-1);
	return ret;
}

static stock MI(const token[E_TOKEN])
{
	// Get a token as an integer.
	switch (token[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR:
			return ReadAmxMemory(token[E_TOKEN_SYM_PTR]);
		case e_TOKEN_TYPE_INT:
			return token[E_TOKEN_INT_VAL];
		case e_TOKEN_TYPE_BOOL:
			return token[E_TOKEN_BOOL_VAL] ? 1 : 0;
		case e_TOKEN_TYPE_FLOAT:
			return
				EXEC_TAG_MISMATCH,
				floatround(token[E_TOKEN_FLOAT_VAL]);
		case e_TOKEN_TYPE_FVAR:
			return
				EXEC_TAG_MISMATCH,
				floatround(Float:ReadAmxMemory(token[E_TOKEN_SYM_PTR]));
	}
	return cellmin; // Almost NAN.
}

static stock Float:MF(const token[E_TOKEN])
{
	// Get a token as a float.
	switch (token[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR:
			return
				EXEC_TAG_MISMATCH,
				float(ReadAmxMemory(token[E_TOKEN_SYM_PTR]));
		case e_TOKEN_TYPE_INT:
			return
				EXEC_TAG_MISMATCH,
				float(token[E_TOKEN_INT_VAL]);
		case e_TOKEN_TYPE_BOOL:
			return token[E_TOKEN_BOOL_VAL] ? 1.0 : 0.0;
		case e_TOKEN_TYPE_FLOAT:
			return token[E_TOKEN_FLOAT_VAL];
		case e_TOKEN_TYPE_FVAR:
			return Float:ReadAmxMemory(token[E_TOKEN_SYM_PTR]);
	}
	return Float:0x7FFFFFFF; // NAN.
}

static stock e_TOKEN_TYPE:Exec_ResolveTags(const l[E_TOKEN], const r[E_TOKEN], &lr, &rr)
{
	new
		bool:rfloat = false;
	switch (l[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR, e_TOKEN_TYPE_BOOL, e_TOKEN_TYPE_INT: {}
		case e_TOKEN_TYPE_FVAR, e_TOKEN_TYPE_FLOAT: rfloat = true;
		default: return e_TOKEN_TYPE_NONE;
	}
	switch (r[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR, e_TOKEN_TYPE_BOOL, e_TOKEN_TYPE_INT: {}
		case e_TOKEN_TYPE_FVAR, e_TOKEN_TYPE_FLOAT: rfloat = true;
		default: return e_TOKEN_TYPE_NONE;
	}
	if (rfloat)
	{
		// Some floats.
		return
			lr = _:MF(l),
			rr = _:MF(r),
			e_TOKEN_TYPE_FLOAT;
	}
	else
	{
		return
			lr = MI(l),
			rr = MI(r),
			e_TOKEN_TYPE_INT;
	}
}

static stock e_TOKEN_TYPE:Exec_ResolveBool(const l[E_TOKEN], const r[E_TOKEN], &lr, &rr)
{
	switch (l[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR:
			lr = ReadAmxMemory(l[E_TOKEN_SYM_PTR]) ? true : false;
		case e_TOKEN_TYPE_INT  :
			lr = l[E_TOKEN_INT_VAL] ? true : false;
		case e_TOKEN_TYPE_BOOL :
			lr = l[E_TOKEN_BOOL_VAL];
		case e_TOKEN_TYPE_FLOAT:
			lr = l[E_TOKEN_FLOAT_VAL] ? true : false;
		case e_TOKEN_TYPE_FVAR :
			lr = Float:ReadAmxMemory(l[E_TOKEN_SYM_PTR]) ? true : false;
		default:
			return e_TOKEN_TYPE_NONE;
	}
	switch (r[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR:
			rr = ReadAmxMemory(r[E_TOKEN_SYM_PTR]) ? true : false;
		case e_TOKEN_TYPE_INT  :
			rr = r[E_TOKEN_INT_VAL] ? true : false;
		case e_TOKEN_TYPE_BOOL :
			rr = r[E_TOKEN_BOOL_VAL];
		case e_TOKEN_TYPE_FLOAT:
			rr = r[E_TOKEN_FLOAT_VAL] ? true : false;
		case e_TOKEN_TYPE_FVAR :
			rr = Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]) ? true : false;
		default:
			return e_TOKEN_TYPE_NONE;
	}
	return e_TOKEN_TYPE_BOOL;
}

static stock e_TOKEN_TYPE:Exec_ResolveInt(const l[E_TOKEN], const r[E_TOKEN], &lr, &rr)
{
	new
		e_TOKEN_TYPE:ret = e_TOKEN_TYPE_INT;
	switch (l[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR:
			lr = ReadAmxMemory(l[E_TOKEN_SYM_PTR]);
		case e_TOKEN_TYPE_INT  :
			lr = l[E_TOKEN_INT_VAL];
		case e_TOKEN_TYPE_BOOL :
			lr = _:l[E_TOKEN_BOOL_VAL];
		case e_TOKEN_TYPE_FLOAT:
			ret = e_TOKEN_TYPE_FLOAT,
			lr = _:l[E_TOKEN_FLOAT_VAL];
		case e_TOKEN_TYPE_FVAR :
			ret = e_TOKEN_TYPE_FLOAT,
			lr = _:Float:ReadAmxMemory(l[E_TOKEN_SYM_PTR]);
		default:
			return e_TOKEN_TYPE_NONE;
	}
	switch (r[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_VAR  :
		{
			if (ret == e_TOKEN_TYPE_FLOAT) EXEC_TAG_MISMATCH;
			rr = ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
		}
		case e_TOKEN_TYPE_INT  :
		{
			if (ret == e_TOKEN_TYPE_FLOAT) EXEC_TAG_MISMATCH;
			rr = r[E_TOKEN_INT_VAL];
		}
		case e_TOKEN_TYPE_BOOL :
		{
			if (ret == e_TOKEN_TYPE_FLOAT) EXEC_TAG_MISMATCH;
			rr = _:r[E_TOKEN_BOOL_VAL];
		}
		case e_TOKEN_TYPE_FLOAT:
		{
			if (ret == e_TOKEN_TYPE_INT) EXEC_TAG_MISMATCH;
			rr = _:r[E_TOKEN_FLOAT_VAL];
		}
		case e_TOKEN_TYPE_FVAR :
		{
			if (ret == e_TOKEN_TYPE_INT) EXEC_TAG_MISMATCH;
			rr = _:Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
		}
		default:
			return e_TOKEN_TYPE_NONE;
	}
	return ret;
}

static stock Exec_ToHeap(value)
{
	static
		sNullDest;
	if (++ISI_gHeapPtr == sizeof (ISI_gHeap))
	{
		Parser_Error("Heap overflow.");
		return ref(sNullDest);
	}
	else
	{
		ISI_gHeap[ISI_gHeapPtr] = value;
		return ref(ISI_gHeap[ISI_gHeapPtr]);
	}
}

#define EXEC_OP(%0\32;%9\32;%1,%7) switch(Exec_ResolveTags(%0,%1,lr,rr)) { \
	case e_TOKEN_TYPE_FLOAT:ret[E_TOKEN_TYPE]=e_TOKEN_TYPE_FLOAT,ret[E_TOKEN_FLOAT_VAL]=%7((Float:lr),(Float:rr)); \
	case e_TOKEN_TYPE_INT:ret[E_TOKEN_TYPE]=e_TOKEN_TYPE_INT,ret[E_TOKEN_INT_VAL]=lr%9rr; \
	default:EXEC_INCOMPATIBLE;}

#define EXEC_CMP(%0\32;%9\32;%1,%7) switch(Exec_ResolveTags(%0,%1,lr,rr)) { \
	case e_TOKEN_TYPE_FLOAT:ret[E_TOKEN_TYPE]=e_TOKEN_TYPE_BOOL,ret[E_TOKEN_BOOL_VAL]=%7((Float:lr),(Float:rr)); \
	case e_TOKEN_TYPE_INT:ret[E_TOKEN_TYPE]=e_TOKEN_TYPE_BOOL,ret[E_TOKEN_BOOL_VAL]=lr%9rr; \
	default:EXEC_INCOMPATIBLE;}

#define EXEC_BOOL(%0\32;%9\32;%1) if(Exec_ResolveBool(%0,%1,lr,rr)==e_TOKEN_TYPE_BOOL) \
	ret[E_TOKEN_TYPE]=e_TOKEN_TYPE_BOOL,ret[E_TOKEN_BOOL_VAL]=(bool:lr)%9(bool:rr); \
	else EXEC_INCOMPATIBLE;

#define EXEC_INT(%0\32;%9\32;%1) { new e_TOKEN_TYPE:ttt = Exec_ResolveInt(%0,%1,lr,rr); \
	if(ttt==e_TOKEN_TYPE_NONE) EXEC_INCOMPATIBLE; \
	else ret[E_TOKEN_TYPE]=ttt,ret[E_TOKEN_INT_VAL]=lr%9rr; }

static stock Exec_ExecToken(const t[E_TOKEN], const l[E_TOKEN], const r[E_TOKEN])
{
	static lr, rr;
	static const
		scAssign[E_TOKEN] = MAKE_PARSER_TOKEN(e_TOKEN_TYPE_OP, e_TOKEN_OP_ASSIGN, -1, -1);
	new
		ret[E_TOKEN] = EMPTY_PARSER_TOKEN;
	switch (t[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
	{
		case e_TOKEN_TYPE_OP       : switch (t[E_TOKEN_OP])
		{
			case e_TOKEN_OP_COMMA, e_TOKEN_OP_SEMICOLON:
			{
				ret = r;
			}
			case e_TOKEN_OP_ASSIGN: switch (l[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
			{
				case e_TOKEN_TYPE_VAR:
				{
					rr = MI(r),
					WriteAmxMemory(l[E_TOKEN_SYM_PTR], rr),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = rr;
				}
				case e_TOKEN_TYPE_FVAR:
				{
					rr = _:MF(r),
					WriteAmxMemory(l[E_TOKEN_SYM_PTR], rr),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = Float:rr;
				}
				case e_TOKEN_TYPE_ARRAY:
				{
					// Allow string assignment.
					if (r[E_TOKEN_TYPE] == e_TOKEN_TYPE_STRING)
					{
						new
							idx = ISI_gsStringTable[(ret[E_TOKEN_STRING_IDX] = r[E_TOKEN_STRING_IDX])];
						ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_STRING,
						WriteAmxMemoryArray(l[E_TOKEN_SYM_PTR], ISI_gInputLine[idx], strlen(ISI_gInputLine[idx]));
					}
					else Parser_Error("Can only assign strings to arrays.");
				}
				default: EXEC_NOT_LVALUE;
			}
			// Float versions are reversed.
			case e_TOKEN_OP_EQUALS : // '=='
				EXEC_CMP(l == r, 0 == floatcmp)
			case e_TOKEN_OP_LTE    : // '<='
				EXEC_CMP(l <= r, 0 >= floatcmp)
			case e_TOKEN_OP_GTE    : // '>='
				EXEC_CMP(l >= r, 0 <= floatcmp)
			case e_TOKEN_OP_LESS   : // '<'
				EXEC_CMP(l < r,  0 >  floatcmp)
			case e_TOKEN_OP_GREATER: // '>'
				EXEC_CMP(l > r,  0 <  floatcmp)
			case e_TOKEN_OP_NEQ    : // '!='
				EXEC_CMP(l != r, 0 != floatcmp)
			#define _EXEC_DO_ASSIGN(%0) case e_TOKEN_OP_%0_ASS: { \
				static const scMathOp[E_TOKEN] = MAKE_PARSER_TOKEN(e_TOKEN_TYPE_OP, e_TOKEN_OP_%0, -1, -1); \
				return ret = Exec_ExecToken(scMathOp, l, r), Exec_ExecToken(scAssign, l, ret); }
			// For these, run the code twice.
			_EXEC_DO_ASSIGN(INV)
			_EXEC_DO_ASSIGN(ADD)
			_EXEC_DO_ASSIGN(SUB)
			_EXEC_DO_ASSIGN(MUL)
			_EXEC_DO_ASSIGN(DIV)
			_EXEC_DO_ASSIGN(MOD)
			_EXEC_DO_ASSIGN(XOR)
			_EXEC_DO_ASSIGN(LAND)
			_EXEC_DO_ASSIGN(LOR)
			_EXEC_DO_ASSIGN(RSHIFT)
			_EXEC_DO_ASSIGN(SHIFT)
			_EXEC_DO_ASSIGN(LSHIFT)
			#undef _EXEC_DO_ASSIGN
			case e_TOKEN_OP_INV : switch (r[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = ~ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
				case e_TOKEN_TYPE_INT  :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = ~r[E_TOKEN_INT_VAL];
				case e_TOKEN_TYPE_BOOL :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = ~_:r[E_TOKEN_BOOL_VAL];
				case e_TOKEN_TYPE_FLOAT:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = ~r[E_TOKEN_FLOAT_VAL];
				case e_TOKEN_TYPE_FVAR :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = ~Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
				default:
					return Parser_Error("Unary inversion not applied to value."), ret;
			}
			case e_TOKEN_OP_NOT : switch (r[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
					ret[E_TOKEN_BOOL_VAL] = !ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
				case e_TOKEN_TYPE_INT  :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
					ret[E_TOKEN_BOOL_VAL] = !r[E_TOKEN_INT_VAL];
				case e_TOKEN_TYPE_BOOL :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
					ret[E_TOKEN_BOOL_VAL] = !r[E_TOKEN_BOOL_VAL];
				case e_TOKEN_TYPE_FLOAT:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
					ret[E_TOKEN_BOOL_VAL] = !r[E_TOKEN_FLOAT_VAL];
				case e_TOKEN_TYPE_FVAR :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_BOOL,
					ret[E_TOKEN_BOOL_VAL] = !Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
				default: return Parser_Error("Unary negation not applied to value."), ret;
			}
			case e_TOKEN_OP_NEG : switch (r[E_TOKEN_TYPE]) // PREFIX '-'
			{
				case e_TOKEN_TYPE_VAR:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = -ReadAmxMemory(r[E_TOKEN_SYM_PTR]);
				case e_TOKEN_TYPE_INT  :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = -r[E_TOKEN_INT_VAL];
				case e_TOKEN_TYPE_BOOL :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = -_:r[E_TOKEN_BOOL_VAL];
				case e_TOKEN_TYPE_FLOAT:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = r[E_TOKEN_FLOAT_VAL] ^ Float:cellmin;
				case e_TOKEN_TYPE_FVAR :
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]) ^ Float:cellmin;
				default:
					return Parser_Error("Unary minus not applied to value."), ret;
			}
			case e_TOKEN_OP_SUB    : // INFIX '-'
				EXEC_OP(l - r, floatsub)
			case e_TOKEN_OP_ADD    : // '+'
				EXEC_OP(l + r, floatadd)
			case e_TOKEN_OP_MUL    : // '*'
				EXEC_OP(l * r, floatmul)
			case e_TOKEN_OP_DIV    : // '/'
				EXEC_OP(l / r, floatdiv)
			case e_TOKEN_OP_MOD : // '%'
			{
				if (Exec_ResolveTags(l, r, lr, rr) == e_TOKEN_TYPE_INT)
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = lr % rr;
				else EXEC_INCOMPATIBLE;
			}
			case e_TOKEN_OP_XOR    : // '^'
				EXEC_INT(l ^ r)
			case e_TOKEN_OP_LAND   : // INFIX '&'
				EXEC_INT(l & r)
			case e_TOKEN_OP_REF : switch (r[E_TOKEN_TYPE]) // PREFIX '&'
			{
				case e_TOKEN_TYPE_INT, e_TOKEN_TYPE_BOOL, e_TOKEN_TYPE_FLOAT:
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = Exec_ToHeap(r[E_TOKEN_INT_VAL]);
				case e_TOKEN_TYPE_FVAR, e_TOKEN_TYPE_VAR:
					// Store the pointer as a number.
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = r[E_TOKEN_SYM_PTR];
				default:
					return Parser_Error("References must be made to values."), ret;
			}
			case e_TOKEN_OP_LOR    : // '|'
				EXEC_INT(l | r)
			case e_TOKEN_OP_RSHIFT : // '>>'
				EXEC_INT(l >> r)
			case e_TOKEN_OP_SHIFT  : // '>>>'
				EXEC_INT(l >>> r)
			case e_TOKEN_OP_LSHIFT : // '<<'
				EXEC_INT(l << r)
			case e_TOKEN_OP_AND    : // '&&'
				EXEC_BOOL(l && r)
			case e_TOKEN_OP_OR     : // '||'
				EXEC_BOOL(l || r)
			case e_TOKEN_OP_POST_INC: switch (l[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR: // Suffix integer op.
					lr = ReadAmxMemory(l[E_TOKEN_SYM_PTR]),
					WriteAmxMemory(l[E_TOKEN_SYM_PTR], lr + 1),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = lr;
				case e_TOKEN_TYPE_FVAR: // Suffix float op.
					lr = _:Float:ReadAmxMemory(l[E_TOKEN_SYM_PTR]),
					WriteAmxMemory(l[E_TOKEN_SYM_PTR], _:floatadd(Float:lr, 1.0)),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = Float:lr;
				default: EXEC_NOT_LVALUE;
			}
			case e_TOKEN_OP_PRE_INC: switch (r[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR: // Prefix integer op.
					rr = ReadAmxMemory(r[E_TOKEN_SYM_PTR]) + 1,
					WriteAmxMemory(r[E_TOKEN_SYM_PTR], rr),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = rr;
				case e_TOKEN_TYPE_FVAR: // Prefix float op.
					rr = _:floatadd(Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]), 1.0),
					WriteAmxMemory(r[E_TOKEN_SYM_PTR], rr),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = Float:rr;
				default: EXEC_NOT_LVALUE;
			}
			case e_TOKEN_OP_POST_DEC: switch (l[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR: // Suffix integer op.
					lr = ReadAmxMemory(l[E_TOKEN_SYM_PTR]),
					WriteAmxMemory(l[E_TOKEN_SYM_PTR], lr - 1),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = lr;
				case e_TOKEN_TYPE_FVAR: // Suffix float op.
					lr = _:Float:ReadAmxMemory(l[E_TOKEN_SYM_PTR]),
					WriteAmxMemory(l[E_TOKEN_SYM_PTR], _:floatsub(Float:lr, 1.0)),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = Float:lr;
				default: EXEC_NOT_LVALUE;
			}
			case e_TOKEN_OP_PRE_DEC: switch (r[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR: // Prefix integer op.
					rr = ReadAmxMemory(r[E_TOKEN_SYM_PTR]) - 1,
					WriteAmxMemory(r[E_TOKEN_SYM_PTR], rr),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					ret[E_TOKEN_INT_VAL] = rr;
				case e_TOKEN_TYPE_FVAR: // Prefix float op.
					rr = _:floatsub(Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]), 1.0),
					WriteAmxMemory(r[E_TOKEN_SYM_PTR], rr),
					ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					ret[E_TOKEN_FLOAT_VAL] = Float:rr;
				default: EXEC_NOT_LVALUE;
			}
			case e_TOKEN_OP_CONCAT:
			{
				if (l[E_TOKEN_TYPE] != e_TOKEN_TYPE_STRING || r[E_TOKEN_TYPE] != e_TOKEN_TYPE_STRING)
					return Parser_Error("Can only concat strings."), ret;
				new
					str[512];
				ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_STRING,
				lr = l[E_TOKEN_STRING_IDX],
				rr = r[E_TOKEN_STRING_IDX],
				strcat(str, ISI_gInputLine[ISI_gsStringTable[lr]]),
				strcat(str, ISI_gInputLine[ISI_gsStringTable[rr]]),
				Parser_RemoveString(lr),
				Parser_RemoveString(rr),
				ret[E_TOKEN_STRING_IDX] = Parser_InsertString(str);
			}
			case e_TOKEN_OP_HASH:
			{
				new
					str[512];
				switch (r[E_TOKEN_TYPE])
				{
					case e_TOKEN_TYPE_VAR:
					{
						valstr(str, ReadAmxMemory(r[E_TOKEN_SYM_PTR]));
					}
					case e_TOKEN_TYPE_INT:
					{
						valstr(str, r[E_TOKEN_INT_VAL]);
					}
					case e_TOKEN_TYPE_BOOL:
					{
						str = r[E_TOKEN_BOOL_VAL] ? ("true") : ("false");
					}
					case e_TOKEN_TYPE_FLOAT:
					{
						format(str, sizeof (str), "%.2f", r[E_TOKEN_FLOAT_VAL]);
					}
					case e_TOKEN_TYPE_FVAR:
					{
						format(str, sizeof (str), "%.2f", Float:ReadAmxMemory(r[E_TOKEN_SYM_PTR]));
					}
					case e_TOKEN_TYPE_STRING: return r;
					default: return Parser_Error("Cannot convert token to string."), ret;
				}
				ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_STRING,
				ret[E_TOKEN_STRING_IDX] = Parser_InsertString(str);
			}
			//default: TODO: Whatever OP this is...
		}
		case e_TOKEN_TYPE_INDEX      :
		{
			rr = MI(r);
			if (rr == cellmin) return Parser_Error("Invalid index."), ret;
			rr = l[E_TOKEN_SYM_PTR] + rr * 4,
			lr = _:(l[E_TOKEN_TYPE] >>> TOKEN_TYPE_SHIFT) - 1;
			switch (l[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
			{
				case e_TOKEN_TYPE_ARRAY:
					if (lr <= 0)
						ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_VAR,
						ret[E_TOKEN_SYM_PTR] = rr;
					else
						ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:lr << TOKEN_TYPE_SHIFT),
						ret[E_TOKEN_SYM_PTR] = ReadAmxMemory(rr);
				case e_TOKEN_TYPE_FARRAY:
					if (lr <= 0)
						ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FVAR,
						ret[E_TOKEN_SYM_PTR] = rr;
					else
						ret[E_TOKEN_TYPE] = e_TOKEN_TYPE_FARRAY | (e_TOKEN_TYPE:lr << TOKEN_TYPE_SHIFT),
						ret[E_TOKEN_SYM_PTR] = ReadAmxMemory(rr);
				default: return Parser_Error("Invalid subscript or not an array."), ret;
			}
		}
		default: ret = t;
	}
	return ret;
	// new
		// l[E_EXEC_RESULT]:
		// r[E_EXEC_RESULT];
}

static stock Exec_PushOne(tree[][E_TOKEN], entry)
{
	new
		token[E_TOKEN],
		bool:pushed;
	Exec_Evaluate(token, tree, entry);
	switch (token[E_TOKEN_TYPE] & TOKEN_TYPE_MASK)
	{
		case e_TOKEN_TYPE_VAR, e_TOKEN_TYPE_FVAR:
		{
			pushed = Push(ReadAmxMemory(token[E_TOKEN_SYM_PTR]));
		}
		case e_TOKEN_TYPE_INT,
		     e_TOKEN_TYPE_BOOL,
		     e_TOKEN_TYPE_FLOAT,
		     e_TOKEN_TYPE_ARRAY,
		     e_TOKEN_TYPE_FARRAY:
		{
			pushed = Push(token[E_TOKEN_INT_VAL]);
		}
		case e_TOKEN_TYPE_STRING:
		{
			pushed = PushString(ISI_gInputLine[ISI_gsStringTable[token[E_TOKEN_STRING_IDX]]]);
		}
	}
	if (!pushed) Parser_Error("Could not push parameters.");
}

static stock Exec_PushParams(tree[][E_TOKEN], entry)
{
	if (tree[entry][E_TOKEN_TYPE] == e_TOKEN_TYPE_NONE) return 0; // End.
	else if (tree[entry][E_TOKEN_TYPE] != e_TOKEN_TYPE_OP || tree[entry][E_TOKEN_OP] != e_TOKEN_OP_COMMA)
	{
		Exec_PushOne(tree, entry);
		return
			1;
	}
	new
		ret = Exec_PushParams(tree, tree[entry][E_TOKEN_LEFT]) + 1;
	Exec_PushOne(tree, tree[entry][E_TOKEN_RIGHT]);
	return ret;
}

static stock Exec_Evaluate(token[E_TOKEN], tree[][E_TOKEN], entry)
{
	new
		l[E_TOKEN],
		r[E_TOKEN];
	token = tree[0];
	if (entry == -1) return;
	token = tree[entry];
	if (token[E_TOKEN_LEFT] == -1 && token[E_TOKEN_RIGHT] == -1) return;
	Exec_Evaluate(l, tree, token[E_TOKEN_LEFT]);
	switch (token[E_TOKEN_TYPE])
	{
		case e_TOKEN_TYPE_OP: if (token[E_TOKEN_OP] == e_TOKEN_OP_QUESTION)
		{
			// Ternary operator - requires special handling.
			new
				bool:tf;
			r = tree[token[E_TOKEN_RIGHT]];
			if (r[E_TOKEN_TYPE] != e_TOKEN_TYPE_OP || r[E_TOKEN_OP] != e_TOKEN_OP_COLON)
			{
				Parser_Error("Missing ':' after '?'.");
				return;
			}
			switch (l[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_VAR:
					tf = bool:ReadAmxMemory(l[E_TOKEN_SYM_PTR]);
				case e_TOKEN_TYPE_INT:
					tf = bool:l[E_TOKEN_INT_VAL];
				case e_TOKEN_TYPE_BOOL:
					tf = l[E_TOKEN_BOOL_VAL];
				case e_TOKEN_TYPE_FLOAT:
					tf = bool:token[E_TOKEN_FLOAT_VAL];
				case e_TOKEN_TYPE_FVAR:
					tf = bool:Float:ReadAmxMemory(token[E_TOKEN_SYM_PTR]);
				default:
				{
					Parser_Error("Could not evaluate condition.");
					return;
				}
			}
			// Only execute either the "true" or "false" branch (for side effects).
			if (tf) Exec_Evaluate(token, tree, r[E_TOKEN_LEFT]);
			else Exec_Evaluate(token, tree, r[E_TOKEN_RIGHT]);
			return;
		}
		case e_TOKEN_TYPE_APPLY:
		{
			// Function call.
			new
				count = Exec_PushParams(tree, token[E_TOKEN_RIGHT]);
			switch (l[E_TOKEN_TYPE])
			{
				case e_TOKEN_TYPE_NATIVE:
				{
					token[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					token[E_TOKEN_INT_VAL] = SysreqCN(l[E_TOKEN_NATIVE_IDX], count);
				}
				case e_TOKEN_TYPE_FUNC:
				{
					token[E_TOKEN_TYPE] = e_TOKEN_TYPE_INT,
					token[E_TOKEN_INT_VAL] = CallN(l[E_TOKEN_FUNC_PTR], count);
				}
				case e_TOKEN_TYPE_FFUNC:
				{
					token[E_TOKEN_TYPE] = e_TOKEN_TYPE_FLOAT,
					token[E_TOKEN_FLOAT_VAL] = Float:CallN(l[E_TOKEN_FUNC_PTR], count);
				}
				default: Parser_Error("Not a pointer.");
			}
			return;
		}
	}
	// Default action.
	Exec_Evaluate(r, tree, token[E_TOKEN_RIGHT]);
	token = Exec_ExecToken(token, l, r);
}

#undef EXEC_OP
#undef EXEC_CMP
#undef EXEC_BOOL
#undef EXEC_INT

#undef EXEC_TAG_MISMATCH
#undef EXEC_INCOMPATIBLE
#undef EXEC_NOT_LVALUE

#if defined INTROSPECT_EXEC_TEST

#include "..\amx\amx_memory"

main()
{
	// These should all print "1".
	new
		l  [E_TOKEN],
		r  [E_TOKEN],
		op [E_TOKEN],
		res[E_TOKEN];
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 11),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_ADD),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, 53}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_MUL),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, 0}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 11),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_MUL),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, 462}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_ADD),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, 42}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_FLOAT, _:11.0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_ADD),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_FLOAT, _:53.0}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_FLOAT, _:0.0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_ADD),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_FLOAT, _:42.0}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_FLOAT, _:0.0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_EQUALS),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:false}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(r, e_TOKEN_TYPE_FLOAT, _:42.0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_EQUALS),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:true}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 555),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 101),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_GREATER),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:true}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 65),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 101),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_GREATER),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:false}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 65),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_AND),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:false}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 65),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_OR),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:true}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 65),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 33),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_AND),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:true}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_INT, 0),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 0),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_OR),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_BOOL, _:false}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_NONE, 0),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 7),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_NEG),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, -7}));
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_NONE, 0),
	MAKE_TOKEN(r, e_TOKEN_TYPE_FLOAT, _:88.43),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_NEG),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_FLOAT, _:-88.43}));
	
	new testArr[55][66];
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:2 << TOKEN_TYPE_SHIFT), ref(testArr)),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 5),
	MAKE_TOKEN(op, e_TOKEN_TYPE_INDEX, 0),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_ARRAY | (e_TOKEN_TYPE:1 << TOKEN_TYPE_SHIFT), ReadAmxMemory(ref(testArr) + 20)}));
	
	new testVar;
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_VAR, ref(testVar)),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 7),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_ASSIGN),
	res = Exec_ExecToken(op, l, r);
	printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, 7}));
	printf("%d", testVar);
	
	new testA2[10];
	
	MAKE_TOKEN(l, e_TOKEN_TYPE_ARRAY, ref(testA2)),
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 5),
	MAKE_TOKEN(op, e_TOKEN_TYPE_INDEX, 0),
	res = Exec_ExecToken(op, l, r);
	MAKE_TOKEN(r, e_TOKEN_TYPE_INT, 42),
	MAKE_TOKEN(op, e_TOKEN_TYPE_OP, e_TOKEN_OP_ASSIGN),
	res = Exec_ExecToken(op, res, r);
	//printf("%d", COMPARE_PARSER_TOKEN(res, {e_TOKEN_TYPE_INT, 7}));
	printf("%d", testA2[5]);
}

#endif

