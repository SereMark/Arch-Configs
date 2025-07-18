# 🧠 CLAUDE.md - Essential Memory

## ⚡ WORKFLOW
```bash
# 1. ALWAYS FIRST
source venv/bin/activate

# 2. Quality checks (auto-detects enhanced configs)
/home/seremark/.local/ruff-venv/bin/ruff check .
/home/seremark/.local/ruff-venv/bin/ruff format .
/home/seremark/.local/ruff-venv/bin/ruff check . --fix
/home/seremark/.local/basedpyright-venv/bin/basedpyright .

# 3. GPU monitoring
nvidia-smi
```

## 🚨 CONSTRAINTS
- **8GB VRAM** - Monitor GPU memory constantly

## 🎯 BEHAVIOR
- **MINIMAL CHANGES** - Surgical precision only
- **EDIT > CREATE** - Never create files unless necessary
- **NO DOCS** - Unless explicitly requested
- **MODERN PYTHON** - `int | float | str`, `logging`, `torch.Tensor`

## 🔧 CONFIGS (Auto-detected)
- `/home/seremark/projects/pyproject.toml` - Enhanced Ruff (NPY, PERF, FURB, PTH, ASYNC)
- `/home/seremark/projects/pyrightconfig.json` - Basedpyright (Union types, ML patterns)