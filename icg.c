#include "header.h"

char arg1[10];
char arg2[10];
char result[10];

Index = 0;

char *top()
{
	if (Stack.top == 0)
		return "NULL";
	return Stack.items[Stack.top];
}

void push(char *str)
{
	Stack.top++;
	Stack.items[Stack.top] = (char *)malloc(strlen(str) + 1);
	strcpy(Stack.items[Stack.top], str);
}

char *pop()
{
	int i;
	if (Stack.top == -1)
	{
		printf("\nStack Empty!! \n");
		exit(0);
	}
	char *str = (char *)malloc(strlen(Stack.items[Stack.top]) + 1);
	strcpy(str, Stack.items[Stack.top]);
	Stack.top--;
	return (str);
}

void addQuadruple(char op[10], char op1[10], char op2[10], char res[10], int isLoop)
{
	strcpy(Quad[Index].operator, op);
	strcpy(Quad[Index].arg2, op2);
	strcpy(Quad[Index].arg1, op1);
	strcpy(Quad[Index].result, res);
	Quad[Index].isLoop = isLoop;
	Index++;
}

void display_Quadruple()
{
	int i;
	printf("------------------------------------------------------------------------");
	printf("\n The Quadruple Table\n\n");
	printf("%3s %10s %10s %10s %10s %6s\n", "", "Result", "Operator", "Operand1", "Operand2", "isLoop");
	for (i = 0; i < Index; i++)
	{
		if (strcmp(Quad[i].operator, "DC") != 0)
		{
			printf("%3d %10s %10s %10s %10s %6d\n", i, Quad[i].result, Quad[i].operator, Quad[i].arg1, Quad[i].arg2, Quad[i].isLoop);
		}
	}
	printf("------------------------------------------------------------------------\n");
}

int lnum = 1;
char l[] = "L";
char temp[] = "t";

void while1()
{
	char x[10];
	sprintf(x, "L%d", lnum);
	addQuadruple("label", "NULL", "NULL", x, isLoop);
	fprintf(fp, "%s : \n", x);
	Index++;
	lnum++;
	push(x);
}

void while2()
{
	char x[10];
	sprintf(x, "L%d", lnum);
	strcpy(arg1, pop());
	addQuadruple("iffalse", arg1, "goto", x, isLoop);
	fprintf(fp, "iffalse %s goto %s \n", arg1, x);
	push(x);
	push("while3");
	lnum++;
}

void while3()
{
	strcpy(arg1, pop());
	strcpy(result, pop());
	addQuadruple("goto", "NULL", "NULL", result, isLoop);
	addQuadruple("label", "NULL", "NULL", arg1, isLoop);
	fprintf(fp, "goto %s\n", result);
	fprintf(fp, "%s:\n", arg1);
}

void for1()
{
	sprintf(result, "L%d", lnum);
	addQuadruple("label", "NULL", "NULL", result, isLoop);
	fprintf(fp, "%s: \n", result);
	push(result);
	lnum++;
}

void for2()
{
	sprintf(result, "L%d", lnum);
	strcpy(arg1, pop());
	sprintf(arg2, "L%d", lnum + 2);
	addQuadruple("if", arg1, "goto", result, isLoop);
	fprintf(fp, "if %s goto %s\n", arg1, result);
	addQuadruple("goto", "NULL", "NULL", arg2, isLoop);
	fprintf(fp, "goto %s \n", arg2);
	lnum++;
	sprintf(arg1, "L%d", lnum);
	lnum++;
	addQuadruple("label", "NULL", "NULL", arg1, isLoop);
	fprintf(fp, "%s: \n", arg1);
	char x[10];
	strcpy(x, pop());
	push(arg1);
	push(arg2);
	push(x);
	push(result);
}

void for3()
{
	strcpy(result, pop());
	//strcpy(arg1, pop());
	strcpy(arg2, pop());
	addQuadruple("goto", "NULL", "NULL", arg2, isLoop);
	fprintf(fp, "goto %s\n", arg2);
	addQuadruple("label", "NULL", "NULL", result, isLoop);
	fprintf(fp, "%s: \n", result);
	lnum++;
	//push(arg1);
	push("for4");
}

void for4()
{
	strcpy(arg1, pop());
	strcpy(arg2, pop());
	addQuadruple("goto", "NULL", "NULL", arg2, isLoop);
	fprintf(fp, "goto %s \n", arg2);
	addQuadruple("label", "NULL", "NULL", arg1, isLoop);
	fprintf(fp, "%s: \n", arg1);
	lnum++;
}

void emptyStack()
{
	if (Stack.top == 0)
		return;

	char x[10];
	strcpy(x, pop());
	if (strcmp(x, "for4") == 0)
	{
		for4();
	}
	else if (strcmp(x, "while3") == 0)
	{
		while3();
	}
	else
	{
		push(x);
	}
}

int isBinaryOperator(char *op)
{
	switch (op[0])
	{
		case '=':
		case '+':
		case '-':
		case '*':
		case '/':
		case '<':
		case '>':
		return 1;
		default:
		return 0;
	}
}

int deadCodeElimination()
{
	int deadCode = 1, deadLine, optimized = 0;
	while (deadCode)
	{
		deadCode = 0;
		for (int i = 0; i < Index; i++)
		{
			if ((isBinaryOperator(Quad[i].operator)) && (!Quad[i].isLoop))
			{
				deadLine = 1;
				for (int j = i + 1; j < Index; j++)
				{
					if (strcmp("DC", Quad[j].operator) != 0)
					{
						if ((strcmp(Quad[i].result, Quad[j].arg1) == 0) || (strcmp(Quad[i].result, Quad[j].arg2) == 0))
						{
							deadLine = 0;
							break;
						}
						if (!strcmp(Quad[i].result, Quad[j].result))
						{
							break;
						}
					}
				}
				if (deadLine)
				{
					strcpy(Quad[i].operator, "DC");
					deadCode = 1;
					optimized = 1;
				}
			}
		}
	}
	return optimized;
}

// '2a' returns 1, while 'a2' returns 0
int isNumber(char *str)
{
	int num = atoi(str);

	if (num == 0 && str[0] != 0)
		return 0;
	else
		return 1;
}

int performOperation(char *op, int num1, int num2)
{
	switch (op[0])
	{
		case '+':
		return num1 + num2;
		case '-':
		return num1 - num2;
		case '*':
		return num1 * num2;
		case '/':
		return num1 / num2;
		default:
		return 0;
	}
}

int constantFolding()
{
	int optimized = 0;
	for (int i = 0; i < Index; i++)
	{
		if ((isBinaryOperator(Quad[i].operator)) && (Quad[i].arg1 != NULL) && (Quad[i].arg2 != NULL))
		{
			if (isNumber(Quad[i].arg1) && isNumber(Quad[i].arg2))
			{
				int num1 = atoi(Quad[i].arg1), num2 = atoi(Quad[i].arg2);
				int ans = performOperation(Quad[i].operator, num1, num2);
				strcpy(Quad[i].arg2, "NULL");
				sprintf(Quad[i].arg1, "%d", ans);
				strcpy(Quad[i].operator, "=");
				constantPropagation(ans, i);
				if (Quad[i].result[0] == 't')
				{
					strcpy(Quad[i].operator, "DC");
				}
				optimized = 1;
			}
		}
	}
	return optimized;
}

int constantPropagation(int res, int index)
{
	char *op = strdup(Quad[index].result);
	int propagated = 0;
	for (int i = index + 1; i < Index; i++)
	{
		if (!Quad[i].isLoop && strcmp("DC", Quad[i].operator))
		{
			if (!strcmp(op, Quad[i].arg1))
			{
				sprintf(Quad[i].arg1, "%d", res);
				propagated = 1;
			}
			if (!strcmp(op, Quad[i].arg2))
			{
				sprintf(Quad[i].arg2, "%d", res);
				propagated = 1;
			}
		}
	}
	return propagated;
}

int propagate()
{
	int optimized = 0, propagated = 0;
	;
	for (int i = Index; i >= 0; i--)
	{
		if (!Quad[i].isLoop && !strcmp("=", Quad[i].operator) && isNumber(Quad[i].arg1) && !strcmp("NULL", Quad[i].arg2))
		{
			// printf("propagate(): %s = %d\n", Quad[i].result, atoi(Quad[i].arg1));
			propagated = constantPropagation(atoi(Quad[i].arg1), i);
			optimized |= propagated;
		}
	}
	return optimized;
}

void optimize()
{
	int optimize = 1;
	while (optimize)
	{
		optimize = 0;
		optimize = constantFolding();
		// printf("constanFolding(): %d\n", a);
		optimize |= propagate();
		// printf("propagate(): %d\n", b);
		optimize |= deadCodeElimination();
		// printf("deadCode(): %d\n", c);
	}
}

void printICG(FILE *fp)
{
	int i = 0;
	while (i < Index)
	{
		if (strcmp(Quad[i].operator, "DC") && (strcmp(Quad[i].operator, "")))
		{
			if (!strcmp(Quad[i].operator, "="))
			{
				fprintf(fp, "%s = %s\n", Quad[i].result, Quad[i].arg1);
			}
			else if (!strcmp(Quad[i].operator, "if"))
			{
				fprintf(fp, "if %s goto %s\n", Quad[i].arg1, Quad[i].result);
			}
			else if (!strcmp(Quad[i].operator, "iffalse"))
			{
				fprintf(fp, "iffalse %s goto %s\n", Quad[i].arg1, Quad[i].result);
			}
			else if (!strcmp(Quad[i].operator, "label"))
			{
				fprintf(fp, "%s: \n", Quad[i].result);
			}
			else if (!strcmp(Quad[i].operator, "goto"))
			{
				fprintf(fp, "goto %s\n", Quad[i].result);
			}
			else if (!strcmp(Quad[i].operator, "-"))
			{
				if (!strcmp(Quad[i].arg2, "-"))
				{
					fprintf(fp, "%s = %s %s\n", Quad[i].result, Quad[i].operator, Quad[i].arg1);
				}
				else
				{
					fprintf(fp, "%s = %s %s %s\n", Quad[i].result, Quad[i].arg1, Quad[i].operator, Quad[i].arg2);
				}
			}
			else if (isBinaryOperator(Quad[i].operator) == 1)
			{
				fprintf(fp, "%s = %s %s %s\n", Quad[i].result, Quad[i].arg1, Quad[i].operator, Quad[i].arg2);
			}
			else
			{
				fprintf(fp, "Something went wrong check pls\n");
			}
		}
		i = i + 1;
	}
	fprintf(fp, "\n\n");
}