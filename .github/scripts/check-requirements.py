#!/usr/bin/env bash
""":"
# Python wrapper to run with system python3
exec python3 "$0" "$@"
"""

import os
import re
import sys
import glob
import py_compile
import subprocess

REPO_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

def log_info(msg):
    print(f"\033[1;34m[*] {msg}\033[0m")

def log_success(msg):
    print(f"\033[1;32m[+] {msg}\033[0m")

def log_error(msg):
    print(f"\033[1;31m[x] {msg}\033[0m")

def log_warn(msg):
    print(f"\033[1;33m[!] {msg}\033[0m")

def check_package_requirements():
    log_info("Checking package requirements across installer and documentation...")
    install_sh_path = os.path.join(REPO_DIR, "install.sh")
    install_txt_path = os.path.join(REPO_DIR, "install.txt")
    resources_md_path = os.path.join(REPO_DIR, "RESOURCES.md")

    if not os.path.exists(install_sh_path):
        log_error(f"install.sh not found at {install_sh_path}")
        return False

    with open(install_sh_path, "r", encoding="utf-8") as f:
        install_sh_content = f.read()

    with open(install_txt_path, "r", encoding="utf-8") as f:
        install_txt_content = f.read()

    with open(resources_md_path, "r", encoding="utf-8") as f:
        resources_md_content = f.read()

    # Extract all array definitions for packages
    arrays = [
        "CORE_WM", "MULTIMEDIA", "SYSTEM_UTILS",
        "SESSION_SERVICES", "PORTAL_SERVICES", "DECO_TYPO",
        "SYSTEM_INTEGRATION"
    ]
    
    installer_packages = []
    for arr in arrays:
        m = re.search(rf'readonly {arr}=\((.*?)\)', install_sh_content, re.DOTALL)
        if m:
            pkgs = re.findall(r'\"([^\"]+)\"', m.group(1))
            installer_packages.extend(pkgs)
        else:
            log_warn(f"Array {arr} not found in install.sh")

    installer_packages = sorted(list(set(installer_packages)))
    log_info(f"Found {len(installer_packages)} unique packages specified in install.sh")

    missing_in_install_txt = []
    for pkg in installer_packages:
        # Check word boundary or exact occurrence in install.txt
        if not re.search(r'\b' + re.escape(pkg) + r'\b', install_txt_content):
            missing_in_install_txt.append(pkg)

    missing_in_resources_md = []
    for pkg in installer_packages:
        if not re.search(r'\b' + re.escape(pkg) + r'\b', resources_md_content):
            missing_in_resources_md.append(pkg)

    has_errors = False
    if missing_in_install_txt:
        log_error(f"Packages in install.sh but MISSING from install.txt: {missing_in_install_txt}")
        has_errors = True
    else:
        log_success("All packages in install.sh are documented in install.txt.")

    if missing_in_resources_md:
        log_warn(f"Packages in install.sh not mentioned in RESOURCES.md: {missing_in_resources_md}")
    else:
        log_success("All packages in install.sh are mentioned in RESOURCES.md.")

    return not has_errors

def check_config_modules():
    log_info("Checking configuration modules and file targets...")
    install_sh_path = os.path.join(REPO_DIR, "install.sh")
    with open(install_sh_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract config_modules
    m_mods = re.search(r'config_modules=\((.*?)\)', content, re.DOTALL)
    if not m_mods:
        log_error("Could not find config_modules in install.sh")
        return False
    modules = re.findall(r'\"([^\"]+)\"', m_mods.group(1))

    # Extract home_files
    m_files = re.search(r'home_files=\((.*?)\)', content, re.DOTALL)
    if not m_files:
        log_error("Could not find home_files in install.sh")
        return False
    home_file_specs = re.findall(r'\"([^\"]+)\"', m_files.group(1))

    has_errors = False
    for mod in modules:
        target_dir = os.path.join(REPO_DIR, "hyprland", mod)
        if not os.path.isdir(target_dir):
            log_error(f"Config module directory missing: hyprland/{mod}")
            has_errors = True
        else:
            log_success(f"Config module hyprland/{mod} exists.")

    for item in home_file_specs:
        src = item.split(":")[0]
        target_file = os.path.join(REPO_DIR, "hyprland", src)
        if not os.path.isfile(target_file):
            log_error(f"Home file missing: hyprland/{src}")
            has_errors = True
        else:
            log_success(f"Home file hyprland/{src} exists.")

    return not has_errors

def check_script_syntax():
    log_info("Checking syntax of all shell and python scripts in repository...")
    has_errors = False

    # Check bash scripts with bash -n
    sh_files = []
    for root, _, files in os.walk(REPO_DIR):
        if ".git" in root:
            continue
        for f in files:
            if f.endswith(".sh"):
                sh_files.append(os.path.join(root, f))

    for sh_file in sorted(sh_files):
        rel_path = os.path.relpath(sh_file, REPO_DIR)
        res = subprocess.run(["bash", "-n", sh_file], capture_output=True, text=True)
        if res.returncode != 0:
            log_error(f"Bash syntax error in {rel_path}:\n{res.stderr}")
            has_errors = True
        else:
            log_success(f"Syntax OK: {rel_path}")

    # Check python scripts with py_compile
    py_files = []
    for root, _, files in os.walk(REPO_DIR):
        if ".git" in root or "__pycache__" in root:
            continue
        for f in files:
            if f.endswith(".py"):
                py_files.append(os.path.join(root, f))

    for py_file in sorted(py_files):
        rel_path = os.path.relpath(py_file, REPO_DIR)
        try:
            py_compile.compile(py_file, doraise=True)
            log_success(f"Python syntax OK: {rel_path}")
        except py_compile.PyCompileError as e:
            log_error(f"Python syntax error in {rel_path}: {e}")
            has_errors = True

    return not has_errors

def main():
    print("\n=======================================================")
    print("  🌌 Linux Dotfiles Requirement & Integrity Check")
    print("=======================================================\n")

    ok_pkgs = check_package_requirements()
    print("")
    ok_mods = check_config_modules()
    print("")
    ok_scripts = check_script_syntax()
    print("")

    if ok_pkgs and ok_mods and ok_scripts:
        log_success("All requirement and integrity checks PASSED successfully! 🚀\n")
        sys.exit(0)
    else:
        log_error("Integrity check FAILED. Please resolve the errors listed above.\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
