FROM node:8 AS build-stage

RUN git clone -b 1.2.4 --depth=1 https://github.com/mayswind/AriaNg.git /AriaNg
WORKDIR /AriaNg
RUN npm install
RUN npx gulp clean build-bundle

FROM scratch AS export-stage
COPY --from=build-stage /AriaNg/dist/index.html /
