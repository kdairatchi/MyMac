# Privilege Escalation - Windows

This section covers common techniques and commands for escalating privileges on Windows systems.

## Windows Privilege Escalation

*   **WinPEAS:** A script that searches for possible paths to escalate privileges on Windows hosts. It checks for common misconfigurations, vulnerabilities, and weak permissions.
    ```powershell
    .\WinPEASx64.exe
    ```

*   **System Information:** Gathering basic system information can reveal clues for privilege escalation.
    ```powershell
    systeminfo
    ```

*   **User and Group Information:** Enumerating users and groups helps identify potential targets or misconfigurations.
    ```powershell
    net user
    net localgroup administrators
    ```

*   **Scheduled Tasks:** Misconfigured scheduled tasks can be exploited to run commands with elevated privileges.
    ```powershell
    schtasks /query /fo LIST /v
    ```

*   **Unquoted Service Paths:** If a service executable path contains spaces and is not enclosed in quotes, Windows may interpret parts of the path as separate commands, leading to arbitrary code execution with elevated privileges.
    ```powershell
    wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\\windows\\system32\\"
    ```

*   **AlwaysInstallElevated:** If this registry setting is enabled, any user can install Windows Installer packages (.msi) with elevated (SYSTEM) privileges, which can be exploited for privilege escalation.
    ```powershell
    reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
    reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
    ```

For more in-depth information on Windows privilege escalation, refer to resources like HackTricks and various security blogs.

