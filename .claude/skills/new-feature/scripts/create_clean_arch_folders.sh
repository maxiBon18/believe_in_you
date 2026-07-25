#!/usr/bin/env zsh
# Create Clean Architecture directory structure for a new feature.
# Usage: ./create_clean_arch_folders.sh <feature_name>

set -e

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

# Create feature directories. Layout is authoritative in CLAUDE.md § Where things live:
#   domain/repo/         repository interfaces        data/repo/          repository impls
#   data/repo/source/    data source interfaces       data/source/        data source impls
#   data/repo/dto/       DTO interfaces               data/source/dto/    DTO impls (generated)
mkdir -p "$pathCleanArch/domain/entities"
mkdir -p "$pathCleanArch/domain/services"
mkdir -p "$pathCleanArch/domain/repo"
mkdir -p "$pathCleanArch/data/repo/source"
mkdir -p "$pathCleanArch/data/repo/dto"
mkdir -p "$pathCleanArch/data/source/dto"
mkdir -p "$pathCleanArch/presentation/ux/pages"
mkdir -p "$pathCleanArch/presentation/ux/widgets"
mkdir -p "$pathCleanArch/presentation/viewmodel"
mkdir -p "$pathCleanArch/shared/constants"
mkdir -p "$pathCleanArch/shared/controllers"
mkdir -p "$pathCleanArch/shared/exceptions"
mkdir -p "$pathCleanArch/shared/mixins"
mkdir -p "$pathCleanArch/shared/utils"

# Create assets directories (idempotent).
mkdir -p assets/{images/{svg,1.5x,2.0x,3.0x,4.0x},fonts,icons}

echo "Feature '$featureFolderName' created at $pathCleanArch/"
