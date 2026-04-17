# Reconnaissance - Network Scanning

This section focuses on network scanning techniques, primarily using Nmap, to discover hosts, open ports, and services within a target network.

## Port Scanning & Service Enumeration (Nmap)

Nmap (Network Mapper) is a powerful open-source tool for network discovery and security auditing. It can identify live hosts, open ports, services running on those ports, operating systems, and more.

*   **Basic TCP Scan:** Scans common ports using a full TCP handshake. This is a reliable but potentially noisy scan.
    ```bash
    nmap -sT example.com
    ```

*   **SYN Scan (Stealth Scan):** This is the default and most popular scan option. It sends a SYN packet and waits for a SYN/ACK. If received, it sends an RST, never completing the TCP connection, making it stealthier.
    ```bash
    nmap -sS example.com
    ```

*   **Service Version Detection & OS Detection:** Identifies the version of services running on open ports and attempts to determine the operating system of the target.
    ```bash
    nmap -sV -O example.com
    ```

*   **Aggressive Scan:** A comprehensive scan that enables OS detection, version detection, script scanning (`-sC`), and traceroute. It's fast but can be noisy.
    ```bash
    nmap -A example.com
    ```

*   **Scan Specific Ports:** You can specify individual ports or a range of ports to scan.
    ```bash
    nmap -p 21,22,80,443,3389 example.com
    nmap -p 1-65535 example.com
    ```

*   **Output to File:** Save scan results in various formats for later analysis or reporting. `-oN` for normal, `-oX` for XML.
    ```bash
    nmap -sV -sC -oN normal_output.txt -oX xml_output.xml example.com
    ```

For more detailed Nmap usage and advanced options, refer to the `Tools/Nmap.md` documentation.

