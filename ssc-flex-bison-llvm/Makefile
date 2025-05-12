# Makefile for SSC compiler with LLVM support

# Compiler and tools
CXX = clang++
CXXFLAGS = -Wall -g -std=c++14 `llvm-config --cxxflags`
LDFLAGS = `llvm-config --ldflags --system-libs --libs core`
BISON = bison
FLEX = flex

# Files
LEXER = ssc.l
PARSER = ssc.y
EXECUTABLE = ssc
TEST_FILE = test.ssc

# Intermediate files
LEX_C = lex.yy.c
PARSER_C = ssc.tab.c
PARSER_H = ssc.tab.h

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

# Compile the compiler
$(EXECUTABLE): $(LEX_C) $(PARSER_C)
	$(CXX) $(CXXFLAGS) -o $(EXECUTABLE) $(PARSER_C) $(LEX_C) $(LDFLAGS)

# Run tests
test: $(EXECUTABLE)
	./$(EXECUTABLE) $(TEST_FILE)

# Clean up
clean:
	rm -f $(LEX_C) $(PARSER_C) $(PARSER_H) $(EXECUTABLE)

# Help
help:
	@echo "Available targets:"
	@echo "  make        - Compile the SSC compiler with LLVM support"
	@echo "  make test   - Run the SSC compiler with the test file"
	@echo "  make clean  - Remove compiled and intermediate files"
	@echo "  make help   - Display this help message"

.PHONY: all test clean help
