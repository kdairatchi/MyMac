# Red Team Knowledge Base (MITRE ATT&CK–Mapped)

Purpose-built, ATT&CK-mapped knowledge base intended for authorized red team exercises and lab training. It consolidates methodology, curated tools, and cheatsheets organized by MITRE ATT&CK tactics for quick operator access and blue-team friendly references.

Important
- For authorized use only: training labs or engagements with explicit written permission.
- Educational and defensive goals: structure emphasizes detection notes and references.
- Many operator runbooks are intentionally high-level. Provide your authorization context to enable step-by-step additions.

## Repository structure (mapped to MITRE ATT&CK)
- Reconnaissance/
- Resource_Development/
- Initial_Access/
- Execution/
- Persistence/
- Privilege_Escalation/
- Defense_Evasion/
- Credential_Access/
- Discovery/
- Lateral_Movement/
- Collection/
- Command_and_Control/
- Exfiltration/
- Impact/
- Tools/ (recognized, open-source tools with links and concise usage)
- Documentation/ (methodology, OPSEC, references)
- Cheatsheets/ (general/neutral quick refs; tactic-specific moved into tactic folders)

## How to use
1) Start in Documentation/Methodology.md for high-level phases, OPSEC, and rules of engagement.
2) Navigate to a tactic folder based on your current phase; each folder has focused guides.
3) Use Tools/ as an index to official projects and neutral usage notes.
4) Keep detection in mind; where possible, entries reference detections/hunts.

## Contributing
- Prefer open-source, well-maintained, and widely recognized tools.
- Add references and version/date notes for accuracy.
- Keep offensive specifics behind an authorization gate; default to lab-friendly examples and defenses.

## References (living list)
- MITRE ATT&CK: https://attack.mitre.org/
- GTFOBins: https://gtfobins.github.io/
- LOLBAS: https://lolbas-project.github.io/
- HackTricks: https://book.hacktricks.xyz/
- PayloadsAllTheThings: https://github.com/swisskyrepo/PayloadsAllTheThings

If you need a specific tool/runbook expanded, share your authorization scope and I will add it accordingly.
