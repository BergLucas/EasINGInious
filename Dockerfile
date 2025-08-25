# Base
FROM docker:28.3-dind AS base

ENV INGINIOUS_DIR=/var/www/INGInious

ENV INGINIOUS_TASKS_DIR=${INGINIOUS_DIR}/tasks

ENV INGINIOUS_BACKUPS_DIR=${INGINIOUS_DIR}/backups

ENV INGINIOUS_WEBAPP_HOST=0.0.0.0

ENV INGINIOUS_WEBAPP_PORT=80

ENV INGINIOUS_WEBDAV_HOST=0.0.0.0

ENV INGINIOUS_WEBDAV_PORT=8080

ENV INGINIOUS_WEBAPP_CONFIG=${INGINIOUS_DIR}/configuration.yaml

ENV PYTHONUNBUFFERED=1

VOLUME [ "${INGINIOUS_DIR}" ]

WORKDIR "${INGINIOUS_DIR}"

COPY inginious-entrypoint.sh /usr/local/bin/inginious-entrypoint.sh

RUN apk add --no-cache gcc musl-dev linux-headers python3 python3-dev py3-pip py3-setuptools tidyhtml-libs libzmq xmlsec libtool && \
    mkdir "${INGINIOUS_TASKS_DIR}" && \
    mkdir "${INGINIOUS_BACKUPS_DIR}" && \
    chmod +x /usr/local/bin/inginious-entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/inginious-entrypoint.sh" ]

# Development
FROM base AS development

ENV PYTHONDONTWRITEBYTECODE=1

ENV POETRY_HOME=/opt/poetry

WORKDIR /app

RUN python -m venv $POETRY_HOME && \
    $POETRY_HOME/bin/pip install poetry~=2.0 poetry-plugin-export~=1.9 && \
    ln -s $POETRY_HOME/bin/poetry /usr/local/bin/poetry

# Builder
FROM development AS builder

COPY . .

RUN pip install --prefix /env/ .

# Production
FROM base AS production

ENV REAL_SCRIPT_NAME=""

RUN apk add --no-cache lighttpd fcgi py3-flup && \
    rm -rf /var/www/localhost && \
    adduser lighttpd docker && \
    chown -R lighttpd:lighttpd "${INGINIOUS_DIR}" && \
    sed -i "/^server\.document-root/c\server.document-root = \"${INGINIOUS_DIR}\"" /etc/lighttpd/lighttpd.conf && \
    sed -i "/^server\.pid-file/ s/^/#/" /etc/lighttpd/lighttpd.conf && \
    echo "include \"/etc/lighttpd/vhosts.d/inginious.conf\"" >> /etc/lighttpd/lighttpd.conf

COPY --from=builder /env/ /usr/

COPY inginious.conf /etc/lighttpd/vhosts.d/inginious.conf

EXPOSE ${INGINIOUS_WEBAPP_PORT}

EXPOSE ${INGINIOUS_WEBDAV_PORT}

CMD [ "lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf" ]
