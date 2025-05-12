#ifndef IR_H
#define IR_H

#include <string>
#include <map>
#include <stdio.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Value.h>
#include <llvm/Support/raw_ostream.h>
#include <vector>
#include <stack>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>

using namespace llvm;

// Parse context to hold state during parsing
struct ParseContext {
    BasicBlock* currentBlock;
    std::stack<std::pair<BasicBlock*, BasicBlock*>> ifContextStack;  // then, merge
    std::stack<std::pair<BasicBlock*, BasicBlock*>> elseContextStack; // else, merge
};

static ParseContext parseContext;

// Basic LLVM operations
Value* getFromSymbolTable(const char *id);
void setDouble(const char *id, Value* value);
void printString(const char *str);
void printDouble(Value* value);
Value* performBinaryOperation(Value* lhs, Value* rhs, int op);
void yyerror(const char *err);
static void initLLVM();
void printLLVMIR();
void addReturnInstr();
Value* createDoubleConstant(double val);

// Function for creating control structures
BasicBlock* startIfStatement(Value* condition);
void startElseClause();
void endIfStatement();

// For function support
Function* createFunction(const char* name, const char* returnType, std::vector<const char*> paramTypes);
Value* callFunction(const char* name, std::vector<Value*> args);

static std::map<std::string, Value *> SymbolTable;

static LLVMContext context;
static Module *module = nullptr;
static IRBuilder<> builder(context);
static Function *mainFunction = nullptr;

// These will be defined in the .y file
extern std::map<std::string, Function*> functionTable;

/**
* init LLVM
* Create main function (similar to C-main) that returns a int but takes no parameters.
*/
static void initLLVM() {
	module = new Module("top", context);
	//returns an int and has fixed number of parameters. Do not take any parameters.
	FunctionType *mainTy = FunctionType::get(builder.getInt32Ty(), false);
	//the main function definition.
	mainFunction = Function::Create(mainTy, Function::ExternalLinkage, "main", module);
	//Create entry basic block of the main function.
	BasicBlock *entry = BasicBlock::Create(context, "entry", mainFunction);
	//Tell builder that instruction to be added in this basic block.
	builder.SetInsertPoint(entry);
	parseContext.currentBlock = entry;
}

void addReturnInstr() {
	builder.CreateRet(ConstantInt::get(context, APInt(32, 0)));
}


Value* createDoubleConstant(double val) {
	return ConstantFP::get(context, APFloat(val));
}

void printLLVMIR() {
	module->print(errs(), nullptr);
}

Value* getFromSymbolTable(const char *id) {
	std::string name(id);
	if(SymbolTable.find(name) != SymbolTable.end()) {
		return SymbolTable[name];
	} else {
		Value* defaultValue = builder.CreateAlloca(builder.getDoubleTy(), nullptr, name);
		SymbolTable[name] = defaultValue;
		return defaultValue;
	}
}


void setDouble(const char *id, Value* value) {
	Value *ptr = getFromSymbolTable(id);
	builder.CreateStore(value, ptr);
}

/**
* This is a general LLVM function to print a value in given format.
*/
void printfLLVM(const char *format, Value *inputValue) {
	//check if printf function already exist
	Function *printfFunc = module->getFunction("printf");
	//if it does not exist then create it.
	if(!printfFunc) {
		//The printf function returns integer.
		//It takes variable number of paramters.
		FunctionType *printfTy = FunctionType::get(builder.getInt32Ty(), PointerType::get(builder.getInt8Ty(), 0), true);
		printfFunc = Function::Create(printfTy, Function::ExternalLinkage, "printf", module); // function is created.
	}
	//create global string pointer for format.
	Value *formatVal = builder.CreateGlobalStringPtr(format);
	//Call the printf function using Call LLVM instruction
	builder.CreateCall(printfFunc, {formatVal, inputValue}, "printfCall");
}

void printString(const char *str) {
	//printf("%s\n", str);
	Value *strValue = builder.CreateGlobalStringPtr(str);
	printfLLVM("%s\n", strValue);
}

void printDouble(Value *value) {
	//printf("%f\n", value);
	printfLLVM("%f\n", value); 
}

Value* performBinaryOperation(Value* lhs, Value* rhs, int op) {
	switch (op) {
		case '+': return builder.CreateFAdd(lhs, rhs, "fadd");
		case '-': return builder.CreateFSub(lhs, rhs, "fsub");
		case '*': return builder.CreateFMul(lhs, rhs, "fmul");
		case '/': return builder.CreateFDiv(lhs, rhs, "fdiv");
		default: yyerror("illegal binary operation"); exit(EXIT_FAILURE);
	}
}

// Begin an if statement
BasicBlock* startIfStatement(Value* condition) {
    Function *func = builder.GetInsertBlock()->getParent();
    
    // Create blocks for then, else, and merge
    BasicBlock *thenBB = BasicBlock::Create(context, "then", func);
    BasicBlock *mergeBB = BasicBlock::Create(context, "ifcont");
    
    // Convert condition to boolean if it's not already
    if (condition->getType() != builder.getInt1Ty()) {
        condition = builder.CreateFCmpONE(
            condition, 
            ConstantFP::get(context, APFloat(0.0)),
            "ifcond");
    }
    
    // Create branch instruction based on condition
    builder.CreateCondBr(condition, thenBB, mergeBB);
    
    // Save the current block so we can continue from here later
    parseContext.currentBlock = thenBB;
    
    // Push context for this if statement
    parseContext.ifContextStack.push(std::make_pair(thenBB, mergeBB));
    
    // Set insertion point to the then block
    builder.SetInsertPoint(thenBB);
    
    return thenBB;
}

// Begin an else clause
void startElseClause() {
    if (parseContext.ifContextStack.empty()) {
        yyerror("Else without matching if");
        exit(EXIT_FAILURE);
    }
    
    Function *func = builder.GetInsertBlock()->getParent();
    
    // Get the merge block from the if context
    BasicBlock *mergeBB = parseContext.ifContextStack.top().second;
    
    // Create 'else' block
    BasicBlock *elseBB = BasicBlock::Create(context, "else", func);
    
    // Add branch from then block to merge block
    builder.CreateBr(mergeBB);
    
    // Pop the if context
    parseContext.ifContextStack.pop();
    
    // Add else context
    parseContext.elseContextStack.push(std::make_pair(elseBB, mergeBB));
    
    // Set insertion point to else block
    builder.SetInsertPoint(elseBB);
    parseContext.currentBlock = elseBB;
}

// End an if statement
void endIfStatement() {
    Function *func = builder.GetInsertBlock()->getParent();
    
    if (!parseContext.ifContextStack.empty()) {
        // Simple if (no else)
        auto context = parseContext.ifContextStack.top();
        parseContext.ifContextStack.pop();
        
        // Get the merge block
        BasicBlock *mergeBB = context.second;
        
        // Add branch from current block to merge block
        builder.CreateBr(mergeBB);
        
        // Add merge block to function
        func->getBasicBlockList().push_back(mergeBB);
        
        // Set insertion point to merge block
        builder.SetInsertPoint(mergeBB);
        parseContext.currentBlock = mergeBB;
    } 
    else if (!parseContext.elseContextStack.empty()) {
        // If-else
        auto context = parseContext.elseContextStack.top();
        parseContext.elseContextStack.pop();
        
        // Get the merge block
        BasicBlock *mergeBB = context.second;
        
        // Add branch from current block to merge block
        builder.CreateBr(mergeBB);
        
        // Add merge block to function
        func->getBasicBlockList().push_back(mergeBB);
        
        // Set insertion point to merge block
        builder.SetInsertPoint(mergeBB);
        parseContext.currentBlock = mergeBB;
    }
    else {
        yyerror("Unmatched end of if statement");
        exit(EXIT_FAILURE);
    }
}

//! Debug function for params
void printParamTypes(const char* name, const std::vector<const char*>& paramTypes) {
    printf("Function: %s with %zu parameters:\n", name, paramTypes.size());
    for (size_t i = 0; i < paramTypes.size(); i++) {
        printf("  Param %zu: %s\n", i, paramTypes[i]);
    }
}

// Create a function with the given name, return type, and parameter types
Function* createFunction(const char* name, const char* returnType, std::vector<const char*> paramTypes) {
    // Debug output
    printParamTypes(name, paramTypes);
    
    // Determine the return type
    Type* retType;
    if (strcmp(returnType, "int") == 0) {
        retType = builder.getInt32Ty();
    } else if (strcmp(returnType, "double") == 0) {
        retType = builder.getDoubleTy();
    } else {
        retType = builder.getVoidTy();
    }
    
    // Create parameter types
    std::vector<Type*> paramTys;
    for (const char* paramType : paramTypes) {
        if (strcmp(paramType, "int") == 0) {
            paramTys.push_back(builder.getInt32Ty());
        } else if (strcmp(paramType, "double") == 0) {
            paramTys.push_back(builder.getDoubleTy());
        }
    }
    
    // Create function type
    FunctionType* funcType = FunctionType::get(retType, paramTys, false);
    
    // Check if function already exists
    Function* func = module->getFunction(name);
    
    if (!func) {
        // Create function if it doesn't exist
        func = Function::Create(funcType, Function::ExternalLinkage, name, module);
        
        // Set names for all arguments
        unsigned idx = 0;
        for (auto &arg : func->args()) {
            arg.setName("arg" + std::to_string(idx++));
        }
    } else {
        // If function exists, verify signature matches
        if (func->getFunctionType() != funcType) {
            std::string errorMsg = "Function redefinition with different signature: " + std::string(name);
            yyerror(errorMsg.c_str());
            exit(EXIT_FAILURE);
        }
        return func;
    }
    
    // Create a basic block for the function
    BasicBlock* entryBB = BasicBlock::Create(context, "entry", func);
    
    // Set the insert point to the new function's entry block
    builder.SetInsertPoint(entryBB);
    
    // Store function in the function table
    functionTable[name] = func;
    
    return func;
}

// Call a function with the given name and arguments
Value* callFunction(const char* name, std::vector<Value*> args) {
    // Find the function in the module
    Function* func = module->getFunction(name);
    if (!func) {
        std::string errorMsg = "Function '" + std::string(name) + "' not found";
        yyerror(errorMsg.c_str());
        exit(EXIT_FAILURE);
    }
    
    // Check if argument count matches
    if (func->arg_size() != args.size()) {
        std::string errorMsg = "Incorrect number of arguments for function '" + std::string(name) + 
            "'. Expected " + std::to_string(func->arg_size()) + ", got " + std::to_string(args.size());
        yyerror(errorMsg.c_str());
        exit(EXIT_FAILURE);
    }
    
    // Create call instruction
    return builder.CreateCall(func, args, "calltmp");
}

void yyerror(const char *err) {
	fprintf(stderr, "\n%s\n", err);
}

#endif // IR_H

