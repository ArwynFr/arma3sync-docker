# How to use arma3sync-docker

## Image settings

### Tags

Arma3sync-docker provides multiple tags allowing to run different combinations of the software and the java runtime versions. You can specify major or minor version of arma3sync and optionally major versions of the jre.

The complete list of tags is available on [the project's Docker hub page](https://hub.docker.com/r/arwynfr/arma3sync/tags).

For production usage, you should use `arwynfr/arma3sync:1.7.106-jre8`

#### OpenJDK versions
Arma3Sync-docker provides images for the following versions of the OpenJDK runtime:
*   jre8, version used by arma3sync developpers
*   jre17, current LTS version of the runtime

***Note:** Due to a bug in Github's runner engine matrix build system, I'm not able to provide shorter tags.*

#### Arma3sync versions
Arma3Sync-docker provides images for the following versions of Arma3Sync:
*   1.1.23, 1.1.24, 1.1.30
*   1.2.37, 1.2.38, 1.2.39, 1.2.40, 1.2.45, 1.2.46, 1.2.47, 1.2.48
*   1.3.49
*   1.4.53, 1.4.61, 1.4.63
*   1.5.73, 1.5.75, 1.5.84
*   1.7.99, 1.7.101, 1.7.103, 1.7.104, 1.7.106

***Note:** Arma3Sync 1.6 is not available because it uses Java EE components which are not available with recent jre version.*

### Environment variables

Arma3sync-docker can use the environment variables to to initialize a repository. All you have to do is to provide the follwing environment variables with values.

#### `ARMA3SYNC_NAME`

This variable is the name of a repository that will be created by arma3sync-docker when starting. This repository will be created on every container start, unless a repository with this name already exists. It must be a valid identifier and this name can used for other commands such as `-build`. If blank, the container will ignore the repository creation and proceed as usual.

#### `ARMA3SYNC_PROTOCOL`

The protocol to use for data transfer with this repository. Values must be one of: `FTP`, `HTTP` or `HTTPS`.

#### `ARMA3SYNC_URL`

The repository URL, including the protocol part, such as `http://www.sonsofexiled.fr/repository`. This URL is the remote URL used by clients to download data from your repository. The autoconfig file is stored at `${ARMA3SYNC_URL}/.a3s/autoconfig`. Used both for creating a local repository that remote clients will sync to (using `-build`), or for creating a local copy of a remote repository that you want to download (using `-sync`).

#### `ARMA3SYNC_PORT`

The port used by client when trying to connect to the repository. If empty, it will use the default port according to the specified protocol.

#### `ARMA3SYNC_LOGIN` and `ARMA3SYNC_PASSWD`

If the connexion requires an authentication, you have to provide the credentials. If anonymous connexion is allowed, set those two variables to *empty*. Arma3sync-docker will behave correctly if you don't provide the `anonymous` value required by arma3sync.

#### `ARMA3SYNC_PATH`

The absolute path where your local mod files are stored. Defaults to `/mods`

### Volumes

Arma3Sync stores data regarding repositories, changelog and versions information. All data is stored in the `/data` directory. This directory is made a volume in Dockerfile so that information can be stored outside the image file.

The `/mods` directory, although it shall contain mod data which are not part of the application itself, is **not** made a volume. You may still mount a volume on that directory (to share data with your www server container for instance), but you can also extend the image, copy your mod files into a child docker image if you want.

## Image usage

### Use arma3sync-docker interactively

The easiest way to using this image is by creating a container and runing it. This will start arma3sync in interactive mode just as if you just ran the `arma3sync-console.sh`. Do not forget to add the `-it` options or else the program will complain about being unable to read input.

```console
$ docker run -it --rm --volume=arma3sync-data:/data arwynfr/arma3sync:1.7
ArmA3Sync Installed version = 1.7.104
JRE installed version = 16.0.2
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

### Use arma3sync-docker as a command

Once you have setup your arma3sync repository, you may use arma3sync as a command by passing your arguments after the image name. This time, the `-it` parameter is not required, unless you want to provide the `-console` argument:

```console
$ docker run --rm --volume=arma3sync-data:/data arwynfr/arma3sync:1.7 -build repository-name
Building repository: repository-name
...
```

### Use arma3sync-docker in a docker stack

You can simplify arma3sync-docker usage by using a docker-compose to run it.

#### repository.env
```env
ARMA3SYNC_NAME=my-unit
ARMA3SYNC_PROTOCOL=HTTPS
ARMA3SYNC_URL=https://www.my-unit.com/repository
```

#### docker-compose.yml
```yml
version: "3.8"

volumes:
  data: # contains arma3sync repository information
  mods: # contains addons and used by www service
    external: true

services:
  arma3sync:
    image: arwynfr/arma3sync:1.7
    env_file: ./repository.env
    volumes:
      - data:/data
      - mods:/mods
```

Update files in the mods volume, then run this command to rebuild :
```console
$ docker-compose run --rm arma3sync -build my-unit
```
