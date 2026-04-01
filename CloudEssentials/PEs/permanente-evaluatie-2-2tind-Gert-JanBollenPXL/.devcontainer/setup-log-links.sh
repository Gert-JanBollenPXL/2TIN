#!/bin/bash
# filepath: c:\Users\20003125\workspace\template_codespaces\.devcontainer\setup-log-links.sh
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$script_dir/.." && pwd)"
REPO_LOGS_DIR="$REPO_ROOT/.logs"
mkdir -p "$REPO_LOGS_DIR"

# Install pre-commit hook
HOOKS_DIR="$REPO_ROOT/.git/hooks"
mkdir -p "$HOOKS_DIR"
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_LOGS_DIR="$REPO_ROOT/.logs"
mkdir -p "$REPO_LOGS_DIR"

remoteagent_log=$(find "$HOME/.vscode-remote/data/logs" -type f -name "remoteagent.log" 2>/dev/null | head -n1)

if [ -n "$remoteagent_log" ]; then
    cp "$remoteagent_log" "$REPO_LOGS_DIR/remoteagent.log"
    git add "$REPO_LOGS_DIR/remoteagent.log"
fi

copilot_log=$(find "$HOME/.vscode-remote/data/logs" -type f -name "GitHub Copilot Chat.log" 2>/dev/null | head -n1)

if [ -n "$copilot_log" ]; then
    cp "$copilot_log" "$REPO_LOGS_DIR/GitHub Copilot Chat.log"
    git add "$REPO_LOGS_DIR/GitHub Copilot Chat.log"
fi

AUDIT_FILE="$REPO_ROOT/audit.md"

echo "# Examen Audit Report" > "$AUDIT_FILE"
echo "" >> "$AUDIT_FILE"

ALLOWED_EXTENSIONS="\
github.github-vscode-theme
github.vscode-pull-request-github
github.codespaces
amazonwebservices.aws-toolkit-vscode
"
            
# Check 1: GitHub Copilot Chat log
echo "## Copilot Gebruik" >> "$AUDIT_FILE"
if [ -f "$REPO_ROOT/.logs/GitHub Copilot Chat.log" ]; then
    echo "⚠️ **WAARSCHUWING:** GitHub Copilot Chat log gevonden in .logs/GitHub Copilot Chat.log" >> "$AUDIT_FILE"
    echo "" >> "$AUDIT_FILE"
    echo "Dit kan duiden op gebruik van AI-assistentie tijdens het examen." >> "$AUDIT_FILE"
else
    echo "✅ Geen GitHub Copilot Chat log gevonden." >> "$AUDIT_FILE"
fi
echo "" >> "$AUDIT_FILE"

# Check 2: Remote agent log anomalies
echo "## Remote Agent Analyse" >> "$AUDIT_FILE"
if [ -f "$REPO_ROOT/.logs/remoteagent.log" ]; then
    echo "Remote agent log gevonden. Controleren op anomalieën..." >> "$AUDIT_FILE"
    echo "" >> "$AUDIT_FILE"
    
    RAW_EXT_INSTALLS=$(grep -i "installing extension\|extension.*installed" "$REPO_ROOT/.logs/remoteagent.log" 2>/dev/null | grep -v "pixel-lint" || echo "")
    EXTENSION_INSTALLS=$(echo "$RAW_EXT_INSTALLS" | grep -ivFf <(echo "$ALLOWED_EXTENSIONS") || echo "")
    
    if [ -n "$EXTENSION_INSTALLS" ]; then
        INSTALL_COUNT=$(echo "$EXTENSION_INSTALLS" | wc -l)
        if [ "$INSTALL_COUNT" -gt 5 ]; then
            echo "⚠️ **WAARSCHUWING:** Verdachte extensie-activiteit gedetecteerd ($INSTALL_COUNT events):" >> "$AUDIT_FILE"
            echo '```' >> "$AUDIT_FILE"
            echo "$EXTENSION_INSTALLS" | tail -20 >> "$AUDIT_FILE"
            echo '```' >> "$AUDIT_FILE"
            echo "" >> "$AUDIT_FILE"
        fi
    fi
    
    SUSPICIOUS=$(grep -iE "copilot|tabnine|codeium|chatgpt|ai.*assist" "$REPO_ROOT/.logs/remoteagent.log" 2>/dev/null | grep -v "disabled\|removed" || echo "")
    if [ -n "$SUSPICIOUS" ]; then
        echo "⚠️ **WAARSCHUWING:** Verdachte AI-tool keywords gevonden:" >> "$AUDIT_FILE"
        echo '```' >> "$AUDIT_FILE"
        echo "$SUSPICIOUS" | head -20 >> "$AUDIT_FILE"
        echo '```' >> "$AUDIT_FILE"
        echo "" >> "$AUDIT_FILE"
    fi
    
    if [ -z "$EXTENSION_INSTALLS" ] && [ -z "$SUSPICIOUS" ]; then
        echo "✅ Geen verdachte activiteiten gevonden in remote agent log." >> "$AUDIT_FILE"
    fi
else
    echo "⚠️ Geen remote agent log gevonden." >> "$AUDIT_FILE"
fi
echo "" >> "$AUDIT_FILE"

# Check 3: Git log for "extension"
echo "## Git Commit Analyse" >> "$AUDIT_FILE"
EXTENSION_COMMITS=$(git log --all --grep="extension" -i --oneline 2>/dev/null || echo "")
if [ -n "$EXTENSION_COMMITS" ]; then
    echo "⚠️ **WAARSCHUWING:** Commits gevonden met het woord 'extension':" >> "$AUDIT_FILE"
    echo '```' >> "$AUDIT_FILE"
    echo "$EXTENSION_COMMITS" >> "$AUDIT_FILE"
    echo '```' >> "$AUDIT_FILE"
else
    echo "✅ Geen commits met 'extension' gevonden." >> "$AUDIT_FILE"
fi
echo "" >> "$AUDIT_FILE"

# Check 4: Lines added per commit
echo "## Code Toevoegingen per Commit" >> "$AUDIT_FILE"
echo "" >> "$AUDIT_FILE"
echo "Overzicht van toegevoegde regels (detectie van bulk AI-gegenereerde code):" >> "$AUDIT_FILE"
echo "" >> "$AUDIT_FILE"
echo "| Commit | Regels toegevoegd | Bericht |" >> "$AUDIT_FILE"
echo "|--------|-------------------|---------|" >> "$AUDIT_FILE"

git log --all --pretty=format:"%h|%s" --numstat -- ':!.logs' | awk '
BEGIN { hash=""; msg=""; added=0; skip=0 }
/^[0-9a-f]+\|/ {
    # Print previous commit unless it was an initial commit
    if (hash != "" && skip == 0) {
        if (added > 100) {
            printf "| 🔴 **%s** | **%d** | %s |\n", hash, added, msg
        } else if (added > 50) {
            printf "| 🟠 **%s** | **%d** | %s |\n", hash, added, msg
        } else {
            printf "| %s | %d | %s |\n", hash, added, msg
        }
    }

    split($0, a, "|")
    hash=a[1]
    msg=a[2]

    # Detecteer initial commit (case-insensitive)
    skip = (tolower(msg) ~ /initial commit/) ? 1 : 0

    added=0
}
# Numstat regels
/^[0-9]+\t[0-9]+\t/ {
    if (skip == 0) added += $1
}
END {
    if (hash != "" && skip == 0) {
        if (added > 100) {
            printf "| 🔴 **%s** | **%d** | %s |\n", hash, added, msg
        } else if (added > 50) {
            printf "| 🟠 **%s** | **%d** | %s |\n", hash, added, msg
        } else {
            printf "| %s | %d | %s |\n", hash, added, msg
        }
    }
}
' >> "$AUDIT_FILE"

echo "" >> "$AUDIT_FILE"

# Summary statistics
TOTAL_COMMITS=$(git log --all --pretty=format:"%s" | grep -iv "initial commit" | wc -l)

TOTAL_ADDED=$(
    git log --all --numstat --pretty=format:"%s" |
    awk '
        /^[0-9]+\t[0-9]+\t/ && skip==0 { total+=$1 }
        /^[^0-9]/ {
            msg=$0
            skip = tolower(msg) ~ /initial commit/ ? 1 : 0
        }
        END { print total+0 }
    '
)

if [ "$TOTAL_COMMITS" -gt 0 ]; then
    AVG_ADDED=$((TOTAL_ADDED / TOTAL_COMMITS))
else
    AVG_ADDED=0
fi


echo "## Statistieken" >> "$AUDIT_FILE"
echo "" >> "$AUDIT_FILE"
echo "- **Totaal commits:** $TOTAL_COMMITS" >> "$AUDIT_FILE"
echo "- **Totaal regels toegevoegd:** $TOTAL_ADDED" >> "$AUDIT_FILE"
echo "- **Gemiddeld per commit:** $AVG_ADDED regels" >> "$AUDIT_FILE"
echo "" >> "$AUDIT_FILE"

# Flag suspicious patterns
LARGE_COMMITS=$(
    git log --all --pretty=format:"%h|%s" --numstat |
    awk '
        BEGIN { hash=""; skip=0 }
        /^[0-9a-f]+\|/ {
            # Nieuw commit: check of initial commit
            split($0, a, "|")
            msg = tolower(a[2])
            skip = (msg ~ /initial commit/) ? 1 : 0
        }
        /^[0-9]+\t[0-9]+\t/ {
            if (skip == 0 && $1 > 100) count++
        }
        END { print count+0 }
    '
)
if [ "$LARGE_COMMITS" -gt 0 ]; then
    echo "⚠️ **WAARSCHUWING:** $LARGE_COMMITS commit(s) met meer dan 100 regels toegevoegd (mogelijk AI-gegenereerd)" >> "$AUDIT_FILE"
fi

echo "" >> "$AUDIT_FILE"
echo "---" >> "$AUDIT_FILE"
echo "*Audit gegenereerd door geautomatiseerd systeem*" >> "$AUDIT_FILE"


git add "$AUDIT_FILE"
EOF
chmod +x "$HOOKS_DIR/pre-commit"
echo "Git pre-commit hook installed"
