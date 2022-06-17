alias gc="git checkout"
alias gb="git branch"
alias gp="git pull"
alias gs="git status"
alias gl="git log"
alias oni="/Applications/Onivim2.App/Contents/MacOS/Oni2"
alias activate-conda="export PATH=$HOME/miniconda3/bin:$PATH"

gm() {
  if git branch | grep -q '^[* ]*master$'; then
    git checkout master
  else
    git checkout main
  fi
}

# auto add jira tag to git commits
gitsetupjirahook() {
  write_hook() {
    HOOKS_PATH=$1
    GIT_DIR_PATH=$PWD/.git

    # .git/hooks or .git/modules/<submodule>/hooks
    mkdir -p $HOOKS_PATH

    # Write git hook
    cat <<EOF > $HOOKS_PATH/prepare-commit-msg
#!/bin/bash

# get current branch
branchName=\`GIT_DIR=$GIT_DIR_PATH git rev-parse --abbrev-ref HEAD\`

# search jira issue id in a pattern such a "[feature]/ABC-123-description"
jiraId=\$(echo \$branchName | sed -nr 's,[a-z/]*([A-Z]+-[0-9]+)-.+,\1,p')

# only prepare commit message if pattern matched and jiraId was found
if [[ ! -z \$jiraId ]]; then
 # \$1 is the name of the file containing the commit message
 sed -i.bak -e "1s/^/\$jiraId: /" \$1
 echo Jira \$jiraId added to commit message
fi
EOF

    # Make hook executable
    chmod +x $HOOKS_PATH/prepare-commit-msg
    echo Hook $HOOKS_PATH/prepare-commit-msg added
  }

  # Add hook to root git
  write_hook .git/hooks

  # Add hook to submodules
  for submodule in .git/modules/* ; do
    if [[ -d "$submodule" ]]; then
      write_hook "$submodule/hooks"
    fi
  done
}

