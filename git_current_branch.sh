# Current git branch for the CWD.
# For using as synthetic sugar in command line prompt.
#
# - Git executable should be in PATH.
# - Git repositories can be given via GIT_REPOS environment variable
#   as a colon (':') delimited list like PATH. It can include globbing.
#   e.g.: GIT_REPOS=/opt/src/*:/home/bdd/code/fshp:/shared/code/*
# - Parameter 1 is prefix and 2 is suffix string to wrap output.
# - You can add this to your PS1 with some synthetic sugar (terminal color)
#   e.g.: PS1='\h:\w\[\033[1;32m\]`git_current_branch "<" ">"`\[\033[0m\]\$ '
#   Which gives you a nice bright green repository name.
#   Example screenshot: http://cdn.mindcast.org/i/PS1-gitbranch.png
# - You can be generous with the list in GIT_REPOS when using globbing.
#   Output is only generated if CWD is a real git repository.
#   GIT_REPOS=/ is possible but c'mon, it's overkill.
#
# Notice: Only works on Bourne Again Shell (BASH)

git_current_branch () {
  local _saved_ifs _branch

  if ! command -v git > /dev/null; then
    return 1
  fi

  _saved_ifs=${IFS}

  IFS=:
  for repo in ${GIT_REPOS}; do
    if [[ ${PWD} =~ ${repo}/* ]]; then
      _branch=`git branch 2> /dev/null`
      if [ $? -eq 0 ]; then
        echo -n "$1`echo ${_branch} | grep '^*' | sed -e 's/\*\ //'`$2"
      fi
    fi
  done
  IFS=${_saved_ifs}
}
