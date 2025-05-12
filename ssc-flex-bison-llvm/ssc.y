%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <vector>
	#include "IR.h"
	
	extern int yyparse();
	extern int yylex();
	extern FILE *yyin;
	
	// Uncomment to enable debug output
	//#define DEBUGBISON
	//This code is for producing debug output.
	#ifdef DEBUGBISON
		#define debugBison(a) (printf("\n%d \n",a))
	#else
		#define debugBison(a)
	#endif
	
	// Map to store function definitions
	std::map<std::string, Function*> functionTable;
	
	// For keeping track of function parameters
	std::vector<const char*> currentParamTypes;
	std::vector<Value*> currentCallArgs;
	
	// Global variables to handle control flow code generation
	static BasicBlock *thenBlock = nullptr;
	static BasicBlock *elseBlock = nullptr;
	static BasicBlock *mergeBlock = nullptr;
	static BasicBlock *condBlock = nullptr;
	static BasicBlock *loopBlock = nullptr;
	static BasicBlock *afterBlock = nullptr;
	static Value *incExpr = nullptr;
	static BasicBlock *incrementBlock = nullptr;
%}

%union {
	char *identifier;
	double double_literal;
	char *string_literal;
	llvm::Value* value;
	char *type_name;
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
%token LE GE EQ NE AND OR

%type <value> term expression conditional_expression
%type <type_name> type_specifier
%type <value> call_args call_arg function_call param_list param
%type <value> var_declaration assignment

%left '+' '-' 
%left '*' '/'
%left '<' '>' LE GE EQ NE
%left AND OR
%left '(' ')'
%nonassoc THEN
%nonassoc tok_else

%start program

%%

program: statements ;

statements: statement 
          | statements statement 
          ;

statement: prints ';'
         | printd ';'
         | assignment ';'
         | var_declaration ';'
         | if_statement
         | for_statement
         | while_statement
         | function_definition
         | function_call ';'
         | return_statement ';'
         | compound_statement
         ;

compound_statement: '{' statements '}'
                  | '{' '}'
                  ;

if_statement: 
    tok_if '(' conditional_expression ')' statement %prec THEN {
        // Create blocks for then and merge
        Function *func = builder.GetInsertBlock()->getParent();
        thenBlock = BasicBlock::Create(context, "then", func);
        mergeBlock = BasicBlock::Create(context, "ifcont", func);
        
        // Create conditional branch
        builder.CreateCondBr($3, thenBlock, mergeBlock);
        
        // Set insertion point to then block
        builder.SetInsertPoint(thenBlock);
        
        // Create branch from then to merge
        builder.CreateBr(mergeBlock);
        
        // Set insertion point to merge block
        builder.SetInsertPoint(mergeBlock);
    }
    | tok_if '(' conditional_expression ')' statement tok_else statement {
        // Create blocks for then, else and merge
        Function *func = builder.GetInsertBlock()->getParent();
        thenBlock = BasicBlock::Create(context, "then", func);
        elseBlock = BasicBlock::Create(context, "else", func);
        mergeBlock = BasicBlock::Create(context, "ifcont", func);
        
        // Create conditional branch
        builder.CreateCondBr($3, thenBlock, elseBlock);
        
        // Set insertion point to then block
        builder.SetInsertPoint(thenBlock);
        
        // Create branch from then to merge
        builder.CreateBr(mergeBlock);
        
        // Set insertion point to else block
        builder.SetInsertPoint(elseBlock);
        
        // Create branch from else to merge
        builder.CreateBr(mergeBlock);
        
        // Set insertion point to merge block
        builder.SetInsertPoint(mergeBlock);
    }
    ;

for_statement:
    tok_for '(' assignment ';' conditional_expression ';' assignment ')' {
        Function *func = builder.GetInsertBlock()->getParent();
        
        // Create the condition, body, increment, and exit blocks
        BasicBlock *condBB = BasicBlock::Create(context, "for.cond", func);
        BasicBlock *bodyBB = BasicBlock::Create(context, "for.body", func);
        BasicBlock *incBB = BasicBlock::Create(context, "for.inc", func);
        BasicBlock *exitBB = BasicBlock::Create(context, "for.exit", func);
        
        // Jump from the current block to the condition block
        builder.CreateBr(condBB);
        
        // Position at the end of condition block
        builder.SetInsertPoint(condBB);
        
        // Evaluate the condition
        Value *condValue = $5;
        builder.CreateCondBr(condValue, bodyBB, exitBB);
        
        // Position at the end of the body block
        builder.SetInsertPoint(bodyBB);
        
        // Save blocks for later use
        condBlock = condBB;
        loopBlock = bodyBB;
        afterBlock = exitBB;
        
        // Save increment expression and increment block for later
        incExpr = $7;
        incrementBlock = incBB;
    } statement {
        // Branch to increment block
        builder.CreateBr(incrementBlock);
        
        // Generate the increment code
        builder.SetInsertPoint(incrementBlock);
        incExpr; // Execute the increment expression
        
        // Create branch back to condition block
        builder.CreateBr(condBlock);
        
        // Position at the end of the exit block
        builder.SetInsertPoint(afterBlock);
    }
    | tok_for '(' var_declaration ';' conditional_expression ';' assignment ')' {
        Function *func = builder.GetInsertBlock()->getParent();
        
        // Create the condition, body, increment, and exit blocks
        BasicBlock *condBB = BasicBlock::Create(context, "for.cond", func);
        BasicBlock *bodyBB = BasicBlock::Create(context, "for.body", func);
        BasicBlock *incBB = BasicBlock::Create(context, "for.inc", func);
        BasicBlock *exitBB = BasicBlock::Create(context, "for.exit", func);
        
        // Jump from the current block to the condition block
        builder.CreateBr(condBB);
        
        // Position at the end of condition block
        builder.SetInsertPoint(condBB);
        
        // Evaluate the condition
        Value *condValue = $5;
        builder.CreateCondBr(condValue, bodyBB, exitBB);
        
        // Position at the end of the body block
        builder.SetInsertPoint(bodyBB);
        
        // Save blocks for later use
        condBlock = condBB;
        loopBlock = bodyBB;
        afterBlock = exitBB;
        
        // Save increment expression and increment block for later
        incExpr = $7;
        incrementBlock = incBB;
    } statement {
        // Branch to increment block
        builder.CreateBr(incrementBlock);
        
        // Generate the increment code
        builder.SetInsertPoint(incrementBlock);
        incExpr; // Execute the increment expression
        
        // Create branch back to condition block
        builder.CreateBr(condBlock);
        
        // Position at the end of the exit block
        builder.SetInsertPoint(afterBlock);
    }
    ;

while_statement:
    tok_while '(' conditional_expression ')' {
        Function *func = builder.GetInsertBlock()->getParent();
        
        // Create the condition, body, and exit blocks
        BasicBlock *headerBB = BasicBlock::Create(context, "while.header", func);
        BasicBlock *bodyBB = BasicBlock::Create(context, "while.body", func);
        BasicBlock *exitBB = BasicBlock::Create(context, "while.exit", func);
        
        // Jump from the current block to the header
        builder.CreateBr(headerBB);
        
        // Position at the end of header block
        builder.SetInsertPoint(headerBB);
        
        // Evaluate the condition in the header block
        Value *condValue = $3;
        builder.CreateCondBr(condValue, bodyBB, exitBB);
        
        // Position at the end of the body block
        builder.SetInsertPoint(bodyBB);
        
        // Save blocks for later use
        condBlock = headerBB;
        loopBlock = bodyBB;
        afterBlock = exitBB;
    } statement {
        // Add unconditional branch back to the loop header
        builder.CreateBr(condBlock);
        
        // Position at the end of the after block
        builder.SetInsertPoint(afterBlock);
    }
    ;

function_definition:
    type_specifier tok_identifier {
        // Clear param types vector for this function
        currentParamTypes.clear();
        printf("Cleared param types\n");
    } '(' param_list ')' {
        printf("Creating function %s with %zu params\n", $2, currentParamTypes.size());
        
        // Create function
        Function *func = createFunction($2, $1, currentParamTypes);
        
        // Store parameters in symbol table
        unsigned idx = 0;
        for (auto &arg : func->args()) {
            // Make sure parameter names are correctly stored
            std::string paramName = "param" + std::to_string(idx++);
            arg.setName(paramName);
            
            // Create a new alloca for this variable
            AllocaInst *alloca = builder.CreateAlloca(arg.getType(), nullptr, paramName);
            
            // Store the initial value into the alloca
            builder.CreateStore(&arg, alloca);
            
            // Add to symbol table
            SymbolTable[paramName] = alloca;
        }
        
        // Save insertion point of main
        BasicBlock *savedBlock = builder.GetInsertBlock();
        
        free($1);
        free($2);
    } compound_statement {
        // Add a return instruction if needed
        BasicBlock *currentBlock = builder.GetInsertBlock();
        if (!currentBlock->getTerminator()) {
            if (builder.getCurrentFunctionReturnType()->isVoidTy()) {
                builder.CreateRetVoid();
            } else if (builder.getCurrentFunctionReturnType()->isDoubleTy()) {
                builder.CreateRet(ConstantFP::get(context, APFloat(0.0)));
            } else {
                builder.CreateRet(ConstantInt::get(context, APInt(32, 0)));
            }
        }
        
        // Return to main function
        builder.SetInsertPoint(&module->getFunction("main")->getEntryBlock());
    }
    ;

param_list:
    /* empty */ { $$ = nullptr; }
    | param { $$ = $1; }
    | param_list ',' param { $$ = $1; }
    ;

param:
    type_specifier tok_identifier {
        // Add parameter type to vector - make a copy
        printf("Adding parameter type: %s and name: %s\n", $1, $2);
        currentParamTypes.push_back(strdup($1));
        $$ = nullptr;
        free($1);
        free($2);
    }
    ;

function_call:
    tok_identifier '(' call_args ')' {
        // Call the function with the arguments (these are collected in call_arg)
        $$ = callFunction($1, currentCallArgs);
        
        // Clear the arguments vector for next use
        currentCallArgs.clear();
        
        free($1);
    }
    ;

call_args:
    /* empty */ { $$ = nullptr; }
    | call_arg { $$ = $1; }
    | call_args ',' call_arg { $$ = $1; }
    ;

call_arg:
    expression {
        // Add argument to vector
        currentCallArgs.push_back($1);
        $$ = $1;
    }
    ;

return_statement:
    tok_return expression {
        // Create return instruction
        builder.CreateRet($2);
    }
    | tok_return {
        // Create void return
        builder.CreateRetVoid();
    }
    ;

var_declaration:
    type_specifier tok_identifier {
        // Declare variable without initialization
        Value* ptr = getFromSymbolTable($2);
        setDouble($2, createDoubleConstant(0.0));
        $$ = ptr;
        free($1);
        free($2);
    }
    | type_specifier tok_identifier '=' expression {
        // Declare variable with initialization
        setDouble($2, $4);
        $$ = $4;
        free($1);
        free($2);
    }
    ;

type_specifier:
    tok_int { $$ = strdup("int"); }
    | tok_double { $$ = strdup("double"); }
    | tok_void { $$ = strdup("void"); }
    ;

prints: tok_prints '(' tok_string_literal ')' { printString($3); free($3); } ;

printd: tok_printd '(' term ')' { printDouble($3); } ;

term: tok_identifier { 
        Value* ptr = getFromSymbolTable($1); 
        $$ = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_identifier"); 
        free($1); 
    }
    | tok_double_literal { $$ = createDoubleConstant($1); }
    | function_call { $$ = $1; }
    ;

assignment: tok_identifier '=' expression { 
        setDouble($1, $3); 
        $$ = $3;
        free($1); 
    }
    ;

expression: term { $$ = $1; }
          | expression '+' expression { $$ = performBinaryOperation($1, $3, '+'); }
          | expression '-' expression { $$ = performBinaryOperation($1, $3, '-'); }
          | expression '/' expression { $$ = performBinaryOperation($1, $3, '/'); }
          | expression '*' expression { $$ = performBinaryOperation($1, $3, '*'); }
          | '(' expression ')' { $$ = $2; }
          ;

conditional_expression: expression { $$ = $1; }
                      | expression '<' expression { $$ = builder.CreateFCmpOLT($1, $3, "cmp_lt"); }
                      | expression '>' expression { $$ = builder.CreateFCmpOGT($1, $3, "cmp_gt"); }
                      | expression LE expression { $$ = builder.CreateFCmpOLE($1, $3, "cmp_le"); }
                      | expression GE expression { $$ = builder.CreateFCmpOGE($1, $3, "cmp_ge"); }
                      | expression EQ expression { $$ = builder.CreateFCmpOEQ($1, $3, "cmp_eq"); }
                      | expression NE expression { $$ = builder.CreateFCmpONE($1, $3, "cmp_ne"); }
                      | conditional_expression AND conditional_expression { $$ = builder.CreateAnd($1, $3, "logical_and"); }
                      | conditional_expression OR conditional_expression { $$ = builder.CreateOr($1, $3, "logical_or"); }
                      | '(' conditional_expression ')' { $$ = $2; }
                      ;

%%

int main(int argc, char** argv) {
	if (argc > 1) {
		FILE *fp = fopen(argv[1], "r");
		yyin = fp; //read from file when its name is provided.
	} 
	if (yyin == NULL) { 
		yyin = stdin; //otherwise read from terminal
	}
	
	//Function that initialize LLVM
	initLLVM();
	
	//yyparse will call internally yylex
	//It will get a token and insert it into AST
	int parserResult = yyparse();
		
	//print LLVM IR
	printLLVMIR();
	
	//Add a return at the end
	addReturnInstr();
	
	return EXIT_SUCCESS;
}

