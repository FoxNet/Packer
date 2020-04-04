#!/bin/bash

echo -e "\nUploaded Files:"
find /tmp/hashicorp
sleep 1
echo -e

set -x
CONSUL_ZIP_URL="https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip"
CONSUL_CHECKSUM_URL="https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS"
CONSUL_TEMPLATE_ZIP_URL="https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip"
CONSUL_TEMPLATE_CHECKSUM_URL="https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS"
VAULT_ZIP_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_CHECKSUM_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS"
NOMAD_ZIP_URL="https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip"
NOMAD_CHECKSUM_URL="https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS"
set +x

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq upgrade
apt-get -qq install --no-install-recommends curl unzip jq dnsmasq

# Fetch Hashicorp signing key from Keybase
# https://keybase.io/docs/api/1.0/call/key/fetch - API Documentation
# curl -s "https://keybase.io/_/api/1.0/key/fetch.json?pgp_key_ids=${HASHICORP_KEY_ID}&ops=4" | \
#     jq -r '.keys[0].bundle' | \
#     gpg --import
curl -s https://keybase.io/hashicorp/pgp_keys.asc | gpg --import --quiet

mkdir fetch ; cd fetch
curl -s -O $CONSUL_ZIP_URL -O $CONSUL_CHECKSUM_URL -O $CONSUL_CHECKSUM_URL.sig
curl -s -O $CONSUL_TEMPLATE_ZIP_URL -O $CONSUL_TEMPLATE_CHECKSUM_URL -O $CONSUL_TEMPLATE_CHECKSUM_URL.sig
curl -s -O $VAULT_ZIP_URL -O $VAULT_CHECKSUM_URL -O $VAULT_CHECKSUM_URL.sig
curl -s -O $NOMAD_ZIP_URL -O $NOMAD_CHECKSUM_URL -O $NOMAD_CHECKSUM_URL.sig

echo -e "\nFetched files:"
ls -lh
sleep 1
echo -e

gpg --verify --quiet consul_${CONSUL_VERSION}_SHA256SUMS{.sig,} || \
     (echo "Could not verify signature of Consul archive!"; exit 1) || exit 1
gpg --verify --quiet consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS{.sig,} || \
     (echo "Could not verify signature of Consul-Template archive!"; exit 1) || exit 1
gpg --verify --quiet vault_${VAULT_VERSION}_SHA256SUMS{.sig,} || \
     (echo "Could not verify signature of Vault archive!"; exit 1) || exit 1
gpg --verify --quiet nomad_${NOMAD_VERSION}_SHA256SUMS{.sig,} || \
     (echo "Could not verify signature of Nomad archive!"; exit 1) || exit 1

sha256sum --check --ignore-missing consul_${CONSUL_VERSION}_SHA256SUMS || \
     (echo "Could not verify checksum of Consul archive!"; exit 1) || exit 1
sha256sum --check --ignore-missing consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS || \
     (echo "Could not verify checksum of Consul-Template archive!"; exit 1) || exit 1
sha256sum --check --ignore-missing vault_${VAULT_VERSION}_SHA256SUMS || \
     (echo "Could not verify checksum of Vault archive!"; exit 1) || exit 1
sha256sum --check --ignore-missing nomad_${NOMAD_VERSION}_SHA256SUMS || \
     (echo "Could not verify checksum of Nomad archive!"; exit 1) || exit 1

for file in *.zip
do
    unzip -d /usr/bin $file || (echo "Could not extract '$file'!"; exit 1) || exit 1
    rm -v ${file} ${file/linux_amd64.zip/SHA256SUMS}{,.sig}
done

for service in consul consul-template vault nomad
do
    useradd -r -U -d /var/lib/${service} ${service}
    chown ${service}:${service} /var/lib/${service}
done

mv -v /tmp/hashicorp/{consul,vault,nomad}.d /etc/
mv -v /tmp/hashicorp/systemd/*.service /etc/systemd/system


