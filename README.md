# Install required plugins

## Tmux
- Install TPM
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
- Reload the tmux config
```bash
tmux source-file ~/.tmux.conf
```
- Install the plugins
```bash
prefix + I
```

## Vim
- To install 'PlugInstall'
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
- To install Lightline and OSCyank, run `:PlugInstall` inside Vim.
