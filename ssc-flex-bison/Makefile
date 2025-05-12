# Makefile for SSC compiler using Flex and Bison

# Compiler and tools
CC = gcc
CFLAGS = -Wall -g
BISON = bison
FLEX = flex

# Files
LEXER = ssc.l
PARSER = ssc.y
IR_SRC = IR.c
EXECUTABLE = ssc
TEST_FILE = test.ssc

# Intermediate files
LEX_C = lex.yy.c
PARSER_C = ssc.tab.c
PARSER_H = ssc.tab.h
IR_OBJ = IR.o

# Bison and Flex flags
BISON_FLAGS = -d
FLEX_FLAGS =

# Default target
all: $(EXECUTABLE)

# Generate parser
$(PARSER_C) $(PARSER_H): $(PARSER)
	$(BISON) $(BISON_FLAGS) $(PARSER)

# Generate lexer
$(LEX_C): $(LEXER) $(PARSER_H)
	$(FLEX) $(FLEX_FLAGS) $(LEXER)

# Compile IR
$(IR_OBJ): $(IR_SRC) IR.h
	$(CC) $(CFLAGS) -c $(IR_SRC) -o $(IR_OBJ)

# Compile the compiler
$(EXECUTABLE): $(LEX_C) $(PARSER_C) $(IR_OBJ)
	$(CC) $(CFLAGS) -o $(EXECUTABLE) $(PARSER_C) $(LEX_C) $(IR_OBJ) -lfl

# Run tests
test: $(EXECUTABLE)
	./$(EXECUTABLE) $(TEST_FILE)

# Clean up
clean:
	rm -f $(LEX_C) $(PARSER_C) $(PARSER_H) $(EXECUTABLE) $(IR_OBJ)

# Help
help:
	@echo "Available targets:"
	@echo "  make        - Compile the SSC compiler"
	@echo "  make test   - Run the SSC compiler with the test file"
	@echo "  make clean  - Remove compiled and intermediate files"
	@echo "  make help   - Display this help message"

.PHONY: all test clean help

