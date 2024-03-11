# React.js with Docker Compose

## Development Setup

1. Create a React.js project using 
[Create React App](https://create-react-app.dev/) tool:
    ```bash
    npx create-react-app react-demo-app
    ```

2. Create a Dockerfile for local development in the root 
of the project:
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
