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

# omp-base already created USERNAME and switched to it
USER root

# Install extra packages
RUN if [ -n "$EXTRA_PACKAGES" ]; then \
      apt-get update && apt-get install -y $EXTRA_PACKAGES && \
      { if [ -x $WORKDIR/dependencies.sh ] ; then ./$WORKDIR/dependencies.sh ; fi ; } && \
      apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

USER $USERNAME

# must have a .omp/agent directory with:
#
#    .omp/agent/config.yml
#    .omp/agent/models.yml
#    .omp/agent/secrets.yml
#
# auth is NOT baked in (omp stores it in agent.db via /login);
# pass provider keys as env vars (e.g. -e XAI_API_KEY) or log in
# on first entry.

COPY --chown=$UID:$GID .omp/agent/config.yml*  /home/$USERNAME/.omp/agent/
COPY --chown=$UID:$GID .omp/agent/models.yml*  /home/$USERNAME/.omp/agent/
COPY --chown=$UID:$GID .omp/agent/secrets.yml* /home/$USERNAME/.omp/agent/

WORKDIR ${WORKDIR}

# Keep running
CMD ["tail", "-f", "/dev/null"]
