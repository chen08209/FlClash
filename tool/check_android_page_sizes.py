#!/usr/bin/env python3
"""Check 64-bit Android libraries' ELF and APK ZIP alignment using Python 3."""

import argparse
from pathlib import Path
import struct
import sys
import zipfile


PAGE_SIZE = 16 * 1024
MACHINES = {"arm64-v8a": 183, "x86_64": 62}
PROGRAM_HEADER = struct.Struct("<IIQQQQQQ")


def check_elf(data, abi):
    if len(data) < 64 or data[:7] != b"\x7fELF\x02\x01\x01":
        raise ValueError("expected a little-endian ELF64 library")
    if struct.unpack_from("<H", data, 18)[0] != MACHINES[abi]:
        raise ValueError(f"ELF machine does not match {abi}")
    offset = struct.unpack_from("<Q", data, 32)[0]
    entry_size, count = struct.unpack_from("<HH", data, 54)
    if entry_size != PROGRAM_HEADER.size or not count:
        raise ValueError("invalid ELF program header table")
    if offset < 64 or offset + entry_size * count > len(data):
        raise ValueError("truncated ELF program header table")

    loads = 0
    for index in range(count):
        kind, _, file_offset, address, _, file_size, memory_size, alignment = (
            PROGRAM_HEADER.unpack_from(data, offset + index * entry_size)
        )
        if kind == 1:
            loads += 1
            if alignment < PAGE_SIZE or alignment & (alignment - 1):
                raise ValueError(f"LOAD[{index}] alignment is {alignment}, expected >= {PAGE_SIZE}")
            if (address - file_offset) % PAGE_SIZE:
                raise ValueError(f"LOAD[{index}] offset and address are not 16 KB congruent")
            if file_size > memory_size or file_offset + file_size > len(data):
                raise ValueError(f"LOAD[{index}] has invalid bounds")
    if not loads:
        raise ValueError("ELF has no LOAD segments")


def check_zip_offset(raw, entry):
    raw.seek(entry.header_offset)
    header = raw.read(30)
    if len(header) != 30 or header[:4] != b"PK\x03\x04":
        raise ValueError("invalid ZIP local header")
    name_size, extra_size = struct.unpack_from("<HH", header, 26)
    offset = entry.header_offset + 30 + name_size + extra_size
    if offset % PAGE_SIZE:
        raise ValueError(f"uncompressed library ZIP offset {offset} is not 16 KB aligned")


def check_apk(path):
    failures = []
    checked = 0
    skipped = 0
    with zipfile.ZipFile(path) as apk, path.open("rb") as raw:
        libraries = [
            entry for entry in apk.infolist()
            if entry.filename.startswith("lib/") and entry.filename.endswith(".so")
        ]
        if not libraries:
            raise ValueError("APK contains no native libraries")
        for entry in libraries:
            parts = entry.filename.split("/")
            if len(parts) != 3:
                failures.append(f"{entry.filename}: unexpected native library path")
                continue
            abi = parts[1]
            if abi in ("armeabi-v7a", "x86"):
                skipped += 1
                continue
            if abi not in MACHINES:
                failures.append(f"{entry.filename}: unsupported ABI {abi}")
                continue
            try:
                check_elf(apk.read(entry), abi)
                if entry.compress_type == zipfile.ZIP_STORED:
                    check_zip_offset(raw, entry)
                checked += 1
            except (ValueError, zipfile.BadZipFile) as error:
                failures.append(f"{entry.filename}: {error}")
    return checked, skipped, failures


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="+", type=Path, help="APK files or directories to scan")
    args = parser.parse_args(argv)
    apks = set()
    for path in args.paths:
        found = sorted(path.rglob("*.apk")) if path.is_dir() else [path]
        if not found or any(not item.is_file() or item.suffix != ".apk" for item in found):
            parser.error(f"no APK files at {path}")
        apks.update(found)
    failed = False
    for path in sorted(apks):
        try:
            checked, skipped, failures = check_apk(path)
        except (OSError, ValueError, zipfile.BadZipFile, RuntimeError) as error:
            checked, skipped, failures = 0, 0, [str(error)]
        status = "FAIL" if failures else "PASS" if checked else "SKIP"
        print(f"{status} {path}: {checked} compatible 64-bit libraries, {skipped} 32-bit libraries skipped")
        for failure in failures:
            print(f"  {failure}", file=sys.stderr)
        failed |= bool(failures)
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
