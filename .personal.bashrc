# .bashrc

export GITHUB_AUTH_TOKEN=490c10746d7fc9fcbc393338fd476486757d57ab
export GITHUB_USERNAME=brandon-logan
export IMAGE_SERVER_USERNAME=brandon.logan@ibm
export IMAGE_SERVER_PASSWORD=9efa6688f64b30486356294c6c24cd6285e5e5ad
export IMAGE_SERVER_EMAIL=brandon.logan@ibm.com
export IMAGE_SERVER=ibm-docker-wrigley.bintray.io


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Git promt to show branch name to prompt and color coded status

function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi=42
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi=43
        else
            local ansi=41
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=' '
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        echo -n '\[\e[0;37;'"$ansi"';1m\]'"$branch"'\[\e[0m\] '
    fi
}
function _prompt_command() {
    PS1="`_git_prompt`"'\u> \[\e[1;34m\]\w \$\[\e[0m\] '
}
PROMPT_COMMAND=_prompt_command


# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

export PATH=$PATH:/usr/local/go/bin
export GOPATH="$HOME/go"
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:"/home/brandon/bin"
export ICP_EMAIL="brandon.logan@ibm.com"
export DOCKER_REG_PASSWORD="drag-banshee-peace-macaroni"
export WRIGLEY_PATH="/home/brandon/wrigley"
export KUBE_EDITOR='vim'

export ICP_ZEC_ENDPOINT_ROOT_CERT_PATH=/Users/owen/repos/wrigley/icp-zec/minikube/trusted-roots.crt
export ICP_JOB_TIMEOUT_INTERVAL=1
export ICP_ZEC_PORT=30060
export ICP_ZEC_IP=192.168.99.100
export ICP_ZEC_ENDPOINT=kube-test.iaasdev.cloud.ibm.com

function setup_k8s_clients() {
    source ~/venvs/ansible/bin/activate
    ~/wrigley/cicd-tools/scripts/setup-k8s-client.sh durable
    ~/wrigley/cicd-tools/scripts/setup-k8s-client.sh vpcbeta-durable-bm
    ~/wrigley/cicd-tools/scripts/setup-k8s-client.sh zncp-dal10-int01 
    kubectl config use-context minikube
    deactivate
}
