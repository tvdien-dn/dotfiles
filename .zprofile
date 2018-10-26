function get_last_download(){
  ls -t ~/Downloads|head -1 | awk '{system("mv -v ~/Downloads/" $0 " .");}'
}

function quick_less() {
  BUFFER=`find $(pwd) ! -path '*.git*' -type f|fzf --reverse --preview "less {}"`
  BUFFER="less "$BUFFER
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N quick_less
bindkey '^F' quick_less

## fzf-tweak (https://github.com/junegunn/fzf/wiki/examples#git)

## Crtl-Rで履歴検索 (fzf)
function fzf-history-selection() {
    BUFFER=$(history -n -r 1 | fzf --reverse --no-sort +m --color 16 --query "$LBUFFER" --prompt="History > ")
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

fcs() {
  local commits commit
  commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
  echo -n $(echo "$commit" | sed "s/ .*//")
}

fbr() {
  local branches branch
  # branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  # branch=$(echo "$branches" |
  #          fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

fe() {
  emacsclient -nw $(fzf +m --reverse --preview "/Users/mars_tran/dotfiles/src-hilite-lesspipe.sh {}")
}

function git() { hub "$@" }

fghost() {
  local script_dictionary_file="~/jp_projects/osascripts/osascripts"
  if [ "$1" = "--edit" ]; then
    emacsclient -c -t $script_dictionary_file
  else
    local order
    # order=$(cat ~/jp_projects/osascripts/osascripts |fzf|gsed -e 's/\((\|"\|)\)/\\\1/g')
    order=$(cat ~/jp_projects/osascripts/osascripts |fzf)
    local my_cmd
    my_cmd="osascript -e '$order'"
    ssh taopaipai $my_cmd
  fi
}

showSSH() {
    local search_options=$1
    for item in `find $HOME/.ssh/ -type f -name '*.conf' -o -name 'config'` ; do
        local result=$(gsed -n -e "/^Host $search_options.*/,/^\n$/p;/^\n$/q" $item)
        if [ ! $result = '' ]; then
          echo "----- IN $item -----"
          echo $result
        fi
    done
}
alias fssh='ssh $(echo `cat ~/.ssh/config ~/.ssh/conf.d/*.conf|gsed -n -e "/^Host / { s/^Host \(.\+\)$/\1/g; /\*/d; s/ /\n/g;p }"|fzf --reverse`)'
alias fdc='docker container ls -a|fzf -m --reverse|cut -d " " -f1|sed -e ":a" -e "N" -e "$!ba" -e "s/\n/ /g"'
alias revert-tree="sort|gsed -e '1d; s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'"
alias rcolor="gsed -r 's/\x1B\[[0-9;]+[mGK]//g'"
alias tree='tree -C --dirsfirst'
alias mycli57='mycli -uroot -P3357 --prompt="\u@\h:\d\n>"'
alias mycli56='mycli -uroot -P3356 --prompt="\u@\h:\d\n>"'
# alias e='emacsclient -c -t --alternate-editor='