![](https://github.com/ViktorLindstrm/CerTF/workflows/Erlang%20CI/badge.svg)

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


The host is now running at port 4437, on localhost.
To minimize issues and faults, make sure to set 127.0.0.1 in the hosts-file to certf.org
i.e. /etc/hosts
```
...
127.0.0.1   certf.org
...
```


now you are all set, visit:
```
https://certf.org:4437
```
