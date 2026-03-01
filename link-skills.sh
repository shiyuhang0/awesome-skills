#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$SCRIPT_DIR/.agents/skills"

usage() {
  cat <<"EOF"
Usage:
  ./link-skills.sh [link] [--all] [--force] <target_project_path> [category ...]
  ./link-skills.sh unlink [--all] [--force] <target_project_path> [category ...]

Examples:
  ./link-skills.sh /path/to/project general
  ./link-skills.sh link /path/to/project general
  ./link-skills.sh unlink /path/to/project general
  ./link-skills.sh /path/to/project frontend backend
  ./link-skills.sh --all /path/to/project
  ./link-skills.sh unlink --all /path/to/project

Options:
  link      Link categories into target project (default command)
  unlink    Remove linked categories from target project
  --all     Link all categories found in .agents/skills
  --force   For link: replace existing targets; for unlink: remove non-symlink targets
  -h,--help Show this help message
EOF
}

FORCE=0
LINK_ALL=0
POSITIONAL=()
CMD="link"

while [[ $# -gt 0 ]]; do
  case "$1" in
    link|unlink)
      CMD="$1"
      shift
      ;;
    --all)
      LINK_ALL=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
  usage
  exit 1
fi

TARGET_PROJECT="${POSITIONAL[0]}"
TARGET_PROJECT="${TARGET_PROJECT%/}"

if [[ ! -d "$TARGET_PROJECT" ]]; then
  echo "Error: target project does not exist: $TARGET_PROJECT" >&2
  exit 1
fi

TARGET_ROOT="$TARGET_PROJECT/.agents/skills"
mkdir -p "$TARGET_ROOT"

declare -a CATEGORIES=()

if [[ "$LINK_ALL" -eq 1 ]]; then
  while IFS= read -r -d "" dir; do
    CATEGORIES+=("$(basename "$dir")")
  done < <(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0)
else
  if [[ ${#POSITIONAL[@]} -lt 2 ]]; then
    echo "Error: please provide at least one category, or use --all" >&2
    usage
    exit 1
  fi

  for ((i = 1; i < ${#POSITIONAL[@]}; i++)); do
    CATEGORIES+=("${POSITIONAL[$i]}")
  done
fi

if [[ ${#CATEGORIES[@]} -eq 0 ]]; then
  echo "No categories found to process."
  exit 0
fi

for category in "${CATEGORIES[@]}"; do
  source_path="$SOURCE_ROOT/$category"
  target_path="$TARGET_ROOT/$category"

  if [[ "$CMD" == "link" ]]; then
    if [[ ! -d "$source_path" ]]; then
      echo "Skip: category does not exist in awesome-skills: $category" >&2
      continue
    fi

    if [[ -L "$target_path" || -e "$target_path" ]]; then
      if [[ "$FORCE" -eq 1 ]]; then
        rm -rf "$target_path"
      else
        echo "Skip: target already exists, use --force to replace: $target_path"
        continue
      fi
    fi

    ln -s "$source_path" "$target_path"
    echo "Linked: $category -> $target_path"
    continue
  fi

  if [[ -L "$target_path" ]]; then
    rm -f "$target_path"
    echo "Unlinked: $category from $target_path"
  elif [[ -e "$target_path" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$target_path"
      echo "Removed (forced): $category from $target_path"
    else
      echo "Skip: target exists but is not a symlink, use --force to remove: $target_path"
    fi
  else
    echo "Skip: category is not linked in target project: $category"
  fi
done
