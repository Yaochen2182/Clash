#!/bin/bash
# Rule validation script for Clash configuration
# Validates rule syntax and checks domain coverage

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
LIST_DIR="$REPO_ROOT/List"
CONVERSION_INI="$REPO_ROOT/Conversion.ini"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ERRORS=$((ERRORS + 1)); }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
log_info() { echo -e "[INFO] $1"; }

validate_rule_syntax() {
    local file="$1"
    local line_num=0
    local valid_types="DOMAIN|DOMAIN-SUFFIX|DOMAIN-KEYWORD|IP-CIDR|IP-CIDR6|GEOIP|MATCH|PROCESS-NAME|USER-AGENT|SRC-PORT|DST-PORT|IN-PORT|RULE-SET|AND|OR|NOT|SUB-RULE|NETWORK"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        if ! echo "$line" | grep -qE "^($valid_types),"; then
            log_fail "$file:$line_num: Invalid rule type: $line"
        fi
    done < "$file"
}

check_appleai_coverage() {
    log_info "Checking AppleAI.list official endpoint coverage..."
    local appleai_file="$LIST_DIR/AppleAI.list"
    
    local required_domains=(
        "guzzoni.apple.com"
        "smoot.apple.com"
        "apple-relay.apple.com"
        "apple-relay.cloudflare.com"
        "apple-relay.fastly-edge.com"
        "cp4.cloudflare.com"
    )
    
    for domain in "${required_domains[@]}"; do
        if grep -q "$domain" "$appleai_file" 2>/dev/null; then
            log_pass "AppleAI covers: $domain"
        else
            log_fail "AppleAI missing required domain: $domain"
        fi
    done
    
    local excluded_domains=(
        "mask.icloud.com"
        "mask-h2.icloud.com"
        "mask-api.icloud.com"
    )
    
    for domain in "${excluded_domains[@]}"; do
        if grep -q "$domain" "$appleai_file" 2>/dev/null; then
            log_fail "AppleAI incorrectly includes iCloud Private Relay domain: $domain"
        else
            log_pass "AppleAI correctly excludes: $domain"
        fi
    done
}

check_precedence() {
    log_info "Checking rule precedence in Conversion.ini..."
    
    local appleai_line=$(grep -n "AppleAI.list" "$CONVERSION_INI" | head -1 | cut -d: -f1)
    local apple_line=$(grep -n "Apple.list" "$CONVERSION_INI" | head -1 | cut -d: -f1)
    local cloudflare_line=$(grep -n "CloudflareProxy.list" "$CONVERSION_INI" | head -1 | cut -d: -f1)
    local proxmisc_line=$(grep -n "ProxyMisc.list" "$CONVERSION_INI" | head -1 | cut -d: -f1)
    
    if [[ -n "$appleai_line" && -n "$apple_line" ]]; then
        if [[ "$appleai_line" -lt "$apple_line" ]]; then
            log_pass "AppleAI.list (line $appleai_line) precedes Apple.list (line $apple_line)"
        else
            log_fail "AppleAI.list must come BEFORE Apple.list for proper precedence"
        fi
    else
        log_fail "Could not find AppleAI.list or Apple.list in Conversion.ini"
    fi
    
    if [[ -n "$appleai_line" && -n "$cloudflare_line" ]]; then
        if [[ "$appleai_line" -lt "$cloudflare_line" ]]; then
            log_pass "AppleAI.list (line $appleai_line) precedes CloudflareProxy.list (line $cloudflare_line)"
        else
            log_warn "AppleAI.list should come before CloudflareProxy.list"
        fi
    fi
    
    if [[ -n "$appleai_line" && -n "$proxmisc_line" ]]; then
        if [[ "$appleai_line" -lt "$proxmisc_line" ]]; then
            log_pass "AppleAI.list (line $appleai_line) precedes ProxyMisc.list (line $proxmisc_line)"
        else
            log_warn "AppleAI.list should come before ProxyMisc.list"
        fi
    fi
}

check_proxy_group() {
    log_info "Checking Siri/AI proxy group configuration..."
    
    if grep -q "Siri/AI" "$CONVERSION_INI"; then
        log_pass "Siri/AI proxy group exists"
        
        if grep "Siri/AI" "$CONVERSION_INI" | grep -q "🇺🇸 美国节点"; then
            log_pass "Siri/AI group includes USA nodes"
        else
            log_warn "Siri/AI group should include USA nodes for optimal AI access"
        fi
        
        if grep "Siri/AI" "$CONVERSION_INI" | grep -q "DIRECT"; then
            log_pass "Siri/AI group has DIRECT fallback"
        else
            log_warn "Siri/AI group should have DIRECT fallback option"
        fi
    else
        log_fail "Siri/AI proxy group not found in Conversion.ini"
    fi
}

check_no_duplicate_rules() {
    log_info "Checking for duplicate domain entries across lists..."
    
    local appleai_domains=$(grep -E "^DOMAIN," "$LIST_DIR/AppleAI.list" 2>/dev/null | cut -d, -f2 | sort -u)
    
    for domain in $appleai_domains; do
        local cloudflare_match=$(grep -l "DOMAIN.*$domain" "$LIST_DIR/CloudflareProxy.list" 2>/dev/null || true)
        if [[ -n "$cloudflare_match" ]]; then
            log_warn "Domain $domain exists in both AppleAI.list and CloudflareProxy.list"
        fi
        
        local proxmisc_match=$(grep "DOMAIN,$domain" "$LIST_DIR/ProxyMisc.list" 2>/dev/null || true)
        if [[ -n "$proxmisc_match" ]]; then
            log_warn "Domain $domain exists in both AppleAI.list and ProxyMisc.list"
        fi
    done
}

main() {
    echo "========================================"
    echo "Clash Rule Validation"
    echo "========================================"
    echo ""
    
    log_info "Validating rule syntax in all .list files..."
    for file in "$LIST_DIR"/*.list; do
        validate_rule_syntax "$file"
    done
    echo ""
    
    check_appleai_coverage
    echo ""
    
    check_precedence
    echo ""
    
    check_proxy_group
    echo ""
    
    check_no_duplicate_rules
    echo ""
    
    echo "========================================"
    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}Validation FAILED: $ERRORS errors, $WARNINGS warnings${NC}"
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Validation PASSED with $WARNINGS warnings${NC}"
        exit 0
    else
        echo -e "${GREEN}Validation PASSED: All checks passed${NC}"
        exit 0
    fi
}

main "$@"
