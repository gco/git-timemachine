# Mercurial time machine

## Installation

Installation alternatives:

- Download hg-timemachine.el and drop it somewhere in your `load-path`.
- If you use `el-get`, simply add `hg-timemachine` to your packages list.
- If you have melpa configured it's available through `package-install`.

## Usage

Visit an hg-controlled file and issue `M-x hg-timemachine` (or
bind it to a keybinding of your choice).

Use the following keys to navigate historic version of the file
 - `p` Visit previous historic version
 - `n` Visit next historic version
 - `w` Copy the hash of the current historic version
 - `q` Exit the time machine.
