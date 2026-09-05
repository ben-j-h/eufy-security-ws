FROM node:24-alpine AS build
WORKDIR /tmp
COPY . .
RUN npm ci --foreground-scripts
RUN npm run build

FROM node:24-alpine AS prod
WORKDIR /tmp_prod
COPY --from=build /tmp/dist ./dist
COPY --from=build /tmp/docker/run.sh ./run.sh
COPY --from=build /tmp/docker/eufy-security-client-4.0.0.tgz ./docker/eufy-security-client-4.0.0.tgz
COPY --from=build /tmp/package.json ./package.json
COPY --from=build /tmp/package-lock.json ./package-lock.json
RUN npm ci --omit=dev

FROM node:24-alpine
WORKDIR /usr/src/app
COPY --from=prod /tmp_prod ./
RUN apk add --no-cache jq
RUN apk add --no-cache bash
EXPOSE 3000
VOLUME ["/data"]
CMD [ "/usr/src/app/run.sh" ]
