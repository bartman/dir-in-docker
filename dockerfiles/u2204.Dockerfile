#FROM debian:testing
FROM ubuntu:22.04

# all the variables passed in from the shell script
ARG UID
ARG GID
ARG USERNAME
ARG WORKDIR
ARG EXTRA_ENV
ARG GIT_EMAIL
ARG GIT_NAME
ARG EXTRA_PACKAGES

# Install curl, Node.js (LTS version 20), and npm in one layer to reduce image size
RUN apt-get update && \
    apt-get install -y curl ca-certificates sudo neovim jq git kitty-terminfo ${EXTRA_PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# this lets us have the same UID:GID in the container
RUN getent group $GID || groupadd -g $GID $USERNAME
RUN getent passwd ubuntu && userdel ubuntu || true
RUN useradd -u $UID -g $GID -m -s /bin/bash $USERNAME
RUN echo "$USERNAME  ALL=(ALL:ALL)  NOPASSWD:SETENV: ALL" > "/etc/sudoers.d/$USERNAME"
USER $USERNAME

# Make git usable inside container
RUN git config --global --add safe.directory ${WORKDIR}

ENV GIT_EMAIL=${GIT_EMAIL}
ENV GIT_NAME=${GIT_NAME}
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global user.name "${GIT_NAME}"

WORKDIR ${WORKDIR}

# Keep running
CMD ["tail", "-f", "/dev/null"]
