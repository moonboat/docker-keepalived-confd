#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# add config file
ln -sf ${CONTAINER_SERVICE_DIR}/confd/assets/confd.toml /etc/confd/confd.toml

# add template resource
ln -sf ${CONTAINER_SERVICE_DIR}/confd/assets/conf.d/* /etc/confd/conf.d/

# add template
ln -sf ${CONTAINER_SERVICE_DIR}/confd/assets/templates/* /etc/confd/templates/

# override the keepalived image config file with the confd template
# so keepalived startup script do variable replacements
ln -sf ${CONTAINER_SERVICE_DIR}/confd/assets/templates/keepalived.tmpl ${CONTAINER_SERVICE_DIR}/keepalived/assets/keepalived.conf


FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-confd-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  if [ "${KEEPALIVED_CONFD_CLIENT_TLS,,}" == "true" ]; then
    # backend ssl
    # generate a certificate and key if files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
    ssl-helper ${KEEPALIVED_CONFD_CLIENT_SSL_HELPER_PREFIX} "${CONTAINER_SERVICE_DIR}/confd/assets/certs/$KEEPALIVED_CONFD_CLIENT_CERT_FILENAME" "${CONTAINER_SERVICE_DIR}/confd/assets/certs/$KEEPALIVED_CONFD_CLIENT_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/confd/assets/certs/$KEEPALIVED_CONFD_CLIENT_CAKEYS_FILENAME"
  fi
  touch $FIRST_START_DONE
fi

exit 0
