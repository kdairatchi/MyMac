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

## 2026-04-17

### Bypass URL Access Control via X-Original-URL
- **Tags:** `#auth-bypass` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://medium.com/@The4v1/%EF%B8%8F-10-url-based-access-control-can-be-circumvented-x-original-url-fc4aaf569b55?source=rss------bug_bounty-5) · [2](https://medium.com/@The4v1/%EF%B8%8F-11-method-based-access-control-can-be-circumvented-d836d99578b0) · [3](https://medium.com/@The4v1/%EF%B8%8F-13-referer-based-access-control-953f079e07de) · [4](https://osintteam.blog/the-identity-trap-bypassing-modern-perimeters-via-cross-platform-correlation-f188221431d1?source=rss------infosec-5)

- **Trick:** Sending requests to an allowed endpoint while overriding the path via the `X-Original-URL` header to trick the backend into processing a restricted path.
- **Why it matters:** Security controls (WAFs or middleware) often inspect the request line for path restrictions; this header bypass shifts the routing logic downstream, potentially allowing unauthorized access to admin panels or user data.
- **Rating:** variant

---
*Clustered 4 sources for this item.*

### Worker Factory Start Routine Injection
- **Tags:** `#rce` `#web`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@s12deff/worker-factory-start-routine-injection-742c26214616?source=rss------pentesting-5)

- **Trick:** Manipulating the initialization parameters of a worker factory to inject arbitrary code or commands into the startup routine of a spawned worker process.
- **Why it matters:** This technique allows an attacker to gain execution within a separate thread or process context, potentially bypassing sandbox restrictions or main-thread monitoring.
- **Rating:** novel

---
### From Image Upload to Admin Panel: SSRF Leads to PII Disclosure
- **Tags:** `#ssrf` `#idor` `#auth-bypass` `#data-exfil`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 15.75 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://medium.com/@sagardhoot56/from-image-upload-to-admin-panel-how-a-simple-ssrf-led-to-massive-pii-disclosure-and-earned-738e3be3708c?source=rss------infosec-5)

- **Trick:** An SSRF vulnerability in an image upload function allowed attackers to access internal admin panels and exfiltrate sensitive PII.
- **Why it matters:** This demonstrates how seemingly minor features can lead to critical data breaches, highlighting the importance of input validation on all user inputs.
- **Rating:** chain-worthy

---
### Race Condition in Poll Systems
- **Tags:** `#race-condition`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 15.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@jonathangeorge1412/race-condition-exploitation-in-poll-systems-how-i-manipulated-votes-with-a-single-account-093a61acd24f)

- **Trick:** Exploiting a time-of-check to time-of-use (TOCTOU) gap by sending concurrent requests to a voting endpoint, allowing multiple votes to be recorded before the server enforces the "one vote per user" restriction.
- **Why it matters:** Integrity flaws in polling and reputation systems can allow attackers to manipulate public opinion, rig contests, or farm reward points without detection, often bypassing standard front-end validation.
- **Rating:** variant

---
### When AI Becomes the Attacker: Inside a 195 Million Record Cyber Breach
- **Tags:** `#data-exfil` `#llm`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://medium.com/@sharanraju10/when-ai-becomes-the-attacker-inside-a-195-million-record-cyber-breach-76548cf5365f)

- **Trick:** Leveraging AI agents or LLM-based automation to discover vulnerabilities and exfiltrate a massive dataset of 195 million records at scale.
- **Why it matters:** Represents a shift toward AI-driven offensive operations where automation enables high-impact breaches without requiring sophisticated manual human operators.
- **Rating:** novel

---
### Multi-step process with no access control on one step
- **Tags:** `#idor` `#auth-bypass`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://medium.com/@The4v1/%EF%B8%8F-12-multi-step-process-with-no-access-control-on-one-step-fad63523cf3e)

- **Trick:** The author bypasses business logic restrictions by identifying an intermediate step in a multi-step workflow that lacks access control checks, allowing unauthorized state manipulation.
- **Why it matters:** Developers often focus authorization on the initialization and finalization of processes, leaving interim API endpoints exposed to IDOR or privilege escalation.
- **Rating:** variant

---
### DockerLabs Writeup — Tokenaso (Spanish)
- **Tags:** `#docker` `#web`
- **Severity:** unknown · **Hunt:** 2/5 · **Score:** 8.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://pyth0nk1d.medium.com/dockerlabs-writeup-tokenaso-spanish-a937f302e258?source=rss------pentesting-5)

- **Trick:** Exploitation of Tokenaso machine, likely involving Docker container escape techniques and web application vulnerabilities.
- **Why it matters:** Demonstrates practical Docker security risks and web exploitation patterns in a controlled environment.
- **Rating:** chain-worthy

---
### Blogger — wpDiscuz File Upload CVE and Vagrant Default Password
- **Tags:** `#rce` `#auth-bypass`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 7.0 · **Status:** patched · **Age:** 30d
- **Sources:** [1](https://medium.com/h7w/blogger-wpdiscuz-file-upload-cve-and-a-vagrant-default-password-that-was-never-changed-offsec-0a0877c7db05)

- **Trick:** Exploiting wpDiscuz file upload vulnerability and accessing a Vagrant instance with unchanged default credentials
- **Why it matters:** Combines a critical RCE vulnerability in a popular WordPress comment plugin with a basic authentication weakness
- **Rating:** chain-worthy

---
### Account Takeover via OAuth Redirect Uri Manipulation
- **Tags:** `#auth-bypass` `#oauth`
- **Severity:** high · **Hunt:** 1/5 · **Score:** 7.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://skysenz.medium.com/account-takeover-via-oauth-redirect-uri-manipulation-5ae02c165fef?source=rss------bug_bounty-5)

- **Trick:** Exploiting improper OAuth redirect URI validation to hijack authorization codes.
- **Why it matters:** Compromises social login functionality, enabling full account takeover of connected services.
- **Rating:** variant

---
### Cross-Site Scripting (XSS) — From Input to Browser Control
- **Tags:** `#xss` `#web`
- **Severity:** medium · **Hunt:** 1/5 · **Score:** 5.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/bug-bounty-hunting-a-comprehensive-guide-in/cross-site-scripting-xss-from-input-to-browser-control-b39a8de952b4)

- **Trick:** Comprehensive guide covering the full lifecycle of XSS, identifying input vectors and analyzing how they lead to browser control.
- **Why it matters:** Solidifies fundamental knowledge of XSS triggers and sinks, which is critical for finding high-impact injection flaws in modern web apps.
- **Rating:** variant

---
### TakeOver-TryHackMe write up
- **Tags:** `#subdomain-takeover`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 4.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@wolfofv/takeover-tryhackme-write-up-e8c672250e19)

- **Trick:** Walkthrough of identifying and exploiting dangling DNS records (likely subdomain takeover) on the TryHackMe platform.
- **Why it matters:** Reinforces methodology for detecting CNAME misconfigurations pointing to deprovisioned cloud resources, a common critical finding in real-world assessments.
- **Rating:** variant

---
### GLITCH — TryHackMe Write-up (Command Injection + Privilege Escalation)
- **Tags:** `#command-injection` `#privesc`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@brmarquess/glitch-try-hack-me-43139c33f97d)

- **Trick:** Walks through exploiting a web input to achieve command injection, then leveraging standard Linux privilege escalation vectors (likely SUID binaries or misconfigured permissions) to gain root access.
- **Why it matters:** Reinforces the fundamental impact of improper input sanitization and the necessity of system hardening post-exploitation.
- **Rating:** variant

---
### AI-Driven Threat Detection Using AWS Security Agent
- **Tags:** `#aws` `#cloud` `#llm`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@umashankarak/ai-driven-threat-detection-using-aws-security-agent-a-framework-for-on-demand-autonomous-31183ed16d86)

- **Trick:** Architectural framework utilizing AWS Security Agent and AI models to perform on-demand, autonomous threat detection.
- **Why it matters:** Demonstrates how to automate real-time security analysis within cloud environments, potentially catching anomalies faster than traditional rule-based systems.
- **Rating:** novel

---
