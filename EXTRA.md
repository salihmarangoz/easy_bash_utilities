# Extra Tricks

## Better Bash history

Open `~/.bashrc` and find these lines:

```bash
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
```

and modify them to look like this:

```bash
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
#HISTCONTROL=ignoreboth
export HISTCONTROL=ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
#HISTSIZE=1000
#HISTFILESIZE=2000
export HISTFILESIZE=-1
export HISTSIZE=-1
export HISTTIMEFORMAT="[%F %T] "
```

## Trim Current Working Directory

Sometimes it becomes difficult to use terminal in deep subdirectories and terminal looks like this:

`user@mypc:~/folder1/folder2/folder3/folder4/folder5$ _`

It is possible to make it look like this:

`user@mypc:~/.../folder4/folder5$ _`

Place this line into `~/.bashrc` for it:

```bash
PROMPT_DIRTRIM=2
```

