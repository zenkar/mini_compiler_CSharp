%{
#include<stdio.h>
int c=0;
%}
%%
\/[\/]+.*[\n\t]*	{fprintf(yyout, "");}
"/*"([^*]|\*+[^*/])*\*+"/"[\n\t]*	{fprintf(yyout, "");}
%%
int main()
{
	yyin=fopen("tests/for.cs","r");
	yyout=fopen("CLEAN_CODE.cs","w");
	yylex();
	//printf("number of comments=%d\n",c);
	return 0;
	}

