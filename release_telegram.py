import html
import json
import os
import sys

import requests

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TAG = os.getenv("TAG")
RUN_ID = os.getenv("RUN_ID")

IS_STABLE = "-" not in TAG

CHAT_ID = "@FlClash"
API_URL = f"http://localhost:8081/bot{TELEGRAM_BOT_TOKEN}/sendMediaGroup"

DIST_DIR = os.path.join(os.getcwd(), "dist")
# Rendered by `tool/changelog.dart render telegram`: plain bullets, already
# truncated to fit the caption limit. release.md carries the download table and
# would blow past that limit.
release = os.path.join(os.getcwd(), "telegram.md")

text = ""

media = []
files = {}

i = 1

releaseKeywords = [
    "windows-amd64-setup",
    "android-arm64",
    "macos-arm64",
    "macos-amd64"
]

for file in os.listdir(DIST_DIR):
    file_path = os.path.join(DIST_DIR, file)
    if os.path.isfile(file_path):
        file_lower = file.lower()
        if any(kw in file_lower for kw in releaseKeywords):
            file_key = f"file{i}"
            media.append({
                "type": "document",
                "media": f"attach://{file_key}"
            })
            files[file_key] = open(file_path, 'rb')
            i += 1

if TAG:
    text += f"\n<b>{html.escape(TAG)}</b>\n"

if IS_STABLE:
    text += f"\nhttps://github.com/chen08209/FlClash/releases/tag/{TAG}\n"
else:
    text += f"\nhttps://github.com/chen08209/FlClash/actions/runs/{RUN_ID}\n"

if os.path.exists(release):
    text += "\n"
    with open(release, 'r') as f:
        text += f.read()
    text += "\n"

if media:
    media[-1]["caption"] = text
    # HTML, not Markdown: the caption carries changelog entries written by
    # whoever wrote the commit, and HTML is the one Telegram parse mode with a
    # defined escape for them. `tool/changelog.dart render telegram` emits the
    # matching markup.
    media[-1]["parse_mode"] = "HTML"

try:
    response = requests.post(
        API_URL,
        data={
            "chat_id": CHAT_ID,
            "media": json.dumps(media)
        },
        files=files,
        timeout=300
    )
finally:
    for handle in files.values():
        handle.close()

# A rejected caption comes back as a 400 with a description, not an exception.
# Without this the release job stays green while the announcement never posted.
try:
    payload = response.json()
except ValueError:
    payload = None

print("Response JSON:", payload if payload is not None else response.text)

if not response.ok or not (payload or {}).get("ok"):
    description = (payload or {}).get("description", response.text)
    print(f"Telegram rejected the release post: {description}", file=sys.stderr)
    sys.exit(1)
