# by Sean Helling <sean@sfx.dev>
# Staticflux Development
# very heavily modified from something else

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}☢%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
alias ls="ls --color=auto -aG"

if [ -z "$ZSHCOLOR" ] 
then
    CUSER="cyan"
else
    CUSER=$ZSHCOLOR
fi
CROOT="red"

#function test_connected() {}
TEST_LOC=0

#TEST_LOC=1
#LOCATION="AZRAEL"

function get_ip() {
	OUTSIDE_IP=$(curl -s icanhazip.com | head -n1)
	INSIDE_IP=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++)if($i=="src")print $(i+1)}')
}

get_ip


function get_return() {
    E=$?
	if [ $E -ne 0 ]; then echo "%{${bg[red]}%}$E%{$reset_color%}";
 	else echo "%{${fg[green]}%}OK%{$reset_color%}";
	fi
}

UCOLOR="%(!.%{${fg[$CROOT]}%}.%{${fg[$CUSER]}%})"

PROMPT='%{${UCOLOR}%}[%{$reset_color%}%n@%m:%0~%{$reset_color%}%{${UCOLOR}%}%#%{$reset_color%}%{${UCOLOR}%}]%{$reset_color%}$(git_prompt_info) %{${UCOLOR}%}> %{$reset_color%}'

RPROMPT='%{${UCOLOR}%}[%{$reset_color%}`get_return` $INSIDE_IP %{${UCOLOR}%}|%{$reset_color%} $OUTSIDE_IP%{${UCOLOR}%}]%{$reset_color%}'
# some notes...
# left: %{${fg[COLOR]}%}  %{${UCOLOR}%}
# right: %{$reset_color%}
# Cloud Storage for Characters: ⪼ ⚡ ⫩ ⦁ ❖ ✓ ✗ ‽ ❯ ☢
