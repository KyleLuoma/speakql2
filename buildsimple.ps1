java org.antlr.v4.Tool SimpleSpeakQlLexer.g4 -o gen_simple -package gen_simple
java org.antlr.v4.Tool SimpleSpeakQlParser.g4 -o gen_simple -lib gen_simple -visitor -package gen_simple
#javac .\gen_simple\SimpleSpeakQl*.java