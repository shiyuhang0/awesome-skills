# awesome-skills

A local-first repository for managing and reusing Agent Skills across multiple projects.

`awesome-skills` focuses on:
- category-based skill management
- plug-and-play integration into any local project
- no remote dependency and no code changes in business source files

## Features

- Local only: all skills are stored and referenced from your machine.
- Category structure: manage skills under `.agents/skills/<category>/...`.
- Plug-and-play import: use symlinks to attach categories to target projects.
- Zero copy: no duplicated skill files across projects.
- Easy maintenance: update once in `awesome-skills`, all linked projects use latest content.

## Repository Structure

```text
awesome-skills/
├── .agents/
│   └── skills/
│       └── general/
│           └── find-skills/
│               └── SKILL.md
├── link-skills.sh
└── README.md
```

## Requirements

- macOS / Linux
- Bash 3.2+ (macOS default Bash is supported)
- Local filesystem supports symbolic links

## Quick Start

### 1) Clone or place this repository locally

```bash
cd /path/to/local/workspace
# if already available locally, skip clone
```

### 2) Prepare your local skills

Put skills into category folders:

```text
.agents/skills/<category>/<skill-name>/SKILL.md
```

Example:

```text
.agents/skills/general/find-skills/SKILL.md
```

### 3) Link categories into a target project

From `awesome-skills` root:

```bash
./link-skills.sh /path/to/your-project general
```

This creates a symlink in target project:

```text
/path/to/your-project/.agents/skills/general -> /path/to/awesome-skills/.agents/skills/general
```

### 4) Link multiple categories

```bash
./link-skills.sh /path/to/your-project general frontend backend
```

### 5) Link all categories

```bash
./link-skills.sh --all /path/to/your-project
```

### 6) Replace existing links or folders (if needed)

```bash
./link-skills.sh --force /path/to/your-project general
```

## Script Usage

```bash
./link-skills.sh [--all] [--force] <target_project_path> [category ...]
```

- `--all`: link all categories under `.agents/skills/`
- `--force`: replace existing file/folder/symlink at target path
- `-h`, `--help`: show help

## How to Add New Skills

1. Create a category folder if missing:
   - `.agents/skills/<category>/`
2. Add a skill folder:
   - `.agents/skills/<category>/<skill-name>/`
3. Add the skill spec:
   - `.agents/skills/<category>/<skill-name>/SKILL.md`
4. Re-run `link-skills.sh` for the target project/category.

## Validation Checklist

After linking, validate in the target project:

```bash
ls -la /path/to/your-project/.agents/skills
ls -la /path/to/your-project/.agents/skills/<category>
```

Expected:
- category entry is a symlink
- skill folders/files are accessible through the symlink

## Troubleshooting

- `target already exists`:
  - Re-run with `--force`.
- `category does not exist`:
  - Ensure category folder exists in `awesome-skills/.agents/skills/`.
- Symlink permission issues:
  - Check filesystem permissions for both source and target paths.

## Contributing

- Keep skill metadata concise and actionable.
- Use clear category names.
- Avoid embedding secrets in any skill content.

## License

Choose a license (for open source, MIT is commonly used) and add a `LICENSE` file.
