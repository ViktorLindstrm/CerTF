#!/usr/bin/env sh
#RootCA

openssl genrsa -out testCA.key 2048
openssl req -x509 -new -nodes -key testCA.key \
    -extensions v3_ca \
    -subj "/C=SE/ST=CA/O=TotalyLegitCompany/CN=testRootCA" \
    -sha256 -days 1024 -out testCA.crt
#Server
for i in $(seq 1 20); do
    echo $i
    Name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    Key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    openssl genrsa -out $Key.key 1024
    openssl req -new -sha256 \
        -key $Key.key \
        -subj "/C=US/ST=CA/O=CertForEveryone, Inc./CN=test.certf.org" \
        -extensions v3_req \
        -out $Name.csr 
    openssl x509 -req -extfile v3.ext -in $Name.csr -CA testCA.crt -CAkey testCA.key -CAcreateserial -out $Name.crt -days 500 -sha256
    rm $Name.csr
done

Name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
Key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
openssl genrsa -out $Key.key 1024
openssl req -new -sha256 \
    -key $Key.key \
    -subj "/C=US/ST=CA/O=CertForEveryone, Inc./CN=certf.org" \
    -extensions v3_req \
    -out $Name.csr 
openssl x509 -req -extfile v3.ext -in $Name.csr -CA ../ssl/rootCA.crt -CAkey ../rootCA.key -CAcreateserial -out $Name.crt -days 500 -sha256
rm $Name.csr

openssl x509 -pubkey -noout -in $Name.crt  > chal4_pubkey.pem
mv chal4_pubkey.pem ../ssl/chal4_pubkey.pem

cp $Name.crt ../ssl/chal4.crt

mkdir chal4
rm testCA.*
mv *.crt *.key chal4
tar cfz chal4.tar.gz chal4 
rm -r chal4 
