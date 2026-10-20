"""Shared, offline-testable project configuration for macOS and Windows.

Database passwords remain in the vendor package's OS keyring. This helper
never accepts passwords as command-line arguments or writes them to TOML.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import tempfile
import tomllib


def project_config(existing: str, python: Path, wrapper: Path) -> str:
    """Replace only LiveLab and its subtables; preserve all other settings."""
    tomllib.loads(existing)
    lines = []
    skipping = False
    for line in existing.splitlines(keepends=True):
        header = re.match(r'^\s*\[\[?(.+?)\]\]?\s*(?:#.*)?$', line)
        if header:
            section = header.group(1)
            skipping = bool(re.match(r'^mcp_servers\.(?:LiveLab|"LiveLab"|\'LiveLab\')(?:\.|$)', section))
        if not skipping:
            lines.append(line)
    text = ''.join(lines).rstrip()
    text += '\n\n[mcp_servers.LiveLab]\n'
    text += '# PeakGear LiveLab: passwords stay in the OS credential store.\n'
    text += '# admin is a tool profile, not the database account.\n'
    text += f'command = {json.dumps(str(python), ensure_ascii=False)}\n'
    text += f'args = {json.dumps([str(wrapper), "--transport", "stdio", "--profile", "admin"], ensure_ascii=False)}\n'
    text += 'enabled = true\nstartup_timeout_sec = 60\ntool_timeout_sec = 180\n'
    text += 'default_tools_approval_mode = "prompt"\n'
    tomllib.loads(text)
    return text


def configure(project: Path, runtime: Path, python: Path) -> Path:
    project = project.resolve()
    runtime = runtime.resolve()
    # Preserve the virtualenv executable path: resolving its symlink to the
    # base interpreter would lose access to the installed MCP dependencies.
    python = python.absolute()
    wrapper = runtime / 'livelab_mcp.py'
    if not project.is_dir():
        raise ValueError('Select an existing project folder before configuring LiveLab.')
    if not python.is_file() or not wrapper.is_file():
        raise ValueError('The installed Python runtime or LiveLab server is missing. Run setup again.')
    config_dir = project / '.codex'
    config_dir.mkdir(parents=True, exist_ok=True)
    config = config_dir / 'config.toml'
    existing = config.read_text(encoding='utf-8-sig') if config.exists() else ''
    updated = project_config(existing, python, wrapper)
    # Atomic replacement: malformed existing TOML is rejected before any write.
    handle, name = tempfile.mkstemp(prefix='.peakgear-config-', dir=config_dir)
    try:
        with os.fdopen(handle, 'w', encoding='utf-8', newline='\n') as stream:
            stream.write(updated)
        os.replace(name, config)
    finally:
        if os.path.exists(name):
            os.unlink(name)
    (runtime / 'project-path').write_text(str(project), encoding='utf-8')
    return config


def verify_credentials() -> None:
    from mcp_server.credential_store import get_keyring_password, load_config_file

    settings = load_config_file().get('adp', {})
    if settings.get('user') != 'PEAKGEAR_USER':
        raise ValueError('The configured database user is not PEAKGEAR_USER. Run setup again.')
    database_url_pattern = r'https://' + r'[^/\s]+\.oraclecloudapps\.com/?'
    if not re.fullmatch(database_url_pattern, settings.get('url', '')):
        raise ValueError('The configured database URL is invalid. Use the ADP_URL from Lab 3.')
    if not get_keyring_password('adp', 'PEAKGEAR_USER'):
        raise ValueError('The password was not saved in the OS credential store. Ask the instructor before continuing.')


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='action', required=True)
    commands.add_parser('verify-credentials')
    config = commands.add_parser('configure')
    config.add_argument('--project', type=Path, required=True)
    config.add_argument('--runtime', type=Path, required=True)
    config.add_argument('--python', type=Path, required=True)
    args = parser.parse_args()
    try:
        if args.action == 'verify-credentials':
            verify_credentials()
            print('Database password storage verified; no password is displayed.')
        else:
            path = configure(args.project, args.runtime, args.python)
            print(f'LiveLab project configuration saved: {path}')
    except (ValueError, OSError, tomllib.TOMLDecodeError) as exc:
        print(f'Setup stopped: {exc}')
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
