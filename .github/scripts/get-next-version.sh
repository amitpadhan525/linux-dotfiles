#!/usr/bin/env bash
set -euo pipefail

# Fetch latest tag matching v*
LATEST_TAG=$(git tag -l "v[0-9]*.[0-9]*.[0-9]*" | sort -V | tail -n 1)

if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG="v2.0.0"
fi

# Strip 'v' prefix
VERSION="${LATEST_TAG#v}"
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
PATCH=$(echo "$VERSION" | cut -d. -f3)

# Determine bump type based on git log commits since latest tag
BUMP_TYPE="patch"

if git rev-parse "$LATEST_TAG" >/dev/null 2>&1; then
    COMMITS_LOG=$(git log "${LATEST_TAG}..HEAD" --oneline 2>/dev/null || true)
else
    COMMITS_LOG=$(git log -n 10 --oneline)
fi

if echo "$COMMITS_LOG" | grep -qiE "breaking change|major:"; then
    BUMP_TYPE="major"
elif echo "$COMMITS_LOG" | grep -qiE "feat(\(.*\))?:|feature(\(.*\))?:"; then
    BUMP_TYPE="minor"
fi

# Allow manual override via argument if provided (e.g. major, minor, patch, or vX.Y.Z)
if [ -n "${1:-}" ]; then
    if [[ "$1" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TARGET_VER="${1#v}"
        echo "v${TARGET_VER}"
        exit 0
    elif [[ "$1" == "major" || "$1" == "minor" || "$1" == "patch" ]]; then
        BUMP_TYPE="$1"
    fi
fi

case "$BUMP_TYPE" in
    major)
        NEXT_MAJOR=$((MAJOR + 1))
        NEXT_VERSION="v${NEXT_MAJOR}.0.0"
        ;;
    minor)
        NEXT_MINOR=$((MINOR + 1))
        NEXT_VERSION="v${MAJOR}.${NEXT_MINOR}.0"
        ;;
    patch)
        NEXT_PATCH=$((PATCH + 1))
        NEXT_VERSION="v${MAJOR}.${MINOR}.${NEXT_PATCH}"
        ;;
esac

echo "$NEXT_VERSION"
