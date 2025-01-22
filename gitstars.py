import requests

# GitHub username
username = "kdairatchi"

# Initialize variables
url = f"https://api.github.com/users/kdairatchi/starred"
page = 1
repos = []

# Fetch all pages of starred repositories
while True:
    response = requests.get(url, params={"per_page": 100, "page": page})
    if response.status_code != 200:
        print(f"Error: {response.status_code} - {response.text}")
        break

    data = response.json()
    if not data:
        break  # Exit loop when no more repos are returned

    repos.extend(data)
    page += 1

# Save repositories to Markdown file
with open("starred_repos.md", "w") as file:
    file.write("# ⭐ My Starred GitHub Repositories\n\n")
    for repo in repos:
        file.write(f"### [{repo['name']}]({repo['html_url']})\n")
        file.write(f"{repo['description'] or 'No description provided.'}\n\n")
        file.write(f"**Stars:** {repo['stargazers_count']} | **Forks:** {repo['forks_count']}\n\n")
        file.write("---\n\n")

print(f"Saved {len(repos)} repositories to 'starred_repos.md'")
