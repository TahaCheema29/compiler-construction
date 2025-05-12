#ifndef IR_H
#define IR_H

#include <stdio.h>

// Perform binary operations
double performBinaryOperation(double lhs, double rhs, int op);

// Print a string
void printString(const char* format, const char* value);

// Print a double
void printDouble(const char* format, double value);

// Set value in symbol table
void setValueInSymbolTable(const char* id, double value);

// Get value from symbol table
double getValueFromSymbolTable(const char* id);

// Register a function
void registerFunction(const char* name, double returnValue);

// Call a function with multiple arguments
double callFunction(const char* name, double firstArg, double* args, int argCount);

#endif /* IR_H */
