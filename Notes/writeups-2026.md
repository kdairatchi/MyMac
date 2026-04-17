# writeups-2026

## Writeups

**CVE-2026-22679: Unauthenticated RCE in Weaver E-cology** · `CVE-2026-22679` · critical — Unauthenticated RCE in Weaver E-cology enterprise software; full system compromise with no auth required. Hunt: look for exposed e-cology login pages, nuclei or manual POST to `/weaveroa/`. [Medium writeup](https://medium.com/@keraattin/cve-2026-22679-unauthenticated-rce-in-weaver-e-cology-7fa97c1e904b)

---

**FortiClient EMS Zero-Day CVE-2026-35616 Exploited** · `CVE-2026-35616` · critical — Second zero-day in FortiClient EMS in one week, actively exploited ITW before patch available; chained after CVE-2026-21643. Hunt: shodan for FortiClient EMS exposed management ports, check patch status. [Medium writeup](https://medium.com/@alidak/forticlient-ems-gets-a-second-zero-day-in-one-week-cve-2026-35616-is-already-being-exploited-469960f238cb)

---

**HTTP Request Smuggling: From Basics to Real Exploitation** · `#smuggling` · high — Exploiting CL.TE / TE.CL discrepancies between proxy and backend to bypass auth/cache/ACLs; PortSwigger method via Burp Repeater. Hunt: probe Transfer-Encoding header handling on any dual-server architecture. [Medium writeup](https://medium.com/@Aman-Gupta.cse/http-request-smuggling-from-basics-to-real-exploitation-in-burp-repeater-144e145459ac) · [PortSwigger research](https://portswigger.net/research/how-to-distinguish-http-pipelining-from-request-smuggling)

---

**Technical Proof of Decryption and Root Access** · `#privesc #deserialization` · critical — Insecure object deserialization during decryption path leads to root. Hunt: identify decryption endpoints that accept serialized objects, chain with known gadgets. [Medium writeup](https://medium.com/@fazul1324/technical-proof-of-decryption-and-root-access-8830c5b7a909)

---

**NTLM Relay: The Attack That Turns Your Network Against Itself** · `#auth-bypass #windows` · high — Captures NTLM auth from one service, relays to another to impersonate users without cracking; leads to domain compromise if positioned correctly. Hunt: pass on internal engagements with Responder/ntlmrelayx; low value for external BB. [Medium writeup](https://medium.com/@garrettstimpson/ntlm-relay-the-attack-that-turns-your-network-against-itself-6eeba27c341b)

---

**Flutter iOS SSL Pinning Bypass** · `#mobile` · medium — Bypass SSL pinning in Flutter iOS apps by hooking into native iOS networking stack (not Dart layer) via Frida/Objection; prerequisite for API analysis on Flutter targets. Hunt: any Flutter app in scope — check `libflutter.so` / Dart network stack. [Medium writeup](https://medium.com/@anuragbhoir07/flutter-based-ios-application-sslpinning-bypass-37b1c84332fa)

---

**Kerberoasting: Why Your AD Service Accounts Are Already Toast** · `#auth-bypass #privesc` · high — Any authenticated domain user can request TGS tickets for SPN accounts and crack them offline; weak passwords = domain compromise. Hunt: pass on internal AD engagements; out of scope for most external BB. [Medium writeup](https://medium.com/@garrettstimpson/kerberoasting-why-your-ad-service-accounts-are-already-toast-977a836de9d2)

---

**From Critical to Low: 6 Vulnerabilities That Exposed a Web App** · `#web #bug-bounty` · mixed — Beginner-friendly walkthrough of chaining low-to-critical findings across a single target; practical enumeration and escalation approach. Hunt: read for methodology patterns. [Medium writeup](https://medium.com/@seafeldeenwael/from-critical-to-low-6-vulnerabilities-that-exposed-a-web-application-c5fcf5130adf)

---

**Evading an AI SOC with Sable (Vulnetic)** · `#llm #prompt-injection` · info — Sable framework executes adversarial attacks/prompt injection against AI-driven SOC triage pipelines; evasion before detection triggers. Hunt: red team use only; test org's AI SOC tooling for injection paths. [Medium writeup](https://medium.com/@Vulnetic-CEO/evading-an-ai-soc-with-sable-from-vulnetic-fad12376995c)

---

**WordPress XML-RPC Admin Path Disclosure** · `#web #data-exfil` · info — Malformed requests to `xmlrpc.php` trigger verbose errors revealing absolute filesystem path; useful prerequisite for LFI. Hunt: `nuclei -t wordpress/xmlrpc-*` or manual POST to `/xmlrpc.php`. [Medium writeup](https://vanshrathorebughunter.medium.com/hunting-for-xmlrpc-uncovering-wordpress-xml-rpc-admin-path-disclosures-b5707b8f5424)

---

**Inside GPT-5.4-Cyber: OpenAI's Defensive LLM** · `#llm` · info — Speculative architecture article on a hypothetical security-tuned LLM for threat detection and vuln analysis; arms race framing. Hunt: pass. [Medium writeup](https://medium.com/@psyduck90/inside-gpt-5-4-cyber-openais-new-secret-weapon-for-security-defenders-845daa714cdd)

---

**Xalgorix: AI Pentesting Agent Setup** · `#llm #web` · info — Open-source AI agent for autonomous vuln discovery; setup guide for self-hosted pentesting automation. Hunt: evaluate for recon pipeline integration. [InfoSec writeups](https://infosecwriteups.com/the-complete-guide-to-setting-up-xalgorix-the-most-powerful-open-source-ai-pentesting-agent-befc9b721b9e)
