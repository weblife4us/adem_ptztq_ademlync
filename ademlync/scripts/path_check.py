#!/usr/bin/env python3
# Script to optimize Dart import paths in a Flutter project by minimizing relative paths
# and removing invalid or duplicate imports. Excludes localization files in l10n/ and oss_licenses.dart.

import os
from pathlib import Path
import re
from concurrent.futures import ThreadPoolExecutor
import sys
import time
import threading


def loading_animation(stop_event):
    """Display a loading animation until stop_event is set."""
    # Cycles through |, /, -, \ to indicate ongoing processing
    chars = ["|", "/", "-", "\\"]
    while not stop_event.is_set():
        for char in chars:
            sys.stdout.write(f"\rProcessing... {char}")
            sys.stdout.flush()
            time.sleep(0.1)
    sys.stdout.write("\r")
    sys.stdout.flush()


def find_project_root():
    """Find the Flutter project root by locating pubspec.yaml."""
    # Traverses up from current directory until pubspec.yaml is found
    current = Path.cwd()
    while current != current.parent:
        if (current / "pubspec.yaml").exists():
            return current
        current = current.parent
    raise FileNotFoundError("No pubspec.yaml found. Are you in a Flutter project?")


def get_dart_files(project_root):
    """Collect all .dart files in the lib directory, excluding l10n/ and oss_licenses.dart."""
    # Recursively scans lib/ for .dart files, skipping localization and license files
    lib_dir = project_root / "lib"
    if not lib_dir.exists():
        return []
    dart_files = []
    for file in lib_dir.rglob("*.dart"):
        # Skip l10n/ (localization) and oss_licenses.dart (auto-generated)
        if (
            "l10n/" not in str(file.relative_to(lib_dir))
            and file.name != "oss_licenses.dart"
        ):
            dart_files.append(file)
    return dart_files


def build_file_cache(dart_files):
    """Build a cache of filenames to their paths for faster lookup."""
    # Maps filenames to full paths to avoid repeated filesystem searches
    return {file.name: file for file in dart_files}


def resolve_import_path(current_file, import_path, project_root, file_cache):
    """Resolve a relative import path and verify if the target file exists."""
    # Try resolving the import path relative to the current file's directory
    current_dir = current_file.parent
    try:
        resolved = (current_dir / import_path).resolve()
        if resolved.exists():
            return resolved
    except (FileNotFoundError, ValueError):
        # Handle invalid paths or symlinks gracefully
        pass
    # Fallback: look up the filename in the cached file list
    filename = Path(import_path).name
    return file_cache.get(filename)


def compute_minimal_path(current_file, target_file):
    """Compute the shortest relative path from current_file to target_file."""
    # Uses os.path.relpath to create minimal ../ or ./ paths
    current_dir = current_file.parent
    target_dir = target_file.parent
    rel_path = os.path.relpath(target_dir, current_dir)
    return Path(rel_path) / target_file.name


def process_dart_file(file_path, project_root, file_cache):
    """Process a Dart file to optimize relative imports and remove duplicates."""
    # Reads file, updates relative import paths, and removes invalid/duplicate imports
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    modified = False
    new_lines = []
    import_pattern = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"];")
    seen_imports = set()  # Tracks import paths to detect duplicates

    for line in lines:
        match = import_pattern.match(line)
        if match:
            import_path = match.group(1)
            # Skip package: and dart: imports, process only relative imports
            if not (
                import_path.startswith("package:") or import_path.startswith("dart:")
            ):
                target_file = resolve_import_path(
                    file_path, import_path, project_root, file_cache
                )
                if target_file is None:
                    modified = True
                    continue  # Skip invalid import (file not found)
                new_path = compute_minimal_path(file_path, target_file)
                new_path_str = str(new_path).replace("\\", "/")
                if new_path_str in seen_imports:
                    modified = True
                    continue  # Skip duplicate import
                seen_imports.add(new_path_str)
                new_line = line.replace(import_path, new_path_str)
                new_lines.append(new_line)
                if new_line != line:
                    modified = True
                continue
        new_lines.append(line)

    if modified:
        # Write updated content to file
        with open(file_path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)

    return modified, file_path


def main():
    """Optimize Dart imports across a Flutter project using parallel processing."""
    # Manages file processing with multithreading for efficiency
    try:
        stop_event = threading.Event()
        loading_thread = threading.Thread(target=loading_animation, args=(stop_event,))
        loading_thread.start()

        project_root = find_project_root()
        dart_files = get_dart_files(project_root)
        if not dart_files:
            stop_event.set()
            loading_thread.join()
            print("No .dart files found in lib directory.")
            return

        file_cache = build_file_cache(dart_files)  # Cache filenames for faster lookups
        modified_files = 0

        # Process files in parallel to improve performance
        with ThreadPoolExecutor() as executor:
            results = executor.map(
                lambda f: process_dart_file(f, project_root, file_cache), dart_files
            )

        for modified, file_path in results:
            if modified:
                modified_files += 1

        stop_event.set()
        loading_thread.join()

        # Display summary of changes
        print(f"Total files checked: {len(dart_files)}")
        print(f"Total files corrected: {modified_files}")

    except Exception as e:
        stop_event.set()
        loading_thread.join()
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
