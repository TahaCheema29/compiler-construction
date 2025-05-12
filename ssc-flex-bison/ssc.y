%{
	#include <stdio.h>
	#include <stdlib.h>
	//contains our functions to be reused later by llvm.
	#include "IR.h"
	
	extern int yyparse();
	extern int yylex();
	extern FILE *yyin;
	void yyerror(const char *err);

	
	//#define DEBUGBISON
	//This code is for producing debug output.
	#ifdef DEBUGBISON
		#define debugBison(a) (printf("\n%d \n",a))
	#else
		#define debugBison(a)
	#endif

	void cleanupString(char* str) {
		if (str != NULL) {
			free(str);
		}
	}
%}

%union {
	char *identifier;
	double double_literal;
	char *string_literal;
}

%token tok_printd
%token tok_prints
%token tok_if
%token tok_else
%token tok_for
%token tok_while
%token tok_return
%token tok_int
%token tok_double
%token tok_void
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <double_literal> term expression condition
%type <identifier> type_specifier
%type <string_literal> prints
%type <double_literal> printd
%type <identifier> assignment_var
%type <double_literal> assignment_expr
%type <double_literal> function_call
%type <double_literal> argument_list
%type <double_literal> argument

%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-' 
%left '*' '/'
%left '(' ')'
%nonassoc IFX
%nonassoc tok_else

%token LE GE EQ NE AND OR

%start root

%%

root:	/* empty */				{debugBison(1);}  	
	| function_decl root			{debugBison(2);}
	| statement root				{debugBison(3);}
	; 

function_decl: type_specifier tok_identifier '(' param_list ')' block
	{
		debugBison(4);
		// Register function for demo purposes
		registerFunction($2, 0.0);
		cleanupString($2);
	}
	;

param_list: /* empty */
	| param
	| param_list ',' param
	;

param: type_specifier tok_identifier
	{
		cleanupString($2);
	}
	;

block: '{' statement_list '}'
	;

statement_list: /* empty */
	| statement statement_list
	;

statement: prints ';'			{debugBison(5); printString("%s\n", $1); cleanupString($1); }
	| printd ';'				{debugBison(6); printDouble("%lf\n", $1); }
	| assignment_var '=' assignment_expr ';'	{debugBison(7); setValueInSymbolTable($1, $3); cleanupString($1); }
	| declaration ';'
	| if_statement
	| for_statement
	| while_statement
	| return_statement ';'
	| function_call ';'			{debugBison(8); /* Function call as a statement */ }
	| block
	;

declaration: type_specifier assignment_var '=' assignment_expr
	{
		debugBison(9);
		setValueInSymbolTable($2, $4);
		cleanupString($2);
	}
	| type_specifier assignment_var
	{
		debugBison(10);
		setValueInSymbolTable($2, 0.0);
		cleanupString($2);
	}
	;

if_statement: tok_if '(' condition ')' statement %prec IFX
	{
		debugBison(11);
	}
	| tok_if '(' condition ')' statement tok_else statement
	{
		debugBison(12);
	}
	;

for_statement: tok_for '(' declaration ';' condition ';' assignment_var '=' assignment_expr ')' statement
	{
		debugBison(13);
		cleanupString($7);
	}
	| tok_for '(' assignment_var '=' assignment_expr ';' condition ';' assignment_var '=' assignment_expr ')' statement
	{
		debugBison(14);
		cleanupString($3);
		cleanupString($9);
	}
	;

while_statement: tok_while '(' condition ')' statement
	{
		debugBison(15);
	}
	;

return_statement: tok_return expression
	{
		debugBison(16);
	}
	;

condition: expression '<' expression	{debugBison(17); $$ = $1 < $3 ? 1.0 : 0.0; }
	| expression '>' expression		{debugBison(18); $$ = $1 > $3 ? 1.0 : 0.0; }
	| expression LE expression		{debugBison(19); $$ = $1 <= $3 ? 1.0 : 0.0; }
	| expression GE expression		{debugBison(20); $$ = $1 >= $3 ? 1.0 : 0.0; }
	| expression EQ expression		{debugBison(21); $$ = $1 == $3 ? 1.0 : 0.0; }
	| expression NE expression		{debugBison(22); $$ = $1 != $3 ? 1.0 : 0.0; }
	| condition AND condition		{debugBison(23); $$ = ($1 != 0.0 && $3 != 0.0) ? 1.0 : 0.0; }
	| condition OR condition		{debugBison(24); $$ = ($1 != 0.0 || $3 != 0.0) ? 1.0 : 0.0; }
	| '(' condition ')'			{debugBison(25); $$ = $2; }
	;

type_specifier: tok_int			{debugBison(26); $$ = "int"; }
	| tok_double				{debugBison(27); $$ = "double"; }
	| tok_void				{debugBison(28); $$ = "void"; }
	;

prints:	tok_prints '(' tok_string_literal ')'	{debugBison(29); $$ = $3; }
	;

printd:	tok_printd '(' term ')'		{debugBison(30); $$ = $3; }
	;

term:	tok_identifier			{debugBison(31); $$ = getValueFromSymbolTable($1); cleanupString($1); } 
	| tok_double_literal		{debugBison(32); $$ = $1; }
	| function_call			{debugBison(33); $$ = $1; }
	;

assignment_var: tok_identifier		{debugBison(34); $$ = $1; }
	;

assignment_expr: expression		{debugBison(35); $$ = $1; }
	;

function_call: tok_identifier '(' ')'		{debugBison(36); $$ = callFunction($1, 0.0, NULL, 0); cleanupString($1); }
	| tok_identifier '(' argument_list ')'	{debugBison(37); 
								// Currently, we only support single argument for simplicity
								// In a real implementation, you'd collect all arguments
								$$ = callFunction($1, $3, NULL, 0); 
								cleanupString($1); 
							}
	;

argument_list: argument			{debugBison(38); $$ = $1; }
	| argument_list ',' argument	{debugBison(39); /* For now, we only support simple function calls */ $$ = $1; }
	;

argument: expression			{debugBison(40); $$ = $1; }
	;

expression: term				{debugBison(41); $$ = $1;}
	| expression '+' expression		{debugBison(42); $$ = performBinaryOperation($1, $3, '+');}
	| expression '-' expression		{debugBison(43); $$ = performBinaryOperation($1, $3, '-');}
	| expression '/' expression		{debugBison(44); $$ = performBinaryOperation($1, $3, '/');}
	| expression '*' expression		{debugBison(45); $$ = performBinaryOperation($1, $3, '*');}
	| '(' expression ')'			{debugBison(46); $$ = $2;}
	;

%%

void yyerror(const char *err) {
	fprintf(stderr, "\n%s\n", err);
}

int main(int argc, char** argv) {
	if (argc > 1) {
		FILE *fp = fopen(argv[1], "r");
		yyin = fp; //read from file when its name is provided.
	} 
	if (yyin == NULL) { 
		yyin = stdin; //otherwise read from terminal
	}
	
	//yyparse will call internally yylex
	//It will get a token and insert it into AST
	int parserResult = yyparse();
	
	return EXIT_SUCCESS;
}

