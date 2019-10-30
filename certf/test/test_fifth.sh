cp ../apps/certf/priv/ssl/rootCA.crt ca.pem

openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key \
    -extensions v3_ca \
    -subj "/C=SE/ST=CA/O=CerTF{hidden_deep_within}/CN=RootCA" \
    -sha256 -days 1024 -out rootCA.crt

#Server
openssl genrsa -out key.pem 2048
openssl req -new -sha256 \
    -key key.pem \
    -subj "/C=US/ST=CA/O=Test/CN=fake.org" \
    -extensions v3_req \
    -out test.csr 
openssl x509 -req -in test.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out test.pem -days 500 -sha256

result=$(curl --cacert ca.pem https://certf.org:4437/fifth --cert test.pem --key key.pem)
rm  rootCA* test.csr test.pem key.pem 
echo $result


openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key \
    -extensions v3_ca \
    -subj "/C=SE/ST=CA/O=test/CN=RootCA" \
    -sha256 -days 1024 -out rootCA.crt

#Server
openssl genrsa -out key.pem 2048
openssl req -new -sha256 \
    -key key.pem \
    -subj "/C=US/ST=CA/O=Test/CN=Fake" \
    -extensions v3_req \
    -out test.csr 
openssl x509 -req -in test.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out test.pem -days 500 -sha256

result=$(curl --cacert ca.pem https://certf.org:4437/fifth --cert test.pem --key key.pem)
rm ca.pem rootCA* test.csr test.pem key.pem 
echo $result

