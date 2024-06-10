FROM node:20.12.2-buster-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001
EXPOSE 80

CMD ["npm", "run", "start"]
