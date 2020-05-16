#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define INT_MAX 2147483647

#define RED "\x1b[31m"
#define GREEN "\x1b[32m"
#define YELLOW "\x1b[33m"
#define BLUE "\x1b[34m"
#define MAGENTA "\x1b[35m"
#define CYAN "\x1b[36m"
#define RESET "\x1b[0m"

FILE *fp;
FILE *acf;
int Index;

struct symbol
{
    int lineNoDeclared;
    int lineNoLastUsed;
    int scope;
    int value;
    char symbol[50];
    char type[50];
};

struct registers
{
    char var[50];
}reg[14];

char *id, *temp_id;
extern int tokenNo, scope, yylineno, valid;
extern char lastType[10];
extern struct symbol symbolTable[100];
struct symbol symbolTable_opt[100];

void init();
void install_id(int lineNo, int scope, char *symbol, char *type);
int lookup_id(char *symbol);
void display_symbol_table();
void set_last_type();
int yyerror(const char *s);

int check_id_declared(char *);
void check_install_id(int lineNo, int scope, char *symbol, char *type);
void set_id_value(char *s, int val);
int get_id_value(char *s);

struct Quadruple
{
    char operator[10];
    char arg1[10];
    char arg2[10];
    char result[10];
    int isLoop;
} Quad[100];

int Index;
int isLoop;
struct Stack
{
    char *items[100];
    int top;
} Stack;

void push(char *str);
char *pop();
void addQuadruple(char op[10], char op2[10], char op1[10], char res[10], int isLoop);
void display_Quadruple();
void while1();
void while2();
void while3();
void for1();
void for2();
void for3();
void for4();
char *top();
void emptyStack();

int deadCodeElimination();
int isBinaryOperator(char *op);
int constantFolding();
int isNumber(char *str);
int performOperation(char *op, int num1, int num2);
void printICG();
int constantPropagation(int res, int index);
int propagate();
void optimize();

void print_instr(char* cmd, int i);
void assembly_code();
int search(char*);