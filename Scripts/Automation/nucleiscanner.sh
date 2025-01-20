#!/bin/bash

# Rename and move nucleiscanner.sh file to /usr/bin/nucleiscanner
sudo mv nucleiscanner.sh /usr/local/bin/ns

# Make the NucleiScanner file executable
sudo chmod +x /usr/local/bin/ns

echo "NucleiScanner has been installed successfully! Now Enter the command 'ns' to run the tool."
