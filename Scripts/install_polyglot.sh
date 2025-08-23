#!/bin/bash
# Installation script for Polyglot File Creator

echo "Installing Polyglot File Creator..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

# Create virtual environment
python3 -m venv polyglot_env

# Activate virtual environment
source polyglot_env/bin/activate

# Install dependencies
pip install python-magic

# On Linux, check if libmagic is installed
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! dpkg -l | grep -q libmagic1; then
        echo "Installing system dependencies..."
        sudo apt-get update
        sudo apt-get install -y libmagic-dev
    fi
fi

# Make the main script executable
chmod +x polyglot.py

# Create symlink for easy access
ln -sf $(pwd)/polyglot_cli.py /usr/local/bin/polyglot || \
echo "Could not create symlink, you can run: ./polyglot_cli.py"

echo "Installation complete!"
echo "Run: ./polyglot_cli.py --help for usage information"