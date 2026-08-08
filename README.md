# Demosurvey — the Sovereign Ledger · Releases

Official, signed releases of the **Demosurvey** app — a sovereign,
peer-to-peer survey and voting platform with no central server. This
repository exists so anyone, anywhere, on any network can download the
app, verify it, and pass it on.

## 📱 Install on Android

1. Download **`demosurvey.apk`** from the
   [latest release](../../releases/latest).
2. Open the downloaded file. Android will ask you to allow installs
   from your browser — allow it for this install.
3. Open Demosurvey and create your account. If you are near a running
   Demosurvey node (same Wi-Fi), the app finds it automatically; to
   join a network elsewhere, scan a network-join QR from any member.

No app store, no account with us, no tracking. Once installed, your
phone can share the app onward — at a gathering, over a hotspot, in
places with no internet at all.

## 🔏 Verify your download (recommended)

Every release ships three files: the APK, a `manifest.json`
(version, SHA-256 hash, Ed25519 signature), and `public_key.pem`.

**The trust anchor is this fingerprint** — publicly recorded here, in
the main project README, and checkable with anyone already running
Demosurvey:

```
SHA256:9f90a94cf026f5d7ed1bfd5824bfd7915911c4755726b21b75c5614aa5c5a3aa
```

Quick verify (needs `python3` with the `cryptography` package, or use
`verify.sh` from this repo):

```bash
./verify.sh demosurvey.apk manifest.json public_key.pem
```

`verify.sh` checks all three links of the chain:

1. `public_key.pem`'s fingerprint equals the anchor above;
2. `manifest.json`'s Ed25519 signature verifies under that key;
3. the APK's SHA-256 equals the hash the manifest signs.

If any step fails, **do not install** — get the file from another
source and tell us.

## Why a separate repository?

The Demosurvey source lives in a private repository; this public one
holds only signed build artifacts, so the app can spread freely while
the signing chain — not the hosting — carries the trust. A copy
downloaded from a friend's phone, a mirror, or a USB stick verifies
exactly the same way.

## For node operators

Point your node at the latest release so its `/get-app` page shows the
internet-install QR alongside the local-network one:

```bash
export DEMOSURVEY_PUBLIC_APK_URL="https://github.com/OWNER/demosurvey-releases/releases/latest/download/demosurvey.apk"
scripts/setup_node.sh
```

(Replace `OWNER` with this repository's owner.)
