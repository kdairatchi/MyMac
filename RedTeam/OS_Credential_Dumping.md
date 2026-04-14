# Credential Access - OS Credential Dumping

This section covers techniques for accessing and dumping credentials from operating systems, a critical step in many red team operations.

## Credential Access

Credential Access consists of techniques for stealing credentials like account names and passwords. Adversaries often try to steal credentials to use them to access other systems, make changes to configurations, or to exfiltrate data.

### Mimikatz (Windows)

Mimikatz is a powerful open-source tool that extracts plaintext passwords, NTLM hashes, Kerberos tickets, and certificates from Windows memory. It is a primary tool for credential access on Windows systems.

*   **Extract Passwords (plaintext, hashes, Kerberos):**
    ```powershell
    privilege::debug
    sekurlsa::logonpasswords
    ```

### LSASS Dump (Windows)

The Local Security Authority Subsystem Service (LSASS) process stores credentials in memory. Dumping the LSASS process memory allows for offline extraction of credentials.

*   **Dump LSASS process for offline credential extraction:**
    ```powershell
    procdump.exe -accepteula -ma lsass.exe lsass.dmp
    ```
    *Note: `procdump.exe` is a Sysinternals tool. The `-accepteula` flag accepts the EULA, and `-ma` performs a full memory dump.* 

### Password Hashes (Linux)

On Linux systems, password hashes are typically stored in the `/etc/shadow` file. Accessing this file (which requires root privileges) allows for the extraction of hashed passwords that can then be cracked offline.

*   **Locate and read `/etc/shadow` (requires root):**
    ```bash
    cat /etc/shadow
    ```

For more detailed Mimikatz usage, refer to the `Tools/Mimikatz.md` documentation.

