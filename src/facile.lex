%option noyywrap

%{

#include <glib.h>
#include "facile.y.h"

%}

%%

%{
	/* Exercice 1: Instruction if */ 
%}
if	return TOK_IF;
then return TOK_THEN;
elseif return TOK_ELSEIF;
else return TOK_ELSE;
end return TOK_END;
endif return TOK_ENDIF;
or return TOK_BOOL_OR;
and return TOK_BOOL_AND;
not return TOK_BOOL_NOT;
false return TOK_BOOL_FALSE;
true return TOK_BOOL_TRUE;
"=" return TOK_BOOL_EQ;
"#" return TOK_BOOL_NEQ;
">=" return TOK_BOOL_GTE;
">" return TOK_BOOL_GT;
"<=" return TOK_BOOL_LTE;
"<" return TOK_BOOL_LT; 

0|[1-9][0-9]* {
	sscanf(yytext, "%lu", &yylval.number);
	return TOK_NUMBER;
}

print	return TOK_PRINT;

read	return TOK_READ;

[a-zA-Z_][a-zA-Z0-9_]* {
	yylval.string = yytext;
	return TOK_IDENT;
}

":="	return TOK_AFFECT;

";"	return TOK_SEMICOLON;

"-"	return TOK_SUB;

"+"	return TOK_ADD;

"*"	return TOK_MUL;

"/"	return TOK_DIV;

"("	return TOK_OPEN_PARENTHESIS;

")"	return TOK_CLOSE_PARENTHESIS;

[ \t\n]	;

. return yytext[0];

%%

