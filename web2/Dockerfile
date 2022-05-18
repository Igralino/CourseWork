# syntax=docker/dockerfile:1.0.0-experimental
FROM node:16-alpine

RUN apk add git openssh-client && \
  mkdir -p -m 0600 ~/.ssh && \
  ssh-keyscan g.hse.ru >> ~/.ssh/known_hosts

WORKDIR /app

COPY package.json yarn.lock /app/

RUN --mount=type=ssh,id=g yarn install --frozen-lockfile && yarn cache clean

COPY . /app

RUN yarn build-ts

CMD [ "npm", "run", "start"]
