#!/bin/sh

build_root=$PWD
echo "Build Root: ${build_root}"

cd workspace-repo

apt update
apt install -y libssl-dev
apt install -y libpcre3-dev
apt install -y automake
apt install -y checkinstall

./bootstrap.sh
builddate=$(date --utc +%Y-%m-%d)

./configure \
        --bindir=/usr/bin \
        --sbindir=/usr/sbin \
        --datadir=/usr/lib \
        --libdir=/usr/lib/ \
        --sysconfdir=/etc/ \
        --program-prefix=yen- \
        --program-suffix=-$builddate \
        --with-openssl \
        --enable-agent

make
VERSION=$(date -u +"%Y%m%d%H%S")
echo $VERSION

cat <<EOF > description-pak
EOF

cat <<'EOF' > preinstall-pak
EOF

cat preinstall-pak

cat <<'EOF' > postinstall-pak
EOF

cat postinstall-pak

cat <<'EOF' > preremove-pak
EOF

cat preremove-pak

cat <<'EOF' > postremove-pak
EOF

cat postremove-pak

checkinstall \
        --install=no \
        --fstrans=no \
        --pkgname=test-agent \
        --pkgversion="$VERSION" \
        --requires="adduser" \
        --docdir="/usr/share/doc" \
        --default


mkdir test-agent_$VERSION-1_amd64
dpkg-deb -R test-agent_$VERSION-1_amd64.deb test-agent_$VERSION-1_amd64

cd test-agent_$VERSION-1_amd64

mkdir -p lib/systemd/system
cd lib/systemd/system

cat <<EOF > test-agent.service
[Unit]
Description=Test Agent
Documentation=man:test_agentd
After=network.target

[Service]
Type=simple
User=test
Group=test
ExecStart=/usr/sbin/yen-test_agentd-$builddate --foreground
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

cd ../../../..
mv test-agent_$VERSION-1_amd64.deb test-agent_$VERSION-1_amd64.deb.old
dpkg-deb --build test-agent_$VERSION-1_amd64
