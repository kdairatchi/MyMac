# Reconnaissance - OSINT and Subdomain Enumeration

This section covers techniques and commands for Open-Source Intelligence (OSINT) and subdomain enumeration, crucial for the initial reconnaissance phase of a red team operation.

## Subdomain Enumeration

Subdomain enumeration is the process of discovering subdomains associated with a target domain. This can reveal additional attack surface, such as development environments, internal applications, or forgotten services.

*   **Subfinder:** A fast and passive subdomain enumeration tool written in Go. It discovers valid subdomains for websites by using various sources.
    ```bash
    subfinder -d example.com -o example_subs.txt
    ```
    *   `-d`: Specify the domain to enumerate.
    *   `-o`: Output results to a file.

*   **Amass:** A powerful and versatile network mapping tool that performs in-depth DNS enumeration, brute-forcing, and scraping to discover subdomains and associated infrastructure.
    ```bash
    amass enum -d example.com
    ```
    *   `enum`: Enumerate subdomains.
    *   `-d`: Specify the domain to enumerate.

## Web Technology Fingerprinting

Identifying the technologies used by a target website can help in pinpointing potential vulnerabilities and attack vectors.

*   **WhatWeb:** A next-generation web scanner that identifies web technologies including content management systems (CMS), blogging platforms, statistic/analytics packages, JavaScript libraries, web servers, and embedded devices.
    ```bash
    whatweb example.com
    ```

*   **HTTPX:** A fast and multi-purpose HTTP toolkit that allows for quick and reliable HTTP(S) requests, enabling efficient web technology detection, status code checks, and title extraction from a list of URLs.
    ```bash
    httpx -l subdomains.txt -tech-detect -status-code -title
    ```
    *   `-l`: Input file containing a list of URLs.
    *   `-tech-detect`: Enable technology detection.
    *   `-status-code`: Display HTTP status codes.
    *   `-title`: Display page titles.


