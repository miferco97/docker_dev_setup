#!/bin/bash

#check if root is the user

SUDO_PREAMBLE="sudo"
if [[ $(whoami) == "root" ]]; then
    SUDO_PREAMBLE=""
fi
$SUDO_PREAMBLE apt-get install -y lsb-release

UBUNTU_VERSION=$(lsb_release -a | grep Release | tr '.' ' ' | awk '{print $2}')

FORCE_PIP=""
if [[ $UBUNTU_VERSION -gt 22 ]]; then
  FORCE_PIP="--break-system-packages"
fi

echo "SUDO_PREAMBLE: $SUDO_PREAMBLE"
echo "UBUNTU_VERSION: $UBUNTU_VERSION"
echo "FORCE_PIP: $FORCE_PIP"

NODE_MAJOR=20

$SUDO_PREAMBLE apt-get update && apt-get install apt-utils software-properties-common ca-certificates curl gnupg -y
$SUDO_PREAMBLE add-apt-repository ppa:neovim-ppa/unstable && apt update 

# node js and pynvim for use nvim
$SUDO_PREAMBLE mkdir -p /etc/apt/keyrings
$SUDO_PREAMBLE curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | $SUDO_PREAMBLE gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
$SUDO_PREAMBLE echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | $SUDO_PREAMBLE tee /etc/apt/sources.list.d/nodesource.list

$SUDO_PREAMBLE apt-get update && $SUDO_PREAMBLE apt-get install neovim nodejs python3-pip -y
$SUDO_PREAMBLE apt-get install cpplint cppcheck -y
$SUDO_PREAMBLE apt-get install cmake-format -y
$SUDO_PREAMBLE apt-get install clang-format -y
$SUDO_PREAMBLE apt-get install clang-tidy -y
$SUDO_PREAMBLE apt-get install python3-pynvim -y

$SUDO_PREAMBLE apt-get install xclip ripgrep -y

$SUDO_PREAMBLE apt-get install cppcheck -y $FORCE_PIP
$SUDO_PREAMBLE pip install $FORCE_PIP cmakelint 
$SUDO_PREAMBLE pip install $FORCE_PIP cpplint

