# vim:ft=zsh ts=2 sw=2 sts=2
#
# Original agnoster's Theme - https://gist.github.com/3712874

CURRENT_BG='NONE'  # tracks last segment's bg color

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"  # fix locale for special char
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'  # the ➤-like triangle icon
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"  # set bg color or default
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"  # set fg color or default
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "  # draw connector triangle
  else
    echo -n "%{$bg%}%{$fg%} "  # no connector needed
  fi
  CURRENT_BG=$1  # remember this bg for next segment
  [[ -n $3 ]] && echo -n $3  # print segment text if given
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"  # closing triangle
  else
    echo -n "%{%k%}"  # no bg to close
  fi
  echo -n "%{%f%}"  # reset text color
  CURRENT_BG=''  # reset tracker
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
    prompt_segment 004 015 "%n"  # show username
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return  # skip if git not installed
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"  # fix locale for icon
    PL_BRANCH_CHAR=$'\ue0a0'         # branch icon
  }
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)  # get .git dir path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then  # in a git repo?
    dirty=$(parse_git_dirty)  # check for uncommitted changes
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"  # branch name or short hash
    if [[ -n $dirty ]]; then
      prompt_segment yellow black  # dirty repo color
    else
      prompt_segment 014 002  # clean repo color
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"  # bisecting
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"  # merging
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"  # rebasing
    fi

    setopt promptsubst  # allow live command substitution in prompt
    autoload -Uz vcs_info  # load version-control-info module

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '+'      # symbol for staged changes
    zstyle ':vcs_info:*' unstagedstr '-'    # symbol for unstaged changes
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info  # populate vcs_info_msg_0_
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"  # print branch + status + mode
  fi
}

prompt_bzr() {
    (( $+commands[bzr] )) || return  # skip if bzr not installed
    if (bzr status >/dev/null 2>&1); then  # in a bzr repo?
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`  # modified check
        status_all=`bzr status | head -n1 | wc -m`  # any status check
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`  # get revision number
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment yellow black  # modified files
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment yellow black  # some status, not "modified"
                echo -n "bzr@"$revision

            else
                prompt_segment green black  # clean
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return  # skip if hg not installed
  local rev status
  if $(hg id >/dev/null 2>&1); then  # in an hg repo?
    if $(hg prompt >/dev/null 2>&1); then  # hg prompt extension available?
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white  # untracked files
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black  # modified files
        st='±'
      else
        # if working copy is clean
        prompt_segment green black  # clean
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st  # print rev/branch/status
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')  # get local rev number
      branch=$(hg id -b 2>/dev/null)  # get branch name
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black  # untracked files
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment yellow black  # modified/added files
        st='±'
      else
        prompt_segment green black  # clean
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  # prompt_segment 008 010 $(basename `pwd`)   # disabled: would show folder name
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  if [[ -n $CONDA_PROMPT_MODIFIER ]]; then  # conda env active?
    prompt_segment black default ${CONDA_PROMPT_MODIFIER:1:-2}  # show env name, trimmed
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"          # last command failed
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"          # running as root
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"  # background jobs exist

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"  # show icons if any
}

prompt_head() {
	echo "\r               "  # Clear prevous line
  echo "\r %{%F{8}%}[%64<..<%~%<<]"  # print current dir path, truncated if long
}

## Main prompt
build_prompt() {
  RETVAL=$?           # capture last command's exit code first
  prompt_head          # print dir path line
  prompt_status        # error/root/jobs icons
  prompt_virtualenv    # conda env
  prompt_context       # username
  # prompt_dir         # disabled folder segment
  prompt_git           # git info
  prompt_bzr           # bzr info
  prompt_hg            # hg info
  prompt_end           # close last segment
}

PROMPT='%{%f%b%k%}$(build_prompt) '  # reset styles, then build+show prompt
