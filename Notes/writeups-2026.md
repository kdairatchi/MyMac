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

## 2026-04-26

### Argument Injection in /manage/ssh/ via host parameter leads to sensitive file disclosure on Weblate

- **2026-04-26** · sev: — · bounty: undisclosed · cve: CVE-2026-24126
- Source: [hackerone.com/3518571](https://hackerone.com/reports/3518571) · Reporter: [@alexb_616](https://hackerone.com/alexb_616) · Team: [Weblate](https://hackerone.com/weblate)

**What**

A vulnerability was discovered in the SSH management interface of Weblate, a web-based translation tool. The vulnerability allowed an attacker with administrative privileges to inject command-line arguments into the host parameter, leading to sensitive file disclosure on the server. The vulnerable code was found in the ssh() function, where the host parameter was directly appended to a subprocess command without proper sanitization, enabling the attacker to read files like /etc/passwd, Django settings.py, and private SSH keys.

**PoC refs:** search `github.com/search?q=CVE-2026-24126` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-24126.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** POST to SSH-related management endpoints with `host=-o ProxyCommand=cat /etc/passwd` (or `host=-F /etc/shadow`) → check response for file contents.
**Grep:** `rg -n 'subprocess.*(ssh|scp)' src/ | rg -v 'shlex\.split|shell=False'`
**Pass-if:** Endpoint requires non-admin roles OR host param is validated against IP/hostname regex before reaching subprocess.

---

### mruby-engine: UAF in MRubyEngine#initialize enables local RCE

- **2026-04-24** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3679660](https://hackerone.com/reports/3679660) · Reporter: [@0xd0ff9](https://hackerone.com/0xd0ff9) · Team: [Shopify](https://hackerone.com/shopify)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Incomplete fix for CVE-2026-21637: loadSNI() in _tls_wrap.js lacks try/catch leading to Remote DoS

- **2026-04-23** · sev: High · bounty: undisclosed · cve: CVE-2026-21637
- Source: [hackerone.com/3556769](https://hackerone.com/reports/3556769) · Reporter: [@mbarbs](https://hackerone.com/mbarbs) · Team: [Node.js](https://hackerone.com/nodejs)

**What**

A flaw was discovered in the Node.js TLS error handling that left SNICallback invocations unprotected against synchronous exceptions. This represented an incomplete fix of the prior CVE-2026-21637 vulnerability, where the equivalent ALPN and PSK callbacks were already addressed. The issue could lead to a Remote Denial of Service when an SNICallback threw synchronously on unexpected input, causing the exception to bypass TLS error handlers and propagate as an uncaught exception, crashing the Node.js process.

**PoC refs:** search `github.com/search?q=CVE-2026-21637` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-21637.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — library-level CVE (Node.js core); no reusable app-layer probe beyond version fingerprinting.

---

### RBAC bypass on App log endpoints via `permissionRequired` typo — any authenticated user reads admin-only Enterprise App logs

- **2026-04-23** · sev: Medium · bounty: undisclosed · cve: CVE-2026-29197
- Source: [hackerone.com/3589551](https://hackerone.com/reports/3589551) · Reporter: [@arccode](https://hackerone.com/arccode) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Improper Access Control - Generic

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-29197` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-29197.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-05-27

### Heap-OOB read in urlapi `redirect_url()` via `CURLU_GUESS_SCHEME` + `CURLU_NO_GUESS_SCHEME` flow

- **2026-05-25** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3751715](https://hackerone.com/reports/3751715) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Buffer Over-read

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### curl GnuTLS backend accepts a clientAuth-only certificate for HTTPS server authentication

- **2026-05-25** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3752567](https://hackerone.com/reports/3752567) · Reporter: [@jingzhou](https://hackerone.com/jingzhou) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Certificate Validation

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Autotranslate DDP Method Exposes Private Messages Without Authentication or Room Access Check

- **2026-05-25** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3734326](https://hackerone.com/reports/3734326) · Reporter: [@deprrous](https://hackerone.com/deprrous) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### NULL pointer dereference in node:sqlite DatabaseSync#applyChangeset() via malformed SQLite changeset

- **2026-05-23** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3736889](https://hackerone.com/reports/3736889) · Reporter: [@junius](https://hackerone.com/junius) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: NULL Pointer Dereference

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Memory Corruption via TOCTOU Race in SharedArrayBuffer UTF-8 Decode (`StringBytes::Encode`)

- **2026-05-23** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3752489](https://hackerone.com/reports/3752489) · Reporter: [@v1ct0rv0nd00m](https://hackerone.com/v1ct0rv0nd00m) · Team: [Node.js](https://hackerone.com/nodejs)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Group restriction bypass via bearer token in user_oidc (SETTING_RESTRICT_LOGIN_TO_GROUPS not enforced in Backend::getCurrentUserId)

- **2026-05-21** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3572848](https://hackerone.com/reports/3572848) · Reporter: [@msatz](https://hackerone.com/msatz) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Improper Access Control - Generic

**What**

A security inconsistency was identified in the user_oidc app where group-based login restrictions were enforced in the browser OIDC flow but not in bearer token validation. This could have allowed users outside whitelisted groups to access the Nextcloud API with a valid bearer token.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### curl --skip-existing has a TOCTOU race that lets a post-check symlink redirect the later download write

- **2026-05-20** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3747959](https://hackerone.com/reports/3747959) · Reporter: [@sdjasj](https://hackerone.com/sdjasj) · Team: [curl](https://hackerone.com/curl)
- CWE: Time-of-check Time-of-use (TOCTOU) Race Condition

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Credentials forwarded to HTTP after HTTPS→HTTP same-port redirect — url_set_data_creds uses scheme-blind comparator

- **2026-05-20** · sev: None · bounty: undisclosed · cve: CVE-2022-27774, CVE-2024-11053
- Source: [hackerone.com/3733946](https://hackerone.com/reports/3733946) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27774` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27774.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### POST /api/bitcoinWithdrawalFees returns financial data without authentication despite being documented as a USER OPERATION (private endpoint)

- **2026-05-20** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3676308](https://hackerone.com/reports/3676308) · Reporter: [@glferreira-devsecops](https://hackerone.com/glferreira-devsecops) · Team: [CoinMate.io](https://hackerone.com/coinmate)
- CWE: Improper Authentication - Generic

**What**

A vulnerability was discovered in the CoinMate API where the POST /api/bitcoinWithdrawalFees endpoint was accessible without authentication, despite being documented as a private endpoint. The endpoint returned real-time Bitcoin withdrawal fee data without requiring any authentication, unlike other private endpoints which correctly rejected unauthenticated requests. The root cause was determined to be a misconfiguration in the authentication middleware that allowed the request to bypass HMAC-SHA256 signature verification. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### HMAC signature verification omits endpoint and payload allowing request forgery on CoinMate API

- **2026-05-20** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3670955](https://hackerone.com/reports/3670955) · Reporter: [@glferreira-devsecops](https://hackerone.com/glferreira-devsecops) · Team: [CoinMate.io](https://hackerone.com/coinmate)
- CWE: Missing Required Cryptographic Step

**What**

A vulnerability was discovered in the HMAC signature verification process of the CoinMate API. The signature was calculated using only the nonce, client ID, and public key, omitting the HTTP endpoint and request payload. This allowed an attacker to hijack a valid signature intended for a read-only action and use it to execute a malicious action on a different endpoint, bypassing the cryptographic constraints.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### HTTP/3 paused transfer buffers incoming data without bound up to ~1 GiB

- **2026-05-19** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3734947](https://hackerone.com/reports/3734947) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Allocation of Resources Without Limits or Throttling

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Schannel custom-CA path skips Extended Key Usage enforcement

- **2026-05-19** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3734992](https://hackerone.com/reports/3734992) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Connection reuse ignores haproxyprotocol and HAPROXY_CLIENT_IP settings, allowing PROXY context to persist across transfers

- **2026-05-19** · sev: None · bounty: undisclosed · cve: CVE-2026-4873, CVE-2026-5545, CVE-2026-5773, CVE-2026-6429, CVE-2026-6253, CVE-2026-7168, CVE-2026-3784, CVE-2026-3805
- Source: [hackerone.com/3741135](https://hackerone.com/reports/3741135) · Reporter: [@7omoo](https://hackerone.com/7omoo) · Team: [curl](https://hackerone.com/curl)
- CWE: Incorrect Authorization

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-4873` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-4873.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### SSL session-cache peer key omits signature_algorithms: strict-sigalg handle silently resumes a permissive sibling's session

- **2026-05-19** · sev: — · bounty: undisclosed · cve: CVE-2020-8231
- Source: [hackerone.com/3739561](https://hackerone.com/reports/3739561) · Reporter: [@hexproof](https://hackerone.com/hexproof) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Certificate Validation

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2020-8231` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2020-8231.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CURLOPT_PROXY_CAINFO_BLOB silently activates native CA store on Apple builds

- **2026-05-19** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3735179](https://hackerone.com/reports/3735179) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### TLS peer-verification bypass via mid-transfer ssl_config mutation

- **2026-05-19** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3735276](https://hackerone.com/reports/3735276) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### TLS verifyhost bypass in rustls, mbedTLS, and wolfSSL when verifypeer=0

- **2026-05-19** · sev: — · bounty: undisclosed · cve: CVE-2013-4545, CVE-2014-0139
- Source: [hackerone.com/3734095](https://hackerone.com/reports/3734095) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2013-4545` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2013-4545.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### HTTP/2 proxy CONNECT tunnel unbounded 1xx chain (missing Curl_bump_headersize cap in cf-h2-proxy.c)

- **2026-05-19** · sev: None · bounty: undisclosed · cve: CVE-2023-38039
- Source: [hackerone.com/3734020](https://hackerone.com/reports/3734020) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Allocation of Resources Without Limits or Throttling

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2023-38039` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2023-38039.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Cross-repository IDOR in `/settings/security_analysis/bypass_reviewers` allows unauthorized delegated bypass reviewer modification

- **2026-05-19** · sev: Medium · bounty: undisclosed · cve: CVE-2026-3307
- Source: [hackerone.com/3560256](https://hackerone.com/reports/3560256) · Reporter: [@ahacker1](https://hackerone.com/ahacker1) · Team: [GitHub](https://hackerone.com/github)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was identified in GitHub Enterprise Server that allowed an attacker with admin access on one repository to modify the secret scanning push protection delegated bypass reviewer list on another repository. Authorization was verified against the repository in the URL, but the action was applied to a different repository specified in the request body. The vulnerability was limited to assigning existing trusted users as bypass reviewers and did not allow adding arbitrary external users. …

**PoC refs:** search `github.com/search?q=CVE-2026-3307` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3307.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### CURLOPT_HSTS_CTRL disables shared HSTS without share guard — use-after-free and double-free

- **2026-05-18** · sev: — · bounty: undisclosed · cve: CVE-2018-16840, CVE-2023-27537
- Source: [hackerone.com/3733934](https://hackerone.com/reports/3733934) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Use After Free

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2018-16840` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2018-16840.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### cookie: case-insensitive path comparison in replace_existing() allows cookie eviction across distinct paths

- **2026-05-18** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3735238](https://hackerone.com/reports/3735238) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### libssh SFTP initialization ignores CURLOPT_TIMEOUT, hangs indefinitely

- **2026-05-18** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3735080](https://hackerone.com/reports/3735080) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Allocation of Resources Without Limits or Throttling

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### rustls backend silently ignores CURLOPT_CRLFILE when native CA store is active

- **2026-05-18** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3734935](https://hackerone.com/reports/3734935) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### HSTS multi-trailing-dot bypass-ish: possible incomplete fix for CVE-2022-30115

- **2026-05-18** · sev: Medium · bounty: undisclosed · cve: CVE-2022-30115
- Source: [hackerone.com/3733984](https://hackerone.com/reports/3733984) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Cleartext Transmission of Sensitive Information

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-30115` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-30115.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Unauthenticated File Upload to CDN

- **2026-05-18** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3589247](https://hackerone.com/reports/3589247) · Reporter: [@ph0r3nsic](https://hackerone.com/ph0r3nsic) · Team: [Enjin](https://hackerone.com/enjin)
- CWE: Improper Access Control - Generic

**What**

An unauthenticated file upload vulnerability was discovered in the NFT.io platform. The vulnerability allowed an unauthenticated user to upload files to the platform's content delivery network. The issue was reported and promptly fixed by the Enjin team, despite the low-impact nature of the vulnerability.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### IDOR: autotranslate.translateMessage Full Message Content Leak

- **2026-05-18** · sev: Medium · bounty: undisclosed · cve: CVE-2026-32994
- Source: [hackerone.com/3713682](https://hackerone.com/reports/3713682) · Reporter: [@josan_george](https://hackerone.com/josan_george) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

The `/api/v1/autotranslate.translateMessage` endpoint allowed any authenticated user to retrieve the full content of any message from any room, including private groups, direct messages, and channels. The endpoint fetched the message without performing a room access check, returning the complete message object including the message text, sender information, room ID, timestamps, and markdown content.

**PoC refs:** search `github.com/search?q=CVE-2026-32994` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-32994.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Trailing-dot IPv4 URL bypasses IP-address guard, allows wildcard DNS SAN match

- **2026-05-17** · sev: None · bounty: undisclosed · cve: CVE-2022-30115
- Source: [hackerone.com/3734921](https://hackerone.com/reports/3734921) · Reporter: [@giant_anteater](https://hackerone.com/giant_anteater) · Team: [curl](https://hackerone.com/curl)
- CWE: Business Logic Errors

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-30115` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-30115.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### NULL pointer dereference in libcurl URL API redirect_url() with CURLU_DEFAULT_SCHEME

- **2026-05-17** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3736234](https://hackerone.com/reports/3736234) · Reporter: [@mulan_dh](https://hackerone.com/mulan_dh) · Team: [curl](https://hackerone.com/curl)
- CWE: NULL Pointer Dereference

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### SQL Injection in Column Type Parameter Allows Arbitrary SQL Execution

- **2026-05-15** · sev: High · bounty: undisclosed · cve: CVE-2026-45545
- Source: [hackerone.com/3462991](https://hackerone.com/reports/3462991) · Reporter: [@suul](https://hackerone.com/suul) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: SQL Injection

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-45545` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45545.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Kerberos/SPNEGO Connection Reuse Vulnerability

- **2026-05-14** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3725659](https://hackerone.com/reports/3725659) · Reporter: [@rootofpi_ramesh](https://hackerone.com/rootofpi_ramesh) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### QuickSight Authorization Bypass: Chat Agents Accessible Despite Custom Permissions Denial

- **2026-05-12** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3577145](https://hackerone.com/reports/3577145) · Reporter: [@jcow](https://hackerone.com/jcow) · Team: [AWS VDP](https://hackerone.com/aws_vdp)

**What**

A vulnerability was discovered in Amazon Quick Suite (formerly QuickSight) that allowed users to access and interact with AI chat agents, despite administrative restrictions being in place to disable this functionality. The vulnerability was caused by the lack of proper server-side authorization checks, which enabled users to bypass the configured custom permissions and access the AI chat agents.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### another liberapay member team twitter account broken Link Hijacking via Expired Twitter Account Link

- **2026-05-09** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3723002](https://hackerone.com/reports/3723002) · Reporter: [@rox-11](https://hackerone.com/rox-11) · Team: [Liberapay](https://hackerone.com/liberapay)
- CWE: Open Redirect

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Liberapay member team twitter account broken Link Hijacking via Expired Twitter Account Link

- **2026-05-09** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3721519](https://hackerone.com/reports/3721519) · Reporter: [@rox-11](https://hackerone.com/rox-11) · Team: [Liberapay](https://hackerone.com/liberapay)
- CWE: Open Redirect

**What**

The profile of a Liberapay team member contained a link to an expired Twitter account, creating a broken link hijacking vulnerability. The expired Twitter account link was displayed on the member's Liberapay profile and donation page, falsely confirming to donors that the account was legitimate and verified.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Private circle can be added to another circle via API despite visibility restriction

- **2026-05-08** · sev: Low · bounty: $150 · cve: CVE-2026-45155
- Source: [hackerone.com/3511998](https://hackerone.com/reports/3511998) · Reporter: [@vidang04](https://hackerone.com/vidang04) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

A vulnerability was discovered where private circles could be added to other circles via the API, despite visibility restrictions.

**PoC refs:** search `github.com/search?q=CVE-2026-45155` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45155.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Files drop share links for end-to-end encrypted folders allowed to drop files into other folders of the share owner 

- **2026-05-08** · sev: Low · bounty: undisclosed · cve: CVE-2026-45159
- Source: [hackerone.com/3304830](https://hackerone.com/reports/3304830) · Reporter: [@0x0doteth](https://hackerone.com/0x0doteth) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Insecure Direct Object Reference (IDOR)

**What**

Files drop share links for end-to-end encrypted folders allowed to drop files into other folders of the share owner.

**PoC refs:** search `github.com/search?q=CVE-2026-45159` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45159.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### View-only guests could see deleted Collectives pages in the trashbin

- **2026-05-08** · sev: Low · bounty: undisclosed · cve: CVE-2026-45154
- Source: [hackerone.com/3521434](https://hackerone.com/reports/3521434) · Reporter: [@yoyomiski](https://hackerone.com/yoyomiski) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Improper Access Control - Generic

**What**

A vulnerability was discovered where view-only guests could see deleted Collectives pages in the trashbin.

**PoC refs:** search `github.com/search?q=CVE-2026-45154` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-45154.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### mbedTLS private-key blob null-termination asymmetry in lib/vtls/mbedtls.c (mbed_load_privkey)

- **2026-05-07** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3717365](https://hackerone.com/reports/3717365) · Reporter: [@shecantcode2](https://hackerone.com/shecantcode2) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Null Termination

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### ActiveStorage Disk Service Path Traversal via Custom Blob Key Injection

- **2026-05-07** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3580511](https://hackerone.com/reports/3580511) · Reporter: [@ksw9722](https://hackerone.com/ksw9722) · Team: [Ruby on Rails](https://hackerone.com/rails)
- CWE: Path Traversal

**What**

A vulnerability was discovered in the ActiveStorage Disk Service component of Ruby on Rails. The vulnerability allowed an attacker to achieve arbitrary file write, read, and delete on the server's filesystem by injecting a malicious blob key. The vulnerability was due to insufficient validation of the blob key parameter before constructing file paths. This could be exploited by an attacker who could influence the hash passed to the `.attach()` method.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Critical Deadlock Vulnerability in Monero RPC Leading to Complete Node Paralysis

- **2026-05-06** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3307874](https://hackerone.com/reports/3307874) · Reporter: [@rorkh](https://hackerone.com/rorkh) · Team: [Monero](https://hackerone.com/monero)
- CWE: Uncontrolled Resource Consumption

**What**

A deadlock vulnerability was discovered in the Monero JSON-RPC interface that allowed a remote, unauthenticated attacker to completely paralyze any Monero node with a single HTTP request containing specific batch methods, leading to permanent denial of service. The vulnerability affected all releases of Monero up to version 0.18.4.2 and likely previous versions, across all operating systems. The vulnerability was rated as critical, with a CVSS 3.0 score of 10.0.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Connection Count Bug in Monero Node Enables Outbound Peer Reset Attack

- **2026-05-06** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3185083](https://hackerone.com/reports/3185083) · Reporter: [@yulge](https://hackerone.com/yulge) · Team: [Monero](https://hackerone.com/monero)
- CWE: Privacy Violation

**What**

A vulnerability was disclosed that could cause a Monero node's outbound connections to be dropped. The vulnerability was caused by a flaw in how the node incorrectly counted the number of current outbound connections. An attacker could exploit this flaw to trick the node into mistakenly believing it had exceeded the outbound connection maximum limit, prompting it to actively disconnect legitimate outbound connections.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### wcurl treats some URL operands after -- as curl options

- **2026-05-06** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3708482](https://hackerone.com/reports/3708482) · Reporter: [@p4p3r_hak](https://hackerone.com/p4p3r_hak) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Neutralization of Value Delimiters

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Out of scope: Improper Input Validation Order on /api-internal/login via password field leads to unnecessary resource consumption

- **2026-05-05** · sev: Low · bounty: $200
- Source: [hackerone.com/3625600](https://hackerone.com/reports/3625600) · Reporter: [@bereza4321](https://hackerone.com/bereza4321) · Team: [PortSwigger Web Security](https://hackerone.com/portswigger)

**What**

A security issue was discovered in the /api-internal/login authentication endpoint of the internal login interface of Burp Suite DAST (Enterprise). The issue was caused by improper input validation order, where the application processed user-supplied input before enforcing field-level validation. This allowed extremely large payloads in the password field to be buffered and parsed prior to rejection, resulting in unnecessary resource consumption. The application fully processed the requests before applying validation, violating the fail-fast principle.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Potential Resource Leak in tool_parsecfg.c at line 279 during fileerror

- **2026-05-05** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3710209](https://hackerone.com/reports/3710209) · Reporter: [@ravindrasl2026](https://hackerone.com/ravindrasl2026) · Team: [curl](https://hackerone.com/curl)
- CWE: Uncontrolled Resource Consumption

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### libcurl 8.20.0 incomplete fix for CVE-2026-7168: changing only CURLOPT_PROXYPORT leaks stale Proxy Digest auth to a different proxy

- **2026-05-05** · sev: Medium · bounty: undisclosed · cve: CVE-2026-7168
- Source: [hackerone.com/3707747](https://hackerone.com/reports/3707747) · Reporter: [@codexxxx](https://hackerone.com/codexxxx) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-7168` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-7168.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### MQTT CONNACK Packet Type Bypass leads to RCE via Malicious Broker

- **2026-05-05** · sev: Critical · bounty: undisclosed
- Source: [hackerone.com/3712343](https://hackerone.com/reports/3712343) · Reporter: [@orelbn7](https://hackerone.com/orelbn7) · Team: [curl](https://hackerone.com/curl)
- CWE: ASI05: Unexpected Code Execution (RCE)

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Improper input validation On Exported deep-link handler crashes `FileDisplayActivity` on crafted external URL — Denial-of-Service

- **2026-05-01** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3399016](https://hackerone.com/reports/3399016) · Reporter: [@khoof](https://hackerone.com/khoof) · Team: [Nextcloud](https://hackerone.com/nextcloud)
- CWE: Improper Null Termination

**What**

A vulnerability was discovered in the Nextcloud Android client application where improper input validation in the exported deep-link handler caused a null dereference in the FileDisplayActivity component. This resulted in an unhandled NullPointerException and application crash when the deep-link was invoked. An attacker-controlled link or malicious app could trigger this behavior, leading to a denial-of-service incident.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Double fdrop on a socket through sys_netcontrol

- **2026-05-01** · sev: High · bounty: $10,000
- Source: [hackerone.com/3320669](https://hackerone.com/reports/3320669) · Reporter: [@slidybat](https://hackerone.com/slidybat) · Team: [PlayStation](https://hackerone.com/playstation)
- CWE: Double Free

**What**

The netcontrol syscall in the kernel had a vulnerability where the socket file descriptor was not properly validated when removing a socket from a netevent structure. This allowed an attacker to cause a double fdrop on a socket, potentially leading to a use-after-free condition.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### MQTT state machine confusion: PINGRESP/DISCONNECT with non-zero remaining_length dispatches to stale nextstate

- **2026-04-29** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3702718](https://hackerone.com/reports/3702718) · Reporter: [@fxv_ray_st](https://hackerone.com/fxv_ray_st) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Input Validation

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Use-After-Free in SMB connection reuse (req->path dangling pointer after needle destruction)

- **2026-04-29** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3591956](https://hackerone.com/reports/3591956) · Reporter: [@nadsec42](https://hackerone.com/nadsec42) · Team: [curl](https://hackerone.com/curl)
- CWE: Use After Free

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Negotiate connection reuse with wrong credentials when using CURLAUTH_ANY                                        

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-1965
- Source: [hackerone.com/3646072](https://hackerone.com/reports/3646072) · Reporter: [@anonymous_237](https://hackerone.com/anonymous_237) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-1965` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-1965.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Negotiate Authentication Premature on Connection Reuse

- **2026-04-29** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3666576](https://hackerone.com/reports/3666576) · Reporter: [@sdainard](https://hackerone.com/sdainard) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Authentication - Generic

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### CVE-2026-7168: cross-proxy Digest auth state leak

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-7168
- Source: [hackerone.com/3697719](https://hackerone.com/reports/3697719) · Reporter: [@xkilua](https://hackerone.com/xkilua) · Team: [curl](https://hackerone.com/curl)
- CWE: Exposure of Data Element to Wrong Session

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-7168` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-7168.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-7009: OCSP stapling bypass with Apple SecTrust

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2024-8096, CVE-2024-0853, CVE-2026-7009
- Source: [hackerone.com/3694390](https://hackerone.com/reports/3694390) · Reporter: [@3lcarry](https://hackerone.com/3lcarry) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Certificate Validation

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2024-8096` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2024-8096.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-6253: proxy credentials leak over redirect-to proxy

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-6253
- Source: [hackerone.com/3669637](https://hackerone.com/reports/3669637) · Reporter: [@joesephdiver](https://hackerone.com/joesephdiver) · Team: [curl](https://hackerone.com/curl)

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-6253` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-6253.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-5545: wrong reuse of HTTP Negotiate connection

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-5545
- Source: [hackerone.com/3642555](https://hackerone.com/reports/3642555) · Reporter: [@quaccws](https://hackerone.com/quaccws) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-5545` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-5545.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-6276: stale custom cookie host causes cookie leak

- **2026-04-29** · sev: Low · bounty: undisclosed · cve: CVE-2026-6276
- Source: [hackerone.com/3671818](https://hackerone.com/reports/3671818) · Reporter: [@arkss](https://hackerone.com/arkss) · Team: [curl](https://hackerone.com/curl)
- CWE: Exposure of Data Element to Wrong Session

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-6276` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-6276.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-6429: netrc credential leak with reused proxy connection

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-6429
- Source: [hackerone.com/3677759](https://hackerone.com/reports/3677759) · Reporter: [@nobcoderr](https://hackerone.com/nobcoderr) · Team: [curl](https://hackerone.com/curl)
- CWE: Information Exposure Through Sent Data

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-6429` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-6429.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-4873: connection reuse ignores TLS requirement

- **2026-04-29** · sev: Low · bounty: undisclosed · cve: CVE-2026-4873
- Source: [hackerone.com/3621851](https://hackerone.com/reports/3621851) · Reporter: [@bonaire](https://hackerone.com/bonaire) · Team: [curl](https://hackerone.com/curl)
- CWE: Cleartext Transmission of Sensitive Information

**What**

A vulnerability was discovered in libcurl's connection reuse for cleartext-upgrade mail protocols. The vulnerability was that the later transfer's CURLOPT_USE_SSL option was not properly included if a plaintext connection was already open and reusable. This affected the smtp://, pop3://, and imap:// protocols. The vulnerability could allow a later TLS-required mail transfer to be sent over a previously established plaintext connection, contrary to expectation.

**PoC refs:** search `github.com/search?q=CVE-2026-4873` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-4873.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### CVE-2026-5773: wrong reuse of SMB connection

- **2026-04-29** · sev: Low · bounty: undisclosed · cve: CVE-2026-5773
- Source: [hackerone.com/3650689](https://hackerone.com/reports/3650689) · Reporter: [@osama-hamad](https://hackerone.com/osama-hamad) · Team: [curl](https://hackerone.com/curl)

**What**

A vulnerability was discovered in curl version 8.19.0 and earlier versions that support SMB. The vulnerability was due to the incorrect reuse of SMB connections across different shares on the same server. This led to data spoofing and access control bypass. The issue was caused by the lack of verification of the target share name when reusing an existing connection. As a result, the application could silently fetch data from an unintended share.

**PoC refs:** search `github.com/search?q=CVE-2026-5773` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-5773.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Use-after-free in `curl_easy_ssls_export()` during callback re-entrancy

- **2026-04-29** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3682666](https://hackerone.com/reports/3682666) · Reporter: [@m1llie](https://hackerone.com/m1llie) · Team: [curl](https://hackerone.com/curl)
- CWE: Use After Free

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Heap-buffer-overflow in `Curl_ssl_push_certinfo_len()` — sole bounds check is `DEBUGASSERT`

- **2026-04-29** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3684614](https://hackerone.com/reports/3684614) · Reporter: [@h3zh3z](https://hackerone.com/h3zh3z) · Team: [curl](https://hackerone.com/curl)
- CWE: Out-of-bounds Read

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Stack exhaustion in MIME multipart reading with deeply nested subparts

- **2026-04-29** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3684603](https://hackerone.com/reports/3684603) · Reporter: [@wi110w](https://hackerone.com/wi110w) · Team: [curl](https://hackerone.com/curl)
- CWE: Uncontrolled Recursion

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### PS4 BD-J privilege escalation using nested JAR

- **2026-04-29** · sev: Medium · bounty: $2,500
- Source: [hackerone.com/3452696](https://hackerone.com/reports/3452696) · Reporter: [@gezine](https://hackerone.com/gezine) · Team: [PlayStation](https://hackerone.com/playstation)
- CWE: Privilege Escalation

**What**

A PS4 vulnerability was discovered in the Blu-ray Disc Java (BD-J) privilege escalation using nested JAR files. The vulnerability was found in the PS4 system software versions 13.00 to the latest version 13.02. The vulnerability was caused by a discrepancy between the security policy's path canonicalization and the actual class loading path. The security policy granted AllPermission to code that appeared to be loaded from a trusted directory, while the actual code was loaded from an untrusted nested JAR on the Blu-ray disc. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### IBM Aspera HTTP Gateway stores sensitive information in clear text in easily obtainable files which can be read by an unauthenticated user.

- **2026-04-27** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3340797](https://hackerone.com/reports/3340797) · Reporter: [@jhon1231248e](https://hackerone.com/jhon1231248e) · Team: [IBM](https://hackerone.com/ibm)
- CWE: Information Disclosure

**What**

The IBM Aspera HTTP Gateway stored sensitive information in clear text in easily obtainable files, which could be read by an unauthenticated user. The issue was submitted to IBM, analyzed, and remediated.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Bypass of Restricted Keyword "Mozilla" in Display Name Field via Unicode Homoglyphs on addons.allizom.org

- **2026-04-27** · sev: Low · bounty: $500
- Source: [hackerone.com/3279441](https://hackerone.com/reports/3279441) · Reporter: [@icecream_23](https://hackerone.com/icecream_23) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Improper Input Validation

**What**

A restricted keyword bypass vulnerability was discovered on the Firefox Add-ons platform that allowed an attacker to register a display name visually identical to "Mozilla" by using a Unicode homoglyph character. This circumvented the intended restriction and could have been used to impersonate official accounts.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Bypassing Inbox Privacy Settings and Enabling Spam on Pixiv.net

- **2026-04-27** · sev: Low · bounty: $200
- Source: [hackerone.com/3100570](https://hackerone.com/reports/3100570) · Reporter: [@aaqibhussain](https://hackerone.com/aaqibhussain) · Team: [pixiv](https://hackerone.com/pixiv)
- CWE: Improper Access Control - Generic

**What**

A vulnerability was discovered in the messaging system of Pixiv.net. The vulnerability allowed any user to bypass the inbox privacy settings and send messages to another user who had disabled their inbox. The vulnerability was triggered by manipulating the id parameter in the message-sending POST request. Additionally, the lack of rate limiting or duplicate request validation allowed attackers to spam users by repeatedly sending the same or modified requests.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### Non-premium user can disable Ads in japanese version of dic.pixiv.net

- **2026-04-27** · sev: High · bounty: $3,000
- Source: [hackerone.com/3183520](https://hackerone.com/reports/3183520) · Reporter: [@lainkusanagi](https://hackerone.com/lainkusanagi) · Team: [pixiv](https://hackerone.com/pixiv)
- CWE: Business Logic Errors

**What**

A vulnerability was identified in the Japanese version of the pixiv dictionary website where non-premium users could disable advertisements. Normally, the ability to disable ads was restricted to premium users only. However, due to improper access control, any authenticated user could modify their ad display preferences without verification of premium status.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

## 2026-06-27

### I Made OpenID Connect Stop Checking Signatures
- **Date:** 2026-06-25 · **Source:** [medium.com — title-only; direct URL blocked 403](https://github.com/rix4uni/medium-writeups) · **Class:** writeup
- **What:** Researcher bypassed OIDC JWT signature verification on a real target using a JWS JWK header injection or `alg: none` technique against an Authlib-backed OIDC provider, achieving token forgery with no valid credentials.
- **Why it matters:** Any Python app using Authlib ≤ 1.6.6 for OIDC is vulnerable; affects Flask/FastAPI SSO integrations and custom OAuth2 authorization servers — wide BB surface.
- **Hunt signal:** `grep -r "authlib" requirements.txt pip freeze 2>/dev/null | grep authlib`; test by crafting JWT with `"alg":"none"` header and empty signature segment (`.`) and submitting to protected endpoint
- **Evidence:** [Authlib GHSA-wvwj-cvrp-7pv5 JWK Header Injection](https://github.com/lepture/authlib/security/advisories/GHSA-wvwj-cvrp-7pv5) · [Authlib GHSA-7wc2-qxgw-g8gg alg:none](https://github.com/lepture/authlib/security/advisories/GHSA-7wc2-qxgw-g8gg) · [writeup title surfaced 2026-06-25 via medium-writeups tracker]

---


## 2026-07-01

### Server-Side Parameter Injection — $6,500 High-Severity Payout
- **Tags:** `#ssrf` `#web` `#api`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@21bec131/how-an-unchecked-server-side-parameter-injection-earned-a-6-500-high-severity-payout-10abec521232)

- **Trick:** Injecting parameters into server-side requests that pass between internal backend services, exploiting the assumption that backends operate as a unified black box rather than distinct components that may forward unchecked input to each other.
- **Why it matters:** Demonstrates that internal service boundaries often lack input validation, and treating the backend as a monolith causes testers to miss parameter-level injection opportunities that yield high-severity findings.
- **Rating:** chain-worthy

---
### Race Condition Breaking Organization Administration
- **Tags:** `#race-condition` `#web` `#api`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 31.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@omaralgbry1/how-i-found-a-race-condition-that-broke-organization-administration-ea9bd9f914ab)

- **Trick:** Exploiting a race condition in organization administration endpoints by sending concurrent requests to bypass intended authorization or state checks.
- **Why it matters:** Race conditions in admin flows can allow privilege escalation, unauthorized role assignment, or bypassing business logic restrictions that are otherwise enforced sequentially.
- **Rating:** chain-worthy

---
### Intigriti LeakyJar Challenge — One-Click CSRF to Expose Private Data
- **Tags:** `#csrf` `#web`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 15.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@shadowbugbounty32/how-i-solved-intigritis-leakyjar-challenge-one-click-csrf-to-expose-the-master-baker-s-private-fa19b99c4a2a?source=rss------bug_bounty-5)

- **Trick:** One-click CSRF that forces a victim to perform an authenticated action, leaking the "Master Baker's" private data through a crafted cross-origin request.
- **Why it matters:** Demonstrates that even simple CSRF on non-state-changing endpoints can be weaponized for data exfiltration when combined with a leakage point — relevant for bug bounty programs that dismiss CSRF as low-impact.
- **Rating:** variant

---
### Auth Bypass via Session Token Reuse Leading to Account Takeover
- **Tags:** `#auth-bypass` `#web` `#api`
- **Severity:** high · **Hunt:** 2/5 · **Score:** 14.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@youssefawad1357/authentication-bypass-via-session-token-reuse-leading-to-account-takeover-9f24022c32ed)

- **Trick:** Reusing or failing to invalidate a session token after authentication state changes (e.g., logout, password reset) allows an attacker to bypass auth and take over another user's account.
- **Why it matters:** Session token reuse is a subtle logic flaw that can lead to full account takeover without needing credentials — highly impactful in bug bounty contexts, especially on platforms that don't strictly rotate tokens on privilege-boundary transitions.
- **Rating:** variant

---
### PEB Corruption — A Remote Process Crash Technique
- **Tags:** `#privesc`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://medium.com/@s12deff/peb-corruption-a-remote-process-crash-technique-4b25f8887678?source=rss------pentesting-5)

- **Trick:** Corrupt the Process Environment Block (PEB) of a remote Windows process — overwriting critical runtime metadata like image base and heap pointers — to force an uncatchable crash.
- **Why it matters:** Crashing a privileged or security process via PEB manipulation can clear the way for privilege escalation or defense evasion; useful as a chain link when you have write primitives but not full code exec.
- **Rating:** chain-worthy

---
### MD2PDF — Markdown-to-PDF Conversion Vulnerability
- **Tags:** `#xss` `#rce` `#web`
- **Severity:** unknown · **Hunt:** 2/5 · **Score:** 8.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@shachinpr29/md2pdf-a57938883ccc?source=rss------pentesting-5)

- **Trick:** Exploiting a markdown-to-PDF converter (details truncated in RSS feed — likely involves injecting malicious markdown/markup that gets rendered/executed during PDF generation).
- **Why it matters:** MD2PDF tools are frequently exposed as web services and often use unsandboxed rendering engines (puppeteer, wkhtmltopdf, etc.), making them fertile ground for XSS-to-RCE or SSRF chains.
- **Rating:** unknown — full writeup behind paywall; revisit if details surface

---
### NASA VDP Vulnerability Disclosure Recognition
- **Tags:** `#web`
- **Severity:** unknown · **Hunt:** 1/5 · **Score:** 4.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://abuhuzaifa768.medium.com/alhamdulillah-d110b013ae0d?source=rss------bug_bounty-5)

- **Trick:** No technical details shared — post is a recognition/announcement only.
- **Why it matters:** Confirms NASA VDP has attack surface worth probing, but provides zero actionable detail.
- **Rating:** variant

---
### Web Hacking Part 5 — BurpSuite Basics
- **Tags:** `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@vorasmit22/web-hacking-part-5-32616fdd0a81?source=rss------infosec-5)

- **Trick:** Basic introduction to BurpSuite for intercepting and testing web traffic.
- **Why it matters:** Beginner-level tutorial covering BurpSuite fundamentals; no novel technique or vulnerability demonstrated.
- **Rating:** variant

---
### Common Crypto Laundering Techniques & Infrastructure
- **Tags:** `#data-exfil` `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@iamabraham/part-2-common-laundering-techniques-and-laundering-infrastructure-df4fd7ccc81f?source=rss------infosec-5) · [2](https://amanisher.medium.com/windows-to-linux-5-file-transfer-techniques-for-pentesting-exams-8754e8b46c87?source=rss------pentesting-5) · [3](https://infosecwriteups.com/beyond-canarytokens-building-a-diy-document-tripwire-with-passive-os-fingerprinting-c39716d386f6?source=rss------pentesting-5)

- **Trick:** Overview of common cryptocurrency money laundering methods and the infrastructure (mixers, nested exchanges, chain-hopping) that enables them.
- **Why it matters:** Understanding laundering patterns helps identify suspicious transaction flows and misconfigured/exposed financial services that could be reported through bug bounty or VDP programs.
- **Rating:** variant

---
*Clustered 3 sources for this item.*

### Open-Source Cyber Deception Canaries with Wazuh
- **Tags:** `#docker` `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@termineandrea04/open-source-cyber-deception-canaries-integrated-with-wazuh-5ec938c414ef?source=rss------infosec-5)

- **Trick:** Deploy distroless Docker canary containers via HoneyWire and forward high-fidelity trip alerts into Wazuh SIEM for attacker detection.
- **Why it matters:** Deception-based detection is a strong complement to traditional defenses; canary alerts are inherently low-noise, high-signal — useful for bug bounty hunters to understand how defenders catch recon and lateral movement.
- **Rating:** variant

---
### Building with Terraform on AWS: Infrastructure as Code
- **Tags:** `#aws` `#cloud`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://meetcyber.net/part-2-building-with-terraform-on-aws-infrastructure-as-code-94da825851de?source=rss------bug_bounty-5)

- **Trick:** Introductory Terraform IaC tutorial on AWS — no specific vulnerability or exploitation technique documented.
- **Why it matters:** Familiarity with Terraform configurations can help identify misconfigured AWS resources (overly permissive IAM policies, exposed S3 buckets, unencrypted resources) in bug bounty targets that use IaC.
- **Rating:** variant

---
### How CREST Pen Testing Helps Reduce Cyber Security Risks
- **Tags:** `#api` `#cloud` `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 0.5 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://medium.com/@Qualysec.Europe/how-crest-pen-testing-helps-reduce-cyber-security-risks-6993f9c20f5e?source=rss------pentesting-5)

- **Trick:** None — this is a promotional overview of CREST-accredited penetration testing and its claimed benefits for reducing organizational cyber risk.
- **Why it matters:** No actionable bug bounty intelligence; purely informational/marketing content about CREST certification standards with no specific technique or vulnerability detail.
- **Rating:** variant

---

---

### Reversing CVE-2026-25526: From Patch Diff to File Read in HubSpot's Jinjava Template Engine
- **Date:** 2026-07-02 · **Source:** [av4nth1ka.github.io](https://av4nth1ka.github.io/jinjava-rce-cve-2026-25526/) · **Class:** technique
- **What:** Researcher reverse-engineers the CVE-2026-25526 patch diff to reconstruct the full exploit path — ForTag property enumeration via Introspector.getBeanInfo() bypasses sandbox resolver, then ObjectMapper deserialization instantiates restricted classes for arbitrary file read.
- **Why it matters:** Demonstrates patch-diff methodology to find SSTI sandbox bypasses in Java template engines without source access; directly applicable to any CMS or SaaS exposing Jinja/Freemarker/Velocity rendering.
- **Rating:** chain-worthy
