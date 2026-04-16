# writeups-2026


## 2026-04-16

### CVE-2026-22679: Unauthenticated RCE in Weaver E-cology — `CVE-2026-22679`
- **Tags:** `#rce`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 45.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://medium.com/@keraattin/cve-2026-22679-unauthenticated-rce-in-weaver-e-cology-7fa97c1e904b?source=rss------infosec-5)

### CVE-2026–22679: Unauthenticated RCE in Weaver E-cology
- **Trick:** The article discusses a critical vulnerability allowing unauthenticated RCE in Weaver E-cology enterprise software.
- **Why it matters:** This represents a severe risk as it allows complete system compromise without requiring authentication.
- **Rating:** novel

---
### FortiClient EMS Zero-Day CVE-2026-35616 Exploited — `CVE-2026-35616`
- **Tags:** `#fortinet` `#rce` `#appliance`
- **Severity:** critical · **Hunt:** 5/5 · **Score:** 45.0 · **Status:** itw · **Age:** 0d
- **Sources:** [1](https://medium.com/@alidak/forticlient-ems-gets-a-second-zero-day-in-one-week-cve-2026-35616-is-already-being-exploited-469960f238cb)

### FortiClient EMS Zero-Day CVE-2026-35616 Exploited
- **Trick:** Exploitation of a new zero-day (CVE-2026-35616) in FortiClient EMS occurring immediately after organizations patched a separate vulnerability (CVE-2026-21643).
- **Why it matters:** Active in-the-world exploitation allows attackers to compromise enterprise management servers before a patch is available, potentially leading to widespread endpoint control.
- **Rating:** novel

---
### HTTP Request Smuggling: From Basics to Real Exploitation in Burp Repeater
- **Tags:** `#smuggling` `#web`
- **Severity:** unknown · **Hunt:** 4/5 · **Score:** 24.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@Aman-Gupta.cse/http-request-smuggling-from-basics-to-real-exploitation-in-burp-repeater-144e145459ac?source=rss------bug_bounty-5) · [2](https://portswigger.net/research/how-to-distinguish-http-pipelining-from-request-smuggling)

### HTTP Request Smuggling: From Basics to Real Exploitation in Burp Repeater
- **Trick:** Exploiting discrepancies between HTTP parsers in proxies/servers to craft requests that bypass security controls and smuggle unintended actions.
- **Why it matters:** Enables critical bypasses of authentication, access controls, and cache mechanisms, potentially leading to RCE, data theft, or lateral movement.
- **Rating:** chain-worthy

---
*Clustered 2 sources for this item.*

### Technical Proof of Decryption and Root Access
- **Tags:** `#privesc` `#deserialization`
- **Severity:** critical · **Hunt:** 3/5 · **Score:** 20.25 · **Status:** poc · **Age:** 30d
- **Sources:** [1](https://medium.com/@fazul1324/technical-proof-of-decryption-and-root-access-8830c5b7a909?source=rss------bug_bounty-5)

### Technical Proof of Decryption and Root Access
- **Trick:** Exploiting insecure object deserialization during decryption to escalate privileges to root.
- **Why it matters:** Compromises critical system integrity by leveraging trust in data processing for privilege elevation.
- **Rating:** chain-worthy

---
### NTLM Relay: The Attack That Turns Your Network Against Itself
- **Tags:** `#auth-bypass` `#privesc` `#network` `#windows`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 10.5 · **Status:** patched · **Age:** 30d
- **Sources:** [1](https://medium.com/@garrettstimpson/ntlm-relay-the-attack-that-turns-your-network-against-itself-6eeba27c341b?source=rss------infosec-5) · [2](https://medium.com/@pandag0tbann3d/bypassing-2fa-how-a-flawed-sso-architecture-led-to-complete-account-takeover-2518377022e9?source=rss------bug_bounty-5) · [3](https://medium.com/@waltermoar/understanding-cwe-1391-use-of-weak-credentials-2d93f656670c) · [4](https://medium.com/@paritoshblogs/hackers-dont-need-your-password-anymore-d76b3f290d0d?source=rss------bug_bounty-5) · [5](https://www.intigriti.com/researchers/blog/hacking-tools/exploiting-broken-access-control-vulnerabilities)

### NTLM Relay: The Attack That Turns Your Network Against Itself
- **Trick:** Exploits NTLM authentication by capturing credentials from one connection and relaying them to another service to impersonate users without cracking passwords.
- **Why it matters:** Can lead to domain compromise, privilege escalation, and lateral movement with proper network positioning.
- **Rating:** chain-worthy

---
*Clustered 5 sources for this item.*

### Capture Flutter Based IOS Application's Traffic
- **Tags:** `#mobile` `#data-exfil`
- **Severity:** medium · **Hunt:** 2/5 · **Score:** 10.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@anuragbhoir07/flutter-based-ios-application-sslpinning-bypass-37b1c84332fa?source=rss------pentesting-5)

### Capture Flutter Based IOS Application's Traffic
- **Trick:** Details methods to bypass SSL pinning in Flutter iOS applications, likely using Frida or Objection to hook into the underlying native iOS networking stack rather than the Dart layer.
- **Why it matters:** Flutter apps often implement pinning to protect API traffic; bypassing this control is a prerequisite for analyzing API endpoints, manipulating requests, and identifying backend vulnerabilities during mobile assessments.
- **Rating:** variant

---
### Kerberoasting: Why Your AD Service Accounts Are Already Toast
- **Tags:** `#auth-bypass` `#privesc`
- **Severity:** high · **Hunt:** 1/5 · **Score:** 7.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@garrettstimpson/kerberoasting-why-your-ad-service-accounts-are-already-toast-977a836de9d2)

### Kerberoasting: Why Your AD Service Accounts Are Already Toast
- **Trick:** Requesting Kerberos service tickets for accounts with Service Principal Names (SPNs) and brute-forcing the encrypted ticket hashes offline.
- **Why it matters:** Since any authenticated domain user can request these tickets, weak passwords on service accounts lead directly to privilege escalation and potential domain compromise.
- **Rating:** variant

---
### From Critical to Low: 6 Vulnerabilities That Exposed a Web Application
- **Tags:** `#web` `#bug-bounty`
- **Severity:** unknown · **Hunt:** 3/5 · **Score:** 6.0 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://medium.com/@seafeldeenwael/from-critical-to-low-6-vulnerabilities-that-exposed-a-web-application-c5fcf5130adf) · [2](https://www.intigriti.com/researchers/blog/bug-bytes/intigriti-bug-bytes-234-march-2026) · [3](https://github.com/nomi-sec/PoC-in-GitHub/commit/5c8eafc4626773abc5fca572077cda416d744088) · [4](https://github.com/nomi-sec/PoC-in-GitHub/commit/d472e86dbddac9e9c6439a5d04fa5c2cbf4cfed6) · [5](https://github.com/nomi-sec/PoC-in-GitHub/commit/e2590a50930e0c58e3ea2f275eae951275b092ba)

### From Critical to Low: 6 Vulnerabilities That Exposed a Web Application
- **Trick:** The author shares their journey discovering six vulnerabilities in a web application, detailing the process of identification, assessment, and exploitation of security weaknesses.
- **Why it matters:** Provides practical insights into real-world vulnerability discovery for beginners in bug hunting, showing the range of severity levels that can impact web applications.
- **Rating:** variant

---
*Clustered 17 sources for this item.*

### Evading an AI SOC with Sable from Vulnetic
- **Tags:** `#llm` `#prompt-injection` `#jailbreak`
- **Severity:** info · **Hunt:** 3/5 · **Score:** 4.5 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://medium.com/@Vulnetic-CEO/evading-an-ai-soc-with-sable-from-vulnetic-fad12376995c?source=rss------pentesting-5)

### Evading an AI SOC with Sable from Vulnetic
- **Trick:** Details the use of the Sable framework to execute adversarial attacks and prompt injection techniques specifically designed to bypass AI-driven Security Operations Centers.
- **Why it matters:** As organizations adopt AI for SOC triage, understanding these evasion vectors is critical for red teams to test detection robustness and for blue teams to harden automated analysis pipelines.
- **Rating:** chain-worthy

---
### WordPress XML-RPC & Admin Path Disclosures
- **Tags:** `#data-exfil` `#web`
- **Severity:** info · **Hunt:** 2/5 · **Score:** 2.0 · **Status:** theoretical · **Age:** 0d
- **Sources:** [1](https://vanshrathorebughunter.medium.com/hunting-for-xmlrpc-uncovering-wordpress-xml-rpc-admin-path-disclosures-b5707b8f5424)

### WordPress XML-RPC & Admin Path Disclosures
- **Trick:** Interacting with the `xmlrpc.php` endpoint using specific methods or malformed payloads to trigger verbose error responses that reveal the absolute filesystem path of the WordPress installation.
- **Why it matters:** Full path disclosure aids attackers in performing Local File Inclusion (LFI) or other file-system based attacks by confirming the underlying directory structure.
- **Rating:** variant

---
### Inside GPT-5.4-Cyber: OpenAI’s New Secret Weapon for Security Defenders
- **Tags:** `#llm`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 1.0 · **Status:** unknown · **Age:** 0d
- **Sources:** [1](https://medium.com/@psyduck90/inside-gpt-5-4-cyber-openais-new-secret-weapon-for-security-defenders-845daa714cdd)

### Inside GPT-5.4-Cyber: OpenAI’s New Secret Weapon for Security Defenders
- **Trick:** Explores the architecture and defensive capabilities of a hypothetical next-generation LLM specifically tuned for automated threat detection, incident response, and vulnerability analysis.
- **Why it matters:** Highlights the accelerating arms race in AI security, emphasizing how defenders may soon leverage highly specialized models to outpace automated offensive tooling.
- **Rating:** novel

---
### CISCO Notes Networking Basics — Module 4 — Build a Home Network
- **Tags:** `#appliance` `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 0.5 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://medium.com/@vorasmit22/cisco-notes-networking-basics-module-4-build-a-home-network-78cbf853e6d6?source=rss------infosec-5)

### CISCO Notes Networking Basics — Module 4 — Build a Home Network
- **Trick:** Implement network segmentation and security best practices using home-grade Cisco appliances to isolate IoT devices and guest networks.
- **Why it matters:** Creates defense-in-depth against lateral movement and IoT-based attacks, critical for securing personal network perimeters.
- **Rating:** novel

---
### Setting Up Xalgorix: AI Pentesting Agent
- **Tags:** `#llm` `#web`
- **Severity:** info · **Hunt:** 1/5 · **Score:** 0.5 · **Status:** unknown · **Age:** 30d
- **Sources:** [1](https://infosecwriteups.com/the-complete-guide-to-setting-up-xalgorix-the-most-powerful-open-source-ai-pentesting-agent-befc9b721b9e?source=rss------bug_bounty-5)

### Setting Up Xalgorix: Open-Source AI Pentesting Agent
- **Trick:** Provides step-by-step autonomous setup for an AI pentesting agent that finds vulnerabilities without manual intervention
- **Why it matters:** Automates vulnerability discovery, reduces testing time, and democratizes AI-assisted security testing for practitioners
- **Rating:** novel

---
