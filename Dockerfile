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
