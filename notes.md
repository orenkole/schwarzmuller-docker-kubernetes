
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
![img.png](notes-images/gettings-our-hands-dirty-1.png)

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
![img.png](notes-images/eim-1.png)

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

## Removing stopped containers automatically
`docker run -p 3000:80 -d --rm <image name>`
`--rm` - remove container once stopped

## A Look Behind the Scenes: Inspecting Images
`docker image inspect <image id>`

## Copying Files Into & From A Container
Copy files between containers and localhost
copy files into a running container 
`cp <path copy from> <container name>:/<path to copy to>`
Might be useful for configuration files

or out of container
`cp <container name>:/<path to copy to> <path copy from>`
Might be useful for log files

## Naming & Tagging Containers and Images
`docker run --help`
`--name`
`docker run -p 3000:80 -d --rm --name <container name> <image id>`

`docker run -p 3000:80 -d --rm --name goalsapp vds897v9f8sd`
now we can use name:
`docker start goalsapp`

---
name for images are tags:
`name:tag`
`docker build -t <name>:<tag> .`

![img.png](notes-images/ntcai-1.png)
`docker build -t goals:latest .`

## Sharing images: overview
![img.png](notes-images/sio-1.png)  

## Pushing images to dockerhub
![img.png](notes-images/pitd-1.png)
https://hub.docker.com/
create repository

give local image a name:
1) or build image again with given tag
2) we can make clone of existing image:
`docker tag <image name|id> <new image name (same as repository name)>`
   
login to repository:
`docker login --usernma <docker username>`

push to repository
`docker push <new image name>`

## Pulling & Using Shared Images
Pull latest image
`docker pull <image name>`

If image doesn't exist locally, it will be downloaded:
`docker run <image name>`

## Module summary

![img.png](notes-images/ms-1.png)
![img.png](notes-images/ms-2.png)
https://dockerlabs.collabnix.com/docker/cheatsheet/

## Module introduction
- understanding different kinds of data
- images, containers & volumes
- using arguments & environment variables

## Understanding Data Categories / Different Kinds of Data

![img.png](notes-images/understanding-data-1.png)

add new project _data_volumes_

## Building & Understanding the Demo App

```dockerfile
FROM node:14
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
EXPOSE 80
CMD ["node", "server.js"]
```
build image:
`docker build -t feedback-node .` -

run container:
`docker run feedback-node -p 3000:80 -d --name feedback-app --rm feedback-node`

go to localhost:3000
localhost:3000/feedback/<title>.html - see feedback

## Understanding the Problem

`docker stop feedback-app` when with `--rm`, we must recreate container and our file 'awesome.txt' is deleted  

We start new container without `--rm`:
`docker run feedback-node -p 3000:80 -d --name feedback-app feedback-node`
When stopping container without `--rm` the file is not deleted

Containers built on the same image are isolated from each other
We have to save data in such a way that it survived container deletion

## Introducing volumes

Volumes are folders not in the container but on the host machine which are mapped into containers (mounted)  
It's a two direction connection 
Volumes allow to persist data when container is removed  

## A First, Unsuccessful Try

In our app _feedback_ folder we want to persist  
Add instruction:
```dockerfile
VOLUME ["/app/feedback"]
```

`docker buid -t feedback-node:volumes .`
`docker run -d -p 3000:80 --rm --name feedback-app feedback-node:volumes`

---

Try to create feedback and we see error: _cross device link is not permitted_
This is because of `fs.rename` method because of `VOLUME` in docker will move the file outside or the container  
We can replace to
```javascript
await fs.copyFile(tempFilePath, finalFilePath);
await fs.unlink(tempFilePath);
```
Now we must delete our image and rebuild it
`docker rmi feedback-node:volumes`
`docker build -t feedback-node:volumes .`

create container with `--rm`
`docker run -d -p 3000:80 --rm --name feedback-app feedback-node:volumes`
Still data is not persisted for different containers


## Named Volumes To The Rescue!

List volumes
`docker volume ls`
![img.png](notes-images/named-volumes-1.png)
Anonymous volumes exist as long as a container exists
We'll come back later where anonymous volumes can be helpful
For now we'll checkout _named_volumes_

Named volumes survive container remove

We don't create named volumes in Dockerfile

We create them in console while creating container
Remove `VOLUME` from Dockerfile

Create container with named volume `-v feedback:/app/feedback`  
Named volumes are not deleted when the container shuts down  
create new image:
`docker rmi feedback-node:volumes`
`docker build -t feedback-node:volumes .`
`docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback feedback-node:volumes`

After this if we create new container with the same volume name, data will persist after new container creation with the same volume name

---

Note: we don't know path to volumes on our machine  
## Getting Started With Bind Mounts (Code Sharing)

Problem: Changes on our source code are note reflected in running container. We must rebuild image

![img.png](notes-images/bind-mount-1.png)
For bind mounts we define the path on our host machine. To do so, we need second `-v` flag:
`docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app" feedback-node:volumes`

And make sure folder is accessible by docker
![img.png](notes-images/bind-mount-2.png)

But we see that container is immediately stopped (run without `--rm`)
`docker logs feedback-app`
![img.png](notes-images/bind-mount-3.png)

## Combining & Merging Different Volumes
Problem with uninstalled packeges:
1) we execute Dockerfile and install dependencies
2) our bind mount replaces all content of image with our local content without installed depenedencies

We need to tell docker some parts should not be overwritten

Solution add another anonymous volume (without `:`) to cli:
`docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app" -v /app/node_modules feedback-node:volumes`

Here the more specific path `/app/node_modules` of 3rd -v wins over `/app` of 2nd -v

Now recreate container and now if we change source code and reload page, we cen see changes on our web page without rebuilding image  

## A NodeJS-specific Adjustment: Using Nodemon in a Container

_package.jsons_
```json
"scripts": {
  "start": "nodemon server.js"
},
"devDependencies": {
  "nodemon": "2.0.4"
}
```

_Dockerfile_
```javascript
CMD ["npm", "start"]
```

recreate container:
`docker rm feedback-app`
`docker rmi feedback-node:volumes`
`docker build -t feedback-node:volumes .`
`docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app" -v /app/node_modules feedback-node:volumes`

Now server should restart automatically whenever we change our source code for server

---

Note: for windows there it is not working like this

## Volumes & bind mounts: overview

![img.png](notes-images/volumes_&_bind_mounts-1.png)
![img.png](notes-images/volumes_&_bind_mounts-2.png)

## A Look at Read-Only Volumes
add `:ro`, `-v /app/temp` - to be able to write to /temp
`docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app:ro" -v /app/temp -v /app/node_modules feedback-node:volumes`

## Managing Docker Volumes

List volumes:
`docker volume ls`

We can create volume and use it in our subesequently created container:
`docker volume create feedback-filed`

Inspect volume 
`docker volume inspect feedback`

Delete unused volume in running container:
`docker volume rm feedback-files`

Remove all unused volumes:
`docker volume prune`

Anonymous volumes are removed if their container is removed

## Using "COPY" vs Bind Mounts

We bind mount during development to reflect our changes instantly

On the production server there is no connected source code that updates while it running  
That's why we create snapshot containers of our code with:
```dockerfile
COPY . .
```

## Don't COPY Everything: Using "dockerignore" Files
_.dockerignore_  
`node_modules`  

## Working with Environment Variables & ".env" Files

![img.png](notes-images/working-with-environment-1.png)

_server.js_  
```javascript
app.listen(process.env.PORT);
```

_Dockerfile_
```dockerfile
ENV PORT 80
EXPOSE $PORT
```

`docker build feedback-node:env .`
`docker run -d -p 3000:80 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app:ro" -v /app/temp -v /app/node_modules feedback-node:env`

Advantage:
This is default value:
```dockerfile
ENV PORT 80
```

We can run container with different value `--env PORT=8000` (also expose internal port `3000:8000`)
`docker run -d -p 3000:8000 --env PORT=8000 --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app:ro" -v /app/temp -v /app/node_modules feedback-node:env`

`-e` is equal to `--env`

---

Using file for environment variable `--env-file .env`:
_.env_  
```dockerfile
PORT=8000
```

`docker run -d -p 3000:8000 --env-file .env --rm --name feedback-app -v feedback:/app/feedback -v "/Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/data-volumes:/app:ro" -v /app/temp -v /app/node_modules feedback-node:env`

## Using Build Arguments (ARG)

If we want to make
```dockerfile
ENV PORT 80
```
flexible as well so that we can change default port during building image

```dockerfile
ARG DEFAULT_PORT=80
...
ENV PORT $DEFAULT_PORT
```
value of _ARG_ can be used only inside Dockerfile, but not on all commands (can't use on _CMD_)

Build two images with different args:
`docker build -t feedback-node:web-app .`
`docker built -t feedback-node:dev --build-arg DEFAULT_PORT=8000 .`

---

Good to place ARG after `RUN npm install`

## Module summary

![img.png](notes-images/ms-volumes-1.png)


## Case 1: Container to WWW Communication
request to swapi
## Case 2: Container to Local Host Machine Communication

## Case 3: Container to Container Communication

## Creating a Container & Communicating to the Web (WWW)
Note: mongodb is not a part of container
`docker build -t favorites-node .`
`docker run --name favorites --rm -p 3000:3000 favorites-node`
Error: unable to connect to mongodb running on local machine (Max installed and ran)  

![img.png](notes-images/www-1.png)

On the other hand, we can send requests to external apis  
**Out of the box containers can send requests to www**

## Making Container to Host Communication Work
replace `localhost` with `host.docker.internal` to be able to send requests from container to our host machine
```javascript
mongoose.connect(
    'mongodb://host.docker.internal:27017/swfavorites',
```

## Container to Container Communication: A Basic Solution
`docker run -d --name mongodb mongo`
We'll pull official image from dockerhub

`docker container inspect mongodb`
"Ports": {
"27017/tcp": null
},
"IPAddress": "172.17.0.2",

_app.js_
```javascript
mongoose.connect(
  'mongodb://172.17.0.2:27017/swfavorites',
```

rebuild image
`docker build -t favorites-node .`

run containers
`docker run --name favorites -d --rm -p 3000:3000 favorites-node`

we'll get 2 running containers
![img.png](notes-images/www-2.png)

send request to localhost:3000/favorites
and we'll get our favorites array

Problem: we have to look up the ip address and hardcode it

## Introducing Docker Networks: Elegant Container to Container Communication

We can put containers in the same network:
![img_2.png](notes-images/docker-network-1.png)

First we have to create network
Create network (command):
`docker network create <network name>`
run: 
`docker network create favorites-net`

list networks:
`docker network ls`

recreate mongodb container:
`docker run -d --name mongodb --network favorites-net mongo`

Containers from the same network are able to communicate by name
Now we can put container's name in place of localhost
```javascript
mongoose.connect(
  'mongodb://mongodb:27017/swfavorites',
```
Rebuild image:
`docker build -t favorites-node .`
Start our app's container:
` docker run --name favorites --network favorites-net -d --rm -p 3000:3000 favorites-node`

---
![img.png](notes-images/docker-network-2.png)

---

Note: for mongodb we didn't write PORT because it's necessary outside the network

## How Docker Resolves IP Addresses

## Our Target App & Setup
![img.png](notes-images/our_targe_app_setup-1.png)

## Dockerizing the MongoDB Service
`docker contianers prune`
`docker run --name mongodb --rm -d -p 27017:27017 mongo`

Now we are able to connect to mongodb like from node app

## Dockerizing the Node App

_Dockerfile_
```dockerfile
FROM node
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 80
CMD ["node", "app.js"]
```
`docker build -t goals-node .`
`docker run --name goals-backend --rm goals-node`
 
change `localhost` to `host.docker.internal`
_app.js_
```javascript
mongoose.connect(
  'mongodb://host.docker.internal:27017/course-goals',
  
```

---

Our frontend cannot connect to backed because `EXPOSE 80` is not enough
we need `-p 80:80` too
`docker stoop goals-node`
`docker run --name goals-backend --rm -d -p 80:80 goals-node`

Now our frontend is able to query backend

## Moving the React SPA into a Container
_/fronend/Dockerfile_
```dockerfile
FROM node
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```
`docker build -t goals-react .`
`docker run --name goals-frontend --rm -d -p 3000:3000 goals-react`

Our container stopping immediately after start
We need to run it in interactive mode with `-it` to tell there will be some interaction
`docker run --name goals-frontend --rm -p 3000:3000 -it goals-react`

---

For now our containers are able to communicate because we showed their ports `-p`
We'll put them all in one network

---

`docker stop goals-frontend`
`docker stop goals-node`
`docker stop mongodb`

## Adding Docker Networks for Efficient Cross-Container Communication
`docker network create goals-network`

now start containers without `-p`
`docker run --name mongodb --rm -d --network goals-network mongo`

For backend container make some changes:
```javascript
mongoose.connect(
  'mongodb://host.docker.internal:27017/course-goals',
```
to using name of container `mongodb`:
```javascript
mongoose.connect(
  'mongodb://mongodb:27017/course-goals',
```
because now we don't expose port, but run in network 
rebuild image:
`docker build -t goals-node .`
`docker run --name goals-backend --rm -d --network goals-network goals-node`

For frontend we also need to rename host:
```javascript
const response = await fetch('http://localhost/goals');
```
to:
```javascript
const response = await fetch('http://goals-backend/goals');
```
rebuild image:

`docker run --name goals-frontend --rm -d --network goals-network -p 3000:3000 -it goals-react`

![img.png](adding-docker-network-1.png)

This is because our code runs in the browser and browser doesn't know about `http://goals-backend/goals`
We must return to `localhost` and to ensure that endpoints can be reached
We need to publish PORT 80 on backend application. 

`goals stop fronend`
`docker run --name goals-frontend --rm -d -p 3000:3000 -it goals-react`
note: here we don't set _network_ becuase it is not in docker invironment

Restart backend container with `network` to communicate to mongodb and with published port  `-p` for frontedn to be able to send requests
`docker run --name goals-backend --rm -d -p 80:80 --network goals-network goals-node`

## Adding Data Persistence to MongoDB with Volumes
For now if we stop `docker stop mongodb` the data is lost

See documentation

https://hub.docker.com/_/mongo (Where to Store Data)
`data` - give a name to a created named volume (we don't know where it is on our host machine), `/data/db` - path inside container to database  
`-v data:/data/db`  

`docker stop mongodb`
`docker run --name mongodb -v data:/data/db --rm -d -network goals-network mongo`

Now data survives mongodb container stop

---

Authentication (https://hub.docker.com/_/mongo)
image also supports `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD`for creating a simple user with the role root in the admin authentication database, as described in the Environment Variables section above.

`docker run --name mongodb -v data:/data/db --rm -d --network goals-network -e MONGO_INITDB_ROOT_USERNAME=max -e MONGO_INITDB_ROOT_PASSWORD=secret mongo`
    
Now in backend container we must use login and password
_/backend/app.js_
```javascript
mongoose.connect(
  'mongodb://max:secret@mongodb:27017/course-goals?authSource=admin',
```
`docker stop goals-backend`
`docker build -t goals-node .`
`docker run --name goals-backend --rm -p 80:80 --network goals-network goals-node`  

Problem occured: https://www.udemy.com/course/docker-kubernetes-the-practical-guide/learn/lecture/22626647/#questions/13014650
Solution: delete old volume

terminal: `CONNECTED TO MONGODB`

## Volumes, Bind Mounts & Polishing for the NodeJS Container
We want:
- our logs to persist 
- our source code updates live  

`-v logs:/app/logs` For logs we'll use named volumes - thus, we won't have easy access to log data like with _binded mount_  

`-v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/backend:/app`
For source code we'll use _bind mount_ for live updates  

`-v /app/node_modules` We have to ensure that _node_modules_ in our container is not erased because we don't have _node_modules_ in our host machine, so it's path must be more specific  

`docker run --name goals-backend -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/backend:/app -v logs:/app/logs -v /app/node_modules -d --rm -p 80:80 --network goals-network goals-node`

---

Add nodemon to update code live
- Delete package.lock.json in /backend

_/backend/package.json
```json
"scripts": {
  "start": "nodemon app.js"
}
"devDependencies": {
  "nodemon": "^2.0.4"
}
```
_Dockerfile_
```dockerfile
CMD ["node", "app.js"]
```
change to:
```dockerfile
CMD ["npm", "start"]
```

`docker stop goals-backend`
`docker build -t goals-node .`
`docker run --name goals-backend -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/backend:/app -v logs:/app/logs -v /app/node_modules -d --rm -p 80:80 --network goals-network goals-node`

Now we have live updates:
_/backend/app.js_
```javascript
      console.log('CONNECTED TO MONGODB!!');
```
`docker logs goals-backend`

---

Move environment variables for mongodb login and password to docker file
_/backend/Dockerfile_
```dockerfile
ENV MONGODB_USERNAME=root
ENV MONGODB_PASSWORD=secret
```

_app.js_
```javascript
mongoose.connect(
  `mongodb://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@mongodb:27017/course-goals?authSource=admin`,
```
`docker built -t goals-node .`
`docker stop goals-backend`

The default values for `MONGODB_USERNAME` will not work, because these are not what we set in mongodb.
`docker run --name mongodb -v data:/data/db --rm -d --network goals-network -e MONGO_INITDB_ROOT_USERNAME=max -e MONGO_INITDB_ROOT_PASSWORD=secret mongo`
We should add environment variable in our command
`docker run --name goals-backend -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/backend:/app -v logs:/app/logs -v /app/node_modules -e MONGODB_USERNAME=max -d --rm -p 80:80 --network goals-network goals-node`

cli message:
`CONNECTED TO MONGODB!!`

---

add dockerignore
_.dockerignore_
```
node_modules
Dockerfile
.git
```

## Live Source Code Updates for the React Container (with Bind Mounts)
We'll use bind mount

`docker run -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/frontend/src/app/src --name goals-frontend --rm -d -p 3000:3000 -it goals-react`
We don't need nodemon - react is already configured to hot reload
----

Note: windows users need to use linux file system

---

Add dockerignore:
```
node_modules
.git
Dockerfile
```

## Module Summary
Problems: 
- we have very long docker run commands
- project optimized for development

# Section 6. Docker Composer: elegant multi-container orchestration

## Module Introduction
Problem: we have very long docker run commands

![img.png](notes-images/6-module-introduction-1.png)

Solution: docker-compose

## Docker-Compose: What & Why?

![img.png](notes-images/6-docker-compose-what-1.png)
![img.png](notes-images/6-docker-compose-what-2.png)
![img.png](notes-images/6-docker-compose-what-3.png)

## Creating a Compose File

`version` - docker compose specification version. docker copose is in active development

https://docs.docker.com/compose/compose-file/compose-versioning/#compatibility-matrix

`services` - needs at least 1 children. List of containers. To label containers we can choose at our choice

## Diving into the Compose File Configuration

Our run command was:
```
docker run \  
    --name mongodb  \  
    -v data:/data/db  \  
    --rm  \  
    -d \  
    --network goals-network \  
    -e MONGO_INITDB_ROOT_USERNAME=max \  
    -e MONGO_INITDB_ROOT_PASSWORD=secret \  
    mongo
```  

`mongo` =>  `image: mongo` - could be an image, URL of image in repository  
`--rm` -By default when we use compose, service is removed when shuted down, so we don't need

`-v data:/data/db`
=>
```yml
    volumes:
      - data:/data/db
```

```yml
    -e MONGO_INITDB_ROOT_USERNAME=max \  
    -e MONGO_INITDB_ROOT_PASSWORD=secret \ 
```
=>
```yml
    environment:
      MONGO_INITDB_ROOT_USERNAME: max
      MONGO_INITDB_ROOT_PASSWORD: secret
```
note: `:` creates yml object, and since, we don't need `-` in front of the line  
or
```yml
    environment:
      - MONGO_INITDB_ROOT_USERNAME=max
      - MONGO_INITDB_ROOT_PASSWORD=secret
```
or
_/env/mongo.env_
```yml
MONGO_INITDB_ROOT_USERNAME=max
MONGO_INITDB_ROOT_PASSWORD=secret
```
```yml
    env_file:
      - ./env/mongo.env
```

`--network goals-network`
=>
```yml
    networks: 
      - goals-network
```
We can specify network, but we don't need to do this, because out of the box composer creates new environment for all services listed
It will add all services to this network out of the box

For **named volumes** we need to add a section for volumes.  
Without any value.  
Such named volumes can be shared between services.  
Unnamed volumes and bind mounts shouldn't be listed in `volumes`  

Now we have composer for mongodb:  
_docker-compose.yml_
```yml
version: "3.8"
services:
  mongodb:
    image: 'mongo'
    volumes:
      - data:/data/db
#    environment:
#      MONGO_INITDB_ROOT_USERNAME: max
#      MONGO_INITDB_ROOT_PASSWORD: secret
    env_file:
      - ./env/mongo.env
#  backend:
#  frontend:

volumes:
  data:
```

## Docker Compose Up & Down
Command to pull and build images that are required and start all services (containers):
`docker-compose up`  

Check:  
remove all images  
`docker image prune -a`
stop all containers  
`docker kill $(docker ps -q)`  
delete all containers:  
`docker container prune`  

`docker-compose up` by default starts in attached mode  
`docker-compose up -d` - start in detached mode  

Stop all containers, remove all containers and so on (command):  
```
docker-compose down
```

Note: it doesn't remove volumes. To remove volumes add `-v`:  
```
docker-compose down -v
```

## Working with Multiple Containers
We can specify image if we have one:  
```yml
    image: 'goals-node'
```

or if we don't have one, we specify how to build image:  
Tell where is the docker file needed:  
```yml
    build: ./backend
```
or variant with more options:
```yml
  backend:
    context: ./backend
    dockerfile: Dockerfile
    args:
      some-arg: 1
```
`context` - is a path to where the image will be generated - sould be set to a folder which includes everything the Dockerfile might be referring to:
![img.png](notes-images/6_working_with_multiple_containers-1.png)

---

Our command:
```
docker run \  
 --name goals-backend \  
  -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/backend:/app \  
  -v logs:/app/logs \  
  -v /app/node_modules \  
  -e MONGODB_USERNAME=max \  
  -e MONGODB_PASSWORD=secret \
  -d \  
  --rm \  
  -p 80:80 \  
  --network goals-network \  
  goals-node
```
`-d`, `--rm`, `-network` are configured by default  

Named volumes:  
Name volumes `-v logs:/app/logs` must be specified also in `volumes` section of docker-compose.yml:  
```yml
services:
#  ...
  backend:
#    ...
      - '80:80'
    volumes:
      - logs:/app/logs

volumes:
  logs:
```

Bind mount:  
In docker-compose.yml we are allowed instead of absolute path to use relative path to _docker-compose.yml_ file
`-v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/backend:/app`
=> 
```yml
    volumes:
      - ./backend:/app
```

Anonymous volumes:  
just add to a list:
```yml
    volumes:
#     ...
      - /app/node_modules
```

Environment variables:  
```yaml
    env_file:
      - ./env/backend.env
```

`depends_on` - list of containers current container depends on

_docker_compose.yml_ (backend part)
```yml
version: "3.8"
services:
# ...
  backend:
    build: ./backend
    ports:
      - '80:80'
    volumes:
      - logs:/app/logs
      - ./backend:/app
      - /app/node_modules
    env_file:
      - ./env/backend.env
    depends_on:
      - mongodb

volumes:
# ...
  logs:
```

`docker-compose up`
![img.png](notes-images/working_with_multiple_containers_1.png)

Note: composer named our containers _docker-complete-backend-1_ and _docker-complete-mongodb-1_
But we still can reference our containers as they are named in _docker-compose.yml_ file:
`mongodb:27017`  
```javascript
mongoose.connect(
  `mongodb://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@mongodb:27017/course-goals?authSource=admin`,
```
These _service_ names are the names we can use to send requests and to leverage the network docker-compose creates for us.  

---

`docker compose down`

## Adding Another Container

```
docker run \  
    -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/docker-complete/frontend/src/app/src \  
    --name goals-frontend \  
    --rm \  
    -d \  
    -p 3000:3000 \  
    -it \  
    goals-react
```

`-it` means:
- i - open input connection  
- t - attach terminal  
=>
```yml
  stdin_open: true
  tty: true
```
Frontend part of _docker-compose.yml_
```yml
  frontend:
    build: ./frontend
    ports:
      - '3000:3000'
    volumes:
      - ./frontend/src:/app/src
    stdin_open: true
    tty: true
    depends_on:
      - backend
```

`docker-compose up`  

## Building Images & Understanding Container Names

`docker-compose up --build` - force image rebuild  (command)
`docker-compose build` - just build images, without running containers

---

To set name of a container `container_name`:
```yml
services:
  mongodb:
    container_name: mongodb
```
## Module summary

docker-compose only partially substitutes `docker run` and `docker build`

# Section 7. Working with "utility containers" & executing commands in containers

## Module Introduction & What are "Utility Containers"?

_Application container_ - our application code + environment needed to run our code  

_Utility containers_ is not an official term, just Max's. Only have certain environment (node, php) in them.
They don't an application when we run them. We run them in conjunction with some command to run certain task.

![img.png](notes-images/unitility_containers_1.png)

## Utility Containers: Why would you use them?

Earlier we had to download package.json from github

To create projects we need extra tools installed on our host machine, like _node_ to executed `npm init`

## Different Ways of Running Commands in Containers
Note: You can always run `docker container attach <container name>` to attach yourself to the container after it was started
Example:
run official node container:
`docker run -it node`  

---
(command)  
`docker exec -it <container name> <command>` - allows to run commands inside our container besides the default commands (specified in dockerfile) the container executes

`docker run -it -d node`
`docker ps`
`docker exec -it <container name> npm init`  

We can also overwrite default command (command)  
`docker run -it node <our command>`  
`docker run -it node npm init`  

## Building a First Utility Container

./utility-containers/Dockerfile
```dockerfile
FROM node:14-alpine
WORKDIR /app
```
`docker build -t node-util`

We want to create a project on our host machine with the help of a container. Mirror container to our host machine
Utility container - we can use it to execute something that affects our host machine without installing extra tools
Use bind mount

`docker run -it -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/utility-containers:/app node-util npm init`

We've got a package.json on our host machine.  

## Utilizing ENTRYPOINT
Restrict command we can run

With CMD in Dockerfile our command after image name overwrites CMD
`docker run -it -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/utility-containers:/app node-util npm init`  
Here `npm init` overwrites 
```dockerfile
CMD ['...', '...']
```

For `ENTRYPOINT` everything in command in `docker run ... <command>` is appended to `ENTRYPOINT`  
_Dockerfile_
```dockerfile
FROM node:14-alpine
WORKDIR /app
ENTRYPOINT ["npm"]
```
`docker build -t mynpm` 
```
docker build
    -t mynpm \  
    docker \  
    run \  
    -it \  
    -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/utility-containers:/app \  
    mynpm \  
    init # just init, not npm init
```  
Also, we can run npm install in this utility container:  
`docker run -it -v /Users/badger/Desktop/study/schwarzmuller-docker-kubernetes/utility-containers:/app mynpm install`  

## Using Docker Compose
(command)  
`docker-compose run <service name> <command>` - allows us to run single service from docker-compose.yml by service name  
Here `npm` is a name of service and `init` is a command:  
`docker-compose run --rm npm init`  

_docker-compose.yml_  
```yml
version: '3.8'
services:
  npm:
    build: ./
    stdin_open: true
    tty: true
    volumes:
      - ./:/app
```

# Section 8. A more complex setup: a Laravel & PHP dockerized project

## The Target Setup

We'll have 6 containers:
![img.png](notes-images/target_setup_1.png)

## Adding a Nginx (Web Server) Container

_ports, volumes_ from nginx image documentation
`:ro` - read only  
_docker-compose.yml_  
```yml
version: '3.8'

services:
  server:
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
```

add _./nginx/nginx.conf_  

## Adding a PHP Container

_/dockerfiles/php.dockerfile_
```dockerfile
FROM php:8.0-fpm
WORKDIR /var/www/html
RUN docker-php-ext-install pdo pdo-mysql
```

Here we don't have CMD - command of base image will be executed - invokes php interpreter  

Our php container must be able to reach our source code inside /var/www/html - we need bind mount  
Create folder for our code on our host machine  _src_ for our code  
```yml
  php:
    build:
      context: ./dockerfiles
      dockerfile: php.dockerfile
    volumes:
      - ./src:/var/www.html:delegated
```
`delegated` - if the container writes some data, it shouldn't instantly be written to our host machine. It's not necessary, it's optimization

---

Port: we defined it in nginx.conf:  
`php` - name of service  
```nginx configuration
        fastcgi_pass php:3000;
```
From documentation php image exposes port 9000. Change port to 9000 in nginx.config  
```nginx configuration
        fastcgi_pass php:9000;
```

_docker-compose.yml_ (php part):  
```yaml
  php:
    build:
      context: ./dockerfiles
      dockerfile: php.dockerfile
    volumes:
      - ./src:/var/www.html:delegated
```

## Adding a MySQL Container

configure environment from documentation https://hub.docker.com/_/mysql  
_/env/mysql.env
```dotenv
MYSQL_DATABASE=homestead
DEFAULT_USER=homestead
MYSQL_PASSWORD=secret
MYSQL_ROOT_PASSWORD=secret
```
_docker-compose.yml_ (mysql part):
```yml
  mysql:
    image: 'mysql:5.7'
    env_file:
      - ./env/mysql.env
```

## Adding a Composer Utility Container

Add _/dockerfiles/composer.dockerfile_  
```dockerfile
FROM composer:latest
WORKDIR /var/www/html
ENTRYPOINT ["composer", "--ignore-platform-reqs"]
```
_docker-compose.yml_ (composer part): 
```yaml
  composer:
    build:
      context: ./dockerfiles
      dockerfile: composer.dockerfile
    volumes:
      - ./src:/var/www/html
```

---

_docker-composer.yml_ (all)
```yml
version: '3.8'

services:
  server:
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  php:
    build:
      context: ./dockerfiles
      dockerfile: php.dockerfile
    volumes:
      - ./src:/var/www.html:delegated
  mysql:
    image: 'mysql:5.7'
    env_file:
      - ./env/mysql.env
  composer:
    build:
      context: ./dockerfiles
      dockerfile: composer.dockerfile
    volumes:
      - ./src:/var/www/html
```

## Creating a Laravel App via the Composer Utility Container

Run individual composer utility container to create laravel project:  
`composer` - name of our service  
rest - command that is executable inside composer container  
`docker-compose run --rm composer create-project --prefer-dist laravel/laravel .`

Root project will be created in container inside WORKDIR and thanks to bind mount will be reflected in the _src_ folder on our host machine  

## Launching Only Some Docker Compose Services

There is a laravel project created in our _src_     
Part responsible for connection to mySQL database:  
_/src/.env_  
```dotenv
DB_CONNECTION=mysql # +
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=
```
Using /env/mysqml.env data change to:  
_/src/.env_
```dotenv
DB_CONNECTION=mysql
DB_HOST=mysql # +
DB_PORT=3306
DB_DATABASE=homestead # +
DB_USERNAME=homestead # +
DB_PASSWORD=secret # +
```

Run application:  
Path or request: _server => php => mysql_  
We need in _server_ expose extra volume, bind mount:  
In _nginx.config_ we're looking for files in:  
_/nginx/nginx.conf_
```nginx configuration
root /var/www/html/public;
```
_docker-compose.yml_
```yml
  server:
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./src:/var/www/html # expose files
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
```
---
Fix:  
```yaml
  server:
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./src:/var/www/html
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro # fix path in container
```
Run only _server, php, mysql_ services (command):  
`docker-compose down`  
```zsh
docker-compose up -d server php mysql
```

---

Use:  
```yml
  server:
    depends_on:
      - php
      - mysql
```
Now we can write:  
`docker-compose up server`  

---

For now docker compose doesn't rebuild our images  
We want docker compose to evaluate our dockerfiles and build images if it changed

`docker-compose up -d --build server`

---

Note: some fixes in commit "Finally works. Launching Only Some Docker Compose Services"
![img.png](notes-images/laravel-2.png)
![img.png](notes-images/laravel-1.png)

## Adding More Utility Containers
We need artisan to handle laravel commands, like populate databse with initial data 

For artisan we can use dockerfile of php, but just add _entrypoint_
_/var/www/html/artisan_ - a utility program that can do a lot of staff  

_docker-compose.yml_ (artisan & npm)  
```yml
  artisan:
    build:
      context: .
      dockerfile: dockerfiles/php.dockerfile
    volumes:
      - ./src:/var/www/html
    entrypoint: ["php", "/var/www/html/artisan"]
  npm:
    image: node:14
    working_dir: /var/www/html
    entrypoint: ["npm"]
    volumes:
      - ./src:/var/www/html
```

use artisan utility container: 
`docker-compose run --rm artisan migrate`

--- 

Problem: connection refused  

Solution:  
https://www.udemy.com/course/docker-kubernetes-the-practical-guide/learn/lecture/22167198#questions/14040174

- make sure everything is stopped  
`docker-compose down`

- create your laravel project  
`docker-compose run --rm composer create-project --prefer-dist laravel/laravel .`
  
- launch your containers with --build to make sure you're getting the latest images  
`docker-compose up -d --build server`

---

## Docker Compose with and without Dockerfiles

Adding dockerfile to docker-compose (like `entrypoint`, `working_dir`)

In docker-compose we don't have some commands that we have in dockerfile:
like `COPY`, `RUN`, etc.

Keep in mind: bind mount are great for development, not an option for deployment  
Because in production we don't have local folders like `/src`, `./nginx/nginx.conf` etc  
The idea of the bind mound is that our latest source code during development is directly exposed to a container  

For deployment we want to create an image with our source code, we copy a snapshot of the source code

## Bind Mounts and COPY: When To Use What

To copy source code and configuration in the image when it' built  
When we later deploy that image it already contains source code and configuration  

For development we use bind mount in docker-composer.yml  
For deployment we use commands to build image in nginx.dockerfile  
We don't have to specify CMD because official image already has a default command to start nginx server  
_/dockerfiles/nginx.dockerfile_
```dockerfile
FROM nginx:stable-alpine
# Copy configuration file
WORKDIR /etc/nginx/conf.d
COPY nginx/nginx.conf .
RUN mv nginx.conf default.conf
# Copy source code
WORKDIR /var/www/html
COPY src .
```

use our custom image in docker-compose.yml  
Note: `context` sets path to where to look a dockerfile and also where to build dockerfile.  
But we need our `context` to be on the upper level of all folders it needs
_docker-compose.yml_
```yml
  server:
    # image: 'nginx:stable-alpine'
    build:
      context: .
      dockerfile: dockerfiles/nginx.dockerfile
```

---

We also need to tweek php dockerfile to get a snapshot of source code for deployment:  
_/dockerfiles/php.dockerfile_
```dockerfile
COPY src .
```

---

Now try to run docker-compose without volumes: we'll have snapshots, but updates in our code won't be reflected:
```yml
  server:
...
#    volumes:
#      - ./src:/var/www/html
#      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
...
  php:
...
#    volumes:
#      - ./src:/var/www/html:delegated
```

Now we can run a container:  
`docker-compose up -d --build server`

---

Note image can restrict read and write to container: 
We can't execute `COPY` with some images  
This wasn't a problem with bind mount but a problem when working only inside container  
We can grant access  to write to certain folders 
_/dockerfiles/php.dockerfile_
```dockerfile
RUN chown -R www-data:www-data /var/www/html
```

`www-data` - default user of the image  
Thus Laravel will have access to write to folder `/var/www/html` as a `www-data` user  

---

For artisan also change context:
```yml
  artisan:
    build:
      context: .
      dockerfile: dockerfiles/php.dockerfile
```

# Section 9. Deploying docker containers

## From Development To Production

We shouldn't use bind mounts in production  
![img.png](notes-images/from_development_to_production_1.png)

## Getting Started With An Example
![img.png](notes-images/getting_started_1.png)

`docker build -t node-dep-example .`  
`docker run -d --rm --name node-dep -p 80:80 node-dep-example`  
![img.png](notes-images/getting_started_2.png)

## Bind Mounts In Production
We use `COPY` instead of bind mounts for production  
Because we don't setup environment in production  
![img.png](notes-images/bind_mounts_in_production.png)

## Introducing AWS & EC2

Find EC2 on AWS  

## Connecting to an EC2 Instance

- launch instance: Amazon Linux 2 AMI  
- make sure vpc option is configured  
- press 'review and launch'  
- create new key pair (to run commands later), name: 'schwarzmuller-example-1'
- save key file  ('code' folder)
- press `launch instance`  

---

Note: on Windows or use wsl2 or putty

---

connect => choose 'SSH client'  

![img.png](notes-images/connect.png)

run command from folder where is the key file:  
`chmod 400 schwarzmuller-example-1.pem`  
`ssh -i "schwarzmuller-example-1.pem" ec2-user@ec2-18-197-177-8.eu-central-1.compute.amazonaws.com`  

Now all comands from this terminal will be executed on the remote machine  

Now left:  
- install docker
- get image on remote machine
- run container  
- configure security groups  

## Installing Docker on a Virtual Machine
After connecting to EC2, update packages on remote machine:  
`sudo yum update -y`  

Install docker on remote machine:  
`sudo amazon-linux-extras install docker`  

Start docker:  
`sudo service docker start`  

Now we're able to run docker commands on remote machine  




