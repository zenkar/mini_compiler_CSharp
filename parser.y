%{

#include "header.h"
#include <string.h>

int yylex();
int yyerror(const char *s);

int temp_i = 1;
char op[10];
char arg1[10];
char arg2[10];
char result[10];

FILE *yyin;

%}

%define parse.error verbose

%token INT FLOAT CHAR DOUBLE BOOL STRING NUMBER
%token TRUE FALSE
%token FOR WHILE RETURN
%token IDENTIFIER STRING_LITERAL
%token CB_OPEN CB_CLOSE SB_OPEN SB_CLOSE RB_OPEN RB_CLOSE
%token MOD ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token INC DEC AND_BIT OR_BIT AND_LOG OR_LOG NOT_LOG
%token USING NAMESPACE CLASS PUBLIC STATIC VOID MAIN NEW NL
%right ASSIGN
%left AND OR
%left LTE GTE EQ NEQ LT GT
%left ADD SUB
%left MUL DIV

%%

/*NAME SPACES*/

S: program {isLoop = 0;}
   |error ';' program{ yyerrok; yyclearin;}
   ;

program:    namespace_unit
    ;

namespace_unit: using_namespace_directive ';' namespace_unit
    | class_unit
    ;

class_unit: class_declaration CB_OPEN method_declaration CB_CLOSE
    ;

method_declaration: global_var STATIC MAIN RB_OPEN RB_CLOSE CB_OPEN method_body CB_CLOSE
    ;

global_var: local_variable_declaration ';'
    |
    ;

method_body:    statement
    ;

using_namespace_directive:  USING namespace_name
    ;

class_declaration:  CLASS class_name
    ;

namespace_name: IDENTIFIER
    ;

class_name: IDENTIFIER
    ; 

/*Types*/

type: INT   { set_last_type("int"); }
      | FLOAT { set_last_type("float"); }
      | DOUBLE { set_last_type("double"); }
      | CHAR { set_last_type("char"); }
      | STRING { set_last_type("string"); }
      | BOOL { set_last_type("bool"); }
      | type SB_OPEN SB_CLOSE
      ;

/*Expressions*/

assignment: IDENTIFIER{temp_id=strdup(id);push(temp_id);} ASSIGN expression {
        if (check_id_declared(temp_id)) {
            set_id_value(temp_id, $4);
            strcpy(arg1, pop());
            strcpy(result, pop());
            addQuadruple("=", arg1, "NULL", result, isLoop);
            fprintf(fp, "%s = %s \n", result, arg1);           
        }	    
    }

	| IDENTIFIER{temp_id=strdup(id); push(temp_id);} ADD_ASSIGN expression {
        if (check_id_declared(temp_id)) 
        {
            int temp = get_id_value(id);
            temp += $4;
            set_id_value(temp_id, temp);
            strcpy(arg2, pop());
            strcpy(arg1, pop());

            sprintf(result, "t%d", temp_i);
            addQuadruple("+", arg1, arg2, result, isLoop);
            addQuadruple("=", result, "NULL", arg1, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $4);
            
            fprintf(fp, "%s = %s + %s \n", result, arg1, arg2);
            fprintf(fp, "%s = %s \n", arg1, result);
            temp_i++;
        }
    }
	| IDENTIFIER{temp_id=strdup(temp_id); push(temp_id);} SUB_ASSIGN expression {
        if (check_id_declared(temp_id)) {
            int temp = get_id_value(id);
            temp -= $4;
            set_id_value(temp_id, temp);
            strcpy(arg2, pop());
            strcpy(arg1, pop());

            sprintf(result, "t%d", temp_i);
            addQuadruple("-", arg1, arg2, result, isLoop);
            addQuadruple("=", result, "NULL", arg1, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $4);   

            fprintf(fp, "%s = %s - %s \n", result, arg1, arg2);
            fprintf(fp, "%s = %s \n", arg1, result);
            temp_i++;
        }
    }
	| IDENTIFIER{temp_id=strdup(id); push(temp_id);} MUL_ASSIGN expression {
        if (check_id_declared(temp_id)) {
            int temp = get_id_value(temp_id);
            temp *= $4;
            set_id_value(temp_id, temp);
            strcpy(arg2, pop());
            strcpy(arg1, pop());
            sprintf(result, "t%d", temp_i);
            addQuadruple("*", arg1, arg2, result, isLoop);
            addQuadruple("=", result, "NULL", arg1, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $4);

            fprintf(fp, "%s = %s * %s \n", result, arg1, arg2);
            fprintf(fp, "%s = %s \n", arg1, result);
            temp_i++;
        }
    }
	| IDENTIFIER{temp_id=strdup(id); push(temp_id);} DIV_ASSIGN expression {
        if (check_id_declared(temp_id)) {
            int temp = get_id_value(temp_id);
            temp /= $4;
            set_id_value(temp_id, temp);
            strcpy(arg2, pop());
            strcpy(arg1, pop());
            sprintf(result, "t%d", temp_i);
            addQuadruple("/", arg1, arg2, result, isLoop);
            addQuadruple("=", result, "NULL", arg1, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $4);            
            fprintf(fp, "%s = %s / %s \n", result, arg1, arg2);
            fprintf(fp, "%s = %s \n", arg1, result);
            temp_i++;
        }
    }
	;

array_creation_expression: NEW type SB_OPEN expression SB_CLOSE array_initializer
                           | NEW type SB_OPEN expression SB_CLOSE
			               | array_initializer
                           ;

array_initializer: CB_OPEN expression Z CB_CLOSE
                   ;

Z: ',' expression Z
   |
   ;

statement_expression: assignment
		    | U { $$ = $1;}
            ;

expression: E   { $$ = $1;}
            ;

E: E ADD T      {   $$ = $1 + $3;        
                    strcpy(arg2, pop());
                    strcpy(arg1, pop());
                    sprintf(result, "t%d", temp_i);
                    addQuadruple("+", arg1, arg2, result, isLoop);
                    check_install_id(yylineno, scope, result, lastType);                    
                    set_id_value(result, $$);
                    fprintf(fp, "%s = %s + %s \n", result, arg1, arg2);
                    temp_i++;
                    push(result);
                }

   | E SUB T    {   $$ = $1 - $3; 
                    strcpy(arg2, pop());
                    strcpy(arg1, pop());
                    sprintf(result, "t%d", temp_i);
                    addQuadruple("-", arg1, arg2, result, isLoop);
                    check_install_id(yylineno, scope, result, lastType);
                    set_id_value(result, $$);                    
                    fprintf(fp, "%s = %s - %s \n", result, arg1, arg2);
                    temp_i++;
                    push(result);                
                }
   | T          {   $$ = $1;     
                }
   ;

T: T MUL F      {   $$ = $1 * $3; 
                    strcpy(arg2, pop());
                    strcpy(arg1, pop());
                    sprintf(result, "t%d", temp_i);
                    addQuadruple("*", arg1, arg2, result, isLoop);
                    check_install_id(yylineno, scope, result, lastType);
                    set_id_value(result, $$);                    
                    fprintf(fp, "%s = %s * %s \n", result, arg1, arg2);
                    temp_i++;
                    push(result);                  
                }
   | T DIV F    { $$ = $1 / $3; 
                    strcpy(arg2, pop());
                    strcpy(arg1, pop());
                    sprintf(result, "t%d", temp_i);
                    addQuadruple("/", arg1, arg2, result, isLoop);
                    fprintf(fp, "%s = %s / %s \n", result, arg1, arg2);
                    check_install_id(yylineno, scope, result, lastType);
                    set_id_value(result, $$);                    
                    temp_i++;
                    push(result);  
                }

   | F          { $$ = $1;}
   ;

F: IDENTIFIER   { if (check_id_declared(id)) {
                    $$ = get_id_value(id);
                    push(id);
                }
                }
   | NUMBER {$$ = yylval; char num[5]; sprintf(num, "%d", $$); push(num);}
   | array_access
   | STRING_LITERAL
   | U {$$ = $1;}
   ;

array_access : IDENTIFIER SB_OPEN expression SB_CLOSE
	     ;


U : INC IDENTIFIER {
        if (check_id_declared(id)) 
        {
            int temp = get_id_value(id);
            temp = temp + 1;
            set_id_value(id, temp);
            $$ = temp;
            sprintf(result, "t%d", temp_i);
            addQuadruple("+", id, "1", result, isLoop);
            addQuadruple("=", result, "NULL", id, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $$);
            fprintf(fp, "%s = %s + %s \n", result, id, "1");
            fprintf(fp, "%s = %s \n", id, result);
            temp_i++;
            //push(id);
        }
    }
    | DEC IDENTIFIER  {
        if (check_id_declared(id)) {
            int temp = get_id_value(id);
            temp = temp - 1;
            set_id_value(id, temp);
            $$ = temp;                        
            sprintf(result, "t%d", temp_i);
            addQuadruple("-", id, "1", result, isLoop);
            addQuadruple("=", result, "NULL", id, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $$);
            fprintf(fp, "%s = %s - %s \n", result, id, "1");
            fprintf(fp, "%s = %s \n", id, result);
            temp_i++;
            //push(id);
        }
    }
	| IDENTIFIER INC  {
        if (check_id_declared(id)) {
            int temp = get_id_value(id);
            $$ = temp;
            sprintf(arg1, "t%d", temp_i);
            addQuadruple("=", id, "NULL", arg1, isLoop);
            fprintf(fp, "%s = %s \n", arg1, id);
            temp_i++;
            temp = temp + 1;
            set_id_value(id, temp);
            sprintf(result, "t%d", temp_i);
            addQuadruple("+", id, "1", result, isLoop);
            addQuadruple("=", result, "NULL", id, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $$);
            fprintf(fp, "%s = %s + %s \n", result, id, "1");
            fprintf(fp, "%s = %s \n", id, result);
            temp_i++;
            //push(arg1);
        }
    }
    | IDENTIFIER DEC  {
        if (check_id_declared(id)) {
            int temp = get_id_value(id);
            $$ = temp;
            sprintf(arg1, "t%d", temp_i);
            addQuadruple("=", id, "NULL", arg1, isLoop);
            fprintf(fp, "%s = %s \n", arg1,id);
            temp_i++;
            temp = temp - 1;
            set_id_value(id, temp);

            sprintf(result, "t%d", temp_i);
            addQuadruple("-", id, "1", result, isLoop);
            addQuadruple("=", result, "NULL", id, isLoop);
            check_install_id(yylineno, scope, result, lastType);
            set_id_value(result, $$);
            fprintf(fp, "%s = %s - %s \n", result, id, "1");
            fprintf(fp, "%s = %s \n", id, result);
            temp_i++;
            //push(arg1);
        }
    }
	;

boolean_expression: conditional_or_expression
                    | assignment
                    ;

conditional_or_expression: conditional_or_expression OR_LOG conditional_and_expression
                        | conditional_and_expression
                        ;

conditional_and_expression: conditional_and_expression AND_LOG conditional_not_expression
                            | conditional_not_expression
                            ;

conditional_not_expression: NOT_LOG conditional_not_expression 
                            | K
                            ;

K: RB_OPEN boolean_expression RB_CLOSE 
   | relational_expression
   | TRUE   {push("true");}
   | FALSE  {push("false");}
   ;

relational_expression:  F relational_operator F{
                            sprintf(result, "t%d", temp_i); 
                            temp_i++;
                            strcpy(arg2, pop());
                            strcpy(op, pop());
                            strcpy(arg1, pop());
                            addQuadruple(op, arg1, arg2, result, isLoop);
                            //check_install_id(yylineno, scope, result, lastType);
                            // install_id(result, $$);
                            fprintf(fp, "%s = %s %s %s \n", result, arg1, op, arg2);
                            push(result);
                        }
                        | expression
                       ;

relational_operator: LT { push("<");}
                     | GT { push(">");}
                     | LTE {push("<=");}
                     | GTE { push(">=");}
                     | EQ { push("==");}
                     | NEQ { push("!=");}
                     ;
                     
/*statements*/

statement:  statement_expression ';' statement
            | block statement
            | local_variable_declaration  ';' statement
            | iteration_statement statement
            | 
            ;

S_:     statement_expression ';' {emptyStack();}
        | block {emptyStack();}
        | local_variable_declaration  ';' {emptyStack();}
        | iteration_statement {emptyStack();}
        | ';' {emptyStack();}
        ;

block: CB_OPEN statement CB_CLOSE
       ;

iteration_statement: { isLoop = 1; } for_loop { isLoop = 0; }
                     | { isLoop = 1; } while_loop { isLoop = 0; }
                     ;

/*WHILE*/
while_loop: WHILE {while1();} RB_OPEN boolean_expression RB_CLOSE {while2();} S_
            ;

local_variable_declaration: type variable_declarator
                            ;

variable_declarator: IDENTIFIER { check_install_id(yylineno, scope, id, lastType); fprintf(fp, "%s %s \n", lastType, id); set_id_value(id, INT_MAX); } X
                        | IDENTIFIER  { 
                            check_install_id(yylineno, scope, id, lastType); 
                            temp_id=strdup(id);
                            push(temp_id); } 
                            
                            ASSIGN variable_initializer { 
                                set_id_value(temp_id, $4); 
                                strcpy(arg1, pop()); 
                                strcpy(result, pop()); 
                                printf("%s", arg1);
                                fprintf(fp, "%s %s \n", lastType, result); 
                                addQuadruple("=", arg1, "NULL", result, isLoop); 
                                fprintf(fp, "%s = %s \n", result, arg1); } X 
                        ;

X: ',' variable_declarator
   |
   ;

variable_initializer: expression {$$ = $1;}
		      | array_creation_expression 
                      ;

/*FOR*/

for_loop: FOR RB_OPEN for_intializer ';' {for1(); temp_id = top();} 
          C ';'{if(strcmp(temp_id, top())==0)
                    push("true");
                for2();
               } 

          for_iterator RB_CLOSE {for3();} S_
          ;

C:  boolean_expression
    |
   ;

for_intializer: local_variable_declaration 
                | statement_expression Y
                | 
                ;

for_iterator: statement_expression Y
		|
              ;

Y: ',' statement_expression
   |
   ;

%%


int yyerror(const char *s)
{
  	valid = 0;
  	printf("\n" RED "ERROR!:" RESET " %s  " MAGENTA "(line no: %d)\n" RESET, s, yylineno);

}

int main()
{
    yyin = fopen("./tests/for.cs", "r"); 
    fp = fopen("./UNOPTIMIZED_ICG.txt", "w");
    FILE *fp2 = fopen("./INTERMEDIATE_CODE.txt","w");
    acf = fopen("./ASSEMBLY_CODE.txt","w");
	yyparse();
	if(valid)
  		printf(GREEN "\n\nPARSING SUCCESSFUL!!\n\n" RESET);
	else
	{
  		printf(RED "\n\nPARSING UNSUCCESSFUL!!\n\n" RESET);
	}

    fclose(yyin);

    //display_symbol_table();
    //display_Quadruple();
    optimize();
    display_Quadruple();
    printICG(fp2);
    display_symbol_table();
    assembly_code();

	return 0;
}
