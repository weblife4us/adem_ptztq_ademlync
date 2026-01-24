#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting Flutter build...${NC}"

# Get latest valid tag (vX.Y.Z-N)
echo -e "${BLUE}Running: git tag --sort=-creatordate | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$' | head -1${NC}"
latest_tag=$(git tag --sort=-creatordate | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$' | head -1 || echo "v0.0.0-0")
version=$(echo "$latest_tag" | sed 's/^v//;s/-.*//')
build_number=$(echo "$latest_tag" | cut -d'-' -f2)
new_build_number=$((build_number + 1))

# Prompt for version and build number
echo -e "${GREEN}Enter version (default: $version):${NC}"
read input_version
version=${input_version:-$version}

while true; do
  echo -e "${GREEN}Enter build number (default: $new_build_number):${NC}"
  read input_build
  build_number=${input_build:-$new_build_number}
  [[ "$build_number" =~ ^[0-9]+$ ]] && [ "$build_number" -gt 0 ] && break
  echo -e "${BLUE}Error: Build number must be a positive integer.${NC}"
done

# Confirm build
echo -e "${BLUE}Build version: $version+$build_number. Proceed? (y/n, default: y)${NC}"
read confirmation
[ "${confirmation:-y}" != "y" ] && [ "${confirmation:-y}" != "Y" ] && { echo "Build cancelled."; exit 1; }

# Build process
echo -e "${BLUE}Running: flutter clean${NC}"
flutter clean || { echo "Clean failed"; exit 1; }

echo -e "${BLUE}Running: flutter pub get${NC}"
flutter pub get || { echo "Pub get failed"; exit 1; }

echo -e "${BLUE}Running: flutter build ipa --release --build-name=$version --build-number=$build_number${NC}"
flutter build ipa --release --build-name="$version" --build-number="$build_number" || { echo "IPA build failed"; exit 1; }

echo -e "${BLUE}Running: flutter build appbundle --release --build-name=$version --build-number=$build_number${NC}"
flutter build appbundle --release --build-name="$version" --build-number="$build_number" || { echo "AppBundle build failed"; exit 1; }

# Create git tag
new_tag="v$version-$build_number"
echo -e "${BLUE}Running: git rev-parse $new_tag${NC}"
if git rev-parse "$new_tag" >/dev/null 2>&1; then
  echo -e "${GREEN}Tag $new_tag exists. Delete and recreate? (y/n, default: n)${NC}"
  read delete_tag
  if [ "${delete_tag:-n}" = "y" ] || [ "${delete_tag:-n}" = "Y" ]; then
    echo -e "${BLUE}Running: git tag -d $new_tag${NC}"
    git tag -d "$new_tag" || { echo "Failed to delete tag $new_tag"; exit 1; }
  fi
fi
echo -e "${BLUE}Running: git tag $new_tag${NC}"
git tag "$new_tag" || { echo "Failed to create tag $new_tag"; exit 1; }

echo -e "${GREEN}Build completed!${NC}"
echo "IPA: build/ios/ipa"
echo "AppBundle: build/app/outputs/bundle/release"