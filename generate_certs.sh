#/bin/sh

set -e

# Certificate data
export PUBLIC_IP=$(hostname -I | awk -F " " '{ print $1 }')
export DOMAIN=$(hostname)
export SUBJECT=/C=TW/ST=Taiwan/L=Taipei/O=Demo/OU=Demo
export SUBJECT_ALT_NAME=IP:$PUBLIC_IP,IP:127.0.0.1
if [ -n "$1" ] ; then
  export SUBJECT_ALT_NAME=$SUBJECT_ALT_NAME,IP:$1
fi

echo Domain is $DOMAIN
echo subjectAltName is $SUBJECT_ALT_NAME

# Generate server certificates
export ca_dir=./certs/demo.com
export certs=/var/lib/docker/certs
sudo mkdir -p $certs
export tmp=`mktemp -d`
trap "rm -rf $tmp" EXIT
sudo openssl genrsa -out $certs/server.key 4096
openssl req -new -key $certs/server.key -out $tmp/server.csr -subj "/CN=$DOMAIN$SUBJECT"
echo subjectAltName = $SUBJECT_ALT_NAME > $tmp/extfile.cnf
sudo openssl x509 -req -days 3650 -sha256 -in $tmp/server.csr -CA $ca_dir/ca.crt -CAkey $ca_dir/ca.key -CAcreateserial -out $certs/server.crt -extfile $tmp/extfile.cnf
sudo cp $ca_dir/ca.crt $certs/ca.crt

# Configurate Docker daemon
sudo mkdir -p /etc/docker
sudo cp ./daemon-tls.json /etc/docker/daemon.json

# Restart Docker daemon
sudo service docker restart
