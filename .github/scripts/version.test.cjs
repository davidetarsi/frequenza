// node --test .github/scripts/
const test = require('node:test');
const assert = require('node:assert/strict');
const { parseVersion, selectedLabel, nextVersion, formatVersion } = require('./version.cjs');

test('parseVersion reads MAJOR.MINOR.PATCH+BUILD', () => {
  assert.deepEqual(parseVersion('name: frequenza\nversion: 0.1.0+1\n'), [0, 1, 0, 1]);
});

test('parseVersion rejects a version without build unless allowed', () => {
  assert.throws(() => parseVersion('version: 0.1.0\n'));
  assert.deepEqual(parseVersion('version: 0.1.0\n', { allowMissingBuild: true }), [0, 1, 0, 0]);
});

test('parseVersion rejects a missing version line', () => {
  assert.throws(() => parseVersion('name: frequenza\n', { allowMissingBuild: true }));
});

test('the first release from 0.1.0 expects 0.2.0+1', () => {
  assert.deepEqual(nextVersion([0, 1, 0, 0], 'version:minor'), [0, 2, 0, 1]);
  assert.equal(formatVersion([0, 2, 0, 1]), '0.2.0+1');
});

test('major and patch bumps also bump the build', () => {
  assert.deepEqual(nextVersion([1, 2, 3, 7], 'version:major'), [2, 0, 0, 8]);
  assert.deepEqual(nextVersion([1, 2, 3, 7], 'version:patch'), [1, 2, 4, 8]);
});

test('selectedLabel wants exactly one version label', () => {
  assert.equal(selectedLabel(['bug', 'version:patch']), 'version:patch');
  assert.equal(selectedLabel(['version:major', 'version:minor']), null);
  assert.equal(selectedLabel([]), null);
});
