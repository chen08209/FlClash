import os
import json
import requests

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TAG = os.getenv("TAG")

IS_STABLE = "-" not in TAG

CHAT_ID = "@FlClash"
API_URL = f"http://localhost:8081/bot{TELEGRAM_BOT_TOKEN}/sendMediaGroup"

DIST_DIR = os.path.join(os.getcwd(), "dist")
release = os.path.join(os.getcwd(), "release.md")

text = ""
if TAG:
    text += f"\n**{TAG}**\n"
if IS_STABLE:
    text += f"\nhttps://github.com/chen08209/FlClash/releases/tag/{TAG}\n"
if os.path.exists(release):
    with open(release, 'r') as f:
        release_content = f.read().strip()
    text += f"\n{release_content}\n"


file_paths = []
for file in os.listdir(DIST_DIR):
    file_path = os.path.join(DIST_DIR, file)
    if os.path.isfile(file_path):
        file_paths.append(file_path)

batch_size = 10
total_batches = (len(file_paths) + batch_size - 1) // batch_size

for batch_num in range(total_batches):
    start_idx = batch_num * batch_size
    end_idx = start_idx + batch_size
    current_batch = file_paths[start_idx:end_idx]
    is_first_batch = batch_num == 0

    media = []
    files_dict = {}
    file_handles = []

    for idx, file_path in enumerate(current_batch, start=1):
        file_key = f"file{idx}"
        media.append({"type": "document", "media": f"attach://{file_key}"})
        file_handle = open(file_path, 'rb')
        files_dict[file_key] = file_handle
        file_handles.append(file_handle)

    if is_first_batch and media:
        media[-1]["caption"] = text.strip()
        media[-1]["parse_mode"] = "Markdown"

    if media:
        response = requests.post(
            API_URL,
            data={
                "chat_id": CHAT_ID,
                "media": json.dumps(media)
            },
            files=files_dict
        )
        print(f"Batch {batch_num + 1}/{total_batches} response:", response.json())

    for fh in file_handles:
        fh.close()