import os
import json
import requests

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TAG = os.getenv("TAG")

IS_RELEASE = "+" not in TAG

CHAT_ID = "@FlClash"
API_URL = f"http://localhost:8081/bot{TELEGRAM_BOT_TOKEN}/sendMediaGroup"

DIST_DIR = os.path.join(os.getcwd(), "dist")
release = os.path.join(os.getcwd(), "release.md")

text = ""

media = []
files = {}

i = 1
for file in os.listdir(DIST_DIR):
    file_path = os.path.join(DIST_DIR, file)
    if os.path.isfile(file_path):
        file_key = f"file{i}"
        media.append({
            "type": "document",
            "media": f"attach://{file_key}"
        })
        files[file_key] = open(file_path, 'rb')
        i += 1

if TAG:
    text += f"\n**{TAG}**\n"

if IS_RELEASE:
    text += f"\nhttps://github.com/chen08209/FlClash/releases/tag/{TAG}\n"


if os.path.exists(release):
    text += "\n"
    with open(release, 'r') as f:
        text += f.read()
    text += "\n"

if media:
    media[-1]["caption"] = text
    media[-1]["parse_mode"] = "Markdown"

response = requests.post(
    API_URL,
    data={
        "chat_id": CHAT_ID,
        "media": json.dumps(media)
    },
    files=files
)

print("Response JSON:", response.json())