# GitMacStatusBar

this is a tool that allows you to have a status bar icon on your Mac where you can check all your GIT projects.

Never forget to commit a project anymore!

The idea is pretty simple:
- you need to have all projects under GIT in a directory (each project in its own directory obviously)
- you set up your "GIT directory"
- that's all: you will have a nice icon on your status bar!

When you click the icon, you will be able to set a new "GIT directory" and view the status of all your projects inside the selected directory.

So directories should look like:

```sh

/<dir>/projectA
/<dir>/projectB
/<dir>/projectC

```
Every directory contains its .git directory

```sh

/<dir>/projectA/.git/
/<dir>/projectB/.git/
/<dir>/projectC/.git

```

So your "GIT directory" is "dir"


#Install

You wil find in "releases" section .app files.

Just drag them in Applications directory (~/Applications is fine) and add it as login element.


#LICENSE

GNU GPL


#Contributing

Any contribute is always appreciated!
