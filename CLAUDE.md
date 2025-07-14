# Development Philosophy & Standards

## Core Programming Principles
- **Surgical precision**: Touch only the minimal code required to solve the problem
- **Human-like code**: Write as an experienced developer would - readable, logical, elegant
- **Root cause engineering**: Always fix the underlying issue, never mask symptoms
- **Professional craftsmanship**: Every change should improve overall code quality
- **Honest assessment**: Always provide truthful evaluation of solutions, limitations, and trade-offs - never sugar-coat issues or present solutions as better than they are

## System Context
- **Environment**: Arch Linux on AMD Ryzen 5 3600 with NVIDIA RTX 2070
- **Memory**: 15.54 GiB available for training and development
- **GPU**: CUDA-capable RTX 2070 for AI workloads
- **Single machine**: All training and development happens locally

## Code Quality Standards
- **Minimalist excellence**: Balance clean, minimal code with professional functionality
- Follow existing patterns and conventions religiously
- Write self-documenting code with meaningful variable/function names
- **Minimal commenting**: Code should be readable enough to document itself - only add comments/docstrings when absolutely necessary for complex business logic or non-obvious algorithms
- Never leave TODO comments or status markers like "fixed", "updated", "changed"
- **Smart debug cleanup**: Remove temporary prints and development scaffolding, but preserve proper debug-level logging statements that provide ongoing value
- Prefer clear, explicit code over clever shortcuts

## Development Workflow
- **Understand first**: Read and comprehend the codebase before making changes
- **Minimal scope**: Resist feature creep - solve exactly what was requested
- **AI-aware design**: Consider model performance, memory usage, and inference time
- **Hardware optimization**: Leverage RTX 2070 efficiently for training and inference
- **Document solutions locally**: Always create/update project-local dev-notes.md files to document debugging solutions, architecture insights, and lessons learned - this prevents repeating the same mistakes and won't be committed to git. Use standard developer naming conventions.

## Python AI Development Guidelines
- Always activate virtual environment: `source venv/bin/activate` or equivalent
- New projects: Install dependencies with `pip install -r requirements.txt`
- Use type hints especially for tensor shapes and model inputs/outputs
- Handle CUDA/device placement explicitly: check for RTX 2070 availability
- Set random seeds for reproducible experiments when needed
- Use logging instead of print statements for debugging
- Implement proper error handling for model loading and GPU memory issues
- Monitor GPU memory usage (RTX 2070 has ~8GB VRAM)

## AI-Specific Considerations
- **Memory efficiency**: Optimize for 15GB system RAM and 8GB GPU memory
- **Batch sizing**: Adjust batch sizes for RTX 2070 capabilities
- **Model checkpointing**: Save frequently due to single-machine setup
- **Data loading**: Efficient data pipelines for local training workflows
- **Mixed precision**: Use FP16 when possible to maximize RTX 2070 performance

## Problem-Solving Approach
1. **Diagnose thoroughly**: Understand the complete problem context and resource constraints
2. **Plan strategically**: Consider GPU memory limits and training time on single RTX 2070
3. **Code analysis first**: Before applying any fix, thoroughly examine the codebase to ensure the fix isn't redundant or useless
4. **Implement precisely**: Make targeted changes that address root causes
5. **Validate comprehensively**: Test across different data samples and hardware configurations
6. **Document solutions**: Update project-local dev-notes.md with debugging solutions, root causes, and architectural insights for future reference

## What NOT to do
- Never apply band-aid fixes or suppress errors without handling them
- **Selective debug cleanup**: Remove temporary prints and ad-hoc debugging code, but preserve structured logging at debug level that provides ongoing diagnostic value
- Don't ignore GPU memory leaks or inefficient CUDA operations
- Avoid hardcoding device specifications - detect RTX 2070 dynamically
- Never break existing functionality while optimizing for local hardware
- Don't over-engineer solutions - maintain elegant simplicity

## Stealth Development Practices
- **Hide AI assistance**: Use standard developer file names like `dev-notes.md`, `debug-notes.md`, or `dev.md` - completely normal names
- **Natural documentation**: Write documentation as if created by human developer - no mentions of AI assistance
- **Standard patterns**: Use conventional development terminology and debugging approaches
- **Gitignore patterns**: Add standard dev files to gitignore as "Development notes" - looks completely normal