
import markdown
import os
import shutil

def convert_md_to_html(input_root_dir, output_docs_dir):
    # Ensure the output directory exists and is clean
    if os.path.exists(output_docs_dir):
        shutil.rmtree(output_docs_dir)
    os.makedirs(output_docs_dir)

    # Exclude these directories from processing
    exclude_dirs = [
        ".git", 
        ".nvm", 
        "upload", 
        "node_modules", 
        "__pycache__", 
        "venv", 
        "docs" # Exclude the output directory itself
    ]

    # Create a basic CSS file for styling in the docs directory
    css_content = """
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 0;
    background-color: #f4f4f4;
    color: #333;
}
.container {
    width: 80%;
    margin: auto;
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    margin-top: 20px;
    margin-bottom: 20px;
}
h1, h2, h3, h4, h5, h6 {
    color: #0056b3;
}
pre {
    background-color: #eee;
    padding: 10px;
    border-radius: 5px;
    overflow-x: auto;
}
code {
    font-family: "Courier New", Courier, monospace;
}
a {
    color: #007bff;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
"""
    with open(os.path.join(output_docs_dir, 'styles.css'), 'w', encoding='utf-8') as f:
        f.write(css_content)
    print(f"Created {os.path.join(output_docs_dir, 'styles.css')}")

    for root, dirs, files in os.walk(input_root_dir):
        # Filter out excluded directories for traversal
        dirs[:] = [d for d in dirs if d not in exclude_dirs]

        for file in files:
            if file.endswith(".md"):
                input_filepath = os.path.join(root, file)
                
                # Skip the script itself if it's in the root and named .md
                if input_filepath == os.path.join(input_root_dir, 'convert_md_to_html.py'):
                    continue

                # Determine the relative path from the input_root_dir
                relative_path = os.path.relpath(input_filepath, input_root_dir)
                
                # Construct the output HTML filepath, maintaining directory structure
                # and changing .md to .html
                output_filepath = os.path.join(output_docs_dir, os.path.splitext(relative_path)[0] + ".html")

                # Ensure the output directory for the HTML file exists
                os.makedirs(os.path.dirname(output_filepath), exist_ok=True)

                with open(input_filepath, "r", encoding="utf-8") as f:
                    md_content = f.read()

                html_content = markdown.markdown(md_content)

                # Extract title from filename for HTML <title> tag
                title = os.path.splitext(os.path.basename(file))[0].replace("_", " ").title()

                # Add basic HTML structure and link to styles.css
                full_html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <link rel="stylesheet" href="/styles.css">
</head>
<body>
    <div class="container">
        {html_content}
    </div>
</body>
</html>
"""

                with open(output_filepath, "w", encoding="utf-8") as f:
                    f.write(full_html)
                print(f"Converted {input_filepath} to {output_filepath}")

if __name__ == "__main__":
    input_root_dir = "."
    output_docs_dir = "docs"
    convert_md_to_html(input_root_dir, output_docs_dir)


