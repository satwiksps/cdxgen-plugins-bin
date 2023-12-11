#!/usr/bin/env bash

rm -rf plugins/goversion
rm -rf plugins/trivy
rm -rf plugins/cargo-auditable
rm -rf plugins/osquery
rm -rf plugins/dosai
mkdir -p plugins/osquery plugins/dosai

wget https://github.com/osquery/osquery/releases/download/5.10.2/osquery-5.10.2.windows_x86_64.zip
unzip osquery-5.10.2.windows_x86_64.zip
cp "osquery-5.10.2.windows_x86_64/Program Files/osquery/osqueryi.exe" plugins/osquery/osqueryi-windows-amd64.exe
upx -9 --lzma plugins/osquery/osqueryi-windows-amd64.exe
sha256sum plugins/osquery/osqueryi-windows-amd64.exe > plugins/osquery/osqueryi-windows-amd64.exe.sha256
rm -rf osquery-5.10.2.windows_x86_64
rm osquery-5.10.2.windows_x86_64.zip

wget https://github.com/osquery/osquery/releases/download/5.10.2/osquery-5.10.2_1.linux_x86_64.tar.gz
tar -xvf osquery-5.10.2_1.linux_x86_64.tar.gz
cp opt/osquery/bin/osqueryd plugins/osquery/osqueryi-linux-amd64
upx -9 --lzma plugins/osquery/osqueryi-linux-amd64
sha256sum plugins/osquery/osqueryi-linux-amd64 > plugins/osquery/osqueryi-linux-amd64.sha256
rm -rf etc usr var opt
rm osquery-5.10.2_1.linux_x86_64.tar.gz

curl -L https://github.com/owasp-dep-scan/dosai/releases/latest/download/Dosai -o plugins/dosai/dosai-linux-amd64
chmod +x plugins/dosai/dosai-linux-amd64
sha256sum plugins/dosai/dosai-linux-amd64 > plugins/dosai/dosai-linux-amd64.sha256

curl -L https://github.com/owasp-dep-scan/dosai/releases/latest/download/Dosai.exe -o plugins/dosai/dosai-windows-amd64.exe
sha256sum plugins/dosai/dosai-windows-amd64.exe > plugins/dosai/dosai-windows-amd64.exe.sha256

for plug in goversion trivy cargo-auditable
do
    mkdir -p plugins/$plug
    pushd thirdparty/$plug
    make all
    chmod +x build/*
    cp -rf build/* ../../plugins/$plug/
    rm -rf build
    popd
done

./plugins/osquery/osqueryi-linux-amd64 --help
./plugins/goversion/goversion-linux-amd64
./plugins/trivy/trivy-cdxgen-linux-amd64 -v
./plugins/cargo-auditable/cargo-auditable-cdxgen-linux-amd64
./plugins/dosai/dosai-linux-amd64 --help

chmod +x packages/arm64/build-arm64.sh
pushd packages/arm64
./build-arm64.sh
popd
chmod +x packages/ppc64/build-ppc64.sh
pushd packages/ppc64
./build-ppc64.sh
popd
