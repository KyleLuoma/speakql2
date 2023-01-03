echo "Building lexer"
java org.antlr.v4.Tool SimpleSpeakQlLexer.g4 -o speakql_package -package speakql
echo "Building parser"
java org.antlr.v4.Tool SimpleSpeakQlParser.g4 -o speakql_package -lib speakql_package -visitor -package speakql
