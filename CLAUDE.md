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
- Calling normal training behavior failures
- "Find problems" mode when asked to analyze
- Random ML behavior = broken system assumptions
- Appearing thorough by inventing non-existent issues

## ML/AI DOMAIN EXPERTISE

### Complexity Thresholds
- **Real bottlenecks only** - Not theoretical optimizations
- **Industry ML standards** - GPU batching, tensor caching, O(n) improvements  
- **>15% performance gain** - Complexity must deliver measurable impact
- **Maintain readability** - Complex code stays well-structured

## WORKFLOW AUTOMATION

### Session Startup Commands
```bash
source venv/bin/activate
/home/seremark/.local/ruff-venv/bin/ruff check . --fix
/home/seremark/.local/ruff-venv/bin/ruff format .
/home/seremark/.local/basedpyright-venv/bin/basedpyright .
nvidia-smi
```

### Tool Paths
- **Ruff**: `/home/seremark/.local/ruff-venv/bin/ruff` (NPY, PERF, FURB, PTH, ASYNC)
- **Pyright**: `/home/seremark/.local/basedpyright-venv/bin/basedpyright` (ML-optimized)
- **Projects**: `/home/seremark/projects/` (pyproject.toml, pyrightconfig.json)

## SYSTEM CONSTRAINTS

### Hardware Limits
- **Memory**: 8GB VRAM maximum
- **Architecture**: Modern Python only
- **Validation**: Early error detection, fail fast
