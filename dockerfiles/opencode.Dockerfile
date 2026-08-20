ARG BASE=did-will-override-this-with-a-good-name
FROM ${BASE}

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

# opencode-base already created USERNAME and switched to it
USER root

# Install extra packages
RUN if [ -n "$EXTRA_PACKAGES" ]; then \
      apt-get update && apt-get install -y $EXTRA_PACKAGES && \
      { if [ -x dependencies.sh ] ; then ./dependencies.sh ; fi ; } && \
      apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

USER $USERNAME

# must have an .opencode directory with:
#
#    .opencode/auth.json
#    .opencode/opencode.jsonc
#    .opencode/skills/
#

COPY --chown=$UID:$GID .opencode/auth.json*      /home/$USERNAME/.local/share/opencode/
COPY --chown=$UID:$GID .opencode/opencode.jsonc* /home/$USERNAME/.config/opencode/
COPY --chown=$UID:$GID .opencode/skills          /home/$USERNAME/.config/opencode/skills/

WORKDIR ${WORKDIR}

# Keep running
CMD ["tail", "-f", "/dev/null"]
