# Reconnaissance - OSINT and Subdomain Enumeration

OSINT + subdomain enum for the recon phase. More subdomains = more attack surface: dev environments, internal apps, forgotten services.

## Subdomain Enumeration

* **Subfinder:** fast, passive subdomain enum, multiple sources.

    ```bash
    subfinder -d example.com -o example_subs.txt
    ```

  * `-d`: Specify the domain to enumerate.
  * `-o`: Output results to a file.

* **Amass:** network mapping — DNS enum, brute-force, scraping for subdomains + infra.

    ```bash
    amass enum -d example.com
    ```

  * `enum`: Enumerate subdomains.
  * `-d`: Specify the domain to enumerate.

## Web Technology Fingerprinting

Knowing the stack narrows down which vulns to try first.

* **WhatWeb:** fingerprints CMS, JS libs, web servers, embedded devices.

    ```bash
    whatweb example.com
    ```

* **HTTPX:** fast HTTP toolkit — tech detection, status codes, titles, across a list of URLs.

    ```bash
    httpx -l subdomains.txt -tech-detect -status-code -title
    ```

  * `-l`: Input file containing a list of URLs.
  * `-tech-detect`: Enable technology detection.
  * `-status-code`: Display HTTP status codes.
  * `-title`: Display page titles.
