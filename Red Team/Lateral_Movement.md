# Lateral Movement

Lateral Movement consists of techniques that adversaries use to move from a compromised host to other hosts within a network. Adversaries often use the same techniques for lateral movement as they do for Initial Access. For example, adversaries might use valid accounts and pass the hash to move between systems.

## Windows Lateral Movement

*   **PsExec:** A light-weight telnet-replacement that lets you execute processes on other systems, complete with full interactivity for console applications, without having to manually install client software. PsExec's most powerful capabilities are launching interactive command-prompts on remote systems and remote-enabling tools like IpConfig that otherwise could not show information about remote systems.
    ```powershell
    PsExec.exe \\target_ip -u username -p password command
    ```

*   **WMI (Windows Management Instrumentation):** A powerful interface for managing Windows systems. It can be used to execute commands remotely, query system information, and more.
    ```powershell
    wmic /node:target_ip /user:username /password:password process call create "cmd.exe /c command"
    ```

*   **SMB/Admin Shares:** Windows administrative shares (e.g., `C$`, `ADMIN$`) can be accessed remotely with appropriate credentials, allowing for file transfer and command execution.
    ```powershell
    net use \\target_ip\c$ password /user:username
    ```

*   **Pass-the-Hash (PTH):** A technique where an attacker authenticates to a remote system or service by using the underlying NTLM hash of a user's password, rather than the plaintext password itself. This is particularly effective in environments where the same credentials are used across multiple systems.
    ```powershell
    # Using Mimikatz
    sekurlsa::pth /user:username /domain:domain /ntlm:hash /run:"cmd.exe"
    ```

## Linux Lateral Movement

*   **SSH:** Secure Shell (SSH) is a cryptographic network protocol for operating network services securely over an unsecured network. If an attacker obtains SSH keys or credentials, they can use SSH to move laterally between Linux systems.
    ```bash
    ssh -i id_rsa user@target_ip
    sshpass -p 'password' ssh user@target_ip
    ```

*   **SCP:** Secure Copy Protocol (SCP) is a network protocol that supports file transfers between hosts on a network. It uses SSH for data transfer and provides the same authentication and security as SSH.
    ```bash
    scp file.txt user@target_ip:/path/to/destination
    ```


