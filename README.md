# env-sanitizer

This repository provides a custom pre-commit hook that identifies `.env*` files and generates `.example` versions with sensitive data removed, while preserving port numbers.

## How It Works

1. The script searches for all `.env*` files (excluding `.example` files).
2. It creates an `.example` version of each `.env` file.
3. Sensitive information is removed, except for port numbers.
4. The original `.env` file is added to `.gitignore` if it's not already present.
5. The `.env.example` files are automatically staged for commit.

## Installation

1. Add this repository to your project’s `.pre-commit-config.yaml`:

    ```yaml
    repos:
      - repo: https://github.com/nicballarini/env-sanitizer
        rev: v1.0.1
        hooks:
          - id: sanitize-env-files
    ```

2. Install pre-commit in your project:

    ```bash
    pre-commit install
    ```

3. Now, every time you commit changes, the `.env` files will be sanitized and `.example` copies will be generated automatically.

## License

MIT License
