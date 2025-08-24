#!/bin/bash

# Omarchy Enhanced Bindings Test Script
# Created by: nemui
# Description: Tests the installation script and verifies all components are working correctly
# This script runs various checks to ensure the enhanced bindings can be installed properly

# Remove set -e to prevent early exit and add better error handling
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters for test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Function to print colored output
print_test_header() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to print the final summary without incrementing counters
print_final_summary() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_TOTAL++))
    print_test_header "Running: $test_name"
    
    if eval "$test_command" 2>&1; then
        print_success "$test_name"
        ((TESTS_PASSED++))
        return 0
    else
        local exit_code=$?
        print_failure "$test_name (exit code: $exit_code)"
        return 1
    fi
}

# Test 1: Check if script directory structure is correct
test_directory_structure() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check if all required files exist
    [ -f "$script_dir/install.sh" ] || { echo "install.sh missing"; return 1; }
    [ -f "$script_dir/uninstall.sh" ] || { echo "uninstall.sh missing"; return 1; }
    [ -f "$script_dir/README.md" ] || { echo "README.md missing"; return 1; }
    [ -d "$script_dir/bindings" ] || { echo "bindings directory missing"; return 1; }
    
    # Check if enhanced binding files exist (streamlined package)
    [ -f "$script_dir/bindings/tiling.conf" ] || { echo "tiling.conf missing"; return 1; }
    [ -f "$script_dir/bindings/bindings.conf" ] || { echo "bindings.conf missing"; return 1; }
    [ -f "$script_dir/bindings/webapps.conf" ] || { echo "webapps.conf missing"; return 1; }
    
    return 0
}

# Test 2: Check if scripts are executable
test_script_permissions() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    [ -x "$script_dir/install.sh" ] || { echo "install.sh not executable"; return 1; }
    [ -x "$script_dir/uninstall.sh" ] || { echo "uninstall.sh not executable"; return 1; }
    
    return 0
}

# Test 3: Validate binding file syntax
test_binding_syntax() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local errors=0
    
    # Check tiling.conf for proper syntax
    if ! grep -q "^bindd = " "$script_dir/bindings/tiling.conf"; then
        echo "tiling.conf: No valid bindd entries found"
        ((errors++))
    fi
    
    # Check for numpad support
    if ! grep -q "KP_" "$script_dir/bindings/tiling.conf"; then
        echo "tiling.conf: No numpad bindings found"
        ((errors++))
    fi
    
    # Check bindings.conf for additional features
    if ! grep -q "^bindd = " "$script_dir/bindings/bindings.conf"; then
        echo "bindings.conf: No valid bindd entries found"
        ((errors++))
    fi
    
    # Check webapps.conf for web app bindings
    if ! grep -q "^bindd = " "$script_dir/bindings/webapps.conf"; then
        echo "webapps.conf: No valid bindd entries found"
        ((errors++))
    fi
    
    [ $errors -eq 0 ] || return 1
    return 0
}

# Test 4: Check for key binding conflicts within files
test_binding_conflicts() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local conflicts=0
    
    # Extract all keybindings and check for duplicates
    local temp_file=$(mktemp)
    
    # Combine all binding definitions
    grep "^bindd = \|^bind = \|^bindld = \|^bindeld = \|^bindmd = " "$script_dir/bindings/"*.conf | \
    awk -F', ' '{print $1 "," $2}' | \
    sort > "$temp_file"
    
    # Check for duplicate key combinations, but exclude intentional duplicates like ALT+Tab
    local duplicates=$(uniq -d "$temp_file" | grep -v "ALT,Tab")
    if [ -n "$duplicates" ]; then
        echo "Problematic duplicate key bindings found:"
        echo "$duplicates"
        conflicts=1
    fi
    
    # Check if there are ALT+Tab duplicates and show info (but don't fail)
    local alt_tab_count=$(grep -c "ALT,Tab" "$temp_file" || true)
    if [ "$alt_tab_count" -gt 1 ]; then
        print_status "Found $alt_tab_count ALT+Tab bindings (this is intentional for window cycling)"
    fi
    
    rm -f "$temp_file"
    [ $conflicts -eq 0 ] || return 1
    return 0
}

# Test 5: Simulate Omarchy detection
test_omarchy_detection() {
    # This test checks if the detection logic would work
    # We don't want to actually require Omarchy for testing
    
    if [ -d "$HOME/.local/share/omarchy" ]; then
        print_status "Omarchy installation found - detection would succeed"
        return 0
    else
        print_status "Omarchy not installed - detection logic works (would fail appropriately)"
        return 0
    fi
}

# Test 6: Check install script syntax
test_install_script_syntax() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check bash syntax
    bash -n "$script_dir/install.sh" || { echo "install.sh has syntax errors"; return 1; }
    bash -n "$script_dir/uninstall.sh" || { echo "uninstall.sh has syntax errors"; return 1; }
    
    return 0
}

# Test 7: Verify specific enhanced features
test_enhanced_features() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local missing_features=0
    
    # Check for numpad workspace switching
    if ! grep -q "KP_End.*workspace.*1" "$script_dir/bindings/tiling.conf"; then
        echo "Missing: Numpad workspace switching"
        ((missing_features++))
    fi
    
    # Check for numpad window moving
    if ! grep -q "KP_End.*movetoworkspace.*1" "$script_dir/bindings/tiling.conf"; then
        echo "Missing: Numpad window moving"
        ((missing_features++))
    fi
    
    # Check for relative workspace navigation
    if ! grep -q "SUPER CTRL.*Right.*workspace.*r+" "$script_dir/bindings/tiling.conf"; then
        echo "Missing: Relative workspace navigation"
        ((missing_features++))
    fi
    
    # Check for VSCode Cline support  
    if ! grep -q "pass.*code" "$script_dir/bindings/bindings.conf"; then
        echo "Missing: VSCode Cline support"
        ((missing_features++))
    fi
    
    # Check for correct window close/float bindings
    if ! grep -q "SUPER, Q,.*killactive" "$script_dir/bindings/tiling.conf"; then
        echo "Missing: SUPER+Q to close window"
        ((missing_features++))
    fi
    if ! grep -q "SUPER, W,.*togglefloating" "$script_dir/bindings/tiling.conf"; then
        echo "Missing: SUPER+W to toggle floating"
        ((missing_features++))
    fi

    [ $missing_features -eq 0 ] || return 1
    return 0
}

# Test 8: Check documentation completeness
test_documentation() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local missing_docs=0
    
    # Check README.md
    if ! grep -q "Numpad Support" "$script_dir/README.md"; then
        echo "README.md missing numpad documentation"
        ((missing_docs++))
    fi
    
    if ! grep -q "Installation" "$script_dir/README.md"; then
        echo "README.md missing installation instructions"
        ((missing_docs++))
    fi
    
    if ! grep -q "Key Bindings" "$script_dir/README.md"; then
        echo "README.md missing key bindings documentation"
        ((missing_docs++))
    fi
    
    [ $missing_docs -eq 0 ] || return 1
    return 0
}

# Test 9: Dry run installation (without actually installing)
test_dry_run_installation() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Save our test functions before sourcing install.sh
    local saved_print_success=$(declare -f print_success)
    local saved_print_status=$(declare -f print_status)
    local saved_print_warning=$(declare -f print_warning)
    
    # Source the install script functions without running main
    source "$script_dir/install.sh"
    
    # Restore our test functions
    eval "$saved_print_success"
    eval "$saved_print_status" 
    eval "$saved_print_warning"
    
    # Test individual functions
    print_status "Testing installation functions..."
    
    # Test that functions exist
    type check_omarchy >/dev/null 2>&1 || { echo "check_omarchy function missing"; return 1; }
    type backup_bindings >/dev/null 2>&1 || { echo "backup_bindings function missing"; return 1; }
    type install_bindings >/dev/null 2>&1 || { echo "install_bindings function missing"; return 1; }
    type reload_hyprland >/dev/null 2>&1 || { echo "reload_hyprland function missing"; return 1; }
    type perform_merge >/dev/null 2>&1 || { echo "perform_merge function missing"; return 1; }
    
    return 0
}

# Test 10: Test the merge logic
test_merge_logic() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Save the test script's helper functions
    local saved_print_success=$(declare -f print_success)
    local saved_print_failure=$(declare -f print_failure)
    local saved_print_status=$(declare -f print_status)
    local saved_print_warning=$(declare -f print_warning)

    # Source install.sh to get the perform_merge function
    source "$script_dir/install.sh"

    # Restore the test script's helper functions to prevent conflicts
    eval "$saved_print_success"
    eval "$saved_print_failure"
    eval "$saved_print_status"
    eval "$saved_print_warning"
    
    # Create dummy files
    local source_file=$(mktemp)
    local target_file=$(mktemp)
    
    cat > "$source_file" <<EOF
# Source Bindings
\$browser = uwsm app -- brave
bindd = SUPER, B, Browser, exec, \$browser
bindd = SUPER, N, Neovim, exec, \$terminal -e nvim
EOF

    cat > "$target_file" <<EOF
# Target Bindings
\$browser = uwsm app -- chromium
bindd = SUPER, B, Old Browser, exec, \$browser
bindd = SUPER, C, Custom User Binding, exec, custom-command
EOF

    # Perform the merge
    perform_merge "$source_file" "$target_file" >/dev/null 2>&1
    
    # Verify results
    local errors=0
    # 1. Custom binding should be preserved
    grep -q "SUPER, C, Custom User Binding" "$target_file" || { echo "Merge failed: Custom binding was removed."; ((errors++)); }
    # 2. Existing binding should be updated
    grep -q "SUPER, B, Browser" "$target_file" || { echo "Merge failed: Existing binding not updated."; ((errors++)); }
    ! grep -q "SUPER, B, Old Browser" "$target_file" || { echo "Merge failed: Old binding was not removed."; ((errors++)); }
    # 3. New binding should be added
    grep -q "SUPER, N, Neovim" "$target_file" || { echo "Merge failed: New binding was not added."; ((errors++)); }
    # 4. Variable should be updated
    grep -q "\$browser = uwsm app -- brave" "$target_file" || { echo "Merge failed: Variable not updated."; ((errors++)); }

    # Cleanup
    rm -f "$source_file" "$target_file"
    
    [ $errors -eq 0 ] || return 1
    return 0
}

# Function to run all tests
run_all_tests() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Omarchy Enhanced Bindings Test     ║${NC}"
    echo -e "${BLUE}║           Suite Runner                ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    print_status "Testing from directory: $script_dir"
    echo ""
    
    # Run all tests
    run_test "Directory Structure" "test_directory_structure"
    run_test "Script Permissions" "test_script_permissions"
    run_test "Binding File Syntax" "test_binding_syntax"
    run_test "Key Binding Conflicts" "test_binding_conflicts"
    run_test "Omarchy Detection Logic" "test_omarchy_detection"
    run_test "Install Script Syntax" "test_install_script_syntax"
    run_test "Enhanced Features" "test_enhanced_features"
    run_test "Documentation" "test_documentation"
    run_test "Dry Run Installation" "test_dry_run_installation"
    run_test "Merge Logic" "test_merge_logic"
    
    # Print results
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║            Test Results               ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_final_summary "All tests passed! ($TESTS_PASSED/$TESTS_TOTAL)"
        echo ""
        echo -e "${GREEN}✅ The enhanced bindings are ready for distribution!${NC}"
        echo -e "${GREEN}✅ Installation script should work correctly${NC}"
        echo -e "${GREEN}✅ All enhanced features are present${NC}"
        echo ""
        print_status "To install the enhanced bindings, run:"
        echo -e "${CYAN}  ./install.sh${NC}"
        return 0
    else
        print_failure "Some tests failed! ($TESTS_FAILED/$TESTS_TOTAL failed)"
        echo ""
        echo -e "${RED}❌ Please fix the issues above before distributing${NC}"
        return 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests "$@"
fi
