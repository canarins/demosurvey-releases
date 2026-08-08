#!/usr/bin/env bash
# verify.sh — verify a Demosurvey release APK against its signed manifest.
#
# Usage: ./verify.sh demosurvey.apk manifest.json public_key.pem
#
# Checks, in order:
#   1. public_key.pem fingerprint == the pinned trust anchor below
#   2. manifest.json Ed25519 signature verifies under that key
#   3. the APK SHA-256 == the hash the manifest signs
#
# Requires: python3 with the "cryptography" package
#   (pip install cryptography)

set -euo pipefail

EXPECTED_FP="SHA256:9f90a94cf026f5d7ed1bfd5824bfd7915911c4755726b21b75c5614aa5c5a3aa"

APK="${1:?usage: verify.sh <apk> <manifest.json> <public_key.pem>}"
MANIFEST="${2:?usage: verify.sh <apk> <manifest.json> <public_key.pem>}"
PUBKEY="${3:?usage: verify.sh <apk> <manifest.json> <public_key.pem>}"

APK="$APK" MANIFEST="$MANIFEST" PUBKEY="$PUBKEY" EXPECTED_FP="$EXPECTED_FP" \
python3 - <<'PY'
import base64, hashlib, json, os, sys

from cryptography.hazmat.primitives import serialization

apk = os.environ["APK"]
manifest_path = os.environ["MANIFEST"]
pubkey_path = os.environ["PUBKEY"]
expected_fp = os.environ["EXPECTED_FP"]

# 1. Fingerprint of the public key must match the pinned anchor.
pk = serialization.load_pem_public_key(open(pubkey_path, "rb").read())
raw = pk.public_bytes(
    serialization.Encoding.Raw, serialization.PublicFormat.Raw)
fp = "SHA256:" + hashlib.sha256(raw).hexdigest()
if fp != expected_fp:
    sys.exit(f"FAIL: public key fingerprint mismatch\n  got      {fp}\n  expected {expected_fp}")
print("  1/3  public key fingerprint matches the trust anchor")

# 2. Manifest signature must verify (canonical bytes per
#    DEMOSURVEY-RELEASE-v1, same scheme as the source-release pipeline).
m = json.load(open(manifest_path))
canonical = (
    b"DEMOSURVEY-RELEASE-v1|" + m["version"].encode()
    + b"|" + m["hash"].encode()
    + b"|" + repr(float(m["signed_at"])).encode())
pk.verify(base64.standard_b64decode(m["signature"]), canonical)
print("  2/3  manifest signature verifies")

# 3. APK hash must equal the signed hash.
h = hashlib.sha256()
with open(apk, "rb") as f:
    for chunk in iter(lambda: f.read(1 << 20), b""):
        h.update(chunk)
if h.hexdigest() != m["hash"]:
    sys.exit(f"FAIL: APK hash mismatch\n  got      {h.hexdigest()}\n  expected {m['hash']}")
print("  3/3  APK hash matches the signed manifest")
print("\nOK — this APK is authentic. Safe to install.")
PY
