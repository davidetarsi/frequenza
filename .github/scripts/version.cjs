// Versioni di pubspec.yaml per i rilasci: usato da ci.yml e bump_version.yml.
// Test: node --test '.github/scripts/*.test.cjs'

const LABELS = ['version:major', 'version:minor', 'version:patch'];

// Il primo rilascio parte da `version: 0.1.0`, senza numero di build: con
// allowMissingBuild si legge come build 0, così la versione attesa è 0.2.0+1.
function parseVersion(text, { allowMissingBuild = false } = {}) {
  const match = text.match(/^version: (\d+)\.(\d+)\.(\d+)(?:\+(\d+))?\s*$/m);
  if (!match || (match[4] === undefined && !allowMissingBuild)) {
    throw new Error('Expected version: MAJOR.MINOR.PATCH+BUILD in pubspec.yaml');
  }
  return [match[1], match[2], match[3], match[4] ?? '0'].map(Number);
}

function selectedLabel(labelNames) {
  const selected = labelNames.filter((name) => LABELS.includes(name));
  return selected.length === 1 ? selected[0] : null;
}

function nextVersion([major, minor, patch, build], label) {
  if (label === 'version:major') return [major + 1, 0, 0, build + 1];
  if (label === 'version:minor') return [major, minor + 1, 0, build + 1];
  if (label === 'version:patch') return [major, minor, patch + 1, build + 1];
  throw new Error(`Unknown version label: ${label}`);
}

function formatVersion([major, minor, patch, build]) {
  return `${major}.${minor}.${patch}+${build}`;
}

module.exports = { LABELS, parseVersion, selectedLabel, nextVersion, formatVersion };
