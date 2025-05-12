# Root Makefile for SSC compiler project

# Directories
FLEX_BISON_DIR = ssc-flex-bison
LLVM_DIR = ssc-flex-bison-llvm

# Default target
all: flex-bison llvm

# Flex-Bison part
flex-bison:
	@echo "Building Flex-Bison part..."
	@cd $(FLEX_BISON_DIR) && $(MAKE)

# LLVM part
llvm:
	@echo "Building LLVM part..."
	@cd $(LLVM_DIR) && $(MAKE)

# Clean all
clean:
	@echo "Cleaning all..."
	@cd $(FLEX_BISON_DIR) && $(MAKE) clean
	@cd $(LLVM_DIR) && $(MAKE) clean

# Test Flex-Bison part
test-flex-bison:
	@echo "Testing Flex-Bison part..."
	@cd $(FLEX_BISON_DIR) && $(MAKE) test

# Test LLVM part
test-llvm:
	@echo "Testing LLVM part..."
	@cd $(LLVM_DIR) && $(MAKE) test

# Help
help:
	@echo "Available targets:"
	@echo "  make            - Build both Flex-Bison and LLVM parts"
	@echo "  make flex-bison - Build Flex-Bison part"
	@echo "  make llvm       - Build LLVM part"
	@echo "  make clean      - Clean all build files"
	@echo "  make test-flex-bison - Test Flex-Bison part"
	@echo "  make test-llvm  - Test LLVM part"
	@echo "  make help       - Display this help message"

.PHONY: all flex-bison llvm clean test-flex-bison test-llvm help 