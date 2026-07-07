# Email Spoofing

## DNS Record Checks

- [ ] Query SPF: `dig TXT target.com | grep spf` — no SPF record = vulnerable
- [ ] Query DMARC: `dig TXT _dmarc.target.com` — no record or `p=none` = vulnerable
- [ ] Query DKIM: `dig TXT default._domainkey.target.com` — missing = no signing
- [ ] Check DMARC policy: `p=none` (monitor only), `p=quarantine`, `p=reject` — only reject fully mitigates
- [ ] Check DMARC `rua=` and `ruf=` — no reporting = owner likely unaware of spoofing

## Validation

```bash
# Check SPF
dig TXT target.com +short | grep spf

# Check DMARC
dig TXT _dmarc.target.com +short

# Check DKIM (try common selectors)
for sel in default google selector1 selector2 k1 dkim mail; do
  dig TXT "${sel}._domainkey.target.com" +short
done
```

- [ ] Use [MXToolbox SPF checker](https://mxtoolbox.com/spf.aspx) to confirm
- [ ] Use [MXToolbox DMARC checker](https://mxtoolbox.com/dmarc.aspx) to confirm

## Test Sending (authorized environments only)

- [ ] Use [emkei.cz](https://emkei.cz) or `swaks` to send spoofed email to a test inbox

  ```bash
  swaks --to test@yourdomain.com --from ceo@target.com \
    --server mail.target.com --body "spoofing test"
  ```

- [ ] Check if spoofed email lands in inbox vs spam — inbox = confirmed vulnerable

## Impact Mapping

- No SPF + no DMARC = anyone can send as any @target.com address (High/Medium)
- SPF exists + DMARC p=none = still exploitable, no enforcement (Low/Informational)
- SPF exists + DMARC p=reject = mitigated

## References

- [HackerOne #1071521](https://hackerone.com/reports/1071521)
- [DMARC RFC 7489](https://tools.ietf.org/html/rfc7489)
