#!/bin/sh

# Function to process .env files
process_env_file() {
  env_file="$1"
  example_file="$env_file.example"

  # Copy the .env file to .env.example
  cp "$env_file" "$example_file"

  # Check OS type and adjust sed syntax accordingly
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Use sed with an empty '' argument for in-place editing
    sed -i '' '/^[^#]*port=/! s/=.*/=/' "$example_file"
    sed -i '' '1s/^/# generated automatically by .git\/hooks\/pre-commit\n/' "$example_file"
  else
    # Linux: Use sed without an argument for in-place editing
    sed -i '/^[^#]*port=/! s/=.*/=/' "$example_file"
    sed -i '1s/^/# generated automatically by .git\/hooks\/pre-commit\n/' "$example_file"
  fi

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
