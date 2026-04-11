# Makefile Base

>A project skeleton using Makefiles

## About

This project is about providing the basic structure and utilities for operations abstracted by Make recipes

It includes
- managing the automatic creation of an `.env` file for storing environment variables
- an automated helper which parses the recipes comments to present the available commands to the user
- utilities for diverse functionnalities such as checking for newer github projects releases or newer docker immutable tags

### Requirements

- [GNU Make](https://www.gnu.org/software/make/)

### Directory structure

```shell
.
├── make
│   ├── clean.mk
│   ├── deps
│   └── utils
└── Makefile
```

The `Makefile` is the main file invoked by make, it includes all files ending by `.mk` from the `make` directory as sub makefiles.

The `make/deps` directory stores the makefiles to manage automatic installation of dependencies binaries.

The `make/utils` directory holds the makefiles utilities such as base environment variables, messages display management, and so on.

## Usage

You can either clone this repository as a base of your project or use it as a [git subtree](#git-subtree-integration)

The basic usage is to invoke `make` which will display the helper

```shell
$ make
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans The Working Copy
help            💡 Shows This Help Menu
```

## Adding recipes

Here is an example of adding a simple recipe which demonstrates how you can develop your own commands

>Create the file `make/test.mk` with the following content

```shell
.PHONY: test
test: # 🎯 A simple test for demo purpose
    echo test
```

> [!IMPORTANT]
>Make sure to replace the spaces before `echo test` with a tabulation, otherwise make will produce the error `make/test.mk:3: *** missing separator. Exited.`

>Invoke the recipe with `make test` which will just echo `test`

```shell
$ make test
test
```

>Now if you invoke `make` to show the helper, the `test` command will pop-up

```shell
$ make
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans The Working Copy
help            💡 Shows This Help Menu
test            🎯 A simple test for demo purpose
```

### Git Subtree integration

The best suitable way to use this project is to embed it as a git subtree of your project

#### Kick-off a new project

Here is an example of kicking-off a new git repository for holding this project as a subtree

>Init the repository `test`

```shell
git init test
cd test
```

>Add an empty commit

```shell
git commit --allow-empty --message 'init'
```

> [!NOTE]
>This empty commit is required to avoid the git error `fatal: ambiguous argument 'HEAD': unknown revision or path not in the working tree` when adding the subtree

#### Add this project as a Git Subtree

The bellow instructions are for adding this project as a Git Subtree to a new or existing project

>Add this project as git remote

```shell
git remote add -f makefile-base git@github.com:Didier-Lane/makefile-base.git
```

> [!NOTE]
>The bellow example clones this repository through ssh, use `https://github.com/Didier-Lane/makefile-base.git` if you prefer to clone it through the web


>Add this project as a git subtree

```shell
git subtree add --prefix=make/base makefile-base main --squash
```

> [!IMPORTANT]
>The `--prefix=make/base` argument is mandatory because of the [directory structure](#directory-structure) of this project

>At this point the directory structure should look like this

```shell
.
└── make
    └── base
        ├── COPYING
        ├── .editorconfig
        ├── .gitignore
        ├── make
        ├── Makefile
        └── README.md
```

>From here you just have to create a `Makefile` which includes the `make/base/Makefile`

```shell
cat <<EOF > Makefile
include make/base/Makefile
EOF
```

> [!NOTE]
>Copy the `make/base/.gitignore` file to the root directory of the project or add the `.env` line to your existing `.gitignore` file in order to avoid the `.env` file to be staged by git.

>Copy the `make/base/.editorconfig` file to the root directory of your project or add the bellow content to your existing `.editorconfig` file

```shell
[{Makefile,*.mk}]
indent_style = tab
```

You can now start to add [your own recipes](#adding-recipes) to extend functionnalities for your project

#### Update the Git Subtree

>Use the following command to pull changes from this repository to your project Git Subtree

```shell
git subtree pull --prefix=make/base makefile-base main --squash
```
