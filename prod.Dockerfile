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
