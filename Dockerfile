# Base
FROM fedora:40 AS base

ENV INGINIOUS_DIR=/var/www/INGInious

ENV INGINIOUS_WEBAPP_HOST=0.0.0.0

ENV INGINIOUS_WEBAPP_PORT=80

ENV INGINIOUS_WEBDAV_HOST=0.0.0.0

ENV INGINIOUS_WEBDAV_PORT=8080

ENV INGINIOUS_WEBAPP_CONFIG=${INGINIOUS_DIR}/configuration.yaml

ENV PYTHONUNBUFFERED=1

VOLUME [ "${INGINIOUS_DIR}" ]

WORKDIR ${INGINIOUS_DIR}

RUN dnf install -y git gcc libtidy python3 python3-devel python3-pip python3-setuptools zeromq-devel dnf-plugins-core xmlsec1-openssl-devel libtool-ltdl-devel which && \
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo && \
    dnf install -y docker-ce-cli && \
    dnf clean all && \
    mkdir tasks && \
    mkdir backup

# Development
FROM base AS development

ENV PYTHONDONTWRITEBYTECODE=1

ENV POETRY_HOME=/opt/poetry

RUN python3 -m venv $POETRY_HOME && \
    $POETRY_HOME/bin/pip install poetry~=1.8 && \
    ln -s $POETRY_HOME/bin/poetry /usr/local/bin/poetry

# Builder
FROM development AS builder

WORKDIR /app

COPY pyproject.toml poetry.lock ./

COPY . .

RUN poetry export --without-hashes -f requirements.txt | pip install --prefix /env/ -r /dev/stdin

# Production
FROM base AS production

RUN dnf install -y lighttpd lighttpd-fastcgi && \
    usermod -aG docker lighttpd && \
    chown -R lighttpd:lighttpd .

COPY --from=builder /env/ /usr/local/

RUN sed -i 's|server.document-root = server_root + "/lighttpd"|server.document-root = server_root + "/INGInious"|' /etc/lighttpd/lighttpd.conf && \
    sed -i 's|server.pid-file = state_dir + "/lighttpd.pid"|#server.pid-file = state_dir + "/lighttpd.pid"|' /etc/lighttpd/lighttpd.conf && \
    sed -i 's|server.port = 80|server.port = 8080|' /etc/lighttpd/lighttpd.conf && \
    echo 'include "/etc/lighttpd/vhosts.d/inginious.conf"' >> /etc/lighttpd/lighttpd.conf && \
    chown -R lighttpd:lighttpd /usr/local/lib/python3.12/site-packages/inginious/frontend/static/

USER lighttpd

COPY modules.conf /etc/lighttpd/modules.conf

COPY inginious.conf /etc/lighttpd/vhosts.d/inginious.conf

EXPOSE ${INGINIOUS_WEBAPP_PORT}

CMD lighttpd -D -f /etc/lighttpd/lighttpd.conf
