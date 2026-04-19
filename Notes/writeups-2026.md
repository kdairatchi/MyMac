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
### Helium Challenge Batch 2 Write-Up : Menemukan 3 Kerentanan Kritis di Aplikasi Job Portal
- **Tags:** `#web`
- **Severity:** critical · **Hunt:** 2/5 · **Score:** 18.0 · **Status:** patched · **Age:** 0d
- **Sources:** [1](https://medium.com/@subzxd14/helium-challenge-batch-2-write-up-menemukan-3-kerentanan-kritis-di-aplikasi-job-portal-61d461bc73ba?source=rss------pentesting-5) · [2](https://github.com/nomi-sec/PoC-in-GitHub/commit/5d162113ddc09079833b17d363cd479b3bdd726d) · [3](https://meetcyber.net/why-i-thought-i-found-a-zero-day-the-false-positive-trap-in-bug-bounty-3ec08e86fc99) · [4](https://github.com/nomi-sec/PoC-in-GitHub/commit/eee6ffc597e28b85d2ccbe52c1562ab2d4ef1a84) · [5](https://github.com/nomi-sec/PoC-in-GitHub/commit/bb527399f5c226fab24d81df6aab640928a79436)

- **Trick:** Indonesian pentester discovered 3 critical vulnerabilities in a job portal application during the Helium Challenge.
- **Why it matters:** Demonstrates effective vulnerability discovery techniques in a real-world application, providing valuable insights for penetration testers and bug hunters.
- **Rating:** chain-worthy

---
*Clustered 9 sources for this item.*

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
