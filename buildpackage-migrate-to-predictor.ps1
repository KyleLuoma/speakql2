echo "Building lexer"
java org.antlr.v4.Tool SimpleSpeakQlLexer.g4 -o gen_package -package antlrgen
echo "Building parser"
java org.antlr.v4.Tool SimpleSpeakQlParser.g4 -o gen_package -lib gen_package -visitor -package antlrgen
echo "Copying lexer and parser package to speakql_predictor source directory"
cp .\gen_package\* C:\java_projects\speakql_predictor\src\main\java\antlrgen