# Red Team Tools and C2 Frameworks

Red team operations leverage a variety of tools across different phases of an engagement. These tools facilitate tasks from reconnaissance and initial access to post-exploitation and persistence. Command and Control (C2) frameworks are central to managing compromised systems and maintaining covert communication.

## Categories of Red Team Tools:

1.  **Reconnaissance & OSINT Tools:**
    *   **Nmap:** Network scanner for host discovery, port scanning, and service enumeration.
    *   **Maltego:** Open-source intelligence and graphical link analysis tool.
    *   **Subfinder/Amass:** Subdomain enumeration tools.
    *   **WhatWeb/httpx:** Web technology fingerprinting.
    *   **Shodan/Censys:** Search engines for internet-connected devices.

2.  **Initial Access & Exploitation Tools:**
    *   **Metasploit Framework:** A powerful penetration testing framework for developing, executing, and testing exploits.
    *   **Burp Suite:** Web vulnerability scanner and proxy for web application testing.
    *   **SQLMap:** Automatic SQL injection and database takeover tool.
    *   **Social Engineering Toolkit (SET):** For various social engineering attacks (phishing, spear-phishing).
    *   **CrackMapExec (CME):** Post-exploitation tool for active directory environments.

3.  **Post-Exploitation & Privilege Escalation Tools:**
    *   **Mimikatz:** Extracts credentials from Windows memory.
    *   **PowerSploit:** PowerShell scripts for post-exploitation tasks (recon, privilege escalation, persistence).
    *   **BloodHound:** Graphs Active Directory relationships to identify attack paths.
    *   **LinPEAS/WinPEAS:** Scripts for local privilege escalation enumeration on Linux and Windows.
    *   **Impacket:** Collection of Python classes for working with network protocols, often used for lateral movement and credential relay attacks.

4.  **Command and Control (C2) Frameworks:**
    C2 frameworks are critical for managing implants, executing commands, and exfiltrating data from compromised networks while evading detection. They provide a centralized platform for red team operators.

    *   **Cobalt Strike:** A popular commercial C2 framework known for its Malleable C2 profiles, Beacon payload, and extensive post-exploitation capabilities. (Often emulated by other tools).
    *   **Mythic:** An open-source C2 framework that supports multiple agents and C2 profiles.
    *   **PoshC2:** An open-source PowerShell and Python C2 framework.
    *   **Covenant:** A .NET C2 framework designed for red team operations.
    *   **Havoc:** A modern, open-source C2 framework with a focus on stealth and evasion.
    *   **Nighthawk:** An advanced commercial C2 framework.

5.  **Evasion & Obfuscation Tools:**
    *   **Donut:** Shellcode generation tool that creates position-independent shellcode from .NET assemblies.
    *   **Sliver:** Go-based cross-platform C2 framework with advanced evasion capabilities.

6.  **Utilities & Miscellaneous:**
    *   **Exiftool:** For reading and writing metadata in files.
    *   **Gobuster/WFuzz:** Directory and file brute-forcing tools.
    *   **Chisel:** A fast TCP/UDP tunnel over HTTP.
    *   **Proxychains:** Force any TCP connection made by a program to go through SOCKS5 or HTTP proxies.

This categorized list will be used to guide the creation of detailed cheatsheets and tool documentation in subsequent phases.

