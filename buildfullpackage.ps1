echo "Building lexer"
java org.antlr.v4.Tool SpeakQlLexer.g4 -o gen_full_speakql -package speakql
echo "Building parser"
java org.antlr.v4.Tool SpeakQlParser.g4 -o gen_full_speakql -lib gen_full_speakql -visitor -package speakql
