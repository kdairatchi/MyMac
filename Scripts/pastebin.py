#!/usr/bin/env python3
“””
OSINT Pastebin Scanner
A comprehensive tool for searching across multiple pastebin services for intelligence gathering.
“””

import asyncio
import json
import re
import time
import hashlib
import os
import sys
import argparse
from datetime import datetime
from urllib.parse import urljoin, urlparse
from typing import List, Dict, Set, Optional, Tuple
import aiohttp
import aiofiles
from playwright.async_api import async_playwright
from dataclasses import dataclass, asdict
import logging

# Configure logging

logging.basicConfig(
level=logging.INFO,
format=’%(asctime)s - %(levelname)s - %(message)s’,
handlers=[
logging.FileHandler(‘osint_scan.log’),
logging.StreamHandler()
]
)
logger = logging.getLogger(**name**)

@dataclass
class PasteResult:
“”“Data class for paste results”””
url: str
title: str
content: str
timestamp: str
author: str
language: str
hash: str
keywords_found: List[str]
confidence_score: float
metadata: Dict

class PastebinConfig:
“”“Configuration for pastebin services”””

```
# Active pastebin services with their configurations
ACTIVE_SERVICES = {
    'pastebin.com': {
        'search_endpoint': 'https://pastebin.com/search',
        'search_method': 'custom_search',
        'selectors': {
            'content': ['.de1', '#paste_content', 'pre.prettyprint', 'textarea.textarea'],
            'title': ['h1', '.paste_box_line1 h1', '.info-top h1'],
            'author': ['.username', '.paste_box_line2 a'],
            'date': ['.paste_box_line2', '.date']
        },
        'rate_limit': 2,
        'requires_auth': False
    },
    'paste.mozilla.org': {
        'base_url': 'https://paste.mozilla.org',
        'search_method': 'sitemap_crawl',
        'selectors': {
            'content': ['pre', '.paste-content', 'code'],
            'title': ['title', 'h1'],
            'date': ['.date', '.timestamp']
        },
        'rate_limit': 1,
        'requires_auth': False
    },
    'justpaste.it': {
        'base_url': 'https://justpaste.it',
        'search_method': 'google_dork',
        'selectors': {
            'content': ['.jp-content', 'pre', '.paste-content'],
            'title': ['h1.jp-title', 'title'],
            'date': ['.jp-date', '.date']
        },
        'rate_limit': 2,
        'requires_auth': False
    },
    'hastebin.com': {
        'base_url': 'https://hastebin.com',
        'search_method': 'api_search',
        'api_endpoint': 'https://hastebin.com/documents',
        'selectors': {
            'content': ['#box code', 'pre', '.content']
        },
        'rate_limit': 1,
        'requires_auth': False
    },
    'dpaste.org': {
        'base_url': 'https://dpaste.org',
        'search_method': 'recent_crawl',
        'selectors': {
            'content': ['.code', 'pre', '.highlight'],
            'title': ['title', 'h1'],
            'language': ['.language', '.syntax']
        },
        'rate_limit': 1,
        'requires_auth': False
    },
    'paste.ee': {
        'base_url': 'https://paste.ee',
        'search_method': 'recent_crawl',
        'selectors': {
            'content': ['.source', 'pre', '.paste-content'],
            'title': ['.paste-title', 'h1'],
            'date': ['.paste-date', '.date']
        },
        'rate_limit': 2,
        'requires_auth': False
    }
}

# Authenticated services (require API keys or login)
AUTHENTICATED_SERVICES = {
    'gist.github.com': {
        'api_endpoint': 'https://api.github.com/gists',
        'requires_token': True,
        'search_method': 'api_search'
    },
    'gitlab.com': {
        'api_endpoint': 'https://gitlab.com/api/v4/snippets',
        'requires_token': True,
        'search_method': 'api_search'
    }
}

# Read-only archives
ARCHIVE_SERVICES = {
    'paste.pound-python.org': 'http://paste.pound-python.org',
    'paste.frubar.net': 'http://paste.frubar.net/',
    'geany.org': 'https://www.geany.org/p/'
}
```

class IntelligenceAnalyzer:
“”“Analyzes paste content for intelligence value”””

```
def __init__(self):
    self.patterns = {
        'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
        'phone': r'(\+\d{1,3}[-.\s]?)?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}',
        'ip_address': r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b',
        'url': r'https?://(?:[-\w.])+(?:\:[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:\#(?:[\w.])*)?)?',
        'api_key': r'(?i)(api[_-]?key|apikey|access[_-]?token|auth[_-]?token)["\'\s]*[:=]["\'\s]*([a-zA-Z0-9_-]{20,})',
        'aws_key': r'AKIA[0-9A-Z]{16}',
        'private_key': r'-----BEGIN (?:RSA )?PRIVATE KEY-----',
        'credit_card': r'\b(?:\d{4}[-\s]?){3}\d{4}\b',
        'ssn': r'\b\d{3}-\d{2}-\d{4}\b',
        'hash_md5': r'\b[a-fA-F0-9]{32}\b',
        'hash_sha1': r'\b[a-fA-F0-9]{40}\b',
        'hash_sha256': r'\b[a-fA-F0-9]{64}\b',
        'bitcoin': r'\b[13][a-km-zA-HJ-NP-Z1-9]{25,34}\b',
        'database_string': r'(?i)(server|host|database|db)["\'\s]*[:=]["\'\s]*([^\s"\']+)',
        'password': r'(?i)(password|passwd|pwd)["\'\s]*[:=]["\'\s]*([^\s"\']+)'
    }
    
    self.severity_weights = {
        'private_key': 10,
        'api_key': 9,
        'aws_key': 9,
        'password': 8,
        'database_string': 8,
        'credit_card': 7,
        'ssn': 7,
        'email': 5,
        'phone': 4,
        'ip_address': 4,
        'url': 3,
        'hash_sha256': 3,
        'hash_sha1': 2,
        'hash_md5': 2,
        'bitcoin': 6
    }

def analyze_content(self, content: str, keywords: List[str]) -> Tuple[List[str], float, Dict]:
    """Analyze paste content for intelligence value"""
    found_patterns = []
    intelligence_data = {}
    confidence_score = 0
    
    # Check for sensitive patterns
    for pattern_name, pattern in self.patterns.items():
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            found_patterns.append(pattern_name)
            intelligence_data[pattern_name] = matches[:5]  # Limit to first 5 matches
            confidence_score += self.severity_weights.get(pattern_name, 1) * min(len(matches), 3)
    
    # Check for keyword matches
    keyword_matches = []
    for keyword in keywords:
        if keyword.lower() in content.lower():
            keyword_matches.append(keyword)
            confidence_score += 5
    
    # Additional scoring based on content characteristics
    if len(content) > 10000:  # Large content
        confidence_score += 2
    if 'confidential' in content.lower() or 'secret' in content.lower():
        confidence_score += 5
    if 'internal' in content.lower() or 'private' in content.lower():
        confidence_score += 3
        
    # Normalize confidence score
    confidence_score = min(confidence_score / 50.0, 1.0)
    
    return found_patterns, confidence_score, intelligence_data
```

class UltimatePastebinOSINT:
“”“Main OSINT scanner class”””

```
def __init__(self, keywords: List[str], output_dir: str = "osint_results"):
    self.keywords = keywords
    self.output_dir = output_dir
    self.results: List[PasteResult] = []
    self.analyzer = IntelligenceAnalyzer()
    self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    self.visited_urls: Set[str] = set()
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Setup session
    self.setup_session()

def setup_session(self):
    """Setup scanning session"""
    session_info = {
        'session_id': self.session_id,
        'start_time': datetime.now().isoformat(),
        'keywords': self.keywords,
        'total_services': len(PastebinConfig.ACTIVE_SERVICES)
    }
    
    with open(f"{self.output_dir}/session_{self.session_id}.json", 'w') as f:
        json.dump(session_info, f, indent=2)

async def scan_all_services(self, max_concurrent: int = 5):
    """Scan all configured pastebin services"""
    logger.info(f"Starting OSINT scan for keywords: {', '.join(self.keywords)}")
    
    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch(
            headless=True,
            args=['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
        )
        
        # Create semaphore to limit concurrent requests
        semaphore = asyncio.Semaphore(max_concurrent)
        
        tasks = []
        for service_name, config in PastebinConfig.ACTIVE_SERVICES.items():
            task = self.scan_service_with_semaphore(semaphore, browser, service_name, config)
            tasks.append(task)
        
        # Execute all scanning tasks
        await asyncio.gather(*tasks, return_exceptions=True)
        await browser.close()
    
    # Post-processing and analysis
    await self.process_results()

async def scan_service_with_semaphore(self, semaphore, browser, service_name: str, config: Dict):
    """Scan a service with rate limiting"""
    async with semaphore:
        try:
            logger.info(f"Scanning {service_name}...")
            page = await browser.new_page()
            
            # Set user agent and other headers
            await page.set_extra_http_headers({
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            })
            
            results = await self.scan_service(page, service_name, config)
            self.results.extend(results)
            
            await page.close()
            
            # Rate limiting
            await asyncio.sleep(config.get('rate_limit', 1))
            
            logger.info(f"Completed {service_name}: found {len(results)} relevant pastes")
            
        except Exception as e:
            logger.error(f"Error scanning {service_name}: {str(e)}")

async def scan_service(self, page, service_name: str, config: Dict) -> List[PasteResult]:
    """Scan a specific pastebin service"""
    results = []
    search_method = config.get('search_method', 'custom_search')
    
    try:
        if search_method == 'custom_search':
            results = await self.custom_search(page, service_name, config)
        elif search_method == 'google_dork':
            results = await self.google_dork_search(page, service_name, config)
        elif search_method == 'recent_crawl':
            results = await self.recent_crawl(page, service_name, config)
        elif search_method == 'api_search':
            results = await self.api_search(service_name, config)
        elif search_method == 'sitemap_crawl':
            results = await self.sitemap_crawl(page, service_name, config)
            
    except Exception as e:
        logger.error(f"Error in {search_method} for {service_name}: {str(e)}")
    
    return results

async def custom_search(self, page, service_name: str, config: Dict) -> List[PasteResult]:
    """Perform custom search on pastebin services"""
    results = []
    base_url = config.get('base_url', f"https://{service_name}")
    
    try:
        await page.goto(base_url, timeout=30000)
        
        # Handle cookie consent
        await self.handle_cookie_consent(page)
        
        # Search for each keyword
        for keyword in self.keywords:
            keyword_results = await self.search_keyword(page, service_name, config, keyword)
            results.extend(keyword_results)
            
    except Exception as e:
        logger.error(f"Custom search error for {service_name}: {str(e)}")
    
    return results

async def google_dork_search(self, page, service_name: str, config: Dict) -> List[PasteResult]:
    """Use Google dorking to find pastes"""
    results = []
    base_url = config.get('base_url', f"https://{service_name}")
    
    try:
        for keyword in self.keywords:
            # Construct Google dork query
            dork_query = f'site:{service_name} "{keyword}"'
            google_url = f"https://www.google.com/search?q={dork_query}"
            
            await page.goto(google_url, timeout=30000)
            await asyncio.sleep(2)
            
            # Extract URLs from Google results
            search_results = await page.query_selector_all('a[href*="{}"]'.format(service_name))
            
            for result in search_results[:10]:  # Limit to first 10 results
                href = await result.get_attribute('href')
                if href and href not in self.visited_urls:
                    self.visited_urls.add(href)
                    paste_result = await self.extract_paste_content(page, href, config)
                    if paste_result:
                        results.append(paste_result)
            
    except Exception as e:
        logger.error(f"Google dork search error for {service_name}: {str(e)}")
    
    return results

async def recent_crawl(self, page, service_name: str, config: Dict) -> List[PasteResult]:
    """Crawl recent pastes"""
    results = []
    base_url = config.get('base_url', f"https://{service_name}")
    
    try:
        # Common recent paste URLs
        recent_urls = [
            f"{base_url}/recent",
            f"{base_url}/archive",
            f"{base_url}/public",
            f"{base_url}/browse"
        ]
        
        for url in recent_urls:
            try:
                await page.goto(url, timeout=20000)
                
                # Find paste links
                paste_links = await page.query_selector_all('a[href*="/"]')
                
                for link in paste_links[:20]:  # Limit crawling
                    href = await link.get_attribute('href')
                    if href:
                        full_url = urljoin(base_url, href)
                        if full_url not in self.visited_urls:
                            self.visited_urls.add(full_url)
                            paste_result = await self.extract_paste_content(page, full_url, config)
                            if paste_result and self.contains_keywords(paste_result.content):
                                results.append(paste_result)
                
                break  # If one URL works, don't try others
                
            except Exception:
                continue  # Try next URL
                
    except Exception as e:
        logger.error(f"Recent crawl error for {service_name}: {str(e)}")
    
    return results

async def api_search(self, service_name: str, config: Dict) -> List[PasteResult]:
    """Search using API endpoints"""
    results = []
    api_endpoint = config.get('api_endpoint')
    
    if not api_endpoint:
        return results
    
    try:
        async with aiohttp.ClientSession() as session:
            for keyword in self.keywords:
                params = {'q': keyword, 'per_page': 50}
                
                async with session.get(api_endpoint, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        # Process API response based on service
                        if service_name == 'gist.github.com':
                            results.extend(await self.process_github_gists(data, keyword))
                        elif service_name == 'gitlab.com':
                            results.extend(await self.process_gitlab_snippets(data, keyword))
                
                await asyncio.sleep(1)  # Rate limiting
                
    except Exception as e:
        logger.error(f"API search error for {service_name}: {str(e)}")
    
    return results

async def sitemap_crawl(self, page, service_name: str, config: Dict) -> List[PasteResult]:
    """Crawl using sitemap"""
    results = []
    base_url = config.get('base_url', f"https://{service_name}")
    
    try:
        sitemap_urls = [
            f"{base_url}/sitemap.xml",
            f"{base_url}/robots.txt"
        ]
        
        for sitemap_url in sitemap_urls:
            try:
                await page.goto(sitemap_url, timeout=20000)
                content = await page.content()
                
                # Extract URLs from sitemap/robots.txt
                urls = re.findall(r'https?://[^\s<>"{}|\\^`\[\]]+', content)
                
                for url in urls[:50]:  # Limit to 50 URLs
                    if url not in self.visited_urls:
                        self.visited_urls.add(url)
                        paste_result = await self.extract_paste_content(page, url, config)
                        if paste_result and self.contains_keywords(paste_result.content):
                            results.append(paste_result)
                
                break  # If sitemap works, don't check robots.txt
                
            except Exception:
                continue
                
    except Exception as e:
        logger.error(f"Sitemap crawl error for {service_name}: {str(e)}")
    
    return results

async def extract_paste_content(self, page, url: str, config: Dict) -> Optional[PasteResult]:
    """Extract content from a paste URL"""
    try:
        await page.goto(url, timeout=20000)
        await page.wait_for_load_state("domcontentloaded", timeout=10000)
        
        # Extract content using selectors
        content = await self.extract_with_selectors(page, config['selectors'].get('content', []))
        if not content:
            return None
        
        # Extract metadata
        title = await self.extract_with_selectors(page, config['selectors'].get('title', []))
        author = await self.extract_with_selectors(page, config['selectors'].get('author', []))
        date = await self.extract_with_selectors(page, config['selectors'].get('date', []))
        language = await self.extract_with_selectors(page, config['selectors'].get('language', []))
        
        # Analyze content
        found_patterns, confidence, intelligence_data = self.analyzer.analyze_content(content, self.keywords)
        
        # Create hash for deduplication
        content_hash = hashlib.sha256(content.encode()).hexdigest()
        
        return PasteResult(
            url=url,
            title=title or "Unknown",
            content=content,
            timestamp=date or datetime.now().isoformat(),
            author=author or "Unknown",
            language=language or "Unknown",
            hash=content_hash,
            keywords_found=found_patterns,
            confidence_score=confidence,
            metadata=intelligence_data
        )
        
    except Exception as e:
        logger.debug(f"Error extracting content from {url}: {str(e)}")
        return None

async def extract_with_selectors(self, page, selectors: List[str]) -> str:
    """Extract text using multiple selectors"""
    for selector in selectors:
        try:
            element = await page.query_selector(selector)
            if element:
                text = await element.inner_text()
                if text.strip():
                    return text.strip()
        except Exception:
            continue
    return ""

async def handle_cookie_consent(self, page):
    """Handle cookie consent banners"""
    cookie_selectors = [
        "button:has-text('Accept')",
        "button:has-text('OK')",
        "button:has-text('I Understand')",
        ".cookie-accept",
        "#cookie-accept"
    ]
    
    for selector in cookie_selectors:
        try:
            if await page.is_visible(selector, timeout=3000):
                await page.click(selector)
                await asyncio.sleep(1)
                break
        except Exception:
            continue

async def search_keyword(self, page, service_name: str, config: Dict, keyword: str) -> List[PasteResult]:
    """Search for a specific keyword on a service"""
    results = []
    
    try:
        # Try different search input selectors
        search_selectors = [
            'input[placeholder*="search" i]',
            'input[name*="search" i]',
            'input[type="search"]',
            '#search',
            '.search-input'
        ]
        
        search_input = None
        for selector in search_selectors:
            try:
                search_input = await page.query_selector(selector)
                if search_input:
                    break
            except Exception:
                continue
        
        if search_input:
            await search_input.fill(keyword)
            await search_input.press("Enter")
            await page.wait_for_load_state("domcontentloaded", timeout=15000)
            
            # Extract search results
            result_links = await page.query_selector_all('a[href]')
            
            for link in result_links[:10]:  # Limit to first 10 results
                href = await link.get_attribute('href')
                if href and href not in self.visited_urls:
                    self.visited_urls.add(href)
                    
                    # Convert relative URLs to absolute
                    if not href.startswith('http'):
                        base_url = config.get('base_url', f"https://{service_name}")
                        href = urljoin(base_url, href)
                    
                    paste_result = await self.extract_paste_content(page, href, config)
                    if paste_result and self.contains_keywords(paste_result.content):
                        results.append(paste_result)
        
    except Exception as e:
        logger.debug(f"Search keyword error for {service_name}: {str(e)}")
    
    return results

def contains_keywords(self, content: str) -> bool:
    """Check if content contains any of the target keywords"""
    content_lower = content.lower()
    return any(keyword.lower() in content_lower for keyword in self.keywords)

async def process_results(self):
    """Process and analyze all results"""
    logger.info(f"Processing {len(self.results)} total results...")
    
    # Remove duplicates based on content hash
    unique_results = {}
    for result in self.results:
        if result.hash not in unique_results:
            unique_results[result.hash] = result
        else:
            # Keep the one with higher confidence score
            if result.confidence_score > unique_results[result.hash].confidence_score:
                unique_results[result.hash] = result
    
    self.results = list(unique_results.values())
    
    # Sort by confidence score
    self.results.sort(key=lambda x: x.confidence_score, reverse=True)
    
    # Save results
    await self.save_results()
    
    # Generate report
    await self.generate_report()

async def save_results(self):
    """Save results to various formats"""
    timestamp = datetime.now().isoformat()
    
    # Save as JSON
    json_results = [asdict(result) for result in self.results]
    json_file = f"{self.output_dir}/results_{self.session_id}.json"
    
    async with aiofiles.open(json_file, 'w') as f:
        await f.write(json.dumps(json_results, indent=2, default=str))
    
    # Save high-confidence results separately
    high_confidence = [r for r in self.results if r.confidence_score > 0.7]
    if high_confidence:
        hc_file = f"{self.output_dir}/high_confidence_{self.session_id}.json"
        async with aiofiles.open(hc_file, 'w') as f:
            await f.write(json.dumps([asdict(r) for r in high_confidence], indent=2, default=str))
    
    # Save summary statistics
    stats = {
        'total_results': len(self.results),
        'high_confidence': len(high_confidence),
        'keywords_searched': self.keywords,
        'scan_timestamp': timestamp,
        'top_patterns': self.get_pattern_statistics()
    }
    
    stats_file = f"{self.output_dir}/statistics_{self.session_id}.json"
    async with aiofiles.open(stats_file, 'w') as f:
        await f.write(json.dumps(stats, indent=2))

def get_pattern_statistics(self) -> Dict:
    """Get statistics about found patterns"""
    pattern_counts = {}
    for result in self.results:
        for pattern in result.keywords_found:
            pattern_counts[pattern] = pattern_counts.get(pattern, 0) + 1
    
    return dict(sorted(pattern_counts.items(), key=lambda x: x[1], reverse=True))

async def generate_report(self):
    """Generate a comprehensive OSINT report"""
    report_file = f"{self.output_dir}/report_{self.session_id}.md"
    
    report_content = f"""# OSINT Pastebin Scan Report
```

## Scan Summary

- **Session ID**: {self.session_id}
- **Keywords**: {’, ’.join(self.keywords)}
- **Total Results**: {len(self.results)}
- **High Confidence Results**: {len([r for r in self.results if r.confidence_score > 0.7])}
- **Scan Date**: {datetime.now().strftime(’%Y-%m-%d %H:%M:%S’)}

## Top Findings

“””

```
    # Add top 10 results
    for i, result in enumerate(self.results[:10], 1):
        report_content += f"""### Result {i} - Confidence: {result.confidence_score:.2f}
```

- **URL**: {result.url}
- **Title**: {result.title}
- **Author**: {result.author}
- **Patterns Found**: {’, ’.join(result.keywords_found)}
- **Content Preview**: {result.content[:200]}…

“””

```
    # Add pattern statistics
    pattern_stats = self.get_pattern_statistics()
    if pattern_stats:
        report_content += "\n## Pattern Analysis\n\n"
        for pattern, count in pattern_stats.items():
            report_content += f"- **{pattern}**: {count} occurrences\n"
    
    # Add recommendations
    report_content += f"""
```

## Security Recommendations

Based on the scan results, the following actions are recommended:

1. **Immediate Actions**: Review high-confidence results for sensitive data exposure
1. **Monitoring**: Set up alerts for keywords found in this scan
1. **Investigation**: Verify the authenticity and context of found pastes
1. **Mitigation**: If sensitive data is confirmed, contact paste services for removal

## Files Generated

- `results_{self.session_id}.json`: Complete results in JSON format
- `high_confidence_{self.session_id}.json`: High-confidence results only
- `statistics_{self.session_id}.json`: Scan statistics
- `report_{self.session_id}.md`: This report

-----

Generated by Ultimate OSINT Pastebin Scanner
“””

```
    async with aiofiles.open(report_file, 'w') as f:
        await f.write(report_content)
    
    logger.info(f"Report generated: {report_file}")
```

def main():
“”“Main function with CLI interface”””
parser = argparse.ArgumentParser(description=‘Ultimate OSINT Pastebin Scanner’)
parser.add_argument(‘keywords’, nargs=’+’, help=‘Keywords to search for’)
parser.add_argument(’–output’, ‘-o’, default=‘osint_results’, help=‘Output directory’)
parser.add_argument(’–concurrent’, ‘-c’, type=int, default=5, help=‘Max concurrent requests’)
parser.add_argument(’–verbose’, ‘-v’, action=‘store_true’, help=‘Verbose logging’)

```
args = parser.parse_args()

if args.verbose:
    logging.getLogger().setLevel(logging.DEBUG)

# Create and run scanner
scanner = UltimatePastebinOSINT(args.keywords, args.output)

try:
    asyncio.run(scanner.scan_all_services(args.concurrent))
    print(f"\n✅ Scan completed successfully!")
    print(f"📁 Results saved to: {args.output}/")
    print(f"📊 Report available at: {args.output}/report_{scanner.session_id}.md")
    
    # Display quick summary
    high_confidence = [r for r in scanner.results if r.confidence_score > 0.7]
    print(f"\n📈 Quick Summary:")
    print(f"   Total results: {len(scanner.results)}")
    print(f"   High confidence: {len(high_confidence)}")
    
    if high_confidence:
        print(f"\n🚨 Top High-Confidence Results:")
        for i, result in enumerate(high_confidence[:3], 1):
            print(f"   {i}. {result.url} (Score: {result.confidence_score:.2f})")
            print(f"      Patterns: {', '.join(result.keywords_found)}")
    
except KeyboardInterrupt:
    print("\n❌ Scan interrupted by user")
    sys.exit(1)
except Exception as e:
    print(f"\n❌ Scan failed: {str(e)}")
    logger.error(f"Scan failed: {str(e)}", exc_info=True)
    sys.exit(1)
```

async def process_github_gists(scanner, data: List[Dict], keyword: str) -> List[PasteResult]:
“”“Process GitHub Gists API response”””
results = []

```
for gist in data:
    try:
        # Get gist content
        files = gist.get('files', {})
        content = ""
        
        for filename, file_data in files.items():
            if 'content' in file_data:
                content += file_data['content'] + "\n"
        
        if not content or not scanner.contains_keywords(content):
            continue
        
        # Analyze content
        found_patterns, confidence, intelligence_data = scanner.analyzer.analyze_content(content, scanner.keywords)
        
        result = PasteResult(
            url=gist.get('html_url', ''),
            title=gist.get('description', 'Untitled Gist'),
            content=content,
            timestamp=gist.get('created_at', ''),
            author=gist.get('owner', {}).get('login', 'Unknown'),
            language=list(files.keys())[0] if files else 'Unknown',
            hash=hashlib.sha256(content.encode()).hexdigest(),
            keywords_found=found_patterns,
            confidence_score=confidence,
            metadata=intelligence_data
        )
        
        results.append(result)
        
    except Exception as e:
        logger.debug(f"Error processing GitHub gist: {str(e)}")
        continue

return results
```

async def process_gitlab_snippets(scanner, data: List[Dict], keyword: str) -> List[PasteResult]:
“”“Process GitLab Snippets API response”””
results = []

```
for snippet in data:
    try:
        # GitLab API requires additional request for snippet content
        snippet_id = snippet.get('id')
        if not snippet_id:
            continue
        
        # For now, we'll use the description and title for analysis
        content = f"{snippet.get('title', '')} {snippet.get('description', '')}"
        
        if not scanner.contains_keywords(content):
            continue
        
        # Analyze content
        found_patterns, confidence, intelligence_data = scanner.analyzer.analyze_content(content, scanner.keywords)
        
        result = PasteResult(
            url=snippet.get('web_url', ''),
            title=snippet.get('title', 'Untitled Snippet'),
            content=content,
            timestamp=snippet.get('created_at', ''),
            author=snippet.get('author', {}).get('username', 'Unknown'),
            language=snippet.get('file_name', '').split('.')[-1] if '.' in snippet.get('file_name', '') else 'Unknown',
            hash=hashlib.sha256(content.encode()).hexdigest(),
            keywords_found=found_patterns,
            confidence_score=confidence,
            metadata=intelligence_data
        )
        
        results.append(result)
        
    except Exception as e:
        logger.debug(f"Error processing GitLab snippet: {str(e)}")
        continue

return results
```

class InteractiveMode:
“”“Interactive mode for the OSINT scanner”””

```
def __init__(self):
    self.scanner = None

def run(self):
    """Run interactive mode"""
    print("🔍 Ultimate OSINT Pastebin Scanner - Interactive Mode")
    print("=" * 60)
    
    while True:
        try:
            self.show_menu()
            choice = input("\nSelect option: ").strip()
            
            if choice == '1':
                self.start_new_scan()
            elif choice == '2':
                self.view_results()
            elif choice == '3':
                self.export_results()
            elif choice == '4':
                self.show_statistics()
            elif choice == '5':
                self.configure_settings()
            elif choice == '6':
                print("👋 Goodbye!")
                break
            else:
                print("❌ Invalid option. Please try again.")
                
        except KeyboardInterrupt:
            print("\n👋 Goodbye!")
            break
        except Exception as e:
            print(f"❌ Error: {str(e)}")

def show_menu(self):
    """Display main menu"""
    print("\n📋 Main Menu:")
    print("1. 🚀 Start New Scan")
    print("2. 📊 View Results")
    print("3. 💾 Export Results")
    print("4. 📈 Show Statistics")
    print("5. ⚙️  Configure Settings")
    print("6. 🚪 Exit")

def start_new_scan(self):
    """Start a new OSINT scan"""
    print("\n🚀 Starting New Scan")
    print("-" * 30)
    
    # Get keywords
    keywords_input = input("Enter keywords (comma-separated): ").strip()
    if not keywords_input:
        print("❌ No keywords provided.")
        return
    
    keywords = [k.strip() for k in keywords_input.split(',')]
    
    # Get output directory
    output_dir = input("Output directory (default: osint_results): ").strip()
    if not output_dir:
        output_dir = "osint_results"
    
    # Get concurrent requests
    try:
        concurrent = int(input("Max concurrent requests (default: 5): ") or "5")
    except ValueError:
        concurrent = 5
    
    # Create scanner and run
    self.scanner = UltimatePastebinOSINT(keywords, output_dir)
    
    print(f"\n🔍 Scanning for: {', '.join(keywords)}")
    print("⏳ This may take several minutes...")
    
    try:
        asyncio.run(self.scanner.scan_all_services(concurrent))
        
        print(f"\n✅ Scan completed!")
        print(f"📁 Results saved to: {output_dir}/")
        
        # Show quick results
        high_confidence = [r for r in self.scanner.results if r.confidence_score > 0.7]
        print(f"\n📊 Results Summary:")
        print(f"   Total: {len(self.scanner.results)}")
        print(f"   High confidence: {len(high_confidence)}")
        
    except Exception as e:
        print(f"❌ Scan failed: {str(e)}")

def view_results(self):
    """View scan results"""
    if not self.scanner or not self.scanner.results:
        print("❌ No results available. Run a scan first.")
        return
    
    print(f"\n📊 Viewing Results ({len(self.scanner.results)} total)")
    print("-" * 50)
    
    # Show top 10 results
    for i, result in enumerate(self.scanner.results[:10], 1):
        print(f"\n{i}. 🔗 {result.url}")
        print(f"   📝 Title: {result.title}")
        print(f"   🎯 Confidence: {result.confidence_score:.2f}")
        print(f"   🔍 Patterns: {', '.join(result.keywords_found) if result.keywords_found else 'None'}")
        print(f"   👤 Author: {result.author}")
        print(f"   📅 Date: {result.timestamp}")
        print(f"   📄 Preview: {result.content[:100]}...")
    
    if len(self.scanner.results) > 10:
        print(f"\n... and {len(self.scanner.results) - 10} more results")

def export_results(self):
    """Export results in different formats"""
    if not self.scanner or not self.scanner.results:
        print("❌ No results available. Run a scan first.")
        return
    
    print("\n💾 Export Options:")
    print("1. 📄 CSV Export")
    print("2. 📊 Excel Export")
    print("3. 🔧 Custom JSON Export")
    
    choice = input("Select export format: ").strip()
    
    if choice == '1':
        self.export_csv()
    elif choice == '2':
        self.export_excel()
    elif choice == '3':
        self.export_custom_json()
    else:
        print("❌ Invalid option.")

def export_csv(self):
    """Export results to CSV"""
    try:
        import csv
        
        filename = f"{self.scanner.output_dir}/export_{self.scanner.session_id}.csv"
        
        with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = ['url', 'title', 'author', 'confidence_score', 'patterns_found', 'timestamp']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            writer.writeheader()
            for result in self.scanner.results:
                writer.writerow({
                    'url': result.url,
                    'title': result.title,
                    'author': result.author,
                    'confidence_score': result.confidence_score,
                    'patterns_found': ', '.join(result.keywords_found),
                    'timestamp': result.timestamp
                })
        
        print(f"✅ CSV exported to: {filename}")
        
    except Exception as e:
        print(f"❌ Export failed: {str(e)}")

def export_excel(self):
    """Export results to Excel (requires openpyxl)"""
    try:
        import openpyxl
        from openpyxl import Workbook
        
        wb = Workbook()
        ws = wb.active
        ws.title = "OSINT Results"
        
        # Headers
        headers = ['URL', 'Title', 'Author', 'Confidence Score', 'Patterns Found', 'Timestamp', 'Content Preview']
        ws.append(headers)
        
        # Data
        for result in self.scanner.results:
            ws.append([
                result.url,
                result.title,
                result.author,
                result.confidence_score,
                ', '.join(result.keywords_found),
                result.timestamp,
                result.content[:200] + '...' if len(result.content) > 200 else result.content
            ])
        
        filename = f"{self.scanner.output_dir}/export_{self.scanner.session_id}.xlsx"
        wb.save(filename)
        
        print(f"✅ Excel exported to: {filename}")
        
    except ImportError:
        print("❌ openpyxl not installed. Install with: pip install openpyxl")
    except Exception as e:
        print(f"❌ Export failed: {str(e)}")

def export_custom_json(self):
    """Export custom filtered JSON"""
    min_confidence = float(input("Minimum confidence score (0.0-1.0): ") or "0.0")
    
    filtered_results = [
        asdict(result) for result in self.scanner.results 
        if result.confidence_score >= min_confidence
    ]
    
    filename = f"{self.scanner.output_dir}/filtered_export_{self.scanner.session_id}.json"
    
    with open(filename, 'w') as f:
        json.dump(filtered_results, f, indent=2, default=str)
    
    print(f"✅ Filtered JSON exported to: {filename}")
    print(f"📊 Exported {len(filtered_results)} results with confidence >= {min_confidence}")

def show_statistics(self):
    """Show detailed statistics"""
    if not self.scanner or not self.scanner.results:
        print("❌ No results available. Run a scan first.")
        return
    
    print("\n📈 Detailed Statistics")
    print("=" * 40)
    
    # Basic stats
    total_results = len(self.scanner.results)
    high_confidence = len([r for r in self.scanner.results if r.confidence_score > 0.7])
    medium_confidence = len([r for r in self.scanner.results if 0.3 <= r.confidence_score <= 0.7])
    low_confidence = len([r for r in self.scanner.results if r.confidence_score < 0.3])
    
    print(f"📊 Result Distribution:")
    print(f"   Total Results: {total_results}")
    print(f"   High Confidence (>0.7): {high_confidence}")
    print(f"   Medium Confidence (0.3-0.7): {medium_confidence}")
    print(f"   Low Confidence (<0.3): {low_confidence}")
    
    # Pattern statistics
    pattern_stats = self.scanner.get_pattern_statistics()
    if pattern_stats:
        print(f"\n🔍 Pattern Analysis:")
        for pattern, count in list(pattern_stats.items())[:10]:
            print(f"   {pattern}: {count} occurrences")
    
    # Service statistics
    service_stats = {}
    for result in self.scanner.results:
        domain = urlparse(result.url).netloc
        service_stats[domain] = service_stats.get(domain, 0) + 1
    
    if service_stats:
        print(f"\n🌐 Results by Service:")
        for service, count in sorted(service_stats.items(), key=lambda x: x[1], reverse=True):
            print(f"   {service}: {count} results")

def configure_settings(self):
    """Configure scanner settings"""
    print("\n⚙️ Configuration Options:")
    print("1. 🔧 View Current Services")
    print("2. 📝 Add Custom Service")
    print("3. 🚫 Disable Service")
    print("4. ⏱️ Adjust Rate Limits")
    
    choice = input("Select option: ").strip()
    
    if choice == '1':
        self.show_services()
    elif choice == '2':
        self.add_custom_service()
    elif choice == '3':
        self.disable_service()
    elif choice == '4':
        self.adjust_rate_limits()
    else:
        print("❌ Invalid option.")

def show_services(self):
    """Show configured services"""
    print("\n🔧 Configured Services:")
    print("-" * 30)
    
    for service_name, config in PastebinConfig.ACTIVE_SERVICES.items():
        status = "✅ Active"
        print(f"{service_name}: {status}")
        print(f"   Method: {config.get('search_method', 'Unknown')}")
        print(f"   Rate Limit: {config.get('rate_limit', 1)}s")
        print(f"   Auth Required: {config.get('requires_auth', False)}")
        print()

def add_custom_service(self):
    """Add a custom pastebin service"""
    print("\n📝 Add Custom Service")
    print("-" * 25)
    
    name = input("Service name (e.g., custom.pastebin.com): ").strip()
    if not name:
        print("❌ Service name required.")
        return
    
    base_url = input("Base URL: ").strip()
    if not base_url:
        print("❌ Base URL required.")
        return
    
    search_method = input("Search method (custom_search/google_dork/recent_crawl): ").strip()
    if search_method not in ['custom_search', 'google_dork', 'recent_crawl']:
        search_method = 'custom_search'
    
    try:
        rate_limit = int(input("Rate limit (seconds, default 2): ") or "2")
    except ValueError:
        rate_limit = 2
    
    # Add to configuration
    PastebinConfig.ACTIVE_SERVICES[name] = {
        'base_url': base_url,
        'search_method': search_method,
        'selectors': {
            'content': ['pre', '.content', '.paste-content'],
            'title': ['title', 'h1'],
            'author': ['.author', '.username'],
            'date': ['.date', '.timestamp']
        },
        'rate_limit': rate_limit,
        'requires_auth': False
    }
    
    print(f"✅ Added custom service: {name}")

def disable_service(self):
    """Disable a service"""
    print("\n🚫 Disable Service")
    print("-" * 20)
    
    print("Available services:")
    services = list(PastebinConfig.ACTIVE_SERVICES.keys())
    for i, service in enumerate(services, 1):
        print(f"{i}. {service}")
    
    try:
        choice = int(input("Service number to disable: ")) - 1
        if 0 <= choice < len(services):
            service_name = services[choice]
            del PastebinConfig.ACTIVE_SERVICES[service_name]
            print(f"✅ Disabled service: {service_name}")
        else:
            print("❌ Invalid service number.")
    except ValueError:
        print("❌ Invalid input.")

def adjust_rate_limits(self):
    """Adjust rate limits for services"""
    print("\n⏱️ Adjust Rate Limits")
    print("-" * 25)
    
    for service_name, config in PastebinConfig.ACTIVE_SERVICES.items():
        current_limit = config.get('rate_limit', 1)
        print(f"\n{service_name} (current: {current_limit}s)")
        
        try:
            new_limit = input(f"New rate limit (press Enter to keep {current_limit}): ").strip()
            if new_limit:
                config['rate_limit'] = int(new_limit)
                print(f"✅ Updated {service_name} rate limit to {new_limit}s")
        except ValueError:
            print("❌ Invalid number, keeping current limit.")
```

if **name** == “**main**”:
if len(sys.argv) == 1:
# Run in interactive mode
interactive = InteractiveMode()
interactive.run()
else:
# Run in CLI mode
main()