ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive

USER root

SHELL ["/bin/bash", "-c"]

# --- Handle user creation ---
RUN if id -u $USER_UID ; then userdel "$(id -un $USER_UID)" ; fi

# check if user exists if not create it
RUN if id -u $USERNAME >/dev/null 2>&1; then \
        echo "User $USERNAME already exists"; \
    else \
        groupadd --gid $USER_GID $USERNAME && \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
        echo "User $USERNAME created"; fi

# --- System setup ---
RUN apt-get update -y
RUN apt-get install tmux tmuxinator -y

##### NVIM setup #####

WORKDIR /home/$USERNAME

COPY ./setup_nvim_for_docker.bash .setup_nvim_for_docker.bash 
RUN chown $USERNAME:$USERNAME .setup_nvim_for_docker.bash
RUN chmod +x .setup_nvim_for_docker.bash
RUN ./.setup_nvim_for_docker.bash
RUN rm .setup_nvim_for_docker.bash
RUN mkdir -p /home/$USERNAME/.config
RUN mkdir -p /home/$USERNAME/.local
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/.local
RUN touch /home/$USERNAME/.gitconfig_local

USER $USERNAME
RUN git config --global --add safe.directory '*'

RUN echo 'export PS1="[\u@\h \W] 🐳 "' >> /home/$USERNAME/.bashrc
RUN echo "source /home/$USERNAME/.complementary_bashrc" >> /home/$USERNAME/.bashrc


