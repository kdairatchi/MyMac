#!/Users/anom/tools/env/bin/python
# blackwidow by @Kdairatchi 

from bs4 import BeautifulSoup
from urllib.parse import urlparse
import requests
import sys
import os
import atexit
import optparse

requests.packages.urllib3.disable_warnings()

# Color codes for terminal output
OKBLUE = '\033[94m'
OKRED = '\033[91m'
OKGREEN = '\033[92m'
OKORANGE = '\033[93m'
COLOR1 = '\033[95m'
COLOR2 = '\033[96m'
RESET = '\x1b[0m'

def read_links(url, domain, port, save_dir, cookies):
    """Fetch and parse links from the given URL."""
    try:
        headers = {'Cookie': cookies} if cookies else {}
        response = requests.get(url, headers=headers, verify=False)
        response.raise_for_status()  # Raise an error for bad responses
        data = response.text
        soup = BeautifulSoup(data, "lxml")
        
        # Open files for writing
        with open(f"{save_dir}{domain}_{port}-urls.txt", "a") as urls_file, \
             open(f"{save_dir}{domain}_{port}-forms.txt", "a") as forms_file, \
             open(f"{save_dir}{domain}_{port}-subdomains.txt", "a") as subdomains_file, \
             open(f"{save_dir}{domain}_{port}-emails.txt", "a") as emails_file, \
             open(f"{save_dir}{domain}_{port}-phones.txt", "a") as phones_file:

            print(f"\n{OKGREEN}Scanning: {url}{RESET}")
            for form in soup.find_all('form'):
                forms_file.write(url + "\n")

            for link in soup.find_all('a', href=True):
                href = link.get('href')
                parsed_uri = urlparse(href)
                link_domain = parsed_uri.netloc

                # Check for subdomains
                if domain != link_domain and link_domain:
                    print(f"{COLOR1}[+] Sub-domain found: {link_domain}{RESET}")
                    subdomains_file.write(link_domain + "\n")

                # Handle different types of links
                if href.startswith("http"):
                    if domain in href:
                        urls_file.write(href + "\n")
                    elif "?" in href:
                        print(f"{OKRED}[+] Dynamic URL found: {href}{RESET}")
                        urls_file.write(href + "\n")
                elif href.startswith("tel:"):
                    phone_num = href.split(':')[1]
                    print(f"{OKORANGE}[i] Telephone # found: {phone_num}{RESET}")
                    phones_file.write(phone_num + "\n")
                elif href.startswith("mailto:"):
                    email = href.split(':')[1]
                    print(f"{OKORANGE}[i] Email found: {email}{RESET}")
                    emails_file.write(email + "\n")
                else:
                    full_url = url + "/" + href
                    urls_file.write(full_url + "\n")

    except requests.RequestException as e:
        print(f"{OKRED}Error fetching {url}: {e}{RESET}")

def exit_handler(save_dir, domain, port):
    """Sort and clean up files on exit."""
    for file_type in ['urls', 'forms', 'dynamic', 'subdomains', 'emails', 'phones']:
        os.system(f'sort -u {save_dir}{domain}_{port}-{file_type}.txt > {save_dir}{domain}_{port}-{file_type}-sorted.txt 2>/dev/null')
        os.system(f'rm -f {save_dir}{domain}_{port}-{file_type}.txt')

    print(f"{OKGREEN}[+] Results saved in: {save_dir}{RESET}")

def readfile(url, domain, port, save_dir, cookies):
    """Placeholder for reading URLs from a file and processing them."""
    # Implement the logic to read URLs from a file and call read_links on them
    pass  # Replace with actual implementation

def logo():
    """Display the logo of the tool."""
    print(f"{OKBLUE}Blackwidow - Web Crawler {RESET}")

def main():
    logo()
    if len(sys.argv) < 2:
        print("You need to specify a URL to scan. Use --help for all options.")
        sys.exit()
    
    parser = optparse.OptionParser()
    parser.add_option('-u', '--url', action="store", dest="url", help="Full URL to spider", default="")
    parser.add_option('-d', '--domain', action="store", dest="domain", help="Domain name to spider", default="")
    parser.add_option('-c', '--cookie', action="store", dest="cookie", help="Cookies to send", default="")
    parser.add_option('-l', '--level', action="store", dest="level", help="Level of depth to traverse", default="2")
    parser.add_option('-s', '--scan', action="store", dest="scan", help="Scan all dynamic URLs found", default="n")
    parser.add_option('-p', '--port', action="store", dest="port", help="Port for the URL", default="80")
    parser.add_option('-v', '--verbose', action="store", dest="verbose", help="Set verbose mode ON", default="y")

    options, args = parser.parse_args()
    target = str(options.url)
    domain = str(options.domain)
    cookies = str(options.cookie)
    max_depth = int(options.level)
    scan = str(options.scan)
    port = str(options.port)

    if ":" not in target:
        url = f"http://{domain}:{port}" if len(target) <= 6 else f"{target}:{port}"
    else:
        url = target
        parsed_uri = urlparse(target)
        domain = parsed_uri.netloc.split(':')[0]
        port = parsed_uri.port or port

    save_dir = f"/Users/anom/tools/Scripts/blackwidow/{domain}_{port}/"
    os.makedirs(save_dir, exist_ok=True)
    atexit.register(exit_handler, save_dir, domain, port)

    try:
        read_links(url, domain, port, save_dir, cookies)
    except Exception as ex:
        print(ex)

    for level in range(1, max_depth + 1):
        try:
            readfile(url, domain, port, save_dir, cookies)
        except Exception as ex:
            print(ex)

if __name__ == "__main__":
    main()
