# Makefile Base

>A project skeleton using Makefiles

## About

This project is about providing the basic structure and utilities for operations abstracted by Make recipes

It includes
- managing the [automatic creation of an `.env` file](./make/utils/env.mk) for storing environment variables
- an [automated helper](./make/utils/help.mk) which parses the recipes comments to present the available commands to the user
- diverse functionnalities such as checking for [newer github projects releases](./make/deps/github.mk) or [newer docker immutable tags](./make/deps/dockerhub.mk)

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

- [Makefile](./Makefile) is the main file invoked by make, it controls the inclusion of files ending by `.mk` from the [make](./make) directory as sub makefiles.
- [deps](./make/deps) directory stores the [dependencies](#dependencies) makefiles.
- [utils](./make/utils) directory holds the makefiles utilities such as an [automated helper](./make/utils/help.mk), [messages display management](./make/utils/display.mk), and so on.

## Usage

You can either clone this repository as a base of your project or use it as a [git subtree](#git-subtree-integration).

The basic usage is to invoke `make` which will display the helper.

```shell
$ make
Usage

# To run and execute a target
make <target>

Available Targets

clean           ✨ Cleans the working copy
help            💡 Shows this help menu
```

## Dependencies

Dependencies are makefiles which can be enabled to provide functionnalities, such as installing required binaries or implementing some functions for later use in Make recipes.

Enabling the inclusion of dependencies makefiles is controlled by the `DEPENDENCIES` [environment variable](#environment-variables) when invoking make.

For example the [./make/deps/jq.mk](./make/deps/jq.mk) makefile holds the recipes to download and install [JQ command-line JSON processor](https://github.com/jqlang/jq) through the recipe called `jq`.

To enable the `jq` dependency run the following command when creating [the `.env` file](#the-env-file).

```shell
make DEPENDENCIES=jq
```

Then once the `jq` dependency is enabled, you can use it as a [prerequisite](https://www.gnu.org/software/make/manual/make.html#Rule-Syntax) of a recipe

```shell
test.json: jq
    jq -n '.foo = "bar" | .bar = "foo"' > test.json
```
> [!NOTE]
>The above example will automatically install [JQ](https://github.com/jqlang/jq) when invoking `make test.json` because the `test.json` recipe as `jq` as [prerequisite](https://www.gnu.org/software/make/manual/make.html#Rule-Syntax)

### Special dependencies

Some dependencies are automatically added on the `DEPENDENCIES` [environment variable](#environment-variables) when invoking make when some conditions are met.

| Dependency                  | Makefile                                    | Description           | Condition
|:--                          |:--                                          |:--                    |:--
| `host`                      | [./make/deps/host.mk](./make/deps/host.mk)  | Provides host system informations such as the OS name, the processor architecture and the `BIN_DIR` [environment variable](#user-defined-environment-variables) | `DEPENDENCIES` is not empty and doesn't includes `host`
| `jq`                      | [./make/deps/jq.mk](./make/deps/jq.mk)  | Provides [JQ command-line JSON processor](https://github.com/jqlang/jq) for [github](./make/deps/github.mk) and / or [dockerhub](./make/deps/dockerhub.mk) dependencies | `DEPENDENCIES` contains either `github` or `dockerhub` and doesn't includes `jq`

## Environment variables

### The `.env` file

The `.env` file is responsible for storing [user defined environment variables](#user-defined-environment-variables), such as the list of enabled [dependencies](#dependencies)

It is [automatically created](./make/utils/env.mk) on each invocation of `make`, and can be removed either manually or with the `make clean` recipe.

### User defined environment variables

Those are the variables that are stored in the [the `.env` file](#the-env-file)

| Name                  | Aliases               | Description               | Default value
|:--                    |:--                    |:--                        |:--
| `DEPENDENCIES`        | `DEPS`                | Enables [dependencies](#dependencies) | `null`
| `BIN_DIR`             |                       | The directory where dependencies binairies will be downloaded.<br/>This variable is only available if the `host` [special dependency](#special-dependencies) is enabled | `~/.local/bin`

### Special variables

Those are the variables that are **not** stored in [the `.env` file](#the-env-file)

They can either be overrided through the command line or directly from the main Makefile

| Name                  | Aliases               | Description               | Default value
|:--                    |:--                    |:--                        |:--
| `VERBOSE`             |                       | Enables make recipes verbosity | `undefined`
| `NOCOLORS`            |                       | Disables colored display | `undefined`
| `HELP_HEADER`         |                       | Provides a custom [helper header](./make/utils/help.mk) | `undefined`
| `HELP_LINE_PADDING`   |                       | Defines a custom padding for the [helper](./make/utils/help.mk) lines | `16`

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

## Git Subtree integration

The best suitable way to use this project is to embed it as a git subtree of your project

### Starting a new project

Here is an example of starting a new git repository for holding this project as a subtree

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

### Add this project as a Git Subtree

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

### The `.gitignore` file

Copy the `make/base/.gitignore` file to the root directory of the project or add the `.env` line to your existing `.gitignore` file in order to avoid the `.env` file to be staged by git

### The `.editorconfig` file

Copy the `make/base/.editorconfig` file to the root directory of your project or add the bellow content to your existing `.editorconfig` file

```shell
[{Makefile,*.mk}]
indent_style = tab
```

You can now start to add [your own recipes](#adding-recipes) to extend functionnalities for your project

### Updating the Git Subtree

>Use the following command to pull changes from this repository to your project Git Subtree

```shell
git subtree pull --prefix=make/base makefile-base main --squash
```
