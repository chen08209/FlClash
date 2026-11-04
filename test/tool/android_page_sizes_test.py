import contextlib
import importlib.util
import io
from pathlib import Path
import struct
import tempfile
import unittest
import zipfile


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "page_sizes", ROOT / "tool/check_android_page_sizes.py"
)
page_sizes = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(page_sizes)


def elf(alignment=16384, machine=183, relro_end=16384, extra_load=None):
    headers = [
        (1, 5, 0, 0, 0, 256, 16384, alignment),
        (0x6474E552, 4, 0, 0x3F00, 0, 0, relro_end - 0x3F00, 1),
    ]
    if extra_load is not None:
        headers.append(extra_load)
    data = bytearray(256)
    data[:7] = b"\x7fELF\x02\x01\x01"
    struct.pack_into("<HHI", data, 16, 3, machine, 1)
    struct.pack_into("<Q", data, 32, 64)
    struct.pack_into("<HHH", data, 52, 64, 56, len(headers))
    for index, header in enumerate(headers):
        struct.pack_into("<IIQQQQQQ", data, 64 + 56 * index, *header)
    return data


class AndroidPageSizesTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.apk = self.directory / "app.apk"

    def write_apk(self, data, *, abi="arm64-v8a", compressed=True, aligned=False):
        name = f"lib/{abi}/libtest.so"
        entry = zipfile.ZipInfo(name)
        entry.compress_type = zipfile.ZIP_DEFLATED if compressed else zipfile.ZIP_STORED
        if aligned:
            padding = -(30 + len(name)) % 16384
            entry.extra = struct.pack("<HH", 0xD935, padding - 4) + bytes(padding - 4)
        with zipfile.ZipFile(self.apk, "w") as apk:
            apk.writestr(entry, data)
            entry.extra = b""

    def test_compressed_libraries_still_require_elf_alignment(self):
        for alignment in (4096, 8192, 16384, 65536):
            with self.subTest(alignment=alignment):
                self.write_apk(elf(alignment))
                checked, _, failures = page_sizes.check_apk(self.apk)
                self.assertEqual(bool(failures), alignment < 16384)
                self.assertEqual(checked, int(alignment >= 16384))

    def test_every_load_segment_is_checked(self):
        self.write_apk(elf(extra_load=(1, 6, 0, 0, 0, 256, 16384, 4096)))
        self.assertIn("LOAD[2]", page_sizes.check_apk(self.apk)[2][0])

    def test_load_offset_must_match_virtual_address_modulo_page_size(self):
        self.write_apk(elf(extra_load=(1, 6, 0, 4096, 0, 256, 16384, 16384)))
        self.assertIn("congruent", page_sizes.check_apk(self.apk)[2][0])

    def test_unaligned_relro_end_does_not_imply_incompatible_load_alignment(self):
        self.write_apk(elf(relro_end=20480))
        self.assertEqual(page_sizes.check_apk(self.apk), (1, 0, []))

    def test_uncompressed_library_must_also_be_zip_aligned(self):
        self.write_apk(elf(), compressed=False)
        self.assertIn("ZIP offset", page_sizes.check_apk(self.apk)[2][0])

    def test_zip_alignment_uses_local_header_not_central_directory(self):
        self.write_apk(elf(), compressed=False, aligned=True)
        self.assertEqual(page_sizes.check_apk(self.apk), (1, 0, []))

    def test_x86_64_is_checked_too(self):
        self.write_apk(elf(machine=62), abi="x86_64")
        self.assertEqual(page_sizes.check_apk(self.apk), (1, 0, []))
        self.write_apk(elf(machine=183), abi="x86_64")
        self.assertIn("machine", page_sizes.check_apk(self.apk)[2][0])

    def test_32_bit_only_apk_is_explicitly_skipped(self):
        self.write_apk(b"32-bit fixture", abi="armeabi-v7a")
        self.assertEqual(page_sizes.check_apk(self.apk), (0, 1, []))

    def test_malformed_elf_is_rejected(self):
        for data in (b"not an ELF", elf()[:100]):
            with self.subTest(size=len(data)):
                self.write_apk(data)
                self.assertTrue(page_sizes.check_apk(self.apk)[2])

    def test_no_native_libraries_is_not_a_success(self):
        with zipfile.ZipFile(self.apk, "w") as apk:
            apk.writestr("AndroidManifest.xml", b"manifest")
        with self.assertRaisesRegex(ValueError, "no native libraries"):
            page_sizes.check_apk(self.apk)

    def test_command_fails_on_bad_apk_even_when_another_passes(self):
        self.write_apk(elf())
        (self.directory / "broken.apk").write_bytes(b"not a zip")
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(page_sizes.main([str(self.directory)]), 1)

    def test_empty_directory_is_not_a_success(self):
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
            page_sizes.main([str(self.directory)])
        self.assertEqual(error.exception.code, 2)


if __name__ == "__main__":
    unittest.main()
