# Azure Checklist

## AAD / Entra ID

- Guest users with elevated roles.
- Consent grants to third-party apps (`Mail.ReadWrite`, `Files.ReadWrite.All`).
- Legacy auth (ROPC, IMAP/POP3) enabled — bypasses MFA.
- Dynamic group rules that can be manipulated via attribute change.

```bash
az login
az ad signed-in-user show
az role assignment list --assignee <upn>
az ad app list --show-mine

# Anon tenant enum
curl "https://login.microsoftonline.com/<tenant>.onmicrosoft.com/.well-known/openid-configuration"
```

Tools: [ROADtools](https://github.com/dirkjanm/ROADtools), [AADInternals](https://github.com/Gerenios/AADInternals), [azurehound](https://github.com/BloodHoundAD/AzureHound).

## Storage accounts

- Anonymous blob access (`Container` or `Blob` public access level).
- SAS tokens in URLs (often in JS bundles, emails) — check expiry + permissions.
- Shared keys in app configs.

```bash
# Probe
az storage blob list --account-name <acct> --container-name <c> --auth-mode login
curl "https://<acct>.blob.core.windows.net/<container>?restype=container&comp=list"
```

Subdomain patterns: `*.blob.core.windows.net`, `*.file.core.windows.net`, `*.queue.core.windows.net`, `*.table.core.windows.net`, `*.dfs.core.windows.net`.

## Managed identities → SSRF

Azure IMDS endpoint (similar to AWS/GCP):

```bash
curl "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" \
  -H "Metadata: true"
```

Returns bearer token scoped to the VM's managed identity. Use against:

- `https://management.azure.com/subscriptions?api-version=2020-01-01`
- `https://graph.microsoft.com/v1.0/me`
- `https://vault.azure.net/secrets/...?api-version=7.3`

## App Service / Function App

- `SCM_DO_BUILD_DURING_DEPLOYMENT` + deployment credentials exposed.
- Kudu console (`https://<app>.scm.azurewebsites.net`) → full filesystem + cmd.
- App settings leaking secrets — review `az webapp config appsettings list`.

## Key Vault

- RBAC misconfig: `Key Vault Secrets User` granted to wide groups.
- Firewall disabled (`networkAcls.defaultAction: Allow`).
- Soft-delete disabled → permanent data loss risk.

## Subdomain takeover hotspots

`*.azurewebsites.net`, `*.cloudapp.net`, `*.trafficmanager.net`, `*.cloudapp.azure.com`, `*.azureedge.net` — classic dangling CNAME takeover sources.

## References

- hackingthe.cloud Azure — https://hackingthe.cloud/azure/
- ROADtools wiki — https://github.com/dirkjanm/ROADtools/wiki
- MicroBurst — https://github.com/NetSPI/MicroBurst
