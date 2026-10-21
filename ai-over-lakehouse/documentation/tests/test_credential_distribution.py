"""Offline safeguards only; these do not prove backend fields or key rotation."""

from pathlib import Path
import re
import unittest
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[2]
PRIVATE_FIELDS = (
    "Azure Storage Password",
    "Databricks Client ID",
    "Databricks Client Secret",
)
TEXT_SUFFIXES = {".md", ".sql", ".py", ".ps1", ".command", ".json", ".html"}
SECRET_PATTERNS = (
    # Azure storage account key (64 bytes, encoded as 88 base64 characters).
    re.compile(r"(?<![A-Za-z0-9+/])[A-Za-z0-9+/]{86}==(?=$|[^A-Za-z0-9+/=])"),
    re.compile(r"\b(?:dose|dapi)[A-Za-z0-9]{20,}\b"),
    re.compile(r"\bsig=[A-Za-z0-9%+/=]{20,}", re.I),
    re.compile(r"\|\s*Client ID\s*\|\s*`?[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}`?\s*\|", re.I),
)


class CredentialDistributionTests(unittest.TestCase):
    def test_public_references_use_private_reservation_fields(self):
        for relative in (
            "connect-sources/connect-sources.md",
            "assets/event-lab-values.md",
            "starter-kit/event-lab-values.md",
        ):
            text = " ".join((ROOT / relative).read_text(encoding="utf-8").split())
            with self.subTest(file=relative):
                self.assertIn("View Login Info", text)
                for field in PRIVATE_FIELDS:
                    self.assertIn(field, text)
                self.assertRegex(text, r"missing or empty.*?stop and ask the instructor")
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
        sql = (ROOT / "scripts/01-connect-event-sources.sql").read_text(encoding="utf-8")
        for name in ("AZURE_STORAGE_PASSWORD", "DATABRICKS_CLIENT_ID", "DATABRICKS_CLIENT_SECRET"):
            placeholder = "<" + name + "_FROM_VIEW_LOGIN_INFO>"
            self.assertEqual(sql.count(placeholder), 1, "Replace only a declaration, never a guard literal")
        for variable in ("l_storage_password", "l_client_id", "l_client_secret"):
            self.assertIn(f"{variable} IS NULL OR SUBSTR({variable}, 1, 1) = '<'", sql)
        self.assertLess(sql.index("RAISE_APPLICATION_ERROR(-20001"), sql.index("DBMS_CLOUD.CREATE_CREDENTIAL("))
        self.assertLess(sql.index("RAISE_APPLICATION_ERROR(-20002"), sql.index("DBMS_SHARE.CREATE_BEARER_TOKEN_CREDENTIAL("))

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
