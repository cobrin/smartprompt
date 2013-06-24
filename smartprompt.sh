# Creates a new git sensitive prompt with different information based on
# whether you are in a schroot or python virtualenv or a
# regular bash session.
#
# Load it from your .bashrc with the following:
#
# if [ -f  ~/bin/smartprompt.sh ]; then
#   . ~/bin/smartprompt.sh
# fi

### --------------------------
# smartprompt.sh

# Definitions
        RED="\[\033[0;31m\]"
   BOLD_RED="\[\033[1;31m\]"
     YELLOW="\[\033[0;33m\]"
BOLD_YELLOW="\[\033[1;33m\]"
      GREEN="\[\033[0;32m\]"
 BOLD_GREEN="\[\033[1;32m\]"
       BLUE="\[\033[0;34m\]"
  BOLD_BLUE="\[\033[1;34m\]"
      WHITE="\[\033[1;37m\]"
  BOLD_GRAY="\[\033[0;37m\]"
     PURPLE="\[\033[0;35m\]"
BOLD_PURPLE="\[\033[1;35m\]"
 COLOR_NONE="\[\e[0m\]"
FG_RED_BG_WHITE="\[\033[1;31;47m\]"
      UNAME="$(id -un 2> /dev/null)"

function parse_git_branch {
 
  git rev-parse --git-dir &> /dev/null
  machinename="$(hostname 2> /dev/null)"
  git_status="$(git status 2> /dev/null)"
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern="# Your branch is (.*) of"
  diverge_pattern="# Your branch and (.*) have diverged"
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    state="${BOLD_RED}⚡"
  fi
  # add an else if or two here if you want to get more specific
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
    remote="${YELLOW}↑"
        else
    remote="${YELLOW}↓"
        fi
    fi
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}↕"
  fi
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo " (${branch})${remote}${state}"
  fi
}

function prompt_func() {
    previous_return_value=$?;

    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -r /etc/debian_chroot ]
    then
        debian_chroot="$(cat /etc/debian_chroot 2> /dev/null)"
        prompt="${FG_RED_BG_WHITE}$debian_chroot${COLOR_NONE} ${BOLD_YELLOW}$(hostname)${BOLD_GREEN}$(parse_git_branch)${TITLEBAR}${BOLD_BLUE}[${BOLD_RED}\w${BOLD_BLUE}]${COLOR_NONE}"
    elif [ -n "$VIRTUAL_ENV" ]
    then
        virtualenviro="$(showvirtualenv 2> /dev/null)"
        prompt="${FG_RED_BG_WHITE}$virtualenviro${COLOR_NONE} ${BOLD_YELLOW}$(hostname)${TITLEBAR}${BOLD_BLUE}[${BOLD_GREEN}\w${BOLD_BLUE}]${COLOR_NONE}"
    else
        prompt="${BOLD_YELLOW}$(hostname):${BOLD_RED}${UNAME}${BOLD_GREEN}$(parse_git_branch)${TITLEBAR}${BOLD_BLUE}[${BOLD_RED}\w${BOLD_BLUE}]${COLOR_NONE}"
    fi

    if test $previous_return_value -eq 0
    then
        PS1="${prompt}➔ "
    else
        PS1="${prompt}${BOLD_RED}➔${COLOR_NONE} "
    fi
}

PROMPT_COMMAND=prompt_func
