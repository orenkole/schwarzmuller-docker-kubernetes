
## Docker setup overview
Linux operating systems natively support containers
![img.png](notes-images/docker-setup-overview-1.png)

## An overview of docker tools

![img.png](notes-images/overview-of-docker-tools-1.png)

## Getting our hands dirty
launch docker daemon

_Dockerfile_
```dockerfile
FROM node:14

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.mjs"]
```

_app.mjs_
```javascript
import express from 'express'
import connectToDatabase from "./helpers.mjs"

const app = express()

app.get('/', (req, res) => {
    res.send('<h2>Hi there</h2>')
})

await connectToDatabase()

app.listen(3000);
```

don't `npm i`  
do:
`
docker build .
docker run -p 3000:3000 <image id>`  (command)
`-p` - publish port
![img.png](gettings-our-hands-dirty-1.png)

`docker ps` - list containers (command)
`docker stop <image name>` - stop container (command)

## Course outline

![img.png](notes-images/course-outline-1.png)

## Images & Containers: What and Why?

*Container* small packages contain application and entire environment.
It runs code

*Image* contains code and tools to execute code

![img.png](notes-images/images-and -containers-1.png)

_Image_ is a template and _container_ is a running instance of image
![img.png](notes-images/images-and -containers-2.png)

## Using & Running External (Pre-Built) Images
https://hub.docker.com/_/node
`docker run node` - will utilize _node_ image to run container based on this image (command)
![img.png](notes-images/using-&-running-external-images-1.png)

`docker ps -a` show all containers

`docker run -it node` - expose containers terminal (command)
`-it` - interactive mode - expose containers mode

## Building our own Image with a Dockerfile
```dockerfile
COPY . /app
```
first `.` - path to copy from starting from location of Dockerfile
second `/app` - where to store inside image

---
by default commands run from root folder of the image
We have to specify _WORKDIR_ - set where commands should run from. All subsequent commands will be executed from inside specified path
```dockerfile
WORKDIR /app
RUN npm install
```

Also, since we changed our working directory, we can copy to /app by:
```dockerfile
COPY . ./
```
here second `.` is now `/app`.
This is equivalent to specifying absolute path:
```dockerfile
COPY . /app
```
It's better to use absolute paths

---
_RUN_ - commands to create an image
_CMD_ - commands to start in the container

_CMD_ - execute command when the container is started

If we don't specify _CMD_ , the _CMD_ of base image will be executed. If not _CMD_ in base image, we get an error

---

Container is isolated from our local machine
We must explicitly expose

_Dockerfile_ (all)
```dockerfile
FROM node

WORKDIR /app

COPY . /app

RUN npm install

EXPOSE 80

CMD ["node", "server.js"]
```

## Running a Container based on our own Image
Build and run:
`docker build .` - create image based on Dockerfile (command)
`docker run <image id>`

stop container:
`docker ps
docker stop <image name>`

`docker ps -a` - see all containers

---
```dockerfile
EXPOSE 80
```
Just tells which port should be exposed

To be able to access port, we must use flag `-p` in console
`docker run -p 3000:80 <image name>`

## Images are read-only
When we change code form which we build image, we must build a completely new image
`docker build .`

## Understanding image layers
Every instruction creates layer
Only commands which have changes due to changes are executed, all previous steps in Dockerfile skipped, They are cached

Optimization: 
copy package.json => install => copy rest of code

```dockerfile
FROM node

WORKDIR /app

COPY package.json /app

RUN npm install

COPY . /app

EXPOSE 80

CMD ["node", "server.js"]
```

## Managing images and containers

![img.png](notes-images/miac-1.png)

`docker --help`\
`--help` - see help on command\

## Stopping & restarting containers
`docker run <image name>` - running new container\
`docker stop <container name>`\
`docker start <container name>` - reuse already built container

## Understanding Attached & Detached Containers
(commands):
`docker start <container name>` - start already existing container in _detached_ mode  
`docker attach <container name>` - attach already existing and running container

`docker run -p 3000:80 <image name>` - start new container in _attached_ mode  
`docker run -p 3000:80 -d <image name>` - start new container in _detached_ mode  
_attached_ mode - we listen to the output of the container, we see logs of container in real time

`docker logs <container name>` - see containers previous logs
`docker logs -f <container name>` - see containers logs in real time
`-f` - follow mode

`docker start -a <container name>` - start container in attached mode

## Entering interactive mode
```python
from random import randint

min_number = int(input('Please enter the min number:'))
max_number = int(input('Please enter the max number:'))

if(max_number < min_number):
  print('Invalid input')
else:
  rnd_number = randint(min_number, max_number)
  print(rnd_number)
```

```dockerfile
FROM python
WORKDIR /app
COPY . /app
CMD ["python", "rng.py"]
```
`docker run build .`
We can't input into container, we're not in interactive mode:
![img.png](eim-1.png)

`docker run --help`
`-i` - interactive mode. Container will listen to input
`-t` - allocate pseudo TTY. Container will provide input

`docker run -it <image id>`

---
To start a container that we can type to container's input, we can start in _attached_ mode
`docker start -a <container name>`  
Behavior is strange: we can input only once

We need `-i` because of interactive mode
`docker start -ai <container name>`

## Deleting Images & Containers
`docker ps -a` - list all containers
`docker rm <container name>` - remove container (can remove only stopped container)
`docker container prune` - remove all stopped containers
`docker images` - list all images
`docker rmi <image id>` - remove image. Can be removed only if not use by any container (including stopped containers)
`docker image prune -a` - remove all unused images


