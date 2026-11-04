"""Offline safeguards only; these do not prove backend fields or key rotation."""

from pathlib import Path
import re
import unittest
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[2]
SOURCE_CREDENTIALS = ("DBX_PEAKGEAR_OAUTH", "ADLS_PEAKGEAR_DATA")
TEXT_SUFFIXES = {".md", ".sql", ".py", ".ps1", ".command", ".json", ".html"}
SECRET_PATTERNS = (
    # Azure storage account key (64 bytes, encoded as 88 base64 characters).
    re.compile(r"(?<![A-Za-z0-9+/])[A-Za-z0-9+/]{86}==(?=$|[^A-Za-z0-9+/=])"),
    re.compile(r"\b(?:dose|dapi)[A-Za-z0-9]{20,}\b"),
    re.compile(r"\bsig=[A-Za-z0-9%+/=]{20,}", re.I),
    re.compile(r"\|\s*Client ID\s*\|\s*`?[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}`?\s*\|", re.I),
)


class CredentialDistributionTests(unittest.TestCase):
    def test_public_references_use_provisioned_source_credentials(self):
        for relative in (
            "connect-sources/connect-sources.md",
            "assets/event-lab-values.md",
            "starter-kit/event-lab-values.md",
        ):
            text = " ".join((ROOT / relative).read_text(encoding="utf-8").split())
            text = text.replace("&#95;", "_")
            with self.subTest(file=relative):
                for credential in SOURCE_CREDENTIALS:
                    self.assertIn(credential, text)
                self.assertIn("provision", text)
                self.assertRegex(text, r"missing.*?stop and ask the instructor")
                self.assertNotRegex(text, r"(?i)copy.{0,40}(?:Azure Storage Password|Databricks Client ID|Databricks Client Secret)")
        self.assertEqual(
            (ROOT / "assets/event-lab-values.md").read_bytes(),
            (ROOT / "starter-kit/event-lab-values.md").read_bytes(),
        )

    def test_sql_templates_have_no_literal_credential_arguments(self):
        for path in (ROOT / "scripts").glob("*.sql"):
            with self.subTest(file=path.name):
                self.assertNotRegex(
                    path.read_text(encoding="utf-8"),
                    r"(?i)\b(?:password|client_id|client_secret)\s*=>\s*'",
                )

    def test_participant_source_setup_never_changes_credentials(self):
        for relative in (
            "connect-sources/connect-sources.md",
            "scripts/01-connect-event-sources.sql",
            "scripts/02-unity-sql-reference.sql",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            with self.subTest(file=relative):
                self.assertNotRegex(
                    text,
                    r"(?i)\bDBMS_(?:CLOUD|SHARE)\.(?:CREATE|DROP|UPDATE|REFRESH)(?:_BEARER_TOKEN)?_CREDENTIAL\s*\(",
                )
                self.assertNotRegex(text, r"<(?:AZURE_STORAGE_PASSWORD|DATABRICKS_CLIENT_ID|DATABRICKS_CLIENT_SECRET)_FROM_VIEW_LOGIN_INFO>")

    def test_oauth_credential_screenshot_is_not_distributed(self):
        removed = "create-iceberg-catalog-credential.png"
        self.assertFalse((ROOT / "connect-sources/images" / removed).exists())
        text = (ROOT / "connect-sources/connect-sources.md").read_text(encoding="utf-8")
        self.assertNotIn(removed, text)

    def test_source_and_zip_have_no_known_secret_formats(self):
        candidates = [
            (str(path.relative_to(ROOT)), path.read_bytes())
            for path in ROOT.rglob("*")
            if path.is_file() and path.suffix in TEXT_SUFFIXES
            and "__pycache__" not in path.parts
        ]
        with ZipFile(ROOT / "downloads/peakgear-livelab-starter-kit.zip") as archive:
            candidates.extend(
                ("ZIP:" + name, archive.read(name))
                for name in archive.namelist()
                if Path(name).suffix in TEXT_SUFFIXES
            )
        for name, data in candidates:
            text = data.decode("utf-8")
            with self.subTest(file=name):
                # Do not print the matched value in a test failure.
                self.assertFalse(any(pattern.search(text) for pattern in SECRET_PATTERNS),
                                 "Possible embedded credential; inspect privately")


if __name__ == "__main__":
    unittest.main()
