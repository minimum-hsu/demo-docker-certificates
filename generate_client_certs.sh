#!/bin/bash

set -e

# Generate client certificates
export ca_dir=./certs/demo.com
export certs=/home/$USER/.docker
rm -rf $certs
mkdir -p $certs
export tmp=`mktemp -d`
trap "rm -rf $tmp" EXIT
openssl genrsa -out $certs/key.pem 4096
openssl req -new -key $certs/key.pem -out $tmp/client.csr -subj "/CN=$(hostname)"
echo extendedKeyUsage = clientAuth > $tmp/extfile.cnf
openssl x509 -req -days 3650 -sha256 -in $tmp/client.csr -CA $ca_dir/ca.crt -CAkey $ca_dir/ca.key -CAcreateserial -out $certs/cert.pem -extfile $tmp/extfile.cnf
cp $ca_dir/ca.crt $certs/ca.pem

# Configurate Docker engine
set +e
chmod -v 0400 $certs/ca.pem $certs/key.pem $certs/cert.pem
export str="export DOCKER_HOST=tcp://127.0.0.1:2376 DOCKER_TLS_VERIFY=1"
grep "$str" /etc/profile
if [ $? = 0 ] ; then
  exit 0
fi
sudo echo "$str" >> /etc/profile
. /etc/profile
