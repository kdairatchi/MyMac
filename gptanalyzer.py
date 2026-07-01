import os
import time
import requests
from bs4 import BeautifulSoup
from transformers import pipeline
from github import Github, GithubException
import pyttsx3
import logging

# Configure logging
logging.basicConfig(filename='bug_report_bot.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Environment variable checks
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
OPENAI_API_KEY = os.getenv("***REMOVED***-0oBltwHTckRfJiNU3jWn28GjeFKIp6xD4TnLzM8_aLb8iOVCjyoPuE_Ksvl56oTn-d34e14_qGT3BlbkFJkriIBOnRzRVog2qLfAidciflwJgBGIKMRa505Yx6JZWBSTNRsEyVLziD5fPxXF2bgRTzvFfkUA")

if not GITHUB_TOKEN or not OPENAI_API_KEY:
    raise EnvironmentError("Environment variables GITHUB_TOKEN and OPENAI_API_KEY must be set.")

# Initialize GitHub client
github = Github(GITHUB_TOKEN)
repo_name = "kdairatchi/bug-report-summarize"  # Replace with your repo details
repo = github.get_repo(repo_name)

# Initialize AI summarizer
summarizer = pipeline("summarization", model="facebook/bart-large-cnn")

# Initialize text-to-speech
engine = pyttsx3.init()

def fetch_report_content(url):
    """Fetch the content of a vulnerability report."""
    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        return soup.get_text()
    except requests.RequestException as e:
        logging.error(f"Failed to fetch {url}: {e}")
        return None

def summarize_content(content):
    """Summarize the content using an AI model."""
    try:
        summary = summarizer(content, max_length=200, min_length=50, do_sample=False)
        return summary[0]['summary_text']
    except Exception as e:
        logging.error(f"Error summarizing content: {e}")
        return "Summary not available due to an error."

def save_to_github(url, title, summary):
    """Save the report summary to GitHub."""
    try:
        file_path = f"reports/{title.replace(' ', '_')}.md"
        
        # Check if file exists in the repo
        try:
            existing_file = repo.get_contents(file_path)
            repo.update_file(existing_file.path, f"Update {title}", summary, existing_file.sha)
            logging.info(f"Updated existing report: {file_path}")
        except GithubException:
            # File does not exist; create a new one
            repo.create_file(file_path, f"Add {title}", summary)
            logging.info(f"Created new report: {file_path}")
    except Exception as e:
        logging.error(f"Failed to save {title} to GitHub: {e}")

def read_aloud(text):
    """Read text aloud."""
    try:
        engine.say(text)
        engine.runAndWait()
    except Exception as e:
        logging.error(f"Text-to-speech error: {e}")

def process_report(line, options):
    """Process a single report from the input."""
    try:
        # Validate and parse the input line
        if "|" not in line:
            logging.warning(f"Skipping invalid line: {line}")
            return
        
        url, title = map(str.strip, line.split("|", 1))
        content = fetch_report_content(url)
        if not content:
            return
        
        summary = summarize_content(content)
        save_to_github(url, title, summary)
        
        # Optional features
        if options.get("read_aloud"):
            read_aloud(summary)
        if options.get("open_in_browser"):
            os.system(f"open {url}")
        
    except Exception as e:
        logging.error(f"Error processing report {line}: {e}")

def main():
    # Example report list
    report_list = [
        "https://hackerone.com/reports/120 |  Missing SPF for hackerone.com",
        "https://hackerone.com/reports/280 |  Real impersonation",
        "https://hackerone.com/reports/284 |  Broken Authentication and session management OWASP A2",
        "https://hackerone.com/reports/288 |  Session Management",
        "https://hackerone.com/reports/499 | Ruby: Heap Overflow in Floating Point Parsing"
    ]
    
    # Command-line options
    options = {
        "read_aloud": False,  # Set to True to enable text-to-speech
        "open_in_browser": False  # Set to True to open reports in a browser
    }
    
    for line in report_list:
        process_report(line, options)
        time.sleep(1)  # To handle rate limits gracefully

if __name__ == "__main__":
    main()
