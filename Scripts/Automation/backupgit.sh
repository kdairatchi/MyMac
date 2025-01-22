#!/bin/bash
tar -czf backup-$(date +%F).tar.gz BugBounty
git add -A
git commit -m "Backup BugBounty before clean-up"
