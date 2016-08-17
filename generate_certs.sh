#/bin/sh

set -e

# Certificate data
export PUBLIC_IP=$(hostname -I | awk -F " " '{ print $1 }')
export DOMAIN=$(hostname)
export SUBJECT=/C=TW/ST=Taiwan/L=Taipei/O=Demo/OU=Demo
export SUBJECT_ALT_NAME=IP:$PUBLIC_IP,IP:127.0.0.1
if [ -n $1 ] ; then
  export SUBJECT_ALT_NAME=$SUBJECT_ALT_NAME,IP:$1
fi

echo Domain is $DOMAIN
echo subjectAltName is $SUBJECT_ALT_NAME

# Generate server certificates
export ca_dir=./certs/demo.com
export certs=/var/lib/docker/certs
mkdir -p $certs
export tmp=`mktemp -d`
trap "rm -rf $tmp" EXIT
openssl genrsa -out $certs/server.key 4096
openssl req -new -key $certs/server.key -out $tmp/server.csr -subj "/CN=$DOMAIN$SUBJECT"
echo subjectAltName = $SUBJECT_ALT_NAME > $tmp/extfile.cnf
openssl x509 -req -days 3650 -sha256 -in $tmp/server.csr -CA $ca_dir/ca.crt -CAkey $ca_dir/ca.key -CAcreateserial -out $certs/server.crt -extfile $tmp/extfile.cnf
cp $ca_dir/ca.crt $certs/ca.crt

# Configurate Docker daemon
mkdir -p /etc/docker
cp ./daemon.json /etc/docker/daemon.json

# Restart Docker daemon
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

