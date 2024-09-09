#!/bin/bash

# Define the search directory (Anonymized)
SEARCH_DIR="/path/to/search/directory"

# Define the backup directory (Anonymized)
BACKUP_DIR="/path/to/backup/directory"

# Define the log file
LOG_FILE="log_file_incompatible_linux.txt"

# Remove previous log file if it exists
if [ -f "$LOG_FILE" ]; then
  rm "$LOG_FILE"
fi

# Create the backup folder if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
fi

# Define the list of characters not compatible with Linux (ext4)
INVALID_CHARS='[:/\:*?"<>|]'

# Search for files with incompatible characters in the filenames
echo "Searching for files with incompatible characters in $SEARCH_DIR"
find "$SEARCH_DIR" -type f -print0 | while IFS= read -r -d '' file; do
  # Extract only the filename without the path
  filename=$(basename "$file")

  # Check if the filename contains invalid characters
  if [[ "$filename" =~ $INVALID_CHARS ]]; then
    echo "$file" >> "$LOG_FILE"

    # Copy the file to the backup directory while maintaining the structure
    backup_path="$BACKUP_DIR/${file#$SEARCH_DIR/}"
    backup_dir=$(dirname "$backup_path")

    # Create the destination directory if it doesn't exist
    mkdir -p "$backup_dir"

    # Copy the file
    cp "$file" "$backup_path"

    # Create a new filename replacing invalid characters with "-"
    new_filename=$(echo "$filename" | sed 's/[:/\:*?"<>|]/-/g')

    # Construct the new complete path for the source file
    new_filepath="$(dirname "$file")/$new_filename"

    # Rename the source file with the new name
    mv "$file" "$new_filepath"

    echo "File renamed: $file -> $new_filepath"
  fi
done

# Print the search results
if [ -s "$LOG_FILE" ]; then
  echo "Files found, copied, and renamed. See the log file $LOG_FILE for details."
else
  echo "No files with incompatible characters found."
fi
