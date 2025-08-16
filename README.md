# EasINGInious

EasINGInious is a project which tries to simplify the installation of INGInious by using [Docker](https://docs.docker.com/engine/install/) and by fixing dependency version issues.

Currently, this project installs the version `0.8` of INGInious. The documentation for this version is available [here](https://docs.inginious.org/en/v0.8.2/admin_doc/install_doc/installation.html).

Because of how INGInious works, installing it in a Docker container requires a few specific actions. This is due to the fact that the INGInious Docker agent dynamically creates Docker containers to run the student code and therefore the container running INGInious must have access to the Docker socket and must have the correct permissions. In addition, the containers running the student code must ‘mount’ certain files. However, files from a Docker container cannot be ‘mounted’ in another container. It is therefore necessary to use the host file system at some point.

## Installation

First, you need to clone the repository and its submodules using the following command:

```bash
git clone --recurse-submodules https://github.com/BergLucas/EasINGInious.git
```

Then, you must install [Docker](https://docs.docker.com/engine/install/) on your machine.

After that, you need to create a user that will have access to the INGInious folder:

```bash
sudo useradd -U -M -s /usr/sbin/nologin inginious
sudo mkdir /var/www/INGInious
sudo chown inginious:inginious /var/www/INGInious
sudo chmod 775 /var/www/INGInious
```

Next, you must run the installer by running the following commands:

```bash
export DOCKER_GID=$(getent group docker | awk -F: '{print $3}')
export INGINIOUS_GID=$(getent group inginious | awk -F: '{print $3}')
docker compose -f docker-compose.yml -f docker-compose.installer.yml -f docker-compose.build.yml up -d
docker compose -f docker-compose.yml -f docker-compose.installer.yml exec -it backend inginious-install
docker compose -f docker-compose.yml -f docker-compose.installer.yml down
```

Afterwards, the installer should be started. You can configure INGInious as you like, the only important information you'll need is that the address of the Mongo DB is `db`. To avoid permission issues, it is also recommended that you edit the `/var/www/INGInious/configuration.yaml` file after installation to change the value of `local-config` to:

```yml
local-config:
    tmp_dir: /var/www/INGInious/agent_tmp
```

Finally, you can start the application by running the following command:

```bash
DOCKER_GID=$(getent group docker | awk -F: '{print $3}') INGINIOUS_GID=$(getent group inginious | awk -F: '{print $3}') docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```
