# .bash_aliases

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias git-rm-branches="git branch | grep -v "master" | xargs git branch -D"
alias vi=vim

alias docker-rm-all='docker rm $(docker ps -a -q)'
alias docker-rmi-all='docker rmi $(docker images -q)'
alias minikube-start='minikube start --vm-driver=kvm2 --cpus=4 --memory=8192'
alias minikube-docker='eval $(minikube docker-env)'

alias pyclean='find . -name "*.pyc" -delete; find . -depth -name "__pycache__" -exec rm -rf "{}" \;'

