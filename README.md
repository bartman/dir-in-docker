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

## TODO

- this is getting complex -- consider python or rust.
- have a config file the script reads: ENV vars to copy, files to copy, shared volumes to mount, etc
- generate a custom Dockerfile instead of using `ENV` variables to pass info to an existing Dockerfile.
  maybe use some templating engine (python/rust).
