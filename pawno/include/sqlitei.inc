/*
	SQLite Improved v0.9.7 by Slice
	
	Changelog:
			2015-07-13:
				* Update for 0.3.7 R2.
				* All crash issues should be solved now, including the previous one that happened only on some servers.

			2014-10-08:
				* Fix crash when using stmt_fetch_row on an empty result (only affects Linux servers).

			2013-10-07:
				* Display errors from db_query. Works only on Windows.
			
			2012-07-23:
				* Fix problem with persistent databases (hopefully).
			
			2012-07-21:
				* Fix crash happening on Linux related to NULL values in db_free_result.
			
			2012-07-15:
				* Improvements to persistent databases.
			
			2012-06-15:
				* Fix compiler crash when db_query isn't used.
			
			2012-05-27:
				* Always throw warnings when invalid results are given to SQLitei functions.
				* Even more improvements to stability!
				* GetAmxBase is now updated with a JIT compatible version (all credits to Zeex).
				* All the default DB functions (which are hooked by SQLitei) are now compatible with the JIT plugin.
				* Fixed a bug in SA-MP's SQLite implementation where strings would contain signed characters instead of unsigned.
				  Most functions work just fine with both types of strings but strcmp, for one, does not.
				* stmt_bind_value now deals with packed strings properly.
			
			2012-03-22:
				* db_query now accept extra parameters similar to those in stmt_bind_value, allowing
				  a very quick way to format and run queries!
				
			2012-03-21:
				* Fixed a rare crash that would occur if you closed a DB while having autofreed results open.
				* The deprecated db_query_autofree is now removed. Simply use db_query instead.
				* Fixed a problem where a certain integer would cause an invalid value.
				* Added DB::TYPE_UINT, which inserts an unsigned integer.
				  An unsigned integer have values between 0 and 4294967295 as opposed to -2147483648 and 2147483647.
				* Added helper function db_print_query.
				* Added db_dump_table!
			
			2012-03-01:
				* db_free_result will now completely ignore invalid results (0).
			
			2012-02-12:
				* Added db_attach_memory_db and db_detach_memory_db.
			
			2012-02-11:
				* Added DB::TYPE_ARRAY, which allows you to insert and read arrays with statements!
				* Improved error handling and increased some buffer sizes.
				* Added db_begin_transaction, db_end_transaction, and db_set_asynchronous.
				* Minor improvements here and there.
			
			2012-02-10:
				* A few bug fixes.
				* Added db_field_is_null, which returns true if the field is a true NULL value (not just an empty string).
				* Deprecated db_query_autofree.
			
			2012-02-09:
				* Defining WP_Hash prior to inclusion is no longer needed.
				* db_query now has an optional third argument - enable autorelease, which is
				  true by default.
				* Improved stability on freeing results:
					- Freeing results twice will not crash the server anymore - it will just generate
					  a warning.
					- Freeing a result that will be autoreleased will remove it from the autorelease pool.
				* The compiler will no longer wrongfully detect recursion inside this include.
				* Added db_query_int and db_query_float.
				* Added db_get_struct_info and db_set_struct_info; used mainly internally.
				* Added db_exec and db_insert.
				* Performance improvements!
			
			2012-02-08:
				* db_print_result will no longer go to the end of the result.
				* Added db_get_row_index, db_set_row_index, and db_rewind.
			
			2012-02-07:
				* db_get_field/db_get_field_assoc will not crash anymore with NULL values!
			
			2011-12-21:
				* Added two new types for stmt_bind_value:
					- DB::TYPE_WP_HASH: Puts a BLOB value of a whirlpool hash from the given string into the query (ex. x'FFAA4411...').
					- DB::TYPE_PLAYER_NAME: Puts a player name from the ID passed.
				  Note that DB_USE_WHIRLPOOL must be defined as true in order for DB::TYPE_WP_HASH to work.
				* Made some optimizations and minor bug fixes.
				* stmt_execute will now autofree the result unless the 3rd argument is false.
				* Added the preprocessor options DE_DEBUG (logs debug info) and DB_LOG_TO_CHAT (prints log messages to chat).
				* Improved the way results are dealt with internally to avoid crashes at all costs.
				* Added debug messages pretty much everywhere.
			
			2011-12-16:
				* Added db_open_persistent, db_is_persistent, db_is_valid_persistent, and db_free_persistent.
				* Added db_query_autofree.
				* Added db_get_field_int and db_get_field_float.
				* Corrected a few SQLite natives.
			
			2011-12-15:
				* Added stmt_autoclose.
				* Memory usage decreased significantly.
				* All functions now accept both packed and unpacked strings.
				* Minor bug fixes and optimizations.
			
			2011-12-14:
				* Initial release.
*/

#if !defined _samp_included
	#error Please include a_samp before sqlitei.
#endif

#if defined __fmt_funcinc && defined FormatSpecifier
	#error Please include sqlitei before formatex.
#endif

#if !defined HTTP
	#tryinclude <a_http>
#endif

#if !defined DB_MAX_PARAMS
	#define DB_MAX_PARAMS  32
#endif

#if !defined DB_MAX_STATEMENTS
	#define DB_MAX_STATEMENTS  16
#endif

#if !defined DB_MAX_STATEMENT_SIZE
	#define DB_MAX_STATEMENT_SIZE  1024
#endif

#if !defined DB_MAX_FIELDS
	#define DB_MAX_FIELDS  64
#endif

#if !defined DB_MAX_PERSISTENT_DATABASES
	#define DB_MAX_PERSISTENT_DATABASES  4
#endif

#if !defined DB_USE_WHIRLPOOL
	#define DB_USE_WHIRLPOOL  false
#endif

#if !defined DB_DEBUG
	#define DB_DEBUG  false
#endif

#if !defined DB_DEBUG_BACKTRACE_NOTICE
	#define DB_DEBUG_BACKTRACE_NOTICE  false
#endif

#if !defined DB_DEBUG_BACKTRACE_WARNING
	#define DB_DEBUG_BACKTRACE_WARNING  false
#endif

#if !defined DB_DEBUG_BACKTRACE_ERROR
	#define DB_DEBUG_BACKTRACE_ERROR  false
#endif

#if !defined DB_DEBUG_BACKTRACE_DEBUG
	#define DB_DEBUG_BACKTRACE_DEBUG  false
#endif

#if !defined DB_LOG_TO_CHAT
	#define DB_LOG_TO_CHAT  false
#endif

// "Namespace"
#define DB:: DB_

// Fix some natives ("const" keyword was missing)
native DB:db_open@(const szName[]) = db_open;
native DBResult:db_query@(DB:db, const szQuery[]) = db_query;
native db_get_field@(DBResult:dbresult, field, result[], maxlength) = db_get_field;
native db_get_field_assoc@(DBResult:dbresult, const field[], result[], maxlength) = db_get_field_assoc;
native db_close@(DB:db) = db_close;
native db_free_result@(DBResult:dbrResult) = db_free_result;

#define db_open        db_open@
#define db_query%1(    db_query_hook(_,
#define db_close       db_close_hook
#define db_free_result db_free_result_hook

#if DB::USE_WHIRLPOOL
	native DB::WP_Hash(buffer[], len, const str[]) = WP_Hash;
#endif

enum DB::e_SYNCHRONOUS_MODE {
	DB::SYNCHRONOUS_OFF,
	DB::SYNCHRONOUS_NORMAL,
	DB::SYNCHRONOUS_FULL
};

enum DBDataType: {
	DB::TYPE_NONE,
	DB::TYPE_NULL,
	DB::TYPE_INT,
	DB::TYPE_INTEGER = DB::TYPE_INT,
	DB::TYPE_UINT,
	DB::TYPE_UINTEGER = DB::TYPE_UINT,
	DB::TYPE_FLOAT,
	DB::TYPE_STRING,
	DB::TYPE_RAW_STRING,
	DB::TYPE_IDENTIFIER,
	
	// Special types
	
#if DB::USE_WHIRLPOOL
	DB::TYPE_WP_HASH,
#endif
	
	DB::TYPE_PLAYER_NAME,
	DB::TYPE_PLAYER_IP,
	DB::TYPE_ARRAY
};

#define INT:          DB::TYPE_INT,QQPA:
#define INTEGER:      DB::TYPE_INT,QQPA:
#define UINT:         DB::TYPE_UINT,QQPA:
#define UINTEGER:     DB::TYPE_UINT,QQPA:
#define FLOAT:        DB::TYPE_FLOAT,QQPA:
#define STRING:       DB::TYPE_STRING,QQPA:
#define RAW_STRING:   DB::TYPE_RAW_STRING,QQPA:
#define IDENTIFIER:   DB::TYPE_IDENTIFIER,QQPA:

#if DB::USE_WHIRLPOOL
	#define WP_HASH:  DB::TYPE_WP_HASH,QQPA:
#endif

#define PLAYER_NAME:  DB::TYPE_PLAYER_NAME,QQPA:
#define PLAYER_IP:    DB::TYPE_PLAYER_IP,QQPA:

enum DB::E_STATEMENT {
	// The ready-to-run query.
	e_szQuery[DB::MAX_STATEMENT_SIZE + 1],
	
	// Parameter count
	e_iParams,
	
	// The parameter types.
	DBDataType:e_aiParamTypes[DB::MAX_PARAMS],
	
	// Position of parameters in the query string.
	e_aiParamPositions[DB::MAX_PARAMS],
	
	// Length of parameters in the query string.
	e_aiParamLengths[DB::MAX_PARAMS],
	
	// Types of bound return fields
	DBDataType:e_aiFieldTypes[DB::MAX_FIELDS],
	
	// Sizes of bound result fields (used only for strings currently)
	e_aiFieldSizes[DB::MAX_FIELDS],
	
	// Addresses of bound result fields
	e_aiFieldAddresses[DB::MAX_FIELDS],
	
	// The database it was created for
	DB:e_dbDatabase,
	
	// The result (after executing)
	DBResult:e_dbrResult,
	
	// How many rows were fetched from the most recent result
	e_iFetchedRows,
	
	// Whether or not any leftover results should be automatically freed
	// Note that whenever a new result is put into e_dbrResult, the previous one is freed.
	bool:e_bAutoFreeResult
};

enum {
	SQLITE_LIMIT_LENGTH,
	SQLITE_LIMIT_SQL_LENGTH,
	SQLITE_LIMIT_COLUMN,
	SQLITE_LIMIT_EXPR_DEPTH,
	SQLITE_LIMIT_COMPOUND_SELECT,
	SQLITE_LIMIT_VDBE_OP,
	SQLITE_LIMIT_FUNCTION_ARG,
	SQLITE_LIMIT_ATTACHED,
	SQLITE_LIMIT_LIKE_PATTERN_LEN,
	SQLITE_LIMIT_VARIABLE_NUMBER,

	SQLITE_LIMIT_TRIGGER_DEPTH
};

// SQLite 3 C-struct offsets
enum e_SQLITE3 {
	     sqlite3_pVfs                [4],
	     sqlite3_iBackends           [4],
	     sqlite3_pBackends           [4],
	     sqlite3_iFlags              [4],
	     sqlite3_iOpenFlags          [4],
	
	     sqlite3_iErrorCode          [4],
	     sqlite3_iErrorMask          [4],
	bool:sqlite3_bAutoCommit         [1],
	     sqlite3_iTempStore          [1],
	bool:sqlite3_bMallocFailed       [1],
	
	     sqlite3_iDefaultLockMode    [1],
	     sqlite3_iNextAutovac        [1],
	bool:sqlite3_bSuppressErrors     [1],
	     sqlite3_iPad                [2],
	
	     sqlite3_iNextPagesize       [4],
	     sqlite3_iNumTables          [4],
	     sqlite3_pDefaultCollation   [4],
	     sqlite3_iLastRowid          [4],
	     sqlite3_iLastRowidUpperBytes[4],
	     sqlite3_iMagic              [4],
	     sqlite3_iNumChanges         [4],
	     sqlite3_iNumTotalChanges    [4],
	
	     sqlite3_aiLimits            [SQLITE_LIMIT_TRIGGER_DEPTH * 4],
	
	     sqlite3_aInitInfo           [12],
	     sqlite3_iNumExtensions      [4],
	     sqlite3_pExtensions         [4],
	     sqlite3_pVdbe               [4],
	     sqlite3_iActiveVdbeCount    [4],
	     sqlite3_iWritingVdbeCount   [4],
	
	     sqlite3_pTraceFunc          [4],
	     sqlite3_pTraceArg           [4],
	     sqlite3_pProfilingFunc      [4],
	     sqlite3_pProfilingArg       [4],
	     sqlite3_pCommitArg          [4],
	     sqlite3_pCommitCallback     [4],
	     sqlite3_pRollbackArg        [4],
	     sqlite3_pRollbackCallback   [4],
	     sqlite3_pUpdateArg          [4],
	     sqlite3_pUpdateCallback     [4],
	     sqlite3_pWalCallback        [4],
	     sqlite3_pWalArg             [4],
	     sqlite3_pCollNeeded         [4],
	     sqlite3_pCollNeeded16       [4],
	     sqlite3_pCollNeededArg      [4],
	     sqlite3_pError              [4],
	     sqlite3_pErrorMsg           [4],
	     sqlite3_pErrorMsg16         [4]
};

enum DB::E_PERSISTENT_DB {
	     e_szName[128 char],
	bool:e_bIsUsed,
	  DB:e_dbDatabase
};

static stock
	            gs_szBuffer[8192],
	            gs_aiCompressBuffer[3072],
	            gs_Statements[DBStatement:DB::MAX_STATEMENTS][DB::E_STATEMENT],
	            gs_iAutoFreeTimer = -1,
	            gs_iAutoFreeResultsIndex = 0,
	   DBResult:gs_adbrAutoFreeResults[1024],
	            gs_iAutoCloseStatementsIndex = 0,
	DBStatement:gs_astAutoCloseStatements[1024],
	            gs_PersistentDatabases[DB::MAX_PERSISTENT_DATABASES][DB::E_PERSISTENT_DB],
	            gs_iClosePersistentTimer = -1,
	            gs_iFreeStatementResultsTimer = -1,
	            gs_szNull[1] = {0}
;

const
	DBStatement:DB::INVALID_STATEMENT = DBStatement:-1,
	   DBResult:DB::INVALID_RESULT = DBResult:0
;

#if !DB_DEBUG
	#define DB_Debug(%1);
#endif

#if !DB_LOG_TO_CHAT
	#if DB_DEBUG_BACKTRACE_NOTICE
		#define DB_Notice(%1)    print(!"SQLitei Notice: " %1),PrintAmxBacktrace()
		#define DB_Noticef(%1)   printf("SQLitei Notice: " %1),PrintAmxBacktrace()
	#else
		#define DB_Notice(%1)    print(!"SQLitei Notice: " %1)
		#define DB_Noticef(%1)   printf("SQLitei Notice: " %1)
	#endif

	#if DB_DEBUG_BACKTRACE_WARNING
		#define DB_Warning(%1)   print(!"SQLitei Warning: " %1),PrintAmxBacktrace()
		#define DB_Warningf(%1)  printf("SQLitei Warning: " %1),PrintAmxBacktrace()
	#else
		#define DB_Warning(%1)   print(!"SQLitei Warning: " %1)
		#define DB_Warningf(%1)  printf("SQLitei Warning: " %1)
	#endif

	#if DB_DEBUG_BACKTRACE_ERROR
		#define DB_Error(%1)     print(!"SQLitei Error: " %1),PrintAmxBacktrace()
		#define DB_Errorf(%1)    printf("SQLitei Error: " %1),PrintAmxBacktrace()
	#else
		#define DB_Error(%1)     print(!"SQLitei Error: " %1)
		#define DB_Errorf(%1)    printf("SQLitei Error: " %1)
	#endif
	
	#if DB_DEBUG
		#if DB_DEBUG_BACKTRACE_DEBUG
			#define DB_Debug(%1)  printf("SQLitei Debug: " %1),PrintAmxBacktrace()
		#else
			#define DB_Debug(%1)  printf("SQLitei Debug: " %1)
		#endif
	#endif
#else
	new
		gs_szLogMessageBuffer[256]
	;
	
	#define DB_Notice(%1)    SendClientMessageToAll(0xFFFFFFFF, "SQLitei Notice: "  %1), print(!"SQLitei Notice: "  %1)
	#define DB_Warning(%1)   SendClientMessageToAll(0xEBBD17FF, "SQLitei Warning: " %1), print(!"SQLitei Warning: " %1)
	#define DB_Error(%1)     SendClientMessageToAll(0xCC0000FF, "SQLitei Error: "   %1), print(!"SQLitei Error: "   %1)
	#define DB_Noticef(%1)   format(gs_szLogMessageBuffer, sizeof(gs_szLogMessageBuffer), "SQLitei Notice: "  %1), print(gs_szLogMessageBuffer), SendClientMessageToAll(0xDDDDDDFF, gs_szLogMessageBuffer)
	#define DB_Warningf(%1)  format(gs_szLogMessageBuffer, sizeof(gs_szLogMessageBuffer), "SQLitei Warning: " %1), print(gs_szLogMessageBuffer), SendClientMessageToAll(0xEBBD17FF, gs_szLogMessageBuffer)
	#define DB_Errorf(%1)    format(gs_szLogMessageBuffer, sizeof(gs_szLogMessageBuffer), "SQLitei Error: "   %1), print(gs_szLogMessageBuffer), SendClientMessageToAll(0xCC0000FF, gs_szLogMessageBuffer)
	
	#if DB_DEBUG
		#define DB_Debug(%1)  format(gs_szLogMessageBuffer, sizeof(gs_szLogMessageBuffer), "SQLitei Debug: " %1), print(gs_szLogMessageBuffer), SendClientMessageToAll(0xFFFFFFFF, gs_szLogMessageBuffer)
	#endif
#endif

// Has to be defined after statement functions.
stock DBResult:db_query_hook(iTagOf3 = tagof(_bAutoRelease), DB:db, const szQuery[], {bool, DBDataType}:_bAutoRelease = true, {DBDataType, QQPA}:...);

// forward's
forward bool:db_set_row_index(DBResult:dbrResult, iRow);
forward bool:db_free_result_hook(DBResult:dbrResult);
forward bool:db_set_synchronous(DB:db, DB::e_SYNCHRONOUS_MODE:iValue);

forward DB::funcinc();
public DB::funcinc() {
	strcat(gs_szBuffer, "");
	strpack(gs_szBuffer, "");
	ispacked(gs_szBuffer);
	db_get_field(DBResult:0, 0, gs_szBuffer, 0);
	db_query(DB:0,"");
}

static stock DB::CompressArray(const aiArray[], iSize = sizeof(aiArray), aiOutput[]) {
	new
		iOutputIndex = 4,
		iValue,
		iMSB,
		iShift
	;
	
	// * 0b11000000 = Single byte, negative
	// * 0b10000000 = Single byte
	// * 0b01000000 = Multi-byte
	//   - 0b01000000 = More bytes
	//   - 0b11000000 = Last byte
	//   - 0b10000000 = Unused
	
	for (new i = 0; i < iSize; i++) {
		// Will the value fit in one byte?
		
		iValue = aiArray[i];
		
		if (-0b00111111 <= iValue <= 0b00111111) {
			// Is the value negative?
			
			if (iValue & 0x80000000) {
				// Set the "single byte, negative" bits on and put the value without its sign
				
				aiOutput{iOutputIndex++} = 0b11000000 | -iValue;
			} else {
				// Just put the value in with the "single byte" bit
				
				aiOutput{iOutputIndex++} = 0b10000000 |  iValue;
			}
		} else {
			// Figure out how many bits we'll have to write
			iMSB = DB::FindMSB(iValue) + 1;
			
			// Make iShift a multiple of 6 (if it isn't already)
			if ((iShift = iMSB % 6))
				aiOutput{iOutputIndex++} = 0b01000000 | (iValue >>> (iMSB - iShift) & ~(0xFFFFFFFF << iShift));
			
			iShift = iMSB - iShift;
			
			// Write bits out left-right
			while ((iShift -= 6) >= 0)
				aiOutput{iOutputIndex++} = 0b01000000 | (iValue >>> iShift & 0b00111111);
			
			// Change the "more bytes" bits into "last byte"
			aiOutput{iOutputIndex - 1} |= 0b11000000;
		}
	}
	
	// Put the number of bytes we just wrote into the first cell of the output
	aiOutput[0] = 0x80808080 | ((iOutputIndex & 0x1FE00000) << 3) | ((iOutputIndex & 0x3FC000) << 2) | ((iOutputIndex & 0x7F80) << 1) | (iOutputIndex & 0x7F);
	
	// Make sure the bytes in the last cell are 0
	aiOutput{iOutputIndex} = 0;
	
	iValue = iOutputIndex;
	
	while (++iOutputIndex % 4)
		aiOutput{iOutputIndex} = 0;
	
	// Return the number of bytes written (not counting the first 4)
	return iValue;
}

static stock DB::DecompressArray(const aiCompressedArray[], aiOutput[], iOutputSize = sizeof(aiOutput)) {
	new
		iBytes,
		iOutputIndex = 0
	;
	
	// Get the number of bytes to parse
	iBytes = aiCompressedArray[0];
	iBytes = ((iBytes & 0x7F000000) >>> 3) | ((iBytes & 0x7F0000) >>> 2) | ((iBytes & 0x7F00) >>> 1) | (iBytes & 0x7F);
	
	for (new i = 4; i < iBytes; i++) {
		// Out of slots?
		if (iOutputIndex >= iOutputSize) {
			DB::Error("(DB::DecompressArray) Compressed array is larger than decompress buffer.");
		
			break;
		}
		
		// Single byte?
		if ((aiCompressedArray{i} & 0b10000000)) {
			// Negative?
			if ((aiCompressedArray{i} & 0b01000000))
				aiOutput[iOutputIndex++] = -(aiCompressedArray{i} & 0b00111111);
			else
				aiOutput[iOutputIndex++] =  (aiCompressedArray{i} & 0b00111111);
		} else {
			// Multi byte; read the last bits
			aiOutput[iOutputIndex] = aiCompressedArray{i} & 0b00111111;
			
			// Keep reading bits while shifting the value to the left
			do {
				aiOutput[iOutputIndex] <<= 6;
				aiOutput[iOutputIndex]  |= aiCompressedArray{++i} & 0b00111111;
			} while ((aiCompressedArray{i} & 0b10000000) == 0);
			
			iOutputIndex++;
		}
	}
	
	return iOutputIndex;
}

static stock DB::memset(aArray[], iValue, iSize = sizeof(aArray)) {
	new
		iAddress
	;
	
	// Store the address of the array
	#emit LOAD.S.pri 12
	#emit STOR.S.pri iAddress
	
	// Convert the size from cells to bytes
	iSize *= 4;
	
	// Loop until there is nothing more to fill
	while (iSize > 0) {
		// I have to do this because the FILL instruction doesn't accept a dynamic number.
		if (iSize >= 4096) {
			#emit LOAD.S.alt iAddress
			#emit LOAD.S.pri iValue
			#emit FILL 4096
		
			iSize    -= 4096;
			iAddress += 4096;
		} else if (iSize >= 1024) {
			#emit LOAD.S.alt iAddress
			#emit LOAD.S.pri iValue
			#emit FILL 1024

			iSize    -= 1024;
			iAddress += 1024;
		} else if (iSize >= 256) {
			#emit LOAD.S.alt iAddress
			#emit LOAD.S.pri iValue
			#emit FILL 256

			iSize    -= 256;
			iAddress += 256;
		} else if (iSize >= 64) {
			#emit LOAD.S.alt iAddress
			#emit LOAD.S.pri iValue
			#emit FILL 64

			iSize    -= 64;
			iAddress += 64;
		} else if (iSize >= 16) {
			#emit LOAD.S.alt iAddress
			#emit LOAD.S.pri iValue
			#emit FILL 16

			iSize    -= 16;
			iAddress += 16;
		} else {
			#emit LOAD.S.alt iAddress
			#emit LOAD.S.pri iValue
			#emit FILL 4

			iSize    -= 4;
			iAddress += 4;
		}
	}
	
	// aArray is used, just not by its symbol name
	#pragma unused aArray
	
	return 1;
}

stock DB::LazyInitialize() {
	static
		bool:bIsInitialized = false
	;
	
	if (bIsInitialized)
		return;
	
	bIsInitialized = true;
	
	#if defined HTTP
		HTTP(0x7FEDCBA0, HTTP_GET, !"spelsajten.net/sqlitei_version.php?version=097", "", !"DB_VersionCheckReponse");
	#endif
}

#if defined HTTP
	forward DB::VersionCheckReponse(iIndex, iResponseCode, const szResponse[]);
	public DB::VersionCheckReponse(iIndex, iResponseCode, const szResponse[]) {
		if (iResponseCode == 200) {
			if (strval(szResponse) != 1) {
				print(!"\n\n\n  *******************************************************************");
				print(      !"  *   There's a new version version of SQLite Improved available!   *");
				print(      !"  * Please visit the topic at the SA-MP forums for the latest copy. *");
				print(      !"  *  Alternatively, get it here: http://spelsajten.net/sqlitei.inc  *");
				print(      !"  *******************************************************************\n\n\n");
			}
		}
	}
#endif

stock db_escape_string(szString[], const szEnclosing[] = "'", iSize = sizeof(szString)) {
	DB::LazyInitialize();
	
	new
		iPos
	;
	
	while (-1 != (iPos = strfind(szString, szEnclosing, _, iPos))) {
		strins(szString, szEnclosing, iPos, iSize);
		
		iPos += 2;
	}
}

stock bool:db_is_persistent(DB:db) {
	return !!(_:db & 0x80000000);
}

stock bool:db_is_valid_persistent(DB:db) {
	new
		iIndex = (_:db & 0x7FFFFFFF)
	;
	
	if ((0 <= iIndex < sizeof(gs_PersistentDatabases)) && gs_PersistentDatabases[iIndex][e_bIsUsed])
		return true;
	
	return false;
}

stock bool:db_is_table_exists(DB:db, const szTable[])
{
	new
		DBResult:dbrResult
	;
	
	format(gs_szBuffer, sizeof(gs_szBuffer), "SELECT name FROM sqlite_master WHERE type = 'table' AND tbl_name = '%s'", szTable);
	
	dbrResult = db_query(db, gs_szBuffer, false);
	
	if (db_num_fields(dbrResult)) {
		db_free_result(dbrResult);
		
		return true;
	}
	
	db_free_result(dbrResult);
	
	return false;
}

stock bool:db_rewind(DBResult:dbrResult) {
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_rewind) Invalid result given.");
		
		return false;
	}
	
	return db_set_row_index(dbrResult, 0);
}

stock bool:db_exec(DB:db, const szQuery[]) {
	new
		DBResult:dbrResult = db_query(db, szQuery, false)
	;
	
	if (dbrResult) {
		db_free_result(dbrResult);
		
		return true;
	}
	
	return false;
}

stock db_insert(DB:db, const szQuery[]) {
	new
		DBResult:dbrResult = db_query(db, szQuery, false)
	;
	
	if (dbrResult) {
		db_free_result(dbrResult);
		
		return db_last_insert_rowid(db);
	}
	
	return 0;
}

stock db_get_struct_info(DB:db, {_, e_SQLITE3}:iOffset) {
	if (db_is_persistent(db)) {
		if (!db_is_valid_persistent(db)) {
			DB::Errorf("(db_get_struct_info) Invalid persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
			
			return 0;
		}
		
		new iIndex = (_:db & 0x7FFFFFFF);
		
		db = gs_PersistentDatabases[iIndex][e_dbDatabase];
		
		if (!db) {
			DB::Errorf("(db_get_struct_info) Closed persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
			
			return 0;
		}
	}
	
	new
		iAddress = db_get_mem_handle(db & DB:0x7FFFFFFF) - DB::GetAmxBaseRelative() + iOffset,
		iValue
	;
	
	#emit LREF.S.pri  iAddress
	#emit STOR.S.pri  iValue
	
	return iValue;
}

stock db_set_struct_info(DB:db, {_, e_SQLITE3}:iOffset, iValue) {
	if (db_is_persistent(db)) {
		if (!db_is_valid_persistent(db)) {
			DB::Errorf("(db_set_struct_info) Invalid persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
			
			return 0;
		}
		
		new iIndex = (_:db & 0x7FFFFFFF);
		
		db = gs_PersistentDatabases[iIndex][e_dbDatabase];
		
		if (!db) {
			DB::Errorf("(db_set_struct_info) Closed persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
			
			return 0;
		}
	}
	
	new
		iAddress = db_get_mem_handle(db & DB:0x7FFFFFFF) - DB::GetAmxBaseRelative() + iOffset
	;
	
	#emit LOAD.S.pri  iValue
	#emit SREF.S.pri  iAddress
}

stock bool:db_set_row_index(DBResult:dbrResult, iRow) {
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_set_row_index) Invalid result given.");
		
		return false;
	}
	
	if (iRow < 0 || iRow >= db_num_rows(dbrResult))
		return false;
	
	new
		iAddress = db_get_result_mem_handle(dbrResult) - DB::GetAmxBaseRelative() + 16
	;
	
	#emit LOAD.S.pri  iRow
	#emit SREF.S.pri  iAddress
	
	return true;
}

stock db_get_row_index(DBResult:dbrResult) {
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_get_row_index) Invalid result given.");
		
		return 0;
	}
	
	new
		iAddress = db_get_result_mem_handle(dbrResult) - DB::GetAmxBaseRelative() + 16
	;
	
	#emit LREF.S.pri  iAddress
	#emit STACK       4
	#emit RETN
	
	return 0;
}

stock DB:db_open_persistent(const szName[]) {
	new
		DB:db,
		   iIndex = -1
	;
	
	for (new i = 0; i < sizeof(gs_PersistentDatabases); i++) {
		if (!gs_PersistentDatabases[i][e_bIsUsed]) {
			iIndex = i;
			
			break;
		}
	}
	
	if (iIndex == -1) {
		DB::Error("(db_open_persistent) Unable to find a free slot.");
		
		return DB:-1;
	}
	
	if (!(db = db_open(szName))) {
		DB::Error("(db_open_persistent) Unable to open the database.");
		
		return DB:-1;
	}
	
	gs_PersistentDatabases[iIndex][e_bIsUsed]    = true;
	gs_PersistentDatabases[iIndex][e_dbDatabase] = db;
	gs_PersistentDatabases[iIndex][e_szName][0]  = 0;
	
	if (gs_iClosePersistentTimer == -1)
		gs_iClosePersistentTimer = SetTimer("db_close_persistent", 0, false);
	
	strpack(gs_PersistentDatabases[iIndex][e_szName], szName, _:e_bIsUsed);
	
	DB::Debug("(db_open_persistent=%d) Opened new persistent DB.", iIndex);
	
	return DB:(iIndex | 0x80000000);
}

stock db_close_hook(DB:db) {
	new
		iIndex
	;
	
	if (db_is_persistent(db)) {
		if (!db_is_valid_persistent(db)) {
			DB::Errorf("(db_close) Invalid persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
			
			return;
		}
		
		iIndex = (_:db & 0x7FFFFFFF);
		
		if (gs_PersistentDatabases[iIndex][e_dbDatabase]) {
			db_close@(gs_PersistentDatabases[iIndex][e_dbDatabase]);
			
			gs_PersistentDatabases[iIndex][e_dbDatabase] = DB:0;
			
			DB::Debug("(db_close) Closed the DB for the persistent DB with index %d.", iIndex);
		} else {
			DB::Debug("(db_close) Would close the DB for the persistent DB with index %d, but it already is.", iIndex);
		}
	} else {
		db_close@(db);
	}
}

stock db_query_int(DB:db, const szQuery[], iField = 0) {
	new
		DBResult:dbrResult = db_query(db, szQuery, false)
	;

	if (!dbrResult) {
		strunpack(gs_szBuffer, szQuery);
		
		DB::Warningf("(db_query_int) Query failed: \"%s\".", gs_szBuffer);
		
		return 0;
	}

	db_get_field(dbrResult, iField, gs_szBuffer, sizeof(gs_szBuffer) - 1);

	db_free_result(dbrResult);

	return strval(gs_szBuffer);
}

stock Float:db_query_float(DB:db, const szQuery[], iField = 0) {
	new
		DBResult:dbrResult = db_query(db, szQuery, false)
	;

	if (!dbrResult) {
		strunpack(gs_szBuffer, szQuery);
		
		DB::Warningf("(db_query_float) Query failed: \"%s\".", gs_szBuffer);
		
		return 0.0;
	}

	db_get_field(dbrResult, iField, gs_szBuffer, sizeof(gs_szBuffer) - 1);

	db_free_result(dbrResult);

	return floatstr(gs_szBuffer);
}

stock db_is_result_freed(DBResult:dbrResult) {
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_is_result_freed) Invalid result given.");
		
		return true;
	}

	return db_get_result_mem_handle(dbrResult) == 0;
}

stock bool:db_free_result_hook(DBResult:dbrResult) {
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_free_result_hook) Invalid result given.");
		
		return false;
	}
	
	DB::Debug("(db_free_result) Freeing 0x%04x%04x.", _:dbrResult >>> 16, _:dbrResult & 0xFFFF);
	
	for (new i = gs_iAutoFreeResultsIndex; i--; ) {
		if (gs_adbrAutoFreeResults[i] == dbrResult) {
			gs_adbrAutoFreeResults[i] = DBResult:0;
			
			DB::Debug("(db_free_result) The result being freed was inside the autorelease pool.");
		}
	}

	new
		iFreeTestAddress = db_get_result_mem_handle(dbrResult) - DB::GetAmxBaseRelative() + 16,
		iData
	;
	
	#emit LREF.S.pri  iFreeTestAddress
	#emit STOR.S.pri  iData
	
	if (iData != 0xFFFFFFFF) {
		new
			iResultAddress = db_get_result_mem_handle(dbrResult) - DB::GetAmxBaseRelative(),
			iAddress,
			iRows,
			iCols,
			iDataAddress,
			iOffset,
			iNullAddress
		;

		#emit CONST.pri   gs_szNull
		#emit STOR.S.pri  iNullAddress
		
		iNullAddress +=  DB::GetAmxBaseRelative();
		
		iAddress = iResultAddress;

		#emit LREF.S.pri  iAddress
		#emit STOR.S.pri  iRows
		
		iAddress += 4;

		#emit LREF.S.pri  iAddress
		#emit STOR.S.pri  iCols
		
		iAddress += 4;

		#emit LREF.S.pri  iAddress
		#emit STOR.S.pri  iDataAddress
		
		iDataAddress -= DB::GetAmxBaseRelative();
		
		iOffset = (iCols + iRows * iCols) * 4 - 4;
		
		while (iOffset >= 0) {
			iAddress = iDataAddress + iOffset;
			
			#emit LREF.S.pri  iAddress
			#emit STOR.S.pri  iAddress
			
			if (iAddress == iNullAddress) {
				iAddress = iDataAddress + iOffset;
				
				#emit CONST.pri   0
				#emit SREF.S.pri  iAddress
			}
			
			iOffset -= 4;
		}
		
		db_free_result@(dbrResult);
		
		#emit CONST.pri   0xFFFFFFFF
		#emit SREF.S.pri  iFreeTestAddress
		
		return true;
	} else {
		DB::Warning("(db_free_result) Attempted to free an already freed result; crash prevented.");
	}
	
	return false;
}

stock db_free_persistent(DB:db) {
	new
		iIndex
	;
	
	if (!db_is_valid_persistent(db)) {
		DB::Errorf("(db_free_persistent) Invalid persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
		
		return;
	}
	
	iIndex = (_:db & 0x7FFFFFFF);
	
	if (gs_PersistentDatabases[iIndex][e_dbDatabase]) {
		db_close@(gs_PersistentDatabases[iIndex][e_dbDatabase]);
		
		gs_PersistentDatabases[iIndex][e_dbDatabase] = DB:0;
		
		DB::Debug("(db_free_persistent:%d) Closed and freed the persistent DB.", iIndex);
	} else {
		DB::Debug("(db_free_persistent:%d) Freed the already closed persistent DB.", iIndex);
	}
	
	gs_PersistentDatabases[iIndex][e_bIsUsed] = false;
}

stock db_changes(DB:db) {
	DB::LazyInitialize();
	
	if (!db) {
		DB::Error("(db_changes) Invalid database handle given.");
		
		return 0;
	}
	
	return db_get_struct_info(db, sqlite3_iNumChanges);
}

stock db_begin_transaction(DB:db)
	return db_exec(db, !"BEGIN");

stock db_end_transaction(DB:db)
	return db_exec(db, !"COMMIT");

stock db_set_asynchronous(DB:db, bool:bSet = true) {
	db_set_synchronous(DB:db, bSet ? DB::SYNCHRONOUS_OFF : DB::SYNCHRONOUS_FULL);
}

stock bool:db_set_synchronous(DB:db, DB::e_SYNCHRONOUS_MODE:iValue) {
	if (0 <= _:iValue <= 2) {
		format(gs_szBuffer, sizeof(gs_szBuffer), "PRAGMA synchronous = %d", _:iValue);
	
		return db_exec(db, gs_szBuffer);
	} else
		return false;
}

stock bool:db_attach_memory_db(DB:db, const szName[]) {
	strunpack(gs_szBuffer, szName);
	
	db_escape_string(gs_szBuffer, "\"");
	
	format(gs_szBuffer, sizeof(gs_szBuffer), "ATTACH DATABASE ':memory:' AS \"%s\"", gs_szBuffer);
	
	return db_exec(db, gs_szBuffer);
}

stock bool:db_detach_memory_db(DB:db, const szName[]) {
	strunpack(gs_szBuffer, szName);
	
	db_escape_string(gs_szBuffer, "\"");
	
	format(gs_szBuffer, sizeof(gs_szBuffer), "DETACH DATABASE \"%s\"", gs_szBuffer);
	
	return db_exec(db, gs_szBuffer);
}

stock db_total_changes(DB:db) {
	DB::LazyInitialize();

	if (!db) {
		DB::Error("(db_changes) Invalid database handle given.");

		return 0;
	}

	return db_get_struct_info(db, sqlite3_iNumTotalChanges);
}

stock db_last_insert_rowid(DB:db) {
	DB::LazyInitialize();
	
	if (!db) {
		DB::Error("(db_last_insert_rowid) Invalid database handle given.");
		
		return 0;
	}
	
	return db_get_struct_info(db, sqlite3_iLastRowid);
}

stock db_field_is_null(DBResult:dbrResult, iField) {
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_field_is_null) Invalid result given.");
	
		return false;
	}
	
	new
		iAddress = db_get_result_mem_handle(dbrResult) - DB::GetAmxBaseRelative(),
		iCols,
		iCurrentRow
	;
	
	iAddress += 4;

	#emit LREF.S.pri  iAddress
	#emit STOR.S.pri  iCols
	
	if (iField >= iCols)
		return true;
	
	iAddress += 8;

	#emit LREF.S.pri  iAddress
	#emit STOR.S.pri  iCurrentRow
	
	iAddress -= 4;
	
	#emit LREF.S.pri  iAddress
	#emit STOR.S.pri  iAddress
	
	iAddress -= DB::GetAmxBaseRelative();
	iAddress += (iCols + iCols * iCurrentRow + iField) * 4;
	
	#emit LREF.S.pri  iAddress
	#emit CONST.alt   gs_szNull
	#emit SUB
	#emit STOR.S.pri  iAddress
	
	iAddress -= DB::GetAmxBaseRelative();
	
	return !iAddress;
}

stock db_autofree_result(DBResult:dbrResult) {
	DB::LazyInitialize();
	
	if (dbrResult == DB::INVALID_RESULT) {
		DB::Notice("(db_autofree_result) Invalid result given.");
		
		return;
	}
	
	if (gs_iAutoFreeTimer == -1)
		gs_iAutoFreeTimer = SetTimer("db_drain_autofree_pool", 0, false);
	
	if (gs_iAutoFreeResultsIndex + 1 >= sizeof(gs_adbrAutoFreeResults)) {
		DB::Warning("(db_autofree_result) The autofree pool is full!");
		
		return;
	}
	
	gs_adbrAutoFreeResults[gs_iAutoFreeResultsIndex] = dbrResult;
	
	DB::Debug("(db_autofree_result) Will autofree 0x%04x%04x.", _:dbrResult >>> 16, _:dbrResult & 0xFFFF);
	
	gs_iAutoFreeResultsIndex++;
}

stock DBStatement:db_prepare(DB:db, const szQuery[]) {
	DB::LazyInitialize();
	
	new
		DBStatement:stStatement = DB::INVALID_STATEMENT,
		iPos,
		i,
		iLength
	;
	
	if (!db) {
		DB::Error("(db_prepare) Invalid database handle given.");
		
		return DB::INVALID_STATEMENT;
	}
	
	// Pretty useless to prepare empty queries.
	if (!(iLength = strlen(szQuery))) {
		DB::Error("(db_prepare) Empty query.");
		
		return DB::INVALID_STATEMENT;
	}
	
	if (iLength char > DB::MAX_STATEMENT_SIZE) {
		DB::Error("(db_prepare) The query is too long. Increase DB_MAX_STATEMENT_SIZE.");
		
		return DB::INVALID_STATEMENT;
	}
	
	// Find an empty slot in gs_Statements.
	for (i = 0; i < sizeof(gs_Statements); i++) {
		if (!gs_Statements[DBStatement:i][e_dbDatabase]) {
			stStatement = DBStatement:i;
			
			break;
		}
	}
	
	if (stStatement == DB::INVALID_STATEMENT) {
		DB::Error("(db_prepare) Unable to find an empty slot for the statement. Increase DB_MAX_STATEMENTS.");
		
		return DB::INVALID_STATEMENT;
	}
	
	gs_Statements[stStatement][e_dbDatabase] = db;
	gs_Statements[stStatement][e_dbrResult] = DB::INVALID_RESULT;
	gs_Statements[stStatement][e_iFetchedRows] = 0;
	
	// Make sure no parameters are initialized.
	for (i = 0; i < DB::MAX_PARAMS; i++)
		gs_Statements[stStatement][e_aiParamTypes][i] = DB::TYPE_NONE;
	
	// Make sure no return fields are initialized.
	for (i = 0; i < DB::MAX_FIELDS; i++)
		gs_Statements[stStatement][e_aiFieldTypes][i] = DB::TYPE_NONE;
	
	iPos = -1;
	i = 0;
	
	// Find all parameters
	while (-1 != (iPos = strfind(szQuery, !"?", _, ++iPos))) {
		gs_Statements[stStatement][e_aiParamPositions][i] = iPos;
		gs_Statements[stStatement][e_aiParamLengths][i] = 1;
		
		if (++i >= DB::MAX_PARAMS) {
			DB::Error("(db_prepare) Parameter limit exceeded. Increase DB_MAX_PARAMS.");
			
			return DB::INVALID_STATEMENT;
		}
	}
	
	gs_Statements[stStatement][e_iParams] = i;
	
	gs_Statements[stStatement][e_szQuery][0] = 0;
	
	if (ispacked(szQuery)) {
#if DB_DEBUG
		strunpack(gs_szBuffer, szQuery);
		
		DB::Debug("(db_prepare=%d) Preparing statement with %d params: %s", _:stStatement, i, gs_szBuffer);
#endif
		
		strcat(gs_Statements[stStatement][e_szQuery], szQuery, DB::MAX_STATEMENT_SIZE);
	} else {
		DB::Debug("(db_prepare=%d) Preparing statement with %d params: %s", _:stStatement, i, szQuery);
		
		strpack(gs_Statements[stStatement][e_szQuery], szQuery, DB::MAX_STATEMENT_SIZE);
	}
	
	return stStatement;
}

stock bool:stmt_bind_value(&DBStatement:stStatement, iParam, DBDataType:iType, {Float, _}:...) {
	DB::LazyInitialize();
	
	new
		     iLengthDiff,
		     iLength,
		bool:bIsPacked,
		     iNumArgs
	;
	
	#emit LOAD.S.pri  8
	#emit SHR.C.pri   2
	#emit STOR.S.pri  iNumArgs
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Warningf("(stmt_bind_value) Invalid statement passed (%d).", _:stStatement);
		
		return false;
	}
	
	if (iParam >= gs_Statements[stStatement][e_iParams]) {
		DB::Warningf("(stmt_bind_value) Parameter index larger than number of parameters (%d > %d).", iParam, gs_Statements[stStatement][e_iParams]);
		
		return false;
	}
	
	// Fill gs_szBuffer with the new contents.
	gs_szBuffer[0] = 0;
	
	switch (iType) {
		case DB::TYPE_NULL:
			goto default_case;
		
		case DB::TYPE_INT: {
			new
				iArgValue = getarg(3)
			;
			
			if (iArgValue == cellmin)
				gs_szBuffer = !"-2147483648";
			else
				format(gs_szBuffer, sizeof(gs_szBuffer), "%d", getarg(3));
		}
		
		case DB::TYPE_UINT: {
			new
				iArgValue = getarg(3)
			;
			
			if (!iArgValue) {
				gs_szBuffer = !"0";
			} else {
				new
					j = 11
				;
				
				gs_szBuffer = "00000000000";
				
				while (iArgValue) {
					// gs_szBuffer[--j]
					#emit CONST.alt   gs_szBuffer // alt = *gs_szBuffer
					#emit LOAD.S.pri  j           // pri = j
					#emit DEC.pri                 // pri -= 1
					#emit STOR.S.pri  j           // j = pri
					#emit IDXADDR                 // pri = alt + j * 4
					#emit PUSH.pri                // Store for later

					// Now do an unsigned divide on iArgValue then use both the quotient and remainder!
					#emit LOAD.S.pri  iArgValue // pri = iArgValue
					#emit CONST.alt   10
					#emit UDIV                  // pri = iArgValue / 10; alt = iArgValue % 10
					#emit STOR.S.pri  iArgValue // iArgValue = pri
					#emit CONST.pri   '0'
					#emit ADD                   // pri = '0' + (iArgValue % 10)
					#emit POP.alt               // alt = gs_szBuffer[j]
					#emit STOR.I                // gs_szBuffer[j] = pri
				}
			
				strpack(gs_szBuffer, gs_szBuffer[j]);
			}
		}
		
		case DB::TYPE_FLOAT:
			format(gs_szBuffer, sizeof(gs_szBuffer), "%f", getarg(3));
		
		case DB::TYPE_STRING: {
			new iSize = sizeof(gs_szBuffer) - 3;
			
			//strpack(dest[], const source[], maxlength = sizeof dest)
			#emit PUSH.S    iSize
			#emit PUSH.S    24 // arg 3
			#emit PUSH.C    gs_szBuffer
			#emit PUSH.C    12
			#emit SYSREQ.C  strpack
			#emit STACK     16
			
			db_escape_string(gs_szBuffer, "'", sizeof(gs_szBuffer) - 1);
			
			strins(gs_szBuffer, !"'", 0);
			strcat(gs_szBuffer, !"'");
		}
		
#if DB::USE_WHIRLPOOL
		case DB::TYPE_WP_HASH: {
			strcat(gs_szBuffer, "x'");
			
			DB::getstringarg(gs_szBuffer[2], 3, sizeof(gs_szBuffer) - 2);
			
			DB::WP_Hash(gs_szBuffer[2], sizeof(gs_szBuffer) - 2, gs_szBuffer[2]);
			
			strcat(gs_szBuffer, "'");
		}
#endif
		
		case DB::TYPE_PLAYER_NAME: {
			new
				iPlayer = getarg(3)
			;
			
			if (!(0 <= iPlayer < MAX_PLAYERS) || !IsPlayerConnected(iPlayer)) {
				DB::Warningf("(stmt_bind_value) Invalid player ID passed for DB::TYPE_PLAYER_NAME (%d).", iPlayer);
				
				strcat(gs_szBuffer, !"''");
			} else {
				gs_szBuffer[0] = '\'';
				
				GetPlayerName(iPlayer, gs_szBuffer[1], sizeof(gs_szBuffer) - 1);
				
				db_escape_string(gs_szBuffer[1], "'", sizeof(gs_szBuffer) - 1);
				
				strcat(gs_szBuffer, "'");
			}
		}
		
		case DB::TYPE_PLAYER_IP: {
			new
				iPlayer = getarg(3)
			;
			
			if (!(0 <= iPlayer < MAX_PLAYERS) || !IsPlayerConnected(iPlayer)) {
				DB::Warningf("(stmt_bind_value) Invalid player ID passed for DB::TYPE_PLAYER_IP (%d).", iPlayer);
				
				strcat(gs_szBuffer, !"''");
			} else {
				gs_szBuffer[0] = '\'';
				
				GetPlayerIp(iPlayer, gs_szBuffer[1], sizeof(gs_szBuffer) - 1);
				
				db_escape_string(gs_szBuffer[1], "'", sizeof(gs_szBuffer) - 1);
				
				strcat(gs_szBuffer, "'");
			}
		}
		
		// http://www.sqlite.org/lang_keywords.html
		case DB::TYPE_IDENTIFIER: {
			bIsPacked = !!DB::isargpacked(3);
			
			if (!bIsPacked)
				gs_szBuffer[0] = '"';
			
			DB::getstringarg(gs_szBuffer[bIsPacked ? 0 : 1], 3, sizeof(gs_szBuffer) - 3);
			
			db_escape_string(gs_szBuffer[bIsPacked ? 0 : 1], "\"", sizeof(gs_szBuffer) - 1);
			
			if (bIsPacked)
				strins(gs_szBuffer, "\"", 0);
			
			strcat(gs_szBuffer, "\"");
		}
		
		case DB::TYPE_RAW_STRING:
			DB::getstringarg(gs_szBuffer, 3);
		
		case DB::TYPE_ARRAY: {
			// DB::CompressArray(const aiArray[], iSize = sizeof(aiArray), aiOutput[])
			
			if (iNumArgs != 5) {
				DB::Error("(stmt_bind_value) Invalid argument count. DB::TYPE_ARRAY requires an additional argument containing the array's length.");
				
				return false;
			}
			
			new
				iCompressedSize,
				i
			;
			
			// Push the output array
			#emit PUSH.C      gs_aiCompressBuffer
			
			// Push the size
			#emit LREF.S.pri  28 // 12 + 4 cells
			#emit PUSH.pri
			
			// Push the input array
			#emit PUSH.S      24
			
			// Push the argument count
			#emit PUSH.C      12
			
			// Push the return address
			#emit LCTRL       6
			#emit ADD.C       28
			#emit PUSH.pri
			
			// Call DB::CompressArray
			#emit CONST.pri   DB_CompressArray
			#emit SCTRL       6
			
			// Store the return value
			#emit STOR.S.pri  iCompressedSize
			
			iCompressedSize = (iCompressedSize + 3) / 4;
			
			gs_szBuffer[0] = 'x';
			gs_szBuffer[1] = '\'';
			
			if ((iCompressedSize << 3) + 1 < sizeof(gs_szBuffer)) {
				for (i = 0; i < iCompressedSize; i++)
					format(gs_szBuffer[2 + (i << 3)], sizeof(gs_szBuffer) - (2 + (i << 3)), "%01x%07x", gs_aiCompressBuffer[i] >>> 28, gs_aiCompressBuffer[i] & 0x0FFFFFFF);
			} else {
				strcat(gs_szBuffer, "00");
				
				DB::Errorf("(stmt_bind_value) Unable to compress the array; out of buffer size (has %d, needs %d).", sizeof(gs_szBuffer), (iCompressedSize << 3) + 2);
				
				return false;
			}
			
			strcat(gs_szBuffer, "'");
		}	
		
		default: {
default_case:
			
			strcat(gs_szBuffer, "NULL");
		}
	}
	
	iLength = strlen(gs_szBuffer);
	
	iLengthDiff = iLength - gs_Statements[stStatement][e_aiParamLengths][iParam];
	
	// Adjust the position of any params after the one being modified.
	for (new i = iParam + 1; i < gs_Statements[stStatement][e_iParams]; i++)
		gs_Statements[stStatement][e_aiParamPositions][i] += iLengthDiff;
	
	// Delete the old parameter from the query.
	strdel(gs_Statements[stStatement][e_szQuery], gs_Statements[stStatement][e_aiParamPositions][iParam], gs_Statements[stStatement][e_aiParamPositions][iParam] + gs_Statements[stStatement][e_aiParamLengths][iParam]);
	
	// Make sure we have enough space.
	if ((strlen(gs_Statements[stStatement][e_szQuery]) + iLength) char > DB::MAX_STATEMENT_SIZE) {
		DB::Error("(stmt_bind_value) Buffer overflow. Increase DB_MAX_STATEMENT_SIZE.");
		
		stmt_close(stStatement);
		
		return false;
	}
	
	// Insert the new parameter.
	strins(gs_Statements[stStatement][e_szQuery], gs_szBuffer, gs_Statements[stStatement][e_aiParamPositions][iParam], DB::MAX_STATEMENT_SIZE);
	
#if DB_DEBUG
	if (ispacked(gs_szBuffer))
		strunpack(gs_szBuffer, gs_szBuffer);
	
	DB::Debug("(stmt_bind_value:%d) Inserted new value for parameter %d at %d: %s", _:stStatement, iParam, gs_Statements[stStatement][e_aiParamPositions][iParam], gs_szBuffer);
#endif
	
	gs_Statements[stStatement][e_aiParamLengths][iParam] = iLength;
	gs_Statements[stStatement][e_aiParamTypes][iParam] = iType;
	
	return true;
}

stock stmt_bind_result_field(&DBStatement:stStatement, iField, DBDataType:iType, {Float, _}:...) {
	DB::LazyInitialize();
	
	new
		iAddress,
		iSize,
		iNumArgs
	;
	
	#emit LOAD.S.pri  8
	#emit SHR.C.pri   2
	#emit STOR.S.pri  iNumArgs

	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Warningf("(stmt_bind_result_field) Invalid statement passed (%d).", _:stStatement);

		return;
	}

	if (iField < 0) {
		DB::Errorf("(stmt_bind_result_field) Negative field index (%d).", iField);

		return;
	}
	
	switch (iType) {
		case DB::TYPE_STRING,
		     DB::TYPE_RAW_STRING,
		     DB::TYPE_IDENTIFIER,
		     DB::TYPE_ARRAY: {
			if (iNumArgs != 5) {
				DB::Error("(stmt_bind_result_field) Invalid number of arguments passed. Strings and arrays require an additional argument containing the string size.");

				return;
			}
			
			iSize = getarg(4);
		}
		
		case DB::TYPE_NONE: {
			gs_Statements[stStatement][e_aiFieldTypes][iField] = DB::TYPE_NONE;
			
			return;
		}
		
		default: {
			if (iNumArgs != 4) {
				DB::Error("(stmt_bind_result_field) Invalid number of arguments passed.");

				return;
			}
			
			iSize = 1;
		}
	}
	
	if (iField >= DB::MAX_FIELDS) {
		DB::Warningf("(stmt_bind_result_field) Field index larger than max number of fields (%d > %d). Increase DB_MAX_FIELDS.", iField, DB::MAX_FIELDS);
		
		return;
	}
	
	// Without this, STOR.S.pri doesn't seem to do what it should.
	iAddress = 0;
	
	#emit LOAD.S.pri 24
	#emit STOR.S.pri iAddress
	
	gs_Statements[stStatement][e_aiFieldTypes][iField] = iType;
	gs_Statements[stStatement][e_aiFieldAddresses][iField] = iAddress;
	gs_Statements[stStatement][e_aiFieldSizes][iField] = iSize;
	
	DB::Debug("(stmt_bind_result_field:%d) Bound result field %d (type %d) to variable 0x%04x%04x.", _:stStatement, iField, _:iType, iAddress >>> 16, iAddress & 0xFFFF);
}

stock bool:stmt_skip_row(&DBStatement:stStatement) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Errorf("(stmt_skip_row) Invalid statement passed (%d).", _:stStatement);
		
		return false;
	}
	
	if (gs_Statements[stStatement][e_dbrResult] == DB::INVALID_RESULT) {
		if (!gs_Statements[stStatement][e_iFetchedRows])
			DB::Warning("(stmt_skip_row) Statement has no result.");
		
		return false;
	}
	
	gs_Statements[stStatement][e_iFetchedRows]++;
	
	if (!db_next_row(gs_Statements[stStatement][e_dbrResult])) {
		db_free_result(gs_Statements[stStatement][e_dbrResult]);
		
		gs_Statements[stStatement][e_dbrResult] = DB::INVALID_RESULT;
		
		DB::Debug("(stmt_skip_row:%d) Skipped row and freed result.", _:stStatement);
	} else {
		DB::Debug("(stmt_skip_row:%d) Skipped row.", _:stStatement);
	}
	
	return true;
}

stock bool:stmt_fetch_row(&DBStatement:stStatement) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Errorf("(stmt_fetch_row) Invalid statement passed (%d).", _:stStatement);
		
		return false;
	}
	
	if (gs_Statements[stStatement][e_dbrResult] == DB::INVALID_RESULT) {
		if (!gs_Statements[stStatement][e_iFetchedRows])
			DB::Warning("(stmt_fetch_row) Statement has no result.");
		
		return false;
	}

	if (!stmt_rows_left(stStatement)) {
		DB::Debug("(stmt_fetch_row) No rows left.");

		return false;
	}
	
	if (!db_num_rows(gs_Statements[stStatement][e_dbrResult])) {
		DB::Debug("(stmt_fetch_row) Freed previous result.");
		
		db_free_result(gs_Statements[stStatement][e_dbrResult]);
		
		gs_Statements[stStatement][e_dbrResult] = DB::INVALID_RESULT;
	
		return false;
	}
	
	new
		iFields = db_num_fields(gs_Statements[stStatement][e_dbrResult]),
		iAddress,
		xValue,
		iCount
	;
	
	if (iFields > DB::MAX_FIELDS) {
		DB::Warning("(stmt_bind_result_field) There are more fields returned than DB_MAX_FIELDS.");
		
		iFields = DB::MAX_FIELDS;
	}
	
	gs_Statements[stStatement][e_iFetchedRows]++;
	
	for (new iField = 0; iField < iFields; iField++) {
		if (gs_Statements[stStatement][e_aiFieldTypes][iField] == DB::TYPE_NONE)
			continue;
		
		iCount++;
		
		switch (gs_Statements[stStatement][e_aiFieldTypes][iField]) {
			case DB::TYPE_NONE,
			     DB::TYPE_NULL:
				continue;
			
			case DB::TYPE_INT,
			     DB::TYPE_UINT,
			     DB::TYPE_FLOAT: {
				db_get_field(gs_Statements[stStatement][e_dbrResult], iField, gs_szBuffer, sizeof(gs_szBuffer) - 1);
				
				iAddress = gs_Statements[stStatement][e_aiFieldAddresses][iField];
				xValue = (gs_Statements[stStatement][e_aiFieldTypes][iField] != DB::TYPE_FLOAT) ? strval(gs_szBuffer) : _:floatstr(gs_szBuffer);

				#emit LOAD.S.pri xValue
				#emit SREF.S.pri iAddress
			}
			
			// Assumes the field is a string containing a player name.
			// Gives the ID of a connected play with that name, otherwise INVALID_PLAYER_ID.
			case DB::TYPE_PLAYER_NAME: {
				static
					s_szName[MAX_PLAYER_NAME]
				;
				
				xValue = INVALID_PLAYER_ID;
				
				for (new i = 0, l = GetMaxPlayers(); i < l; i++) {
					if (!IsPlayerConnected(i))
						continue;
					
					GetPlayerName(i, s_szName, sizeof(s_szName));
					db_get_field(gs_Statements[stStatement][e_dbrResult], iField, gs_szBuffer, sizeof(gs_szBuffer) - 1);
					
					if (!strcmp(gs_szBuffer, s_szName, true)) {
						xValue = i;
						
						break;
					}
				}
				
				iAddress = gs_Statements[stStatement][e_aiFieldAddresses][iField];

				#emit LOAD.S.pri xValue
				#emit SREF.S.pri iAddress
			}
			
			case DB::TYPE_STRING,
			     DB::TYPE_RAW_STRING,
			     DB::TYPE_IDENTIFIER: {
				new
					DBResult:dbrResult,
					         iSize
				;
				
				static const
					sc_szFormatString[] = "%s"
				;
				
				iAddress  = gs_Statements[stStatement][e_aiFieldAddresses][iField];
				dbrResult = gs_Statements[stStatement][e_dbrResult];
				iSize     = gs_Statements[stStatement][e_aiFieldSizes][iField];
				
				#emit PUSH.S    iSize
				#emit PUSH.S    iAddress
				#emit PUSH.S    iField
				#emit PUSH.S    dbrResult
				#emit PUSH.C    16
				#emit SYSREQ.C  db_get_field
				#emit STACK     20
				
				// Fix a bug with UTF-8 characters
				// For example, 'ö' would become 0xFFFFFFC3 instead of 0xC3
				#emit PUSH.S     iAddress
				#emit PUSH.C     sc_szFormatString
				#emit PUSH.S     iSize
				#emit PUSH.S     iAddress
				#emit PUSH.C     16
				#emit SYSREQ.C   format
				#emit STACK      20
			}
			
			case DB::TYPE_ARRAY: {
				// DecompressArray(const aiCompressedArray[], aiOutput[], iOutputSize = sizeof(aiOutput))
				
				db_get_field(gs_Statements[stStatement][e_dbrResult], iField, gs_szBuffer, sizeof(gs_szBuffer) - 1);
				
				format(gs_szBuffer, sizeof(gs_szBuffer), "%s", gs_szBuffer);
				strpack(gs_szBuffer, gs_szBuffer);
				
				new
					iOutputSize = gs_Statements[stStatement][e_aiFieldSizes][iField],
					iDecompressedCells
				;
				
				iAddress = gs_Statements[stStatement][e_aiFieldAddresses][iField];
				
				// Push the output array size
				#emit PUSH.S      iOutputSize

				// Push the output array
				#emit PUSH.S      iAddress

				// Push the input array
				#emit PUSH.C      gs_szBuffer

				// Push the argument count
				#emit PUSH.C      12

				// Push the return address
				#emit LCTRL       6
				#emit ADD.C       28
				#emit PUSH.pri

				// Call DB::DecompressArray
				#emit CONST.pri   DB_DecompressArray
				#emit SCTRL       6
				
				// Store the return address
				#emit STOR.S.pri  iDecompressedCells
				
				// If there are more cells in the array, fill them with 0
				if (iOutputSize > iDecompressedCells) {
					DB::Noticef("(stmt_fetch_row:%d) The array fetched from the DB is smaller than the destination array (%d > %d); the remaining slots with will be filled with 0.", _:stStatement, iOutputSize, iDecompressedCells);
					
					iAddress += iDecompressedCells * 4-4;
					iOutputSize = iOutputSize - iDecompressedCells;
					
					// DB::memset(aArray[], iValue, iSize = sizeof(aArray))
					#emit PUSH.S      iOutputSize
					#emit PUSH.C      0
					#emit PUSH.S      iAddress
					#emit PUSH.C      12
					#emit LCTRL       6
					#emit ADD.C       28
					#emit PUSH.pri
					#emit CONST.pri   DB_memset
					#emit SCTRL       6
				}
				
				
			}
		}
	}
	
	if (!db_next_row(gs_Statements[stStatement][e_dbrResult])) {
		db_free_result(gs_Statements[stStatement][e_dbrResult]);
		
		gs_Statements[stStatement][e_dbrResult] = DB::INVALID_RESULT;
		
		DB::Debug("(stmt_fetch_row:%d) Fetched %d fields and freed the result.", _:stStatement, iCount);
	} else {
		DB::Debug("(stmt_fetch_row:%d) Fetched %d fields.", _:stStatement, iCount);
	}
	
	return true;
}

stock stmt_rows_left(&DBStatement:stStatement) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Errorf("(stmt_rows_left) Invalid statement passed (%d).", _:stStatement);
		
		return 0;
	}
	
	if (gs_Statements[stStatement][e_dbrResult] == DB::INVALID_RESULT) {
		if (!gs_Statements[stStatement][e_iFetchedRows])
			DB::Warning("(stmt_rows_left) Statement has no result.");
		
		return 0;
	}
	
	return max(0, db_num_rows(gs_Statements[stStatement][e_dbrResult]) - gs_Statements[stStatement][e_iFetchedRows]);
}

stock bool:stmt_execute(&DBStatement:stStatement, bool:bStoreResult = true, bool:bAutoFreeResult = true) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Errorf("(stmt_execute) Invalid statement passed (%d).", _:stStatement);
		
		return false;
	}
	
	if (!gs_Statements[stStatement][e_dbDatabase]) {
		DB::Errorf("(stmt_execute) Uninitialized statement passed (%d).", _:stStatement);
		
		return false;
	}
	
	// Make sure all parameters have been set.
	for (new i = 0; i < gs_Statements[stStatement][e_iParams]; i++) {
		if (gs_Statements[stStatement][e_aiParamTypes][i] == DB::TYPE_NONE) {
			DB::Errorf("(stmt_execute) Uninitialized parameter in statement (%d).", i);
			
			return false;
		}
	}
	
	// If old results are left, free them.
	if (gs_Statements[stStatement][e_dbrResult] != DB::INVALID_RESULT) {
		db_free_result(gs_Statements[stStatement][e_dbrResult]);
		
		gs_Statements[stStatement][e_dbrResult] = DB::INVALID_RESULT;
	}
	
	DB::Debug("(stmt_execute:%d) Executing statement.", _:stStatement);
	
	new
		DBResult:dbrResult = db_query(gs_Statements[stStatement][e_dbDatabase], gs_Statements[stStatement][e_szQuery], false)
	;
	
	gs_Statements[stStatement][e_iFetchedRows] = 0;
	gs_Statements[stStatement][e_bAutoFreeResult] = bAutoFreeResult;
	
	if (dbrResult == DB::INVALID_RESULT)
		return false;
	
	if (!bStoreResult)
		db_free_result(dbrResult);
	else {
		gs_Statements[stStatement][e_dbrResult] = dbrResult;
		
		if (bAutoFreeResult && gs_iFreeStatementResultsTimer == -1)
			gs_iFreeStatementResultsTimer = SetTimer("db_free_stmt_results", 1, false);
	}
	
	return true;
}

stock stmt_free_result(&DBStatement:stStatement) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Noticef("(stmt_free_result) Invalid statement passed (%d).", _:stStatement);
		
		return;
	}
	
	gs_Statements[stStatement][e_iFetchedRows] = 0;
	
	if (gs_Statements[stStatement][e_dbrResult] != DB::INVALID_RESULT) {
		db_free_result(gs_Statements[stStatement][e_dbrResult]);
		
		gs_Statements[stStatement][e_dbrResult] = DB::INVALID_RESULT;
		
		DB::Debug("(stmt_free_result:%d) Freed result.", _:stStatement);
	} else {
		DB::Debug("(stmt_free_result:%d) Nothing to free.", _:stStatement);
	}
}

stock stmt_close(&DBStatement:stStatement) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Noticef("(stmt_close) Invalid statement passed (%d).", _:stStatement);
		
		return;
	}
	
	if (gs_Statements[stStatement][e_dbrResult] != DB::INVALID_RESULT)
		db_free_result(gs_Statements[stStatement][e_dbrResult]);
	
	gs_Statements[stStatement][e_dbDatabase] = DB:0;
	
	DB::Debug("(stmt_close:%d) Closed statement.", _:stStatement);
	
	stStatement = DB::INVALID_STATEMENT;
}

stock stmt_autoclose(&DBStatement:stStatement) {
	DB::LazyInitialize();
	
	if (stStatement == DB::INVALID_STATEMENT || !(0 <= _:stStatement < sizeof(gs_Statements))) {
		DB::Noticef("(stmt_autoclose) Invalid statement passed (%d).", _:stStatement);
		
		return;
	}
	
	if (gs_iAutoFreeTimer == -1)
		gs_iAutoFreeTimer = SetTimer("db_drain_autofree_pool", 0, false);
	
	if (gs_iAutoCloseStatementsIndex + 1 >= sizeof(gs_astAutoCloseStatements)) {
		DB::Warning("(stmt_autoclose) The autoclose pool is full!");
		
		return;
	}
	
	gs_astAutoCloseStatements[gs_iAutoCloseStatementsIndex] = stStatement;
	
	gs_iAutoCloseStatementsIndex++;
	
	DB::Debug("(stmt_autoclose:%d) Will autoclose statement.", _:stStatement);
}

stock DBResult:db_query_hook(iTagOf3 = tagof(_bAutoRelease), DB:db, const szQuery[], {bool, DBDataType}:_bAutoRelease = true, {DBDataType, QQPA}:...) {
	new
		     iIndex,
		     iNumArgs,
		     iStaticArgs = 4,
		bool:bAutoRelease = true
	;
	
	#emit LOAD.S.pri  8
	#emit SHR.C.pri   2
	#emit STOR.S.pri  iNumArgs
	
	DB::LazyInitialize();
	
	if (iTagOf3 == tagof(DBDataType:)) {
		iStaticArgs = 3;
	} else {
		bAutoRelease = _bAutoRelease;
	}
	
	if (db_is_persistent(db)) {
		if (!db_is_valid_persistent(db)) {
			DB::Errorf("(db_query) Invalid persistent database given (%04x%04x).", _:db >>> 16, _:db & 0xFFFF);
			
			return DB::INVALID_RESULT;
		}
		
		iIndex = _:db & 0x7FFFFFFF;
		
		if (!gs_PersistentDatabases[iIndex][e_dbDatabase]) {
			if (!(gs_PersistentDatabases[iIndex][e_dbDatabase] = db_open(gs_PersistentDatabases[iIndex][e_szName]))) {
				DB::Errorf("(db_query) Failed to lazily open the database.");
				
				return DB::INVALID_RESULT;
			}
			
			if (gs_iClosePersistentTimer == -1)
				gs_iClosePersistentTimer = SetTimer("db_close_persistent", 0, false);
		}
		
		db = gs_PersistentDatabases[iIndex][e_dbDatabase];
	}
	
#if DB_DEBUG
	if (ispacked(szQuery)) {
		strunpack(gs_szBuffer, szQuery);
		
		DB::Debug("(db_query) Running query: %s", gs_szBuffer);
	} else {
		DB::Debug("(db_query) Running query: %s", szQuery);
	}
#endif
	
	new
		DBResult:dbrResult
	;
	
	if (iNumArgs > iStaticArgs) {
		if ((iNumArgs - iStaticArgs) & 0b1) {
			DB::Error("(db_query) Invalid argument count. Did you forget to use the correct prefix on the arguments (e.g. STRING:somestring)?");
			
			return DB::INVALID_RESULT;
		}
		
		new DBStatement:stmt = db_prepare(db, szQuery);
		
		for (new i = iStaticArgs + 1; i < iNumArgs; i += 2) {
			// Load the address of argument <i>
			#emit LCTRL       5
			#emit LOAD.S.alt  i
			#emit SHL.C.alt   2
			#emit ADD
			#emit ADD.C       12
			#emit MOVE.alt
			#emit LOAD.I
			#emit PUSH.pri
			#emit PUSH.alt
			
			if (i == 4) {
				// Load the address of argument <i - 1>
				#emit POP.pri
				#emit ADD.C       0xFFFFFFFC
				#emit LOAD.I
				#emit PUSH.pri
			} else {
				// Load the address of argument <i - 1>
				#emit POP.pri
				#emit ADD.C       0xFFFFFFFC
				#emit LOAD.I
				#emit LOAD.I
				#emit PUSH.pri
			}
			
			// Push the param index: (i - iStaticArgs) / 2
			#emit LOAD.S.pri  i
			#emit LOAD.S.alt  iStaticArgs
			#emit SUB
			#emit SHR.C.pri   1
			#emit PUSH.pri
			#emit PUSH.ADR    stmt
			
			// Push the argument count
			#emit PUSH.C      16
			
			// Push the return address
			#emit LCTRL       6
			#emit ADD.C       28
			#emit PUSH.pri
			
			// Call stmt_bind_value
			#emit CONST.pri   stmt_bind_value
			#emit SCTRL       6
		}
		
		dbrResult = db_query@(db, gs_Statements[stmt][e_szQuery]);
		
		stmt_close(stmt);
	} else {
		dbrResult = db_query@(db, szQuery);
	}
	
	if (dbrResult) {
		if (bAutoRelease)
			db_autofree_result(dbrResult);
		
		new
			iResultAddress = db_get_result_mem_handle(dbrResult) - DB::GetAmxBaseRelative(),
			iAddress,
			iRows,
			iCols,
			iDataAddress,
			iOffset
		;
		
		iAddress = iResultAddress;

		#emit LREF.S.pri  iAddress
		#emit STOR.S.pri  iRows
		
		iAddress += 4;

		#emit LREF.S.pri  iAddress
		#emit STOR.S.pri  iCols
		
		iAddress += 4;

		#emit LREF.S.pri  iAddress
		#emit STOR.S.pri  iDataAddress
		
		iDataAddress -= DB::GetAmxBaseRelative();
		
		iOffset = (iCols + iRows * iCols) * 4 - 4;
		
		while (iOffset >= 0) {
			iAddress = iDataAddress + iOffset;
			
			#emit LREF.S.pri  iAddress
			#emit STOR.S.pri  iAddress
			
			if (!iAddress) {
				new
					iAmxBaseRelative = DB::GetAmxBaseRelative()
				;
				
				iAddress = iDataAddress + iOffset;
				
				#emit CONST.pri   gs_szNull
				#emit LOAD.S.alt  iAmxBaseRelative
				#emit ADD
				#emit SREF.S.pri  iAddress
			}
			
			iOffset -= 4;
		}
	}
	
	return dbrResult;
}

stock db_get_field_hook(DBResult:dbresult, field, result[], maxlength = sizeof(result)) {
	new retval = db_get_field(dbresult, field, result, maxlength);
	
	format(result, maxlength, "%s", result);
	
	return retval;
}

stock db_get_field_assoc_hook(DBResult:dbresult, const field[], result[], maxlength = sizeof(result)) {
	new retval = db_get_field_assoc(dbresult, field, result, maxlength);
	
	format(result, maxlength, "%s", result);
	
	return retval;
}

stock bool:db_dump_table(DB:db, const szTable[], const szFilename[]) {
	static
		s_szColumnName[256]
	;

	new
		DBResult:dbrResult,
		File:fp
	;
	
	if (strfind(szTable, "\"") != -1 || strfind(szTable, "'") != -1) {
		DB::Error("(db_dump_table) Invalid table name given.");
		
		return false;
	}
	
	if (!(fp = fopen(szFilename, io_write))) {
		DB::Error("(db_dump_table) Failed to open the file.");
		
		return false;
	}
	
	format(gs_szBuffer, sizeof(gs_szBuffer), "SELECT sql FROM sqlite_master WHERE tbl_name = '%s'", szTable);
	
	dbrResult = db_query(db, gs_szBuffer);
	
	if (!dbrResult) {
		DB::Error("(db_dump_table) Failed to get the table sql.");
		
		return false;
	}
	
	db_get_field(dbrResult, 0, gs_szBuffer, sizeof(gs_szBuffer) - 1);
	
	if (strlen(gs_szBuffer) >= sizeof(gs_szBuffer) - 2) {
		DB::Error("(db_dump_table) Buffer overflow.");
		
		fwrite(fp, "\nBUFFER OVERFLOW");
		fclose(fp);
		
		db_free_result(dbrResult);
		
		return false;
	}
	
	fwrite(fp, gs_szBuffer);
	fwrite(fp, ";\n\n\n");
	
	db_free_result(dbrResult);
	
	format(gs_szBuffer, sizeof(gs_szBuffer), "PRAGMA table_info(%s)", szTable);
	
	dbrResult = db_query(db, gs_szBuffer, false);
	
	if (!dbrResult) {
		DB::Error("(db_dump_table) Failed to get table info.");
		
		return false;
	}
	
	gs_szBuffer = "SELECT 'INSERT INTO ";
	strcat(gs_szBuffer, szTable);
	strcat(gs_szBuffer, " VALUES('");
	
	if (db_num_rows(dbrResult)) do {
		db_get_field(dbrResult, 1, s_szColumnName, sizeof(s_szColumnName) - 1);
		
		if (db_get_row_index(dbrResult) > 0)
			strcat(gs_szBuffer, " || ', '");
		
		strcat(gs_szBuffer, " || quote(");
		strcat(gs_szBuffer, s_szColumnName);
		strcat(gs_szBuffer, ")");
	} while (db_next_row(dbrResult));
	
	strcat(gs_szBuffer, " || ');' FROM ");
	strcat(gs_szBuffer, szTable);
	
	db_free_result(dbrResult);
	
	dbrResult = db_query(db, gs_szBuffer);
	
	fwrite(fp, "BEGIN;\n\n");
	
	if (db_num_rows(dbrResult)) do {
		db_get_field(dbrResult, 0, gs_szBuffer, sizeof(gs_szBuffer) - 1);
		
		if (strlen(gs_szBuffer) >= sizeof(gs_szBuffer) - 2) {
			DB::Error("(db_dump_table) Buffer overflow.");
			
			fwrite(fp, "\nBUFFER OVERFLOW");
			fclose(fp);
			
			db_free_result(dbrResult);
			
			return false;
		}
		
		fwrite(fp, gs_szBuffer);
		fwrite(fp, "\n");
	} while (db_next_row(dbrResult));
	
	fwrite(fp, "\nCOMMIT;\n");
	
	db_free_result(dbrResult);
	
	fclose(fp);
	
	return true;
}

stock DBResult:db_print_result(DBResult:dbrResult, iMaxFieldLength = 40) {
	DB::LazyInitialize();
	
	const
		MAX_ROWS         = 100,
		MAX_FIELDS       = 20,
		MAX_FIELD_LENGTH = 88
	;
	
	static
		s_aaszFields[MAX_ROWS + 1][MAX_FIELDS][MAX_FIELD_LENGTH char],
		s_aiFieldMaxLength[MAX_FIELDS]
	;
	
	static const
		szcSpacePadding[MAX_FIELD_LENGTH] = {' ', ...},
		szcDashPadding[MAX_FIELD_LENGTH] = {'-', ...}
	;
	
	if (iMaxFieldLength == -1)
		iMaxFieldLength = MAX_FIELD_LENGTH;
	
	print(!" ");
	print(!"Query result:");
	
	if (!dbrResult)
		print(!"\t- Invalid result.");
	else if (!db_num_rows(dbrResult))
		print(!"\t- No rows.");
	else {
		new
			     iRow = 0,
			     iRows,
			     iFields = db_num_fields(dbrResult),
			     iField,
			     iLength,
			bool:bHasMoreLines,
			     iPos,
			     iNextPos,
			     iRowIndex = db_get_row_index(dbrResult)
		;
		
		db_set_row_index(dbrResult, 0);
		
		if (iMaxFieldLength > MAX_FIELD_LENGTH) {
			printf("\t- The longest possible field length is %d. Change MAX_FIELD_LENGTH for larger values.", MAX_FIELD_LENGTH);
			
			iMaxFieldLength = MAX_FIELD_LENGTH;
		}
		
		if (iFields > MAX_FIELDS) {
			printf("\t- There are %d, but only %d of them will be visible.", iFields, MAX_FIELDS);
			print(!"\t- Increase MAX_FIELDS if you want to see all fields.");
			
			iFields = MAX_FIELDS;
		}
		
		for (iField = 0; iField < iFields; iField++) {
			db_field_name(dbrResult, iField, gs_szBuffer, iMaxFieldLength - 1);
			
			iPos = 0;
			
			while (-1 != (iPos = strfind(gs_szBuffer, "\r", _, iPos)))
				gs_szBuffer[iPos] = ' ';
			
			iPos = 0;
			
			while (-1 != (iPos = strfind(gs_szBuffer, "\t", _, iPos))) {
				gs_szBuffer[iPos] = ' ';
				
				strins(gs_szBuffer, "   ", iPos, iMaxFieldLength);
				
				iPos += 4;
			}
			
			iPos = 0;

			do {
				iNextPos = strfind(gs_szBuffer, "\n", _, iPos) + 1;

				if (!iNextPos)
					iLength = strlen(gs_szBuffer[iPos]);
				else
					iLength = iNextPos - iPos - 1;

				s_aiFieldMaxLength[iField] = min(iMaxFieldLength, max(iLength, s_aiFieldMaxLength[iField]));
			} while ((iPos = iNextPos));
			
			strpack(s_aaszFields[0][iField], gs_szBuffer, iMaxFieldLength char);
		}
		
		do {
			for (iField = 0; iField < iFields; iField++) {
				if (db_field_is_null(dbrResult, iField))
					gs_szBuffer = "NULL";
				else
					db_get_field(dbrResult, iField, gs_szBuffer, iMaxFieldLength - 1);
				
				iPos = 0;
				
				while (-1 != (iPos = strfind(gs_szBuffer, "\r", _, iPos)))
					gs_szBuffer[iPos] = ' ';
				
				iPos = 0;
				
				while (-1 != (iPos = strfind(gs_szBuffer, "\t", _, iPos))) {
					gs_szBuffer[iPos] = ' ';
					
					strins(gs_szBuffer, "   ", iPos, iMaxFieldLength);
					
					iPos += 4;
				}
				
				iPos = 0;

				do {
					iNextPos = strfind(gs_szBuffer, "\n", _, iPos) + 1;

					if (!iNextPos)
						iLength = strlen(gs_szBuffer[iPos]);
					else
						iLength = iNextPos - iPos - 1;

					s_aiFieldMaxLength[iField] = min(iMaxFieldLength, max(iLength, s_aiFieldMaxLength[iField]));
				} while ((iPos = iNextPos));

				strpack(s_aaszFields[iRow + 1][iField], gs_szBuffer, iMaxFieldLength char);
			}
			
			if (++iRow >= MAX_ROWS) {
				iRows = iRow;
				
				while (db_next_row(dbrResult))
					iRows++;
				
				printf("\t- Only the first %d rows are displayed; there are %d remaining.", MAX_ROWS, iRows);
				
				break;
			}
		} while (db_next_row(dbrResult));
		
		print(!" ");
		
		for (iRows = iRow, iRow = 0; iRow <= iRows; iRow++) {
			do {
				bHasMoreLines = false;
				
				gs_szBuffer[0] = 0;
				
				for (iField = 0; iField < iFields; iField++) {
					if (iField)
						strcat(gs_szBuffer, " | ");
					
					iLength = strlen(gs_szBuffer);
					
					if (-1 != (iPos = strfind(s_aaszFields[iRow][iField], "\n"))) {
						strunpack(gs_szBuffer[iLength], s_aaszFields[iRow][iField], strlen(gs_szBuffer[iLength]) + iPos + 1);
						
						strdel(s_aaszFields[iRow][iField], 0, iPos + 1);
						
						bHasMoreLines = true;
					} else {
						if (s_aaszFields[iRow][iField]{0}) {
							strunpack(gs_szBuffer[iLength], s_aaszFields[iRow][iField], sizeof(gs_szBuffer) - iLength);
							
							s_aaszFields[iRow][iField]{0} = 0;
						}
					}
				
					iLength = strlen(gs_szBuffer[iLength]);
					
					strcat(gs_szBuffer, szcSpacePadding, strlen(gs_szBuffer) + (s_aiFieldMaxLength[iField] - iLength + 1));
				}
				
				if (bHasMoreLines)
					printf("\t| %s |", gs_szBuffer);
				
			} while (bHasMoreLines);
			
			if (iRow == 0) {
				printf("\t/ %s \\", gs_szBuffer);
			} else {
				printf("\t| %s |", gs_szBuffer);
			}
			
			if (iRow == iRows) {
				gs_szBuffer[0] = 0;
				
				for (iField = 0; iField < iFields; iField++) {
					if (iField)
						strcat(gs_szBuffer, "---");
					
					strcat(gs_szBuffer, szcDashPadding, strlen(gs_szBuffer) + s_aiFieldMaxLength[iField] + 1);
				}

				printf("\t\\-%s-/", gs_szBuffer);
			} else {
				gs_szBuffer[0] = 0;
				
				for (iField = 0; iField < iFields; iField++) {
					if (iField)
						strcat(gs_szBuffer, "-|-");
					
					strcat(gs_szBuffer, szcDashPadding, strlen(gs_szBuffer) + s_aiFieldMaxLength[iField] + 1);
				}
				
				printf("\t|-%s-|", gs_szBuffer);
			}
		}
		
		db_set_row_index(dbrResult, iRowIndex);
	}
	
	print(!" ");
	
	return dbrResult;
}

stock db_print_query(DB:db, const szQuery[], iMaxFieldLength = 40) {
	new
		DBResult:dbrResult = db_query(db, szQuery, false)
	;
	
	db_print_result(dbrResult, iMaxFieldLength);
	
	db_free_result(dbrResult);
}

forward db_drain_autofree_pool();
public db_drain_autofree_pool() {
	DB::LazyInitialize();
	
	gs_iAutoFreeTimer = -1;
	
	for (new i = gs_iAutoFreeResultsIndex; i--; ) {
		if (gs_adbrAutoFreeResults[i]) {
			new DBResult:result = gs_adbrAutoFreeResults[i];
			
			gs_adbrAutoFreeResults[i] = DB::INVALID_RESULT;
			
			DB::Debug("(db_drain_autofree_pool) Autofreeing 0x%04x%04x", _:result >>> 16, _:result & 0xFFFF);
			
			db_free_result_hook(result);
		}
	}
	
	gs_iAutoFreeResultsIndex = 0;

	for (new i = gs_iAutoCloseStatementsIndex; i--; ) {
		if (gs_astAutoCloseStatements[i]) {
			DB::Debug("(db_drain_autofree_pool) Autoclosing statement %d.", _:gs_astAutoCloseStatements[i]);
		
			stmt_close(gs_astAutoCloseStatements[i]);
		}
	}
	
	gs_iAutoCloseStatementsIndex = 0;
}

forward db_free_stmt_results();
public db_free_stmt_results() {
	gs_iFreeStatementResultsTimer = -1;
	
	for (new DBStatement:i = DBStatement:0; _:i < sizeof(gs_Statements); i++) {
		if (gs_Statements[i][e_dbDatabase]
		 && gs_Statements[i][e_bAutoFreeResult]
		 && gs_Statements[i][e_dbrResult] != DB::INVALID_RESULT) {
			new DBResult:result = gs_Statements[i][e_dbrResult];
			
			gs_Statements[i][e_dbrResult] = DB::INVALID_RESULT;
			
			DB::Debug("(db_free_stmt_results) Freeing 0x%04x%04x for %d.", _:result >>> 16, _:result & 0xFFFF, _:i);
			
			db_free_result_hook(result);
		}
	}
}

forward db_close_persistent();
public db_close_persistent() {
	gs_iClosePersistentTimer = -1;
	
	for (new i = 0; i < sizeof(gs_PersistentDatabases); i++) {
		if (gs_PersistentDatabases[i][e_bIsUsed] && gs_PersistentDatabases[i][e_dbDatabase]) {
			db_close@(gs_PersistentDatabases[i][e_dbDatabase]);
			
			gs_PersistentDatabases[i][e_dbDatabase] = DB:0;
		}
	}
}

static stock DB::FindMSB(iInput) {
	// http://graphics.stanford.edu/~seander/bithacks.html#IntegerLogDeBruijn
	
	static const
		s_aiDeBruijnBitPositionsPacked[32 char] = {
			0x0A010900,
			0x1D02150D,
			0x12100E0B,
			0x1E031916,
			0x1C140C08,
			0x0718110F,
			0x06171B13,
			0x1F04051A
		}
	;
	
	if (iInput) {
		#emit LOAD.S.pri  iInput
		#emit MOVE.alt
		#emit SHR.C.alt   1
		#emit OR
		#emit MOVE.alt
		#emit SHR.C.alt   2
		#emit OR
		#emit MOVE.alt
		#emit SHR.C.alt   4
		#emit OR
		#emit MOVE.alt
		#emit SHR.C.alt   8
		#emit OR
		#emit MOVE.alt
		#emit SHR.C.alt   16
		#emit OR
		#emit CONST.alt   0x07C4ACDD
		#emit UMUL
		#emit SHR.C.pri   27
		#emit ADD.C       s_aiDeBruijnBitPositionsPacked
		#emit LODB.I      1
		#emit RETN
	}
	
	return -1;
}

static stock DB::getstringarg(dest[], arg, len = sizeof (dest)) {
    // Get the address of the previous function's stack.  First get the index of
    // the argument required.
    #emit LOAD.S.pri arg
    // Then convert that number to bytes from cells.
    #emit SMUL.C     4
    // Get the previous function's frame.  Stored in variable 0 (in the current
    // frame).  Parameters are FRM+n+12, locals are FRM-n, previous frame is
    // FRM+0, return address is FRM+4, parameter count is FRM+8.  We could add
    // checks that "arg * 4 < *(*(FRM + 0) + 8)", for the previous frame parameter
    // count (in C pointer speak).
    #emit LOAD.S.alt 0
    // Add the frame pointer to the argument offset in bytes.
    #emit ADD
    // Add 12 to skip over the function header.
    #emit ADD.C      12
    // Load the address stored in the specified address.
    #emit LOAD.I
    // Push the length for "strcat".
    #emit PUSH.S     len
    // Push the address we just determined was the source.
    #emit PUSH.pri
    // Load the address of the destination.
    #emit LOAD.S.alt dest
    // Blank the first cell so "strcat" behaves like "strcpy".
    #emit CONST.pri  0
    // Store the loaded number 0 to the loaded address.
    #emit STOR.I
    // Push the loaded address.
    #emit PUSH.alt
    // Push the number of parameters passed (in bytes) to the function.
    #emit PUSH.C     12
    // Call the function.
    #emit SYSREQ.C   strcat
    // Restore the stack to its level before we called this native.
    #emit STACK      16
}

static stock DB::setstringarg(iArg, const szValue[], iLength = sizeof(szValue)) {
	new
		iAddress
	;

	// Get the address of the previous function's stack.  First get the index of
    // the argument required.
    #emit LOAD.S.pri iArg
    // Then convert that number to bytes from cells.
    #emit SMUL.C     4
    // Get the previous function's frame.
	#emit LOAD.S.alt 0
	// Add the frame pointer to the argument offset in bytes.
    #emit ADD
    // Add 12 to skip over the function header.
    #emit ADD.C      12
    // Load the address stored in the specified address.
    #emit LOAD.I
	#emit STOR.S.PRI iAddress

	// Push the length (last argument first)
	#emit PUSH.S     iLength

	// Push the new value (source) szValue
	#emit PUSH.S     szValue

	// Blank out the first cell of the argument
	#emit CONST.pri  0
	#emit SREF.S.pri iAddress
	
	// Push the destination
	#emit PUSH.S     iAddress

	// Push the number of parameters passed (in bytes) to the function.
	#emit PUSH.C     12
	
	// Call the function.
	#emit SYSREQ.C   strcat
	
	// Restore the stack to its level before we called this native.
	#emit STACK      16
}

// Pretty much Y_Less's va_strlen function
static stock DB::isargpacked(iArg) {
    // Get the length of the string at the given position on the previous
    // function's stack (convenience function).
    // Get the address of the previous function's stack.  First get the index of
    // the argument required.
    #emit LOAD.S.pri iArg
    // Then convert that number to bytes from cells.
    #emit SMUL.C     4
    // Get the previous function's frame.  Stored in variable 0 (in the current
    // frame).  Parameters are FRM+n+12, locals are FRM-n, previous frame is
    // FRM+0, return address is FRM+4, parameter count is FRM+8.  We could add
    // checks that "arg * 4 < *(*(FRM + 0) + 8)", for the previous frame parameter
    // count (in C pointer speak).
    #emit LOAD.S.alt 0
    // Add the frame pointer to the argument offset in bytes.
    #emit ADD
    // Add 12 to skip over the function header.
    #emit ADD.C      12
    // Load the address stored in the specified address.
    #emit LOAD.I
    // Push the address we just determined was the source.
    #emit PUSH.pri
    // Push the number of parameters passed (in bytes) to the function.
    #emit PUSH.C     4
    // Call the function.
    #emit SYSREQ.C   ispacked
    // Restore the stack to its level before we called this native.
    #emit STACK      8
    #emit RETN
    // Never called.
    return 0;
}

stock DB::GetAmxBaseRelative() {
	static
		s_iAmxBaseRelative = 0
	;
	
	if (!s_iAmxBaseRelative) {
		s_iAmxBaseRelative = DB::GetAmxBase();

		#emit LCTRL     1
		#emit LOAD.alt  s_iAmxBaseRelative
		#emit ADD
		#emit STOR.pri  s_iAmxBaseRelative
	}
	
	return s_iAmxBaseRelative;
}

// By Zeex!
// Returns the AMX base address i.e. amx->base.
static stock DB::dummy() {
	return 0;
}

stock DB::GetAmxBase() {
	static amx_base = 0; // cached

	if (amx_base == 0) {
		new cod, dat;
		#emit lctrl 0
		#emit stor.s.pri cod
		#emit lctrl 1
		#emit stor.s.pri dat

		// Get code section start address relative to data.
		new code_start = cod - dat;

		// Get address of DB::dummy().
		new fn_addr;
		#emit const.pri DB_dummy
		#emit stor.s.pri fn_addr

		// Get absolute address from the CALL instruction.
		new fn_addr_reloc, call_addr;
		DB_dummy();
		#emit lctrl 6
		#emit stor.s.pri call_addr
		call_addr = call_addr - 12 + code_start;
		#emit lref.s.pri call_addr
		#emit stor.s.pri fn_addr_reloc

		amx_base = fn_addr_reloc - fn_addr - cod;
	}

	return amx_base;
}

// phys_memory.inc
static stock AbsToRel(addr) {
	new dat;
	#emit lctrl 1
	#emit stor.s.pri dat
	return addr - (GetAmxBaseAddress() + dat);
}

// This function has a bug in older amx_assembly versions
static stock WritePhysMemoryCell_(addr, what) {
	new rel_addr = AbsToRel(addr);
	#emit load.s.pri what
	#emit sref.s.pri rel_addr
	#emit stack 4
	#emit retn
	return 0; // make compiler happy
}

// Hook db_get_field
// This is done lastly because the fixed function isn't needed within SQLitei
#define db_get_field db_get_field_hook
#define db_get_field_assoc db_get_field_assoc_hook
