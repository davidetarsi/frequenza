"""Script di configurazione (tool/setup) provati con gh e gcloud finti:
la configurazione vera gira sul Mac di Davide, non sulla VPS.

python3 -m unittest discover -s tool -p 'test_*.py'
"""

import base64
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

SETUP = Path(__file__).resolve().parent / 'setup'

# Registra ogni chiamata (argomenti e stdin) come riga JSON. `describe` fallisce,
# come se progetto e account non esistessero ancora; le liste sono vuote;
# `keys create` scrive il file, come gcloud.
FAKE = '''#!/usr/bin/env python3
import json, os, sys
args = sys.argv[1:]
stdin = '' if sys.stdin.isatty() else sys.stdin.read()
with open(os.environ['FAKE_LOG'], 'a') as log:
    log.write(json.dumps({'tool': os.path.basename(sys.argv[0]), 'args': args, 'stdin': stdin}) + '\\n')
if 'describe' in args:
    sys.exit(1)
if args[:4] == ['iam', 'service-accounts', 'keys', 'create']:
    open(args[4], 'w').write('{}')
'''


class FakeTools:
    def __init__(self, tmp):
        self.tmp = Path(tmp)
        bin_dir = self.tmp / 'bin'
        bin_dir.mkdir()
        for tool in ('gh', 'gcloud'):
            (bin_dir / tool).write_text(FAKE)
            (bin_dir / tool).chmod(0o755)
        self.keys = self.tmp / 'chiavi'
        self.keys.mkdir()
        self.log = self.tmp / 'calls.jsonl'
        self.env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}', FAKE_LOG=str(self.log),
                        KEYS=str(self.keys), REPO='davidetarsi/frequenza')

    def run(self, script, *args, **env):
        result = subprocess.run(['bash', str(SETUP / script), *args], env={**self.env, **env},
                                stdin=subprocess.DEVNULL, capture_output=True, text=True)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []
        return result, calls


def secrets(calls):
    return {c['args'][2]: c['stdin'] for c in calls if c['args'][:2] == ['secret', 'set']}


def rulesets(calls):
    return {json.loads(c['stdin'])['name']: json.loads(c['stdin'])
            for c in calls if c['args'][0] == 'api' and '--input' in c['args']}


class GithubSetupTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.tools = FakeTools(self.tmp.name)
        (self.tools.keys / 'frequenza-upload.jks').write_bytes(b'upload\x00key')
        (self.tools.keys / 'frequenza-dev.p12').write_bytes(b'dev\x00key')
        self.answers = dict(UPLOAD_PASSWORD='segreta', PAT_TOKEN='github_pat_x',
                            TELEGRAM_BOT_TOKEN='123:abc', TELEGRAM_CHAT_ID='-100')

    def tearDown(self):
        self.tmp.cleanup()

    def test_sets_every_secret_once(self):
        result, calls = self.tools.run('github.sh', **self.answers)
        self.assertEqual(result.returncode, 0, result.stderr)
        values = secrets(calls)
        self.assertEqual(base64.b64decode(values['KEYSTORE_BASE64']), b'upload\x00key')
        self.assertEqual(base64.b64decode(values['DEBUG_KEYSTORE_BASE64']), b'dev\x00key')
        self.assertEqual(values['KEYSTORE_PASSWORD'], 'segreta')
        self.assertEqual(values['KEY_PASSWORD'], 'segreta')
        self.assertEqual(values['KEY_ALIAS'], 'upload')
        self.assertEqual(values['PAT_TOKEN'], 'github_pat_x')
        self.assertEqual(values['TELEGRAM_BOT_TOKEN'], '123:abc')
        self.assertEqual(values['TELEGRAM_CHAT_ID'], '-100')
        self.assertNotIn('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', values)
        # I valori passano da stdin, mai dagli argomenti (visibili in `ps`).
        for call in calls:
            self.assertNotIn('segreta', ' '.join(call['args']))

    def test_labels(self):
        _, calls = self.tools.run('github.sh', **self.answers)
        labels = {c['args'][2] for c in calls if c['args'][:2] == ['label', 'create']}
        self.assertEqual(labels, {'version:major', 'version:minor', 'version:patch'})

    def test_rulesets(self):
        _, calls = self.tools.run('github.sh', **self.answers)
        rules = rulesets(calls)
        self.assertEqual(set(rules), {'main', 'develop'})
        for name, rule in rules.items():
            self.assertEqual(rule['conditions']['ref_name']['include'], [f'refs/heads/{name}'])
            self.assertEqual(rule['enforcement'], 'active')
            types = {r['type'] for r in rule['rules']}
            self.assertLessEqual({'deletion', 'non_fast_forward', 'pull_request', 'required_status_checks'}, types)

        def checks(rule):
            status = next(r for r in rule['rules'] if r['type'] == 'required_status_checks')
            return {c['context'] for c in status['parameters']['required_status_checks']}

        self.assertEqual(checks(rules['main']), {'Lint & Unit Tests', 'Android Version Selection'})
        self.assertEqual(checks(rules['develop']), {'Lint & Unit Tests'})
        self.assertEqual(rules['main']['bypass_actors'], [])
        # Il bump della versione scrive su develop con il PAT di Davide (admin).
        self.assertEqual(rules['develop']['bypass_actors'],
                         [{'actor_id': 5, 'actor_type': 'RepositoryRole', 'bypass_mode': 'always'}])

    def test_missing_key_stops_before_writing(self):
        (self.tools.keys / 'frequenza-dev.p12').unlink()
        result, calls = self.tools.run('github.sh', **self.answers)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('frequenza-dev.p12', result.stderr)
        self.assertEqual(secrets(calls), {})

    def test_play_sets_account_and_switch(self):
        account = self.tools.keys / 'frequenza-ci.json'
        account.write_text('{"type": "service_account"}')
        result, calls = self.tools.run('github.sh', 'play', str(account))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(secrets(calls), {'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON': '{"type": "service_account"}'})
        self.assertIn(['variable', 'set', 'PLAY_UPLOAD', '--repo', 'davidetarsi/frequenza', '--body', 'on'],
                      [c['args'] for c in calls])


class GoogleCloudSetupTest(unittest.TestCase):
    def test_creates_project_api_account_and_key(self):
        with tempfile.TemporaryDirectory() as tmp:
            tools = FakeTools(tmp)
            result, calls = tools.run('google_cloud.sh', PROJECT='frequenza-ci-prova')
            self.assertEqual(result.returncode, 0, result.stderr)
            commands = [' '.join(c['args']) for c in calls if c['tool'] == 'gcloud']
            self.assertTrue(any(c.startswith('projects create frequenza-ci-prova') for c in commands))
            self.assertTrue(any(c.startswith('services enable androidpublisher.googleapis.com') for c in commands))
            self.assertTrue(any(c.startswith('iam service-accounts create frequenza-ci') for c in commands))
            key = [c for c in commands if c.startswith('iam service-accounts keys create')]
            self.assertEqual(len(key), 1)
            self.assertIn(str(tools.keys / 'frequenza-ci.json'), key[0])
            self.assertIn('frequenza-ci@frequenza-ci-prova.iam.gserviceaccount.com', result.stdout)


if __name__ == '__main__':
    unittest.main()
