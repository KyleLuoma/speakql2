java org.antlr.v4.Tool SimpleSpeakQlLexer.g4 -o gen_package -package antlrgen
java org.antlr.v4.Tool SimpleSpeakQlParser.g4 -o gen_package -lib gen_package -visitor -package antlrgen
