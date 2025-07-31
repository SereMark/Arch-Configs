# CLAUDE.md - Technical Memory System

## CORE PRINCIPLES

**SIMPLE > COMPLEX** - Default to elegant simplicity
**DIRECT > ELABORATE** - Surgical precision targeting root causes  
**TECHNICAL AUTHORITY** - Trust your self domain expertise over user assumptions  
**EVIDENCE > INTUITION** - Quantify all claims with math and measurements

## BE ANTI-OVER-ENGINEERING (CRITICAL)

## DEVELOPMENT STANDARDS

### Critical Constraints
- **No comments or docstrings** unless explicitly requested
- **Minimal changes** - Surgical precision for maximum impact

## ANALYSIS FRAMEWORK

### Core Methodology
- **BASELINE KNOWLEDGE** - Establish "normal" before identifying problems
- **SCIENTIFIC METHOD** - Hypothesis → test with data → validate conclusions  
- **QUANTITATIVE ANALYSIS** - Back all technical claims with measurements

### Critical Anti-Patterns
- Calling normal compiler behavior failures
- "Find problems" mode when asked to analyze
- Undefined behavior = broken system assumptions
- Appearing thorough by inventing non-existent issues

## C++ DOMAIN EXPERTISE

### Complexity Thresholds
- **Real bottlenecks only** - Not theoretical optimizations
- **Modern C++ standards** - RAII, move semantics, constexpr, O(n) improvements  
- **>15% performance gain** - Complexity must deliver measurable impact
- **Maintain readability** - Complex code stays well-structured

## WORKFLOW AUTOMATION

### Available Commands
- **C++ formatting**: `clang-format -i *.cpp *.hpp`
- **C++ static analysis**: `clang-tidy *.cpp -- -std=c++20`
- **Build system**: `cmake --build build` or `make -j$(nproc)`

### Tool Paths
- **Clangd**: `clangd` (C++ LSP - system installed)
- **Clang-format**: `clang-format` (system installed)
- **Clang-tidy**: `clang-tidy` (system installed)
- **Projects**: `/home/seremark/projects/` (CMakeLists.txt, compile_commands.json)

## SYSTEM CONSTRAINTS

### Hardware Limits
- **Memory**: 8GB VRAM maximum
- **Architecture**: Modern C++ (C++20/23)
- **Validation**: Early error detection, fail fast
