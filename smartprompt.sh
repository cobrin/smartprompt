#
# FILE:         smartprompt.sh
#
# Original version https://gist.github.com/kcoyner/5849796
# This version     https://github.com/cobrin/smartprompt.sh
#

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
   DARK_RED="\[\033[2;31m\]"
     YELLOW="\[\033[0;33m\]"
BOLD_YELLOW="\[\033[1;33m\]"
      GREEN="\[\033[0;32m\]"
 BOLD_GREEN="\[\033[1;32m\]"
       BLUE="\[\033[0;34m\]"
  BOLD_BLUE="\[\033[1;34m\]"
      WHITE="\[\033[1;37m\]"
  BOLD_GRAY="\[\033[0;37m\]"
  DARK_GRAY="\[\033[2;90m\]"
     PURPLE="\[\033[0;35m\]"
BOLD_PURPLE="\[\033[1;35m\]"
       CYAN="\[\033[0;36m\]"
  BOLD_CYAN="\[\033[1;36m\]"
 COLOR_NONE="\[\e[0m\]"
FG_RED_BG_WHITE="\[\033[1;31;47m\]"
      UNAME="$(id -un 2> /dev/null)"

if [ ${UNAME} -eq 0 ]; then
    USER_AT_HOST="${RED}\u${COLOR_NONE}@${BOLD_RED}\h${COLOR_NONE}"		# Steve's choice
#   USER_AT_HOST="${RED}\u${COLOR_NONE}@${BOLD_YELLOW}\h${COLOR_NONE}"		# Ian's choice
        else
    USER_AT_HOST="${CYAN}\u${COLOR_NONE}@${BOLD_CYAN}\h${COLOR_NONE}"		# Steve's choice
#   USER_AT_HOST="${BOLD_GRAY}\u${COLOR_NONE}@${BOLD_YELLOW}\h${COLOR_NONE}"	# Ian's choice
fi

function parse_git_branch {
  git rev-parse --git-dir &> /dev/null
# machinename="$(hostname 2> /dev/null)"
# # shorten hostname, but not used anyway
# machinename="$(hostname -s 2> /dev/null)"
  git_status="$(git status 2> /dev/null)"
  branch_pattern="^On branch ([^${IFS}]*)"
  remote_pattern="Your branch is (.*) of"
  diverge_pattern="Your branch and (.*) have diverged"
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
#   state="${BOLD_RED}⚡"
    # readline gets confused by some double-width unicode characters
    # so fool it into calculating line width correctly
    high_voltage_symbol=$'\u26a1'
    state="${BOLD_RED}\[$(tput sc)\]  \[$(tput rc)\]\[${high_voltage_symbol}\]"
  fi
  # add an else if or two here if you want to get more specific
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
#   remote="${YELLOW}↑"
    upwards_arrow_symbol=$'\u2191'
    remote="${YELLOW}${upwards_arrow_symbol}"
        else
#   remote="${YELLOW}↓"
    downwards_arrow_symbol=$'\u2193'
    remote="${BOLD_YELLOW}${downwards_arrow_symbol}"
        fi
    fi
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
#   remote="${YELLOW}↕"
    updown_arrow_symbol=$'\u2195'
    remote="${YELLOW}${updown_arrow_symbol}"
  fi
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo " (${branch})${remote}${state}"
  else : "No visible branches"
  fi
}

function prompt_func() {
    previous_return_value=$?;
    # set variable identifying the environment (used in the prompt below)

#   prompt=					# Ian's choice
    # optional prompt with timestamp
    prompt="[${GREEN}\t${COLOR_NONE}|"		# Steve's choice

    # rejig setting of prompt to not do it all in one go
    # btw. TITLEBAR doesn't seem to be set anywhere!
    if [ -r /etc/debian_chroot ]
    then : "/etc/debian_chroot exists"
        # !!! UNTESTED
        debian_chroot="$(cat /etc/debian_chroot 2> /dev/null)"
#       prompt="${FG_RED_BG_WHITE}$debian_chroot${COLOR_NONE} ${BOLD_YELLOW}$(hostname)${BOLD_GREEN}$(parse_git_branch)${TITLEBAR}${BOLD_BLUE}[${BOLD_RED}\w${BOLD_BLUE}]${COLOR_NONE}"
        prompt="${prompt}${FG_RED_BG_WHITE}${debian_chroot}${COLOR_NONE} "
        prompt="${prompt}${BOLD_YELLOW}$(hostname)${BOLD_GREEN}$(parse_git_branch)${TITLEBAR}"
        prompt="${prompt}${BOLD_BLUE}[${BOLD_RED}\w${BOLD_BLUE}]${COLOR_NONE}"
    elif [ -n "${VIRTUAL_ENV}" ]
    then : "VIRTUAL_ENV=${VIRTUAL_ENV}"
        # !!! UNTESTED
        virtualenviro="$(showvirtualenv 2> /dev/null)"
#       prompt="${FG_RED_BG_WHITE}$virtualenviro${COLOR_NONE} ${BOLD_YELLOW}$(hostname)${TITLEBAR}${BOLD_BLUE}[${BOLD_GREEN}\w${BOLD_BLUE}]${COLOR_NONE}"
        prompt="${prompt}${FG_RED_BG_WHITE}${virtualenviro}${COLOR_NONE} "
        prompt="${prompt}${BOLD_YELLOW}$(hostname)${TITLEBAR}"
        prompt="${prompt}${BOLD_BLUE}[${BOLD_GREEN}\w${BOLD_BLUE}]${COLOR_NONE}"
    else : "fall-thru"
#       prompt="${BOLD_YELLOW}${UNAME}@$(hostname)${BOLD_GREEN}$(parse_git_branch)${TITLEBAR}${BOLD_BLUE}[${BOLD_RED}\w${BOLD_BLUE}]${COLOR_NONE}"
        prompt="${prompt}${USER_AT_HOST}"
        # display where we are
        prompt="${prompt}${BOLD_GREEN}$(parse_git_branch)${COLOR_NONE}${TITLEBAR}"
#       prompt="${prompt}[\w"			# Ian's choice
        prompt="${prompt}:\w"			# Steve's choice
    fi
    prompt="${prompt}]"

    heavy_wideheaded_rightwards_arrow=$'\u2794'
    if test ${previous_return_value} -eq 0
    then
#       PS1="${prompt}➔ "
        #PS1="${prompt}${heavy_wideheaded_rightwards_arrow}"
        # go back to using standard $ and # prompts
        # need double-backslash here
        PS1="${prompt}\\$ "
    else
#       PS1="${prompt}${BOLD_RED}➔${COLOR_NONE} "
        #PS1="${prompt}${BOLD_RED}${heavy_wideheaded_rightwards_arrow}${COLOR_NONE} "
        # go back to using standard $ and # prompts
        PS1="${prompt}${BOLD_RED}\\\$${COLOR_NONE} "
    fi
}

PROMPT_COMMAND=prompt_func
