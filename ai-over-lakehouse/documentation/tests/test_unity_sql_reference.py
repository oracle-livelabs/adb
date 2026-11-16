"""Offline contract checks, not live Oracle PL/SQL or UI execution proof."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/02-unity-sql-reference.sql"
LAB = ROOT / "connect-sources/connect-sources.md"


class UnitySqlReferenceTests(unittest.TestCase):
    def setUp(self):
        self.sql = SCRIPT.read_text(encoding="utf-8")
        text = LAB.read_text(encoding="utf-8")
        self.reference = text.split("### SQL reference (not part of the lab)", 1)[1].split("## Task 3:", 1)[0]
        self.flat = " ".join(re.sub(r"(?m)^> ?", "", self.reference).split())

    def test_reference_is_optional_and_copy_block_matches_download(self):
        self.assertIn("**For reference only:**", self.reference)
        self.assertIn("not a required lab step", self.flat)
        self.assertIn("UI workflow above remains the main path", self.flat)
        self.assertIn("skip this reference", self.flat)
        self.assertIn("../scripts/02-unity-sql-reference.sql", self.reference)
        blocks = re.findall(r"<copy>\n(.*?)\n</copy>", self.reference, re.S)
        self.assertEqual(len(blocks), 1)
        self.assertTrue(blocks[0].rstrip().endswith("END;\n/"))
        self.assertIn("DBMS_CATALOG.MOUNT_ICEBERG(", blocks[0])
        self.assertEqual(blocks[0], self.sql.rstrip())

    def test_reference_reuses_credentials_without_secret_inputs_or_mutation(self):
        self.assertIn("No credential values or placeholders are needed", self.flat)
        for forbidden in ("CLIENT_ID", "CLIENT_SECRET", "CREATE_CREDENTIAL",
                          "CREATE_BEARER_TOKEN_CREDENTIAL", "DROP_CREDENTIAL",
                          "UPDATE_CREDENTIAL", "REFRESH_BEARER_TOKEN_CREDENTIAL"):
            with self.subTest(fragment=forbidden):
                self.assertNotIn(forbidden, self.sql.upper())
        self.assertIn("credential_name IN ('ADLS_PEAKGEAR_DATA', 'DBX_PEAKGEAR_OAUTH')", self.sql)

    def test_participant_identity_and_both_credentials_are_checked_before_mount(self):
        mount = self.sql.index("DBMS_CATALOG.MOUNT_ICEBERG(")
        for code in (-20011, -20014):
            with self.subTest(error=code):
                self.assertLess(self.sql.index(f"RAISE_APPLICATION_ERROR({code}"), mount)
        self.assertIn("USER <> 'PEAKGEAR_USER'", self.sql)
        self.assertIn("SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'PEAKGEAR_USER'", self.sql)
        self.assertLess(self.sql.index("FROM user_credentials"), mount)
        self.assertRegex(self.sql, r"IF l_credential_count <> 2 THEN\s+RAISE_APPLICATION_ERROR")
        self.assertNotRegex(self.sql, r"(?is)WHEN\s+OTHERS\s+THEN\s+NULL")

    def test_reference_uses_the_supplied_scoped_connection_calls(self):
        for fragment in (
            "DBMS_CATALOG.MOUNT_ICEBERG(",
            "catalog_credential      => 'DBX_PEAKGEAR_OAUTH'",
            "data_storage_credential => 'ADLS_PEAKGEAR_DATA'",
            "catalog_type            => 'ICEBERG_UNITY'",
            "unity-catalog/iceberg-rest/v1/catalogs/peakgear",
        ):
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, self.sql)
        self.assertNotRegex(self.sql, r"(?i)\b(?:UNMOUNT|CREATE_USER|CREATE_DATABASE_LINK)\b")
        self.assertTrue(self.sql.rstrip().endswith("END;\n/"))

    def test_existing_mount_is_preserved_on_retry(self):
        self.assertLess(self.sql.index("FROM user_mounted_catalogs"), self.sql.index("DBMS_CATALOG.MOUNT_ICEBERG("))
        self.assertRegex(self.sql, r"IF l_catalog_count = 0 THEN\s+DBMS_CATALOG\.MOUNT_ICEBERG\(")
        self.assertIn("DBX_UNITY_PEAKGEAR already exists", self.sql)
        self.assertEqual(self.sql.count("DBMS_CATALOG.MOUNT_ICEBERG("), 1)
        legacy = (ROOT / "scripts/01-connect-event-sources.sql").read_text(encoding="utf-8")
        self.assertIn(self.sql, legacy)

    def test_mount_errors_and_retry_are_explained(self):
        for phrase in (
            "wait for the worksheet's completion message",
            "Task 1",
            "sample queries in Task 3 confirm read access",
            "After a timeout, inspect **Data > Database**",
            "Do not drop or unmount objects to force a retry",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, self.flat)


if __name__ == "__main__":
    unittest.main()
