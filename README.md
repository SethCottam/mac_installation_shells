# TEMP INSTALLERS

## HOW TO STEUP A NEW MAC

1. Open the default Terminal
2. `mkdir ~/.ssh`
3. `cd ~/.ssh`
4. `ssh-keygen -t rsa` then [enter], [enter]
5. `cat id_rsa.pub` then copy the public key

6. Usiing a browser login to the Repo and add the SSH key

7. `cd ~`
8. Git clone from ssh
9. You may be inturupted with a wizard to install additional software which you should install, which may also require attempting the close a second time


## ZSH TMEME
ln -s $HOME/Forge/sethcottam.zsh-theme $HOME/.oh-my-zsh/themes/sethcottam.zsh-theme
ln -s $HOME/forge/sethcottam-multiline.zsh-theme $HOME/.oh-my-zsh/themes/sethcottam-multiline.zsh-theme
edit ~/.zshrc
Change `ZSH_THEME="robbyrussell"` to `ZSH_THEME="sethcottam"` or `ZSH_THEME="sethcottam-multiline"`



## TODO LIST

- brew works from the script but not from command line (?!?), says command not found
	`export PATH=/opt/homebrew/bin:$PATH`

- really need something to handle other settings like `git config pull.rebase false` which establishes using the already default pull method when calling git pull without showing the 12 (!!!) line hint EVERY SINGLE TIME you run git pull. This was such a stupid addition on their part... jerks.

- Sublime need to be setup on the command line

- Moom import/export
- Sublime preferences import/export


