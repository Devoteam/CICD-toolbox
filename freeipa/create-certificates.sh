#!/bin/bash

server=$1
domain=$server.tooling.test
commonname=$domain
password=netcicd
country=NL
state="Zuid Holland"
locality="Den Haag"
organization=Infraautomator
organizationalunit=IT-infra
email=netcicd@tooling.test

if [ -z "$server" ]
then
    echo "Argument not present."
    echo "Useage $0 [server name]"

    exit 99
fi

echo "Generating key request for $domain"

#Generate a key
openssl genrsa -des3 -passout pass:$password -out $domain.key 2048

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in $domain.key -passin pass:$password -out $domain.key

#Create the request
echo "Creating CSR"
openssl req -new -key $domain.key -out $domain.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

mv $domain.csr freeipa/certs/$domain.csr
mv $domain.key freeipa/certs/$domain.key