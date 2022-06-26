
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

