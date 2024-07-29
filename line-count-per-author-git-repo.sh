#!/bin/bash

# Get a list of all authors (using email to ensure uniqueness)
authors=$(git log --format='%aN <%aE>' | sort -u)

# Initialize an output file
output_file="author_changes_summary.txt"
echo "Summary of Changes per Author:" > $output_file

# Loop through each author and collect their changes
for author in $authors; do
    
    if [[ "$author" != *"<@>"* ]]; then
        echo "Skipping author: $author"
        continue
    fi

    echo "Processing author: $author"

    # Initialize counters
    insertions=0
    deletions=0

    # Get all commits by the author
    commits=$(git log --author="$author" --format='%H')

    for commit in $commits; do
        # Get the diff stats for the commit and parse insertions and deletions
        stats=$(git show --shortstat $commit)
        commit_insertions=$(echo "$stats" | grep "insertion" | awk '{print $4}')
        commit_deletions=$(echo "$stats" | grep "deletion" | awk '{print $6}')

        # Default to 0 if insertions or deletions are empty
        commit_insertions=${commit_insertions:-0}
        commit_deletions=${commit_deletions:-0}

        # Sum up the changes
        insertions=$((insertions + commit_insertions))
        deletions=$((deletions + commit_deletions))
    done

    # Output the results to the file
    echo "Author: $author" >> $output_file
    echo "Total insertions: $insertions" >> $output_file
    echo "Total deletions: $deletions" >> $output_file
    echo "----------------------" >> $output_file
done

echo "Summary of changes per author has been saved to $output_file"