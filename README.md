# dir-in-docker

`did` starts a docker container with the current directory mapped inside.
The container has no access to any files except those found in the PWD.
This may be useful if you just want to quickly run some command in
isolation or don't trust the software you're building/running.

The container is named such that returning from this same path will
invoke the same container, unless you clean things up.

This work is a continuation (or tangent) of my [grok-cli-wrapper](https://github.com/bartman/grok-cli-wrapper)
script.  That was specific to wrapping [grok-cli](https://github.com/superagent-ai/grok-cli/) in docker,
but `did` is generic and should work for anything you want to contain.

## how to use

Setup an alias to run the script from where you cloned it:
```sh
$ git clone https://github.com/bartman/dir-in-docker.git ~/.local/did
$ alias did=~/.local/did/did
```

then you can use it from anywhere

```sh
# go to the directory you want to be visible inside the container
$ cd my-thing
$ did -X build
$ did -X start
$ did enter
# once in the container you can edit files, etc
$ sudo apt install x11-apps
$ xeyes
```

You can combine multiple steps into one command with `,` as a separator...

```sh
$ did -X build , start , enter
```

## extras

An example use case... I downloaded some Intel FPGA build tool (Quartus) and I need
to run an install.  I created a shared directory, that I will make available to the
container.  So the container will only get the current directory, and the `~/altera`
directory.

```sh
$ mkdir ~/altera
$ did -X -N -v ~/altera -p x11-apps -p libglib2.0-0t64 -p libfontconfig build , start , enter
# in the container...
$ ./qinst-linux-25.1.1-125.run
# and after...
$ did down , remove
```

Each subsequent time I want to run the software, I can now do it from different locations,
but passing in the `~/altera` path where the software is installed.

```sh
$ cd ~/work/some-fpga-project
$ did -X -v ~/altera -p x11-apps -p libglib2.0-0t64 -p libfontconfig build , start , enter
```

## targets

Built-in Dockerfiles live in `dockerfiles/`.  A matching `./<target>.Dockerfile` in the
current directory overrides the built-in one.

| target   | base image            | notes                          |
|----------|-----------------------|--------------------------------|
| debian   | debian:testing        | minimal default-style image    |
| u2204    | ubuntu:22.04          | Ubuntu LTS                     |
| opencode | did-opencode-base     | opencode + bun (shared base)   |
| pi       | debian:testing        | pi coding agent                |

```sh
$ did -t u2204 build , start , enter
```

### shared base images

If a target `NAME` has a companion `NAME-base.Dockerfile` (next to `NAME.Dockerfile`),
`did build` will ensure a shared image `did-NAME-base` exists before building the
per-project image.

- First build (or after the base was removed): builds `did-NAME-base`, then the project image.
- Later builds in other directories: reuse the same base layers; only the thin project
  image is rebuilt.
- Force a fresh base with `--rebuild`:

```sh
$ did --rebuild -t opencode build
```

`NAME-base` Dockerfiles are not listed as selectable targets; they are only built as
dependencies of `NAME`. The project Dockerfile should `FROM did-NAME-base` (for example
`FROM did-opencode-base`).

## online help

Here is the online help...

```
❯ did -h
did [ [options] <command> [command-options] ] [ , ... ]

    Options:

        -t <target>    - target to use, default: first available target
        -n <name>      - name to use, default: basename of PWD

        -d <dir>       - [build] local *.Dockerfile location, default: PWD
        -D <dir>       - [build] system *.Dockerfile location, default:
                           <install-dir>/dockerfiles
        -p <pkg>       - [build] add this package to the build
        --rebuild      - [build] force rebuild of shared base image (did-NAME-base)
                         when NAME-base.Dockerfile exists

        -v <dir>       - [start] make this path also visible in container
        -N             - [start] enable host networking (reduces isolation)
        -E <port>      - [start] expose container port to host (host:container)
        -P             - [start] enable perf in docker
        -X             - [start] enable X forwarding (uses xhost +local:docker)

    Available commands:

        build          - create a dev image (auto-builds did-NAME-base if needed)
        remove         - remove a dev image
        start          - start the container (create or restart)
        stop           - stop the container (keeps it for restart)
        down           - stop and remove the container
        status         - check if built/running
        connect        - get a shell in the running container (alias: enter)
        run     <cmd>  - run a command in the running container

        , used to separate multiple commands

    Available targets:

        debian
        opencode
        pi
        u2204

```

## TODO

- this is getting complex -- consider python or rust.
- have a config file the script reads: ENV vars to copy, files to copy, shared volumes to mount, etc
- generate a custom Dockerfile instead of using `ENV` variables to pass info to an existing Dockerfile.
  maybe use some templating engine (python/rust).
```
