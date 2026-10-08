"""Offline package checks; these do not prove live Oracle or browser behavior."""

from html import unescape
import json
from pathlib import Path
import re
import unittest
from urllib.parse import unquote, urlsplit
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "workshops" / "sandbox" / "manifest.json"


def learner_pages():
    manifest = json.loads(MANIFEST.read_text())
    return [
        (entry, (MANIFEST.parent / entry["filename"]).resolve())
        for entry in manifest["tutorials"]
        if not urlsplit(entry["filename"]).scheme
    ]


def learner_labs():
    return [
        (entry, path)
        for entry, path in learner_pages()
        if entry["title"].startswith("Lab ")
    ]


class WorkshopPackageTests(unittest.TestCase):
    def test_five_participant_labs_are_numbered_from_one(self):
        labs = learner_labs()
        self.assertEqual(len(labs), 5)
        for number, (entry, path) in enumerate(labs, 1):
            with self.subTest(lab=number):
                self.assertTrue(entry["title"].startswith(f"Lab {number}: "))
                self.assertNotIn("ADMIN", entry["title"])
                self.assertEqual(unescape(path.read_text().splitlines()[0]), "# " + entry["title"])
        self.assertTrue((MANIFEST.parent / "index.html").is_file())

    def test_task_numbers_are_contiguous_in_each_lab(self):
        for _, path in learner_labs():
            tasks = [int(number) for number in re.findall(r"^## Task (\d+):", path.read_text(), re.M)]
            with self.subTest(file=path.name):
                self.assertTrue(tasks)
                self.assertEqual(tasks, list(range(1, len(tasks) + 1)))

    def test_learner_pages_do_not_manage_data_cache(self):
        for _, path in learner_pages():
            text = unescape(path.read_text())
            with self.subTest(file=path.name):
                self.assertNotRegex(text, re.compile(r"\b(?:DBMS_EXT_TABLE_CACHE|USER_EXTERNAL_TAB_CACHES|Lake\s+Cache)\b", re.I))

    def test_final_lab_combines_model_gap_build_and_answer(self):
        entry, path = learner_labs()[-1]
        text = path.read_text()
        self.assertEqual(entry["title"], "Lab 5: Create Analytic Views with Codex")
        headings = re.findall(r"^## Task \d+: (.+)$", text, re.M)
        self.assertEqual(headings, [
            "Ask the harder business question",
            "Review the governed-model requirements",
            "Ask Codex to build the model",
            "Ask the final business question",
        ])
        self.assertFalse((ROOT / "governed-question" / "governed-question.md").exists())

    def test_local_table_contract_is_consistent_across_labs_and_runtime(self):
        sources = (ROOT / "connect-sources" / "connect-sources.md").read_text()
        enrichment = (ROOT / "ai-enrichment" / "ai-enrichment.md").read_text()
        runtime = (ROOT / "starter-kit" / "livelab_mcp.py").read_text()
        boundary = (ROOT / "connect-codex" / "connect-codex.md").read_text()
        names = (
            "lab_products_raw_t",
            "lab_digital_intent_raw_t",
            "lab_returns_raw_t",
        )
        for name in names:
            with self.subTest(table=name):
                self.assertIn(f"CREATE TABLE {name} AS", sources)
                self.assertIn(name.upper(), enrichment)
                self.assertIn(name.upper(), runtime)
        self.assertNotRegex(runtime, r"LAB_(?:PRODUCTS|DIGITAL_INTENT|RETURNS)_RAW_V")
        self.assertIn("ALTER TABLE", enrichment)
        self.assertIn("Mandatory Analytic View gate", boundary)
        self.assertIn("do not provide category rankings, figures", boundary)

    def test_every_learner_code_block_has_copy_markup(self):
        fence = re.compile(r"^(?P<fence>~{3,}|`{3,})[^\n]*\n(?P<body>.*?)^(?P=fence)[ \t]*$", re.M | re.S)
        for _, path in learner_pages():
            text = re.sub(r"<!--.*?-->", "", path.read_text(), flags=re.S)
            blocks = list(fence.finditer(text))
            markers = re.findall(r"^(?:~{3,}|`{3,})[^\n]*$", text, re.M)
            with self.subTest(file=path.name):
                self.assertEqual(len(markers), 2 * len(blocks), "Unbalanced code fences")
                for block in blocks:
                    body = block["body"].strip()
                    self.assertTrue(body.startswith("<copy>"))
                    self.assertTrue(body.endswith("</copy>"))
                    self.assertEqual(body.count("<copy>"), 1)
                    self.assertEqual(body.count("</copy>"), 1)

    def test_local_links_resolve_and_images_have_alt_text(self):
        link = re.compile(r"(!?)\[([^\]]*)\]\(([^\s)]+)\)")
        for _, path in learner_pages():
            text = re.sub(r"<!--.*?-->", "", path.read_text(), flags=re.S)
            for image, label, destination in link.findall(text):
                with self.subTest(file=path.name, destination=destination):
                    if image:
                        self.assertTrue(label.strip(), "Image must have alternate text")
                    parsed = urlsplit(destination)
                    if not parsed.scheme and parsed.path:
                        self.assertTrue((path.parent / unquote(parsed.path)).is_file())

    def test_filenames_are_lowercase(self):
        for path in ROOT.rglob("*"):
            if "__pycache__" in path.parts or path.name == ".DS_Store":
                continue
            with self.subTest(path=str(path.relative_to(ROOT))):
                self.assertEqual(path.name, path.name.lower())

    def test_starter_kit_zip_matches_all_source_files(self):
        source = ROOT / "starter-kit"
        expected = {
            str(path.relative_to(ROOT))
            for path in source.rglob("*")
            if path.is_file() and "__pycache__" not in path.parts and path.name != ".DS_Store"
        }
        with ZipFile(ROOT / "downloads" / "peakgear-livelab-starter-kit.zip") as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual({name for name in archive.namelist() if not name.endswith("/")}, expected)
            for name in expected:
                with self.subTest(member=name):
                    self.assertEqual(archive.read(name), (ROOT / name).read_bytes())


if __name__ == "__main__":
    unittest.main()
