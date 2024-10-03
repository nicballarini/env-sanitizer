#!/bin/sh

# Function to process .env files
process_env_file() {
  env_file="$1"
  example_file="$env_file.example"

  # Copy the .env file to .env.example
  cp "$env_file" "$example_file"

  # Remove secrets but keep port values
  sed -i '/^[^#]*port=/! s/=.*/=/' "$example_file"

  # Add header note
  sed -i '1s/^/# generated automatically by .git\/hooks\/pre-commit\n/' "$example_file"

  # Add the real .env file to .gitignore if not already present
  if ! grep -q "^$env_file$" .gitignore; then
    echo "$env_file" >> .gitignore
  fi

  # Stage the .env.example file for the commit
  git add "$example_file"
}

# Find all .env files including .env.<environment>, excluding .example files
find . -type f -name ".env*" ! -name "*.example" | while read -r env_file; do
  process_env_file "$env_file"
done
