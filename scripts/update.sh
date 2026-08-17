#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
derivation="$repo_root/derivation.nix"
upstream="buchen/portfolio"
asset_name() { printf 'PortfolioPerformance-%s-linux.gtk.x86_64.tar.gz' "$1"; }

current_version="$(sed -n 's/^[[:space:]]*version = "\([^"]*\)".*/\1/p' "$derivation")"
if [ -z "$current_version" ]; then
  echo "error: could not read version from $derivation" >&2
  exit 1
fi

auth=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth=(-H "Authorization: token $GITHUB_TOKEN")
fi

releases_json="$(curl -fsSL --retry 3 "${auth[@]}" \
  "https://api.github.com/repos/$upstream/releases?per_page=100")"

latest="$(printf '%s' "$releases_json" | python3 -c '
import json, sys
rels = json.load(sys.stdin)
tags = [r["tag_name"].lstrip("v") for r in rels
        if not r.get("draft") and not r.get("prerelease")]
print("\n".join(tags))
' | sort -V | tail -1)"

if [ -z "$latest" ]; then
  echo "error: could not determine latest stable release of $upstream" >&2
  exit 1
fi

newer="$(printf '%s\n%s\n' "$current_version" "$latest" | sort -V | tail -1)"
if [ "$newer" = "$current_version" ]; then
  echo "no update: current version $current_version is up to date (latest stable: $latest)"
  exit 0
fi

asset="$(asset_name "$latest")"
asset_url="$(printf '%s' "$releases_json" | python3 -c '
import json, sys
rels = json.load(sys.stdin)
version, asset = sys.argv[1], sys.argv[2]
for r in rels:
    if r.get("draft") or r.get("prerelease"):
        continue
    if r["tag_name"].lstrip("v") != version:
        continue
    for a in r.get("assets", []):
        if a["name"] == asset:
            print(a["browser_download_url"])
            break
    break
' "$latest" "$asset")"

if [ -z "$asset_url" ]; then
  echo "error: asset '$asset' not found for release $latest" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL --retry 3 -o "$tmpdir/$asset" "$asset_url"
sha256="$(sha256sum "$tmpdir/$asset" | awk '{print $1}')"

sed -i \
  -e "s/^\([[:space:]]*version = \)\"[^\"]*\"/\1\"$latest\"/" \
  -e "s/^\([[:space:]]*sha256 = \)\"[^\"]*\"/\1\"$sha256\"/" \
  "$derivation"

echo "updated $derivation: version $current_version -> $latest"
echo "sha256 = $sha256"
echo "VERSION=$latest"
