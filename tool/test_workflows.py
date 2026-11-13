"""Controlli statici sui workflow GitHub: le pipeline non girano sulla VPS,
questi test fermano almeno gli errori che il design vieta.

python3 -m unittest discover -s tool -p 'test_*.py'
"""

import os
import unittest
from pathlib import Path

try:
    import yaml
except ImportError:  # In CI è obbligatorio (REQUIRE_YAML=1), in locale si salta.
    if os.environ.get('REQUIRE_YAML'):
        raise
    yaml = None

WORKFLOWS = Path(__file__).resolve().parents[1] / '.github' / 'workflows'
FLUTTER = '3.38.5'
PINNED = {
    'actions/github-script': 'ed597411d8f924073f98dfc5c65a23a2325f34cd',
    'r0adkll/upload-google-play': 'e738b9dd8f2476ea806d921b64aacd24f34515a5',
}


def load(name):
    workflow = yaml.safe_load((WORKFLOWS / name).read_text())
    # PyYAML legge la chiave `on` come booleano.
    workflow['on'] = workflow.pop(True, workflow.get('on'))
    return workflow


def steps(workflow):
    for job in workflow['jobs'].values():
        yield from job.get('steps', [])


def step_using(workflow, action):
    found = [s for s in steps(workflow) if s.get('uses', '').startswith(action + '@')]
    assert len(found) == 1, f'{action}: {len(found)} step'
    return found[0]


def runs(workflow):
    return '\n'.join(s.get('run', '') for s in steps(workflow))


SKIP = unittest.skipIf(yaml is None, 'PyYAML non installato')


@SKIP
class AllWorkflowsTest(unittest.TestCase):
    def test_workflows_exist_and_parse(self):
        files = sorted(WORKFLOWS.glob('*.yml'))
        self.assertTrue(files)
        for path in files:
            self.assertIn('jobs', load(path.name), path.name)

    def test_flutter_and_actions_are_pinned(self):
        for path in WORKFLOWS.glob('*.yml'):
            for step in steps(load(path.name)):
                uses = step.get('uses', '')
                if uses.startswith('subosito/flutter-action@'):
                    self.assertEqual(step['with']['flutter-version'], FLUTTER, path.name)
                for action, sha in PINNED.items():
                    if uses.startswith(action + '@'):
                        self.assertEqual(uses.split('@')[1].split()[0], sha, path.name)


@SKIP
class CiTest(unittest.TestCase):
    def test_job_names_used_by_branch_rules(self):
        names = {job['name'] for job in load('ci.yml')['jobs'].values()}
        self.assertLessEqual({'Lint & Unit Tests', 'Android Version Selection'}, names)

    def test_checks_run_and_generated_files_are_committed(self):
        commands = runs(load('ci.yml'))
        self.assertIn('bash tool/check.sh', commands)
        self.assertIn('git diff --exit-code', commands)

    def test_bump_never_checks_out_pr_code(self):
        workflow = load('bump_version.yml')
        self.assertIn('pull_request_target', workflow['on'])
        for step in steps(workflow):
            if step.get('uses', '').startswith('actions/checkout@'):
                ref = str(step.get('with', {}).get('ref', ''))
                self.assertNotIn('head', ref)
                self.assertNotIn('pull_request', ref)


@SKIP
class BuildDevTest(unittest.TestCase):
    def setUp(self):
        self.workflow = load('build_dev.yml')

    def test_triggers(self):
        push = self.workflow['on']['push']
        self.assertEqual(push['branches'], ['develop'])
        self.assertLessEqual({'docs/**', 'test/**', '**/*.md'}, set(push['paths-ignore']))
        self.assertIn('workflow_dispatch', self.workflow['on'])

    def test_builds_dev_arm64(self):
        commands = runs(self.workflow)
        self.assertIn('--flavor dev', commands)
        self.assertIn('--target-platform android-arm64', commands)

    def test_telegram_secrets_only_from_env(self):
        telegram = [s for s in steps(self.workflow) if 'api.telegram.org' in s.get('run', '')]
        self.assertEqual(len(telegram), 1)
        self.assertNotIn('secrets.', telegram[0]['run'])
        self.assertEqual(telegram[0]['env']['TELEGRAM_BOT_TOKEN'], '${{ secrets.TELEGRAM_BOT_TOKEN }}')
        self.assertEqual(telegram[0]['env']['TELEGRAM_CHAT_ID'], '${{ secrets.TELEGRAM_CHAT_ID }}')

    def test_artifact_kept_seven_days(self):
        self.assertEqual(step_using(self.workflow, 'actions/upload-artifact')['with']['retention-days'], 7)


if __name__ == '__main__':
    unittest.main()
