lex lexer3.l
yacc parser3.y -d -v
gcc lex.yy.c y.tab.c -ll
./a.out > AST.txt
rm lex.yy.c y.tab.c y.tab.h y.output a.out
