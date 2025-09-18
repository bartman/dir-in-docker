# dir-in-container

`did` starts a docker container with the current directory mapped inside.
The container has no access to any files except those found in the PWD.
This made be useful if you just want to quickly run some command in
isolation or don't trust the software you're building/running.

The container is named such that returning from this same path will
invoke the same container, unless you clean things up.

This work is continuation (or tangent) of my [grok-cli-wrapper](https://github.com/bartman/grok-cli-wrapper)
script.  This was specific to wrapping [grok-cli](https://github.com/superagent-ai/grok-cli/) in docker,
but `did` is generic and should work for anything you want to contain.

## how to use

Setup an alias to run the script form where you cloned it:
```sh
$ git clone https://github.com/bartman/dir-in-docker.git ~/.local/did
$ alias did=~/.local/did/did
```

then you can use it from anywhere

```sh
# go to the directory you want to be visible inside the container
$ cd my-thing
$ did -x build
$ did -x start
$ did enter
# once in the container you can edit files, etc
$ sudo apt install x11-apps
$ xeyes
```

You can combine multiple steps into one command with `,` as a separator...

```sh
$ did -x build , start , enter
```

## extras

An example use case... I downloaded some Intel FPGA build tool (Quartus) and I need
to run an install.  I created a shared directory, that I will make available to the
container.  So the container will only get the current directory, and the `~/altera`
directory.

```sh
$ mkdir ~/altera
$ did -x -v ~/altera -p x11-apps -p libglib2.0-0t64 -p libfontconfig build , start , enter
# in the container...
$ ./qinst-linux-25.1.1-125.run
# and after...
$ did stop , rm
```

Each subsequent time I want to run the software, I can now do it from different locations,
but passing in the `~/altera` path where the software is installed.

```sh
$ cd ~/work/some-fpga-project
$ did -x -v ~/altera -p x11-apps -p libglib2.0-0t64 -p libfontconfig build , start , enter
```

## online help

Here is the online help...

```
❯ did -h
did [ [options] <command> [command-options] ] [ , ... ]

    Options:

        -t <target>    - target to use, default: debian
        -p <project>   - target to use, default: dir-in-docker
        -d <dir>       - Dockerfile location, default:
                           /home/bart/proj/dir-in-docker/dockerfiles
        -x             - enable X forwarding (use with start/stop)

    Available commands:

        build          - create a dev image
        remove         - remove a dev image
        start          - start the container
        stop           - stop the container
        status         - check if built/running
        connect        - get a shell in the container
        run     <cmd>  - run a command in the container

        , used to separate multiple commands

    Available targets:

        debian

```

## TODO

- this is getting complex -- consider python or rust.
- have a config file the script reads: ENV vars to copy, files to copy, shared volumes to mount, etc
- generate a custom Dockerfile instead of using `ENV` variables to pass info to an existing Dockerfile.
  maybe use some templating engine (python/rust).
