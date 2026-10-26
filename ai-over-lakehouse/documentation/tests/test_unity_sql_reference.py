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
        self.assertEqual(len(blocks), 2)
        self.assertTrue(blocks[0].rstrip().endswith("END;\n/"))
        self.assertTrue(blocks[1].startswith("BEGIN\n"))
        self.assertNotIn("DBMS_CATALOG.MOUNT_ICEBERG(", blocks[0])
        self.assertEqual("\n\n".join(blocks), self.sql.rstrip())

    def test_credentials_are_copied_from_the_reservation_not_published(self):
        self.assertIn("**View Login Info → Environment Details**", self.reference)
        self.assertIn("replace only the two placeholders", self.flat)
        for name in ("DATABRICKS_CLIENT_ID", "DATABRICKS_CLIENT_SECRET"):
            self.assertEqual(self.sql.count("<" + name + "_FROM_VIEW_LOGIN_INFO>"), 1)
        for variable in ("l_client_id", "l_client_secret"):
            self.assertIn(f"{variable} IS NULL OR SUBSTR({variable}, 1, 1) = '<'", self.sql)
        self.assertIn("client_id       => l_client_id", self.sql)
        self.assertIn("client_secret   => l_client_secret", self.sql)

    def test_all_preconditions_are_checked_before_credential_replacement(self):
        drop = self.sql.index("DBMS_CLOUD.DROP_CREDENTIAL(")
        for code in (-20011, -20012, -20013, -20014):
            with self.subTest(error=code):
                self.assertLess(self.sql.index(f"RAISE_APPLICATION_ERROR({code}"), drop)
        self.assertIn("USER <> 'PEAKGEAR_USER'", self.sql)
        self.assertIn("SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'PEAKGEAR_USER'", self.sql)
        self.assertLess(self.sql.index("FROM user_mounted_catalogs"), drop)
        self.assertIn("WHERE credential_name = 'ADLS_PEAKGEAR_DATA'", self.sql)
        self.assertRegex(self.sql, r"IF l_exists > 0 THEN\s+DBMS_CLOUD\.DROP_CREDENTIAL\('DBX_PEAKGEAR_OAUTH'\);\s+END IF;")
        self.assertNotRegex(self.sql, r"(?is)WHEN\s+OTHERS\s+THEN\s+NULL")

    def test_reference_uses_the_supplied_scoped_connection_calls(self):
        for fragment in (
            "DBMS_SHARE.CREATE_BEARER_TOKEN_CREDENTIAL(",
            "DBMS_CATALOG.MOUNT_ICEBERG(",
            "token_scope     => 'all-apis'",
            "data_storage_credential => 'ADLS_PEAKGEAR_DATA'",
            "catalog_type            => 'ICEBERG_UNITY'",
            "unity-catalog/iceberg-rest/v1/catalogs/peakgear",
        ):
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, self.sql)
        self.assertNotRegex(self.sql, r"(?i)\b(?:UNMOUNT|CREATE_USER|CREATE_DATABASE_LINK)\b")
        self.assertTrue(self.sql.rstrip().endswith("END;\n/"))

    def test_partial_success_errors_and_retry_are_explained(self):
        for phrase in (
            "Run **each block separately, in order**",
            "wait for the worksheet's completion message before starting the next block",
            "Task 1",
            "sample queries in Task 3 confirm read access",
            "an error does not guarantee that nothing was created",
            "After a timeout, inspect **Credentials** and **Catalog**",
            "do not drop or unmount objects to force a retry",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, self.flat)


if __name__ == "__main__":
    unittest.main()
