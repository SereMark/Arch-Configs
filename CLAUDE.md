# 🧠 CLAUDE.md - Optimized Memory Reference

## 🖥️ SYSTEM SPECS [CRITICAL]
- **Arch Linux** | AMD Ryzen 5 3600 | NVIDIA RTX 2070 (8GB VRAM)
- **RAM**: 15.54 GiB | **GPU**: CUDA-capable | **Setup**: Single machine only

## 🚀 IMMEDIATE ACTIONS
```bash
source venv/bin/activate          # ALWAYS activate venv first
pip install -r requirements.txt   # New projects only
```

## ⚡ CORE DIRECTIVES
1. **SURGICAL PRECISION** → Touch minimal code only
2. **ROOT CAUSE ONLY** → Never mask symptoms  
3. **HUMAN-LIKE CODE** → Readable > Clever
4. **HONEST ASSESSMENT** → Never sugar-coat limitations

## 🎯 PYTHON AI CHECKLIST
- [ ] Virtual environment activated
- [ ] Type hints for tensors: `torch.Tensor[batch, seq, dim]`
- [ ] Device handling: `device = 'cuda' if torch.cuda.is_available() else 'cpu'`
- [ ] Random seeds: `torch.manual_seed(42)` 
- [ ] Use `logging` not `print()`
- [ ] GPU memory monitoring (8GB limit)
- [ ] Batch size optimization for RTX 2070
- [ ] FP16/mixed precision when possible

## 🔧 DEVELOPMENT WORKFLOW
1. **UNDERSTAND** → Read codebase first
2. **MINIMAL SCOPE** → Solve exactly what's asked
3. **ANALYZE** → Check if fix already exists
4. **IMPLEMENT** → Targeted root-cause changes
5. **VALIDATE** → Test across data samples
6. **DOCUMENT** → Update `dev-notes.md` locally

## 🛡️ MEMORY CONSTRAINTS
- **System RAM**: 15GB total → Keep 3GB buffer
- **GPU VRAM**: 8GB total → Monitor with `nvidia-smi`
- **Batch sizing**: Start small, scale up
- **Checkpointing**: Frequent saves (single machine risk)

## ⚠️ ANTI-PATTERNS [NEVER DO]
- ❌ Band-aid fixes or error suppression
- ❌ Hardcoded device specs (detect dynamically)
- ❌ TODO comments or status markers
- ❌ Breaking existing functionality
- ❌ Over-engineering solutions
- ❌ Ignoring GPU memory leaks

## 📝 CODE STANDARDS
- **Self-documenting**: Variable names > comments
- **Minimal comments**: Only for complex algorithms
- **Debug logging**: Keep structured `logger.debug()`, remove `print()`
- **Follow patterns**: Match existing codebase style
- **Explicit > Implicit**: Clear code over shortcuts

## 🥷 STEALTH PRACTICES
- Files: `dev-notes.md`, `debug-notes.md`, `dev.md`
- Documentation: Write as human developer
- Gitignore: Add as "Development notes"
- No AI mentions in any output

## 🎮 QUICK COMMANDS
```python
# CUDA Check
import torch
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")
if device.type == 'cuda':
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f} GB")

# Memory Monitoring
def get_gpu_memory():
    return torch.cuda.memory_allocated() / 1e9, torch.cuda.memory_reserved() / 1e9

# Batch Size Finder
def find_optimal_batch_size(model, sample_input, max_batch=128):
    batch = 1
    while batch <= max_batch:
        try:
            _ = model(sample_input.repeat(batch, 1, 1))
            batch *= 2
        except RuntimeError as e:
            if "out of memory" in str(e):
                torch.cuda.empty_cache()
                return batch // 2
            raise e
    return batch
```

## 🔄 PROBLEM-SOLVING MATRIX
| Symptom | Check First | Likely Fix |
|---------|------------|------------|
| OOM Error | Batch size, GPU memory | Reduce batch, gradient accumulation |
| Slow Training | Device placement, FP16 | `.cuda()`, mixed precision |
| Reproducibility | Random seeds | Set all seeds (torch, numpy, random) |
| Model Loading | VRAM usage | Clear cache, load in chunks |

## 📌 REMEMBER
- **DO EXACTLY** what's asked - nothing more, nothing less
- **EDIT > CREATE** - Never create files unless necessary
- **NO DOCS** unless explicitly requested
- **LOCAL DEV** - All work happens on this single machine

## 🛠️ CODE QUALITY TOOLS
- When in the Hybrid Chess AI project directory, use the following commands for code quality checks:
  - `basedpyright .` - Static type checking for Python
  - `ruff check .` - Linting and style checks
  - `ruff format .` - Automatic code formatting
  - Recommended: Run these before committing code to ensure high-quality standards