unit odbcsql;

{$DEFINE ODBCVER3}

{$DEFINE DYNLOADINGODBC}

interface
(* DATA TYPES CORRESPONDENCE
   BDE fields  ODBC types
   ----------  ------------------
   ftBlob      SQL_BINARY
   ftBoolean   SQL_BIT
   ftDate      SQL_TYPE_DATE
   ftTime      SQL_TYPE_TIME
   ftDateTime  SQL_TYPE_TIMESTAMP
   ftInteger   SQL_INTEGER
   ftSmallint  SQL_SMALLINT
   ftFloat     SQL_DOUBLE
   ftString    SQL_CHAR
   ftMemo      SQL_CHAR
*)

type
  SQLCHAR      = Char;
  SQLSMALLINT  = smallint;
  SQLUSMALLINT = Word;
  SQLRETURN    = SQLSMALLINT;
  SQLHANDLE    = LongInt;
  SQLHENV      = SQLHANDLE;
  SQLHDBC      = SQLHANDLE;
  SQLHSTMT     = SQLHANDLE;
  SQLINTEGER   = LongInt;
  SQLUINTEGER  = Cardinal;
  SQLPOINTER   = Pointer;
  SQLREAL      = real;
  SQLDOUBLE    = Double;
  SQLFLOAT     = Double;
  PSQLCHAR      = PChar;
  PSQLINTEGER   = ^SQLINTEGER;
  PSQLUINTEGER  = ^SQLUINTEGER;
  PSQLSMALLINT  = ^SQLSMALLINT;
  PSQLUSMALLINT = ^SQLUSMALLINT;
  PSQLREAL      = ^SQLREAL;
  PSQLDOUBLE    = ^SQLDOUBLE;
  PSQLFLOAT     = ^SQLFLOAT;
  PSQLHandle    = ^SQLHANDLE;

const
     { SQL data type codes }
     SQL_UNKNOWN_TYPE = 0;
     SQL_LONGVARCHAR   =(-1);
     SQL_BINARY        =(-2);
     SQL_VARBINARY     =(-3);
     SQL_LONGVARBINARY =(-4);
     SQL_BIGINT        =(-5);
     SQL_TINYINT       =(-6);
     SQL_BIT           =(-7);
     SQL_CHAR          = 1;
     SQL_NUMERIC       = 2;
     SQL_DECIMAL       = 3;
     SQL_INTEGER       = 4;
     SQL_SMALLINT      = 5;
     SQL_FLOAT         = 6;
     SQL_REAL          = 7;
     SQL_DOUBLE        = 8;
{$ifdef ODBCVER3}
     SQL_DATETIME      = 9;
{$endif}
     SQL_VARCHAR       = 12;

     SQL_C_LONG        = SQL_INTEGER;
{$ifdef ODBCVER3}
     SQL_TYPE_DATE     = 91;
     SQL_TYPE_TIME     = 92;
     SQL_TYPE_TIMESTAMP= 93;
{$endif}

     {ODBC2}
     SQL_DATE       = 9;
     SQL_TIME       = 10;
     SQL_TIMESTAMP  = 11;
     {end of Odbc2}

     SQL_NO_TOTAL   = -4;

type
  SQL_DATE_STRUCT = packed record
    Year : SQLSMALLINT;
    Month : SQLUSMALLINT;
    Day : SQLUSMALLINT;
  end;
  PSQL_DATE_STRUCT = ^SQL_DATE_STRUCT;

  SQL_TIME_STRUCT = packed record
    Hour : SQLUSMALLINT;
    Minute : SQLUSMALLINT;
    Second : SQLUSMALLINT;
  end;
  PSQL_TIME_STRUCT = ^SQL_TIME_STRUCT;

  SQL_TIMESTAMP_STRUCT = packed record
    Year :     SQLUSMALLINT;
    Month :    SQLUSMALLINT;
    Day :      SQLUSMALLINT;
    Hour :     SQLUSMALLINT;
    Minute :   SQLUSMALLINT;
    Second :   SQLUSMALLINT;
    Fraction : SQLUINTEGER;
  end;
  PSQL_TIMESTAMP_STRUCT = ^SQL_TIMESTAMP_STRUCT;

const
  SQL_NAME_LEN = 128;
  
  SQL_OV_ODBC3	        = 3;
  SQL_OV_ODBC2	        = 2;
  SQL_ATTR_ODBC_VERSION = 200;
  { Options for SQLDriverConnect }
  SQL_DRIVER_NOPROMPT          = 0;
  SQL_DRIVER_COMPLETE          = 1;
  SQL_DRIVER_PROMPT            = 2;
  SQL_DRIVER_COMPLETE_REQUIRED = 3;

  { whether an attribute is a pointer or not }
  SQL_IS_POINTER    = (-4);
  SQL_IS_UINTEGER   = (-5);
  SQL_IS_INTEGER    = (-6);
  SQL_IS_USMALLINT  = (-7);
  SQL_IS_SMALLINT   = (-8);
  { SQLExtendedFetch "fFetchType" values }
  SQL_FETCH_BOOKMARK = 8;
  SQL_USE_BOOKMARKS  = 12;
  SQL_ATTR_USE_BOOKMARKS = SQL_USE_BOOKMARKS;

  SQL_SCROLL_OPTIONS = 44;

  { SQL_USE_BOOKMARKS options }
  SQL_UB_OFF      = 0;
  SQL_UB_ON       = 1;
  SQL_UB_DEFAULT  = SQL_UB_OFF;
  SQL_UB_FIXED    = SQL_UB_ON;
  SQL_UB_VARIABLE = 2;

  { SQL_SCROLL_OPTIONS masks }
  SQL_SO_FORWARD_ONLY  = $01;
  SQL_SO_KEYSET_DRIVEN = $02;
  SQL_SO_DYNAMIC       = $04;
  SQL_SO_MIXED         = $08;
  SQL_SO_STATIC        = $10;

  SQL_BOOKMARK_PERSISTENCE = 82;
  SQL_STATIC_SENSITIVITY   = 83;

  { SQL_BOOKMARK_PERSISTENCE values }
  SQL_BP_CLOSE       = $01;
  SQL_BP_DELETE      = $02;
  SQL_BP_DROP        = $04;
  SQL_BP_TRANSACTION = $08;
  SQL_BP_UPDATE      = $10;
  SQL_BP_OTHER_HSTMT = $20;
  SQL_BP_SCROLL      = $40;

  SQL_DYNAMIC_CURSOR_ATTRIBUTES1      =	144;
  SQL_DYNAMIC_CURSOR_ATTRIBUTES2      =	145;
  SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1 =	146;
  SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2 =	147;
  SQL_INDEX_KEYWORDS		      =	148;
  SQL_INFO_SCHEMA_VIEWS		      =	149;
  SQL_KEYSET_CURSOR_ATTRIBUTES1	      =	150;
  SQL_KEYSET_CURSOR_ATTRIBUTES2	      =	151;
  SQL_STATIC_CURSOR_ATTRIBUTES1	      = 167;
  SQL_STATIC_CURSOR_ATTRIBUTES2	      = 168;

  { supported SQLFetchScroll FetchOrientation's }
  SQL_CA1_NEXT		= 1;
  SQL_CA1_ABSOLUTE	= 2;
  SQL_CA1_RELATIVE	= 4;
  SQL_CA1_BOOKMARK	= 8;

  { supported SQLSetPos LockType's }
  SQL_CA1_LOCK_NO_CHANGE= $40;
  SQL_CA1_LOCK_EXCLUSIVE= $80;
  SQL_CA1_LOCK_UNLOCK	=$100;

  { supported SQLSetPos Operations }
  SQL_CA1_POS_POSITION	= $200;
  SQL_CA1_POS_UPDATE	= $400;
  SQL_CA1_POS_DELETE	= $800;
  SQL_CA1_POS_REFRESH	=$1000;

  { positioned updates and deletes }
  SQL_CA1_POSITIONED_UPDATE=$2000;
  SQL_CA1_POSITIONED_DELETE=$4000;
  SQL_CA1_SELECT_FOR_UPDATE=$8000;

  { supported SQLBulkOperations operations }
  SQL_CA1_BULK_ADD		  =$10000;
  SQL_CA1_BULK_UPDATE_BY_BOOKMARK =$20000;
  SQL_CA1_BULK_DELETE_BY_BOOKMARK =$40000;
  SQL_CA1_BULK_FETCH_BY_BOOKMARK  =$80000;

  { supported values for SQL_ATTR_SCROLL_CONCURRENCY }
  SQL_CA2_READ_ONLY_CONCURRENCY	= 1;
  SQL_CA2_LOCK_CONCURRENCY	= 2;
  SQL_CA2_OPT_ROWVER_CONCURRENCY= 4;
  SQL_CA2_OPT_VALUES_CONCURRENCY= 8;

  { sensitivity of the cursor to its own inserts, deletes, and updates }
  SQL_CA2_SENSITIVITY_ADDITIONS	=$10;
  SQL_CA2_SENSITIVITY_DELETIONS	=$20;
  SQL_CA2_SENSITIVITY_UPDATES	=$40;

{  semantics of SQL_ATTR_MAX_ROWS }
  SQL_CA2_MAX_ROWS_SELECT	= $80;
  SQL_CA2_MAX_ROWS_INSERT	=$100;
  SQL_CA2_MAX_ROWS_DELETE	=$200;
  SQL_CA2_MAX_ROWS_UPDATE	=$400;
  SQL_CA2_MAX_ROWS_CATALOG	=$800;
  SQL_CA2_MAX_ROWS_AFFECTS_ALL	=(SQL_CA2_MAX_ROWS_SELECT or
					SQL_CA2_MAX_ROWS_INSERT or SQL_CA2_MAX_ROWS_DELETE or
					SQL_CA2_MAX_ROWS_UPDATE or SQL_CA2_MAX_ROWS_CATALOG);

  { semantics of SQL_DIAG_CURSOR_ROW_COUNT }
  SQL_CA2_CRC_EXACT		= $1000;
  SQL_CA2_CRC_APPROXIMATE	= $2000;

  {  the kinds of positioned statements that can be simulated }
  SQL_CA2_SIMULATE_NON_UNIQUE	= $4000;
  SQL_CA2_SIMULATE_TRY_UNIQUE	= $8000;
  SQL_CA2_SIMULATE_UNIQUE	=$10000;

  {  Operations in SQLBulkOperations }
  SQL_ADD                     = 4;
  SQL_SETPOS_MAX_OPTION_VALUE =	SQL_ADD;
  SQL_UPDATE_BY_BOOKMARK      = 5;
  SQL_DELETE_BY_BOOKMARK      = 6;
  SQL_FETCH_BY_BOOKMARK	      = 7;

  { Operations in SQLSetPos }
  SQL_POSITION                = 0;
  SQL_REFRESH                 = 1;
  SQL_UPDATE                  = 2;
  SQL_DELETE                  = 3;

  { Lock options in SQLSetPos }
  SQL_LOCK_NO_CHANGE          = 0;
  SQL_LOCK_EXCLUSIVE          = 1;
  SQL_LOCK_UNLOCK             = 2;

  { SQLExtendedFetch "rgfRowStatus" element values }
  SQL_ROW_SUCCESS           = 0;
  SQL_ROW_DELETED           = 1;
  SQL_ROW_UPDATED           = 2;
  SQL_ROW_NOROW             = 3;
  SQL_ROW_ADDED             = 4;
  SQL_ROW_ERROR             = 5;
  SQL_ROW_SUCCESS_WITH_INFO = 6;

  SQL_ROW_PROCEED	    = 0;
  SQL_ROW_IGNORE	    = 1;

  SQL_MAX_DSN_LENGTH	       = 32; { maximum data source name size }

  SQL_MAX_OPTION_STRING_LENGTH = 256;

  SQL_ODBC_CURSORS      = 110;
  SQL_ATTR_ODBC_CURSORS	= SQL_ODBC_CURSORS;
  { SQL_ODBC_CURSORS options }
  SQL_CUR_USE_IF_NEEDED = 0;
  SQL_CUR_USE_ODBC      = 1;
  SQL_CUR_USE_DRIVER    = 2;
  SQL_CUR_DEFAULT       = SQL_CUR_USE_DRIVER;

  SQL_PARAM_TYPE_UNKNOWN = 0;
  SQL_PARAM_INPUT        = 1;
  SQL_PARAM_INPUT_OUTPUT = 2;
  SQL_RESULT_COL         = 3;
  SQL_PARAM_OUTPUT       = 4;
  SQL_RETURN_VALUE       = 5;

     { special length/indicator values }
     SQL_NULL_DATA    = (-1);
     SQL_DATA_AT_EXEC = (-2);

     SQL_SUCCESS  = 0;
     SQL_SUCCESS_WITH_INFO = 1;

     SQL_NO_DATA = 100;
     SQL_ERROR   = (-1);
     SQL_INVALID_HANDLE =(-2);

     SQL_STILL_EXECUTING =  2;
     SQL_NEED_DATA       = 99;
     { flags for null-terminated string }
     SQL_NTS  = (-3);

     { maximum message length }
     SQL_MAX_MESSAGE_LENGTH = 512;

     { date/time length constants }
{$ifdef ODBCVER3}
     SQL_DATE_LEN      = 10;
     SQL_TIME_LEN      =  8;  { add P+1 if precision is nonzero }
     SQL_TIMESTAMP_LEN = 19;  { add P+1 if precision is nonzero }
{$endif}

     { handle type identifiers }
     SQL_HANDLE_ENV   = 1;
     SQL_HANDLE_DBC   = 2;
     SQL_HANDLE_STMT  = 3;
     SQL_HANDLE_DESC  = 4;

{$ifdef ODBCVER3}
     { environment attribute }
     SQL_ATTR_OUTPUT_NTS  = 10001;
     { connection attributes }
     SQL_ATTR_AUTO_IPD    = 10001;
     SQL_ATTR_METADATA_ID = 10014;
{$endif}  { ODBCVER >= 0x0300 }

     { statement attributes }
     SQL_ATTR_APP_ROW_DESC       = 10010;
     SQL_ATTR_APP_PARAM_DESC     = 10011;
     SQL_ATTR_IMP_ROW_DESC       = 10012;
     SQL_ATTR_IMP_PARAM_DESC     = 10013;
     SQL_ATTR_CURSOR_SCROLLABLE  = (-1);
     SQL_ATTR_CURSOR_SENSITIVITY = (-2);
     SQL_CURSOR_TYPE             = 6;
     SQL_CONCURRENCY		 = 7;
     SQL_ATTR_CURSOR_TYPE        = SQL_CURSOR_TYPE;
     SQL_ATTR_CONCURRENCY	 = SQL_CONCURRENCY;
     SQL_ATTR_FETCH_BOOKMARK_PTR = 16;
     SQL_ATTR_ROW_STATUS_PTR	 = 25;
     SQL_ATTR_ROWS_FETCHED_PTR	 = 26;
     SQL_AUTOCOMMIT              = 102;
     SQL_ATTR_AUTOCOMMIT	 = SQL_AUTOCOMMIT;
     SQL_ROW_NUMBER		 = 14;
     SQL_ATTR_ROW_NUMBER	 = SQL_ROW_NUMBER;
     SQL_TXN_ISOLATION           = 108;
     SQL_ATTR_TXN_ISOLATION	 = SQL_TXN_ISOLATION;

     (* SQL_AUTOCOMMIT options *)
     SQL_AUTOCOMMIT_OFF          = 0;
     SQL_AUTOCOMMIT_ON           = 1;
     SQL_AUTOCOMMIT_DEFAULT      = SQL_AUTOCOMMIT_ON;
     { SQL_ATTR_CURSOR_SCROLLABLE values }
     SQL_NONSCROLLABLE		 = 0;
     SQL_SCROLLABLE		 = 1;
     { SQL_CURSOR_TYPE options }
     SQL_CURSOR_FORWARD_ONLY     = 0;
     SQL_CURSOR_KEYSET_DRIVEN    = 1;
     SQL_CURSOR_DYNAMIC          = 2;
     SQL_CURSOR_STATIC           = 3;
     SQL_CURSOR_TYPE_DEFAULT     = SQL_CURSOR_FORWARD_ONLY;{ Default value }

     { SQL_CONCURRENCY options }
     SQL_CONCUR_READ_ONLY = 1;
     SQL_CONCUR_LOCK      = 2;
     SQL_CONCUR_ROWVER    = 3;
     SQL_CONCUR_VALUES    = 4;
     SQL_CONCUR_DEFAULT   = SQL_CONCUR_READ_ONLY; { Default value }

     { identifiers of fields in the SQL descriptor }
{$ifdef ODBCVER3}
     SQL_DESC_COUNT                  = 1001;
     SQL_DESC_TYPE                   = 1002;
     SQL_DESC_LENGTH                 = 1003;
     SQL_DESC_OCTET_LENGTH_PTR       = 1004;
     SQL_DESC_PRECISION              = 1005;
     SQL_DESC_SCALE                  = 1006;
     SQL_DESC_DATETIME_INTERVAL_CODE = 1007;
     SQL_DESC_NULLABLE               = 1008;
     SQL_DESC_INDICATOR_PTR          = 1009;
     SQL_DESC_DATA_PTR               = 1010;
     SQL_DESC_NAME                   = 1011;
     SQL_DESC_UNNAMED                = 1012;
     SQL_DESC_OCTET_LENGTH           = 1013;
     SQL_DESC_ALLOC_TYPE             = 1099;
{$endif}

     { identifiers of fields in the diagnostics area }
{$ifdef ODBCVER3}
     SQL_DIAG_RETURNCODE            = 1;
     SQL_DIAG_NUMBER                = 2;
     SQL_DIAG_ROW_COUNT             = 3;
     SQL_DIAG_SQLSTATE              = 4;
     SQL_DIAG_NATIVE                = 5;
     SQL_DIAG_MESSAGE_TEXT          = 6;
     SQL_DIAG_DYNAMIC_FUNCTION      = 7;
     SQL_DIAG_CLASS_ORIGIN          = 8;
     SQL_DIAG_SUBCLASS_ORIGIN       = 9;
     SQL_DIAG_CONNECTION_NAME       = 10;
     SQL_DIAG_SERVER_NAME           = 11;
     SQL_DIAG_DYNAMIC_FUNCTION_CODE = 12;
{$endif}

     { dynamic function codes }
{$ifdef ODBCVER3}
     SQL_DIAG_ALTER_TABLE           =  4;
     SQL_DIAG_CREATE_INDEX          = (-1);
     SQL_DIAG_CREATE_TABLE          = 77;
     SQL_DIAG_CREATE_VIEW           = 84;
     SQL_DIAG_DELETE_WHERE          = 19;
     SQL_DIAG_DROP_INDEX            = (-2);
     SQL_DIAG_DROP_TABLE            = 32;
     SQL_DIAG_DROP_VIEW             = 36;
     SQL_DIAG_DYNAMIC_DELETE_CURSOR = 38;
     SQL_DIAG_DYNAMIC_UPDATE_CURSOR = 81;
     SQL_DIAG_GRANT                 = 48;
     SQL_DIAG_INSERT                = 50;
     SQL_DIAG_REVOKE                = 59;
     SQL_DIAG_SELECT_CURSOR         = 85;
     SQL_DIAG_UNKNOWN_STATEMENT     =  0;
     SQL_DIAG_UPDATE_WHERE          = 82;
{$endif}  { ODBCVER >= 0x0300 }

     SQL_C_DEFAULT       = 99;
     SQL_UNSIGNED_OFFSET = (-22);
     SQL_C_ULONG         = (SQL_C_LONG+SQL_UNSIGNED_OFFSET);
     SQL_C_BOOKMARK      = SQL_C_ULONG;

SQL_C_CHAR    = SQL_CHAR;           (* CHAR, VARCHAR, DECIMAL, NUMERIC *)
SQL_C_SHORT   = SQL_SMALLINT;         (* SMALLINT                     *)
SQL_C_FLOAT   = SQL_REAL    ;         (* REAL                         *)
SQL_C_DOUBLE  = SQL_DOUBLE  ;         (* FLOAT, DOUBLE                *)
SQL_C_NUMERIC = 		SQL_NUMERIC;

SQL_SIGNED_OFFSET   =      (-20)           ;
(* C datatype to SQL datatype mapping *)
SQL_C_DATE       = SQL_DATE                   ;
SQL_C_TIME       = SQL_TIME                   ;
SQL_C_TIMESTAMP  = SQL_TIMESTAMP              ;
SQL_C_TYPE_DATE	 = 				SQL_TYPE_DATE;
SQL_C_TYPE_TIME	 = 				SQL_TYPE_TIME;
SQL_C_TYPE_TIMESTAMP = 			SQL_TYPE_TIMESTAMP   ;
SQL_C_BINARY  =    SQL_BINARY                                    ;
SQL_C_BIT     =    SQL_BIT ;
SQL_C_SBIGINT = 	(SQL_BIGINT+SQL_SIGNED_OFFSET)	 ;  (* SIGNED BIGINT *)
SQL_C_UBIGINT = 	(SQL_BIGINT+SQL_UNSIGNED_OFFSET) ;  (* UNSIGNED BIGINT *)
SQL_C_TINYINT =    SQL_TINYINT                       ;
SQL_C_SLONG   =    (SQL_C_LONG+SQL_SIGNED_OFFSET)   ; (* SIGNED INTEGER  *)
SQL_C_SSHORT  =    (SQL_C_SHORT+SQL_SIGNED_OFFSET)  ; (* SIGNED SMALLINT *)
SQL_C_STINYINT=    (SQL_TINYINT+SQL_SIGNED_OFFSET)  ; (* SIGNED TINYINT  *)
SQL_C_USHORT  =    (SQL_C_SHORT+SQL_UNSIGNED_OFFSET); (* UNSIGNED SMALLINT*)
SQL_C_UTINYINT=    (SQL_TINYINT+SQL_UNSIGNED_OFFSET); (* UNSIGNED TINYINT*)


     { Statement attribute values for cursor sensitivity }
{$ifdef ODBCVER3}
     SQL_UNSPECIFIED     = 0;
     SQL_INSENSITIVE     = 1;
     SQL_SENSITIVE       = 2;
{$endif}

     { GetTypeInfo() request for all data types }
     SQL_ALL_TYPES       = 0;

     { Default conversion code for SQLBindCol(), SQLBindParam() and SQLGetData() }
{$ifdef ODBCVER3}
     SQL_DEFAULT         = 99;
{$endif}

     { SQLGetData() code indicating that the application row descriptor
       specifies the data type }
{$ifdef ODBCVER3}
     SQL_ARD_TYPE      = (-99);
{$endif}

     { SQL date/time type subcodes }
{$ifdef ODBCVER3}
     SQL_CODE_DATE       = 1;
     SQL_CODE_TIME       = 2;
     SQL_CODE_TIMESTAMP  = 3;
{$endif}

     { CLI option values }
{$ifdef ODBCVER3}
     SQL_FALSE           = 0;
     SQL_TRUE            = 1;
{$endif}

     { values of NULLABLE field in descriptor }
     SQL_NO_NULLS = 0;
     SQL_NULLABLE = 1;

{ Value returned by SQLGetTypeInfo() to denote that it is
 not known whether or not a data type supports null values. }

     SQL_NULLABLE_UNKNOWN = 2;
{
(* Values returned by SQLGetTypeInfo() to show WHERE clause
 * supported

#if (ODBCVER >= 0x0300)
#define SQL_PRED_NONE     0
#define SQL_PRED_CHAR     1
#define SQL_PRED_BASIC    2
#endif

(* values of UNNAMED field in descriptor *)
#if (ODBCVER >= 0x0300)
#define SQL_NAMED           0
#define SQL_UNNAMED         1
#endif

(* values of ALLOC_TYPE field in descriptor *)
#if (ODBCVER >= 0x0300)
#define SQL_DESC_ALLOC_AUTO 1
#define SQL_DESC_ALLOC_USER 2
#endif
}
     { FreeStmt() options }
     SQL_CLOSE        = 0;
     SQL_DROP         = 1;
     SQL_UNBIND       = 2;
     SQL_RESET_PARAMS = 3;

     { Codes used for FetchOrientation in SQLFetchScroll(),
       and in SQLDataSources() }
     SQL_FETCH_NEXT     = 1;
     SQL_FETCH_FIRST    = 2;

     { Other codes used for FetchOrientation in SQLFetchScroll() }
     SQL_FETCH_LAST     = 3;
     SQL_FETCH_PRIOR    = 4;
     SQL_FETCH_ABSOLUTE = 5;
     SQL_FETCH_RELATIVE = 6;
{
(* SQLEndTran() options *)
#define SQL_COMMIT          0
#define SQL_ROLLBACK        1

(* null handles returned by SQLAllocHandle() *)
#define SQL_NULL_HENV       0
#define SQL_NULL_HDBC       0
#define SQL_NULL_HSTMT      0
#if (ODBCVER >= 0x0300)
#define SQL_NULL_HDESC      0
#endif
}
(* null handle used in place of parent handle when allocating HENV *)
   SQL_NULL_HANDLE = 0;

(* Values that may appear in the result set of SQLSpecialColumns() *)
   SQL_SCOPE_CURROW      = 0;
   SQL_SCOPE_TRANSACTION = 1;
   SQL_SCOPE_SESSION     = 2;

(* Column types and scopes in SQLSpecialColumns.  *)
   SQL_BEST_ROWID        = 1;
   SQL_ROWVER            = 2;

{
#define SQL_PC_UNKNOWN      0
#if (ODBCVER >= 0x0300)
#define SQL_PC_NON_PSEUDO   1
#endif
#define SQL_PC_PSEUDO       2
}

(* Reserved value for the IdentifierType argument of SQLSpecialColumns() *)
{$ifdef ODBCVER3}
   SQL_ROW_IDENTIFIER = 1;
{$endif}

{
(* Reserved values for UNIQUE argument of SQLStatistics() *)
#define SQL_INDEX_UNIQUE    0
#define SQL_INDEX_ALL       1

(* Values that may appear in the result set of SQLStatistics() *)
#define SQL_INDEX_CLUSTERED 1
#define SQL_INDEX_HASHED    2
#define SQL_INDEX_OTHER     3

(* Information requested by SQLGetInfo() *)
#if (ODBCVER >= 0x0300)
#define SQL_MAX_DRIVER_CONNECTIONS           0
#define SQL_MAXIMUM_DRIVER_CONNECTIONS		SQL_MAX_DRIVER_CONNECTIONS
#define SQL_MAX_CONCURRENT_ACTIVITIES        1
#define SQL_MAXIMUM_CONCURRENT_ACTIVITIES	SQL_MAX_CONCURRENT_ACTIVITIES
#endif
#define SQL_DATA_SOURCE_NAME                 2
#define SQL_FETCH_DIRECTION                  8
#define SQL_SERVER_NAME                     13
#define SQL_SEARCH_PATTERN_ESCAPE           14
#define SQL_DBMS_NAME                       17
#define SQL_DBMS_VER                        18
#define SQL_ACCESSIBLE_TABLES               19
#define SQL_ACCESSIBLE_PROCEDURES        	20
#define SQL_CURSOR_COMMIT_BEHAVIOR          23
#define SQL_DATA_SOURCE_READ_ONLY           25
#define SQL_DEFAULT_TXN_ISOLATION           26
#define SQL_IDENTIFIER_CASE                 28
#define SQL_IDENTIFIER_QUOTE_CHAR           29
#define SQL_MAX_COLUMN_NAME_LEN             30
#define SQL_MAXIMUM_COLUMN_NAME_LENGTH		SQL_MAX_COLUMN_NAME_LEN
#define SQL_MAX_CURSOR_NAME_LEN             31
#define SQL_MAXIMUM_CURSOR_NAME_LENGTH		SQL_MAX_CURSOR_NAME_LEN
#define SQL_MAX_SCHEMA_NAME_LEN             32
#define SQL_MAXIMUM_SCHEMA_NAME_LENGTH		SQL_MAX_SCHEMA_NAME_LEN
#define SQL_MAX_CATALOG_NAME_LEN            34
#define SQL_MAXIMUM_CATALOG_NAME_LENGTH		SQL_MAX_CATALOG_NAME_LEN
#define SQL_MAX_TABLE_NAME_LEN              35
}
   SQL_SCROLL_CONCURRENCY              = 43;
   SQL_TXN_CAPABLE                     = 46;
   SQL_TRANSACTION_CAPABLE	       = SQL_TXN_CAPABLE;
   SQL_USER_NAME                       = 47;
   SQL_TXN_ISOLATION_OPTION            = 72;
   SQL_TRANSACTION_ISOLATION_OPTION    = SQL_TXN_ISOLATION_OPTION;
{
#define SQL_INTEGRITY                       73
#define SQL_GETDATA_EXTENSIONS              81
#define SQL_NULL_COLLATION                  85
#define SQL_ALTER_TABLE                     86
#define SQL_ORDER_BY_COLUMNS_IN_SELECT      90
#define SQL_SPECIAL_CHARACTERS              94
#define SQL_MAX_COLUMNS_IN_GROUP_BY         97
#define SQL_MAXIMUM_COLUMNS_IN_GROUP_BY		SQL_MAX_COLUMNS_IN_GROUP_BY
#define SQL_MAX_COLUMNS_IN_INDEX            98
#define SQL_MAXIMUM_COLUMNS_IN_INDEX		SQL_MAX_COLUMNS_IN_INDEX
#define SQL_MAX_COLUMNS_IN_ORDER_BY         99
#define SQL_MAXIMUM_COLUMNS_IN_ORDER_BY		SQL_MAX_COLUMNS_IN_ORDER_BY
#define SQL_MAX_COLUMNS_IN_SELECT          100
#define SQL_MAXIMUM_COLUMNS_IN_SELECT	   SQL_MAX_COLUMNS_IN_SELECT
#define SQL_MAX_COLUMNS_IN_TABLE           101
#define SQL_MAX_INDEX_SIZE                 102
#define SQL_MAXIMUM_INDEX_SIZE			   SQL_MAX_INDEX_SIZE
#define SQL_MAX_ROW_SIZE                   104
#define SQL_MAXIMUM_ROW_SIZE			   SQL_MAX_ROW_SIZE
#define SQL_MAX_STATEMENT_LEN              105
#define SQL_MAXIMUM_STATEMENT_LENGTH	   SQL_MAX_STATEMENT_LEN
#define SQL_MAX_TABLES_IN_SELECT           106
#define SQL_MAXIMUM_TABLES_IN_SELECT	   SQL_MAX_TABLES_IN_SELECT
#define SQL_MAX_USER_NAME_LEN              107
#define SQL_MAXIMUM_USER_NAME_LENGTH	   SQL_MAX_USER_NAME_LEN}
{$ifdef ODBCVER3}
     SQL_OJ_CAPABILITIES         = 115;
     SQL_OUTER_JOIN_CAPABILITIES = SQL_OJ_CAPABILITIES;
{$endif} { ODBCVER >= 0x0300 }

{$ifdef ODBCVER3}
     SQL_XOPEN_CLI_YEAR            = 10000;
     SQL_CURSOR_SENSITIVITY        = 10001;
     SQL_DESCRIBE_PARAMETER        = 10002;
     SQL_CATALOG_NAME              = 10003;
     SQL_COLLATION_SEQ             = 10004;
     SQL_MAX_IDENTIFIER_LEN        = 10005;
     SQL_MAXIMUM_IDENTIFIER_LENGTH = SQL_MAX_IDENTIFIER_LEN;
{$endif} { ODBCVER >= 0x0300 }

{(* SQL_ALTER_TABLE bitmasks *)
#if (ODBCVER >= 0x0200)
#define SQL_AT_ADD_COLUMN                   	0x00000001L
#define SQL_AT_DROP_COLUMN                  	0x00000002L
#endif (* ODBCVER >= 0x0200 *)

#if (ODBCVER >= 0x0300)
#define SQL_AT_ADD_CONSTRAINT               	0x00000008L

(* The following bitmasks are ODBC extensions and defined in sqlext.h
*#define	SQL_AT_COLUMN_SINGLE					0x00000020L
*#define	SQL_AT_ADD_COLUMN_DEFAULT				0x00000040L
*#define	SQL_AT_ADD_COLUMN_COLLATION				0x00000080L
*#define	SQL_AT_SET_COLUMN_DEFAULT				0x00000100L
*#define	SQL_AT_DROP_COLUMN_DEFAULT				0x00000200L
*#define	SQL_AT_DROP_COLUMN_CASCADE				0x00000400L
*#define	SQL_AT_DROP_COLUMN_RESTRICT				0x00000800L
*#define SQL_AT_ADD_TABLE_CONSTRAINT				0x00001000L
*#define SQL_AT_DROP_TABLE_CONSTRAINT_CASCADE		0x00002000L
*#define SQL_AT_DROP_TABLE_CONSTRAINT_RESTRICT		0x00004000L
*#define SQL_AT_CONSTRAINT_NAME_DEFINITION			0x00008000L
*#define SQL_AT_CONSTRAINT_INITIALLY_DEFERRED		0x00010000L
*#define SQL_AT_CONSTRAINT_INITIALLY_IMMEDIATE		0x00020000L
*#define SQL_AT_CONSTRAINT_DEFERRABLE				0x00040000L
*#define SQL_AT_CONSTRAINT_NON_DEFERRABLE			0x00080000L

#endif  (* ODBCVER >= 0x0300 *)


(* SQL_ASYNC_MODE values *)
#if (ODBCVER >= 0x0300)
#define SQL_AM_NONE                         0
#define SQL_AM_CONNECTION                   1
#define SQL_AM_STATEMENT                    2
#endif

(* SQL_CURSOR_COMMIT_BEHAVIOR values *)
#define SQL_CB_DELETE                       0
#define SQL_CB_CLOSE                        1
#define SQL_CB_PRESERVE                     2

(* SQL_FETCH_DIRECTION bitmasks *)
#define SQL_FD_FETCH_NEXT                   0x00000001L
#define SQL_FD_FETCH_FIRST                  0x00000002L
#define SQL_FD_FETCH_LAST                   0x00000004L
#define SQL_FD_FETCH_PRIOR                  0x00000008L
#define SQL_FD_FETCH_ABSOLUTE               0x00000010L
#define SQL_FD_FETCH_RELATIVE               0x00000020L

(* SQL_GETDATA_EXTENSIONS bitmasks *)
#define SQL_GD_ANY_COLUMN                   0x00000001L
#define SQL_GD_ANY_ORDER                    0x00000002L

(* SQL_IDENTIFIER_CASE values *)
#define SQL_IC_UPPER                        1
#define SQL_IC_LOWER                        2
#define SQL_IC_SENSITIVE                    3
#define SQL_IC_MIXED                        4

(* SQL_OJ_CAPABILITIES bitmasks *)
(* NB: this means 'outer join', not what  you may be thinking *)


#if (ODBCVER >= 0x0201)
#define SQL_OJ_LEFT                         0x00000001L
#define SQL_OJ_RIGHT                        0x00000002L
#define SQL_OJ_FULL                         0x00000004L
#define SQL_OJ_NESTED                       0x00000008L
#define SQL_OJ_NOT_ORDERED                  0x00000010L
#define SQL_OJ_INNER                        0x00000020L
#define SQL_OJ_ALL_COMPARISON_OPS           0x00000040L
#endif
}
{ SQL_SCROLL_CONCURRENCY bitmasks }
   SQL_SCCO_READ_ONLY                 = 1;
   SQL_SCCO_LOCK                      = 2;
   SQL_SCCO_OPT_ROWVER                = 4;
   SQL_SCCO_OPT_VALUES                = 8;

(* SQL_TXN_CAPABLE values *)
    SQL_TC_NONE                       = 0;
    SQL_TC_DML                        = 1;
    SQL_TC_ALL                        = 2;
    SQL_TC_DDL_COMMIT                 = 3;
    SQL_TC_DDL_IGNORE                 = 4;

(* SQL_TXN_ISOLATION_OPTION bitmasks *)
    SQL_TXN_READ_UNCOMMITTED         = 1;
    SQL_TRANSACTION_READ_UNCOMMITTED = SQL_TXN_READ_UNCOMMITTED;
    SQL_TXN_READ_COMMITTED           = 2;
    SQL_TRANSACTION_READ_COMMITTED   = SQL_TXN_READ_COMMITTED;
    SQL_TXN_REPEATABLE_READ          = 4;
    SQL_TRANSACTION_REPEATABLE_READ  = SQL_TXN_REPEATABLE_READ;
    SQL_TXN_SERIALIZABLE             = 8;
    SQL_TRANSACTION_SERIALIZABLE     = SQL_TXN_SERIALIZABLE;
{
(* SQL_NULL_COLLATION values *)
#define SQL_NC_HIGH                         0
#define SQL_NC_LOW                          1

}

{ SQL_STATIC_SENSITIVITY values }

    SQL_SS_ADDITIONS = 1;
    SQL_SS_DELETIONS = 2;
    SQL_SS_UPDATES   = 4;

{ SQLColAttributes defines }
    SQL_COLUMN_COUNT               = 0;
    SQL_COLUMN_NAME                = 1;
    SQL_COLUMN_TYPE                = 2;
    SQL_COLUMN_LENGTH              = 3;
    SQL_COLUMN_PRECISION           = 4;
    SQL_COLUMN_SCALE               = 5;
    SQL_COLUMN_DISPLAY_SIZE        = 6;
    SQL_COLUMN_NULLABLE            = 7;
    SQL_COLUMN_UNSIGNED            = 8;
    SQL_COLUMN_MONEY               = 9;
    SQL_COLUMN_UPDATABLE           = 10;
    SQL_COLUMN_AUTO_INCREMENT      = 11;
    SQL_COLUMN_CASE_SENSITIVE      = 12;
    SQL_COLUMN_SEARCHABLE          = 13;
    SQL_COLUMN_TYPE_NAME           = 14;
    SQL_COLUMN_TABLE_NAME          = 15;
    SQL_COLUMN_OWNER_NAME          = 16;
    SQL_COLUMN_QUALIFIER_NAME      = 17;
    SQL_COLUMN_LABEL               = 18;
    SQL_COLATT_OPT_MAX             = SQL_COLUMN_LABEL;
{$ifdef ODBCVER3}
    SQL_COLUMN_DRIVER_START        = 1000;
{$endif} { ODBCVER >= 0x0300 }
    SQL_DESC_AUTO_UNIQUE_VALUE     = SQL_COLUMN_AUTO_INCREMENT;
    SQL_DESC_BASE_COLUMN_NAME	   = 22;
    SQL_DESC_BASE_TABLE_NAME	   = 23;
    SQL_DESC_TABLE_NAME		   = SQL_COLUMN_TABLE_NAME;

(* SQLEndTran() options *)
    SQL_COMMIT    = 0;
    SQL_ROLLBACK  = 1;

    SQL_ATTR_ROW_ARRAY_SIZE = 27;

(* SQLConfigDataSource() options *)
    ODBC_ADD_DSN = 1;
    ODBC_CONFIG_DSN = 2;
    ODBC_REMOVE_DSN = 3;
    ODBC_ADD_SYS_DSN = 4;
    ODBC_CONFIG_SYS_DSN = 5;
    ODBC_REMOVE_SYS_DSN = 6;

{$ifdef DYNLOADINGODBC}

type   tSQLAllocHandle =function(HandleType: SQLSMALLINT;
           InputHandle:SQLHANDLE;Var OutputHandlePtr: SQLHANDLE):SQLRETURN;stdcall;

type   tSQLSetEnvAttr=function (EnvironmentHandle:SQLHENV;
           Attribute:SQLINTEGER;Value:SQLPOINTER;
           StringLength:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLFreeHandle=function (HandleType:SQLSMALLINT;
           Handle:SQLHANDLE):SQLRETURN;stdcall;

type   TSQLGetDiagRec=function (HandleType:SQLSMALLINT;
           Handle:SQLHANDLE;RecNumber:SQLSMALLINT;
           Sqlstate:PSQLCHAR;var NativeError:SQLINTEGER;
           MessageText:PSQLCHAR;BufferLength:SQLSMALLINT;
           var TextLength:SQLSMALLINT ):SQLRETURN;stdcall;

type   TSQLConnect=function (ConnectionHandle:SQLHDBC;
           ServerName:PSQLCHAR;NameLength1:SQLSMALLINT;
           UserName:PSQLCHAR;NameLength2:SQLSMALLINT;
           Authentication:PSQLCHAR;NameLength3:SQLSMALLINT):SQLRETURN;stdcall;

type   TSQLDisconnect=function(ConnectionHandle:SQLHDBC):SQLRETURN;stdcall;

type   TSQLDriverConnect=function (hdbc: SQLHDBC;
           hwnd: Integer;szCsin: PChar;
           szCLen: SQLSMALLINT;szCsout: PChar;
           cbCSMax: SQLSMALLINT;Var cbCsOut: SQLSMALLINT;
           f: Integer):SQLRETURN;stdcall;

type   TSQLExecDirect=function (StatementHandle:SQLHSTMT;
           StatementText:PSQLCHAR;TextLength:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLPrepare=function (StatementHandle:SQLHSTMT;
           StatementText:PSQLCHAR;TextLength:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLCloseCursor=function (StatementHandle:SQLHSTMT):SQLRETURN;stdcall;

type   TSQLExecute=function (StatementHandle:SQLHSTMT):SQLRETURN;stdcall;

type   TSQLFetch=function (StatementHandle:SQLHSTMT):SQLRETURN;stdcall;

type   TSQLNumResultCols=function (StatementHandle:SQLHSTMT;
           var ColumnCount:SQLSMALLINT):SQLRETURN;stdcall;

type   TSQLDescribeCol=function (StatementHandle:SQLHSTMT;
           ColumnNumber:SQLUSMALLINT;ColumnName:PSQLCHAR;
           BufferLength:SQLSMALLINT;var NameLength:SQLSMALLINT;
           var DataType:SQLSMALLINT;var ColumnSize:SQLUINTEGER;
           var DecimalDigits:SQLSMALLINT;var Nullable:SQLSMALLINT):SQLRETURN;stdcall;

type   TSQLFetchScroll=function (StatementHandle:SQLHSTMT;
           FetchOrientation:SQLSMALLINT;FetchOffset:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLExtendedFetch=function (hstmt:SQLHSTMT;
           fFetchType:SQLUSMALLINT;irow:SQLINTEGER;
           pcrow:PSQLUINTEGER;rgfRowStatus:PSQLUSMALLINT):SQLRETURN;stdcall;

type   TSQLGetData=function (StatementHandle:SQLHSTMT;
           ColumnNumber:SQLUSMALLINT;TargetType:SQLSMALLINT;
           TargetValue:SQLPOINTER;BufferLength:SQLINTEGER;
           StrLen_or_Ind:PSQLINTEGER):SQLRETURN;stdcall;

type   TSQLSetStmtAttr=function (StatementHandle:SQLHSTMT;
           Attribute:SQLINTEGER;Value:SQLPOINTER;
           StringLength:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLGetStmtAttr=function (StatementHandle:SQLHSTMT;
           Attribute:SQLINTEGER;Value:SQLPOINTER;
           BufferLength:SQLINTEGER;StringLength:PSQLINTEGER):SQLRETURN;stdcall;

type   tSQLGetInfo=function (ConnectionHandle:SQLHDBC;
           InfoType:SQLUSMALLINT;InfoValue:SQLPOINTER;
           BufferLength:SQLSMALLINT;StringLength:PSQLSMALLINT):SQLRETURN;stdcall;

type   TSQLBulkOperations=function (StatementHandle: SQLHSTMT;
           Operation:SQLSMALLINT):SQLRETURN;stdcall;

type   TSQLPutData=function (StatementHandle:SQLHSTMT;
           Data:SQLPOINTER;StrLen_or_Ind:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLBindCol=function (StatementHandle:SQLHSTMT;
           ColumnNumber:SQLUSMALLINT;TargetType:SQLSMALLINT;
           TargetValue:SQLPOINTER;BufferLength:SQLINTEGER;
           StrLen_or_Ind:PSQLINTEGER):SQLRETURN;stdcall;

type   TSQLSetPos=function (hstmt:SQLHSTMT;
           irow:SQLUSMALLINT;fOption:SQLUSMALLINT;
           fLock:SQLUSMALLINT):SQLRETURN;stdcall;

type   TSQLDataSources=function (EnvironmentHandle:SQLHENV;
           Direction:SQLUSMALLINT;ServerName:PSQLCHAR;
           BufferLength1:SQLSMALLINT;NameLength1:PSQLSMALLINT;
           Description:PSQLCHAR;BufferLength2:SQLSMALLINT;
           NameLength2:PSQLSMALLINT):SQLRETURN;stdcall;

type   TSQLDrivers=function (EnvironmentHandle:SQLHENV;
           Direction:SQLUSMALLINT;DriverDescription:PSQLCHAR;
           BufferLength1:SQLSMALLINT;DescriptionLength1:PSQLSMALLINT;
           DriverAttributes:PSQLCHAR;BufferLength2:SQLSMALLINT;
           AttributesLength2:PSQLSMALLINT):SQLRETURN;stdcall;

type   TSQLSetConnectAttr=function (ConnectionHandle:SQLHDBC;
           Attribute:SQLINTEGER; Value:SQLPOINTER;
           StringLength:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLGetCursorName=function (StatementHandle:SQLHSTMT;
           CursorName:PSQLCHAR; BufferLength:SQLSMALLINT;
           NameLength:PSQLSMALLINT):SQLRETURN;stdcall;

type   TSQLSetCursorName=function (StatementHandle:SQLHSTMT;
           CursorName:PSQLCHAR; NameLength:SQLSMALLINT):SQLRETURN;stdcall;

type   TSQLRowCount=function (StatementHandle:SQLHSTMT;
           Var RowCount:SQLINTEGER):SQLRETURN;stdcall;

type   TSQLBindParameter=function (hstmt:SQLHSTMT;
           ipar:SQLUSMALLINT;fParamType:SQLSMALLINT;
           fCType:SQLSMALLINT;fSqlType:SQLSMALLINT;
           cbColDef:SQLUINTEGER;ibScale:SQLSMALLINT;
           rgbValue:SQLPOINTER;cbValueMax:SQLINTEGER;
           pcbValue:PSQLINTEGER):SQLRETURN;stdcall;

type   TSQLFreeStmt=function (StatementHandle:SQLHSTMT;
           Option:SQLUSMALLINT):SQLRETURN;stdcall;

type   TSQLColAttribute=function (StatementHandle:SQLHSTMT;
           ColumnNumber:SQLUSMALLINT;FieldIdentifier:SQLUSMALLINT;
           CharacterAttribute:PSQLCHAR;BufferLength:SQLSMALLINT;
           StringLength:PSQLSMALLINT;NumericAttribute:SQLPOINTER):SQLRETURN;stdcall;

type   TSQLEndTran=function (HandleType:SQLSMALLINT;
           Handle:SQLHANDLE;CompletionType:SQLSMALLINT):SQLRETURN;stdcall;

type   TSQLTables=function ( hstmt : SQLHSTMT;
           szTableQualifier : PSQLCHAR;cbTableQualifier : SQLSMALLINT;
           szTableOwner : PSQLCHAR;cbTableOwner : SQLSMALLINT;
           szTableName : PSQLCHAR;cbTableName : SQLSMALLINT;
           szTableType : PSQLCHAR;cbTableType : SQLSMALLINT ) : SQLRETURN; stdcall;

type   TSQLColumns=function ( hstmt : SQLHSTMT;
           szTableQualifier : PSQLCHAR;cbTableQualifier : SQLSMALLINT;
           szTableOwner : PSQLCHAR;cbTableOwner : SQLSMALLINT;
           szTableName : PSQLCHAR;cbTableName : SQLSMALLINT;
           szColumnName : PSQLCHAR;cbColumnName : SQLSMALLINT ) : SQLRETURN; stdcall;

type   TSQLSpecialColumns=function (StatementHandle:SQLHSTMT;
           IdentifierType:SQLUSMALLINT;CatalogName:PSQLCHAR;
           NameLength1:SQLSMALLINT;SchemaName:PSQLCHAR;
           NameLength2:SQLSMALLINT;TableName:PSQLCHAR;
           NameLength3:SQLSMALLINT;Scope:SQLUSMALLINT;
           Nullable:SQLUSMALLINT) : SQLRETURN; stdcall;

type   TSQLProcedures=function ( hstmt : SQLHSTMT;
           szTableQualifier : PSQLCHAR;cbTableQualifier : SQLSMALLINT;
           szTableOwner : PSQLCHAR;cbTableOwner : SQLSMALLINT;
           szTableName : PSQLCHAR;cbTableName : SQLSMALLINT ) : SQLRETURN; stdcall;

type   TSQLPrimaryKeys=function (hstmt : SQLHSTMT;
           CatalogName:PSQLCHAR;NameLength1:SQLSMALLINT;
           SchemaName:PSQLCHAR;NameLength2:SQLSMALLINT;
           TableName:PSQLCHAR;NameLength3:SQLSMALLINT ):SQLRETURN;stdcall;

var    SQLAllocHandle:tSQLAllocHandle;
var    SQLSetEnvAttr:tSQLSetEnvAttr;
var    SQLFreeHandle:tSQLFreeHandle;
var    SQLGetInfo:tSQLGetInfo;
var    SQLProcedures:TSQLProcedures;
var    SQLColumns:TSQLColumns;
var    SQLSpecialColumns:TSQLSpecialColumns;
var    SQLGetDiagRec:TSQLGetDiagRec;
var    SQLConnect:TSQLConnect;
var    SQLDisconnect:TSQLDisconnect;
var    SQLDriverConnect:TSQLDriverConnect;
var    SQLExecDirect:TSQLExecDirect;
var    SQLPrepare:TSQLPrepare;
var    SQLCloseCursor:TSQLCloseCursor;
var    SQLExecute:TSQLExecute;
var    SQLFetch:TSQLFetch;
var    SQLNumResultCols:TSQLNumResultCols;
var    SQLDescribeCol:TSQLDescribeCol;
var    SQLFetchScroll:TSQLFetchScroll;
var    SQLExtendedFetch:TSQLExtendedFetch;
var    SQLGetData:TSQLGetData;
var    SQLSetStmtAttr:TSQLSetStmtAttr;
var    SQLGetStmtAttr:TSQLGetStmtAttr;
var    SQLBulkOperations:TSQLBulkOperations;
var    SQLPutData:TSQLPutData;
var    SQLBindCol:TSQLBindCol;
var    SQLSetPos:TSQLSetPos;
var    SQLDataSources:TSQLDataSources;
var    SQLDrivers:TSQLDrivers;
var    SQLSetConnectAttr:TSQLSetConnectAttr;
var    SQLGetCursorName:TSQLGetCursorName;
var    SQLSetCursorName:TSQLSetCursorName;
var    SQLRowCount:TSQLRowCount;
var    SQLBindParameter:TSQLBindParameter;
var    SQLFreeStmt:TSQLFreeStmt;
var    SQLColAttribute:TSQLColAttribute;
var    SQLEndTran:TSQLEndTran;
var    SQLTables:TSQLTables;
var    SQLPrimaryKeys:TSQLPrimaryKeys;
var    odbcversion:word;

{$else}

  function SQLAllocHandle(
               HandleType: SQLSMALLINT;
               InputHandle:SQLHANDLE;
               Var OutputHandlePtr: SQLHANDLE):SQLRETURN;stdcall;external 'ODBC32.DLL';
  function SQLSetEnvAttr(
               EnvironmentHandle:SQLHENV;
               Attribute:        SQLINTEGER;
               Value:            SQLPOINTER;
               StringLength:     SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLFreeHandle(
               HandleType: SQLSMALLINT;
               Handle:     SQLHANDLE):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLGetDiagRec(
               HandleType:   SQLSMALLINT;
               Handle:       SQLHANDLE;
               RecNumber:    SQLSMALLINT;
               Sqlstate:     PSQLCHAR;
               var NativeError: SQLINTEGER;
               MessageText:     PSQLCHAR;
               BufferLength:    SQLSMALLINT;
               var TextLength:  SQLSMALLINT ):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLConnect(
               ConnectionHandle:SQLHDBC;
               ServerName:PSQLCHAR;    NameLength1:SQLSMALLINT;
               UserName:PSQLCHAR;      NameLength2:SQLSMALLINT;
               Authentication:PSQLCHAR;NameLength3:SQLSMALLINT
              ):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLDisconnect(
               ConnectionHandle:SQLHDBC):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLDriverConnect(
               hdbc: SQLHDBC;
               hwnd: Integer;
               szCsin: PChar;
               szCLen: SQLSMALLINT;
               szCsout: PChar;
               cbCSMax: SQLSMALLINT;
               Var cbCsOut: SQLSMALLINT;
               f: Integer):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLExecDirect(
               StatementHandle:SQLHSTMT;
               StatementText:  PSQLCHAR;
               TextLength:     SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLPrepare(
               StatementHandle:SQLHSTMT;
               StatementText:PSQLCHAR;
               TextLength:SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLCloseCursor(
               StatementHandle:SQLHSTMT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLExecute(
               StatementHandle:SQLHSTMT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLFetch(
               StatementHandle:SQLHSTMT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLNumResultCols(
               StatementHandle:SQLHSTMT;
               var ColumnCount:SQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLDescribeCol(
               StatementHandle:SQLHSTMT;
               ColumnNumber:SQLUSMALLINT;
               ColumnName:PSQLCHAR;
               BufferLength:SQLSMALLINT;
               var NameLength:SQLSMALLINT;
               var DataType:SQLSMALLINT;
               var ColumnSize:SQLUINTEGER;
               var DecimalDigits:SQLSMALLINT;
               var Nullable:SQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLFetchScroll(
               StatementHandle:SQLHSTMT;
               FetchOrientation:SQLSMALLINT;
               FetchOffset:SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLExtendedFetch(
               hstmt:SQLHSTMT;
               fFetchType:SQLUSMALLINT;
               irow:SQLINTEGER;
               pcrow:PSQLUINTEGER;
               rgfRowStatus:PSQLUSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLGetData(
               StatementHandle:SQLHSTMT;
               ColumnNumber:SQLUSMALLINT;
               TargetType:SQLSMALLINT;
               TargetValue:SQLPOINTER;
               BufferLength:SQLINTEGER;
               StrLen_or_Ind:PSQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLSetStmtAttr(
               StatementHandle:SQLHSTMT;
               Attribute:SQLINTEGER;
               Value:SQLPOINTER;
               StringLength:SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLGetStmtAttr(
               StatementHandle:SQLHSTMT;
               Attribute:SQLINTEGER;
               Value:SQLPOINTER;
               BufferLength:SQLINTEGER;
               StringLength:PSQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLGetInfo(
               ConnectionHandle:SQLHDBC;
               InfoType:SQLUSMALLINT;
               InfoValue:SQLPOINTER;
               BufferLength:SQLSMALLINT;
               StringLength:PSQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLBulkOperations(
               StatementHandle: SQLHSTMT;
               Operation:SQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLPutData(
               StatementHandle:SQLHSTMT;
               Data:SQLPOINTER;
               StrLen_or_Ind:SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLBindCol(
               StatementHandle:SQLHSTMT;
	       ColumnNumber:SQLUSMALLINT;
               TargetType:SQLSMALLINT;
	       TargetValue:SQLPOINTER;
               BufferLength:SQLINTEGER;
	       StrLen_or_Ind:PSQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLSetPos(
               hstmt:SQLHSTMT;
               irow:SQLUSMALLINT;
               fOption:SQLUSMALLINT;
               fLock:SQLUSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLDataSources(
               EnvironmentHandle:SQLHENV;
               Direction:SQLUSMALLINT;
               ServerName:PSQLCHAR;
               BufferLength1:SQLSMALLINT;
               NameLength1:PSQLSMALLINT;
               Description:PSQLCHAR;
               BufferLength2:SQLSMALLINT;
               NameLength2:PSQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLDrivers(
               EnvironmentHandle:SQLHENV;
               Direction:SQLUSMALLINT;
               DriverDescription:PSQLCHAR;
               BufferLength1:SQLSMALLINT;
               DescriptionLength1:PSQLSMALLINT;
               DriverAttributes:PSQLCHAR;
               BufferLength2:SQLSMALLINT;
               AttributesLength2:PSQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLSetConnectAttr(
               ConnectionHandle:SQLHDBC;
               Attribute:SQLINTEGER; Value:SQLPOINTER;
               StringLength:SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLGetCursorName(
               StatementHandle:SQLHSTMT;
               CursorName:PSQLCHAR; BufferLength:SQLSMALLINT;
               NameLength:PSQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLSetCursorName(
               StatementHandle:SQLHSTMT;
               CursorName:PSQLCHAR; NameLength:SQLSMALLINT
               ):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLRowCount(
               StatementHandle:SQLHSTMT;
	       Var RowCount:SQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLBindParameter(
               hstmt:SQLHSTMT;
               ipar:SQLUSMALLINT;
               fParamType:SQLSMALLINT;
               fCType:SQLSMALLINT;
               fSqlType:SQLSMALLINT;
               cbColDef:SQLUINTEGER;
               ibScale:SQLSMALLINT;
               rgbValue:SQLPOINTER;
               cbValueMax:SQLINTEGER;
               pcbValue:PSQLINTEGER):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLFreeStmt(
               StatementHandle:SQLHSTMT;
               Option:SQLUSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
   function SQLColAttribute (
               StatementHandle:SQLHSTMT;
               ColumnNumber:SQLUSMALLINT;
               FieldIdentifier:SQLUSMALLINT;
               CharacterAttribute:PSQLCHAR;
               BufferLength:SQLSMALLINT;
               StringLength:PSQLSMALLINT;
               NumericAttribute:SQLPOINTER):SQLRETURN;stdcall;external 'ODBC32.DLL';
{$ifdef ODBCVER3}
   function SQLEndTran(
               HandleType:SQLSMALLINT;
               Handle:SQLHANDLE;
               CompletionType:SQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
{$endif}
   function SQLTables( hstmt : SQLHSTMT;
                szTableQualifier : PSQLCHAR;
                cbTableQualifier : SQLSMALLINT;
                szTableOwner : PSQLCHAR;
                cbTableOwner : SQLSMALLINT;
                szTableName : PSQLCHAR;
                cbTableName : SQLSMALLINT;
                szTableType : PSQLCHAR;
                cbTableType : SQLSMALLINT ) : SQLRETURN; stdcall; external 'ODBC32.DLL';
   function SQLColumns( hstmt : SQLHSTMT;
    		szTableQualifier : PSQLCHAR;
                cbTableQualifier : SQLSMALLINT;
                szTableOwner : PSQLCHAR;
                cbTableOwner : SQLSMALLINT;
                szTableName : PSQLCHAR;
                cbTableName : SQLSMALLINT;
                szColumnName : PSQLCHAR;
                cbColumnName : SQLSMALLINT ) : SQLRETURN; stdcall; external 'ODBC32.DLL';
   function SQLSpecialColumns(StatementHandle:SQLHSTMT;
                IdentifierType:SQLUSMALLINT;
                CatalogName:PSQLCHAR;
                NameLength1:SQLSMALLINT;
                SchemaName:PSQLCHAR;
                NameLength2:SQLSMALLINT;
                TableName:PSQLCHAR;
                NameLength3:SQLSMALLINT;
                Scope:SQLUSMALLINT;
                Nullable:SQLUSMALLINT) : SQLRETURN; stdcall; external 'ODBC32.DLL';
   function SQLProcedures( hstmt : SQLHSTMT;
                szTableQualifier : PSQLCHAR;
                cbTableQualifier : SQLSMALLINT;
                szTableOwner : PSQLCHAR;
                cbTableOwner : SQLSMALLINT;
                szTableName : PSQLCHAR;
                cbTableName : SQLSMALLINT ) : SQLRETURN; stdcall; external 'ODBC32.DLL';
   function SQLPrimaryKeys(hstmt : SQLHSTMT;
                CatalogName:PSQLCHAR;NameLength1:SQLSMALLINT;
                SchemaName:PSQLCHAR;NameLength2:SQLSMALLINT;
                TableName:PSQLCHAR;
                NameLength3:SQLSMALLINT):SQLRETURN;stdcall;external 'ODBC32.DLL';
{$endif}
// This function always load dynamic
type   TSQLConfigDataSource=function (
           hwndParent:       Integer;
           fRequest:         Integer;
           lpszDriverString: String;
           lpszAttributes:   String): SQLRETURN;stdcall;
       TSQLInstallerError=function (
               iError:          SQLUSMALLINT;
               pfErrorCode:     PSQLINTEGER;
               lpszErrorMsg:    PCHAR;
               cbErrorMsgMax:   SQLUSMALLINT;
               pcbErrorMsg:     PSQLUSMALLINT): SQLRETURN;stdcall;
function SQLConfigDataSource(
               hwndParent:       Integer;
               fRequest:         Integer;
               lpszDriverString: String;
               lpszAttributes:   String): Integer;stdcall;
function SQLInstallerError(
               iError:          SQLUSMALLINT;
               pfErrorCode:     PSQLINTEGER;
               lpszErrorMsg:    PCHAR;
               cbErrorMsgMax:   SQLUSMALLINT;
               pcbErrorMsg:     PSQLUSMALLINT): SQLRETURN;

function DateStructToDateTime( b:PSQL_DATE_STRUCT):TDateTime;
function DateTimeToDateStruct( b:TDateTime):SQL_DATE_STRUCT;
procedure DateTime2TimeStampStruct( var Value:SQL_TIMESTAMP_STRUCT; b:TDateTime);

function LoadOdbc: Boolean;
procedure UnLoadOdbc;

implementation
uses Windows,SysUtils;

{$IFDEF VER110}
{$HPPEMIT '#pragma comment(lib,"odbc32.lib")'}
{$ENDIF}

Var
{$IFDEF DYNLOADINGODBC}
   OdbcHMODULE:  HMODULE;
{$ENDIF}
   OdbccpHMODULE:HMODULE;

function DateStructToDateTime( b:PSQL_DATE_STRUCT):TDateTime;
begin
     Result:=EncodeDate( b^.Year, b^.Month, b^.Day);
end;

function DateTimeToDateStruct( b:TDateTime):SQL_DATE_STRUCT;
Var
   y,m,d: Word;
begin
     DecodeDate( b, y, m, d);
     with Result do
     begin
          Year:=y; Month:=m; Day:=d;
     end;
end;

procedure DateTime2TimeStampStruct( var Value:SQL_TIMESTAMP_STRUCT; b:TDateTime);
Var
   w1,w2,w3,w4: Word;
begin
               with Value do
               begin
                    DecodeDate(b,w1,w2,w3);
                    Year:=  w1;
                    Month:= w2;
                    Day:=   w3;
                    DecodeTime(b,w1,w2,w3,w4);
                    Hour:=  w1;
                    Minute:=w2;
                    Second:=w3;
                    fraction:=Integer(w4)*1000000;
               end;
end;

{$ifdef DYNLOADINGODBC}

Function GetODBCVersion(Odbc:HMODULE; var version: word):boolean;
var
   lpFilename:pchar;
//   t:integer;
   tmp,lpdwHandle:cardinal;
   F,lpData:pointer;
begin
   Result := False;
   getmem(lpFilename,255);
   if GetModuleFileName(Odbc,lpFilename,254)=0 then begin Freemem(lpFilename,255); Exit end;
   lpdwHandle:=GetFileVersionInfoSize(lpFilename,tmp);
   getmem(lpdata,lpdwHandle);
   version:=0;
   if GetFileVersionInfo(lpFilename,0,lpdwHandle,lpData) then begin
       tmp:=sizeof(tagVS_FIXEDFILEINFO);
       VerQueryValue(lpData,'\',f,tmp);
       version:=hiword(PVSFixedFileInfo(f).dwProductVersionMS)*256+Loword(PVSFixedFileInfo(f).dwProductVersionMS);
   end;
   Freemem(lpdata,lpdwHandle);
   Freemem(lpFilename,255);
   Result := True;
end;

Function GetAdresstoFunction(const funcname:string; var adr): Boolean;
begin
   FARPROC(adr):=GetProcAddress(OdbcHMODULE,pchar(funcname));
   Result := FARPROC(adr) <> nil;
end;
{$endif}

function LoadOdbc: Boolean;
begin
{$ifdef DYNLOADINGODBC}
   if OdbcHMODULE<>0 then begin Result := True; exit; end;
   Result := False;
   OdbcHMODULE:=LoadLibrary('ODBC32.DLL');
   if OdbcHMODULE=0 then Exit;
   if not GetODBCVersion(OdbcHMODULE, odbcversion) then
   begin
     FreeLibrary(OdbcHMODULE); OdbcHMODULE := 0; Exit;
   end;

//Here we know the version of the odbc driver. eg '3.5'

   if not GetAdresstoFunction('SQLAllocHandle', SQLAllocHandle) or
      not GetAdresstoFunction('SQLSetEnvAttr', SQLSetEnvAttr) or
      not GetAdresstoFunction('SQLFreeHandle', SQLFreeHandle) or
      not GetAdresstoFunction('SQLGetInfo', SQLGetInfo) or
      not GetAdresstoFunction('SQLProcedures', SQLProcedures) or
      not GetAdresstoFunction('SQLColumns', SQLColumns) or
      not GetAdresstoFunction('SQLSpecialColumns', SQLSpecialColumns) or
      not GetAdresstoFunction('SQLGetDiagRec', SQLGetDiagRec) or
      not GetAdresstoFunction('SQLConnect', SQLConnect) or
      not GetAdresstoFunction('SQLDisconnect', SQLDisconnect) or
      not GetAdresstoFunction('SQLDriverConnect', SQLDriverConnect) or
      not GetAdresstoFunction('SQLExecDirect', SQLExecDirect) or
      not GetAdresstoFunction('SQLPrepare', SQLPrepare) or
      not GetAdresstoFunction('SQLCloseCursor', SQLCloseCursor) or
      not GetAdresstoFunction('SQLExecute', SQLExecute) or
      not GetAdresstoFunction('SQLFetch', SQLFetch) or 
      not GetAdresstoFunction('SQLNumResultCols', SQLNumResultCols) or 
      not GetAdresstoFunction('SQLDescribeCol', SQLDescribeCol) or 
      not GetAdresstoFunction('SQLFetchScroll', SQLFetchScroll) or 
      not GetAdresstoFunction('SQLExtendedFetch', SQLExtendedFetch) or 
      not GetAdresstoFunction('SQLGetData', SQLGetData) or
      not GetAdresstoFunction('SQLSetStmtAttr', SQLSetStmtAttr) or
      not GetAdresstoFunction('SQLGetStmtAttr', SQLGetStmtAttr) or 
      not GetAdresstoFunction('SQLBulkOperations', SQLBulkOperations) or 
      not GetAdresstoFunction('SQLPutData', SQLPutData) or 
      not GetAdresstoFunction('SQLBindCol', SQLBindCol) or 
      not GetAdresstoFunction('SQLSetPos', SQLSetPos) or 
      not GetAdresstoFunction('SQLDataSources', SQLDataSources) or 
      not GetAdresstoFunction('SQLDrivers', SQLDrivers) or 
      not GetAdresstoFunction('SQLSetConnectAttr', SQLSetConnectAttr) or 
      not GetAdresstoFunction('SQLGetCursorName', SQLGetCursorName) or 
      not GetAdresstoFunction('SQLSetCursorName', SQLSetCursorName) or 
      not GetAdresstoFunction('SQLRowCount', SQLRowCount) or 
      not GetAdresstoFunction('SQLBindParameter', SQLBindParameter) or 
      not GetAdresstoFunction('SQLFreeStmt', SQLFreeStmt) or 
      not GetAdresstoFunction('SQLColAttribute', SQLColAttribute) or 
      not GetAdresstoFunction('SQLEndTran', SQLEndTran) or 
      not GetAdresstoFunction('SQLTables', SQLTables) or 
      not GetAdresstoFunction('SQLPrimaryKeys', SQLPrimaryKeys) then
   begin
     FreeLibrary(OdbcHMODULE); OdbcHMODULE := 0; Exit;
   end;
   Result := True;






































{$endif}
end;

procedure UnLoadOdbc;
begin
{$ifdef DYNLOADINGODBC}
   if  OdbcHMODULE<>0 then begin
       if not FreeLibrary(OdbcHMODULE) then begin
           raise Exception.create(syserrormessage(GetLastError));
       end;
   end;
   OdbcHMODULE:=0;
{$endif}
   if  OdbccpHMODULE<>0 then begin
       if not FreeLibrary(OdbccpHMODULE) then begin
           raise Exception.create(syserrormessage(GetLastError));
       end;
   end;
   OdbccpHMODULE:=0;
end;

//  function SQLConfigDataSource(
//               hwndParent:       Integer;
//               fRequest:         Integer;
//               lpszDriverString: String;
//               lpszAttributes:   String): Integer;stdcall;external 'ODBCCP32.DLL';

function SQLConfigDataSource(
               hwndParent:       Integer;
               fRequest:         Integer;
               lpszDriverString: String;
               lpszAttributes:   String): Integer;stdcall;
var
   func: TSQLConfigDataSource;
begin
   if OdbccpHMODULE=0 then
    begin
       OdbccpHMODULE:=LoadLibrary('ODBCCP32.DLL');
       if OdbccpHMODULE=0
        then raise Exception.create(syserrormessage(GetLastError));
    end;
   func:=GetProcAddress(OdbccpHMODULE,pchar('SQLConfigDataSource'));
   if @func=nil then
    raise Exception.create('Error Getting adress for SQLConfigDataSource; '+syserrormessage(GetLastError));
   Result:=func(hwndParent,fRequest,lpszDriverString,lpszAttributes);
end;

//SQLRETURN INSTAPI SQLInstallerError(WORD iError,
//					DWORD *pfErrorCode,
//					LPSTR	lpszErrorMsg,
//					WORD	cbErrorMsgMax,
//					WORD	*pcbErrorMsg);
function SQLInstallerError(
               iError:          SQLUSMALLINT;
               pfErrorCode:     PSQLINTEGER;
               lpszErrorMsg:    PCHAR;
               cbErrorMsgMax:   SQLUSMALLINT;
               pcbErrorMsg:     PSQLUSMALLINT): SQLRETURN;
var
   func: TSQLInstallerError;
begin
   if OdbccpHMODULE=0 then
    begin
       OdbccpHMODULE:=LoadLibrary('ODBCCP32.DLL');
       if OdbccpHMODULE=0
        then raise Exception.create(syserrormessage(GetLastError));
    end;
   func:=GetProcAddress(OdbccpHMODULE,pchar('SQLInstallerError'));
   if @func=nil then
    raise Exception.create('Error Getting adress for SQLInstallerError; '+syserrormessage(GetLastError));
   Result:=func(iError,pfErrorCode,lpszErrorMsg,cbErrorMsgMax,pcbErrorMsg);
end;

end.
