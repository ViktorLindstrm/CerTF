#!/usr/bin/env sh

#RootCA
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key \
    -extensions v3_ca \
    -subj "/C=SE/ST=CA/O=CerTF{hidden_deep_within}/CN=RootCA" \
    -sha256 -days 1024 -out rootCA.crt

#Server
openssl genrsa -out server.key 2048
openssl req -new -sha256 \
    -key server.key \
    -subj "/C=US/ST=CA/O=CertForEveryone, Inc./CN=certf.org" \
    -extensions v3_req \
    -out server.csr 
openssl x509 -req -extfile v3.ext -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256

#client expired (chal 3)
openssl genrsa -out consult.key 2048
openssl req -new -sha256 \
    -key consult.key \
    -subj "/C=US/ST=CA/O=SecretConsultants, Inc./CN=johnny" \
    -out consult.csr
openssl x509 -req -extfile v3.ext -in consult.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out consult.crt -days 500 -sha256

rm consult.key 
rm *.csr
mkdir ssl
mv rootCA.crt ssl
mv server.crt server.key ssl
mv consult.crt ssl

