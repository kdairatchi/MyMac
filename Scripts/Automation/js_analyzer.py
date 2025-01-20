import requests
import pyfiglet
from tqdm import tqdm
from colorama import Fore, init
import argparse
import re
import sys
import threading
import random

# Initialize colorama
init(autoreset=True)
requests.packages.urllib3.disable_warnings()

# List of fake User Agents
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:110.0) Gecko/20100101 Firefox/110.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 15_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.6 Mobile/15E148 Safari/604.1",
]

# Generate random IP address
def random_ip():
    return ".".join(str(random.randint(1, 255)) for _ in range(4))


class SecretFinder:
    def __init__(self, url, file, threads, proxy, output_file_name):
        self.url = url if url else None
        self.file = file if file else None
        self.threads = threads
        self.proxy = {"http": proxy, "https": proxy} if proxy else None
        self.output_file_name = output_file_name if output_file_name else None
        self.patterns = [
            (re.compile(r'AIza[0-9A-Za-z-_]{35}'), "Google API Key"),
            (re.compile(r'AKIA[0-9A-Z]{16}'), "AWS Access Key ID"),
            (re.compile(r'amzn\.mws\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'), "Amazon MWS Key"),
            (re.compile(r'sk_live_[0-9a-zA-Z]{24}'), "Stripe Live Key"),
            (re.compile(r'-----BEGIN PRIVATE KEY-----'), "Private Key"),
            (re.compile(r'eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.?[A-Za-z0-9-_.+/=]*'), "JWT Token"),
            (re.compile(r'[a-zA-Z0-9-_.]+@[a-zA-Z0-9-_.]+\.[a-zA-Z]{2,}'), "Email Address"),
        ]
        self.results = {description: [] for _, description in self.patterns}

    def banner(self):
        print(Fore.CYAN + pyfiglet.figlet_format("Secret Finder", font="slant"))

    def generate_headers(self):
        return {
            "User-Agent": random.choice(USER_AGENTS),
            "X-Forwarded-For": random_ip(),
            "X-Real-IP": random_ip(),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        }

    def fetch_and_search(self, url, progress=None):
        try:
            headers = self.generate_headers()
            response = requests.get(url, headers=headers, proxies=self.proxy, verify=False, timeout=10)
            if response.status_code == 200:
                for pattern, description in self.patterns:
                    matches = pattern.findall(response.text)
                    if matches:
                        self.results[description].append((url, matches))
        except requests.RequestException as e:
            print(Fore.RED + f"[!] Error fetching {url}: {e}")
        finally:
            if progress:
                progress.update(1)

    def run_multithreaded(self):
        with open(self.file, "r", encoding="utf-8") as f:
            urls = f.readlines()
            with tqdm(total=len(urls), desc="Scanning URLs", unit="url") as progress:
                threads = []
                for i in range(0, len(urls), self.threads):
                    for url in urls[i:i + self.threads]:
                        url = url.strip()
                        if url:
                            thread = threading.Thread(target=self.fetch_and_search, args=(url, progress))
                            threads.append(thread)
                            thread.start()
                for thread in threads:
                    thread.join()

    def output_results(self):
        if self.output_file_name:
            with open(self.output_file_name, "w", encoding="utf-8") as f:
                for description, data in self.results.items():
                    if data:
                        f.write(f"\n{description}:\n")
                        for url, matches in data:
                            f.write(f"- Found in {url}:\n")
                            for match in matches:
                                f.write(f"  {match}\n")
        else:
            for description, data in self.results.items():
                if data:
                    print(Fore.YELLOW + f"\n{description}:")
                    for url, matches in data:
                        print(Fore.CYAN + f"- Found in {url}:")
                        for match in matches:
                            print(Fore.RED + f"  {match}")

    def run(self):
        self.banner()
        if self.url:
            self.fetch_and_search(self.url)
        elif self.file:
            self.run_multithreaded()
        self.output_results()


def main():
    parser = argparse.ArgumentParser(description="Find sensitive information in JavaScript files.")
    parser.add_argument("-u", "--url", help="Single URL to scan")
    parser.add_argument("-f", "--file", help="File containing URLs to scan")
    parser.add_argument("-t", "--threads", type=int, default=10, help="Number of concurrent threads (default: 10)")
    parser.add_argument("-p", "--proxy", help="Proxy (e.g., http://127.0.0.1:8080)")
    parser.add_argument("-o", "--output", help="File to save results")
    args = parser.parse_args()

    if not args.url and not args.file:
        parser.error("You must provide either --url or --file.")
        sys.exit(1)

    finder = SecretFinder(args.url, args.file, args.threads, args.proxy, args.output)
    finder.run()


if __name__ == "__main__":
    main()
