#!/bin/bash
# Lint script for Linux-style commit messages

commit_msg_file="$1"

if [ -z "$commit_msg_file" ]; then
    echo "Usage: $0 <commit-message-file>"
    exit 1
fi

commit_msg=$(cat "$commit_msg_file")
errors=0

# Get first line (subject)
subject=$(echo "$commit_msg" | head -n 1)

# Check subject line format (component: subject)
if ! echo "$subject" | grep -qE '^[a-z0-9-]+: .*'; then
    echo "❌ Subject line must follow format: <component>: <subject>"
    echo "   Example: 'driver: fix NULL pointer dereference'"
    errors=$((errors + 1))
fi

# Check subject length (max 70 chars for component: subject)
if [ ${#subject} -gt 70 ]; then
    echo "❌ Subject line too long (${#subject} chars, max 70)"
    errors=$((errors + 1))
fi

# Check for period at end of subject
if echo "$subject" | grep -q '\.$'; then
    echo "❌ Subject line should not end with a period"
    errors=$((errors + 1))
fi

# Check for imperative mood in subject (basic heuristic)
first_word=$(echo "$subject" | sed -E 's/^[a-z0-9-]+: //' | cut -d' ' -f1)
if echo "$first_word" | grep -qiE '^(added|adding|fixes|fixed|fixing|changed|changing|updates|updating|removed|removing)$'; then
    echo "⚠️  Subject should use imperative mood (use '$first_word' not '${first_word}s/ing')"
fi

# Check body line length (skip first line and trailers)
body=$(echo "$commit_msg" | tail -n +2)
line_num=2
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Skip trailer lines (anything matching Trailer: value format at the end)
    if echo "$line" | grep -qE '^[A-Z][A-Za-z-]+: '; then
        continue
    fi

    # Check line length
    if [ ${#line} -gt 72 ]; then
        echo "❌ Line $line_num too long (${#line} chars, max 72): ${line:0:50}..."
        errors=$((errors + 1))
    fi

    line_num=$((line_num + 1))
done <<< "$body"

if [ $errors -eq 0 ]; then
    echo "✅ Commit message passes Linux-style linting"
    exit 0
else
    echo "❌ Found $errors error(s)"
    exit 1
fi
