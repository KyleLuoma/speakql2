parser grammar SimpleSpeakQlParser;
options { tokenVocab=SimpleSpeakQlLexer; }


start
    : selectStatement END_OF_FILE?
    ;

selectStatement
    : querySpecification                                                                       #simpleSelect
    | queryExpression                                                                          #parenthesisSelect
    ;

querySpecification
    : queryOrderSpecification selectModifierExpression                                        #singleQuerySpecification
    | (multiJoinExpression expressionDelimiter)? (selectModifierExpression expressionDelimiter)?
        multiQueryOrderSpecification
        ( expressionDelimiter ( multiQueryOrderSpecification | multiJoinExpression) )*
        (expressionDelimiter selectModifierExpression)?                                       #multiQuerySpecification
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
    : selectClause selectSpec* selectElements //selectIntoExpression?
    | selectClause selectSpec* selectElements
    | selectClause nothingElement
    ;

selectClause
    : selectKeyword
    ;

selectKeyword //SPEAKQL FEATURE: SELECT keyword synonyms
    : SELECT | RETRIEVE | SHOW_ME | DISPLAY | PRESENT | FIND | GET | WHAT_IS | WHAT_ARE | WHAT_IS_THE | WHAT_ARE_THE
    ;

nothingElement
    : nothingKeyword
    ;

nothingKeyword //SPEAKQL FEATURE: Allows us to specify a where condition in an unbundled query without selecting any columns
    : NOTHING | NO_COLUMNS
    ;

selectSpec
    : (ALL | DISTINCT | DISTINCTROW)
    ;

selectElements
    : (star='*' | selectElement ) (selectElementDelimiter selectElement)*
    ;

selectElement
    : fullId selectElementDot '*'                                   #selectStarElement
    | fullColumnName (selectElementAs uid)?                         #selectColumnElement //SpeakQl constraint: column aliases MUST use the AS keyword
    | functionCall (selectElementAs uid)?                           #selectFunctionElement //SpeakQl constraint: function aliases MUST use the AS keyword
    //| (LOCAL_ID VAR_ASSIGN)? expression (selectElementAs uid)?     #selectExpressionElement //SpeakQl constraint: no expression as select element
    ;

fullId
    : uid ('.' uid)?
    ;

uid
    : simpleId
    ;

simpleId
    : ID | intervalTypeBase //| keywordsCanBeId
    ;

intervalTypeBase
    : QUARTER | MONTH | DAY | HOUR | MINUTE | WEEK | SECOND | MICROSECOND
    ;


//functionNameBase
//    : ABS | ACOS | ADDDATE | ADDTIME | AES_DECRYPT | AES_ENCRYPT | AREA | ASBINARY | ASIN | ASTEXT | ASWKB | ASWKT
//    | ASYMMETRIC_DECRYPT | ASYMMETRIC_DERIVE | ASYMMETRIC_ENCRYPT | ASYMMETRIC_SIGN | ASYMMETRIC_VERIFY | ATAN | ATAN2
//    | BENCHMARK | BIN | BIT_COUNT | BIT_LENGTH | BUFFER | CEIL | CEILING | CENTROID | CHARACTER_LENGTH | CHARSET
//    | CHAR_LENGTH | COERCIBILITY | COLLATION | COMPRESS | CONCAT | CONCAT_WS | CONNECTION_ID | CONV | CONVERT_TZ
//    | COS | COT | COUNT | CRC32 | CREATE_ASYMMETRIC_PRIV_KEY | CREATE_ASYMMETRIC_PUB_KEY | CREATE_DH_PARAMETERS
//    | CREATE_DIGEST | CROSSES | DATE | DATEDIFF | DATE_FORMAT | DAY | DAYNAME | DAYOFMONTH | DAYOFWEEK
//    | DAYOFYEAR | DECODE | DEGREES | DES_DECRYPT | DES_ENCRYPT | DIMENSION | DISJOINT | ELT | ENCODE | ENCRYPT
//    | ENDPOINT | ENVELOPE | EQUALS | EXP | EXPORT_SET | EXTERIORRING | EXTRACTVALUE | FIELD | FIND_IN_SET | FLOOR
//    | FORMAT | FOUND_ROWS | FROM_BASE64 | FROM_DAYS | FROM_UNIXTIME | GEOMCOLLFROMTEXT | GEOMCOLLFROMWKB
//    | GEOMETRYCOLLECTIONFROMTEXT | GEOMETRYCOLLECTIONFROMWKB | GEOMETRYFROMTEXT | GEOMETRYFROMWKB
//    | GEOMETRYN | GEOMETRYTYPE | GEOMFROMTEXT | GEOMFROMWKB | GET_FORMAT | GET_LOCK | GLENGTH | GREATEST | GTID_SUBSET
//    | GTID_SUBTRACT | HEX | HOUR | IFNULL | INET6_ATON | INET6_NTOA | INET_ATON | INET_NTOA | INSTR | INTERIORRINGN
//    | INTERSECTS | ISCLOSED | ISEMPTY | ISNULL | ISSIMPLE | IS_FREE_LOCK | IS_IPV4 | IS_IPV4_COMPAT
//    | IS_IPV4_MAPPED | IS_IPV6 | IS_USED_LOCK | LAST_INSERT_ID | LCASE | LEAST | LEFT | LENGTH | LINEFROMTEXT
//    | LINEFROMWKB | LINESTRINGFROMTEXT | LINESTRINGFROMWKB | LN | LOAD_FILE | LOCATE | LOG | LOG10
//    | LOG2 | LOWER | LPAD | LTRIM | MAKEDATE | MAKETIME | MAKE_SET | MASTER_POS_WAIT | MBRCONTAINS | MBRDISJOINT
//    | MBREQUAL | MBRINTERSECTS | MBROVERLAPS | MBRTOUCHES | MBRWITHIN | MD5 | MICROSECOND | MINUTE | MLINEFROMTEXT
//    | MLINEFROMWKB | MOD| MONTH | MONTHNAME | MPOINTFROMTEXT | MPOINTFROMWKB | MPOLYFROMTEXT | MPOLYFROMWKB
//    | MULTILINESTRINGFROMTEXT | MULTILINESTRINGFROMWKB | MULTIPOINTFROMTEXT
//    | MULTIPOINTFROMWKB | MULTIPOLYGONFROMTEXT | MULTIPOLYGONFROMWKB | NAME_CONST | NULLIF
//    | NUMGEOMETRIES | NUMINTERIORRINGS | NUMPOINTS | OCT | OCTET_LENGTH | ORD | OVERLAPS | PERIOD_ADD | PERIOD_DIFF
//    | PI | POINTFROMTEXT | POINTFROMWKB | POINTN | POLYFROMTEXT | POLYFROMWKB | POLYGONFROMTEXT
//    | POLYGONFROMWKB | POSITION| POW | POWER | QUARTER | QUOTE | RADIANS | RAND | RANDOM_BYTES | RELEASE_LOCK
//    | REVERSE | RIGHT | ROUND | ROW_COUNT | RPAD | RTRIM | SECOND | SEC_TO_TIME | SESSION_USER
//    | SHA | SHA1 | SHA2 | SIGN | SIN | SLEEP | SOUNDEX | SQL_THREAD_WAIT_AFTER_GTIDS
//    | SQRT | SRID | STARTPOINT | STRCMP | STR_TO_DATE | ST_AREA | ST_ASBINARY | ST_ASTEXT | ST_ASWKB | ST_ASWKT
//    | ST_BUFFER | ST_CENTROID | ST_CONTAINS | ST_CROSSES | ST_DIFFERENCE | ST_DIMENSION | ST_DISJOINT | ST_DISTANCE
//    | ST_ENDPOINT | ST_ENVELOPE | ST_EQUALS | ST_EXTERIORRING | ST_GEOMCOLLFROMTEXT | ST_GEOMCOLLFROMTXT
//    | ST_GEOMCOLLFROMWKB | ST_GEOMETRYCOLLECTIONFROMTEXT | ST_GEOMETRYCOLLECTIONFROMWKB | ST_GEOMETRYFROMTEXT
//    | ST_GEOMETRYFROMWKB | ST_GEOMETRYN | ST_GEOMETRYTYPE | ST_GEOMFROMTEXT | ST_GEOMFROMWKB | ST_INTERIORRINGN
//    | ST_INTERSECTION | ST_INTERSECTS | ST_ISCLOSED | ST_ISEMPTY | ST_ISSIMPLE | ST_LINEFROMTEXT | ST_LINEFROMWKB
//    | ST_LINESTRINGFROMTEXT | ST_LINESTRINGFROMWKB | ST_NUMGEOMETRIES | ST_NUMINTERIORRING | ST_NUMINTERIORRINGS
//    | ST_NUMPOINTS | ST_OVERLAPS | ST_POINTFROMTEXT | ST_POINTFROMWKB | ST_POINTN | ST_POLYFROMTEXT | ST_POLYFROMWKB
//    | ST_POLYGONFROMTEXT | ST_POLYGONFROMWKB | ST_SRID | ST_STARTPOINT | ST_SYMDIFFERENCE | ST_TOUCHES | ST_UNION
//    | ST_WITHIN | ST_X | ST_Y | SUBDATE | SUBSTRING_INDEX | SUBTIME | SYSTEM_USER | TAN | TIME | TIMEDIFF | TIMESTAMP
//    | TIMESTAMPADD | TIMESTAMPDIFF | TIME_FORMAT | TIME_TO_SEC | TOUCHES | TO_BASE64 | TO_DAYS | TO_SECONDS | UCASE
//    | UNCOMPRESS | UNCOMPRESSED_LENGTH | UNHEX | UNIX_TIMESTAMP | UPDATEXML | UPPER | UUID | UUID_SHORT
//    | VALIDATE_PASSWORD_STRENGTH | VERSION | WAIT_UNTIL_SQL_THREAD_AFTER_GTIDS | WEEK | WEEKDAY | WEEKOFYEAR
//    | WEIGHT_STRING | WITHIN | YEAR | YEARWEEK | Y_FUNCTION | X_FUNCTION
//    ;

selectElementDot //SPEAKQL FEATURE: '.' synonym is the word DOT
    : '.' | SPOKEN_DOT
    ;

fullColumnName
    : uid (dottedId dottedId? )?
    | selectElementDot dottedId dottedId?
    ;

dottedId
    : selectElementDot uid
    ;

selectElementAs
    : AS
    ;

functionCall
    : aggregateWindowedFunction                                 #aggregateFunctionCall
    //| nonAggregateWindowedFunction                              #nonAggregateFunctionCall
    | scalarFunctionName leftParen functionArgs? rightParen     #scalarFunctionCall
    //| fullId leftParen functionArgs? rightParen                 #udfFunctionCall
    ;

leftParen //SPEAKQL MOD: Added because ANTLR provides the tree as a lisp tree, so this is needed to differentiate between lisp tree parens and query parens
    : '(' //| OPEN_PAREN | LEFT_PAREN | OPEN_PARENTHESIS | LEFT_PARENTHESIS
    ;

rightParen
    : ')' //| CLOSE_PAREN | RIGHT_PAREN | CLOSE_PARENTHESIS | RIGHT_PARENTHESIS
    ;

expression
    : notOperator=(NOT | '!') predicate                    #notExpression
    | predicate IS NOT? testValue=(TRUE | FALSE | UNKNOWN)  #isExpression
    | predicate                                             #predicateExpression
    ;

logicalOperator
    : AND | '&' '&' | XOR | OR | '|' '|'
    ;

predicate //SpeakQL Feature: Optional 'IS' in in predicate
    //: predicate NOT? isKeyword? IN leftParen (selectStatement | expressions) rightParen                 #inPredicate
    : simpleExpressionAtom IS nullNotnull                                                                 #isNullPredicate
    | left=simpleExpressionAtom comparisonOperator right=simpleExpressionAtom                             #binaryComparisonPredicate
    //| predicate comparisonOperator quantifier=(ALL | ANY | SOME) leftParen selectStatement rightParen   #subqueryComparisonPredicate
    //| simpleExpressionAtom NOT? BETWEEN simpleExpressionAtom AND simpleExpressionAtom                     #betweenPredicate
    //| predicate SOUNDS LIKE predicate                                                                   #soundsLikePredicate
    //| simpleExpressionAtom NOT? LIKE simpleExpressionAtom (ESCAPE STRING_LITERAL)?                        #likePredicate
    //| predicate NOT? regex=(REGEXP | RLIKE) predicate                                                   #regexpPredicate
    //| (LOCAL_ID VAR_ASSIGN)? expressionAtom                                                             #expressionAtomPredicate
    | simpleExpressionAtom                                                                                #simpleExpressionAtomPredicate
    //| predicate MEMBER OF leftParen predicate rightParen                                                #jsonMemberOfPredicate
    ;

isKeyword
    : IS
    ;

expressionDelimiter //SPEAKQL FEATURE: delimiter between partitioned simple queries
    : AND_THEN | THEN
    ;

selectModifierExpression //SPEAKQL FEATURE: enables reordering by including optional statements in a single expression
    : groupByClause? havingClause? orderByClause? limitClause?
    //| groupByClause? havingClause? windowClause? orderByClause? limitClause? selectIntoExpression?
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

orderByClause
    : ORDER BY orderByExpression (',' orderByExpression)*
    ;

orderByExpression
    : expression order=(ASC | DESC)?
    ;

limitClause
    : LIMIT ( (offset=limitClauseAtom ',')? limit=limitClauseAtom
    | limit=limitClauseAtom OFFSET offset=limitClauseAtom )
    ;

limitClauseAtom
    : decimalLiteral | simpleId
    ;


queryExpression
    : leftParen querySpecification rightParen
    | leftParen queryExpression rightParen
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

tableKeyword
    : TABLE
    ;

tableSources
    : theKeyword? tableSource tableKeyword? (tableSourceDelimiter theKeyword? tableSource tableKeyword?)*
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
    : tableName tableAlias?                            #onlyTableNameItem
    | subQueryTable tableAlias                                                  #subqueryTableItem
//    | tableName (PARTITION leftParen uidList rightParen )?
//        (tableAlias)? (indexHint (',' indexHint)* )?                            #atomTableItem
    | leftParen tableSources rightParen                                         #tableSourcesItem
    ;

subQueryTable
    : leftParen parenthesisSubquery=selectStatement rightParen
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
    : multiJoinPart (expressionDelimiter multiJoinPart)*
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

expressions
    : expression (whereExpressionDelimiter expression)*
    ;

whereExpressionDelimiter
    : ',' | AND
    ;

nullNotnull
    : NOT? (NULL_LITERAL | NULL_SPEC_LITERAL)
    ;

comparisonOperator
    : '=' | '>' | '<' | '<' '=' | '>' '=' | '<' '>' | '!' '=' | '<' '=' '>'
    ;

simpleExpressionAtom //SpeakQl constraint: Removing subqueries and exists among other recursive expressions to enable faster ASR
    : constant
    | fullColumnName
    | fullColumnName mathOperator fullColumnName
    | fullColumnName mathOperator constant
    | constant mathOperator fullColumnName
    | constant mathOperator constant
    | unaryOperator (constant | fullColumnName)
    ;

//expressionAtom
//    : constant                                                                      #constantExpressionAtom
//    | fullColumnName                                                                #fullColumnNameExpressionAtom
//    | functionCall                                                                  #functionCallExpressionAtom
//    | unaryOperator expressionAtom                                                  #unaryExpressionAtom
//    | leftParen expression (',' expression)* rightParen                             #nestedExpressionAtom
//    | ROW leftParen expression (',' expression)+ rightParen                         #nestedRowExpressionAtom
//    | EXISTS leftParen selectStatement rightParen                                   #existsExpressionAtom
//    | leftParen selectStatement rightParen                                          #subqueryExpressionAtom
//    | left=expressionAtom mathOperator right=expressionAtom                         #mathExpressionAtom
//    ;

constant
    : stringLiteral | decimalLiteral | '-' decimalLiteral | hexadecimalLiteral | booleanLiteral
    | REAL_LITERAL | BIT_STRING | NOT? nullLiteral=(NULL_LITERAL | NULL_SPEC_LITERAL)
    ;

stringLiteral
    : ( STRING_LITERAL
    | START_NATIONAL_STRING_LITERAL ) STRING_LITERAL+
    | ( STRING_LITERAL
    | START_NATIONAL_STRING_LITERAL ) (COLLATE collationName)?
    ;

collationName
    : uid | STRING_LITERAL
    ;

decimalLiteral
    : DECIMAL_LITERAL | ZERO_DECIMAL | ONE_DECIMAL | TWO_DECIMAL | REAL_LITERAL
    ;

hexadecimalLiteral
    : HEXADECIMAL_LITERAL
    ;

booleanLiteral
    : TRUE | FALSE
    ;

unaryOperator
    : '!' | '~' | '+' | '-' | NOT
    ;


mathOperator
    : '*' | '/' | '%' | DIV | MOD | '+' | '-'
    ;


functionArgs
    : (constant | fullColumnName)// | functionCall | expression)
        ( ',' (constant | fullColumnName))*// | functionCall | expression) )*
    ;


aggregateWindowedFunction
    : theKeyword? (AVG | MAX | MIN | SUM) ofKeyword? leftParen aggregator=(ALL | DISTINCT)? functionArg rightParen
    | theKeyword? COUNT ofKeyword? leftParen (starArg='*' | allAggregatorKeyword? functionArg
        | distinctAggregatorKeyword functionArgs) rightParen
//    | ( BIT_AND | BIT_OR | BIT_XOR | STD | STDDEV | STDDEV_POP | STDDEV_SAMP | VAR_POP | VAR_SAMP | VARIANCE )
//        leftParen aggregator=ALL? functionArg rightParen
//    | GROUP_CONCAT leftParen aggregator=DISTINCT? functionArgs
//        (ORDER BY orderByExpression (',' orderByExpression)* )? (SEPARATOR separator=STRING_LITERAL)? rightParen
    ;

//SpeakQl feature / syntactic sugar: OF and THE keywords to make speaking aggregate functions more natural
ofKeyword
    : OF
    ;

theKeyword
    : THE
    ;

functionArg
    : constant | fullColumnName //| functionCall | expression
    ;

allAggregatorKeyword
    : aggregator=ALL
    ;

distinctAggregatorKeyword
    : aggregator=DISTINCT
    ;

//nonAggregateWindowedFunction
//    : (LAG | LEAD) leftParen expression (',' decimalLiteral)? (',' decimalLiteral)? rightParen
//    | (FIRST_VALUE | LAST_VALUE) leftParen expression rightParen
//    | (CUME_DIST | DENSE_RANK | PERCENT_RANK | RANK | ROW_NUMBER) leftParen rightParen
//    | NTH_VALUE leftParen expression ',' decimalLiteral rightParen
//    | NTILE leftParen decimalLiteral rightParen
//    ;

scalarFunctionName
    : CURDATE | CURRENT_DATE | CURRENT_TIME | CURRENT_TIMESTAMP
    | CURTIME | DATE_ADD | DATE_SUB | IF | INSERT | LOCALTIME | LOCALTIMESTAMP | MID | NOW
    | REPLACE | SUBSTR | SUBSTRING | SYSDATE | TRIM | UTC_DATE | UTC_TIME | UTC_TIMESTAMP
    //| functionNameBase
    ;

//passwordFunctionClause
//    : functionName=(PASSWORD | OLD_PASSWORD) leftParen functionArg rightParen
//    ;

selectElementDelimiter //SPEAKQL FEATURE: ',' synonym for select elements for more natural language
    : ',' | AND
    ;

whereKeyword
    : WHERE ;

whereExpression
    : expression (logicalOperator expression)*
    ;

tableExpressionNoJoin
    : fromClauseNoJoin
    ;

tableExpression
    : fromClause
    ;
