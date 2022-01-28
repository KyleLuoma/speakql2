java org.antlr.v4.Tool SpeakQlLexer.g4 -o gen
java org.antlr.v4.Tool SpeakQlParser.g4 -o gen -lib gen
javac .\gens\SpeakQl*.java