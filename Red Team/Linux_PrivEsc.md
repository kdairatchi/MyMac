# Privilege Escalation - Linux

This section covers common techniques and commands for escalating privileges on Linux systems.

## Linux Privilege Escalation

Privilege escalation is the act of exploiting a bug, design flaw, or configuration oversight in an operating system or software application to gain elevated access to resources that are normally protected from an application or user.

*   **LinPEAS:** A script that searches for possible paths to escalate privileges on Linux/Unix* hosts. It checks for kernel exploits, SUID/SGID binaries, cron jobs, writable files, and more.
    ```bash
    ./linpeas.sh
    ```

*   **Sudo Vulnerabilities:** Misconfigured `sudo` permissions can allow a user to run commands as root or another user without providing a password.
    ```bash
    sudo -l
    ```
    This command lists the commands a user can run with `sudo` privileges.

*   **SUID/SGID Binaries:** SUID (Set User ID) and SGID (Set Group ID) are special permissions that allow a user to execute a file with the permissions of the file owner (SUID) or group (SGID). Misconfigured SUID/SGID binaries can be exploited to gain elevated privileges.
    ```bash
    find / -perm -4000 -o -perm -2000 2>/dev/null
    ```
    This command finds all SUID (`-perm -4000`) or SGID (`-perm -2000`) binaries on the system.

*   **Kernel Exploits:** Outdated or unpatched Linux kernels can be vulnerable to exploits that grant root privileges.
    ```bash
    uname -a
    ```
    This command displays kernel information, which can be used to identify potential kernel exploits.

*   **Cron Jobs:** Cron jobs are scheduled tasks. Misconfigured or vulnerable cron jobs can be exploited to execute commands with elevated privileges.
    ```bash
    cat /etc/crontab
    ls -la /etc/cron.*
    ```
    These commands allow you to inspect system-wide and user-specific cron jobs for suspicious entries.

For more in-depth information on Linux privilege escalation, refer to resources like GTFOBins and HackTricks.

