#!/bin/sh

# Function to process .env files
process_env_file() {
  env_file="$1"
  example_file="${env_file%.example}.EXAMPLE"  # Ensure the copied file ends in .EXAMPLE

  # If an env.*.example (lowercase) exists, rename it to uppercase .EXAMPLE
  if [[ "$env_file" == *".example" ]]; then
    mv "$env_file" "${env_file%.example}.EXAMPLE"
  fi

  # Always proceed with copying the .env file to .EXAMPLE
  cp "$env_file" "$example_file" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "Failed to copy $env_file to $example_file."
    return 0
  fi

  # Check OS type and adjust sed syntax accordingly
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Use sed with an empty '' argument for in-place editing
    sed -i '' '/^[^#]*[Pp][Oo][Rr][Tt]=/! s/=.*/=/' "$example_file"
    sed -i '' '1s/^/# generated automatically by .git\/hooks\/pre-commit\n/' "$example_file"
  else
    # Linux: Use sed without an argument for in-place editing
    sed -i '/^[^#]*[Pp][Oo][Rr][Tt]=/! s/=.*/=/' "$example_file"
    sed -i '1s/^/# generated automatically by .git\/hooks\/pre-commit\n/' "$example_file"
  fi

  # Add the real .env file to .gitignore if not already present
  if ! grep -q "^$env_file$" .gitignore; then
    echo "$env_file" >> .gitignore
  fi

  # Stage the .EXAMPLE file for commit, even if .env file isn't staged
  git add "$example_file"

  # Remove the .env file from staging, so it isn't accidentally committed
  git rm --cached "$env_file"
}

# Find all .env files including .env.<environment>, excluding .EXAMPLE files
find . -type f -name ".env*" ! -name "*.EXAMPLE" | while read -r env_file; do
  process_env_file "$env_file"
done
