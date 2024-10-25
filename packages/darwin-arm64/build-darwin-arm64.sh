#!/usr/bin/env bash

rm -rf plugins/trivy
rm -rf plugins/osquery
rm -rf plugins/dosai
rm -rf plugins/sourcekitten
mkdir -p plugins/osquery plugins/dosai plugins/sourcekitten

oras pull ghcr.io/cyclonedx/cdxgen-plugins-bin:darwin-arm64 -o plugins/sourcekitten/

curl -L https://github.com/owasp-dep-scan/dosai/releases/latest/download/Dosai-osx-arm64 -o plugins/dosai/dosai-darwin-arm64
chmod +x plugins/dosai/dosai-darwin-arm64
sha256sum plugins/dosai/dosai-darwin-arm64 > plugins/dosai/dosai-darwin-arm64.sha256

for plug in trivy
do
    mkdir -p plugins/$plug
    mv ../../plugins/$plug/*darwin-arm64* plugins/$plug/
done