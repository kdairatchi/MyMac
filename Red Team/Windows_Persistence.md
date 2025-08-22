# Persistence - Windows

This section covers common techniques for establishing persistence on Windows systems, ensuring continued access to a compromised machine.

## Windows Persistence

Persistence consists of techniques that adversaries use to maintain their foothold in a compromised environment. Adversaries may also use these techniques to maintain access to systems, even if the system is rebooted or credentials are changed.

*   **Registry Run Keys:** Adversaries can add programs to the Windows Registry Run keys, which will execute the program every time the user logs on.
    ```powershell
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Backdoor" /t REG_SZ /d "C:\Path\To\backdoor.exe" /f
    ```
    *   `HKCU`: HKEY_CURRENT_USER. For current user persistence.
    *   `HKLM`: HKEY_LOCAL_MACHINE. For system-wide persistence (requires elevated privileges).

*   **Scheduled Tasks:** Creating scheduled tasks allows adversaries to execute programs at specific times or intervals, or upon certain events (e.g., system startup, user logon).
    ```powershell
    schtasks /create /tn "Backdoor" /tr "C:\Path\To\backdoor.exe" /sc ONLOGON /rl HIGHEST
    ```
    *   `/tn`: Task Name.
    *   `/tr`: Task Run (the command or program to run).
    *   `/sc ONLOGON`: Schedule on user logon. Other options include `ONSTART` (system startup), `DAILY`, `HOURLY`, etc.
    *   `/rl HIGHEST`: Run with highest privileges.

*   **Startup Folder:** Placing an executable in the user's or all users' Startup folder will cause it to run automatically when the user logs in.
    ```powershell
    copy backdoor.exe "C:\Users\Public\Start Menu\Programs\Startup\"
    ```
    *   `C:\Users\<Username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` (Current user)
    *   `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup` (All users)

*   **Service Creation:** Adversaries can create new Windows services that are configured to start automatically at system boot, providing persistent and often privileged access.
    ```powershell
    sc create "BackdoorService" binPath="C:\Path\To\backdoor.exe" start= auto
    sc start "BackdoorService"
    ```
    *   `sc create`: Creates a new service.
    *   `binPath`: Path to the executable.
    *   `start= auto`: Configures the service to start automatically.

These methods provide robust ways to maintain access on Windows systems, often blending in with legitimate system configurations.

