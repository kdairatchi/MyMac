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

## 2026-04-19

### SSRF via OpenID dynamic client registration
- **Tags:** `#ssrf` `#oauth`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@The4v1/%EF%B8%8F-02-ssrf-via-openid-dynamic-client-registration-25d0ae1234c1)

- **Trick:** Abuse the OpenID Connect Dynamic Client Registration endpoint by injecting an internal URL (like `http://169.254.169.254`) into the `redirect_uris` field, forcing the Identity Provider to send a validation request to the target.
- **Why it matters:** Identity Providers are often highly trusted hosts; an SSRF here can pivot to internal cloud metadata or restricted internal services that are otherwise inaccessible.
- **Rating:** chain-worthy

---
### Stored XSS via Custom Template Injection — How I Bypassed Cloudflare WAF
- **Tags:** `#xss` `#ssti`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@mostafaabogoda8/stored-xss-via-custom-template-injection-how-i-bypassed-cloudflare-waf-5abdc0d1807b)

- **Trick:** Abused a custom template injection feature to inject stored XSS payloads, utilizing template syntax to bypass Cloudflare WAF rules that typically block standard HTML/JS vectors.
- **Why it matters:** It highlights how feature-specific injection points (like templating engines) can evade generic WAF signatures, requiring security teams to sanitize application logic rather than relying solely on perimeter filters.
- **Rating:** variant

---
### Helium Challenge Batch 2 Write-Up : Menemukan 3 Kerentanan Kritis di Aplikasi Job Portal
- **Tags:** `#web`
- **Severity:** critical · **Hunt:** 2/5 · **Score:** 18.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://medium.com/@subzxd14/helium-challenge-batch-2-write-up-menemukan-3-kerentanan-kritis-di-aplikasi-job-portal-61d461bc73ba?source=rss------pentesting-5) · [2](https://github.com/nomi-sec/PoC-in-GitHub/commit/5d162113ddc09079833b17d363cd479b3bdd726d) · [3](https://infosecwriteups.com/the-bug-hunting-mistake-that-slowed-my-progress-5597222e982d?source=rss------infosec-5) · [4](https://meetcyber.net/why-i-thought-i-found-a-zero-day-the-false-positive-trap-in-bug-bounty-3ec08e86fc99) · [5](https://github.com/nomi-sec/PoC-in-GitHub/commit/eee6ffc597e28b85d2ccbe52c1562ab2d4ef1a84)

- **Trick:** Indonesian pentester discovered 3 critical vulnerabilities in a job portal application during the Helium Challenge.
- **Why it matters:** Demonstrates effective vulnerability discovery techniques in a real-world application, providing valuable insights for penetration testers and bug hunters.
- **Rating:** chain-worthy

---
*Clustered 13 sources for this item.*

### Forced OAuth profile linking
- **Tags:** `#oauth`
- **Severity:** medium · **Hunt:** 3/5 · **Score:** 15.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://medium.com/@The4v1/%EF%B8%8F-03-forced-oauth-profile-linking-041e7e28ed99) · [2](https://medium.com/@The4v1/oauth-2-0-authetication-vulnerabilities-f810876c21eb)

- **Trick:** Manipulating the OAuth callback flow (often via CSRF or missing state validation) to link a victim's social identity (e.g., Google, Facebook) to an attacker's local account.
- **Why it matters:** Enables account takeover (ATO) by allowing an attacker to bypass authentication and log in as the victim once the link is established, often requiring no user interaction beyond a malicious page visit.
- **Rating:** chain-worthy

---
*Clustered 2 sources for this item.*

### Unauthenticated POST Endpoint via Swagger (BFLA)
- **Tags:** `#auth-bypass` `#api`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://medium.com/@zishanfiroz/how-i-found-an-unauthenticated-post-endpoint-in-a-production-api-a-real-bug-bounty-story-f706957d0702) · [2](https://medium.com/@The4v1/%EF%B8%8F-01-authentication-bypass-via-oauth-implicit-flow-13e26b67e697?source=rss------bug_bounty-5)

- **Trick:** Leveraged Swagger documentation reconnaissance to identify a POST endpoint that was missing authentication checks, allowing unauthenticated access to restricted functionality.
- **Why it matters:** Broken Function Level Authorization (BFLA) can lead to privilege escalation or full system compromise by exposing sensitive administrative actions to public users.
- **Rating:** variant

---
*Clustered 2 sources for this item.*

### Kioptrix Level 1: Apache to Root via ptrace/kmod
- **Tags:** `#rce` `#privesc`
- **Severity:** critical · **Hunt:** 1/5 · **Score:** 13.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@Punih3r7/kioptrix-level-1-vulnhub-walkthrough-openfuck-apache-exploit-to-root-via-ptrace-kmod-95ef4fea31b4)

- **Trick:** Exploits an outdated Apache/mod_ssl service using the "OpenFuck" exploit for initial access, then escalates privileges via the `ptrace` kmod kernel vulnerability.
- **Why it matters:** Provides a foundational walkthrough of scanning for service versions, applying legacy RCE exploits, and chaining them with local privilege escalation on Linux systems.
- **Rating:** variant

---
### Living Off The Land: Using PowerShell & RDP to Stay Invisible
- **Tags:** `#command-injection` `#privesc`
- **Severity:** medium · **Hunt:** 1/5 · **Score:** 5.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@paritoshblogs/how-attackers-use-legit-tools-like-powershell-rdp-to-stay-invisible-living-off-the-land-attacks-d1545a417713?source=rss------bug_bounty-5) · [2](https://medium.com/@laibakashif0011/web-security-series-exploiting-command-injection-for-reverse-shell-bc6c1d3b9aff?source=rss------bug_bounty-5)

- **Trick:** Abusing pre-installed, trusted administrative tools like PowerShell and RDP (LOLBins) to execute malicious code or move laterally without dropping custom malware.
- **Why it matters:** Traditional antivirus and EDR solutions often whitelist these legitimate system binaries, allowing attackers to conduct "fileless" attacks that evade signature-based detection.
- **Rating:** chain-worthy

---
*Clustered 2 sources for this item.*

### AI Agents Unaware of Surveillance
- **Tags:** `#llm` `#prompt-injection`
- **Severity:** unknown · **Hunt:** 2/5 · **Score:** 4.0 · **Status:** theoretical · **Age:** 30d
- **Sources:** [1](https://ad3sh.medium.com/ai-agents-think-they-just-dont-know-they-re-being-watched-2f8eec1dc6a9?source=rss------infosec-5) · [2](https://medium.com/@kanishka_33736/cybersecurity-ai-powered-threats-7604293a8de4?source=rss------pentesting-5)

- **Trick:** AI systems lack awareness of user surveillance, potentially enabling manipulation through hidden context injection.
- **Why it matters:** Creates attack vectors where prompters could exploit blind spots to bypass safety filters or extract unauthorized outputs.
- **Rating:** novel

---
*Clustered 2 sources for this item.*

### IDE [TryHackMe] Machine Walkthrough
- **Tags:** `#web`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 4.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@amroubekhedda/ide-try-hack-me-machine-walkthrough-36f414ffdcb9?source=rss------bug_bounty-5)

- **Trick:** Vulnerability exploitation walkthrough on a TryHackMe machine named IDE
- **Why it matters:** Demonstrates penetration testing techniques on an educational platform machine
- **Rating:** novel

---
### OSINT Strategies for OutSystems Pentesting
- **Tags:** `#web`
- **Severity:** info · **Hunt:** 2/5 · **Score:** 2.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@lucas_11478/osint-outsystems-estrat%C3%A9gia-para-pentests-security-researchs-and-red-teams-bd5ffec56480?source=rss------pentesting-5)

- **Trick:** Applying OSINT methodologies to uncover exposed OutSystems artifacts, modules, and development metadata that are often left public during deployment.
- **Why it matters:** Identifying these platform-specific remnants allows attackers to map the application architecture and find potential entry points that developers assumed were hidden.
- **Rating:** variant

---
### LLMGoat: Offensive LLM Security Environment
- **Tags:** `#llm` `#prompt-injection` `#jailbreak` `#data-exfil`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@liteshghute/llmgoat-offensive-llm-security-environment-cf5440aa708d)

- **Trick:** A locally hosted, free exploitation environment (similar to DVWA but for LLMs) that implements the OWASP LLM Top 10 vulnerabilities, allowing offline practice without cloud API costs.
- **Why it matters:** Provides a safe, cost-effective playground for security researchers to understand, identify, and weaponize LLM-specific attack vectors such as prompt injection and jailbreaking.
- **Rating:** novel

---
### Cracking Open the Black Box: IoT Firmware Analysis
- **Tags:** `#appliance` `#privesc`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://fr3ak-hacks.medium.com/cracking-open-the-black-box-a-practical-guide-to-iot-firmware-analysis-808f289743d8?source=rss------infosec-5)

- **Trick:** Techniques for extracting and reverse-engineering firmware from IoT hardware like routers and cameras.
- **Why it matters:** Static analysis of extracted filesystems allows researchers to discover hardcoded credentials, insecure keys, and vulnerabilities that are invisible from the outside.
- **Rating:** variant

---
### Professional Kali Linux (2026.1+) Post-Installation Setup with Bash
- **Tags:** `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://meetcyber.net/professional-kali-linux-2026-1-post-installation-setup-with-bash-4a78439d6af1)

- **Trick:** Using a Bash script to automate environment configuration and workspace organization on Kali Linux 2026.1+.
- **Why it matters:** Standardizes the penetration testing setup process, reducing manual configuration time and ensuring a consistent, ready-to-hack environment.
- **Rating:** variant

---
### Wireshark Packet Analysis: Investigating Network Traffic Like a SOC Analyst
- **Tags:** `#web` `#data-exfil`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@rgoel.goel03/wireshark-packet-analysis-investigating-network-traffic-like-a-soc-analyst-a640e15d06fd?source=rss------infosec-5)

- **Trick:** Provides a practical walkthrough of using Wireshark display filters, following TCP streams, and analyzing protocol headers to dissect network activity.
- **Why it matters:** Mastering packet-level analysis is essential for verifying exploit behavior, understanding application data flows, and uncovering hidden indicators of compromise or data exfiltration.
- **Rating:** variant

---
### Mr Robot TryHackMe Español
- **Tags:** `#web` `#privesc`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@Us0lfr/mr-robot-tryhackme-espa%C3%B1ol-ea813f4fff9a)

- **Trick:** Walkthrough of the "Mr Robot" medium-difficulty CTF box, likely involving web enumeration (robots.txt), WordPress discovery, password brute-forcing, and standard Linux privilege escalation vectors.
- **Why it matters:** Reinforces fundamental methodologies for OSINT, web application testing, and system post-exploitation in a controlled environment.
- **Rating:** variant

---
### Mobile Security in 2026: Threats, Risks & Best Practices
- **Tags:** `#mobile` `#web` `#api`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 0.5 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://medium.com/@dhanashreeA/mobile-security-in-2026-threats-risks-best-practices-to-stay-safe-045278e87ad2?source=rss------infosec-5)

- **Trick:** Overview of emerging mobile threats and actionable mitigation strategies for 2026.
- **Why it matters:** Mobile devices are primary attack targets, making proactive security measures critical for personal and organizational data protection.
- **Rating:** novel

---

## 2026-04-19

### libcurl omits IPv6 zoneid from host identity and leaks credentials/cookies across scoped link-local realms

- **2026-04-19** · sev: Medium · bounty: undisclosed · cve: CVE-2022-27775
- Source: [hackerone.com/3680680](https://hackerone.com/reports/3680680) · Reporter: [@valvelvel](https://hackerone.com/valvelvel) · Team: [curl](https://hackerone.com/curl)
- CWE: Information Disclosure

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27775` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27775.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Digest Auth State Leak on Cross-Origin Redirect via Netrc - Username and Password Hash Sent to Wrong Host

- **2026-04-19** · sev: Medium · bounty: undisclosed · cve: CVE-2022-27774
- Source: [hackerone.com/3680038](https://hackerone.com/reports/3680038) · Reporter: [@fg0x0](https://hackerone.com/fg0x0) · Team: [curl](https://hackerone.com/curl)
- CWE: Insufficiently Protected Credentials

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27774` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27774.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Stored XSS in attachment-display exploitable through SameSite

- **2026-04-19** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3594137](https://hackerone.com/reports/3594137) · Reporter: [@aikido_security](https://hackerone.com/aikido_security) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A stored XSS vulnerability was discovered in the attachment-display feature of Roundcube. By uploading an HTML file and opening it through the display-attachment endpoint, the embedded script could execute under the Roundcube origin. The issue was caused by the lack of a restrictive Content Security Policy in the attachment display flow, unlike the general attachment viewer.

**Hunt signal:** Upload `.html` to any attachment-handling endpoint, then request the view/display URL. Check response `Content-Type: text/html` + absent/lax `Content-Security-Policy`.
**Grep:** `rg -n 'attachment.*(display|view|inline)' src/ | rg -v 'Content-Security-Policy'`
**Nuclei:** `xss,upload`
**Pass-if:** Target always returns `Content-Disposition: attachment` or strong CSP (`script-src 'self'`).

---

### libcurl reuses a learned RTSP Session header across different hosts on the same easy handle, enabling cross-host session leak and replay

- **2026-04-18** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3680234](https://hackerone.com/reports/3680234) · Reporter: [@skksndk](https://hackerone.com/skksndk) · Team: [curl](https://hackerone.com/curl)
- CWE: Exposure of Data Element to Wrong Session

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Rails::HTML::Sanitizer.allowed_uri? returns true for entity-encoded control-character-split javascript: URLs

- **2026-04-18** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3601655](https://hackerone.com/reports/3601655) · Reporter: [@smlee](https://hackerone.com/smlee) · Team: [Ruby on Rails](https://hackerone.com/rails)

**What**

A vulnerability was discovered in the `Rails::HTML::Sanitizer.allowed_uri?` method of the `rails-html-sanitizer` library. The method incorrectly returned `true` for entity-encoded control-character-split `javascript:` URLs, which could lead to potential security issues if the application relied on the method's result to make security decisions.

**Hunt signal:** POST `href="java&#x09;script:alert(1)"` (and `&#x0a;`, `&#x0d;`, `&#x0c;`) in HTML fields to any Rails app endpoint that sanitizes rich text. Check if sanitized output preserves the `javascript:` URI in `href`/`src` attributes.
**Grep:** `rg -n 'Rails::HTML::Sanitizer|sanitize|sanitize_css' app/`
**Nuclei:** `xss`
**Pass-if:** Target doesn't use `rails-html-sanitizer` or sanitizes URIs via allowlist rather than blocklist.

---

### libcurl stale CURLOPT_AUTOREFERER leaks a previous request URL to a different origin on a reused easy handle

- **2026-04-17** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3673277](https://hackerone.com/reports/3673277) · Reporter: [@asdwe](https://hackerone.com/asdwe) · Team: [curl](https://hackerone.com/curl)
- CWE: Information Exposure Through Sent Data

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Residual Malicious Payloads on HackerOne after Vulnerability Fixes

- **2026-04-16** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3168691](https://hackerone.com/reports/3168691) · Reporter: [@joejoe5](https://hackerone.com/joejoe5) · Team: [HackerOne](https://hackerone.com/security)
- CWE: Improper Input Validation

**What**

A vulnerability was previously discovered on the HackerOne platform that allowed users to add malicious payloads to their profile pages. Despite remediation efforts, some of these malicious payloads were not fully removed from user profiles. This situation meant that the malicious content could still be triggered when users visited certain profile pages.

**Hunt signal:** pass — target-specific incomplete remediation, no reusable probe.

---

### DOS via Mutation Aliasing in GraphQL Account Recovery Phone Number Verification API

- **2026-04-16** · sev: — · bounty: $12,500
- Source: [hackerone.com/3287208](https://hackerone.com/reports/3287208) · Reporter: [@hellokbit](https://hackerone.com/hellokbit) · Team: [HackerOne](https://hackerone.com/security)

**What**

The GraphQL API's 'verifyAccountRecoveryPhoneNumber' mutation was found to be vulnerable to denial-of-service attacks through mutation aliasing. The vulnerability allowed multiple aliases of the same mutation to be included in a single request, causing the server to process each mutation sequentially and increasing the response time linearly. This resource exhaustion issue could potentially have led to service disruption for legitimate users.

**Hunt signal:** POST N aliased copies of a heavy/stateful mutation to `<graphql-endpoint>` in one request. If response time scales linearly with N, the server lacks alias deduplication and query complexity limits.
**Grep:** `rg -n 'resolve|execute' src/graphql/ | rg -iv 'alias|dedup|complexity'`
**Nuclei:** `graphql,dos`
**Pass-if:** GraphQL engine enforces max aliases per request or query cost analysis.

---

### lib/http2.c: SSL connections accept non-HTTP push schemes (incomplete fix for 2e8c922a)

- **2026-04-16** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3674275](https://hackerone.com/reports/3674275) · Reporter: [@hybirdss](https://hackerone.com/hybirdss) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Authorization header leak in ssrf_filter via cross-host redirect leads to credential theft and unauthorized access

- **2026-04-15** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3642600](https://hackerone.com/reports/3642600) · Reporter: [@argareksapatii](https://hackerone.com/argareksapatii) · Team: [arkadiyt-projects](https://hackerone.com/arkadiyt-projects)

**What**

A vulnerability was discovered in the `ssrf_filter` library. The vulnerability allowed an attacker-controlled redirect target to receive credentials that were intended only for the original request origin. This was possible because `ssrf_filter` followed redirects by rebuilding each redirected request from the original request options, including the `Authorization` header. As a result, sensitive state such as bearer tokens was forwarded across cross-host redirects, leading to credential theft and unauthorized access.

**Hunt signal:** Trigger any SSRF-prone endpoint with a URL on an allowed domain that 302-redirects to `<attacker-domain>` → check if `Authorization` header arrives in the redirect request.
**Grep:** `rg -n 'ssrf_filter|SsrfFilter'`
**Nuclei:** `ssrf`
**Pass-if:** Target doesn't use Ruby `ssrf_filter` gem or SSRF endpoint only fetches public/unauthenticated resources.

---

### SQL Injection Detection Bypass in AWS WAF Managed Rules (AWSManagedRulesSQLiRuleSet)

- **2026-04-15** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3591725](https://hackerone.com/reports/3591725) · Reporter: [@killnet-edc](https://hackerone.com/killnet-edc) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: SQL Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### DOM XSS in `fizzy.do` import filename preview enables one-click victim account takeover

- **2026-04-14** · sev: High · bounty: $500
- Source: [hackerone.com/3608199](https://hackerone.com/reports/3608199) · Reporter: [@xavlimsg](https://hackerone.com/xavlimsg) · Team: [Basecamp](https://hackerone.com/basecamp)
- CWE: Cross-site Scripting (XSS) - DOM

**What**

A DOM XSS vulnerability was discovered in the file import functionality of the Fizzy application. The vulnerability allowed an attacker to craft a malicious filename that, when previewed by the victim user, would inject a second form submission into the import page. This enabled the attacker to perform actions on the victim's account, such as changing the email address, creating a personal access token, and deleting the account, all using the victim's authenticated session.

**Hunt signal:** Upload a file with filename `<img src=x onerror=alert(1)>.csv` to any file-import endpoint, then trigger the import preview page. Check if the filename is rendered raw in the DOM.
**Grep:** `rg -n 'filename|file\.name' --type html --type js | rg -v 'textContent|innerText|escape|sanitize'`
**Nuclei:** `xss,dom`
**Pass-if:** Import flow never renders the original filename client-side (e.g., only shows server-generated UUIDs or sanitizes via `textContent`).

---

### Improper Access Control in `fizzy.do` import flow allows cross-tenant ActionText reference resolution and data disclosure

- **2026-04-14** · sev: Low · bounty: $218
- Source: [hackerone.com/3543475](https://hackerone.com/reports/3543475) · Reporter: [@xavlimsg](https://hackerone.com/xavlimsg) · Team: [Basecamp](https://hackerone.com/basecamp)
- CWE: Improper Access Control - Generic

**What**

The vulnerability allowed for cross-tenant ActionText reference resolution and data disclosure during the account import flow. The import process did not properly verify the ownership of the referenced records before minting signed global IDs, enabling an attacker to access and disclose data from other accounts.

**Hunt signal:** POST rich-text payloads containing unowned record IDs to import/migration endpoints. Check if the server mints valid `gid://` references or leaks the referenced data.
**Grep:** `rg -n 'SignedGlobalID|sgid' | rg -i 'import'`
**Nuclei:** `idor`
**Pass-if:** Target doesn't use Rails ActionText/GlobalID or lacks user-facing import flows.

---

### BOLA/IDOR in Out-of-Office API allows any authenticated user to read other users' absence data

- **2026-04-14** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3382343](https://hackerone.com/reports/3382343) · Reporter: [@cyberjoker](https://hackerone.com/cyberjoker) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### [Variation of #3321406] YetAnother 1-Click Chaining of Self-XSS, Cookie Tossing and AntiCSRF Token Prediction leads to auto approval in AccessTempAuth

- **2026-04-14** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3423950](https://hackerone.com/reports/3423950) · Reporter: [@matured_kazama](https://hackerone.com/matured_kazama) · Team: [Cloudflare Public Bug Bounty](https://hackerone.com/cloudflare)
- CWE: Cross-site Scripting (XSS) - Stored

**What**

A vulnerability in Cloudflare Access involving the Browser Isolation email field was discovered, which could allow for unauthorized approvals within the Temporary Auth workflow. The issue has been fully remediated.

**Hunt signal:** pass — summary too thin

---

### [Variation of #1554049] 1-Click Chaining of Self-XSS, Cookie Tossing and AntiCSRF Token Prediction leads to auto approval in Access Temp Auth

- **2026-04-14** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3321406](https://hackerone.com/reports/3321406) · Reporter: [@matured_kazama](https://hackerone.com/matured_kazama) · Team: [Cloudflare Public Bug Bounty](https://hackerone.com/cloudflare)

**What**

A vulnerability was discovered in Cloudflare Access that could allow for unauthorized approvals within the Temporary Auth workflow. The issue was resolved after the researcher reported it to Cloudflare.

**Hunt signal:** pass — summary too thin, no actionable primitives disclosed.

---

### Brave Shields Domain Reordering Leads to Origin Confusion

- **2026-04-13** · sev: Low · bounty: $100
- Source: [hackerone.com/3665151](https://hackerone.com/reports/3665151) · Reporter: [@mousepadkalilinux12](https://hackerone.com/mousepadkalilinux12) · Team: [Brave Software](https://hackerone.com/brave)
- CWE: Violation of Secure Design Principles

**What**

The Brave Shields feature was observed to reorder domain names, leading to potential origin confusion. Specifically, the domain "1.attacker.com" was displayed as "attacker.com.1", and "1.1.1.1.attacker.com" was displayed as "attacker.com.1.1.1.1". This behavior could potentially mislead users about the actual source of the website.

**Hunt signal:** pass — browser-UI display bug in Brave Shields, no server-side probe exists.

---

### Credential Disclosure via Unvalidated directDownloadUrl (Missing DontAddCredentialsAttribute)

- **2026-04-13** · sev: Medium · bounty: $250
- Source: [hackerone.com/3400143](https://hackerone.com/reports/3400143) · Reporter: [@py0zz1](https://hackerone.com/py0zz1) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insufficiently Protected Credentials

**What**

The Nextcloud Desktop Client was found to automatically include user credentials (Authorization header with username and password in Base64) when downloading files via the "directDownloadUrl" feature. This allowed a malicious Nextcloud server to specify an attacker-controlled URL, causing the client to leak the user's credentials to the attacker's server. The root cause was the failure to validate the origin of the "directDownloadUrl" and the lack of setting the "DontAddCredentialsAttribute" for cross-origin requests.

**Hunt signal:** Host a rogue server returning `directDownloadUrl` (or equivalent file-redirect field) pointing to `<collaborator>`, connect the target desktop client to it, and check if `Authorization` header arrives cross-origin.
**Pass-if:** Target is a server-side web app (no client to poison), or client uses short-lived OAuth tokens sent as query params rather than persistent Basic auth headers.

---

### Argument Injection via curl Short-Flag Grouping

- **2026-04-13** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3669305](https://hackerone.com/reports/3669305) · Reporter: [@midoussa7](https://hackerone.com/midoussa7) · Team: [curl](https://hackerone.com/curl)
- CWE: Command Injection - Generic

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Integer Overflow/Signedness Mismatch in Printf Precision for HTTP/2 Trailer Headers

- **2026-04-11** · sev: None · bounty: undisclosed · cve: CVE-2020-19909
- Source: [hackerone.com/3665363](https://hackerone.com/reports/3665363) · Reporter: [@pwnpwn](https://hackerone.com/pwnpwn) · Team: [curl](https://hackerone.com/curl)
- CWE: Integer Overflow

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2020-19909` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2020-19909.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Encryption context keys and values logged at INFO level

- **2026-04-10** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3620760](https://hackerone.com/reports/3620760) · Reporter: [@misop00p](https://hackerone.com/misop00p) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: Insertion of Sensitive Information into Log File

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Open Redirect in Rocket.Chat

- **2026-04-10** · sev: Medium · bounty: undisclosed · cve: CVE-2026-22560
- Source: [hackerone.com/3418031](https://hackerone.com/reports/3418031) · Reporter: [@soohyun](https://hackerone.com/soohyun) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Open Redirect

**What**

An open redirect vulnerability was identified in Rocket.Chat. The /_saml/sloRedirect/:provider endpoint included the redirect query string value directly in the Location header for a 302 redirect without any server-side validation. This issue was fixed in v8.4.0.

**PoC refs:** search `github.com/search?q=CVE-2026-22560` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-22560.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** Probe SAML SLO/SSO redirect endpoints (e.g. `/_saml/sloRedirect/`, `/_saml/ssoRedirect/`) with `?redirect=//evil.com` → check 302 `Location` reflects the attacker URL without validation.
**Nuclei:** `open-redirect`
**Pass-if:** Target doesn't use SAML or all SAML redirect params are validated against an allowlist.

---

### [Vertical Privilege Escalation] User can Unapproved any Approved Translation at [/translations/unapprove/]

- **2026-04-10** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3020021](https://hackerone.com/reports/3020021) · Reporter: [@adilnbabras](https://hackerone.com/adilnbabras) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Privilege Escalation

**What**

A vulnerability was discovered in the Pontoon web application where any logged-in user could unapprove any approved translation, regardless of their privileges. This was due to a logical error in the validation logic, which allowed bypassing the authorization check. The vulnerability could be exploited by intercepting the request to the "/translations/unapprove/" endpoint and modifying the necessary parameters.

**Hunt signal:** Authenticate as lowest-privilege user, POST to any `/approve/`, `/unapprove/`, `/reject/`, or `/publish/` endpoint. Success from non-admin role = missing authorization check.
**Grep:** `rg -n 'login_required' src/ | rg -i '(approve|unapprove|reject|publish)' | rg -v 'permission'`
**Pass-if:** Endpoint returns 403 to low-priv users or uses role-based decorators/middleware.

---

### User Can Delete Other Users' Personal Access Tokens at /delete-token/{token_id}/ on Mozilla Pontoon

- **2026-04-10** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3325582](https://hackerone.com/reports/3325582) · Reporter: [@adilnbabras](https://hackerone.com/adilnbabras) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Improper Access Control - Generic

**What**

A vulnerability was discovered in the Mozilla Pontoon application that allowed users to delete other users' personal access tokens at the /delete-token/{token_id}/ endpoint without proper permission checks. The vulnerability was caused by the absence of user permission verification in the delete_token view function, which allowed anyone to delete any user's personal access token. This could have resulted in users losing access to their accounts if their personal access tokens were deleted.

**Hunt signal:** POST to any `/delete-token/<token_id>` (or similar `/delete-key/`, `/revoke-session/`) endpoint while authenticated as user A, swapping `<token_id>` to a value belonging to user B → check 200/302 vs 403.
**Grep:** `rg -n 'def delete.*(token|key|session|api)' src/ | rg -v 'request\.user|owner|permission'`
**Nuclei:** `idor`
**Pass-if:** Token IDs are UUIDv4 and endpoint is behind proper object-level permission checks.

---

### Memory leak in gem decode logic can allow attacker to take down Rubygems.org application

- **2026-04-09** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3079931](https://hackerone.com/reports/3079931) · Reporter: [@mclaren650sspider](https://hackerone.com/mclaren650sspider) · Team: [RubyGems](https://hackerone.com/rubygems)
- CWE: Uncontrolled Resource Consumption

**What**

A memory leak vulnerability was discovered in the gem decode logic of the Rubygems.org application. The vulnerability allowed an attacker with a valid API key to set arbitrary instance variables during the decoding of gem metadata, which would cause the server to exhaust its memory. The issue was addressed by restricting the instance variables that can be set during metadata decoding.

**Hunt signal:** pass — target-specific deserialization quirk in Rubygems.org gem upload, requires valid API key and crafted Marshal payload injecting arbitrary instance variables; no reusable cross-target probe.

---

### libcurl: Integer truncation in curl_easy_ssls_import() causes TLS sessions to never expire

- **2026-04-09** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3658049](https://hackerone.com/reports/3658049) · Reporter: [@adityasunny_06](https://hackerone.com/adityasunny_06) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Health check errors silently dropped when channel buffer full

- **2026-04-07** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3620761](https://hackerone.com/reports/3620761) · Reporter: [@misop00p](https://hackerone.com/misop00p) · Team: [AWS VDP](https://hackerone.com/aws_vdp)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### IDOR on ██████ via direct photo URL leads to unauthorized access to deleted and other users' photos

- **2026-04-07** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3518758](https://hackerone.com/reports/3518758) · Reporter: [@shiva2550](https://hackerone.com/shiva2550) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### no_proxy IDN mismatch: Unicode hostnames bypass proxy exclusion list

- **2026-04-07** · sev: — · bounty: undisclosed · cve: CVE-2022-42916, CVE-2022-43551
- Source: [hackerone.com/3650443](https://hackerone.com/reports/3650443) · Reporter: [@mzfr](https://hackerone.com/mzfr) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Access Control - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-42916` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-42916.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### FTP entrypath accepts 0xFF (Telnet IAC) through incomplete ISCNTRL filter, sent on wire via CWD on connection reuse

- **2026-04-07** · sev: — · bounty: undisclosed · cve: CVE-2020-8284
- Source: [hackerone.com/3650473](https://hackerone.com/reports/3650473) · Reporter: [@mzfr](https://hackerone.com/mzfr) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2020-8284` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2020-8284.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Improper enforcement of CURLOPT_SOCKS5_AUTH due to missing reuse key validation in libcurl

- **2026-04-07** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3650435](https://hackerone.com/reports/3650435) · Reporter: [@cutiapretaa](https://hackerone.com/cutiapretaa) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Authorization

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Reported Denial of Service

- **2026-04-06** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3241102](https://hackerone.com/reports/3241102) · Reporter: [@jehrenhofermagicgrants](https://hackerone.com/jehrenhofermagicgrants) · Team: [Monero](https://hackerone.com/monero)
- CWE: Uncontrolled Resource Consumption

**What**

A vulnerability was reported in the Monero RPC server that could cause a denial of service. The issue was found in the "calc_pow" RPC endpoint, where specially crafted input could cause the server to crash with the message "Cryptonight variant 1 needs at least 43 bytes of data". The problem was that the function did not properly validate the length of the input data, leading to an unexpected exit condition.

**Hunt signal:** pass — target-specific, no reusable trick.

---

### Reported RPC Overflow

- **2026-04-06** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3240792](https://hackerone.com/reports/3240792) · Reporter: [@jehrenhofermagicgrants](https://hackerone.com/jehrenhofermagicgrants) · Team: [Monero](https://hackerone.com/monero)
- CWE: Integer Overflow

**What**

A stack buffer overflow was reported in the Monero RPC server. Specifically, on line 1291 of the `core_rpc_server.cpp` file, an overflow could occur if the size of the `b.data()` did not match the size of the `crypto::key_image`. Additionally, a missing return statement was found following line 1289. The issue was detected through fuzzing performed by Ada Logics on behalf of the MAGIC Monero Fund.

**Hunt signal:** pass — target-specific Monero C++ fuzzing finding, no reusable primitive.

---

### # SCURLOPT_SSH_KNOWNHOSTS and host fingerprint pins are silently bypassed when an SSH connection is reused from the connection pool

- **2026-04-06** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3645415](https://hackerone.com/reports/3645415) · Reporter: [@spiderchan26](https://hackerone.com/spiderchan26) · Team: [curl](https://hackerone.com/curl)
- CWE: Exposed Dangerous Method or Function

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### SMTP Command Injection via CRLF in libcurl MAIL_FROM / MAIL_RCPT (lib/smtp.c)

- **2026-04-06** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3651975](https://hackerone.com/reports/3651975) · Reporter: [@divsz](https://hackerone.com/divsz) · Team: [curl](https://hackerone.com/curl)
- CWE: CRLF Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### ignoring 'options' when doing connection reuse

- **2026-04-05** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3646914](https://hackerone.com/reports/3646914) · Reporter: [@spichanlio76](https://hackerone.com/spichanlio76) · Team: [curl](https://hackerone.com/curl)
- CWE: Incorrect Comparison

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Data race in Curl_dnscache_add_negative() corrupts shared DNS cache — heap corruption and double-free when using CURLOPT_SHARE with CURL_LOCK_DATA_DNS

- **2026-04-04** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3645361](https://hackerone.com/reports/3645361) · Reporter: [@intrax](https://hackerone.com/intrax) · Team: [curl](https://hackerone.com/curl)
- CWE: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Internal application wrapper or script using curl

- **2026-04-03** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3648199](https://hackerone.com/reports/3648199) · Reporter: [@rougerseven7](https://hackerone.com/rougerseven7) · Team: [curl](https://hackerone.com/curl)
- CWE: Code Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Missing server identity policy enforcement in SSH connection reuse allows host key verification bypass via pool poisoning

- **2026-04-03** · sev: High · bounty: undisclosed · cve: CVE-2022-27782, CVE-2023-27538
- Source: [hackerone.com/3640932](https://hackerone.com/reports/3640932) · Reporter: [@intrax71](https://hackerone.com/intrax71) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27782` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27782.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Cookie attribute TAB injection regression in Set-Cookie parsing

- **2026-04-03** · sev: Low · bounty: undisclosed · cve: CVE-2022-35252
- Source: [hackerone.com/3641893](https://hackerone.com/reports/3641893) · Reporter: [@calaba_zas](https://hackerone.com/calaba_zas) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Input Validation

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-35252` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-35252.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Bypassing Strict SSH Server Verification via Connection Pool Reuse in libcurl

- **2026-03-31** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3639277](https://hackerone.com/reports/3639277) · Reporter: [@whitehat411](https://hackerone.com/whitehat411) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Use-After-Free race condition in url_move_hostname() via shared connection pool

- **2026-03-31** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3638715](https://hackerone.com/reports/3638715) · Reporter: [@h3xb1tx](https://hackerone.com/h3xb1tx) · Team: [curl](https://hackerone.com/curl)
- CWE: Use After Free

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Unauthenticated SSRF via Public Reference API -Sharing Token Bypass

- **2026-03-31** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3479692](https://hackerone.com/reports/3479692) · Reporter: [@eclipse07077](https://hackerone.com/eclipse07077) · Team: [Nextcloud](https://hackerone.com/nextcloud)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### HackerOne Vulnerability Report: libcurl SSL/TLS Identity Leakage via Insecure Connection Reuse

- **2026-03-31** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3636244](https://hackerone.com/reports/3636244) · Reporter: [@ankitsingh131225](https://hackerone.com/ankitsingh131225) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### HTTP/2 PUSH_PROMISE header loss on OOM bypasses scheme validation (regression of 2e8c922a89)

- **2026-03-31** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3636044](https://hackerone.com/reports/3636044) · Reporter: [@m42kl33](https://hackerone.com/m42kl33) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Handling of Insufficient Permissions or Privileges

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Unbounded GZIP Decompression Leading to Event-Loop Starvation

- **2026-03-31** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3632427](https://hackerone.com/reports/3632427) · Reporter: [@ok3y](https://hackerone.com/ok3y) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Handling of Highly Compressed Data (Data Amplification)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### SSRF Filter Bypass via Unblocked NAT64 Local-Use IPv6 Prefix (64:ff9b:1::/48)

- **2026-03-31** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3634400](https://hackerone.com/reports/3634400) · Reporter: [@tipsen](https://hackerone.com/tipsen) · Team: [arkadiyt-projects](https://hackerone.com/arkadiyt-projects)
- CWE: Server-Side Request Forgery (SSRF)

**What**

A vulnerability was discovered in the `ssrf_filter` library version 1.3.0. The library failed to block the NAT64 local-use IPv6 prefix `64:ff9b:1::/48`, allowing such addresses to be treated as public. This enabled SSRF requests through `/fetch` to targets encoded under that prefix when routable in the deployment environment.

**Hunt signal:** `curl --data-raw 'url=http://[64:ff9b:1::7f00:1]/' <target>/fetch` — test SSRF endpoints with the NAT64 local-use prefix `64:ff9b:1::` mapped to `127.0.0.1` (`7f00:1`).
**Grep:** `rg -n 'ssrf|url.*parse|is_private|is_internal' --type ruby`
**Nuclei:** `ssrf`
**Pass-if:** Target has no URL-fetch/orchestration endpoints, or IPv6 is fully disabled on the server network.

---

### Path Traversal in writeFile via Unsafe Prefix Containment Check Allows Out-of-Directory Writes

- **2026-03-31** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3634571](https://hackerone.com/reports/3634571) · Reporter: [@tipsen](https://hackerone.com/tipsen) · Team: [arkadiyt-projects](https://hackerone.com/arkadiyt-projects)
- CWE: Path Traversal

**What**

A path traversal vulnerability was discovered in the `protodump` tool. The vulnerability allowed an attacker to influence the output filename construction and bypass the containment check, enabling writes outside the intended output directory. The vulnerability was caused by the use of descriptor-controlled paths in the output filename construction, along with an unsafe lexical prefix check for directory containment. This issue has been identified in the `protodump` tool.

**Hunt signal:** pass — bug in a specific internal tool (`protodump`), no reusable endpoint or generic probe.

---

### HashDoS in V8

- **2026-03-30** · sev: Medium · bounty: undisclosed · cve: CVE-2026-21717
- Source: [hackerone.com/3511792](https://hackerone.com/reports/3511792) · Reporter: [@sharp_edged](https://hackerone.com/sharp_edged) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Cryptographic Issues - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21717` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21717.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Permission Model Bypass in realpathSync.native Allows File Existence Disclosure

- **2026-03-30** · sev: Low · bounty: undisclosed · cve: CVE-2026-21715
- Source: [hackerone.com/3480841](https://hackerone.com/reports/3480841) · Reporter: [@stif](https://hackerone.com/stif) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Information Disclosure

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21715` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21715.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Timing side-channel in HMAC verification via memcmp() in crypto_hmac.cc leads to potential MAC forgery

- **2026-03-30** · sev: Medium · bounty: undisclosed · cve: CVE-2026-21713
- Source: [hackerone.com/3533945](https://hackerone.com/reports/3533945) · Reporter: [@x_probe](https://hackerone.com/x_probe) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Cryptographic Issues - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21713` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21713.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Node.js Permission Model bypass: UDS server bind/listen works without `--allow-net`

- **2026-03-30** · sev: Medium · bounty: undisclosed · cve: CVE-2026-21711
- Source: [hackerone.com/3559715](https://hackerone.com/reports/3559715) · Reporter: [@xavlimsg](https://hackerone.com/xavlimsg) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Improper Access Control - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21711` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21711.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Denial of Service via `__proto__` header name in `req.headersDistinct` (Uncaught `TypeError` crashes Node.js process)

- **2026-03-30** · sev: High · bounty: undisclosed · cve: CVE-2026-21710
- Source: [hackerone.com/3560402](https://hackerone.com/reports/3560402) · Reporter: [@yushengchen](https://hackerone.com/yushengchen) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Uncontrolled Resource Consumption

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21710` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21710.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2024-36137 Patch Bypass - FileHandle.chmod/chown

- **2026-03-30** · sev: Low · bounty: undisclosed · cve: CVE-2026-21716
- Source: [hackerone.com/3449392](https://hackerone.com/reports/3449392) · Reporter: [@wooseokdotkim](https://hackerone.com/wooseokdotkim) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Improper Access Control - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21716` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21716.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Memory leak in Node.js HTTP/2 server via WINDOW_UPDATE on stream 0 leads to resource exhaustion

- **2026-03-30** · sev: Medium · bounty: undisclosed · cve: CVE-2026-21714
- Source: [hackerone.com/3531737](https://hackerone.com/reports/3531737) · Reporter: [@galbarnahum](https://hackerone.com/galbarnahum) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Missing Release of Memory after Effective Lifetime

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-21714` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21714.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CRLF Injection in HAProxy PROXY Protocol via CURLOPT_HAPROXY_CLIENT_IP allows IP spoofing and protocol injection

- **2026-03-30** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3633534](https://hackerone.com/reports/3633534) · Reporter: [@sakthi02_sk](https://hackerone.com/sakthi02_sk) · Team: [curl](https://hackerone.com/curl)
- CWE: CRLF Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### HTTP/2 server push accepts a non-authoritative :scheme=https over cleartext h2c, enabling HTTPS cache-key poisoning

- **2026-03-29** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3630310](https://hackerone.com/reports/3630310) · Reporter: [@argareksapatii](https://hackerone.com/argareksapatii) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Input Validation

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Password Strength Policy Bypass via Server-Side Validation Flaw

- **2026-03-27** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3523703](https://hackerone.com/reports/3523703) · Reporter: [@2026](https://hackerone.com/2026) · Team: [Tucows (VDP)](https://hackerone.com/tucows_vdp)
- CWE: Business Logic Errors

**What**

A password strength policy bypass was discovered due to a server-side validation flaw. The password strength policy was only enforced in the browser, not on the server side.

**Hunt signal:** pass — fundamental methodology (always bypass client-side validation), not a specific discoverable pattern.

---

### Potential DoS due to PasswordPoliciesNotMet in errors.go

- **2026-03-27** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/2441029](https://hackerone.com/reports/2441029) · Reporter: [@sinic](https://hackerone.com/sinic) · Team: [passhash](https://hackerone.com/passhash)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Missing policies for password in password_policies.go

- **2026-03-27** · sev: — · bounty: undisclosed
- Source: [hackerone.com/2439734](https://hackerone.com/reports/2439734) · Reporter: [@sinic](https://hackerone.com/sinic) · Team: [passhash](https://hackerone.com/passhash)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Assertion error in node_url.cc via malformed URL format leads to Node.js crash

- **2026-03-26** · sev: Medium · bounty: undisclosed · cve: CVE-2026-21712
- Source: [hackerone.com/3546390](https://hackerone.com/reports/3546390) · Reporter: [@rafaelgss](https://hackerone.com/rafaelgss) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Reachable Assertion

**What**

An assertion error in node_url.cc via malformed URL format leads to a Node.js crash. A flaw in the URL processing caused an assertion failure in the native code when url.format() was called with a malformed internationalized domain name containing invalid characters, crashing the Node.js process. This vulnerability affected Node.js versions 24.x and 25.x.

**PoC refs:** search `github.com/search?q=CVE-2026-21712` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21712.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — Node.js library CVE; impact is process crash only, exact malformed IDN payload unspecified, and most bounty programs don't reward unauthenticated DoS.

---

### Server-side ReDoS via user-controlled regex in OIDC Access Policy

- **2026-03-26** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3542546](https://hackerone.com/reports/3542546) · Reporter: [@6b_jjj](https://hackerone.com/6b_jjj) · Team: [RubyGems](https://hackerone.com/rubygems)
- CWE: Uncontrolled Resource Consumption

**What**

The OIDC Access Policy implementation evaluated user-supplied regular expressions against JWT claim values using Ruby's Regexp engine without any timeout or complexity validation. The vulnerable code path was Regexp.new(value).match?(claim_value), where value was fully user-controlled and claim_value was derived from JWT claims. Malicious regular expressions with catastrophic backtracking characteristics could be supplied, causing the server to spend an excessive amount of CPU time evaluating a single request.

**Hunt signal:** POST catastrophic-backtracking regex `(a+)+$` to any endpoint accepting regex patterns (OIDC policy fields, ACL rules, filter inputs) → measure response time >10s.
**Grep:** `rg -n 'Regexp\.new\(|new RegExp\(' src/ | rg -v 'timeout|Timeout'`
**Pass-if:** Target never accepts user-supplied regex patterns, or engine enforces timeout/step limits.

---

### Bearer Token Leaked to Attacker via .netrc Despite CVE-2026-3783 Fix

- **2026-03-26** · sev: — · bounty: undisclosed · cve: CVE-2026-3783
- Source: [hackerone.com/3611825](https://hackerone.com/reports/3611825) · Reporter: [@wizard021](https://hackerone.com/wizard021) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-3783` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3783.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Security Vulnerability Report: Protocol Injection via Programmatic Options

- **2026-03-26** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3627638](https://hackerone.com/reports/3627638) · Reporter: [@ankitsingh_76](https://hackerone.com/ankitsingh_76) · Team: [curl](https://hackerone.com/curl)
- CWE: CRLF Injection

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### HTTP/1.1 Response Desynchronization via conflicting CL/TE headers in Proxy CONNECT

- **2026-03-25** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3623064](https://hackerone.com/reports/3623064) · Reporter: [@3lcarry](https://hackerone.com/3lcarry) · Team: [curl](https://hackerone.com/curl)
- CWE: HTTP Request Smuggling

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Function `do_pubkey()` can have out-of-bound read issue

- **2026-03-25** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3617719](https://hackerone.com/reports/3617719) · Reporter: [@tynus](https://hackerone.com/tynus) · Team: [curl](https://hackerone.com/curl)
- CWE: Out-of-bounds Read

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Potential Subdomain Takeover on IBM.com domain.

- **2026-03-24** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3592387](https://hackerone.com/reports/3592387) · Reporter: [@bugmithalchemist](https://hackerone.com/bugmithalchemist) · Team: [IBM](https://hackerone.com/ibm)
- CWE: Improper Access Control - Generic

**What**

A potential subdomain takeover on an IBM.com domain was reported to IBM, analyzed, and remediated.

**Hunt signal:** pass — summary too thin.

---

### Access to Deactivated LinkedIn Company Pages via Competitor Analytics API

- **2026-03-24** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3604288](https://hackerone.com/reports/3604288) · Reporter: [@riadalrashed](https://hackerone.com/riadalrashed) · Team: [LinkedIn](https://hackerone.com/linkedin)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered in LinkedIn's Competitor Analytics API that permitted authenticated users to access analytics data for deactivated company pages.

**Hunt signal:** Collect IDs of soft-deleted/deactivated resources (from account history, cached pages, prior responses), then probe analytics/insights/reporting API endpoints with those IDs — check for 200 responses still returning data.
**Pass-if:** Analytics API validates resource `active`/`status` field before serving data.

---

### Fail-Open in set_tlsext_servername_callback on pyopenssl via unhandled exceptions leads to security bypass

- **2026-03-20** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3558277](https://hackerone.com/reports/3558277) · Reporter: [@uv3doble](https://hackerone.com/uv3doble) · Team: [Python Cryptographic Authority](https://hackerone.com/pyca)

**What**

A vulnerability was discovered in the `pyopenssl` library's handling of the Server Name Indication (SNI) callback (`set_tlsext_servername_callback`). The internal wrapper for this callback catches all Python exceptions raised by user code but returns `0` (Success/`SSL_TLSEXT_ERR_OK`) to the underlying OpenSSL engine. This behavior allowed a TLS connection to be successfully established even when the security validation logic inside the callback crashed or raised an exception, potentially bypassing critical access controls or authentication mechanisms implemented at the SNI layer.

**Hunt signal:** Send TLS ClientHello with empty/malformed SNI (null bytes, zero-length, >255 chars) against targets known to use pyopenssl with SNI-based access control. If connection succeeds where a valid SNI is required, the fail-open is present.
**Grep:** `rg -n 'set_tlsext_servername_callback' src/`
**Pass-if:** Target doesn't use pyopenssl, or SNI callback is used only for routing (not security enforcement).

---

### [Privilege Escalation] User can Pin|Unpin Any Comment on Any Project or Locale

- **2026-03-20** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3025797](https://hackerone.com/reports/3025797) · Reporter: [@adilnbabras](https://hackerone.com/adilnbabras) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Privilege Escalation

**What**

A vulnerability was discovered in the Pontoon application where any user could pin or unpin comments on any project or locale, despite lacking the necessary privileges. This was possible due to the lack of proper access controls in the backend code handling the pin and unpin functionality.

**Hunt signal:** Find comment pin/unpin/toggle endpoints, swap target resource IDs, send POST as low-priv user → check 200 instead of 403.
**Grep:** `rg -n 'def (pin|unpin|toggle).*comment' --type py | rg -v '@(permission|login_required|role)'`
**Nuclei:** `idor`
**Pass-if:** Pin/unpin is a frontend-only feature with no dedicated backend endpoint.

---

### Exposed .git/config File Leading to Potential Sensitive Information Disclosure

- **2026-03-20** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3612891](https://hackerone.com/reports/3612891) · Reporter: [@zoroo2](https://hackerone.com/zoroo2) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Add labels to arbitrary issues/prs & compromise github actions label checks

- **2026-03-19** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3306
- Source: [hackerone.com/3527771](https://hackerone.com/reports/3527771) · Reporter: [@ahacker1](https://hackerone.com/ahacker1) · Team: [GitHub](https://hackerone.com/github)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was identified that allowed a user with read access to a repository and write access to a project to modify issue and pull request metadata through the project. When adding an item to a project that already existed, column value updates were applied without verifying the actor's repository write permissions.

**PoC refs:** search `github.com/search?q=CVE-2026-3306` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3306.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — target-specific GitHub Projects v2 permission boundary, no reusable probe.

---

### PATs without the required scope can leak issues

- **2026-03-19** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3582
- Source: [hackerone.com/3522254](https://hackerone.com/reports/3522254) · Reporter: [@s3rdz0](https://hackerone.com/s3rdz0) · Team: [GitHub](https://hackerone.com/github)
- CWE: Improper Access Control - Generic

**What**

An Incorrect Authorization vulnerability was identified in GitHub Enterprise Server that allowed an authenticated user with a classic personal access token (PAT) lacking the repo scope to retrieve issues and commits from private and internal repositories via the search REST API endpoints. The user must have had existing access to the repository through organization membership or as a collaborator for the vulnerability to be exploitable.

**PoC refs:** search `github.com/search?q=CVE-2026-3582` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3582.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — target-specific to GitHub's PAT scope model and search API auth logic, no reusable trick.

---

### Lack of Validation in Reward Redemption Allows Unlimited Burp Suite License Abuse

- **2026-03-18** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3378540](https://hackerone.com/reports/3378540) · Reporter: [@theokeen](https://hackerone.com/theokeen) · Team: [HackerOne](https://hackerone.com/security)
- CWE: Improper Access Control - Generic

**What**

A vulnerability was discovered in the reward redemption process of a points and rewards system. The vulnerability allowed an attacker to obtain multiple valid Burp Suite Pro licenses by using different email addresses, without any validation or verification tied to the user's account. The email contained a link to redeem the reward, which directed the user to a Google Form. After submitting the form with different email addresses, the attacker received multiple valid licenses. …

**Hunt signal:** pass — business logic flaw in a Google Form reward flow, no reusable technical primitive.

---

### HSTS accepted from HTTP origin behind HTTPS proxy

- **2026-03-17** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3609505](https://hackerone.com/reports/3609505) · Reporter: [@lg_oled77c5pua](https://hackerone.com/lg_oled77c5pua) · Team: [curl](https://hackerone.com/curl)
- CWE: Acceptance of Extraneous Untrusted Data With Trusted Data

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Unescaped username in SASL DIGEST-MD5 response allows injection

- **2026-03-17** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3608522](https://hackerone.com/reports/3608522) · Reporter: [@am-perip](https://hackerone.com/am-perip) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Neutralization of Escape, Meta, or Control Sequences

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Session Cookie Leakage via Static Header Field in WebViewerFragment

- **2026-03-17** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3475626](https://hackerone.com/reports/3475626) · Reporter: [@dphoeniixx](https://hackerone.com/dphoeniixx) · Team: [LinkedIn](https://hackerone.com/linkedin)
- CWE: Misconfiguration

**What**

A vulnerability was identified in the "WebViewerFragment" that could lead to the leakage of the user's cookies. The root cause was a static field ("CUSTOM_HEADERS") that persisted cookies across different URL loads, allowing an attacker to steal the victim's session cookies. The vulnerability was demonstrated through a complex exploitation chain involving chaining multiple weaknesses.

**Hunt signal:** Decompile APK, trace any `WebView` that accepts external URLs → grep for `static` fields storing `Map<String,String>` headers or cookies injected via `loadUrl(url, headers)`.
**Grep:** `rg -n 'static.*Map.*String.*header|static.*CUSTOM_HEADER' --type kotlin --type java`
**Pass-if:** Target is a web-only application with no mobile client.

---

### Business Logic Bypass Allows Setting “Read Access” Role Without Pro Plan Subscription

- **2026-03-16** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3591764](https://hackerone.com/reports/3591764) · Reporter: [@ziadmomen](https://hackerone.com/ziadmomen) · Team: [Lovable VDP](https://hackerone.com/lovable-vdp)
- CWE: Business Logic Errors

**What**

A business logic vulnerability was identified that allowed users on a free plan to generate an invitation link that assigned the "Read Access" role, which was intended to be restricted to users with a Pro Plan subscription. The vulnerability was triggered by manipulating the invitation creation process to bypass the subscription-based permission restrictions.

**Hunt signal:** `curl -X POST '<target>/api/invitations' -H 'Content-Type: application/json' --data-raw '{"email":"test@test.com","role":"read_access"}'` on a free-tier session. If 200, check if invite grants premium permissions.
**Grep:** `rg -n 'invitation.*(create|generate)' src/ | rg -v 'subscription|plan|tier'`
**Pass-if:** Role assignment is enforced via a separate permissions microservice with no direct role param in invite payload.

---

### SMB READ_ANDX DataOffset not validated

- **2026-03-16** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3603300](https://hackerone.com/reports/3603300) · Reporter: [@tavro](https://hackerone.com/tavro) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Unauthenticated access to private files on app.fizzy.do via Active Storage URLs leads to information disclosure

- **2026-03-16** · sev: Low · bounty: $100
- Source: [hackerone.com/3467641](https://hackerone.com/reports/3467641) · Reporter: [@perxibes](https://hackerone.com/perxibes) · Team: [Basecamp](https://hackerone.com/basecamp)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered where unauthenticated users could access private files and file previews on the application through Active Storage URLs. This vulnerability allowed information disclosure, as the files and previews could be accessed without any authentication or authorization checks.

**Hunt signal:** Find Active Storage blob/representation URLs in page source or API responses (`/rails/active_storage/blobs/` or `/rails/active_storage/representations/`), then `curl -L 'https://<target>/rails/active_storage/blobs/<signed_id>/<filename>'` with no session cookie.
**Grep:** `rg -n 'active_storage/(blobs|representations)' app/ | rg -v 'before_action.*(auth|authenticate|verify)'`
**Nuclei:** `idor,rails`
**Pass-if:** Target isn't Ruby on Rails, or Active Storage routes are wrapped in `authenticate_user!` / `before_action` with auth checks.

---

### Authorization Bypass in Starknet Snap via enableAuthorize parameter leads to unauthorized transaction signing

- **2026-03-13** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3507241](https://hackerone.com/reports/3507241) · Reporter: [@aszx87410](https://hackerone.com/aszx87410) · Team: [Consensys](https://hackerone.com/consensys)
- CWE: Business Logic Errors

**What**

A critical security vulnerability was discovered in the Starknet Snap by Consensys. The vulnerability allowed malicious websites to bypass user authorization when signing messages or transactions. The vulnerability existed in the `enableAuthorize` parameter, which could be controlled by any website. When set to `false`, the confirmation dialog was not shown to the user, allowing a malicious website to sign arbitrary messages or transactions without user approval.

**Hunt signal:** pass — target-specific, no reusable trick.

---

### SQL Injection vulnerability found on ibm.com endpoint

- **2026-03-12** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3578842](https://hackerone.com/reports/3578842) · Reporter: [@cr3ckerxploit](https://hackerone.com/cr3ckerxploit) · Team: [IBM](https://hackerone.com/ibm)
- CWE: SQL Injection

**What**

A SQL injection vulnerability was found on an ibm.com endpoint. The vulnerability was reported to IBM, analyzed, and remediated.

**Hunt signal:** pass — summary too thin.

---

### Curl_compareheader() fails to match multi-value HTTP headers

- **2026-03-12** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3598444](https://hackerone.com/reports/3598444) · Reporter: [@henriqueg](https://hackerone.com/henriqueg) · Team: [curl](https://hackerone.com/curl)
- CWE: Expected Behavior Violation

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### urlapi: off-by-one in custom scheme validation skips last character

- **2026-03-12** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3598358](https://hackerone.com/reports/3598358) · Reporter: [@otiscui](https://hackerone.com/otiscui) · Team: [curl](https://hackerone.com/curl)
- CWE: Off-by-one Error

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Bypass of Open Redirect Fix on lovable.dev via /..// Path Traversal in redirect parameter

- **2026-03-12** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3599248](https://hackerone.com/reports/3599248) · Reporter: [@marioniangi](https://hackerone.com/marioniangi) · Team: [Lovable VDP](https://hackerone.com/lovable-vdp)
- CWE: Open Redirect

**What**

A bypass was discovered for a previously patched open redirect vulnerability on a web application. The original fix blocked certain payloads, but failed to account for path traversal sequences combined with double slashes. By supplying a specific redirect value, an attacker could still redirect authenticated users to arbitrary external domains. The vulnerability was caused by an incomplete denylist approach rather than proper validation.

**Hunt signal:** Fuzz any `redirect`/`next`/`return_to`/`url` param with path-traversal sequences: `//..//evil.com`, `/\..//evil.com`, `/%2f..%2f/evil.com`. Check if 302 Location resolves to external domain after normalization.
**Grep:** `rg -n 'redirect|next|return_to' src/ | rg -iv "url\.parse|new URL|allowlist|whitelist"`
**Nuclei:** `open-redirect`
**Pass-if:** Redirect validation uses proper URL parsing (e.g., `new URL().hostname` check) rather than denylist/string-matching.

---

### NULL Pointer Dereference (DoS) in libcurl SFTP QUOTE command parsing due to missing return statement

- **2026-03-11** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3597359](https://hackerone.com/reports/3597359) · Reporter: [@m777m0](https://hackerone.com/m777m0) · Team: [curl](https://hackerone.com/curl)
- CWE: NULL Pointer Dereference

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### CVE-2026-3805: use after free in SMB connection reuse

- **2026-03-11** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3805
- Source: [hackerone.com/3591944](https://hackerone.com/reports/3591944) · Reporter: [@rat5ak](https://hackerone.com/rat5ak) · Team: [curl](https://hackerone.com/curl)
- CWE: Use After Free

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-3805` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3805.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-3784: wrong proxy connection reuse with credentials

- **2026-03-11** · sev: Low · bounty: undisclosed · cve: CVE-2026-3784
- Source: [hackerone.com/3584903](https://hackerone.com/reports/3584903) · Reporter: [@nobcoder](https://hackerone.com/nobcoder) · Team: [curl](https://hackerone.com/curl)
- CWE: Incorrect Authorization

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-3784` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3784.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-3783: token leak with redirect and netrc

- **2026-03-11** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3783, CVE-2025-14524, CVE-2025-0167, CVE-2024-11053
- Source: [hackerone.com/3583983](https://hackerone.com/reports/3583983) · Reporter: [@spectreglobalsec](https://hackerone.com/spectreglobalsec) · Team: [curl](https://hackerone.com/curl)
- CWE: Information Exposure Through Sent Data

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-3783` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3783.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Connection Reuse Ignores OAuth Bearer Token Mismatch

- **2026-03-10** · sev: Medium · bounty: undisclosed · cve: CVE-2022-22576
- Source: [hackerone.com/3595753](https://hackerone.com/reports/3595753) · Reporter: [@sabari_n](https://hackerone.com/sabari_n) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Authentication - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-22576` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-22576.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CURLOPT_UNRESTRICTED_AUTH Dangerous Default Documentation Gap

- **2026-03-10** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3595764](https://hackerone.com/reports/3595764) · Reporter: [@sabari_n](https://hackerone.com/sabari_n) · Team: [curl](https://hackerone.com/curl)
- CWE: Information Disclosure

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Arbitrary Code Execution via Scanner Bypass in **aws-diagram-mcp-server** `exec()` Namespace

- **2026-03-09** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3557138](https://hackerone.com/reports/3557138) · Reporter: [@locus-x64](https://hackerone.com/locus-x64) · Team: [AWS VDP](https://hackerone.com/aws_vdp)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Users can change project visibility which requires high subscription by just changing request body

- **2026-03-09** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3370430](https://hackerone.com/reports/3370430) · Reporter: [@hossam25](https://hackerone.com/hossam25) · Team: [Lovable VDP](https://hackerone.com/lovable-vdp)
- CWE: Improper Access Control - Generic

**What**

A Broken Access Control vulnerability was discovered that allowed users to change project visibility to higher subscription tiers by modifying the request body. The visibility was changed from the default setting to Personal or Workspace, bypassing subscription checks and enabling unauthorized access to premium functionality.

**Hunt signal:** Find project/workspace settings update endpoints (PATCH/PUT to `/api/projects/<id>` or similar), send `{"visibility":"personal"}` or `{"visibility":"workspace"}` — if response is 200 and subscription check is skipped, it's vulnerable.
**Grep:** `rg -n 'visibility.*(public|private|personal|workspace)' src/ | rg -i 'update|patch|set'`
**Pass-if:** Visibility change requires a separate subscription upgrade API call with payment verification before the setting takes effect.

---

### LM Challenge-Response Hash Always Sent in SMB Authentication

- **2026-03-09** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3584491](https://hackerone.com/reports/3584491) · Reporter: [@brewm4ster](https://hackerone.com/brewm4ster) · Team: [curl](https://hackerone.com/curl)
- CWE: Reversible One-Way Hash

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### In curl's SASL OAUTHBEARER authentication, including the SOH character (0x01) in the username corrupts the message structure.

- **2026-03-08** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3584865](https://hackerone.com/reports/3584865) · Reporter: [@y_security](https://hackerone.com/y_security) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Neutralization of Value Delimiters

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Injection in path parameter of Ingress-nginx

- **2026-03-07** · sev: High · bounty: undisclosed · cve: CVE-2021-25748
- Source: [hackerone.com/2701701](https://hackerone.com/reports/2701701) · Reporter: [@fisjkars](https://hackerone.com/fisjkars) · Team: [Kubernetes](https://hackerone.com/kubernetes)
- CWE: Code Injection

**What**

A vulnerability was discovered in the Ingress-nginx controller where an attacker could inject arbitrary content into the path parameter of an Ingress. This allowed the attacker to upload a malicious nginx configuration file to the ingress controller's file system and then include that file in a subsequent Ingress. The attacker could then execute arbitrary code on the ingress controller.

**PoC refs:** search `github.com/search?q=CVE-2021-25748` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2021-25748.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — requires K8s RBAC to create Ingress objects; not a web-huntable pattern.

---

### IDOR to make someone attend or leave an event

- **2026-03-06** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/1734639](https://hackerone.com/reports/1734639) · Reporter: [@safehacker_2715](https://hackerone.com/safehacker_2715) · Team: [LinkedIn](https://hackerone.com/linkedin)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

An Insecure Direct Object Reference (IDOR) vulnerability was discovered in LinkedIn's event attendance functionality. The vulnerability allowed an attacker to manipulate event attendance by modifying the fsd_profile parameter in POST requests to the voyagerScheduledcontentDashViewerStates API endpoint. This issue has been fixed.

**Hunt signal:** POST to event RSVP/attendance endpoints with the victim's profile/user ID swapped into the request body → verify victim's attendance state changed.
**Nuclei:** idor
**Pass-if:** API binds attendance state to the authenticated session token rather than a client-supplied profile parameter.

---

### Blocking a company page admin prevents him from delete paid media admin or edit his roles

- **2026-03-05** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/2339192](https://hackerone.com/reports/2339192) · Reporter: [@riadalrashed](https://hackerone.com/riadalrashed) · Team: [LinkedIn](https://hackerone.com/linkedin)
- CWE: Improper Access Control - Generic

**What**

A company page admin was prevented from managing (deleting or editing roles of) a paid media admin when the paid media admin blocked the company page admin. This created an access control vulnerability where administrative privileges were circumvented through the platform's social blocking feature.

**Hunt signal:** Create two accounts (admin over user), have the user block the admin, then replay the admin's role-edit/delete endpoints (e.g. `curl -b <admin-cookie> -X PATCH 'https://<target>/api/users/<blocker-id>/role' --data-raw '{"role":"member"}'`) — 200/204 confirms the bug.
**Pass-if:** Target has no social blocking/mute feature or admin actions route through a backend service account rather than the admin's user identity.

---

### Open Redirect on lovable.dev via redirect parameter leads to phishing attacks

- **2026-03-05** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3581815](https://hackerone.com/reports/3581815) · Reporter: [@jdc94](https://hackerone.com/jdc94) · Team: [Lovable VDP](https://hackerone.com/lovable-vdp)

**What**

An open redirect vulnerability was discovered on the website lovable.dev. After logging in, a request was sent to a URL with a 'redirect' parameter. By supplying a backslash-prefixed value for the 'redirect' parameter, the user could be redirected to an external domain. This vulnerability could have been exploited to craft malicious URLs on the lovable.dev domain that redirect users to arbitrary external sites.

**Hunt signal:** Find any login/callback endpoint accepting a `redirect`/`next`/`return_to` param and supply a backslash-prefixed URL: `curl -L -v 'https://<target>/login?redirect=\https://evil.com'`. Look for 302 to external domain.
**Grep:** `rg -n 'redirect.*req\.query|next.*req\.query|returnTo.*req\.query' src/ | rg -v 'startsWith.*["\x27]/'`
**Nuclei:** `open-redirect`
**Pass-if:** Target normalizes backslashes to forward slashes before URL parsing, or uses `URL` constructor which strips backslashes.

---

### DoS via Unbounded Memory Allocation in sendWebStream on Fastify v5.7.0+ leads to OOM crash when backpressure is ignored

- **2026-03-05** · sev: — · bounty: undisclosed · cve: CVE-2026-25224
- Source: [hackerone.com/3524779](https://hackerone.com/reports/3524779) · Reporter: [@onlybugs05](https://hackerone.com/onlybugs05) · Team: [Fastify](https://hackerone.com/fastify)

**What**

A vulnerability was discovered in Fastify versions 5.7.0 and later. The issue was in the "sendWebStream" function, which failed to handle TCP backpressure correctly. When a ReadableStream was sent as a response, Fastify continuously pulled data from the stream producer and wrote it to the response object, ignoring the return value of the write operation. This allowed a fast producer to fill the server's memory indefinitely, leading to an Out-Of-Memory (OOM) crash if a client stopped reading the response.

**PoC refs:** search `github.com/search?q=CVE-2026-25224` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-25224.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — library-specific backpressure bug, no reusable probe; just check `package.json` for fastify `>=5.7.0,<patched` and any route calling `reply.send(readableStream)`.

---


## 2026-04-20

### Unfixed Apple/Visa NFC Flaw Drains Locked iPhones
- **Tags:** `#auth-bypass` `#mobile` `#data-exfil`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 36.0 · **Status:** itw · **Age:** 0d
- **Sources:** [1](https://infosecwriteups.com/apple-knows-visa-knows-nobody-has-fixed-it-heres-why-e37796a6e8e2)

- **Trick:** Leveraging NFC Express Transit mode or a relay attack to trick the iPhone into processing Visa transactions without authentication while the device is locked.
- **Why it matters:** Attackers can physically pickpocket a phone and drain associated bank accounts without knowing the passcode, bypassing Apple's core security model.
- **Rating:** novel

---
### Booking.com Got Breached. Your Reservation Was the Weapon.
- **Tags:** `#web` `#idor` `#auth-bypass`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://infosecwriteups.com/booking-com-got-breached-your-reservation-was-the-weapon-fcf6c0ac334f)

- **Trick:** Exploiting weak validation on booking identifiers to access or modify reservations belonging to other users, effectively using the reservation system as a pivot for account takeover or data theft.
- **Why it matters:** Demonstrates how broken access controls (IDOR) in high-value transactional platforms can be weaponized against users, bypassing standard authentication mechanisms by manipulating predictable or insecure object references.
- **Rating:** chain-worthy

---
### Write-Up: BugForge Weekly Challenge — Galaxy Dash with Stored-XSS
- **Tags:** `#xss` `#web`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 21.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@teammyinside/write-up-bugforge-weekly-challenge-galaxy-dash-with-stored-xss-06d0f0a15042?source=rss------pentesting-5)

- **Trick:** Identifying and exploiting a Stored Cross-Site Scripting (XSS) vulnerability within the Galaxy Dash challenge environment.
- **Why it matters:** Stored XSS is critical for user persistence; this writeup demonstrates the specific payload and injection point required to solve the weekly challenge.
- **Rating:** variant

---
### How a Simple OTP Flaw Could Lead to Full Account Takeover
- **Tags:** `#auth-bypass`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://blackmambaa.medium.com/how-a-simple-otp-flaw-could-lead-to-full-account-takeover-12220a10a63b)

- **Trick:** Exploiting a logic error in the OTP verification flow (e.g., response manipulation or state issues) to bypass validation.
- **Why it matters:** Subverts 2FA/MFA protections, allowing attackers to fully compromise user accounts without possessing the secondary factor.
- **Rating:** chain-worthy

---
### ⏱️ Race Conditions — Exploiting Timing for Real Impact
- **Tags:** `#race-condition` `#web`
- **Severity:** critical · **Hunt:** 3/5 · **Score:** 20.25 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://medium.com/bug-bounty-hunting-a-comprehensive-guide-in/%EF%B8%8F-race-conditions-exploiting-timing-for-real-impact-6647ae1958ab?source=rss------bug_bounty-5)

- **Trick:** Exploiting timing discrepancies in race conditions to manipulate operations (e.g., privilege escalation or data manipulation).
- **Why it matters:** Race conditions are prevalent in web applications and can enable critical impacts when combined with other vulnerabilities.
- **Rating:** chain-worthy

---
### Visible Error-Based SQL Injection
- **Tags:** `#sqli`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://meetcyber.net/visible-error-based-sql-injection-5932aab1b6d0?source=rss------bug_bounty-5)

- **Trick:** Leveraging verbose database error messages to directly extract sensitive data such as admin passwords.
- **Why it matters:** Provides a direct path to data exfiltration in vulnerable applications, bypassing the need for time-based or boolean-based blind techniques.
- **Rating:** variant

---
### Kioptrix Level 1: Apache Exploit to Root via ptrace/kmod
- **Tags:** `#rce` `#privesc` `#web`
- **Severity:** critical · **Hunt:** 1/5 · **Score:** 13.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@Punih3r7/kioptrix-level-1-vulnhub-walkthrough-openfuck-apache-exploit-to-root-via-ptrace-kmod-95ef4fea31b4?source=rss------pentesting-5)

- **Trick:** Gains initial shell by exploiting the Apache/mod_ssl vulnerability using the OpenFuck tool, then escalates to root by exploiting the `ptrace` kernel vulnerability or `kmod`.
- **Why it matters:** Serves as a foundational exercise for mastering remote code execution followed by local privilege escalation on legacy Linux systems.
- **Rating:** variant

---
### 5 Vulnerabilities I Find in Almost Every Pentest (After 100+ Tests)
- **Tags:** `#rce` `#sqli` `#xss` `#idor` `#auth-bypass`
- **Severity:** unknown · **Hunt:** 3/5 · **Score:** 6.0 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://medium.com/@Tab1shX/5-vulnerabilities-i-find-in-almost-every-pentest-after-100-tests-cc994baca6e7?source=rss------bug_bounty-5)

- **Trick:** Summary of five critical recurring vulnerabilities discovered across 100+ security assessments
- **Why it matters:** High prevalence indicates systemic security gaps in common development practices
- **Rating:** chain-worthy

---
### Mr Robot TryHackMe Español
- **Tags:** `#web` `#privesc`
- **Severity:** low · **Hunt:** 1/5 · **Score:** 3.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@Us0lfr/mr-robot-tryhackme-espa%C3%B1ol-ea813f4fff9a)

- **Trick:** Walkthrough of the Mr. Robot CTF machine covering web enumeration (WordPress) and Linux privilege escalation (kernel exploits).
- **Why it matters:** Useful educational material for practicing standard CTF methodology, web scanning, and basic system pwnage.
- **Rating:** variant

---
### Intermediate Practical Malware Analysis Course
- **Tags:** `#deserialization` `#command-injection`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 2.0 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://medium.com/@s12deff/intermediate-practical-malware-analysis-course-6e3938c4443b?source=rss------pentesting-5)

- **Trick:** Practical malware analysis techniques covering static/dynamic analysis, reverse engineering, and unpacking for intermediate professionals.
- **Why it matters:** Bridges foundational knowledge to professional-grade analysis, equipping essential skills for real-world threat investigation.
- **Rating:** novel

---
### AI-Driven Pentesting: Integrating Kali Linux with LLMs via MCP
- **Tags:** `#llm` `#mcp`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@mansheman/ai-driven-penetration-testing-integrating-kali-linux-arsenal-with-llms-through-mcp-4b8bd0c00392)

- **Trick:** Implementing the Model Context Protocol (MCP) to create a bridge between LLMs and local Kali Linux tools, enabling the AI to execute commands and analyze results directly rather than merely generating shell scripts.
- **Why it matters:** This integration moves beyond static script generation to dynamic, interactive penetration testing, allowing AI agents to autonomously navigate and utilize the full Kali arsenal within a unified workflow.
- **Rating:** novel

---
### The Current State Agentic Penetration Testing
- **Tags:** `#llm` `#web` `#api`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@anasshlool11/the-current-state-agentic-penetration-testing-2ca2d0874adb)

- **Trick:** Overview and analysis of the current maturity level, workflows, and effectiveness of autonomous AI agents in performing penetration testing tasks.
- **Why it matters:** Understanding the capabilities of agentic pentesting is crucial for anticipating how attackers might scale their operations and for evaluating the reliability of automated AI security tools.
- **Rating:** novel

---


## 2026-04-23

### Complete authentication bypass to admin permissions

- **2026-04-22** · sev: Critical · bounty: undisclosed · cve: CVE-2026-29198
- Source: [hackerone.com/3564655](https://hackerone.com/reports/3564655) · Reporter: [@npc](https://hackerone.com/npc) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: SQL Injection

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-29198` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-29198.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---
