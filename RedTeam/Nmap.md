# Nmap (Network Mapper)

Nmap is a free and open-source utility for network discovery and security auditing. It uses raw IP packets to determine what hosts are available on the network, what services (application name and version) those hosts are offering, what operating systems (and OS versions) they are running, what type of packet filters/firewalls are in use, and dozens of other characteristics.

### Installation

Nmap is often pre-installed on penetration testing distributions like Kali Linux and Parrot OS. If not, you can install it using your system's package manager:

*   **Debian/Ubuntu:**
    ```bash
    sudo apt update
    sudo apt install nmap
    ```
*   **Fedora/RHEL:**
    ```bash
    sudo dnf install nmap
    ```
*   **Windows/macOS:** Download the official installer from [nmap.org](https://nmap.org/download.html).

### Basic Usage

*   **Scan a single target:**
    ```bash
    nmap example.com
    ```
*   **Scan multiple targets:**
    ```bash
    nmap example.com 192.168.1.1
    ```
*   **Scan a range of IP addresses:**
    ```bash
    nmap 192.168.1.1-100
    ```
*   **Scan a subnet:**
    ```bash
    nmap 192.168.1.0/24
    ```

### Common Scan Types

*   **SYN Scan (`-sS`):** The default and most popular scan option for good reasons. It can scan thousands of ports per second on a fast network not hampered by intrusive firewalls. It is also relatively stealthy, as it never completes TCP connections.
    ```bash
    nmap -sS target.com
    ```
*   **TCP Connect Scan (`-sT`):** This is the default TCP scan type when SYN scan is not an option (e.g., insufficient permissions). It completes the three-way handshake.
    ```bash
    nmap -sT target.com
    ```
*   **UDP Scan (`-sU`):** Scans for open UDP ports. UDP services are often overlooked in security audits.
    ```bash
    nmap -sU target.com
    ```

### Advanced Options

*   **Service Version Detection (`-sV`):** Determines the service and version number running on open ports.
    ```bash
    nmap -sV target.com
    ```
*   **OS Detection (`-O`):** Attempts to determine the operating system of the target host.
    ```bash
    nmap -O target.com
    ```
*   **Aggressive Scan (`-A`):** Enables OS detection, version detection, script scanning (`-sC`), and traceroute.
    ```bash
    nmap -A target.com
    ```
*   **Script Scanning (`-sC` or `--script`):** Runs default Nmap scripts or specified scripts to perform more advanced detection, vulnerability scanning, and exploitation.
    ```bash
    nmap -sC target.com
    nmap --script http-enum target.com
    ```
*   **Firewall Evasion (`-f`, `--mtu`, `--data-length`, `--badsum`): Privilege Escalation:** Gaining higher-level permissions on a system or network.
*   **Defense Evasion:** Avoiding detection by security controls.
*   **Credential Access:** Stealing credentials like usernames and passwords.
*   **Discovery:** Gaining knowledge about the system and internal network.
*   **Lateral Movement:** Moving through an environment to gain access to other systems.
*   **Collection:** Gathering data of interest to the adversary from a target environment.
*   **Exfiltration:** Stealing data from a network.
*   **Command and Control:** Communicating with compromised systems to control them.
*   **Impact:** Disrupting availability or compromising integrity by manipulating business and operational processes.

## Repository Structure

```
. 
├── README.md
├── LICENSE
├── Reconnaissance/
│   ├── OSINT.md
│   ├── Network_Scanning.md
│   └── ...
├── Resource_Development/
│   ├── Infrastructure_Setup.md
│   └── ...
├── Initial_Access/
│   ├── Phishing.md
│   ├── Exploitation.md
│   └── ...
├── Execution/
│   ├── Command_and_Scripting_Interpreter.md
│   └── ...
├── Persistence/
│   ├── Linux_Persistence.md
│   ├── Windows_Persistence.md
│   └── ...
├── Privilege_Escalation/
│   ├── Linux_PrivEsc.md
│   ├── Windows_PrivEsc.md
│   └── ...
├── Defense_Evasion/
│   ├── Obfuscated_Files_or_Information.md
│   └── ...
├── Credential_Access/
│   ├── OS_Credential_Dumping.md
│   ├── Brute_Force.md
│   └── ...
├── Discovery/
│   ├── Network_Discovery.md
│   ├── System_Information_Discovery.md
│   └── ...
├── Lateral_Movement/
│   ├── Remote_Services.md
│   ├── Pass_the_Hash.md
│   └── ...
├── Collection/
│   ├── Data_from_Local_System.md
│   └── ...
├── Exfiltration/
│   ├── Exfiltration_Over_C2_Channel.md
│   └── ...
├── Command_and_Control/
│   ├── C2_Frameworks.md
│   └── ...
├── Impact/
│   ├── Data_Destruction.md
│   └── ...
├── Tools/
│   ├── Nmap.md
│   ├── Metasploit.md
│   ├── Mimikatz.md
│   ├── BloodHound.md
│   └── ...
└── Cheatsheets/
    ├── General_Commands.md
    ├── Wireless_Attacks.md
    └── ...
```

## Contribution

Contributions are welcome! Please refer to the `CONTRIBUTING.md` (to be added) for guidelines on how to contribute to this handbook.

## License

This project is licensed under the [MIT License](LICENSE).

