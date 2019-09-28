#!/bin/bash

WHITE="${fg[white]}"
RED="${fg[red]}"
YELLOW="${fg[yellow]}"
CYAN="${fg[cyan]}"
GREEN="${fg[green]}"

ERROR="[${fg[red]}FAIL${fg[white]}]"
WARN="[${fg[yellow]}WARN${fg[white]}]"
INFO="[${fg[cyan]}INFO${fg[white]}]"
SUCCESS="[${fg[green]}DONE${fg[white]}]"

# default parameters
NEWTERMURL="https://seanhelling.com/sh/newterm"
THEMEURL="https://seanhelling.com/sh/seanthree.zsh-theme"
ZSHRCURL="https://seanhelling.com/sh/zshrc-standard"

OPTIND=1
while getopts ":n:t:z:fvh" opt; do
  case $opt in
    n)
      NEWTERMURL="https://seanhelling.com/sh/"$OPTARG >&2
      ;;
    t)
      THEMEURL="https://seanhelling.com/sh/"$OPTARG".zsh-theme" >&2
      ;;
    z)
      ZSHRCURL="https://seanhelling.com/sh/"$OPTARG >&2
      ;;
    f)
      RUNASROOT=1
      ;;
    v)
      VERBOSE=1
      ;;
    h)
      echo "termupdate usage:"
      echo "This script is not intended for initial installs. For that, use https://seanhelling.com/sh/prep.sh"
      echo "It will update your terminal with the default scripts, unless you specify parameters."
      echo "  -n <newterm>: Download and install the specified .newterm file."
      echo "  -t <theme>: Download and install the specified theme file."
      echo "  -z <zshrc>: Download and install the specified .zshrc file."
      echo "  -v: Show informational messages."
      echo "  -f: Allow execution as root."
      return 0
      ;;
    \?)
      echo "$ERROR Invalid option: -$OPTARG" >&2
      return 1
      ;;
    :)
      echo "$ERROR Option -$OPTARG requires an argument." >&2
      return 1
      ;;
  esac
done

NEWTERMFILENAME=$(echo $NEWTERMURL | sed 's/.*\///')
THEMEFILENAME=$(echo $THEMEURL | sed 's/.*\///')
THEMEFILENAMESIMPLE=$(echo $THEMEFILENAME | sed 's/\..*//')
ZSHRCFILENAME=$(echo $ZSHRCURL | sed 's/.*\///')

if [[ $UID -eq 0 && $RUNASROOT -ne 1 ]]; then
    echo "$ERROR This script must not be run as root!"
    return 1
elif [[ $UID -eq 0 && $RUNASROOT -eq 1 ]]; then
    echo "$WARN Script is being run as root!"
    echo "$WARN Shell may not function as intended for unprivileged users."
fi

if [[ -d ~/.zsh-backup ]]; then
    [[ $VERBOSE -eq 1 ]] && echo "$INFO Found directory $(readlink -f ~/.zsh-backup)"
else
    echo "$WARN Directory $(readlink -f ~/.zsh-backup) does not exist."
    mkdir -p ~/.zsh-backup 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "$ERROR Could not create directory $(readlink -f ~/.zsh-backup). Unable to create backups. returning..."
        return 1
    fi
fi
[[ $VERBOSE -eq 1 ]] && echo "$INFO Backing up .newterm to $(readlink -f ~/.zsh-backup/)/"
cp ~/.newterm ~/.zsh-backup/.newterm-`date +"%Y%m%d-%H%M%S"`-backup 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$WARN$YELLOW Backup failed:$WHITE .newterm"
fi
[[ $VERBOSE -eq 1 ]] && echo "$INFO Installing $NEWTERMFILENAME from seanhelling.com"
curl -Lsfo ~/.newterm $NEWTERMURL
if [[ $? -eq 0 && -s ~/.newterm ]]; then
    echo "$SUCCESS Installed .newterm"
    chmod +x ~/.newterm
else
    echo "$ERROR Failed to get $NEWTERMFILENAME from $NEWTERMURL!"
    return 1
fi
[[ $VERBOSE -eq 1 ]] && echo "$INFO Backing up $THEMEFILENAME to $(readlink -f ~/.zsh-backup/)/"
cp ~/.oh-my-zsh/themes/$THEMEFILENAME ~/.zsh-backup/$THEMEFILENAME-`date +"%Y%m%d-%H%M%S"`-backup 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$WARN$YELLOW Backup failed:$WHITE $THEMEFILENAME"
fi
[[ $VERBOSE -eq 1 ]] && echo "$INFO Installing $THEMEFILENAME from seanhelling.com"
curl -Lsfo ~/.oh-my-zsh/themes/$THEMEFILENAME $THEMEURL
if [[ $? -eq 0 && -s ~/.oh-my-zsh/themes/$THEMEFILENAME ]]; then
    echo "$SUCCESS Installed $THEMEFILENAME"
    chmod +x ~/.oh-my-zsh/themes/$THEMEFILENAME
else
    echo "$ERROR Failed to get $THEMEFILENAME from $THEMEURL!"
    return 1
fi
if [[ -f ~/.zshrc ]]; then
    [[ $VERBOSE -eq 1 ]] && echo "$INFO Existing .zshrc found. Attempting to preserve color settings."
    COLOR_STRING=$(cat ~/.zshrc | grep "export ZSHCOLOR=")
    if [[ $? -ne 0 ]]; then
        echo "$WARN Failed to obtain color settings; defaulting to cyan."
        COLOR_STRING="export ZSHCOLOR=\"cyan\""
    else
        [[ $VERBOSE -eq 1 ]] && echo "$INFO Existing color settings have been preserved. ($(echo $COLOR_STRING | sed 's/export ZSHCOLOR=//' | sed 's/"//' | sed 's/"//' ))"
    fi
else
    [[ $VERBOSE -eq 1 ]] && echo "$INFO No .zshrc was found, terminal color settings will be defaulted to cyan."
    COLOR_STRING="export ZSHCOLOR=\"cyan\""
fi
[[ $VERBOSE -eq 1 ]] && echo "$INFO Backing up .zshrc to $(readlink -f ~/.zsh-backup/)/"
cp ~/.zshrc ~/.zsh-backup/.zshrc-`date +"%Y%m%d-%H%M%S"`-backup 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$WARN$YELLOW Backup failed:$WHITE .zshrc"
fi
[[ $VERBOSE -eq 1 ]] && echo "$INFO Installing $ZSHRCFILENAME from seanhelling.com"
curl -Lsfo ~/.zshrc $ZSHRCURL
if [[ $? -eq 0 && -s ~/.zshrc ]]; then
    echo "$SUCCESS Installed .zshrc"
    chmod +x ~/.zshrc
else
    echo "$ERROR Failed to get $ZSHRCFILENAME from $ZSHRCURL!"
    return 1
fi
# grab the new .zshrc lines, get the incomplete .zshrc, and concatenate them
echo $(echo $COLOR_STRING)"\n"$(echo "export ZSH_THEME=\"$THEMEFILENAMESIMPLE\"") | cat - ~/.zshrc > ~/.zsh-backup/temp && mv ~/.zsh-backup/temp ~/.zshrc

if [[ -r ~/.zshrc && -r ~/.newterm && -r ~/.oh-my-zsh/themes/$THEMEFILENAME && $? -eq 0 ]]; then
    echo "$SUCCESS ${GREEN}Update completed successfully.${WHITE}"
    exec zsh
else
    echo "$ERROR Update did not complete successfully. Please check the results manually."
    return 1
fi