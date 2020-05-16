#include "header.h"

int tokenNo = 0, scope = 0, yylineno, valid = 1;
char lastType[10] = "VOID";
struct symbol symbolTable[100];

void init()
{
    // tokenNo = 0, scope = 0, valid = 1;
    // strcpy("CHAR", lastType);
}

void install_id(int lineNo, int scope, char *symbol, char *type)
{
    symbolTable[tokenNo].lineNoDeclared = lineNo;
    symbolTable[tokenNo].lineNoLastUsed = lineNo;
    symbolTable[tokenNo].scope = scope;
    strcpy(symbolTable[tokenNo].symbol, symbol);
    strcpy(symbolTable[tokenNo].type, type);
    tokenNo++;
}

int lookup_id(char *symbol)
{
    for (int i = 0; i < tokenNo; i++)
    {
        if (0 == strcmp(symbol, symbolTable[i].symbol))
        {
            if (symbolTable[i].scope <= scope)
            {
                // symbolTable[i].lineNoLastUsed = yylineno;
                return 1; // valid, in the right scope
            }
            return 2; // invalid, not in the right scope
        }
    }
    return 0;
}

void display_symbol_table()
{
    printf("\n\n---------------------------------------------------------------------------------------------------");
    printf("\n    SYMBOL TABLE \n\n");
    printf("%7s\t%8s\t%15s\t%20s\t%10s\t%10s\n", "Sl No.", "Type", "Identifier", "Line No(declared)", "Scope", "Value");
    for (int i = 0; i < tokenNo; i++)
    {
        printf("%6d\t%8s\t%15s\t%20d\t%10d\t%10d\n", i, symbolTable[i].type, symbolTable[i].symbol, symbolTable[i].lineNoDeclared, symbolTable[i].scope, symbolTable[i].value);
    }
    printf("----------------------------------------------------------------------------------------------------");
    printf("\n\n");
}

void set_last_type(char *type)
{
    strcpy(lastType, type);
}

void set_id_value(char *symbol, int val)
{
    for (int i = 0; i < tokenNo; i++)
    {
        if ((0 == strcmp(symbol, symbolTable[i].symbol)) && (symbolTable[i].scope <= scope))
        {
            symbolTable[i].value = val;
            return;
        }
    }
}

int get_id_value(char *symbol)
{
    for (int i = 0; i < tokenNo; i++)
    {
        if ((0 == strcmp(symbol, symbolTable[i].symbol)) && (symbolTable[i].scope <= scope))
        {
            return symbolTable[i].value;
        }
    }
}

void check_install_id(int lineNo, int scope, char *symbol, char *type)
{
    for (int i = 0; i < tokenNo; i++)
    {
        if ((0 == strcmp(symbol, symbolTable[i].symbol)) && (symbolTable[i].scope == scope))
        {
            char err[50];
            snprintf(err, sizeof(err), "variable '%s' is re-declared", symbol);
            yyerror(err);
            return;
        }
        if ((0 == strcmp(symbol, symbolTable[i].symbol)) && (symbolTable[i].scope < scope))
        {
            install_id(yylineno, scope, symbol, lastType);
            return;
        }
    }
    install_id(yylineno, scope, symbol, lastType);
}

int check_id_declared(char *s)
{
    int val = lookup_id(s);
    char err[50];
    if (val == 0)
    {
        snprintf(err, sizeof(err), "variable '%s' not declared", s);
        yyerror(err);
        return 0;
    }
    else if (val == 2)
    {
        snprintf(err, sizeof(err), "variable '%s' not declared in this scope", s);
        yyerror(err);
        return 0;
    }

    return 1;
}
