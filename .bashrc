#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -sh --color'
alias lls='ls -sh --color | less -R'
alias ll='ls -lh -color'
alias ll='ls -lh --color | less -R'
alias b='cd ..'
alias desk='cd ~/Desktop'
alias dl='cd ~/Downloads'
alias docu='cd ~/Documents'
alias home='cd ~'
alias pacman='sudo pacman'

function cl { cd $1; ls;}
function lg { ls | grep $1;}

eval $(dircolors -b ~/.dircolors)

PS1='[\A \u@\h \W]\$ '
#PS1='\[\e[1;32m\][\u@\h \W]\$\[\e[0m\]'


