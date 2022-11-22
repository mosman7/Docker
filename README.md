# Microservices
### What are Microservices
Microservices are an architectural and organizational approach to software development where software is composed of small independent services that communicate over well-defined APIs. These services are owned by small, self-contained teams.

Microservices architectures make applications easier to scale and faster to develop, enabling innovation and accelerating time-to-market for new features.

### Monolithic vs. Microservices Architecture
With monolithic architectures, all processes are tightly coupled and run as a single service. This means that if one process of the application experiences a spike in demand, the entire architecture must be scaled. Adding or improving a monolithic application’s features becomes more complex as the code base grows. This complexity limits experimentation and makes it difficult to implement new ideas. Monolithic architectures add risk for application availability because many dependent and tightly coupled processes increase the impact of a single process failure.

With a microservices architecture, an application is built as independent components that run each application process as a service. These services communicate via a well-defined interface using lightweight APIs. Services are built for business capabilities and each service performs a single function. Because they are independently run, each service can be updated, deployed, and scaled to meet demand for specific functions of an application.
![mono vs micro](https://user-images.githubusercontent.com/115226294/203055783-ce2db2a5-a52f-4d15-8301-ba7e2bf12c91.png)

### What is docker
Docker is a software platform that allows you to build, test, and deploy applications quickly. Docker packages software into standardized units called containers that have everything the software needs to run including libraries, system tools, code, and runtime. Using Docker, you can quickly deploy and scale applications into any environment and know your code will run.

### Why Docker
![docker](https://user-images.githubusercontent.com/115226294/203055961-50aec1c7-bc5a-4cc3-96ec-f0d6034d3ddb.jpeg)
- Docker allows you to ship code faster, standardize application operations, seamlessly move code, and save money by improving resource utilization.
- With Docker, you get a single that can reliably run anywhere.
- Docker's simple and straightforward syntax gives you full control.
- Wide adoption means there's a robust ecosystem of tools and off-the-shelf applications that are ready to use with Docker.

### How Docker works
When you try to run a container, Docker will first try to check your local machine for the image. If it is not there, it will fetch the appropriate image from the registry (docker hub) using an API.

### Docker lifecycle
Docker containers have the following lifecycle:
- Create a container
- Run the container
- Pause the container(optional)
- Un-pause the container(optional)
- Start the container
- Stop the container
- Restart the container
- Kill the container
- Destroy the container

### Docker commands
- Windows users should use `alias docker="winpty docker"` for the below commands to work.
- `docker run hello-world`: This first looks locally. Then it looks on the registry (on docker hub). It then displays the message if it finds it. The command is case sensitive.
- `docker images`: lists all the local images
- `docker run -d -p 80:80 nginx`: this will run the image, and the 80:80 is an example of port mapping, 80:3000 means image is from port 80, display in port 3000 in my machine. -d stands for detached - if there is an error, kill the container and run this command without -d to see the logs.
- `docker rm (id)`: Removes a container.
- `docker ps -a`: Lists all the running containers.
- `docker exec -it (id) bash`: The exec command is used to interact with already running containers on the Docker host. It allows you to start a session within the default directory of the container.
- `docker stop (id)`: Stops a running container(it does save changes).
- `docker rm (id) -f`: Completely removes a container.

## Create website task
1. In vscode create a file `index.html`
2. Then i pulled the latest docker image `docker pull nginx`
3. Then i started the image `docker run -d -p 80:80 nginx`
4. i then copied over my index.html that was saved locally into my container - html folder `docker cp index.html 2359977b50d1:/usr/share/nginx/html/`
5. i ran my site and when i saw everything working i commited to docker hub `docker commit <container id> mosman7/eng130-website-profile:tagname`
6. Now we need to login to docker again `docker login`
7. Then we push to docker hub `docker push mosman7/eng130-website-profile:tagname`
8. to run website run `docker run -d -p 80:80  mosman7/eng130-website-profile:tagname`

### How to Automate creating a container
1. We need to create a `Dockerfile`
2. In this file we must:
    - define what image we are pulling
    - Copy the index file from localhost to location inside docker container
    - Define the port number we will be using
    - Launch the server with commands 
3. Build the image `docker build -t mosman7/name .`
    - here we name the image and specify the location of Dockerfile, . means in current location
4. After build we can create the container `docker run -d -p 80:80 mosman7/name`

### NODE app task
1. Create new directory 
2. Create Dockerfile
```
# docker pull node
FROM node

# copy folders
COPY app /home/
COPY environment /home/

# define the ports
EXPOSE 80
EXPOSE 3000

# Install npm
RUN apt-get update
RUN apt-get install -y
RUN apt-get install software-properties-common -y
RUN apt-get install npm -y

CMD ["nginx", "-g", "daemon off;"]
# cd into app folder to run npm
WORKDIR /home/app
RUN npm install
CMD ["npm", "start"] # CMD is the last command run
```
3. Build the image `docker build -t mosman7/docker-app .`
4. Run the container `docker run -d -p 80:3000 mosman7/docker-app` 
    - If nginx is running on port 80 delete it or reverse proxy will not work
5. Go to localhost on machine and Node app should be running


## Using Docker compose to combine 2 containers together
### Docker Compose
Docker Compose is a tool that was developed to help define and share multi-container applications. With Compose, we can create a YAML file to define the services and with a single command, can spin everything up or shut it all down.

A big advantage of using Compose is you can define your application in a file, keep it at the root of your project repo, and easily enable someone else to contribute to your project.

#### Steps
1. Create new directory and copy app folder
2. Create a DB folder
3. Create a dockerfile in both of these folders
4. My app Dockerfile looked like this:
```
# give node app an alias
FROM node as app
#create app folder
WORKDIR /usr/src/app
#copy dependencies - all .json files to default location - app folder made
COPY package*.json ./
#run this npm version globally
RUN npm install -g npm@7.20.6
#copy everything from this location to app folder
COPY . .
#expose port 3000
EXPOSE 3000
#launch the app
CMD ["node", "app.js"]
# 1st build complete

# multi stage build
# slimmer version of node -alpine
FROM node:alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install -g npm@7.20.6
COPY --from=app /usr/src/app /usr/src/app
EXPOSE 3000
RUN node seeds/seed.js
CMD ["node", "app.js"]
```
5. Create a mongo.conf file in db allowing port 27017
6. In DB Dockerfile copy mongo.conf into container and expose port 27017
```
FROM mongo
WORKDIR /usr/src/db/
COPY ./mongod.conf /etc/
EXPOSE 27017
CMD ["mongod"]
```
7. Now both dockerfiles are complete, create a docker compose.yml file
8. In compose file, call both Dockerfiles 
```
# Version of the compose file format 
version: "3.9"
# Container services
services:
  db:
  #  # image to fetch from docker hub
    image: mongo
    # Mapping of container port to host
    ports:
      - "27017:27017"

  app:
  # Path to Dockerfile 
    build: ./app
    restart: always
    ports:
      - "3000:3000"
    # Environment variables for startup script
    # container will use these variables to start the container with these define variables. 
    environment:
      - DB_HOST=mongodb://db:27017/posts
    depends_on:
      - db
```
9. Run `docker compose up` which will build the container using the 2 images