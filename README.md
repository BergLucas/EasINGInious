# EasINGInious

EasINGInious is a project which tries to simplify the installation of INGInious using [Docker in Docker (DinD)](https://hub.docker.com/_/docker).

This allows INGInious to separate the grading containers from the application containers using its own Docker daemon and to avoid problems with [bind-mounts](https://docs.docker.com/engine/storage/bind-mounts/) inside containers.


## Setting up a development environment

First, you need to clone the repository and its submodules using the following command:

```bash
git clone --recurse-submodules https://github.com/BergLucas/EasINGInious.git
```

Then, you must install [Docker](https://docs.docker.com/engine/install/) on your machine.

Next, you must execute and install the application using the following commands:

```bash
# Start the application containers
docker compose up -d

# To create a super admin
docker compose exec -it app poetry run easinginious createsuperadmin

# To build the grading containers
docker compose exec -it app poetry run easinginious buildcontainers
```


## Setting up a production environment

First, you need to clone the repository and its submodules using the following command:

```bash
git clone --recurse-submodules https://github.com/BergLucas/EasINGInious.git
```

Then, you must install [Docker](https://docs.docker.com/engine/install/) on your machine.

Next, you must execute and install the application using the following commands:

```bash
# Start the application containers
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.build.yml up -d

# To create a super admin
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -it app poetry run easinginious createsuperadmin

# To build the grading containers
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -it app poetry run easinginious buildcontainers
```
