#!/usr/bin/env sh
# Copy the Anti-Defensive Writing skills into a dsh (DeepSeek Harness) skills
# directory, for hosts that load skills from disk instead of installing the
# plugin bundle.
#
# For the plugin route, prefer:
#   dsh plugin --profile <profile> add <this-folder>
set -eu

HERE=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
DEST=${DSH_HOME:-$HOME/.dsh}/skills
FORCE=0

usage() {
  cat <<'HELP'
Copy the Anti-Defensive Writing skills into a skills directory.

Usage:
  ./install.sh [--dest DIR] [--force]

Options:
  --dest DIR   Parent skills directory. Default: ${DSH_HOME:-~/.dsh}/skills
  --force      Replace existing skill folders
  --help       Show this help

Examples:
  ./install.sh
  ./install.sh --dest ~/.agents/skills
  ./install.sh --dest ~/.dsh/skills
HELP
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dest)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "Missing value for --dest" >&2
        exit 2
      fi
      DEST=$2
      shift 2
      ;;
    --force) FORCE=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$DEST" in
  \~) DEST=$HOME ;;
  \~/*) DEST="$HOME/${DEST#\~/}" ;;
  -*) echo "Use an absolute path or prefix the destination with ./" >&2; exit 2 ;;
esac

mkdir -p "$DEST"

for skill in anti-defensive-writing anti-defensive-writing-en; do
  source="$HERE/skills/$skill/SKILL.md"
  [ -f "$source" ] || { echo "Missing bundled skill file: $source" >&2; exit 1; }

  target="$DEST/$skill"
  if [ -L "$target" ]; then
    echo "Destination is a symbolic link: $target. Choose another directory." >&2
    exit 1
  fi
  if [ -e "$target" ] && [ "$FORCE" -ne 1 ]; then
    echo "Destination already exists: $target. Use --force to replace it." >&2
    exit 1
  fi

  staging=$(mktemp -d "$DEST/.${skill}.tmp.XXXXXX")
  trap 'rm -rf "$staging"' 0
  cp "$source" "$staging/SKILL.md"
  IFS= read -r first_line < "$staging/SKILL.md"
  [ "$first_line" = '---' ] || { echo "Invalid SKILL.md: missing YAML frontmatter ($skill)." >&2; exit 1; }

  if [ -e "$target" ]; then
    rm -rf "$target"
  fi
  mv "$staging" "$target"
  trap - 0
  printf 'Installed %s/SKILL.md\n' "$target"
done

printf 'Done. Restart dsh or wait for its skill watcher to pick up %s.\n' "$DEST"
