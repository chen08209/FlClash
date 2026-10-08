import os
import sys
from pathlib import Path

urls = [
    line.strip()
    for line in os.environ.get("BRANDING_SUB_URLS", "").splitlines()
    if line.strip()
]
code = os.environ.get("BRANDING_UNLOCK_CODE", "").strip()


def unsafe(value):
    return any(ch in value for ch in ("'", "\\", "\r", "\n"))


if any(unsafe(u) for u in urls) or unsafe(code):
    print("::error::Branding value contains a quote or backslash.")
    sys.exit(1)

if not urls:
    print("::warning::BRANDING_SUB_URLS is empty, no built-in profiles.")
if not code:
    print("::warning::BRANDING_UNLOCK_CODE is empty, unlock is disabled.")

lines = ["const brandingSecretUrls = <String>["]
lines += [f"  r'{u}'," for u in urls]
lines += ["];", f"const brandingSecretCode = r'{code}';", ""]

target = Path(__file__).resolve().parents[2] / "lib" / "branding_secret.dart"
target.write_text("\n".join(lines), encoding="utf-8")
print(f"Wrote {len(urls)} url(s) to lib/branding_secret.dart")
