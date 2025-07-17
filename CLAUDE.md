# 🧠 CLAUDE.md - Critical System Memory

## 🚨 SYSTEM ESSENTIALS
- **Arch Linux** | RTX 2070 (8GB VRAM) | 15.54GB RAM
- **Tools**: `/home/seremark/.local/ruff-venv/bin/ruff` `/home/seremark/.local/basedpyright-venv/bin/basedpyright`
- **Always**: `source venv/bin/activate` first

## ⚡ CRITICAL COMMANDS
```bash
# Quality checks (uses project configs - matches nvim exactly)
/home/seremark/.local/ruff-venv/bin/ruff check . 
/home/seremark/.local/ruff-venv/bin/ruff format .
source venv/bin/activate && /home/seremark/.local/basedpyright-venv/bin/basedpyright .

# Quick validation (same as nvim diagnostics)
/home/seremark/.local/ruff-venv/bin/ruff check . --fix
source venv/bin/activate && /home/seremark/.local/basedpyright-venv/bin/basedpyright . --createstub

# GPU monitoring
nvidia-smi
```

## 🎯 CORE RULES (NEVER FORGET)
1. **SURGICAL PRECISION** → Minimal code changes only
2. **ROOT CAUSE ONLY** → Never mask symptoms
3. **VENV FIRST** → Always activate before work
4. **8GB VRAM LIMIT** → Monitor GPU memory constantly

## ❌ NEVER DO
- Break existing functionality
- Value Complexity over Simplicity

## 🔧 WORKFLOW: R→A→M→I→V→T
1. **Read** codebase → 2. **Activate** venv → 3. **Minimal** fix → 4. **Implement** → 5. **Validate** → 6. **Test**

## 🛡️ MEMORY LIMITS
- **System**: 15GB (keep 3GB buffer) | **GPU**: 8GB | **Batch**: Start small, scale up

## 🔍 EMERGENCY COMMANDS
```bash
# Find tools if lost
find /home/seremark -name "ruff" -type f 2>/dev/null
find /home/seremark -name "basedpyright" -type f 2>/dev/null

# GPU memory check
python -c "import torch; print(f'{torch.cuda.memory_allocated()/1e9:.1f}GB/{torch.cuda.get_device_properties(0).total_memory/1e9:.1f}GB')"

# Device check
python -c "import torch; print('cuda' if torch.cuda.is_available() else 'cpu')"
```

## 📝 ESSENTIALS
- **DO EXACTLY** what's asked - nothing more, nothing less
- **EDIT > CREATE** - Never create files unless necessary
- **NO DOCS** unless explicitly requested
- **NO TEMP FILES** - Clean workspace policy, remove test/temp files immediately
- Use `logging` not `print()` | Type hints: `torch.Tensor` | Random seeds: `torch.manual_seed(42)`

## 🔧 CONFIGURATION SYSTEM
**Shared configs in /home/seremark/projects/ - consistent across all projects**

**Config Files:**
- `/home/seremark/projects/pyproject.toml` - Ruff configuration (linting, formatting, imports)
- `/home/seremark/projects/pyrightconfig.json` - Basedpyright configuration (type checking, diagnostics)

**Validation Commands:**
```bash
# Test config consistency (configs auto-detected from parent directory)
/home/seremark/.local/ruff-venv/bin/ruff check . --diff
source venv/bin/activate && /home/seremark/.local/basedpyright-venv/bin/basedpyright . --outputjson

# Config validation
/home/seremark/.local/ruff-venv/bin/ruff check --show-settings
source venv/bin/activate && /home/seremark/.local/basedpyright-venv/bin/basedpyright . --verifytypes
```

**Cleanup Commands:**
```bash
# Remove temporary files
find . -name "*.py" -path "*/test_*" -delete
find . -name "*.tmp" -delete
find . -name "__pycache__" -type d -exec rm -rf {} +
```
