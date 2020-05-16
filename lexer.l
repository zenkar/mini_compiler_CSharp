%{
#include "header.h"
#include "y.tab.h"


#define TOK(t) return t;

%}

/* %option noyywrap */

comment_start \/\* 
comment_end  \*\/ 

%% 

\/[\/]+.*[\n\t]*	{}
"/*"([^*]|\*+[^*/])*\*+"/"[\n\t]*	{} 

[\n]                    { yylineno++; }

"using"                 { TOK(USING); }
"namespace"             { TOK(NAMESPACE); }
"class"                 { TOK(CLASS); }
"public"                { TOK(PUBLIC); }
"static"                { TOK(STATIC); }
"void"                  { TOK(VOID); }
"Main"                  { TOK(MAIN); }
"new"                   { TOK(NEW); }

"int"					{ TOK(INT); }
"float"					{ TOK(FLOAT); }
"double"				{ TOK(DOUBLE); }
"char"					{ TOK(CHAR); }
"bool"                  { TOK(BOOL); }
"string"                { TOK(STRING); }
"for"					{ TOK(FOR); }
"return"				{ TOK(RETURN); }
"while"					{ TOK(WHILE); }

"+"                     { TOK(ADD); }
"-"                     { TOK(SUB); }
"*"                     { TOK(MUL); }
"/"                     { TOK(DIV); }
"%"                     { TOK(MOD); }
"="                     { TOK(ASSIGN); }
"+="					{ TOK(ADD_ASSIGN); }
"-="					{ TOK(SUB_ASSIGN); }
"*="					{ TOK(MUL_ASSIGN); }
"/="					{ TOK(DIV_ASSIGN); }
"%="					{ TOK(MOD_ASSIGN); }
"++"					{ TOK(INC); }
"--"					{ TOK(DEC); }
"&"					    { TOK(AND_BIT); }
"|"					    { TOK(OR_BIT); }
"&&"					{ TOK(AND_LOG); }
"||"					{ TOK(OR_LOG); }
"!"                     { TOK(NOT_LOG); }
"<"                     { TOK(LT);}
">"                     { TOK(GT);}
"<="					{ TOK(LTE); }
">="					{ TOK(GTE); }
"=="					{ TOK(EQ); }
"!="					{ TOK(NEQ); }
("{")				    { scope++; TOK(CB_OPEN); }
("}")				    { scope--; TOK(CB_CLOSE); }
"("					    { TOK(RB_OPEN); }
")"					    { TOK(RB_CLOSE); }
("[")				    { TOK(SB_OPEN); }
("]")				    { TOK(SB_CLOSE); }
";"					    { TOK(';'); }
","					    { TOK(','); }

"true"                  { TOK(TRUE); }
"false"                 { TOK(FALSE); }
[0-9]+                  { yylval = atoi(yytext); TOK(NUMBER); }
\"(\\.|[^"\\])*\"  { TOK(STRING_LITERAL); }

[_a-zA-Z][0-9_a-zA-Z]*  { id=strdup(yytext); TOK(IDENTIFIER); }
" "                     {}
%%

int yywrap()
{
    return 1;
}
