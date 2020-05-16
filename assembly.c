#include "header.h"

int Ru = 0;
int Lu = 0;


char* isArithmeticOperator(char *op)
{
	switch (op[0])
	{
		case '+': return "ADD";
		case '-': return "SUB";
		case '*': return "MUL";		
		default:
		return "";
	}
}


int isRelationalOperator(char* op)
{
	if(op[0] == '<' || op[0] == '>')
		return 1;
	if(!strcmp(op,"==")||!strcmp(op,"!="))
		return 1;
	return 0;
}

int load_R_res(char* var)
{
	if(Ru<14)
	{
		strcpy(reg[Ru].var,var);
		return Ru++;
	}
	fprintf(acf, "\tSTR\t%s\tR%d\n",reg[Lu].var,Lu);
	strcpy(reg[Lu].var,var);
	//fprintf(acf, "LDR\tR%d\t%s\n",Lu,var);
	int ret = Lu;
	Lu = (Lu+1)%14;
	return ret;
}

int search(char* var)
{
	if(!strcmp(var,"NULL"))
		return -1;
	if(isNumber(var))
	{
		int i = 0;
		while(i<Ru)
		{
			if(!strcmp(var,reg[i].var))
				return i;
			++i;
		}
		if(Ru<14)
		{
			strcpy(reg[Ru].var,var);
			fprintf(acf, "\tMOV\tR%d\t#%s\n",Ru,var);
			return Ru++; 
		}
		fprintf(acf, "\tSTR\t%s\tR%d\n",reg[Lu].var,Lu);
		strcpy(reg[Lu].var,var);
		fprintf(acf, "\tMOV\tR%d\t#%s\n",Lu,var);
		int ret = Lu;
		Lu = (Lu+1)%14;
		return ret;
	}
	int i = 0;
	while(i<Ru)
	{
		if(!strcmp(var,reg[i].var))
			return i;
		++i;
	}
	if(Ru<14)
	{
		strcpy(reg[Ru].var,var);
		fprintf(acf, "\tLDR\tR%d\t%s\n",Ru,var);
		return Ru++; 
	}
	fprintf(acf, "\tSTR\t%s\tR%d\n",reg[Lu].var,Lu);
	strcpy(reg[Lu].var,var);
	fprintf(acf, "\tLDR\tR%d\t%s\n",Lu,var);
	int ret = Lu;
	Lu = (Lu+1)%14;
	return ret;
}
void print_instr(char* cmd, int i)
{
	int r1,r2,r3;
	r2 = search(Quad[i].arg1);
	r1 = load_R_res(Quad[i].result);
	fprintf(acf, "%s\tR%d\t",cmd,r1);
	fprintf(acf, "R%d\t",r2);
	if(isNumber(Quad[i].arg2))
		fprintf(acf, "#%s\t",Quad[i].arg2);
	else
	{	
		r3 = search(Quad[i].arg2);
		if(r3 != -1)
			fprintf(acf, "R%d\t",r3);
	}
	fprintf(acf, "\n");
	//fprintf(acf, "STR\t%s\tR%d\n",Quad[i].result,r1);
	return;
}
void assembly_code()
{
	int i = 0;
	char cond[10];
	char txt[10];
	while (i < Index)
	{
		if (strcmp(Quad[i].operator, "DC") && (strcmp(Quad[i].operator, "")))
		{
			if (!strcmp(Quad[i].operator, "="))
			{
					fprintf(acf, "\t");
					if(isNumber(Quad[i].arg1))
					{
						int rx = load_R_res(Quad[i].result);
						fprintf(acf, "MOV\tR%d\t#%s\n",rx,Quad[i].arg1);
						fprintf(acf, "\tSTR\t%s\tR%d\n",Quad[i].result,rx);

					}
					else if(!strcmp(Quad[i].arg1,"0"))
					{
						fprintf(acf, "STR\t%s\t$0\n",Quad[i].result);

					}
				
					else 
					{
						int rx = search(Quad[i].arg1);
						fprintf(acf, "STR\t%s\tR%d\n",Quad[i].result,rx);
					}
			}
			else if(!strcmp(Quad[i].operator, "label"))
			{
				fprintf(acf, "\n%s:\n",Quad[i].result);
			}
			
			else if (!strcmp(Quad[i].operator, "if"))
			{
				switch(cond[0])
				{
					case '<' : if(cond[1]=='\0') strcpy(txt,"LT"); else strcpy(txt,"LE");break;
					case '>' : if(cond[1]=='\0') strcpy(txt,"GT"); else strcpy(txt,"GE");break;
					case '!' : strcpy(txt,"NE");break;
					case '=' : strcpy(txt,"EQ");break;
				}
				fprintf(acf, "\t");
				fprintf(acf, "B%s\t%s\n",txt,Quad[i].result);
			}
			else if (!strcmp(Quad[i].operator, "goto"))
			{
				fprintf(acf, "\t");
				fprintf(acf, "B\t%s\n", Quad[i].result);
			}
			
			else if (!strcmp(Quad[i].operator, "iffalse"))
			{
				fprintf(acf, "\t");
				switch(cond[0])
				{
					case '<' : if(cond[1]=='\0') strcpy(txt,"GE"); else strcpy(txt,"GT");break;
					case '>' : if(cond[1]=='\0') strcpy(txt,"LE"); else strcpy(txt,"LT");break;
					case '!' : strcpy(txt,"EQ");break;
					case '=' : strcpy(txt,"NE");break;
				}
				fprintf(acf, "B%s\t%s\n",txt,Quad[i].result);
			}
			else if (isArithmeticOperator(Quad[i].operator)[0] != '\0')
			{
				fprintf(acf, "\t");
				print_instr(isArithmeticOperator(Quad[i].operator),i);
			}
			else if(isRelationalOperator(Quad[i].operator))
			{
				int rx = search(Quad[i].arg1);
				fprintf(acf, "\t");
				fprintf(acf, "CMP\t");
				fprintf(acf, "R%d\t",rx);
				if(isNumber(Quad[i].arg2))
				{
					fprintf(acf, "#%s\n",Quad[i].arg2);
				}
				else
				{
					rx = search(Quad[i].arg1);
					fprintf(acf, "R%d\t",rx);
				}
				strcpy(cond,Quad[i].operator);
			}
			else
			{
				
			}
		}
		i = i + 1;
	}
}

