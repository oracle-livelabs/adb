"""Offline configuration checks; not a live database or Windows-machine test."""

import importlib.util
from pathlib import Path, PureWindowsPath
import sys
import tempfile
import tomllib
import types
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('livelab_setup', ROOT / 'starter-kit/livelab_setup.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class SetupTests(unittest.TestCase):
    def test_windows_paths_are_toml_escaped_without_a_shell(self):
        python = PureWindowsPath(r'C:\Users\Learner Name\工具 🧪\Scripts\python.exe')
        wrapper = PureWindowsPath(r'C:\Users\Learner Name\AppData\Local\peakgear-livelab\livelab_mcp.py')
        config = tomllib.loads(setup.project_config('', python, wrapper))['mcp_servers']['LiveLab']
        self.assertEqual(config['command'], str(python))
        self.assertEqual(config['args'], [str(wrapper), '--transport', 'stdio', '--profile', 'admin'])
        self.assertNotIn('zsh', config['command'])
        self.assertEqual(config['default_tools_approval_mode'], 'prompt')

    def test_refresh_preserves_unrelated_tables_arrays_and_settings(self):
        existing = '''model = "example"
[mcp_servers.Other]
command = "other-server"
[mcp_servers.LiveLab]
command = "old"
[mcp_servers.LiveLab.env]
OLD_VALUE = "remove-this"
[[skills.config]]
path = "keep-this"
enabled = true
[features]
example = true
'''
        result = tomllib.loads(setup.project_config(existing, Path('/runtime/python'), Path('/runtime/server.py')))
        previous = tomllib.loads(existing)
        for key in ('model', 'features', 'skills'):
            self.assertEqual(result[key], previous[key])
        self.assertEqual(result['mcp_servers']['Other'], previous['mcp_servers']['Other'])
        self.assertNotIn('env', result['mcp_servers']['LiveLab'])

    def test_quoted_livelab_section_is_replaced(self):
        for quote in ('"', "'"):
            existing = f'[mcp_servers.{quote}LiveLab{quote}]\ncommand = "old"\n'
            result = tomllib.loads(setup.project_config(existing, Path('/python'), Path('/wrapper')))
            self.assertEqual(result['mcp_servers']['LiveLab']['command'], str(Path('/python')))

    def test_config_refresh_is_idempotent(self):
        first = setup.project_config('', Path('/python'), Path('/wrapper'))
        self.assertEqual(first, setup.project_config(first, Path('/python'), Path('/wrapper')))

    def test_configure_preserves_existing_project_and_never_creates_password_fields(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            project = root / 'Project with spaces'
            runtime = root / 'Runtime'
            project.mkdir()
            runtime.mkdir()
            python = runtime / 'python'
            python.touch()
            (runtime / 'livelab_mcp.py').touch()
            (project / '.codex').mkdir()
            config = project / '.codex/config.toml'
            config.write_text('model = "keep"\n', encoding='utf-8')
            self.assertEqual(setup.configure(project, runtime, python), config.resolve())
            self.assertEqual(tomllib.loads(config.read_text())['model'], 'keep')
            self.assertEqual((runtime / 'project-path').read_text(), str(project.resolve()))
            self.assertNotIn('password =', config.read_text())
            self.assertNotIn('token =', config.read_text())
            self.assertEqual(list((project / '.codex').glob('.peakgear-config-*')), [])

    def test_malformed_existing_config_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / '.codex').mkdir()
            config = root / '.codex/config.toml'
            config.write_text('invalid = [', encoding='utf-8')
            python = root / 'python'
            python.touch()
            (root / 'livelab_mcp.py').touch()
            with self.assertRaises(tomllib.TOMLDecodeError):
                setup.configure(root, root, python)
            self.assertEqual(config.read_text(), 'invalid = [')

    def test_virtualenv_interpreter_symlink_is_not_resolved_to_base_python(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp).resolve()
            base = root / 'base-python'
            base.touch()
            python = root / 'venv-python'
            try:
                python.symlink_to(base)
            except OSError:
                self.skipTest('This host does not permit symlink creation.')
            (root / 'livelab_mcp.py').touch()
            config = setup.configure(root, root, python)
            self.assertEqual(tomllib.loads(config.read_text())['mcp_servers']['LiveLab']['command'], str(python))

    def test_missing_runtime_stops_before_project_config(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            with self.assertRaises(ValueError):
                setup.configure(root, root, root / 'missing-python')
            self.assertFalse((root / '.codex').exists())

    def verify_fake_credentials(self, user='PEAKGEAR_USER', url='https://example.adb.test.oraclecloudapps.com', present=True):
        module = types.ModuleType('mcp_server.credential_store')
        module.load_config_file = lambda: {'adp': {'user': user, 'url': url}}
        module.get_keyring_password = lambda service, name: 'test-only-value' if present else None
        with patch.dict(sys.modules, {'mcp_server.credential_store': module}):
            setup.verify_credentials()

    def test_stored_credentials_pass_without_a_database_call(self):
        self.verify_fake_credentials()

    def test_failed_password_storage_stops_setup(self):
        with self.assertRaisesRegex(ValueError, 'password was not saved'):
            self.verify_fake_credentials(present=False)

    def test_wrong_database_user_stops_setup(self):
        with self.assertRaisesRegex(ValueError, 'not PEAKGEAR_USER'):
            self.verify_fake_credentials(user='OTHER_USER')

    def test_non_database_url_stops_setup(self):
        for url in ('http://localhost:8000', 'https://datastudio.oracle.com', 'https://example.oraclecloudapps.com/ords/'):
            with self.subTest(url=url), self.assertRaisesRegex(ValueError, 'URL is invalid'):
                self.verify_fake_credentials(url=url)


if __name__ == '__main__':
    unittest.main()
