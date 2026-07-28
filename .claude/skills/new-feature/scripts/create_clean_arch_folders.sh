#!/usr/bin/env bash
# Create Clean Architecture directory structure for a new feature.
# Usage: bash .claude/skills/new-feature/scripts/create_clean_arch_folders.sh <feature_name>

set -euo pipefail

# Resolve project root (parent of lib/) from script location.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

# Validate input.
featureFolderName="${1:?Usage: $0 <feature_name>}"

if [[ ! "$featureFolderName" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "Error: Feature name must be snake_case (lowercase letters, digits, underscores)."
    exit 1
fi

if [ -d "lib/$featureFolderName" ]; then
    echo "Error: lib/$featureFolderName already exists."
    exit 1
fi

echo "Creating feature: $featureFolderName"

pathCleanArch="lib/$featureFolderName"

# Layout is authoritative in CLAUDE.md § Where things live:
#   domain/repo/         repository interfaces        data/repo/          repository impls
#   data/repo/source/    data source interfaces       data/source/        data source impls
#   data/repo/dto/       DTO interfaces               data/source/dto/    DTO impls (generated)
#   data/source/db/      Drift tables and database
featureDirs=(
    "domain/entities"
    "domain/services"
    "domain/repo"
    "data/repo"
    "data/repo/source"
    "data/repo/dto"
    "data/source"
    "data/source/db"
    "data/source/dto"
    "presentation/ux/pages"
    "presentation/ux/widgets"
    "presentation/viewmodel"
    "shared/constants"
    "shared/controllers"
    "shared/exceptions"
    "shared/mixins"
    "shared/utils"
)

# Git does not track empty directories, so the scaffold would vanish on the next clone
# without a placeholder in each leaf.
for dir in "${featureDirs[@]}"; do
    mkdir -p "$pathCleanArch/$dir"
    touch "$pathCleanArch/$dir/.gitkeep"
done

# Mirror the structure under test/, which mirrors lib/ (testing-rules.md § Structure).
for dir in domain/services data/repo presentation/viewmodel presentation/ux; do
    mkdir -p "test/$featureFolderName/$dir"
    touch "test/$featureFolderName/$dir/.gitkeep"
done

# Shared asset directories (idempotent — created once, not per feature).
for dir in assets/images/svg assets/images/1.5x assets/images/2.0x assets/images/3.0x \
           assets/images/4.0x assets/fonts assets/icons; do
    mkdir -p "$dir"
    touch "$dir/.gitkeep"
done

echo "Feature '$featureFolderName' created at $pathCleanArch/"
echo "Tests scaffolded at test/$featureFolderName/"
