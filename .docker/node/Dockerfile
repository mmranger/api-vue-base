FROM node:12.7.0-stretch-slim

ARG SERVICE_DIR="./node"
COPY ./.shared/scripts/ /tmp/scripts/
RUN chmod +x -R /tmp/scripts/

# set timezone
ARG TZ=${TIMEZONE}
RUN /tmp/scripts/set_timezone.sh ${TZ}

RUN /tmp/scripts/install_software.sh

# add users
ARG APP_USER=www-data
ARG APP_GROUP=www-data
ARG APP_USER_ID=1000
ARG APP_GROUP_ID=1000

# RUN /tmp/scripts/create_user.sh ${APP_USER} ${APP_GROUP} ${APP_USER_ID} ${APP_GROUP_ID}

# workdir
ARG APP_CODE_PATH="/var/lib"
WORKDIR "$APP_CODE_PATH"

# entrypoint
RUN mkdir -p /bin/docker-entrypoint/ \
 && cp /tmp/scripts/docker-entrypoint/* /bin/docker-entrypoint/ \
 && chmod +x -R /bin/docker-entrypoint/ \
;

RUN npm install -g @vue/cli

RUN /tmp/scripts/cleanup.sh

# @see https://docs.docker.com/engine/examples/running_ssh_service/
#CMD ["/usr/sbin/sshd", "-D"]
ENTRYPOINT ["/bin/docker-entrypoint/resolve-docker-host-ip.sh"]
