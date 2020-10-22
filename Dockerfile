FROM node:14.6-buster
LABEL maintainer="Johannes Rohr <jorohr@gmail.com>"

# see https://github.com/nodejs/docker-node#how-to-use-this-image

## Install common software
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
  bzip2 \
  dh-autoreconf \
  git \
  libpng-dev \
  poppler-utils

# Install mongo & mongorestore (this is used only for database initialization, not on runtime)
# So much space need, see 'After this operation, 184 MB of additional disk space will be used.'
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - \
  && echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list \
  && apt-get update \
  && apt-get install -y mongodb-org-shell mongodb-org-tools \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

## Download Uwazi v1.10.1
RUN git clone -b 1.10.1 --single-branch --depth=1 https://github.com/huridocs/uwazi.git /home/node/uwazi/ \
  && chown node:node -R /home/node/uwazi/ \
  && cd /home/node/uwazi/ \
  && npm config set scripts-prepend-node-path auto \
  && yarn install \
  && yarn production-build

WORKDIR /home/node/uwazi/
COPY --chown=node:node docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
