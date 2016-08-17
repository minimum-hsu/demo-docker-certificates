#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "Need ONE argument as domain name (ex. example.com)"
  exit 1;
fi

if [ -f config ] ; then
  . config
else
  export SUBJECT=/C=TW
fi

# Generate CA certificates
export certs=./$1
mkdir -p $certs
openssl genrsa -out $certs/ca.key 4096
openssl req -new -x509 -days 3650 -key $certs/ca.key -out $certs/ca.crt -subj "$SUBJECT"

