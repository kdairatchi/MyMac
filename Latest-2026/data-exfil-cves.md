# data-exfil-cves


## 2026-04-16

### Stop Putting Your Passwords Into Random Websites
- **Tags:** `#data-exfil` `#web` `#supply-chain`
- **Severity:** high · **Hunt:** 3/5 · **Score:** 21.0 · **Status:** itw · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/stop-putting-your-passwords-into-random-websites-yes-seriously-you-are-the-problem/)

### Stop Putting Your Passwords Into Random Websites — data-exfil
- **What:** Researchers identified vast quantities of exposed passwords, secrets, and keys publicly accessible on the web.
- **Why it matters:** Publicly exposed credentials allow for immediate account takeover, lateral movement, and supply chain compromise.
- **Hunt signal:** `dork: intext:"password" ext:env OR ext:log filetype:log -git`
- **Evidence:** [watchtowr_labs] analysis confirms sensitive credentials are widely exposed ... · [opinion] Users must stop reusing passwords across platforms.

---
