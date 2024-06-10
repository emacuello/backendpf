FROM node:lts-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001
EXPOSE 80

CMD ["node", "--max-old-space-size=4096", "node_modules/.bin/nest", "start"]
