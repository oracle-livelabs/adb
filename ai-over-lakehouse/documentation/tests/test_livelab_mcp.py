"""Offline regression tests: no MCP process or database connection is started.

Run with: python3 -m unittest discover -s documentation/tests -v
These mocks verify helper control flow and returned labels, not Oracle execution.
"""

import importlib.util
import json
from pathlib import Path
import sys
import types
import unittest
from unittest.mock import Mock, patch


class FakeMCP:
    _tool_manager = types.SimpleNamespace(get_tool=lambda name: None)

    def tool(self):
        return lambda function: function


def load_runtime():
    stubs = {}
    for name in (
        "mcp", "mcp.server", "mcp.server.fastmcp", "mcp_server",
        "mcp_server.server", "mcp_server.tools",
        "mcp_server.tools._adp_connect", "mcp_server.tools._helpers",
    ):
        stubs[name] = types.ModuleType(name)
    stubs["mcp.server.fastmcp"].Context = object
    stubs["mcp_server.server"].mcp = FakeMCP()
    stubs["mcp_server.server"].main = lambda: None
    stubs["mcp_server.tools._adp_connect"].get_adp = lambda ctx: None
    stubs["mcp_server.tools._helpers"].bound_rows = lambda value, **kwargs: value
    stubs["mcp_server.tools._helpers"].err = lambda value: json.dumps({"error": str(value)})
    path = Path(__file__).resolve().parents[2] / "starter-kit" / "livelab_mcp.py"
    spec = importlib.util.spec_from_file_location("peakgear_runtime_under_test", path)
    module = importlib.util.module_from_spec(spec)
    with patch.dict(sys.modules, stubs):
        spec.loader.exec_module(module)
    return module


runtime = load_runtime()


def contract_rows():
    return [
        {"OBJECT_NAME": name, "ANNOTATION_NAME": annotation, "ANNOTATION_VALUE": "reviewed"}
        for name in ("LAB_DIGITAL_INTENT_RAW_V", "LAB_PRODUCTS_RAW_V")
        for annotation in ("DESCRIPTION", "TAGS")
    ]


class InterestRankingTests(unittest.TestCase):
    def setUp(self):
        self.client = types.SimpleNamespace(Misc=Mock(), rest=Mock())
        self.client.Misc.run_query.side_effect = [contract_rows(), []]
        self.client.rest.get_prefix.return_value = "/test"

    def run_helper(self, rows=None):
        if rows is not None:
            self.client.rest.post.return_value = json.dumps({
                "items": [{"resultSet": {"items": rows}}]
            })
        with patch.object(runtime, "get_adp", return_value=self.client):
            return json.loads(runtime.adp_get_top_digital_interest())

    def test_missing_contract_stops_without_ranking(self):
        self.client.Misc.run_query.side_effect = [[]]
        result = self.run_helper()
        self.assertEqual(result["status"], "needs_data_studio_contract")
        self.assertEqual(len(result["missing_contracts"]), 2)
        self.client.rest.post.assert_not_called()
        self.assertEqual(self.client.Misc.run_query.call_count, 1)

    def test_product_contract_is_required(self):
        self.client.Misc.run_query.side_effect = [contract_rows()[:2]]
        result = self.run_helper()
        self.assertEqual(result["object"], "PEAKGEAR_USER.LAB_PRODUCTS_RAW_V")
        self.client.rest.post.assert_not_called()

    def test_blank_annotation_does_not_unlock_ranking(self):
        rows = contract_rows()
        rows[0]["ANNOTATION_VALUE"] = "   "
        self.client.Misc.run_query.side_effect = [rows]
        result = self.run_helper()
        self.assertEqual(result["missing_annotations"], ["DESCRIPTION"])
        self.client.rest.post.assert_not_called()

    def test_product_names_are_returned_without_changing_event_count(self):
        row = {"PRODUCT_ID": 1, "PRODUCT_NAME": "Reviewed product", "DIGITAL_EVENTS": 61564}
        result = self.run_helper([row])
        self.assertEqual(result["rows"], [row])
        self.assertEqual(result["product_labels"], "PEAKGEAR_USER.LAB_PRODUCTS_RAW_V")
        statement = self.client.rest.post.call_args.args[1]["statementText"]
        self.assertLess(statement.index("GROUP BY product_id"), statement.index("LEFT JOIN"))
        self.assertIn("p.product_id = t.product_id", statement)
        self.assertEqual(self.client.rest.post.call_args.kwargs["timeout"], 90)

    def test_duplicate_product_keys_stop_before_label_join(self):
        self.client.Misc.run_query.side_effect = [contract_rows(), [{"PRODUCT_ID": 1, "PRODUCT_ROWS": 2}]]
        result = self.run_helper()
        self.assertEqual(result["status"], "needs_unique_product_keys")
        self.client.rest.post.assert_not_called()

    def test_empty_result_stays_empty(self):
        self.assertEqual(self.run_helper([])["rows"], [])

    def test_unknown_product_name_is_not_invented(self):
        row = {"PRODUCT_ID": 17, "PRODUCT_NAME": None, "DIGITAL_EVENTS": 10}
        self.assertIsNone(self.run_helper([row])["rows"][0]["PRODUCT_NAME"])

    def test_contract_parser_handles_tuple_and_lowercase_rows(self):
        self.client.Misc.run_query.side_effect = [json.dumps({"items": [
            ["LAB_PRODUCTS_RAW_V", "DESCRIPTION", "Product catalog"],
            {"object_name": "LAB_PRODUCTS_RAW_V", "annotation_name": "TAGS", "annotation_value": "product_catalog"},
        ]})]
        contract = runtime._saved_interest_contracts(self.client)
        self.assertEqual(contract["LAB_PRODUCTS_RAW_V"]["DESCRIPTION"], "Product catalog")
        self.assertEqual(contract["LAB_PRODUCTS_RAW_V"]["TAGS"], "product_catalog")

    def test_no_connection_is_a_controlled_error(self):
        with patch.object(runtime, "get_adp", return_value=None):
            result = json.loads(runtime.adp_get_top_digital_interest())
        self.assertIn("error", result)
        self.client.Misc.run_query.assert_not_called()


if __name__ == "__main__":
    unittest.main()
