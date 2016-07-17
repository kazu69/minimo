minimo example
--------------

First you prepare the docker machine.

https://docs.docker.com/machine/

Then prepare the environment in the docker machine.

```sh
# if not create local vm
docker-machine create -d virtulbox YOUR-VM

# if you have local vm
docker-machine start YOUR-VM

# expose path
dm env YOUR-VM
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/YOU/.docker/machine/machines/YOUR-VM"
export DOCKER_MACHINE_NAME="YOUR-VM"
# Run this command to configure your shell:
# eval $(docker-machine env YOUR-VM)

eval $(docker-machine env YOUR-VM)
```

Local vertual machine name and described in the case of a ```dev```.

```sh
# docker container start
docker build -t minimo .
docker run -p 8080:8080 -d -t minimo
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
7c0ff00246bd        minimo              "bundle exec ruby ini"   4 seconds ago       Up 3 seconds        0.0.0.0:8080->8080/tcp   amazing_kirch

# request to minimo
# HEAD request
curl -I http://$(docker-machine ip dev):8080/example/test
HTTP/1.1 200 OK
Vary: Accept-Encoding
Content-Type: application/json; charset=utf-8
Content-Length: 30
Server: WEBrick/1.3.1 (Ruby/2.3.0/2015-12-25)
Date: Sun, 17 Jul 2016 08:09:44 GMT
Connection: Keep-Alive
# GET request
curl http://$(docker-machine ip dev):8080/example/test
{
    "greet": "hello world"
}%
```
