# grok-cli-wrapper

This script builds a Docker container, installs [grok-cli](https://github.com/superagent-ai/grok-cli/) in it,
and maps the current directory into the container.

This should make it relatively safe to run agentic work on your current repository.

The first time you must build and start the container.

- `grok-cli-wrapper deb build` - builds the docker container
- `grok-cli-wrapper deb start` - launches it
- `grok-cli-wrapper deb enter` - enters the container (from multiple terminals if you wish)

Your `~/.grok/user-settings.json` will be copied into the container,
or created if you have `GROK_API_KEY` or `XAI_API_KEY` environment variable set.

In the container, just run `grok`.

## TODO

- this is getting complex -- consider python or rust.
- have a config file the script reads: ENV vars to copy, files to copy, shared volumes to mount, etc
- generate a custom Dockerfile instead of using `ENV` variables to pass info to an existing Dockerfile.
  maybe use some templating engine (python/rust).
