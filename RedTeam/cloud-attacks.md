# Cloud Attacks

Authorized engagements / in-scope bug bounty. Every cloud provider logs everything; assume every call is visible in CloudTrail / Activity Log / Cloud Audit Logs.

Top-level reference: https://hackingthe.cloud.

## AWS

### Enumeration

With creds (key ID + secret, or STS from SSRF):

```
aws sts get-caller-identity
aws iam get-account-authorization-details > iam.json
```

Tools:

- ScoutSuite — https://github.com/nccgroup/ScoutSuite — multi-cloud posture
- PMapper — https://github.com/nccgroup/PMapper — IAM graph + privesc
- Pacu — https://github.com/RhinoSecurityLabs/pacu — AWS offensive framework
- enumerate-iam — https://github.com/andresriancho/enumerate-iam — brute-force reachable API calls
- CloudFox — https://github.com/BishopFox/cloudfox — recon-focused

### IAM privilege escalation

Reference catalog: https://github.com/RhinoSecurityLabs/AWS-IAM-Privilege-Escalation — Rhino's "21 methods".

Highlights:

- `iam:CreateAccessKey` on another user → mint keys for them
- `iam:CreateLoginProfile` → console access
- `iam:AttachUserPolicy` / `AttachRolePolicy` / `PutUserPolicy` → grant self AdministratorAccess
- `iam:PassRole` + `lambda:CreateFunction` + `lambda:InvokeFunction` → run code as any passable role
- `iam:PassRole` + `ec2:RunInstances` → attach admin role to instance
- `iam:UpdateAssumeRolePolicy` → trust yourself
- `sts:AssumeRole` with permissive trust → lateral to another role
- `glue:CreateDevEndpoint` + PassRole → code-exec as role

Pacu module per chain: `exec iam__privesc_scan`.

### SSRF → IMDS

Classic bounty path. IMDSv1 on EC2:

```
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<role>
```

Returns short-lived creds. IMDSv2 (token required) is default on new launches but legacy instances keep v1.

On ECS/Fargate: `curl $AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` (169.254.170.2).

On Lambda: creds are in env vars (`AWS_SESSION_TOKEN`, etc.).

### Cross-account / STS confusion

- `sts:AssumeRole` where trust is `"Principal":"*"` with no condition — anyone in any AWS account can assume.
- "Confused deputy" where an external ID isn't required — third party can be tricked to assume.
- Assume-role chaining: `sts assume-role` → new session → `assume-role` again; session policies sometimes permissive.

### S3 / data surface

- Public buckets still common — `aws s3 ls s3://bucket --no-sign-request`
- Misconfigured bucket policy granting `s3:PutBucketPolicy` to `*` — chain to takeover.
- Backup snapshots (EBS, RDS) shared public — `aws ec2 describe-snapshots --restorable-by-user-ids all`.

### CloudTrail evasion (concept, cite only)

Full evasion is heavily monitored by defenders. Known technique: use an API Gateway resource policy to proxy calls and break user-agent attribution — conceptual reference in SpecterOps cloud research: https://specterops.io/blog. Do not attempt to disable trails on engagements without explicit permission.

## Azure / Entra ID

### Enumeration

- AzureHound (BloodHound ingestor) — https://github.com/SpecterOps/AzureHound
- ROADtools — https://github.com/dirkjanm/ROADtools — MSGraph dumper
- MicroBurst — https://github.com/NetSPI/MicroBurst
- Stormspotter — historical; ROADtools supersedes
- PowerZure — https://github.com/hausec/PowerZure
- AADInternals — https://github.com/Gerenios/AADInternals — toolkit by Dr Nestori Syynimaa

```
# ROADrecon
roadrecon auth -u user@domain.onmicrosoft.com -p 'pass'
roadrecon gather
roadrecon gui
```

### Entra ID attack paths

- Illicit consent grant — phish user into consenting to an attacker OAuth app with broad Graph scopes (`Mail.Read`, `Files.Read.All`). Reference: https://www.microsoft.com/en-us/security/blog/2022/09/22/malicious-oauth-applications-used-to-compromise-email-servers-and-spread-spam/.
- Device code phishing — request device code, convince user to complete login, receive tokens. Tool: https://github.com/rvrsh3ll/TokenTactics.
- Primary Refresh Token (PRT) theft on domain-joined host. AADInternals / roadtx.
- Admin consent to risky app — requires Global Admin typically.
- Directory role abuse — Application Administrator can add creds to any service principal, then login as it.
- Privileged Authentication Administrator — reset privileged user passwords.
- Dynamic group abuse — manipulate attribute (like `department`) to join a group granting app access.

### Azure resource plane

- Managed Identity IMDS: `curl -H "Metadata:true" 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/'`
- Run Command on VM — `az vm run-command invoke` with `Contributor` → code-exec as SYSTEM.
- Automation Account runbooks — `Contributor` on automation → run as Automation account identity.
- Key Vault — reader roles + purge rights can extract secrets.

### Azure AD Connect

On-prem server running AADC stores MSOL_* account creds; compromising it gives DCSync in on-prem and token-minting in cloud. Tool: `Get-AADIntSyncCredentials` from AADInternals.

## GCP

### Enumeration

```
gcloud auth list
gcloud projects list
gcloud projects get-iam-policy PROJECT_ID
```

Tools:

- GCP_IAM_Privilege_Escalation (Rhino) — https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation
- gcp_enum / gcp_firebase_enum — https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation
- gcp-scanner (Google-maintained) — https://github.com/google/gcp_scanner
- Hayat — https://github.com/DenizParlak/hayat

### IAM privesc

Rhino's GCP "31 methods" — https://rhinosecuritylabs.com/gcp/privilege-escalation-google-cloud-platform-part-1/.

Common paths:

- `iam.serviceAccountKeys.create` on a higher-priv SA → mint key, act as them.
- `iam.serviceAccountTokens.create` (or `-AccessToken`) → mint tokens.
- `iam.serviceAccounts.actAs` + `cloudfunctions.functions.create` → deploy function as target SA.
- `iam.serviceAccounts.actAs` + `compute.instances.create` → run VM as target SA.
- `iam.serviceAccounts.actAs` + `cloudbuild.builds.create` → Cloud Build runs as SA (often highly-privileged default SA).
- `deploymentmanager.deployments.create` — DM runs as Google APIs SA which is project-editor.

### Metadata service

GCE IMDS:

```
curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token
```

Cloud Run / Cloud Functions / GKE all expose metadata service similarly; GKE hardens with Workload Identity but many legacy clusters don't.

### Cross-project abuse

Organization-level IAM grants bleed into every project; `resourcemanager.organizations.getIamPolicy` reveals scope. Folder-level bindings often forgotten.

## Kubernetes

- Pod with host mounts / privileged / hostNetwork → node escape.
- Service-account token in `/var/run/secrets/kubernetes.io/serviceaccount/token` → check RBAC via `kubectl auth can-i --list`.
- RBAC audit: `kubectl-who-can` — https://github.com/aquasecurity/kubectl-who-can
- Peirates — https://github.com/inguardians/peirates — offensive K8s toolkit
- kube-hunter — https://github.com/aquasecurity/kube-hunter

Cloud managed-K8s (EKS/AKS/GKE) tie pod identities to cloud roles — IAM privesc routes back into cloud plane.

## Cross-cloud / federated

- AWS-Azure SSO via SAML — check trust policies for wildcard.
- Workload Identity Federation (AWS→GCP, GitHub→AWS) — misconfigured conditions (`sub` regex too loose) allow any repo to assume.
- GitHub OIDC → AWS: verify `aud` and `sub` pinning. Misuse has led to public takeover scenarios.

## OPSEC

- Every cloud API call is logged. Plan your enumeration — don't run the kitchen sink.
- Keep a per-engagement source IP (VPS) allowlisted in the engagement doc.
- Never create persistent IAM entities without cleanup plan.
- For bounty, stop at proof — a single `sts:GetCallerIdentity` from leaked keys is enough; don't `iam list` everything.

## References

- Hacking The Cloud — https://hackingthe.cloud
- AWS IAM privesc (Rhino) — https://github.com/RhinoSecurityLabs/AWS-IAM-Privilege-Escalation
- GCP privesc (Rhino) — https://rhinosecuritylabs.com/gcp/privilege-escalation-google-cloud-platform-part-1/
- AADInternals — https://aadinternals.com
- MITRE ATT&CK Cloud — https://attack.mitre.org/matrices/enterprise/cloud/
