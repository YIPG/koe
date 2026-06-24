#!/usr/bin/env bash
# koe — end-to-end Azure transcription smoke test.
#
# Synthesizes a Japanese clip with macOS `say`, sends it to the gpt-4o-transcribe
# deployment, and prints input vs. transcription so you can eyeball accuracy.
# This validates the whole Azure path WITHOUT the Swift app.
#
# Usage:
#   source .koe.env
#   ./scripts/smoke-test.sh ["custom Japanese text"]
set -euo pipefail

: "${KOE_ENDPOINT:?set KOE_ENDPOINT (run: source .koe.env)}"
: "${KOE_API_KEY:?set KOE_API_KEY (run: source .koe.env)}"
DEPLOYMENT="${KOE_DEPLOYMENT:-gpt-4o-transcribe}"
API_VERSION="${KOE_API_VERSION:-2025-03-01-preview}"
VOICE="${KOE_VOICE:-Kyoko}"
TEXT="${1:-こんにちは。これは音声入力アプリkoeのテストです。今日は晴れていて、午後三時に渋谷で会議があります。}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

say -v "$VOICE" -o "$TMP/sample.aiff" "$TEXT"
ffmpeg -y -loglevel error -i "$TMP/sample.aiff" -ar 16000 -ac 1 "$TMP/sample.wav"

echo "INPUT  : $TEXT"
echo "----"
RESULT=$(curl -s -X POST \
  "${KOE_ENDPOINT%/}/openai/deployments/$DEPLOYMENT/audio/transcriptions?api-version=$API_VERSION" \
  -H "api-key: $KOE_API_KEY" \
  -F "file=@$TMP/sample.wav" \
  -F "language=ja" \
  -F "response_format=json")

OUTPUT=$(printf '%s' "$RESULT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("text","<no text>"))' 2>/dev/null || printf '%s' "$RESULT")
echo "OUTPUT : $OUTPUT"
