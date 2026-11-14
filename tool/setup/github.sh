#!/usr/bin/env bash
# Configura il repo GitHub per le pipeline, al posto dei clic del punto 2 di
# docs/azioni-manuali.md.
#
#   bash tool/setup/github.sh               segreti, etichette version:*, regole di main e develop
#   bash tool/setup/github.sh play FILE     segreto dell'account di servizio e PLAY_UPLOAD=on (punto 6)
#
# Serve la CLI gh autenticata: brew install gh && gh auth login.
# Le chiavi si leggono da $KEYS (predefinito ~/chiavi/frequenza). Password e
# token si chiedono a schermo senza mostrarli, e arrivano a gh da stdin, mai
# come argomenti. Si può rilanciare: chiede prima di sovrascrivere un segreto,
# etichette e regole si aggiornano.
set -euo pipefail

REPO=${REPO:-davidetarsi/frequenza}
KEYS=${KEYS:-$HOME/chiavi/frequenza}

die() { echo "$*" >&2; exit 1; }

existing=$(gh secret list --repo "$REPO" --json name --jq '.[].name')

# Vero se il segreto va scritto: manca, oppure Davide conferma.
want() {
  grep -qx "$1" <<<"$existing" || return 0
  local answer=''
  read -rp "$1 è già impostato: sovrascrivere? [s/N] " answer || true
  [[ $answer == [sS]* ]]
}

put() { gh secret set "$1" --repo "$REPO" >/dev/null; }

# Valore dalla variabile d'ambiente con lo stesso nome, se c'è, altrimenti a schermo.
ask() {
  local value=${!1:-}
  if [[ -z $value ]]; then
    read -rsp "$2: " value
    echo >&2
  fi
  [[ -n $value ]] || die "$2: valore vuoto"
  printf %s "$value"
}

encode() { base64 <"$1" | tr -d '\n'; }

play() {
  local file=${1:-}
  [[ -f $file ]] || die "Uso: bash tool/setup/github.sh play ~/chiavi/frequenza/frequenza-ci.json"
  put GOOGLE_PLAY_SERVICE_ACCOUNT_JSON <"$file"
  gh variable set PLAY_UPLOAD --repo "$REPO" --body on
  echo "Fatto: da ora ogni merge su main va nel test chiuso."
}

ruleset() { # nome, controlli richiesti (JSON), bypass (JSON)
  cat <<JSON
{
  "name": "$1",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["refs/heads/$1"], "exclude": []}},
  "bypass_actors": $3,
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false}},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": false,
      "required_status_checks": $2}}
  ]
}
JSON
}

apply_ruleset() { # nome, corpo JSON
  local id
  id=$(gh api "repos/$REPO/rulesets" --jq ".[] | select(.name == \"$1\") | .id")
  if [[ -n $id ]]; then
    gh api -X PUT "repos/$REPO/rulesets/$id" --input - <<<"$2" >/dev/null
  else
    gh api -X POST "repos/$REPO/rulesets" --input - <<<"$2" >/dev/null
  fi
  echo "Regola $1 a posto."
}

if [[ ${1:-} == play ]]; then
  play "${2:-}"
  exit 0
fi

upload="$KEYS/frequenza-upload.jks"
dev="$KEYS/frequenza-dev.p12"
for file in "$upload" "$dev"; do
  [[ -f $file ]] || die "Manca $file: crealo con i comandi del punto 1 di docs/azioni-manuali.md"
done

want KEYSTORE_BASE64 && encode "$upload" | put KEYSTORE_BASE64
if want KEYSTORE_PASSWORD; then
  # Le chiavi PKCS12 di keytool hanno una sola password per archivio e chiave.
  password=$(ask UPLOAD_PASSWORD 'Password della chiave di upload')
  printf %s "$password" | put KEYSTORE_PASSWORD
  printf %s "$password" | put KEY_PASSWORD
fi
want KEY_ALIAS && printf upload | put KEY_ALIAS
want DEBUG_KEYSTORE_BASE64 && encode "$dev" | put DEBUG_KEYSTORE_BASE64
want PAT_TOKEN && ask PAT_TOKEN 'PAT_TOKEN (fine-grained, Contents read/write)' | put PAT_TOKEN
want TELEGRAM_BOT_TOKEN && ask TELEGRAM_BOT_TOKEN 'Token del bot Telegram' | put TELEGRAM_BOT_TOKEN
want TELEGRAM_CHAT_ID && ask TELEGRAM_CHAT_ID 'Chat ID di Telegram' | put TELEGRAM_CHAT_ID
echo "Segreti a posto."

gh label create version:major --repo "$REPO" --color B60205 --description 'Rilascio: X.0.0' --force
gh label create version:minor --repo "$REPO" --color FBCA04 --description 'Rilascio: 0.X.0' --force
gh label create version:patch --repo "$REPO" --color 0E8A16 --description 'Rilascio: 0.0.X' --force

# Su develop la bypass list «Repository admin» (ruolo 5) lascia scrivere il
# bump della versione, che usa il PAT di Davide.
apply_ruleset main "$(ruleset main '[{"context": "Lint & Unit Tests"}, {"context": "Android Version Selection"}]' '[]')"
apply_ruleset develop "$(ruleset develop '[{"context": "Lint & Unit Tests"}]' \
  '[{"actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always"}]')"
