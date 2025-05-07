
{{ % if nvim % }}
workdir /root/

run add-apt-repository ppa:neovim-ppa/unstable && apt update 
run apt-get install apt-utils software-properties-common ca-certificates curl gnupg -y

# node js and pynvim for use nvim
arg node_major=20
run mkdir -p /etc/apt/keyrings
run curl -fssl https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
run echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$node_major.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

run apt-get update 
run apt-get install neovim nodejs python3-pip -y
run pip3 install pynvim 

# this folders are for nvim
run mkdir .config
run mkdir .local/share -p

run apt-get install tmux tmuxinator -y

run apt-get install cpplint cppcheck -y
run pip install cmakelint -u

{{ % endif % }}
