#!/usr/bin/env bash
# koe — create a stable self-signed code-signing identity for local dev.
#
# Ad-hoc signing (`codesign --sign -`) changes the binary's identity on every
# rebuild, so macOS resets Accessibility permission and re-prompts the Keychain
# ACL each time. Signing with a fixed self-signed cert keeps the app's
# designated requirement constant across rebuilds, so those grants persist.
#
# Run once:  ./scripts/create-signing-cert.sh
# Then `make app` picks the identity up automatically.
#
# Security note: this is an UNTRUSTED, local-only code-signing key (Gatekeeper
# won't trust it; that's fine for running your own build). It's imported with
# -A so codesign can use it without a password prompt.
set -euo pipefail

CERT_NAME="${KOE_SIGN_IDENTITY:-koe-dev}"
KEYCHAIN="${HOME}/Library/Keychains/login.keychain-db"

if security find-identity -v -p codesigning | grep -q "\"$CERT_NAME\""; then
    echo "✓ signing identity '$CERT_NAME' already exists."
    exit 0
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/cert.cnf" <<EOF
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = $CERT_NAME
[v3]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
EOF

openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$TMP/key.pem" -out "$TMP/cert.pem" \
    -days 3650 -config "$TMP/cert.cnf" 2>/dev/null

# OpenSSL 3 defaults to a PKCS12 MAC/cipher that Apple's `security import` can't
# read; -legacy restores the 3DES/SHA1 format it accepts. LibreSSL has no
# -legacy flag (and already writes the legacy format), so add it only if present.
LEGACY=""
if openssl pkcs12 -help 2>&1 | grep -q -- '-legacy'; then LEGACY="-legacy"; fi
openssl pkcs12 -export -out "$TMP/cert.p12" \
    -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -passout pass:koe -name "$CERT_NAME" $LEGACY

# -A: any app may use the key without prompting (fine for a local dev key).
security import "$TMP/cert.p12" -k "$KEYCHAIN" -P koe -A

echo
echo "✓ created signing identity '$CERT_NAME'."
security find-identity -v -p codesigning | grep "$CERT_NAME" || true
echo
echo "Next: make app   (it will sign with '$CERT_NAME')"
