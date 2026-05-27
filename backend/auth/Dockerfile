FROM node:20-alpine
 
# Set working directory
WORKDIR /app
 
# Install dependencies first (layer cache optimisation)
COPY package*.json ./
RUN npm ci --omit=dev
 
# Copy application source
COPY . .
 
# Expose the service port
EXPOSE 3001
 
# Start the server
CMD ["node", "server.js"]
