# Base
FROM fedora:40 AS base

ENV INGINIOUS_DIR=/var/www/INGInious

VOLUME [ "${INGINIOUS_DIR}" ]

ENV PYTHONUNBUFFERED=1

RUN dnf install -y git gcc libtidy python3 python3-devel python3-pip python3-setuptools zeromq-devel dnf-plugins-core xmlsec1-openssl-devel libtool-ltdl-devel which && \
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo && \
    dnf install -y docker-ce-cli && \
    dnf clean all && \
    mkdir -p ${INGINIOUS_DIR} && \
    mkdir -p ${INGINIOUS_DIR}/tasks && \
    mkdir -p ${INGINIOUS_DIR}/backup


# Development
FROM base AS development

ENV PYTHONDONTWRITEBYTECODE=1

ENV POETRY_HOME=/opt/poetry

WORKDIR /app

RUN python3 -m venv $POETRY_HOME && \
    $POETRY_HOME/bin/pip install poetry~=1.8 && \
    ln -s $POETRY_HOME/bin/poetry /usr/local/bin/poetry
