# GCP Checklist

## IAM

- Project-level `roles/owner`, `roles/editor` given to non-admin service accounts.
- `allUsers` / `allAuthenticatedUsers` bindings on sensitive resources.
- Service account keys not rotated; JSON keys in repos.
- `iam.serviceAccounts.actAs` or `iam.serviceAccountTokenCreator` → impersonation priv-esc.

```bash
gcloud auth list
gcloud projects list
gcloud projects get-iam-policy <project> --format=json
gcloud iam service-accounts list
```

Tools: [gcp_enum](https://gitlab.com/gitlab-com/gl-security/security-operations/redteam/redteam-public/gcp_enum), [Hayat](https://github.com/DenizParlak/hayat), [gcpbucketbrute](https://github.com/RhinoSecurityLabs/GCPBucketBrute).

## GCS (Cloud Storage)

```bash
# Public bucket probe
gcpbucketbrute -k words.txt -u

# Direct check
curl -s https://storage.googleapis.com/<bucket>/
gsutil ls gs://<bucket> -a
gsutil iam get gs://<bucket>
```

- `allUsers:READER` → public list/read.
- `allUsers:WRITER` → defacement.
- HMAC keys exposed → long-lived access.

## SSRF → metadata

GCP metadata requires `Metadata-Flavor: Google` header — classic SSRF often bypasses this if the request is proxied literally.

```bash
curl -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
curl -H "Metadata-Flavor: Google" \
  http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token
```

Returns `access_token` usable via `gcloud auth activate-service-account --key-file=-` or `curl -H "Authorization: Bearer <token>"`.

## Cloud Functions / Cloud Run

- `allUsers` invoker role → pre-auth endpoint.
- Env vars with secrets (check via `gcloud run services describe`).
- Container registry (`gcr.io`, `pkg.dev`) public by default for some configs.

## Firebase

- Open RTDB: `https://<project>.firebaseio.com/.json` returns all data if rules are `".read": true`.
- Firestore rules `allow read, write: if true`.
- Firebase web config in JS bundles — valid by design, but combined with open rules = critical.

```bash
curl https://<project>.firebaseio.com/.json
```

## References

- hackingthe.cloud GCP — https://hackingthe.cloud/gcp/
- GCP IAM recipes — https://github.com/marcin-kolda/gcp-iam-collector
- DenizParlak Hayat — https://github.com/DenizParlak/Hayat
