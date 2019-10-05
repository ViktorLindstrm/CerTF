CerTF
=====
CerTF is a collection of a few small challenges to help and make it a little
fun to understanding of certifciates and how to read/create them.
Mainly focus is client authentication with certificates, although understanding
of PKI and 

More challenges are in planing, if you have an idea, put it as a issue here. 
Prettier and more info regarding challenges are also in the making. 

Some of the challenges are more "real" than other, little regard has been taken
to this to be "real" cases.

Challenges has flag format: certf{FLAG}

First
-----
The first challenge is a story of how to authenticate users. 
Client authentication without authenticating the validity of the certificate

Second
------
Pinning on the SKI might be a good idea.

SKI: AC:9E:B0:93:A6:F3:A7:03:44:0C:55:93:FB:ED:E5:78:D2:A5:CD:96

Build
-----
Create docker image with: 
```
docker build -t certf .         
```
Run the docker container with: 
```
docker run -d -p 4437:4437 certf
```
