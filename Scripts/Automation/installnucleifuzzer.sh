#!/bin/bash

# Rename and move NucleiFuzzer.sh file to /usr/bin/nf
sudo cp nucleifuzzer.sh /usr/local/bin/nf

# Make the NucleiFuzzer file executable
sudo chmod u+x /usr/local/bin/nf

echo "NucleiFuzzer has been installed successfully! Now Enter the command 'nf' to run the tool."
