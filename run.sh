lex lexer.l
yacc parser.y -d
gcc lex.yy.c y.tab.c symbol_table.c icg.c assembly.c -o optimizedICG
./optimizedICG

rm lex.yy.c y.tab.c y.tab.h
