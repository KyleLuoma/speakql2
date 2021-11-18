parser grammar SpeakQlParser;

options { tokenVocab=SpeakQlLexer; }

root
    : sqlStatements? (MINUS MINUS)? EOF
    ;

sqlStatements
    : (sqlStatement (MINUS MINUS)? SEMI? | emptyStatement)*
    (sqlStatement ((MINUS MINUS)? SEMI)? | emptyStatement)
    ;

sqlStatement
    : dmlStatement
    ;

emptyStatement
    : SEMI
    ;

dmlStatement
    : selectStatement
    ;

selectStatement
    : querySpecification lockClause?                                #simpleSelect
    | queryExpression lockClause?                                   #parenthesisSelect
    | querySpecificationNointo unionStatement+
        (
          UNION unionType=(ALL | DISTINCT)?
          (querySpecification | queryExpression)
        )?
        orderByClause? limitClause? lockClause?                     #unionSelect
    | queryExpressionNointo unionParenthesis+
        (
          UNION unionType=(ALL | DISTINCT)?
          queryExpression
        )?
        orderByClause? limitClause? lockClause?                     #unionParenthesisSelect
    ;

queryExpression
    : '(' querySpecification ')'
    | '(' queryExpression ')'
    ;

queryExpressionNointo
    : '(' querySpecificationNointo ')'
    | '(' queryExpressionNointo ')'
    ;

querySpecification
    : SELECT selectSpec* selectElements selectIntoExpression?
      fromClause? groupByClause? havingClause? windowClause? orderByClause? limitClause?
    | SELECT selectSpec* selectElements
    fromClause? groupByClause? havingClause? windowClause? orderByClause? limitClause? selectIntoExpression?
    ;

querySpecificationNointo
    : SELECT selectSpec* selectElements
      fromClause? groupByClause? havingClause? windowClause? orderByClause? limitClause?
    ;

selectSpec
    : (ALL | DISTINCT | DISTINCTROW)
    | HIGH_PRIORITY | STRAIGHT_JOIN | SQL_SMALL_RESULT
    | SQL_BIG_RESULT | SQL_BUFFER_RESULT
    | (SQL_CACHE | SQL_NO_CACHE)
    | SQL_CALC_FOUND_ROWS
    ;

selectElements
    : (star='*' | selectElement ) (',' selectElement)*
    ;

selectElement
    : fullId '.' '*'                                                #selectStarElement
    | fullColumnName (AS? uid)?                                     #selectColumnElement
    | functionCall (AS? uid)?                                       #selectFunctionElement
    | (LOCAL_ID VAR_ASSIGN)? expression (AS? uid)?                  #selectExpressionElement
    ;

selectIntoExpression
    : INTO assignmentField (',' assignmentField )*                  #selectIntoVariables
    | INTO DUMPFILE STRING_LITERAL                                  #selectIntoDumpFile
    | (
        INTO OUTFILE filename=STRING_LITERAL
        (CHARACTER SET charset=charsetName)?
        (
          fieldsFormat=(FIELDS | COLUMNS)
          selectFieldsInto+
        )?
        (
          LINES selectLinesInto+
        )?
      )                                                             #selectIntoTextFile
    ;

fromClause
    : (FROM tableSources)?
      (WHERE whereExpr=expression)?
    ;

tableSources
    : tableSource (',' tableSource)*
    ;

lockClause
    : FOR UPDATE | LOCK IN SHARE MODE
    ;

unionStatement
    : UNION unionType=(ALL | DISTINCT)?
      (querySpecificationNointo | queryExpressionNointo)
    ;

unionParenthesis
    : UNION unionType=(ALL | DISTINCT)? queryExpressionNointo
    ;

orderByClause
    : ORDER BY orderByExpression (',' orderByExpression)*
    ;

orderByExpression
    : expression order=(ASC | DESC)?
    ;

limitClause
    : LIMIT
    (
      (offset=limitClauseAtom ',')? limit=limitClauseAtom
      | limit=limitClauseAtom OFFSET offset=limitClauseAtom
    )
    ;

expression
    : notOperator=(NOT | '!') expression                            #notExpression
    | expression logicalOperator expression                         #logicalExpression
    | predicate IS NOT? testValue=(TRUE | FALSE | UNKNOWN)          #isExpression
    | predicate                                                     #predicateExpression
    ;

predicate
    : predicate NOT? IN '(' (selectStatement | expressions) ')'     #inPredicate
    | predicate IS nullNotnull                                      #isNullPredicate
    | left=predicate comparisonOperator right=predicate             #binaryComparisonPredicate
    | predicate comparisonOperator
      quantifier=(ALL | ANY | SOME) '(' selectStatement ')'         #subqueryComparisonPredicate
    | predicate NOT? BETWEEN predicate AND predicate                #betweenPredicate
    | predicate SOUNDS LIKE predicate                               #soundsLikePredicate
    | predicate NOT? LIKE predicate (ESCAPE STRING_LITERAL)?        #likePredicate
    | predicate NOT? regex=(REGEXP | RLIKE) predicate               #regexpPredicate
    | (LOCAL_ID VAR_ASSIGN)? expressionAtom                         #expressionAtomPredicate
    | predicate MEMBER OF '(' predicate ')'                         #jsonMemberOfPredicate
    ;