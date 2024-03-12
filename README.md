# React.js with Docker Compose

What will you learn here:

- How to set up a **development environment** for a React.js application using Docker Compose
- How to set up a **production environment** for a React.js application using Docker Compose
- How to use **environment variables** in a React.js application with Docker Compose

This repository contains a simple React.js application that is set up
to run in a Docker container using Docker Compose. It is set up for both
development and production environments. Keep reading to find out how
to do it yourself.

<br/>

## Create React App

Before setting up any environment, we need to create a React.js project.
We can do this with [Create React App](https://create-react-app.dev/) tool:

```bash
npx create-react-app react-demo-app
```

<br/>

## Development Setup

### Steps

1. Create a `Dockerfile` for in the root of the project:
   ```Dockerfile
   # Use an official Node runtime as a parent image
   FROM node:latest
   
   # Set the working directory in the container
   WORKDIR /usr/src/app
   
   # Copy package.json and package-lock.json
   COPY package.json package-lock.json ./
   
   # Install dependencies
   RUN npm install
   
   # Bundle app source inside the docker image
   COPY . .
   
   # Define environment variable
   ENV NODE_ENV=development
   
   # Run npm start script when the container launches
   CMD ["npm", "start"]
   ```

2. Create a `docker-compose.yml` file in the root of the project:
   ```yaml
   version: "3.8"
   
   services:
   
    react:
      container_name: react
      build:
        dockerfile: Dockerfile
      ports:
        - "3000:3000"
      volumes:
        - .:/usr/src/app # Mount the current directory into the container
        - node-modules:/usr/src/app/node_modules # Use a named volume for node_modules
   
   volumes:
    node-modules:
   ```

### Now what?

Run:

```bash
docker compose up
```

This will build the image from the `Dockerfile` and start a container
from it which will run the `npm start` script.
Now, you will be able to see the changes in the code immediately without
rebuilding the container. This is known as **hot reloading**, and in this
case, it is achieved by mounting the current directory into the container
and using a named volume for `node_modules`.

However, in order to install a new npm package, we need to do it from
inside the container.

Example:

```bash
docker compose exec react npm install lodash
```

This will install a package called `lodash` in the container, and it will
be added to the `node_modules` directory in the named volume. On the host,
you will see the added package only in the `package.json` (and
`package-lock.json`) file.

<br/>

## Production Setup

### Steps

1. Create a `prod.Dockerfile` for in the root of the project:
   ```Dockerfile
   # Stage 1: Build the React application
   FROM node:latest as build
   
   WORKDIR /app
   
   # Copy package.json and package-lock.json (or yarn.lock if you use yarn)
   COPY package.json package-lock.json ./
   
   # Install dependencies
   RUN npm install
   
   # Copy the rest of the code
   COPY . .
   
   # Build the application
   RUN npm run build
   
   # Stage 2: Serve the application from Nginx
   FROM nginx:alpine
   
   # Copy the build from the previous stage
   COPY --from=build /app/build /usr/share/nginx/html
   
   # Start Nginx and keep it running
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. Create a `docker-compose.prod.yml` file in the root of the project:
   ```yaml
   version: "3.8"
   
   services:
   
    react-prod:
      container_name: react-prod
      build:
        dockerfile: prod.Dockerfile
      ports:
        - "80:80"
   ```

### Now what?

Run:

```bash
docker compose -f docker-compose.prod.yml up
```

This will build a lightweight image with Nginx from the `prod.Dockerfile`
and it will start a container from it which will serve the React application
on port `80`.
The served application is built using the `npm run build` script, which
**optimizes the application for production** (minification, tree shaking,
chunk splitting, etc.).
Served application is static, and it is not possible to see the changes
immediately without rebuilding the image and restarting the container.

<br/>

## Environment Variables

In both development and production setups, only the environment variables
prefixed with `REACT_APP_` are available to the React application (plus
`NODE_ENV`).

### Development

In the development setup, if you pass environment variables to the container
on the container start, they will be available to the React application.
You can do this by adding the `environment` key to the `docker-compose.yml`
and defining the environment variables there, or by creating a `.env` file
in the root of the project and defining the environment variables there.

### Production

In production setup, you need to make the environment variables available
during the Docker image build process. You can do this by adding the `args`
key to the `prod.Dockerfile` and defining the environment variables there,
or by creating a `.env` file in the root of the project and defining the
environment variables there (just like in production setup).

### `.env` files

Besides `.env` file, there are
[other files](https://create-react-app.dev/docs/adding-custom-environment-variables/#what-other-env-files-can-be-used)
that you can use to set environment variables and each of them has its
own priority.
