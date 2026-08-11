FROM debian:testing

# all the variables passed in from the shell script
ARG UID
ARG GID
ARG USERNAME
ARG WORKDIR
ARG EXTRA_ENV
ARG GIT_EMAIL
ARG GIT_NAME
ARG EXTRA_PACKAGES

# Install curl, Node.js/npm, and common tools in one layer
RUN apt-get update && \
    apt-get install -y curl ca-certificates sudo neovim jq git kitty-terminfo \
        npm systemd-coredump linux-perf ripgrep fd-find \
        ${EXTRA_PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install pi coding agent
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# matching UID:GID so bind-mounted files stay owned by the host user
RUN getent group users || groupadd -g $GID users
RUN getent group $GID || groupadd -g $GID $USERNAME
RUN useradd -u $UID -g $GID -m -s /bin/bash $USERNAME
RUN echo "$USERNAME  ALL=(ALL:ALL)  NOPASSWD:SETENV: ALL" > "/etc/sudoers.d/$USERNAME"
USER $USERNAME

# Pi global config / sessions / auth live under ~/.pi/agent/
# Project-level config is expected under $WORKDIR/.pi/ (mounted from host)
RUN mkdir -p /home/$USERNAME/.pi/agent

# update user's bashrc
RUN echo "export PATH=\$PATH:~/bin:~/.local/bin" >> "/home/$USERNAME/.bashrc"

# Make git usable inside container
RUN git config --global --add safe.directory ${WORKDIR}

# install some pi packages
pi install npm:pi-meta-ai
pi install npm:pi-meta-oauth

ENV GIT_EMAIL=${GIT_EMAIL}
ENV GIT_NAME=${GIT_NAME}
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global user.name "${GIT_NAME}"

WORKDIR ${WORKDIR}

# Keep running (attach with docker exec / your launcher)
CMD ["tail", "-f", "/dev/null"]
