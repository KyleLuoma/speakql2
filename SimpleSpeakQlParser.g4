parser grammar SimpleSpeakQlParser;
options { tokenVocab=SimpleSpeakQlLexer; }

schrodinger
    : SCHRODINGER
    ;

selectStatement
    : querySpecification lockClause?                                                            #simpleSelect
    | queryExpression lockClause?                                                               #parenthesisSelect
    | querySpecificationNointo unionStatement+
        ( UNION unionType=(ALL | DISTINCT)? (querySpecification
    | queryExpression) )? orderByClause? limitClause? lockClause?                               #unionSelect
    | queryExpressionNointo unionParenthesis+
        ( UNION unionType=(ALL | DISTINCT)? queryExpression )?
        orderByClause? limitClause? lockClause?                                                 #unionParenthesisSelect
    ;

querySpecification
    : queryOrderSpecification selectModifierExpression                                        #singleQuerySpecification
    | multiJoinExpression? expressionDelimiter? multiQueryOrderSpecification
        ( expressionDelimiter ( multiQueryOrderSpecification | multiJoinExpression) )*
        selectModifierExpression                                                              #multiQuerySpecification
    ;


queryOrderSpecification //SPEAKQL FEATURE: Alternate expression ordering
    : selectExpression (whereKeyword whereExpression)? tableExpression
    | selectExpression tableExpression (whereKeyword whereExpression)?
    | tableExpression selectExpression (whereKeyword whereExpression)?
    | tableExpression (whereKeyword whereExpression)? selectExpression
    ;

multiQueryOrderSpecification
    : selectExpression (whereKeyword whereExpression)? tableExpressionNoJoin
    | selectExpression tableExpressionNoJoin (whereKeyword whereExpression)?
    | tableExpressionNoJoin selectExpression (whereKeyword whereExpression)?
    | tableExpressionNoJoin (whereKeyword whereExpression)? selectExpression
    ;



selectExpression
    : selectClause selectSpec* selectElements selectIntoExpression?
    | selectClause selectSpec* selectElements
    ;

selectClause
    : selectKeyword
    ;


selectKeyword //SPEAKQL FEATURE: SELECT keyword synonyms
    : SELECT | RETRIEVE | SHOW_ME | DISPLAY | PRESENT | FIND | GET
    ;

selectSpec
    : (ALL | DISTINCT | DISTINCTROW)
    | HIGH_PRIORITY | STRAIGHT_JOIN | SQL_SMALL_RESULT | SQL_BIG_RESULT
    | SQL_BUFFER_RESULT | (SQL_CACHE | SQL_NO_CACHE) | SQL_CALC_FOUND_ROWS
    ;

selectElements
    : (star='*' | selectElement ) (selectElementDelimiter selectElement)*
    ;

selectElement
    : fullId selectElementDot '*'                                   #selectStarElement
    | fullColumnName (selectElementAs? uid)?                        #selectColumnElement
    | functionCall (selectElementAs? uid)?                          #selectFunctionElement
    | (LOCAL_ID VAR_ASSIGN)? expression (selectElementAs? uid)?     #selectExpressionElement
    ;

fullId
    : uid (DOT_ID | '.' uid)?
    ;

uid
    : simpleId
    ; //| DOUBLE_QUOTE_ID | REVERSE_QUOTE_ID | CHARSET_REVERSE_QOUTE_STRING ;

simpleId
    : ID | charsetNameBase | transactionLevelBase | engineName
    | privilegesBase | intervalTypeBase | dataTypeBase
    | keywordsCanBeId | functionNameBase
    ;

charsetNameBase
    : ARMSCII8 | ASCII | BIG5 | BINARY | CP1250 | CP1251 | CP1256 | CP1257 | CP850 | CP852
    | CP866 | CP932 | DEC8 | EUCJPMS | EUCKR | GB18030 | GB2312 | GBK | GEOSTD8 | GREEK
    | HEBREW | HP8 | KEYBCS2 | KOI8R | KOI8U | LATIN1 | LATIN2 | LATIN5 | LATIN7 | MACCE
    | MACROMAN | SJIS | SWE7 | TIS620 | UCS2 | UJIS | UTF16 | UTF16LE | UTF32 | UTF8 | UTF8MB3 | UTF8MB4
    ;

transactionLevelBase
    : REPEATABLE | COMMITTED | UNCOMMITTED | SERIALIZABLE
    ;

engineName
    : ARCHIVE | BLACKHOLE | CSV | FEDERATED | INNODB | MEMORY | MRG_MYISAM | MYISAM | NDB | NDBCLUSTER
    | PERFORMANCE_SCHEMA | TOKUDB | ID | STRING_LITERAL | REVERSE_QUOTE_ID | CONNECT
    ;

privilegesBase
    : TABLES | ROUTINE | EXECUTE | FILE | PROCESS | RELOAD | SHUTDOWN | SUPER | PRIVILEGES
    ;

intervalTypeBase
    : QUARTER | MONTH | DAY | HOUR | MINUTE | WEEK | SECOND | MICROSECOND
    ;

dataTypeBase
    : DATE | TIME | TIMESTAMP | DATETIME | YEAR | ENUM | TEXT
    ;

keywordsCanBeId
    : ACCOUNT | ACTION | AFTER | AGGREGATE | ALGORITHM | ANY | AT | AUDIT_ADMIN | AUTHORS | AUTOCOMMIT
    | AUTOEXTEND_SIZE | AUTO_INCREMENT | AVG | AVG_ROW_LENGTH | BACKUP_ADMIN | BEGIN | BINLOG | BINLOG_ADMIN
    | BINLOG_ENCRYPTION_ADMIN | BIT | BIT_AND | BIT_OR | BIT_XOR | BLOCK | BOOL | BOOLEAN | BTREE | CACHE
    | CASCADED | CHAIN | CHANGED | CHANNEL | CHECKSUM | PAGE_CHECKSUM | CATALOG_NAME | CIPHER | CLASS_ORIGIN | CLIENT
    | CLONE_ADMIN | CLOSE | COALESCE | CODE | COLUMNS | COLUMN_FORMAT | COLUMN_NAME | COMMENT | COMMIT | COMPACT
    | COMPLETION | COMPRESSED | COMPRESSION | CONCURRENT | CONNECT | CONNECTION | CONNECTION_ADMIN | CONSISTENT
    | CONSTRAINT_CATALOG | CONSTRAINT_NAME | CONSTRAINT_SCHEMA | CONTAINS | CONTEXT | CONTRIBUTORS | COPY | COUNT
    | CPU | CURRENT | CURSOR_NAME | DATA | DATAFILE | DEALLOCATE | DEFAULT_AUTH | DEFINER | DELAY_KEY_WRITE
    | DES_KEY_FILE | DIAGNOSTICS | DIRECTORY | DISABLE | DISCARD | DISK | DO | DUMPFILE | DUPLICATE | DYNAMIC
    | ENABLE | ENCRYPTION | ENCRYPTION_KEY_ADMIN | END | ENDS | ENGINE | ENGINES | ERROR | ERRORS | ESCAPE | EUR
    | EVEN | EVENT | EVENTS | EVERY | EXCEPT | EXCHANGE | EXCLUSIVE | EXPIRE | EXPORT | EXTENDED | EXTENT_SIZE | FAST
    | FAULTS | FIELDS | FILE_BLOCK_SIZE | FILTER | FIREWALL_ADMIN | FIREWALL_USER | FIRST | FIXED | FLUSH | FOLLOWS
    | FOUND | FULL | FUNCTION | GENERAL | GLOBAL | GRANTS | GROUP | GROUP_CONCAT | GROUP_REPLICATION
    | GROUP_REPLICATION_ADMIN | HANDLER | HASH | HELP | HOST | HOSTS | IDENTIFIED | IGNORE_SERVER_IDS | IMPORT
    | INDEXES | INITIAL_SIZE | INNODB_REDO_LOG_ARCHIVE | INPLACE | INSERT_METHOD | INSTALL | INSTANCE | INTERNAL
    | INVOKER | IO | IO_THREAD | IPC | ISO | ISOLATION | ISSUER | JIS | JSON | KEY_BLOCK_SIZE | LANGUAGE | LAST
    | LEAVES | LESS | LEVEL | LIST | LOCAL | LOGFILE | LOGS | MASTER | MASTER_AUTO_POSITION | MASTER_CONNECT_RETRY
    | MASTER_DELAY | MASTER_HEARTBEAT_PERIOD | MASTER_HOST | MASTER_LOG_FILE | MASTER_LOG_POS | MASTER_PASSWORD
    | MASTER_PORT | MASTER_RETRY_COUNT | MASTER_SSL | MASTER_SSL_CA | MASTER_SSL_CAPATH | MASTER_SSL_CERT
    | MASTER_SSL_CIPHER | MASTER_SSL_CRL | MASTER_SSL_CRLPATH | MASTER_SSL_KEY | MASTER_TLS_VERSION | MASTER_USER
    | MAX_CONNECTIONS_PER_HOUR | MAX_QUERIES_PER_HOUR | MAX | MAX_ROWS | MAX_SIZE | MAX_UPDATES_PER_HOUR
    | MAX_USER_CONNECTIONS | MEDIUM | MEMBER | MEMORY | MERGE | MESSAGE_TEXT | MID | MIGRATE | MIN | MIN_ROWS
    | MODE | MODIFY | MUTEX | MYSQL | MYSQL_ERRNO | NAME | NAMES | NCHAR | NDB_STORED_USER | NEVER | NEXT | NO
    | NODEGROUP | NONE | NUMBER | OFFLINE | ODBC | OFFSET | OF | OJ | OLD_PASSWORD | ONE | ONLINE | ONLY | OPEN
    | OPTIMIZER_COSTS  | OPTIONS | ORDER | OWNER | PACK_KEYS | PAGE | PARSER | PARTIAL | PARTITIONING | PARTITIONS
    | PASSWORD | PERSIST_RO_VARIABLES_ADMIN | PHASE | PLUGINS | PLUGIN_DIR | PLUGIN | PORT | PRECEDES | PREPARE
    | PRESERVE | PREV | PROCESSLIST | PROFILE | PROFILES | PROXY | QUERY | QUICK | REBUILD | RECOVER
    | REDO_BUFFER_SIZE | REDUNDANT | RELAY | RELAYLOG | RELAY_LOG_FILE | RELAY_LOG_POS | REMOVE | REORGANIZE
    | REPAIR | REPLICATE_DO_DB | REPLICATE_DO_TABLE | REPLICATE_IGNORE_DB | REPLICATE_IGNORE_TABLE
    | REPLICATE_REWRITE_DB | REPLICATE_WILD_DO_TABLE | REPLICATE_WILD_IGNORE_TABLE | REPLICATION | REPLICATION_APPLIER
    | REPLICATION_SLAVE_ADMIN | RESET | RESOURCE_GROUP_ADMIN | RESOURCE_GROUP_USER | RESUME | RETURNED_SQLSTATE
    | RETURNS | ROLE | ROLE_ADMIN | ROLLBACK | ROLLUP | ROTATE | ROW | ROWS | ROW_FORMAT | SAVEPOINT | SCHEDULE
    | SCHEMA_NAME | SECURITY | SERIAL | SERVER | SESSION | SESSION_VARIABLES_ADMIN | SET_USER_ID | SHARE | SHARED
    | SHOW_ROUTINE | SIGNED | SIMPLE | SLAVE | SLOW | SNAPSHOT | SOCKET | SOME | SONAME | SOUNDS | SOURCE
    | SQL_AFTER_GTIDS | SQL_AFTER_MTS_GAPS | SQL_BEFORE_GTIDS | SQL_BUFFER_RESULT | SQL_CACHE | SQL_NO_CACHE
    | SQL_THREAD | STACKED | START | STARTS | STATS_AUTO_RECALC | STATS_PERSISTENT | STATS_SAMPLE_PAGES | STATUS
    | STD | STDDEV | STDDEV_POP | STDDEV_SAMP | STOP | STORAGE | STRING | SUBCLASS_ORIGIN | SUBJECT | SUBPARTITION
    | SUBPARTITIONS | SUM | SUSPEND | SWAPS | SWITCHES | SYSTEM_VARIABLES_ADMIN | TABLE_NAME | TABLESPACE
    | TABLE_ENCRYPTION_ADMIN | TEMPORARY | TEMPTABLE | THAN | TRADITIONAL | TRANSACTION | TRANSACTIONAL | TRIGGERS
    | TRUNCATE | UNDEFINED | UNDOFILE | UNDO_BUFFER_SIZE | UNINSTALL | UNKNOWN | UNTIL | UPGRADE | USA | USER
    | USE_FRM | USER_RESOURCES | VALIDATION | VALUE | VAR_POP | VAR_SAMP | VARIABLES | VARIANCE | VERSION_TOKEN_ADMIN
    | VIEW | WAIT | WARNINGS | WITHOUT | WORK | WRAPPER | X509 | XA | XA_RECOVER_ADMIN | XML | SPOKEN_DOT
    ;

functionNameBase
    : ABS | ACOS | ADDDATE | ADDTIME | AES_DECRYPT | AES_ENCRYPT | AREA | ASBINARY | ASIN | ASTEXT | ASWKB | ASWKT
    | ASYMMETRIC_DECRYPT | ASYMMETRIC_DERIVE | ASYMMETRIC_ENCRYPT | ASYMMETRIC_SIGN | ASYMMETRIC_VERIFY | ATAN | ATAN2
    | BENCHMARK | BIN | BIT_COUNT | BIT_LENGTH | BUFFER | CEIL | CEILING | CENTROID | CHARACTER_LENGTH | CHARSET
    | CHAR_LENGTH | COERCIBILITY | COLLATION | COMPRESS | CONCAT | CONCAT_WS | CONNECTION_ID | CONV | CONVERT_TZ
    | COS | COT | COUNT | CRC32 | CREATE_ASYMMETRIC_PRIV_KEY | CREATE_ASYMMETRIC_PUB_KEY | CREATE_DH_PARAMETERS
    | CREATE_DIGEST | CROSSES | DATABASE | DATE | DATEDIFF | DATE_FORMAT | DAY | DAYNAME | DAYOFMONTH | DAYOFWEEK
    | DAYOFYEAR | DECODE | DEGREES | DES_DECRYPT | DES_ENCRYPT | DIMENSION | DISJOINT | ELT | ENCODE | ENCRYPT
    | ENDPOINT | ENVELOPE | EQUALS | EXP | EXPORT_SET | EXTERIORRING | EXTRACTVALUE | FIELD | FIND_IN_SET | FLOOR
    | FORMAT | FOUND_ROWS | FROM_BASE64 | FROM_DAYS | FROM_UNIXTIME | GEOMCOLLFROMTEXT | GEOMCOLLFROMWKB
    | GEOMETRYCOLLECTION | GEOMETRYCOLLECTIONFROMTEXT | GEOMETRYCOLLECTIONFROMWKB | GEOMETRYFROMTEXT | GEOMETRYFROMWKB
    | GEOMETRYN | GEOMETRYTYPE | GEOMFROMTEXT | GEOMFROMWKB | GET_FORMAT | GET_LOCK | GLENGTH | GREATEST | GTID_SUBSET
    | GTID_SUBTRACT | HEX | HOUR | IFNULL | INET6_ATON | INET6_NTOA | INET_ATON | INET_NTOA | INSTR | INTERIORRINGN
    | INTERSECTS | INVISIBLE | ISCLOSED | ISEMPTY | ISNULL | ISSIMPLE | IS_FREE_LOCK | IS_IPV4 | IS_IPV4_COMPAT
    | IS_IPV4_MAPPED | IS_IPV6 | IS_USED_LOCK | LAST_INSERT_ID | LCASE | LEAST | LEFT | LENGTH | LINEFROMTEXT
    | LINEFROMWKB | LINESTRING | LINESTRINGFROMTEXT | LINESTRINGFROMWKB | LN | LOAD_FILE | LOCATE | LOG | LOG10
    | LOG2 | LOWER | LPAD | LTRIM | MAKEDATE | MAKETIME | MAKE_SET | MASTER_POS_WAIT | MBRCONTAINS | MBRDISJOINT
    | MBREQUAL | MBRINTERSECTS | MBROVERLAPS | MBRTOUCHES | MBRWITHIN | MD5 | MICROSECOND | MINUTE | MLINEFROMTEXT
    | MLINEFROMWKB | MOD| MONTH | MONTHNAME | MPOINTFROMTEXT | MPOINTFROMWKB | MPOLYFROMTEXT | MPOLYFROMWKB
    | MULTILINESTRING | MULTILINESTRINGFROMTEXT | MULTILINESTRINGFROMWKB | MULTIPOINT | MULTIPOINTFROMTEXT
    | MULTIPOINTFROMWKB | MULTIPOLYGON | MULTIPOLYGONFROMTEXT | MULTIPOLYGONFROMWKB | NAME_CONST | NULLIF
    | NUMGEOMETRIES | NUMINTERIORRINGS | NUMPOINTS | OCT | OCTET_LENGTH | ORD | OVERLAPS | PERIOD_ADD | PERIOD_DIFF
    | PI | POINT | POINTFROMTEXT | POINTFROMWKB | POINTN | POLYFROMTEXT | POLYFROMWKB | POLYGON | POLYGONFROMTEXT
    | POLYGONFROMWKB | POSITION| POW | POWER | QUARTER | QUOTE | RADIANS | RAND | RANDOM_BYTES | RELEASE_LOCK
    | REVERSE | RIGHT | ROUND | ROW_COUNT | RPAD | RTRIM | SECOND | SEC_TO_TIME | SCHEMA | SESSION_USER
    | SESSION_VARIABLES_ADMIN | SHA | SHA1 | SHA2 | SIGN | SIN | SLEEP | SOUNDEX | SQL_THREAD_WAIT_AFTER_GTIDS
    | SQRT | SRID | STARTPOINT | STRCMP | STR_TO_DATE | ST_AREA | ST_ASBINARY | ST_ASTEXT | ST_ASWKB | ST_ASWKT
    | ST_BUFFER | ST_CENTROID | ST_CONTAINS | ST_CROSSES | ST_DIFFERENCE | ST_DIMENSION | ST_DISJOINT | ST_DISTANCE
    | ST_ENDPOINT | ST_ENVELOPE | ST_EQUALS | ST_EXTERIORRING | ST_GEOMCOLLFROMTEXT | ST_GEOMCOLLFROMTXT
    | ST_GEOMCOLLFROMWKB | ST_GEOMETRYCOLLECTIONFROMTEXT | ST_GEOMETRYCOLLECTIONFROMWKB | ST_GEOMETRYFROMTEXT
    | ST_GEOMETRYFROMWKB | ST_GEOMETRYN | ST_GEOMETRYTYPE | ST_GEOMFROMTEXT | ST_GEOMFROMWKB | ST_INTERIORRINGN
    | ST_INTERSECTION | ST_INTERSECTS | ST_ISCLOSED | ST_ISEMPTY | ST_ISSIMPLE | ST_LINEFROMTEXT | ST_LINEFROMWKB
    | ST_LINESTRINGFROMTEXT | ST_LINESTRINGFROMWKB | ST_NUMGEOMETRIES | ST_NUMINTERIORRING | ST_NUMINTERIORRINGS
    | ST_NUMPOINTS | ST_OVERLAPS | ST_POINTFROMTEXT | ST_POINTFROMWKB | ST_POINTN | ST_POLYFROMTEXT | ST_POLYFROMWKB
    | ST_POLYGONFROMTEXT | ST_POLYGONFROMWKB | ST_SRID | ST_STARTPOINT | ST_SYMDIFFERENCE | ST_TOUCHES | ST_UNION
    | ST_WITHIN | ST_X | ST_Y | SUBDATE | SUBSTRING_INDEX | SUBTIME | SYSTEM_USER | TAN | TIME | TIMEDIFF | TIMESTAMP
    | TIMESTAMPADD | TIMESTAMPDIFF | TIME_FORMAT | TIME_TO_SEC | TOUCHES | TO_BASE64 | TO_DAYS | TO_SECONDS | UCASE
    | UNCOMPRESS | UNCOMPRESSED_LENGTH | UNHEX | UNIX_TIMESTAMP | UPDATEXML | UPPER | UUID | UUID_SHORT
    | VALIDATE_PASSWORD_STRENGTH | VERSION | VISIBLE | WAIT_UNTIL_SQL_THREAD_AFTER_GTIDS | WEEK | WEEKDAY | WEEKOFYEAR
    | WEIGHT_STRING | WITHIN | YEAR | YEARWEEK | Y_FUNCTION | X_FUNCTION | JSON_ARRAY | JSON_OBJECT | JSON_QUOTE
    | JSON_CONTAINS | JSON_CONTAINS_PATH | JSON_EXTRACT | JSON_KEYS | JSON_OVERLAPS | JSON_SEARCH | JSON_VALUE
    | JSON_ARRAY_APPEND | JSON_ARRAY_INSERT | JSON_INSERT | JSON_MERGE | JSON_MERGE_PATCH | JSON_MERGE_PRESERVE
    | JSON_REMOVE | JSON_REPLACE | JSON_SET | JSON_UNQUOTE | JSON_DEPTH | JSON_LENGTH | JSON_TYPE | JSON_VALID
    | JSON_TABLE | JSON_SCHEMA_VALID | JSON_SCHEMA_VALIDATION_REPORT | JSON_PRETTY | JSON_STORAGE_FREE
    | JSON_STORAGE_SIZE | JSON_ARRAYAGG | JSON_OBJECTAGG
    ;

selectElementDot //SPEAKQL FEATURE: '.' synonym is the word DOT
    : '.' | SPOKEN_DOT
    ;

fullColumnName
    : uid (dottedId dottedId? )?
    | selectElementDot dottedId dottedId?
    ;

dottedId
    : DOT_ID | selectElementDot uid
    ;

selectElementAs
    : AS
    ;

functionCall
    : specificFunction                                          #specificFunctionCall
    | aggregateWindowedFunction                                 #aggregateFunctionCall
    | nonAggregateWindowedFunction                              #nonAggregateFunctionCall
    | scalarFunctionName leftParen functionArgs? rightParen     #scalarFunctionCall
    | fullId leftParen functionArgs? rightParen                 #udfFunctionCall
    | passwordFunctionClause                                    #passwordFunctionCall
    ;

specificFunction
    : ( CURRENT_DATE | CURRENT_TIME | CURRENT_TIMESTAMP | CURRENT_USER | LOCALTIME )
        (leftParen rightParen)?                                                                     #simpleFunctionCall
    | CONVERT leftParen expression separator=',' convertedDataType rightParen                       #dataTypeFunctionCall
    | CONVERT leftParen expression USING charsetName rightParen                                     #dataTypeFunctionCall
    | CAST leftParen expression AS convertedDataType rightParen                                     #dataTypeFunctionCall
    | VALUES leftParen fullColumnName rightParen                                                    #valuesFunctionCall
    | CASE expression caseFuncAlternative+ (ELSE elseArg=functionArg)? END                          #caseExpressionFunctionCall
    | CASE caseFuncAlternative+ (ELSE elseArg=functionArg)? END                                     #caseFunctionCall
    | CHAR leftParen functionArgs (USING charsetName)? rightParen                                   #charFunctionCall
    | POSITION leftParen ( positionString=stringLiteral | positionExpression=expression ) IN
        ( inString=stringLiteral | inExpression=expression ) rightParen                             #positionFunctionCall
    | (SUBSTR | SUBSTRING) leftParen ( sourceString=stringLiteral | sourceExpression=expression )
        FROM ( fromDecimal=decimalLiteral | fromExpression=expression )
        ( FOR ( forDecimal=decimalLiteral | forExpression=expression ) )? rightParen                #substrFunctionCall
    | TRIM leftParen positioinForm=(BOTH | LEADING | TRAILING)
        ( sourceString=stringLiteral | sourceExpression=expression )?
        FROM ( fromString=stringLiteral | fromExpression=expression ) rightParen                    #trimFunctionCall
    | TRIM leftParen ( sourceString=stringLiteral | sourceExpression=expression )
        FROM ( fromString=stringLiteral | fromExpression=expression ) rightParen                    #trimFunctionCall
    | WEIGHT_STRING leftParen (stringLiteral | expression) (AS stringFormat=(CHAR | BINARY)
        leftParen decimalLiteral rightParen )? levelsInWeightString? rightParen                     #weightFunctionCall
    | EXTRACT leftParen intervalType FROM
        ( sourceString=stringLiteral | sourceExpression=expression ) rightParen                     #extractFunctionCall
    | GET_FORMAT leftParen datetimeFormat=(DATE | TIME | DATETIME) ',' stringLiteral rightParen     #getFormatFunctionCall
    | JSON_VALUE leftParen expression ',' expression (RETURNING convertedDataType)?
        ((NULL_LITERAL | ERROR | (DEFAULT defaultValue)) ON EMPTY)?
        ((NULL_LITERAL | ERROR | (DEFAULT defaultValue)) ON ERROR)? rightParen                      #jsonValueFunctionCall
    ;

leftParen //SPEAKQL MOD: Added because ANTLR provides the tree as a lisp tree, so this is needed to differentiate between lisp tree parens and query parens
    : '('
    ;

rightParen
    : ')'
    ;

expression
    : notOperator=(NOT | '!') expression                    #notExpression
    | expression logicalOperator expression                 #logicalExpression
    | predicate IS NOT? testValue=(TRUE | FALSE | UNKNOWN)  #isExpression
    | predicate                                             #predicateExpression
    ;

logicalOperator
    : AND | '&' '&' | XOR | OR | '|' '|'
    ;

predicate
    : predicate NOT? IN leftParen (selectStatement | expressions) rightParen                            #inPredicate
    | predicate IS nullNotnull                                                                          #isNullPredicate
    | left=predicate comparisonOperator right=predicate                                                 #binaryComparisonPredicate
    | predicate comparisonOperator quantifier=(ALL | ANY | SOME) leftParen selectStatement rightParen   #subqueryComparisonPredicate
    | predicate NOT? BETWEEN predicate AND predicate                                                    #betweenPredicate
    | predicate SOUNDS LIKE predicate                                                                   #soundsLikePredicate
    | predicate NOT? LIKE predicate (ESCAPE STRING_LITERAL)?                                            #likePredicate
    | predicate NOT? regex=(REGEXP | RLIKE) predicate                                                   #regexpPredicate
    | (LOCAL_ID VAR_ASSIGN)? expressionAtom                                                             #expressionAtomPredicate
    | predicate MEMBER OF leftParen predicate rightParen                                                #jsonMemberOfPredicate
    ;

expressionDelimiter //SPEAKQL FEATURE: delimiter between partitioned simple queries
    : AND | AND_THEN | THEN
    ;

selectModifierExpression //SPEAKQL FEATURE: enables reordering by including optional statements in a single expression
    : groupByClause? havingClause? windowClause? orderByClause? limitClause?
    | groupByClause? havingClause? windowClause? orderByClause? limitClause? selectIntoExpression?
    ;

groupByClause //SPEAKQL FEATURE: Added aggregate function option to end of group by clause to enable table-spanning aggregation using the simple query partitioning feature
    : groupByKeyword groupByItem (groupByItemDelimiter groupByItem)* (WITH ROLLUP)?
            (expressionDelimiter selectKeyword? aggregateWindowedFunction (selectElementDelimiter aggregateWindowedFunction)* )?
    ;

groupByKeyword
    : GROUP BY | GROUP
    ;

groupByItem
    : groupByExpression order=(ASC | DESC)?
    | automaticGroupByKeyword
    ;

automaticGroupByKeyword
    : AUTOMATIC | AUTOMATICALLY
    ;

groupByExpression
    : notOperator=(NOT | '!') groupByExpression
    | predicate IS NOT? testValue=(TRUE | FALSE | UNKNOWN)
    | predicate
    ;

groupByItemDelimiter
    : ',' | AND
    ;

havingClause
    : havingKeyword havingExpr=expression
    ;

havingKeyword
    : HAVING
    ;

windowClause
    : WINDOW windowName AS leftParen windowSpec rightParen (',' windowName AS leftParen windowSpec rightParen)*
    ;

windowName
    : uid
    ;

windowSpec
    : windowName? partitionClause? orderByClause? frameClause?
    ;

partitionClause
    : PARTITION BY expression (',' expression)*
    ;

orderByClause
    : ORDER BY orderByExpression (',' orderByExpression)*
    ;

orderByExpression
    : expression order=(ASC | DESC)?
    ;

frameClause
    : frameUnits frameExtent
    ;

frameUnits
    : ROWS | RANGE
    ;

frameExtent
    : frameRange
    | frameBetween
    ;

frameRange
    : CURRENT ROW
    | UNBOUNDED (PRECEDING | FOLLOWING)
    | expression (PRECEDING | FOLLOWING)
    ;

frameBetween
    : BETWEEN frameRange AND frameRange
    ;

limitClause
    : LIMIT ( (offset=limitClauseAtom ',')? limit=limitClauseAtom
    | limit=limitClauseAtom OFFSET offset=limitClauseAtom )
    ;

limitClauseAtom
    : decimalLiteral | mysqlVariable | simpleId
    ;

selectIntoExpression
    : INTO assignmentField (',' assignmentField )*                                          #selectIntoVariables
    | INTO DUMPFILE STRING_LITERAL                                                          #selectIntoDumpFile
    | ( INTO OUTFILE filename=STRING_LITERAL (CHARACTER SET charset=charsetName)?
        ( fieldsFormat=(FIELDS | COLUMNS)
        selectFieldsInto+ )? ( LINES selectLinesInto+ )? )                                  #selectIntoTextFile
    ;

assignmentField
    : uid | LOCAL_ID
    ;

selectFieldsInto
    : TERMINATED BY terminationField=STRING_LITERAL
    | OPTIONALLY? ENCLOSED BY enclosion=STRING_LITERAL
    | ESCAPED BY escaping=STRING_LITERAL
    ;

selectLinesInto
    : STARTING BY starting=STRING_LITERAL
    | TERMINATED BY terminationLine=STRING_LITERAL
    ;

lockClause
    : FOR UPDATE | LOCK IN SHARE MODE
    ;

queryExpression
    : leftParen querySpecification rightParen
    | leftParen queryExpression rightParen
    ;

querySpecificationNointo
    : selectKeyword selectSpec* selectElements fromClause? groupByClause? havingClause?
        windowClause? orderByClause? limitClause?
    ;

fromClauseNoJoin //SPEAKQL FEATURE: This is the from clause used by the simple query partition. If a query has a query expression delimiter, then this rule is used.
    : fromKeyword tableSourceNoJoin
    ;

fromClause
    : fromKeyword tableSources
    ; //(whereKeyword whereExpression)? //commented out and moved up to queryOrderExpressions ;

fromKeyword //SPEAKQL FEATURE: FROM keyword synonyms
    : FROM | FROM_TABLE | FROM_TABLES | IN | IN_TABLE | IN_TABLES
    ;

tableSources
    : tableSource (tableSourceDelimiter tableSource)*
    ;

tableSourceNoJoin //SPEAKQL FEATURE: Used in queries with an expressionDelimiter
    : tableSourceItem                                                           #tableSourceNoJoinBase
    | leftParen tableSourceItem rightParen                                      #tableSourceNoJoinNested
    ;

tableSource
    : tableSourceItem joinPart*                                                 #tableSourceBase
    | leftParen tableSourceItem joinPart* rightParen                            #tableSourceNested
    ;

tableSourceItem
    : subQueryTable tableAlias                                                  #subqueryTableItem
    | tableName                                                                 #onlyTableNameItem
    | tableName (PARTITION leftParen uidList rightParen )?
        (tableAlias)? (indexHint (',' indexHint)* )?                            #atomTableItem
    | leftParen tableSources rightParen                                         #tableSourcesItem
    ;

subQueryTable
    : (selectStatement | leftParen parenthesisSubquery=selectStatement rightParen)
    | (selectStatement | leftParen parenthesisSubquery=selectStatement rightParen)
    ;

tableAlias
    : tableAliasAs? alias=uid
    ;

tableAliasAs
    : AS
    ;

tableName
    : fullId
    ;

uidList
    : uid (',' uid)*
    ;

indexHint
    : indexHintAction=(USE | IGNORE | FORCE) keyFormat=(INDEX|KEY) ( FOR indexHintType)? leftParen uidList rightParen
    ;

indexHintType
    : JOIN | ORDER BY | GROUP BY
    ;

joinKeyword //SPEAKQL FEATURE: JOIN keyword synonyms
    : JOIN | JOIN_TABLE | BY_JOINING | BY_JOINING_TABLE | JOINED_WITH | JOIN_WITH
    | JOINED_WITH_TABLE | JOIN_WITH_TABLE | BY_JOINING_WITH_TABLE
    ;

multiJoinExpression //SPEAKQL FEATURE: New join semantics to isolate all join statements into a single sub-expression
    : multiJoinPart+
    ;

multiJoinPart
    : multiInnerJoin | multiOuterJoin | multiNaturalJoin
    ;

multiInnerJoin //SPEAKQL FEATURE: Explicit two-table join statements JOIN TABLE_ONE WITH TABLE_TWO ON...
    : ( innerJoinKeyword )? joinKeyword tableSourceItem withKeyword tableSourceItem
        ( onKeyword expression | USING leftParen uidList rightParen)?
    ;

multiOuterJoin
    : ( joinDirection ) outerJoinKeyword? joinKeyword tableSourceItem withKeyword tableSourceItem
          ( onKeyword expression | USING leftParen uidList rightParen )
    ;

multiNaturalJoin
    : naturalJoinKeyword (( joinDirection ) outerJoinKeyword?)? joinKeyword tableSourceItem withKeyword tableSourceItem
    ;

withKeyword //SPEAKQL FEATURE: WITH keyword associates two tables in a multi-join statement
    : WITH | WITH_TABLE
    ;

joinPart
    : innerJoin | outerJoin | naturalJoin
    ;

innerJoin
    : (innerJoinKeyword)? joinKeyword tableSourceItem ( onKeyword expression | USING leftParen uidList rightParen )?
    ;

innerJoinKeyword
    : INNER | CROSS
    ;

onKeyword
    : ON
    ;

outerJoin
    : (joinDirection) outerJoinKeyword? joinKeyword tableSourceItem
        ( onKeyword expression | USING leftParen uidList rightParen )
    ;

joinDirection //SPEAKQL MOD: Added joinDirection rule to make it easier to work with during translation
    : LEFT | RIGHT
    ;

outerJoinKeyword
    : OUTER
    ;

naturalJoin
    : naturalJoinKeyword ((joinDirection) outerJoinKeyword?)? joinKeyword tableSourceItem
    ;

naturalJoinKeyword
    : NATURAL
    ;

tableSourceDelimiter //SPEAKQL FEATURE: Added ',' synonym for more natural language
    : ',' | AND
    ;

unionStatement
    : UNION unionType=(ALL | DISTINCT)? (querySpecificationNointo | queryExpressionNointo)
    ;

queryExpressionNointo
    : leftParen querySpecificationNointo rightParen
    | leftParen queryExpressionNointo rightParen
    ;

unionParenthesis
    : UNION unionType=(ALL | DISTINCT)? queryExpressionNointo
    ;

expressions
    : expression (',' expression)*
    ;

nullNotnull
    : NOT? (NULL_LITERAL | NULL_SPEC_LITERAL)
    ;

comparisonOperator
    : '=' | '>' | '<' | '<' '=' | '>' '=' | '<' '>' | '!' '=' | '<' '=' '>'
    ;

expressionAtom
    : constant                                                                      #constantExpressionAtom
    | fullColumnName                                                                #fullColumnNameExpressionAtom
    | functionCall                                                                  #functionCallExpressionAtom
    | expressionAtom COLLATE collationName                                          #collateExpressionAtom
    | mysqlVariable                                                                 #mysqlVariableExpressionAtom
    | unaryOperator expressionAtom                                                  #unaryExpressionAtom
    | BINARY expressionAtom                                                         #binaryExpressionAtom
    | leftParen expression (',' expression)* rightParen                             #nestedExpressionAtom
    | ROW leftParen expression (',' expression)+ rightParen                         #nestedRowExpressionAtom
    | EXISTS leftParen selectStatement rightParen                                   #existsExpressionAtom
    | leftParen selectStatement rightParen                                          #subqueryExpressionAtom
    | INTERVAL expression intervalType                                              #intervalExpressionAtom
    | left=expressionAtom bitOperator right=expressionAtom                          #bitExpressionAtom
    | left=expressionAtom mathOperator right=expressionAtom                         #mathExpressionAtom
    | left=expressionAtom jsonOperator right=expressionAtom                         #jsonExpressionAtom
    ;

constant
    : stringLiteral | decimalLiteral | '-' decimalLiteral | hexadecimalLiteral | booleanLiteral
    | REAL_LITERAL | BIT_STRING | NOT? nullLiteral=(NULL_LITERAL | NULL_SPEC_LITERAL)
    ;

stringLiteral
    : ( STRING_CHARSET_NAME? STRING_LITERAL
    | START_NATIONAL_STRING_LITERAL ) STRING_LITERAL+
    | ( STRING_CHARSET_NAME? STRING_LITERAL
    | START_NATIONAL_STRING_LITERAL ) (COLLATE collationName)?
    ;

collationName
    : uid | STRING_LITERAL
    ;

decimalLiteral
    : DECIMAL_LITERAL | ZERO_DECIMAL | ONE_DECIMAL | TWO_DECIMAL | REAL_LITERAL
    ;

hexadecimalLiteral
    : STRING_CHARSET_NAME? HEXADECIMAL_LITERAL
    ;

booleanLiteral
    : TRUE | FALSE
    ;

mysqlVariable
    : LOCAL_ID | GLOBAL_ID
    ;

unaryOperator
    : '!' | '~' | '+' | '-' | NOT
    ;

intervalType
    : intervalTypeBase | YEAR | YEAR_MONTH | DAY_HOUR | DAY_MINUTE | DAY_SECOND | HOUR_MINUTE
    | HOUR_SECOND | MINUTE_SECOND | SECOND_MICROSECOND | MINUTE_MICROSECOND
    | HOUR_MICROSECOND | DAY_MICROSECOND
    ;

bitOperator
    : '<' '<' | '>' '>' | '&' | '^' | '|'
    ;

mathOperator
    : '*' | '/' | '%' | DIV | MOD | '+' | '-'
    ;

jsonOperator
    : '-' '>' | '-' '>' '>'
    ;

convertedDataType
    : typeName=(BINARY| NCHAR) lengthOneDimension?
    | typeName=CHAR lengthOneDimension? ((CHARACTER SET | CHARSET) charsetName)?
    | typeName=(DATE | DATETIME | TIME | JSON) | typeName=DECIMAL lengthTwoDimension?
    | (SIGNED | UNSIGNED) INTEGER? | UNSIGNED ARRAY
    ;

lengthOneDimension
    : leftParen decimalLiteral rightParen
    ;

charsetName
    : BINARY | charsetNameBase | STRING_LITERAL | CHARSET_REVERSE_QOUTE_STRING
    ;

lengthTwoDimension
    : leftParen decimalLiteral ',' decimalLiteral rightParen
    ;

caseFuncAlternative
    : WHEN condition=functionArg THEN consequent=functionArg
    ;

functionArgs
    : (constant | fullColumnName | functionCall | expression)
        ( ',' (constant | fullColumnName | functionCall | expression) )*
    ;

levelsInWeightString
    : LEVEL levelInWeightListElement (',' levelInWeightListElement)*                #levelWeightList
    | LEVEL firstLevel=decimalLiteral '-' lastLevel=decimalLiteral                  #levelWeightRange
    ;

levelInWeightListElement
    : decimalLiteral orderType=(ASC | DESC | REVERSE)?
    ;

defaultValue
    : (NULL_LITERAL | unaryOperator? constant | currentTimestamp
    | leftParen expression rightParen) (ON UPDATE currentTimestamp)?
    ;

currentTimestamp
    : ( (CURRENT_TIMESTAMP | LOCALTIME | LOCALTIMESTAMP) (leftParen decimalLiteral? rightParen)?
    | NOW leftParen decimalLiteral? rightParen )
    ;

aggregateWindowedFunction
    : (AVG | MAX | MIN | SUM) leftParen aggregator=(ALL | DISTINCT)? functionArg rightParen overClause?
    | COUNT leftParen (starArg='*' | allAggregatorKeyword? functionArg
    | distinctAggregatorKeyword functionArgs) rightParen overClause?
    | ( BIT_AND | BIT_OR | BIT_XOR | STD | STDDEV | STDDEV_POP | STDDEV_SAMP | VAR_POP | VAR_SAMP | VARIANCE )
        leftParen aggregator=ALL? functionArg rightParen overClause?
    | GROUP_CONCAT leftParen aggregator=DISTINCT? functionArgs
        (ORDER BY orderByExpression (',' orderByExpression)* )? (SEPARATOR separator=STRING_LITERAL)? rightParen
    ;

functionArg
    : constant | fullColumnName | functionCall | expression
    ;

overClause
    : OVER (leftParen windowSpec? rightParen | windowName)
    ;

allAggregatorKeyword
    : aggregator=ALL
    ;

distinctAggregatorKeyword
    : aggregator=DISTINCT
    ;

nonAggregateWindowedFunction
    : (LAG | LEAD) leftParen expression (',' decimalLiteral)? (',' decimalLiteral)? rightParen overClause
    | (FIRST_VALUE | LAST_VALUE) leftParen expression rightParen overClause
    | (CUME_DIST | DENSE_RANK | PERCENT_RANK | RANK | ROW_NUMBER) leftParen rightParen overClause
    | NTH_VALUE leftParen expression ',' decimalLiteral rightParen overClause
    | NTILE leftParen decimalLiteral rightParen overClause
    ;

scalarFunctionName
    : functionNameBase | ASCII | CURDATE | CURRENT_DATE | CURRENT_TIME | CURRENT_TIMESTAMP
    | CURTIME | DATE_ADD | DATE_SUB | IF | INSERT | LOCALTIME | LOCALTIMESTAMP | MID | NOW
    | REPLACE | SUBSTR | SUBSTRING | SYSDATE | TRIM | UTC_DATE | UTC_TIME | UTC_TIMESTAMP
    ;

passwordFunctionClause
    : functionName=(PASSWORD | OLD_PASSWORD) leftParen functionArg rightParen
    ;

selectElementDelimiter //SPEAKQL FEATURE: ',' synonym for select elements for more natural language
    : ',' | AND
    ;

whereKeyword
    : WHERE ;

whereExpression
    : whereExpr=expression
    ;

tableExpressionNoJoin
    : fromClauseNoJoin
    ;

tableExpression
    : fromClause
    ;
