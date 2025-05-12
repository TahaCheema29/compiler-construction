# Compiler Using Flex, Bison, LLVM, and MLIR

This project is created and executed on **Ubuntu 22.04.4 LTS**. It uses **Flex 2.6.4**, **GNU Bison 3.8.2**, **LLVM**, and **MLIR**. The project should work on other operating systems and software versions, but no guarantees are provided.

The videos explaining every aspect of this project are available on [YouTube](https://youtube.com/playlist?list=PLxP0p--aBHmL5uj9eecRFLIm1Qx2T8_sx&si=LvvqhGXqyp8faGQG).

---

## Project Organization

The project is organized into the following folders:

1. **`ssc-flex-bison`**:
   - Contains code for the **Simple Simple C (SSC)** compiler using **Flex** and **Bison**.
   - This version does **not** generate LLVM intermediate code.
   - Focuses on lexical analysis, parsing, and semantic analysis.

2. **`ssc-flex-bison-llvm`**:
   - Extends the SSC compiler to generate **LLVM Intermediate Representation (IR)**.
   - Uses **LLVM** for code generation and optimization.
   - Includes support for **MLIR** (Multi-Level Intermediate Representation) for advanced optimizations and transformations.

---

## SSC Language Features

The Simple Simple C (SSC) language implementation includes the following features:

1. **Basic Data Types**:
   - Integer and Double data types
   - Variable declarations and assignments

2. **Arithmetic Operations**:
   - Addition, subtraction, multiplication, division

3. **Control Flow Structures**:
   - **If Statements**: Conditional execution with single branch
   - **If-Else Statements**: Conditional execution with two branches
   - **While Loops**: Condition-based iteration
   - **For Loops**: Iteration with initialization, condition, and increment steps

4. **Functions**:
   - Function declarations with parameters
   - Function calls with arguments
   - Return statements
   - Support for recursive function calls

5. **Input/Output**:
   - Print statements for displaying values
   - String literals for messages

All these features are implemented with LLVM IR generation in the `ssc-flex-bison-llvm` version, allowing for efficient code execution.

---

## Requirements

- **Ubuntu 22.04.4 LTS** or a similar Linux distribution.
- **Flex 2.6.4**.
- **GNU Bison 3.8.2**.
- **Clang++** (for compiling the compiler).
- **LLVM** (for intermediate code generation and optimization).
- **MLIR** (optional, for advanced optimizations).

---

## Compilation and Execution

### Navigating to the Directory

Before running any commands, make sure to navigate to the appropriate directory where the `Makefile` is located. For example:

```bash
cd ssc-flex-bison
```

or

```bash
cd ssc-flex-bison-llvm
```

---

### Compiling the Compiler

To compile the SSC compiler, use the following command:

```bash
make
```

This will generate the executable for the SSC compiler using Flex, Bison, and (if applicable) LLVM.

---

### Running the Compiler

To run the compiler with a sample input file (`input.ssc`), use:

```bash
make run
```

This command will compile the SSC code and output the results.

---

### Testing Specific Language Features

You can create test files to verify different language features:

1. **Testing Control Structures**:
   ```bash
   ./ssc test_control.ssc
   ```

2. **Testing Functions**:
   ```bash
   ./ssc test_functions.ssc
   ```

3. **Testing Loops**:
   ```bash
   ./ssc test_loops.ssc
   ```

These commands will generate LLVM IR for the respective test files.

---

### Optimizing with LLVM (ssc-flex-bison-llvm only)

To generate and run the compiler with **optimized LLVM IR**, use:

```bash
make run_opt
```

This will:
1. Generate LLVM IR (`output.ll`).
2. Optimize the IR using `opt` (`output_opt.ll`).
3. Compile the optimized IR into an executable and run it.

---

### Cleaning Up

To remove compiled and intermediate files, run:

```bash
make clean
```

To remove all generated files, including the output executable, run:

```bash
make distclean
```

---

### Help

To see the available `Makefile` commands, run:

```bash
make help
```

---

## Files in the Project

### **ssc-flex-bison Folder**

- **`ssc.l`**: The Flex file for the lexical analyzer.
- **`ssc.y`**: The Bison file for the syntax and semantic analyzer.
- **`IR.h`**: The header file containing all the C/C++ code.
- **`input.ssc`**: A sample input file containing Simple Simple C code to test the compiler.

---

### **ssc-flex-bison-llvm Folder**

- **`ssc.l`**: The Flex file for the lexical analyzer.
- **`ssc.y`**: The Bison file for the syntax and semantic analyzer.
- **`IR.h`**: The header file containing all the C/C++ code, including LLVM IR generation.
- **`test.ssc`**: A test file containing SSC code to verify language features.
- **`output.ll`**: The generated LLVM IR file.
- **`output_opt.ll`**: The optimized LLVM IR file (generated using `opt`).

---

## Key Features

### **ssc-flex-bison**
- Lexical analysis using **Flex**.
- Syntax and semantic analysis using **Bison**.
- Simple code generation without LLVM.

### **ssc-flex-bison-llvm**
- Lexical analysis using **Flex**.
- Syntax and semantic analysis using **Bison**.
- **LLVM IR generation**: The compiler generates LLVM Intermediate Representation (IR) for the input code.
- **Control flow structures**: Support for if-statements, if-else statements, while loops, and for loops.
- **Function handling**: Support for function declarations, parameters, and function calls.
- **Optimization**: The LLVM IR can be optimized using the `opt` tool.
- **MLIR integration**: Advanced optimizations and transformations using MLIR (optional).

---

## Example Workflow

### For `ssc-flex-bison`:
1. Navigate to the folder:
   ```bash
   cd ssc-flex-bison
   ```
2. Compile the compiler:
   ```bash
   make
   ```
3. Run the compiler:
   ```bash
   make run
   ```

### For `ssc-flex-bison-llvm`:
1. Navigate to the folder:
   ```bash
   cd ssc-flex-bison-llvm
   ```
2. Compile the compiler:
   ```bash
   make
   ```
3. Run the compiler with unoptimized IR:
   ```bash
   make run
   ```
4. Run the compiler with optimized IR:
   ```bash
   make run_opt
   ```

---

## Notes

- Ensure that you are in the correct directory (`ssc-flex-bison` or `ssc-flex-bison-llvm`) before running any commands. Each folder has its own `Makefile` and files necessary for compilation and execution.
- The `ssc-flex-bison-llvm` folder requires LLVM and MLIR to be installed on your system.

---

## Troubleshooting

- If you encounter issues with LLVM IR generation or optimization, ensure that LLVM is installed correctly and that the `opt` tool is available in your system's PATH.
- For MLIR-related issues, ensure that MLIR is properly configured and linked with your project.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```
MIT License

Copyright (c) 2024 faisal-aslam

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
