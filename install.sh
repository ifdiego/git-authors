#!/usr/bin/env bash

install_git_alias() {
    DIST="${HOME}/.config/git-helpers"
    mkdir -p "$DIST"

    cat > "${DIST}/authors" << 'INNER_EOF'
#!/bin/bash
WIDTH=40

git log --pretty=format:'%an|%ae|%ad' --date=format:'%Y-%m' \
| sort \
| awk -F"|" -v WIDTH=$WIDTH '
{
    author=$1 " <" $2 ">"
    month=$3
    total[author]++
    monthly[author "|" month]++
}

END {
    for (a in total) {
        print total[a] "|" a
    }
}
' | sort -nr | while IFS="|" read total author
do
    echo ""
    echo "$author"
    echo "Total: $total commits"
    echo ""

    git log --pretty=format:'%ad' --date=format:'%Y-%m' --author="$author" \
    | sort | uniq -c \
    | awk -v WIDTH=$WIDTH -v total="$total" '
    {
        month=$2
        count=$1

        ratio = count / total
        bar_size = int(ratio * WIDTH)
        if (bar_size < 1) bar_size = 1

        bar=""
        for (i=0; i<bar_size; i++) {
            bar = bar "█"
        }

        printf "%s │ %4d │ %-*s %5.1f%%\n", month, count, WIDTH, bar, ratio*100
    }
    '
    echo "---------------------------------------------"
done
INNER_EOF

    chmod +x "${DIST}/authors"
    git config --global alias.authors "!bash ${DIST}/authors"
    echo "Git authors alias has been installed successfully!"
    echo "You can now use 'git authors' to view commit statistics by authors."
}

install_git_alias
