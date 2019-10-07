#!/usr/bin/env bash

#RootCA
openssl genrsa -des3 -out rootCA.key 4096

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt

openssl genrsa -out server.key 2048

openssl req -new -sha256 \
    -key server.key \
    -subj "/C=US/ST=CA/O=CertForEveryone, Inc./CN=CerTF{see_me_here}" \
    -out server.csr
    #-reqexts SAN \
    #-config <(cat /etc/ssl/openssl.cnf \
        #<(printf "\n[SAN]\nsubjectAltName=DNS:mydomain.com,DNS:www.mydomain.com")) \
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256
