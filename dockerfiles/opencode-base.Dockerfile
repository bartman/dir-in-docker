FROM debian:testing

# all the variables passed in from the shell script
ARG LANG

# Install common tools
RUN apt-get update && \
    apt-get install -y curl ca-certificates sudo neovim jq git kitty-terminfo \
        locales npm systemd-coredump linux-perf && \
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

