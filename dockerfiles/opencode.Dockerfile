FROM debian:testing

# all the variables passed in from the shell script
ARG UID
ARG GID
ARG USERNAME
ARG LANG
ARG WORKDIR
ARG EXTRA_ENV
ARG GIT_EMAIL
ARG GIT_NAME
ARG EXTRA_PACKAGES

# Install common tools
RUN apt-get update && \
    apt-get install -y curl ca-certificates sudo neovim jq git kitty-terminfo \
        locales npm systemd-coredump linux-perf \
        ${EXTRA_PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# enable host locale in the container
RUN if [ -n "$LANG" ] && [ "$LANG" != "C" ] && [ "$LANG" != "C.UTF-8" ]; then \
        sed -i "s|^# *${LANG} UTF-8|${LANG} UTF-8|" /etc/locale.gen || true; \
        grep -q "^${LANG} UTF-8" /etc/locale.gen || echo "${LANG} UTF-8" >> /etc/locale.gen; \
        locale-gen; \
    fi

# install bun
RUN npm install -g bun

# this lets us have the same UID:GID in the container
RUN getent group users || groupadd -g $GID users
RUN getent group $GID || groupadd -g $GID $USERNAME
RUN useradd -u $UID -g $GID -m -s /bin/bash $USERNAME
RUN echo "$USERNAME  ALL=(ALL:ALL)  NOPASSWD:SETENV: ALL" > "/etc/sudoers.d/$USERNAME"
USER $USERNAME

# must have an .opencode directory with:
#
#    .opencode/auth.json
#    .opencode/opencode.jsonc
#    .opencode/skills/
#

RUN mkdir -p /home/$USERNAME/.config/opencode /home/$USERNAME/.local/share/opencode

COPY --chown=$UID:$GID .opencode/auth.json*      /home/$USERNAME/.local/share/opencode/
COPY --chown=$UID:$GID .opencode/opencode.jsonc* /home/$USERNAME/.config/opencode/
COPY --chown=$UID:$GID .opencode/skills          /home/$USERNAME/.config/opencode/skills/

# update user's bashrc
RUN echo "export PATH=\$PATH:~/bin:~/.local/bin:~/.bun/bin" >> "/home/$USERNAME/.bashrc"
RUN if [ -n "$EXTRA_ENV" ]; then echo "export $EXTRA_ENV" >> "/home/$USERNAME/.bashrc"; fi

# install opencode
RUN bun install -g opencode-ai

# Make git usable inside container
RUN git config --global --add safe.directory ${WORKDIR}

ENV GIT_EMAIL=${GIT_EMAIL}
ENV GIT_NAME=${GIT_NAME}
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global user.name "${GIT_NAME}"

WORKDIR ${WORKDIR}

# Keep running
CMD ["tail", "-f", "/dev/null"]
