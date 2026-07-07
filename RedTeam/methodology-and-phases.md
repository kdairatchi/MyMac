# Red Team Methodology and Phases

Standard red team engagement lifecycle. Terminology varies by shop, phases don't:

1. **Planning and Reconnaissance:**
    * **Rules of Engagement (ROE):** Defining the scope, objectives, authorized techniques, and limitations of the engagement with the client.
    * **Threat Modeling:** Identifying potential threats and attack vectors relevant to the target environment.
    * **Open-Source Intelligence (OSINT):** Gathering information about the target organization, its infrastructure, employees, and public-facing assets using publicly available sources.
    * **Active Reconnaissance:** Probing the target's network and systems to identify live hosts, open ports, services, and potential vulnerabilities (within ROE).

2. **Initial Access:**
    * **Phishing/Social Engineering:** Crafting convincing lures to gain initial access through user compromise.
    * **Exploiting Public-Facing Applications:** Leveraging vulnerabilities in web applications, VPNs, or other internet-accessible services.
    * **Physical Access:** Gaining unauthorized physical entry to facilities (if within scope).
    * **Supply Chain Attacks:** Targeting third-party vendors or partners to gain access to the primary target.

3. **Exploitation and Foothold Establishment:**
    * **Vulnerability Exploitation:** Using identified vulnerabilities to gain a foothold on target systems.
    * **Payload Delivery:** Deploying malicious code or implants to establish remote access.
    * **Command and Control (C2):** Setting up covert communication channels to control compromised systems and exfiltrate data.

4. **Privilege Escalation:**
    * **System-level Exploits:** Leveraging misconfigurations or vulnerabilities to gain higher privileges on a compromised system (e.g., root on Linux, Administrator on Windows).
    * **Kernel Exploits:** Exploiting vulnerabilities in the operating system kernel.
    * **Credential Theft:** Harvesting credentials (hashes, plain-text passwords, tokens) from memory, files, or network traffic.

5. **Internal Reconnaissance and Lateral Movement:**
    * **Network Mapping:** Discovering internal network topology, subnets, and connected devices.
    * **Service Enumeration:** Identifying running services and their configurations on internal hosts.
    * **Lateral Movement Techniques:** Moving from one compromised system to another within the network, often using stolen credentials, Pass-the-Hash, or other techniques.

6. **Persistence:**
    * **Backdoors:** Establishing covert mechanisms to maintain access to compromised systems even after reboots or security control updates.
    * **Scheduled Tasks/Services:** Creating scheduled tasks or services to re-establish access.
    * **Registry Modifications:** Modifying Windows Registry for persistence.

7. **Actions on Objectives (AoO):**
    * **Data Exfiltration:** Stealing sensitive data from the target network.
    * **Impact Simulation:** Simulating disruptive actions (e.g., data destruction, service disruption) to assess business continuity and incident response capabilities (with strict client approval).
    * **Domain Dominance:** Gaining full control over Active Directory or other critical infrastructure.

8. **Reporting and Remediation:**
    * **Post-Engagement Analysis:** Documenting all actions taken, vulnerabilities exploited, and data accessed.
    * **Debriefing:** Presenting findings to the client, including technical details, impact assessment, and recommendations for remediation.
    * **Lessons Learned:** Identifying areas for improvement in both the red team's operations and the client's security defenses.

