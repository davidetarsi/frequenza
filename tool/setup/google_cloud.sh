#!/usr/bin/env bash
# Account di servizio per i caricamenti automatici sul Play Store, al posto
# dei clic del punto 6 di docs/azioni-manuali.md: progetto, API, account e
# chiave JSON in $KEYS. L'invito nella Play Console resta a mano.
#
#   bash tool/setup/google_cloud.sh
#
# Serve gcloud autenticato: brew install --cask google-cloud-sdk && gcloud auth login.
# L'id del progetto è unico in tutto Google Cloud: se è preso, PROJECT=altro-id.
set -euo pipefail

PROJECT=${PROJECT:-frequenza-ci-davidetarsi}
KEYS=${KEYS:-$HOME/chiavi/frequenza}
ACCOUNT="frequenza-ci@$PROJECT.iam.gserviceaccount.com"
KEY_FILE="$KEYS/frequenza-ci.json"

gcloud projects describe "$PROJECT" >/dev/null 2>&1 \
  || gcloud projects create "$PROJECT" --name 'Frequenza CI'
gcloud services enable androidpublisher.googleapis.com --project "$PROJECT"
gcloud iam service-accounts describe "$ACCOUNT" --project "$PROJECT" >/dev/null 2>&1 \
  || gcloud iam service-accounts create frequenza-ci --project "$PROJECT" --display-name 'Frequenza CI'

mkdir -p "$KEYS"
if [[ -f $KEY_FILE ]]; then
  echo "La chiave $KEY_FILE c'è già: non ne creo un'altra."
else
  gcloud iam service-accounts keys create "$KEY_FILE" --iam-account "$ACCOUNT" --project "$PROJECT"
  chmod 600 "$KEY_FILE"
fi

cat <<EOF

Account di servizio: $ACCOUNT

Ora, nella Play Console: Utenti e autorizzazioni → Invita nuovi utenti, con
questa email e i permessi su Frequenza (rilascio nei canali di test e in
produzione, presenza nello Store). Poi:

  bash tool/setup/github.sh play $KEY_FILE
EOF
