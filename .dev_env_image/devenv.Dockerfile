ARG BASE_IMAGE

##### NVIM build stage #####
FROM $BASE_IMAGE AS nvim-builder

ENV DEBIAN_FRONTEND=noninteractive
ARG NVIM_VERSION=nightly

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    gettext \
    curl \
    unzip 

WORKDIR /build
RUN git clone --depth 1 --branch ${NVIM_VERSION} https://github.com/neovim/neovim.git
WORKDIR /build/neovim
RUN make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/opt/nvim install

##### Main image #####
FROM $BASE_IMAGE

ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive

USER root

SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install sudo -y

# --- Handle user creation ---
RUN if id -u $USER_UID ; then userdel "$(id -un $USER_UID)" ; fi

# check if user exists if not create it
RUN if id -u $USERNAME >/dev/null 2>&1; then \
        echo "User $USERNAME already exists"; \
    else \
        groupadd --gid $USER_GID $USERNAME && \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "User $USERNAME created"; fi

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# --- System setup ---
RUN apt-get update -y
RUN apt-get install tmux tmuxinator -y

##### NVIM setup #####

# Copy Neovim from builder stage
COPY --from=nvim-builder /opt/nvim /opt/nvim
ENV PATH="/opt/nvim/bin:${PATH}"

# Install Node.js
ARG NODE_MAJOR=20
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim dependencies and linting tools
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-pynvim \
    cppcheck \
    clang-format \
    clang-tidy \
    xclip \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Python linting tools
ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN pip install cmakelint cpplint cmake-format

WORKDIR /home/$USERNAME
RUN mkdir -p /home/$USERNAME/.config
RUN mkdir -p /home/$USERNAME/.local
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/.local
RUN touch /home/$USERNAME/.gitconfig_local

USER $USERNAME

## Claude setup #####

WORKDIR /home/$USERNAME
ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
RUN curl -fsSL https://claude.ai/install.sh | bash

##### Git setup #####
RUN git config --global --add safe.directory '*'
RUN echo -e '[include]\n    path = ~/.gitconfig_local' >> /home/$USERNAME/.gitconfig

RUN echo 'parse_git_branch() { git branch 2>/dev/null | grep "^\*" | sed "s/* / (/;s/$/)/" ; }' >> /home/$USERNAME/.bashrc
RUN echo 'root_icon() { [ "$(id -u)" -eq 0 ] && echo "⚡" ; }' >> /home/$USERNAME/.bashrc
RUN echo 'export PS1="🐳 \$(root_icon)[\[\e[1;36m\]${DEV_ENV_NAME:-docker}\[\e[0m\]] \[\e[1;34m\]\w\[\e[0;35m\]\$(parse_git_branch)\[\e[0m\] $ "' >> /home/$USERNAME/.bashrc
RUN echo "source /home/$USERNAME/.complementary_bashrc" >> /home/$USERNAME/.bashrc


