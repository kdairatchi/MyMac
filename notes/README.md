# Security Research & Bug Bounty Notes

## Overview
This repository contains comprehensive security research notes, bug bounty methodologies, and penetration testing resources organized by category for easy reference.

## 📁 File Structure

### Core Categories
- **[reconnaissance.md](reconnaissance.md)** - Subdomain enumeration, port scanning, DNS recon
- **[web-vulnerabilities.md](web-vulnerabilities.md)** - XSS, SQLi, CORS, SSRF, LFI techniques
- **[google-dorking.md](google-dorking.md)** - Search queries for finding exposed information
- **[bug-bounty-workflows.md](bug-bounty-workflows.md)** - One-liners and automation scripts
- **[tools-and-commands.md](tools-and-commands.md)** - Tool usage, installation, and command references
- **[payloads-and-bypasses.md](payloads-and-bypasses.md)** - Exploit payloads and WAF bypasses
- **[methodologies.md](methodologies.md)** - Structured testing approaches and frameworks

### Quick Reference
- **[quick-commands.md](quick-commands.md)** - Most commonly used commands
- **[cheat-sheets.md](cheat-sheets.md)** - Quick reference guides
- **[resources.md](resources.md)** - External links, platforms, and references

## 🚀 Quick Start

### Essential One-Liners
```bash
# Subdomain enumeration
subfinder -d target.com -silent | httpx -silent | tee subdomains.txt

# XSS testing
cat urls.txt | gau | gf xss | qsreplace '"><img src=x onerror=alert(1)>' | freq

# SQL injection detection
cat urls.txt | gau | gf sqli | qsreplace "'" | httpx -silent
```

### Common Workflows
1. **Reconnaissance** → `reconnaissance.md`
2. **Vulnerability Testing** → `web-vulnerabilities.md` 
3. **Payload Development** → `payloads-and-bypasses.md`
4. **Automation** → `bug-bounty-workflows.md`

## 📚 Learning Path

1. Start with **[methodologies.md](methodologies.md)** for structured approach
2. Learn tools from **[tools-and-commands.md](tools-and-commands.md)**
3. Practice with **[quick-commands.md](quick-commands.md)**
4. Advanced techniques in **[payloads-and-bypasses.md](payloads-and-bypasses.md)**

## 🎯 Target Categories

### Bug Bounty Programs
- HackerOne, Bugcrowd, Intigriti
- YesWeHack, HackenProof, Federacy
- Private programs and VDP

### Testing Environments
- Web applications
- APIs and microservices  
- Mobile applications
- Cloud infrastructure

## ⚠️ Disclaimer
These notes are for authorized security testing only. Always ensure proper authorization before testing any systems.

---
*Last updated: $(date)*
*Organized by: Doctor K & Claude*