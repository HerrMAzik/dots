set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx EDITOR nvim
set -gx VISUAL vscodium

set -gx GOPATH $HOME/go
set -gx PATH $PATH $GOPATH/bin
