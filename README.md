# postgresql-docker
Docker image for PostgreSQL
Installation using boot2docker

```
$ boot2docker init
Latest release for github.com/boot2docker/boot2docker is v1.7.0
Downloading boot2docker ISO image...
Success: downloaded https://github.com/boot2docker/boot2docker/releases/download/v1.7.0/boot2docker.iso
	to /Users/gogasca/.boot2docker/boot2docker.iso
Generating public/private rsa key pair.
Your identification has been saved in /Users/gogasca/.ssh/id_boot2docker.
Your public key has been saved in /Users/gogasca/.ssh/id_boot2docker.pub.
The key fingerprint is:
c7:26:42:1a:45:cd:5a:4a:b7:80:78:28:9f:be:5b:59 gogasca@gonzo.local
The key's randomart image is:
+--[ RSA 2048]----+
|   o ooo         |
|. o o.o =        |
| o o...* .       |
|  o  +o ..       |
| .  . E S +      |
|  .  o . +       |
|   .o            |
|  ..             |
|  ..             |
+-----------------+

$ boot2docker start
Waiting for VM and Docker daemon to start...
.........................oooooooooooooooooooooo
Started.
Writing /Users/gogasca/.boot2docker/certs/boot2docker-vm/ca.pem
Writing /Users/gogasca/.boot2docker/certs/boot2docker-vm/cert.pem
Writing /Users/gogasca/.boot2docker/certs/boot2docker-vm/key.pem

To connect the Docker client to the Docker daemon, please set:
    export DOCKER_HOST=tcp://192.168.59.103:2376
    export DOCKER_CERT_PATH=/Users/gogasca/.boot2docker/certs/boot2docker-vm
    export DOCKER_TLS_VERIFY=1


```
Reinstalling openssl and python in case you get certificate error

```
brew reinstall openssl python
pip install requests[security]
```

Obtain bootdocker ip

```
boot2docker ip
```

How to create a Docker image for PostgreSQL and persist data

http://www.andreagrandi.it/2015/02/21/how-to-create-a-docker-image-for-postgresql-and-persist-data/

```
CREATE DATABASE imbuedb WITH OWNER imbue ENCODING 'UTF8';
CREATE ROLE imbue superuser;  
ALTER ROLE imbue WITH LOGIN;
ALTER USER imbue WITH PASSWORD 'imbue';
ALTER DATABASE imbuedb OWNER TO imbue;
```

Drop database

```
DROP DATABASE "imbuedb";
```

Export database
```
pg_dump -U USERNAME DBNAME > dbexport.pgsql
```

Import database

```
psql -h 192.168.59.103 -p 5432 -U imbue imbuedb < imbuedb.db_010715 
```


