#!/bin/sh
# Puts the checks in front of every commit (the hooks folder of git is not part of the repository).
cd "$(dirname "$0")/.." || exit 1
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/sh
sh tools/check_all.sh
EOF
cat > .git/hooks/commit-msg <<'EOF'
#!/bin/sh
if grep -qiE 'co-authored-by: *claude|generated with' "$1"; then
    echo "Commit message carries an AI note - remove it."
    exit 1
fi
EOF
echo "Hooks installed."
