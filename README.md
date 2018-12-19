# arma3sync-docker

## What is `arma3sync-docker` and how is it different from `arma3sync`?

**Arma3Sync** is a software developped by the arma 3 team [Sons of Exiled](http://sonsofexiled.fr/). It is both a launcher and adddons synchronization software for ArmA 3. It is intend to be used by players, server administrators and ArmA 3 teams.

**arma3sync-docker** is a project to provide Arma3Sync as a runnable docker container. It allows users to execute the software in larger projects without having to install a JRE on the machine. It is maintained by a developper that is not invovled in arma3sync developpement.

## Quick reference

- **Where to get help with docker**
    [the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

- **Where to get help with arma3sync**
    [the Bohemia Interactive Forums](https://forums.bohemia.net/forums/topic/152942-arma3sync-launcher-and-addons-synchronization-software-for-arma-3/), [the Sons of Exiled wiki](http://www.sonsofexiled.fr/wiki/index.php/1._ArmA3Sync)

- **Where to file issues with arma3sync-docker**
    [the project's Github](https://github.com/ArwynFr/arma3sync-docker/issues)

- **Maintained by**
    [ArwynFr](https://github.com/ArwynFr/arma3sync-docker)

## How to use this image

### Run interactively

The easiest way to using this image is by creating a container and runing it. This will start arma3sync in interactive mode just as if you just ran the `arma3sync-console.sh`. Do not forget to add the `-it` options or else the program will complain about being unable to read input.

```console
$ docker run -it --name some-arma3sync arwynfr/arma3sync
ArmA3Sync Installed version = 1.6.97
JRE installed version = 1.8.0_181
OS Name = Linux

ArmA3Sync console commands:
NEW: create a new repository
BUILD: build repository
CHECK: check repository synchronization
DELETE: delete repository
LIST: list repositories
SYNC: synchronize content with a repository
EXTRACT: extract *.bikey files from source directory to target directory
UPDATE: check for updates
COMMANDS: display commands
VERSION: display version
QUIT: quit

Please enter a command =
```

### Run as a command

Once you have setup your arma3sync repository, you may use arma3sync as a command by passing your arguments after the image name. This time, the `-it` parameter is not required, unless you want to provide the `-console` argument:

```console
$ docker run --name some-arma3sync arwynfr/arma3sync -build repository-name
Building repository: repository-name
...
```

Unfortunately, **not all interactive commands are available** as arguments. This is caused by limitations of the arma3sync software itself which do not support them. However, if you need a limited amount of automatization, arma3sync-docker is able to create a repository on startup by provinding a few environment variables (see below).

### Environment variables

Arma3sync-docker will use the following variables to try it's best to initialize a repository. All you have to do is to provide the follwing environment variables with values. The best way to do so is by creating a file containing all values under the `key=value` format:

```console
$ cat ./arma3sync.env
ARMA3SYNC_NAME=test
...

$ docker run --name some-arma3sync --env-file ./arma3sync.env arwynfr/arma3sync -build test
ArmA3Sync Installed version = 1.6.97
JRE installed version = 1.8.0_181
OS Name = Linux
...
Create a new repository
Enter repository name: test
...
Building repository: test
...
```

**`ARMA3SYNC_NAME`**

This variable is the name of a repository that will be created by arma3sync-docker when starting. This repository will be created on every container start, unless a repository with this name already exists. It must be a valid identifier and this name can used for other commands such as `-build`. If blank, the container will ignore the repository creation and proceed as usual.

**`ARMA3SYNC_PROTOCOL`**

The protocol to use for data transfer with this repository. Values must be one of: `FTP`, `HTTP` or `HTTPS`.

**`ARMA3SYNC_URL`**

The repository URL, including the protocol part, such as `http://www.sonsofexiled.fr/repository`. This URL is the remote URL used by clients to download data from your repository. The autoconfig file is stored at `${ARMA3SYNC_URL}/.a3s/autoconfig`. Used both for creating a local repository that remote clients will sync to (using `-build`), or for creating a local copy of a remote repository that you want to download (using `-sync`).

**`ARMA3SYNC_PORT`**

The port used by client when trying to connect to the repository. If empty, it will use the default port according to the specified protocol.

**`ARMA3SYNC_LOGIN`** and **`ARMA3SYNC_PASSWD`**

If the connexion requires an authentication, you have to provide the credentials. If anonymous connexion is allowed, set those two variables to *empty*. Arma3sync-docker will behave correctly if you don't provide the `anonymous` value required by arma3sync.

**`ARMA3SYNC_PATH`**

The absolute path where your local mod files are stored.

### Volumes

Arma3Sync stores data regarding repositories, changelog and versions information. All data is stored in the `/data` directory.

Although bind mounting a host directory works, it is not the recommended docker-way to do this. You may create a docker volume using the `docker volume create volume-name` command instead, and mount that volume through the `-v volume-name:/data` option.

If you don't, docker will create an anonymous volume that will be bound automatically. This will allow you to perist data through using this image, unless you prune or delete the volume.

Regarding mod files, the Dockerfile does not create a specific volume. You can either bind mount a host directory or a volume depending on the way you want to manage your files.

### Using [`docker-compose`](https://docs.docker.com/compose/)

A good way of setting up an arma3sync repository with this docker image is by creating a docker-compose project that binds the arma3sync-docker image to a web server. For this, create a `docker-compose.yml` file such as this one:

```yaml
version: '3'

volumes:
  sync:

services:
  web:
    image: httpd
    restart: unless-stopped
    volumes:
      - /home/mods:/usr/local/apache2/htdocs/files

  sync:
    image: arwynfr/arma3sync
    command: ["-build" "example"]
    environment:
      - ARMA3SYNC_NAME=example
      - ARMA3SYNC_PROTOCOL=HTTP
      - ARMA3SYNC_URL=http://sonsofexiled.fr/files
      - ARMA3SYNC_PATH=/sources
    volumes:
      - /home/mods:/sources
      - sync:/data
```

Run the docker-compose project with `docker-compose up -d`. Your repository will be accessible with this autoconfig url: `http://sonsofexiled.fr/files/.a3s/autoconfig` after the arma3sync-docker image has built your repository. The webserver will start before the repository is built, but the autoconfig file is written at the end of the building process. Once the clients can download the file, everything is ready.

Whenever you want to update you mods, follow this procedure :

- stop the web server with `docker-compose stop web`
- delete and replace mods you want in `/home/mods`
- run `docker-compose run sync` to update your arma3sync repository
- start the web server with `docker-compose start web`

## Contributing

You may contribute to the project either by:

- Submiting issues and request features on github
- Forking the github repository and make pull requests

## License

This software is a derivative work from Arma3Sync, whose license requires us to licence under the same or a compatible one. This is why arma3sync-docker is licensed under the terms of the [GNU GPL v3](https://github.com/ArwynFr/arma3sync-docker/blob/master/LICENSE).