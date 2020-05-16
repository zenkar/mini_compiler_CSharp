%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror(const char *s);
int valid=1;
extern int yylineno;
extern char *id,*sl,*num;
FILE *yyin;

typedef struct AST
{
	char *root;
	struct AST *left;
	struct AST *right;
}AST_node;
struct AST* make_node(char*,AST_node*,AST_node*);
void AST_print(struct AST *tree);
%}

%union
{
	char *str;
	struct AST *node;
	
}

%define parse.error verbose
%token <str> INT FLOAT CHAR DOUBLE BOOL STRING NUMBER
%token <str> TRUE FALSE
%token <str> FOR WHILE RETURN
%token <str> IDENTIFIER STRING_LITERAL
%token <str> CB_OPEN CB_CLOSE SB_OPEN SB_CLOSE RB_OPEN RB_CLOSE
%token <str> MOD ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token <str> INC DEC AND_BIT OR_BIT AND_LOG OR_LOG NOT_LOG
%token <str> USING NAMESPACE CLASS PUBLIC STATIC VOID MAIN NEW NL

%right <str> ASSIGN
%left <str> AND OR
%left <str> LTE GTE EQ NEQ LT GT
%left <str> ADD SUB
%left <str> MUL DIV

%type <node> S program namespace_unit class_unit method_declaration global_var method_body
%type <node> using_namespace_directive class_declaration namespace_name class_name type
%type <node> assignment array_creation_expression array_initializer 
%type <node> Z statement_expression expression E T F array_access 
%type <node> U boolean_expression conditional_or_expression conditional_and_expression conditional_not_expression
%type <node> K relational_expression statement block iteration_statement 
%type <node> while_loop local_variable_declaration variable_declarator variable_initializer X
%type <node> for_loop C for_initializer Y for_iterator
%%

S: program {AST_print($1);}
	| error ';' program{ yyerror;yyclearin;}
	;

program: namespace_unit {$$=$1;}
	;

namespace_unit: using_namespace_directive ';' namespace_unit {$$=$3;}
	| class_unit {$$=$1;}
	;

class_unit: class_declaration CB_OPEN method_declaration CB_CLOSE {$$=$3;}
	;

method_declaration: global_var STATIC MAIN RB_OPEN RB_CLOSE CB_OPEN method_body CB_CLOSE {$$=make_node("method_declaration",$1,$7);}
	;

global_var: local_variable_declaration ';' {$$=$1;}
	| {$$=NULL;}
	;

method_body: statement {$$=$1;}
	;

using_namespace_directive: USING namespace_name {$$=NULL;}
	;

class_declaration: CLASS class_name {$$=NULL;}
	;

namespace_name: IDENTIFIER {$$=NULL;}
	;

class_name: IDENTIFIER {$$=NULL;}
	;


/*Types*/

type: INT {$$=NULL;}  
      | FLOAT {$$=NULL;}
      | DOUBLE {$$=NULL;}
      | CHAR {$$=NULL;}
      | STRING {$$=NULL;}
      | BOOL {$$=NULL;}
      | type SB_OPEN SB_CLOSE {$$=NULL;}
      ;

/*Expressions*/

assignment: IDENTIFIER ASSIGN expression {$1=id;$$=make_node("=",make_node($1,NULL,NULL),$3);}
	| IDENTIFIER ADD_ASSIGN expression {$1=id;$$=make_node("+=",make_node($1,NULL,NULL),$3);}
	| IDENTIFIER SUB_ASSIGN expression {$1=id;$$=make_node("-=",make_node($1,NULL,NULL),$3);}
	| IDENTIFIER MUL_ASSIGN expression {$1=id;$$=make_node("*=",make_node($1,NULL,NULL),$3);}
	| IDENTIFIER DIV_ASSIGN expression {$1=id;$$=make_node("/=",make_node($1,NULL,NULL),$3);}
	;


array_creation_expression: NEW type SB_OPEN expression SB_CLOSE array_initializer {$$=make_node("array_creation_expression",$4,$6);}
                           | NEW type SB_OPEN expression SB_CLOSE {$$=$4;}
			   | array_initializer {$$=$1;}
                           ;

array_initializer: CB_OPEN expression Z CB_CLOSE {$$=make_node("array_initializer",$2,$3);}
                   ;

Z: ',' expression Z {$$=make_node("Z",$2,$3);} 
   | {$$=NULL;}
   ;

statement_expression: assignment {$$=$1;}
		    | U {$$=$1;}
                      ;

expression: E  {$$=$1;}
            ;

E: E ADD T {$$=make_node("+",$1,$3);}     
   | E SUB T {$$=make_node("-",$1,$3);}   
   | T   {$$=$1;}       
   ;

T: T MUL F  {$$=make_node("*",$1,$3);}
   | T DIV F  {$$=make_node("/",$1,$3);}
   | F  {$$=$1;}
   ;


F: IDENTIFIER {$$=make_node(id,NULL,NULL);}
   | NUMBER {$$=make_node(num,NULL,NULL);}
   | array_access {$$=$1;}
   | STRING_LITERAL {$$=make_node(sl,NULL,NULL);}
   ;

array_access : IDENTIFIER SB_OPEN expression SB_CLOSE {$$=make_node("array_access",make_node(id,NULL,NULL),$3);}
	     ;

U : INC F {$$=make_node("++",NULL,$2);}
	| DEC F {$$=make_node("--",NULL,$2);}
	| F INC {$$=make_node("++",$1,NULL);}
	| F DEC {$$=make_node("--",$1,NULL);}
	;


boolean_expression: conditional_or_expression {$$=$1;}
                    | assignment {$$=$1;}
                    ;

conditional_or_expression: conditional_or_expression OR_LOG conditional_and_expression {$$=make_node("||",$1,$3);}
                        | conditional_and_expression {$$=$1;}
                        ;

conditional_and_expression: conditional_and_expression AND_LOG conditional_not_expression {$$=make_node("&&",$1,$3);}
                            | conditional_not_expression {$$=$1;}
                            ;

conditional_not_expression: NOT_LOG conditional_not_expression {$$=make_node("!",NULL,$2);}
                            | K {$$=$1;}
                            ;

K: RB_OPEN boolean_expression RB_CLOSE {$$=$2;}
   | relational_expression {$$=$1;}
   | TRUE {$$=make_node("TRUE",NULL,NULL);}
   | FALSE {$$=make_node("FALSE",NULL,NULL);}
   ;

relational_expression:  F LT F {$$=make_node("<",$1,$3);}
			| F GT F {$$=make_node(">",$1,$3);}
			| F LTE F {$$=make_node("<=",$1,$3);}
			| F GTE F {$$=make_node(">=",$1,$3);}
			| F EQ F {$$=make_node("==",$1,$3);}
			| F NEQ F {$$=make_node("!=",$1,$3);}
                        | expression {$$=$1;}
                       ;
                     ;
                     
/*statements*/

statement:  statement_expression ';' statement {$$=make_node("statement",$1,$3);}
            | block statement {$$=$1;}
            | local_variable_declaration  ';' statement {$$=make_node("statement",$1,$3);} 
            | iteration_statement {$$=$1;}
            | {$$=NULL;}
            ;

block: CB_OPEN statement CB_CLOSE {$$=$2;}
       ;

iteration_statement: for_loop {$$=$1;}
                     | while_loop {$$=$1;}
                     ;

/*WHILE*/
while_loop: WHILE RB_OPEN boolean_expression RB_CLOSE statement {$$=make_node("WHILE",$3,$5);}
            ;

local_variable_declaration: type variable_declarator {$$=$2;}
                            ;

variable_declarator: IDENTIFIER X {$$=make_node("variable_declarator",make_node(id,NULL,NULL),$2);}
                     | IDENTIFIER ASSIGN variable_initializer  X {$$=make_node("=",make_node(id,NULL,NULL),make_node("variable_initializer_x",$3,$4));}
                     ;

X: ',' variable_declarator {$$=$2;}
   | {$$=NULL;}
   ;

variable_initializer: expression {$$=$1;}
		      | array_creation_expression {$$=$1;}
                      ;

/*FOR*/

for_loop: FOR RB_OPEN for_initializer ';' C ';' for_iterator RB_CLOSE statement {$$=make_node("FOR",make_node("for_initializer_C",$3,$5),make_node("for_iterator_statement",$7,$9));}
          ;

C:  boolean_expression {$$=$1;}
    | {$$=NULL;}
   ;

for_initializer: local_variable_declaration {$$=$1;}
                | statement_expression Y {$$=make_node("for_initializer",$1,$2);}
                | {$$=NULL;}
                ;

for_iterator: statement_expression Y {$$=make_node("for_iterator",$1,$2);}
		| {$$=NULL;}
              ;

Y: ',' statement_expression {$$=$2;}
   | {$$=NULL;}
   ;

%%


#include <ctype.h>
void AST_print(struct AST *t){

	if(t->left || t->right)
		printf("(");
	printf(" %s ",t->root);
	if(t->left)
		AST_print(t->left);
	if(t->right)
		AST_print(t->right);
	if(t->left || t->right)
		printf(")");
}

struct AST* make_node(char* root, AST_node* child1, AST_node* child2)
{
	
	struct AST * node = (struct AST*)malloc(sizeof(struct AST));
	
	char *newstr=(char *)malloc(strlen(root)+1);
	strcpy(newstr,root);
	node->left=child1;
	node->right=child2;
	node->root=newstr;
	return(node);
}

int yyerror(const char *s)
{
	valid=0;
	printf("Line no.: %d \nERROR!: %s\n",yylineno,s);

}

int main()
{
	yyin=fopen("./tests/while.cs","r");
	yyparse();
	if(valid)
		printf("\n\n ###########Parsing successful#############\n\n");
	else
		printf("PARSING SUCCESSFUL");
	fclose(yyin);
	return 0;
}


